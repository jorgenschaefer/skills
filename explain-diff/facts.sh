#!/usr/bin/env bash
#
# The facts of a commit range that an explanation of it must not miss, found
# by git and by file name rather than judged.
#
#   facts.sh <A> <B>
#
# Prints one fact per line, its kind first and the fields after it, each
# separated by a tab:
#
#   range     <sha of A> <sha of B>
#   size      <commits> <files> <insertions> <deletions>
#   worktree  at B | not at B
#   links     <https://github.com/owner/repo> | none
#   claim     <sha> <path>     a file of a changes/<slug>/ directory, at the
#                              last commit of the range that still had it
#   decision  <kind> <path>    a file that usually carries a decision
#   deleted   <path>           a file B no longer has
#   tests     <status> <path> <declarations added> <declarations removed>
#             <skips added>
#
# The kinds of `decision` are accept-criteria's signals.sh's; a skill installs
# alone, so the list is held there and here.

set -euo pipefail

A="$(git rev-parse --verify -q "${1:?usage: facts.sh <A> <B>}^{commit}")" || { echo "facts.sh: no commit $1" >&2; exit 1; }
B="$(git rev-parse --verify -q "${2:?usage: facts.sh <A> <B>}^{commit}")" || { echo "facts.sh: no commit $2" >&2; exit 1; }
printf 'range\t%s\t%s\n' "$A" "$B"

read -r files ins del < <(git diff --numstat "$A" "$B" | awk '{f++; if ($1 != "-") i += $1; if ($2 != "-") d += $2} END {print f+0, i+0, d+0}')
printf 'size\t%s\t%s\t%s\t%s\n' "$(git rev-list --count "$A..$B")" "$files" "$ins" "$del"

# A checkout past B shows the wrong files to whoever reads the working tree.
if [ "$(git rev-parse HEAD)" = "$B" ] && git diff --quiet HEAD; then
  printf 'worktree\tat B\n'
else
  printf 'worktree\tnot at B\n'
fi

origin="$(git remote get-url origin 2>/dev/null || true)"
case "$origin" in
  git@github.com:*)     repo="${origin#git@github.com:}" ;;
  https://github.com/*) repo="${origin#https://github.com/}" ;;
  ssh://git@github.com/*) repo="${origin#ssh://git@github.com/}" ;;
  *) repo="" ;;
esac
if [ -n "$repo" ]; then
  printf 'links\thttps://github.com/%s\n' "${repo%.git}"
else
  printf 'links\tnone\n'
fi

# What the change said it would do. accept-criteria deletes a change's
# directory in the change's last commit, so it is read where it last stood.
git log --format= --name-only "$A..$B" -- changes/ |
  awk -F/ 'NF > 2 && $2 != "backlog" {print $1 "/" $2}' | sort -u |
  while IFS= read -r dir; do
    if git cat-file -e "$B:$dir" 2>/dev/null; then
      at="$B"
    else
      at="$(git log --diff-filter=D --format=%H -1 "$A..$B" -- "$dir")^"
      at="$(git rev-parse "$at")"
    fi
    git ls-tree -r --name-only "$at" -- "$dir" | while IFS= read -r path; do
      printf 'claim\t%s\t%s\n' "$at" "$path"
    done
  done

kind() {  # path -> its kind, or nothing
  local name="${1##*/}"
  case "$name" in
    package.json|package-lock.json|npm-shrinkwrap.json|yarn.lock|pnpm-lock.yaml|bun.lockb|go.mod|go.sum|\
    Cargo.toml|Cargo.lock|pyproject.toml|poetry.lock|uv.lock|requirements*.txt|setup.py|setup.cfg|\
    Pipfile|Pipfile.lock|Gemfile|Gemfile.lock|*.gemspec|composer.json|composer.lock|pom.xml|\
    build.gradle|build.gradle.kts|gradle.lockfile|*.csproj|packages.lock.json|Package.swift|Package.resolved|\
    mix.exs|mix.lock|flake.nix|flake.lock|deno.json|deno.lock|.terraform.lock.hcl|.gitmodules)
      echo dependencies; return ;;
    *.proto|openapi.*|swagger.*|*.graphql|*.gql|*.avsc|*.env.example)
      echo "wire formats"; return ;;
    *.sql|schema.*|*.prisma)
      echo "stored formats"; return ;;
    Dockerfile|Dockerfile.*|*.dockerfile|docker-compose*.y*ml|compose*.y*ml|Procfile|crontab|*.tf|*.tfvars)
      echo operations; return ;;
    CLAUDE.md|CODEOWNERS)
      echo "agreed rules"; return ;;
  esac
  case "$1" in
    *migrat*|*alembic/versions/*) echo "stored formats" ;;
    .github/workflows/*|.gitlab-ci.yml|.circleci/*|charts/*|k8s/*|helm/*) echo operations ;;
    docs/adr/*) echo "agreed rules" ;;
  esac
}

is_test() {  # path -> true if it names a test file
  case "$1" in
    */__tests__/*|__tests__/*|test/*|tests/*|*/test/*|*/tests/*|spec/*|*/spec/*) return 0 ;;
  esac
  case "${1##*/}" in
    *.test.*|*.spec.*|*_test.*|*_spec.*|test_*.py|*Test.java|*Tests.java|*Test.kt|*Tests.cs) return 0 ;;
  esac
  return 1
}

# A removed test declaration or an added skip is how a change gets past its
# own tests; both are counted, never judged. Added declarations are counted
# beside the removed ones, since a renamed test is one of each.
declaration='[[:space:]]*((it|test|describe|context)(\.[a-z]+)?[[:space:]]*\(|def test_|func Test|@Test|#\[test\])'
skip_re='^\+.*(\.skip[[:space:]]*\(|\bxit[[:space:]]*\(|\bxdescribe[[:space:]]*\(|\.todo[[:space:]]*\(|@pytest\.mark\.skip|@unittest\.skip|@Disabled|@Ignore|t\.Skip\(|#\[ignore\])'

git diff --name-status --no-renames "$A" "$B" -- . ':(exclude)changes/' |
  while IFS=$'\t' read -r status path; do
    k="$(kind "$path")"
    [ -z "$k" ] || printf 'decision\t%s\t%s\n' "$k" "$path"
    [ "$status" != D ] || printf 'deleted\t%s\n' "$path"
    if is_test "$path"; then
      patch="$(git diff "$A" "$B" -- "$path")"
      added="$(grep -cE "^\+$declaration" <<<"$patch" || true)"
      removed="$(grep -cE "^-$declaration" <<<"$patch" || true)"
      skips="$(grep -cE "$skip_re" <<<"$patch" || true)"
      printf 'tests\t%s\t%s\t%s\t%s\t%s\n' "$status" "$path" "$added" "$removed" "$skips"
    fi
  done
