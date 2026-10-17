#!/usr/bin/env bash
#
# The tests for explain-diff's scripts: the facts facts.sh finds in a range,
# and the references check-refs.sh lets through.
#
#   tests/explain-diff.sh
#
# Each case builds a throwaway repository, because both read its history.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
FACTS="$HERE/../explain-diff/facts.sh"
CHECK_REFS="$HERE/../explain-diff/check-refs.sh"

# shellcheck source=lib.sh
. "$HERE/lib.sh"

WORKSPACES=()
cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

# A repository with a source file, a test and a rule from before the change;
# A is its first commit.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  mkdir -p "$WORK/src"
  printf 'one\ntwo\nthree\n' > "$WORK/src/app.js"
  printf 'it("adds", () => {});\nit("subtracts", () => {});\n' > "$WORK/src/app.test.js"
  echo rule > "$WORK/src/rule.js"
  git -C "$WORK" add . && git -C "$WORK" commit -qm before
  A="$(git -C "$WORK" rev-parse HEAD)"
}
commit() { git -C "$WORK" add -A && git -C "$WORK" commit -qm "$1"; }
facts() { ( cd "$WORK" && "$FACTS" "$A" "${1:-HEAD}" ); }
has() {  # name, expected line, output
  if grep -qxF -- "$2" <<<"$3"; then ok "$1"; else bad "$1" "expected: $2"$'\n'"got: $3"; fi
}

# --- facts.sh -----------------------------------------------------------------

workspace
mkdir -p "$WORK/changes/2026-01-01-x" "$WORK/changes/backlog"
echo criteria > "$WORK/changes/2026-01-01-x/CRITERIA.md"
echo idea > "$WORK/changes/backlog/later.md"
commit paper
echo '{}' > "$WORK/package.json"
git -C "$WORK" rm -q src/rule.js
printf 'it("adds", () => {});\nit.skip("multiplies", () => {});\n' > "$WORK/src/app.test.js"
commit build
paper="$(git -C "$WORK" rev-parse HEAD)"
git -C "$WORK" rm -rq changes/2026-01-01-x
commit accept
B="$(git -C "$WORK" rev-parse HEAD)"
out="$(facts)"

has "the range is named by its full shas" "range	$A	$B" "$out"
# The criteria come and go inside the range, so the diff holds the four others.
has "the size counts commits, files, insertions and deletions" "size	3	4	3	2" "$out"
has "a change directory deleted in the range is read where it last stood" \
  "claim	$paper	changes/2026-01-01-x/CRITERIA.md" "$out"
if ! grep -q 'backlog' <<<"$out"; then
  ok "the backlog is no claim"
else bad "the backlog is no claim" "$out"; fi
has "a dependency file is named as a decision" "decision	dependencies	package.json" "$out"
has "a deleted file is named" "deleted	src/rule.js" "$out"
has "a test counts declarations added, removed and skips added" "tests	M	src/app.test.js	1	1	1" "$out"
if ! grep -q $'^tests\t.*src/app.js' <<<"$out"; then
  ok "a source file is no test"
else bad "a source file is no test" "$out"; fi
has "a checkout at B says so" "worktree	at B" "$out"
has "a repository without a remote has no links" "links	none" "$out"

git -C "$WORK" checkout -q "$A"
has "a checkout behind B says so" "worktree	not at B" "$(facts "$B")"
git -C "$WORK" checkout -q main

echo dirty >> "$WORK/src/app.js"
has "uncommitted changes are not B" "worktree	not at B" "$(facts)"
git -C "$WORK" checkout -q -- src/app.js

workspace
mkdir -p "$WORK/changes/2026-01-01-x"
echo criteria > "$WORK/changes/2026-01-01-x/CRITERIA.md"
commit paper
B="$(git -C "$WORK" rev-parse HEAD)"
has "a change directory still there at B is read at B" \
  "claim	$B	changes/2026-01-01-x/CRITERIA.md" "$(facts)"

for origin in git@github.com:o/r.git https://github.com/o/r.git ssh://git@github.com/o/r https://github.com/o/r; do
  git -C "$WORK" remote remove origin 2>/dev/null || true
  git -C "$WORK" remote add origin "$origin"
  has "a GitHub origin $origin links to its web address" "links	https://github.com/o/r" "$(facts)"
done

if ! ( cd "$WORK" && "$FACTS" "$A" no-such-ref ) 2>/dev/null; then
  ok "a ref that names no commit is refused"
else bad "a ref that names no commit is refused"; fi

# --- check-refs.sh ------------------------------------------------------------

workspace
git -C "$WORK" rm -q src/rule.js
echo four >> "$WORK/src/app.js"
commit build
B="$(git -C "$WORK" rev-parse HEAD)"
PAGE="$WORK/page.html"
check_refs() { ( cd "$WORK" && "$CHECK_REFS" "$PAGE" "$A" "$B" ); }

printf '<a data-f="src/app.js:4"></a><a data-a="src/rule.js:1"></a><a data-c="%s"></a>\n' "$B" > "$PAGE"
if out="$(check_refs)" && [ "$out" = "checked	3" ]; then
  ok "references to a line at B, a line at A and a commit pass"
else bad "references to a line at B, a line at A and a commit pass" "$out"; fi

for ref in 'data-f="src/app.js:5"' 'data-f="src/rule.js:1"' 'data-a="src/app.js:4"' \
           'data-f="src/app.js:0"' 'data-f="src/app.js"' 'data-c="0000000"'; do
  printf '<a data-f="src/app.js:1"></a><a %s></a>\n' "$ref" > "$PAGE"
  if ! out="$(check_refs)" && grep -q 'broken' <<<"$out"; then
    ok "a broken reference fails: $ref"
  else bad "a broken reference fails: $ref" "$out"; fi
done

echo '<p>no evidence</p>' > "$PAGE"
if ! check_refs 2>/dev/null; then
  ok "a page without references fails"
else bad "a page without references fails"; fi

finish
