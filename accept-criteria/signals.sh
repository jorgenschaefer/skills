#!/usr/bin/env bash
#
# The files a change touched that usually carry a decision the person answers
# for, found by name rather than judged. A floor, not the walk: routes, config
# reads and outgoing calls look different in every framework, and are left to
# whoever reads the diff.
#
#   signals.sh changes/<slug>
#
# Prints the base the change's diff is taken from, then one line per file:
# its kind, a tab, its path.
#
# The base is found as run/report.sh's review_base finds it, from the paper
# rather than from tickets/: a one-ticket change never meets the runner. The
# two agree because criteria-to-tickets commits CRITERIA.md and its tickets
# together; a skill installs alone, so the rule is held here twice.

set -euo pipefail

change="${1:?usage: signals.sh changes/<slug>}"
change="${change%/}"

# The change's diff starts before its paper did: the commit before the first
# one that added anything under its directory.
added="$(git log --diff-filter=A --format=%H -- "$change" | tail -1)"
if [ -z "$added" ]; then
  echo "signals.sh: nothing under $change was ever committed" >&2
  exit 1
fi
base="$(git rev-parse -q --verify "$added^" || git hash-object -t tree /dev/null)"
printf 'base\t%s\n' "$base"

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

git diff --name-only "$base" -- . ":(exclude)$change" | while IFS= read -r path; do
  k="$(kind "$path")"
  [ -z "$k" ] || printf '%s\t%s\n' "$k" "$path"
done
