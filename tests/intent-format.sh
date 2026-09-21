#!/usr/bin/env bash
#
# The tests for the intent format: that `idea/INTENT_FORMAT.md` specifies the
# shape everything downstream addresses, and that every intent in the tree
# actually holds that shape.
#
#   tests/intent-format.sh
#
# An intent is the only artifact written before anything else exists. Every
# later stage addresses it by section and by condition id, so a drifting intent
# is not a cosmetic problem: `/solve` tags criteria against `C-n`, and
# `/accept-intent` walks them back. These cases are those expectations, written
# down where they can fail.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
FORMAT="$ROOT/idea/INTENT_FORMAT.md"
# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

# The sections every intent carries. `Not this`, `User's solution`
# and `Open questions` are real but conditional, so they are not checked here.
REQUIRED=("Problem" "Evidence" "Done when" "Constraints")

# Reports what is wrong with one intent, or nothing at all. Kept as a function
# rather than a script because the adversary that will do this for real is
# `/verify`, and duplicating it as a tool now would be two things to keep true.
check_intent() {
  local file="$1" problems=""
  local section
  for section in "${REQUIRED[@]}"; do
    grep -q "^## $section\$" "$file" || problems+="missing section: ## $section"$'\n'
  done

  # Conditions are C-1..C-n, contiguous and in order. Gaps mean a condition was
  # deleted rather than struck through, and the ids are append-only precisely so
  # that a tag written elsewhere keeps pointing at what it pointed at.
  local ids n=0 id
  ids=$(sed -n '/^## Done when$/,/^## /p' "$file" | grep -o '\*\*C-[0-9]\+\*\*' | grep -o '[0-9]\+')
  [ -n "$ids" ] || problems+="no numbered conditions under ## Done when"$'\n'
  for id in $ids; do
    n=$((n + 1))
    [ "$id" = "$n" ] || { problems+="conditions are not contiguous: expected C-$n, found C-$id"$'\n'; break; }
  done

  printf '%s' "$problems"
}

# Given paths, check those and nothing else. This is how `/verify` asks about the
# artifact in front of it: the mechanical half of its contract is already written
# down here, and re-deriving it by reading would be slower and less exact.
if [ "$#" -gt 0 ]; then
  for f in "$@"; do
    name="$(basename "$f")"
    if [ ! -f "$f" ]; then bad "$name conforms" "no such file: $f"; continue; fi
    problems="$(check_intent "$f")"
    if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
  done
  finish
  exit
fi

# --- the format document itself

TEMPLATE="$(template_of "$FORMAT")"
expect_sections "$TEMPLATE" "$FORMAT" "${REQUIRED[@]}"
expect_dropped "$TEMPLATE" "Proposed outcome" "Affected"

if printf '%s' "$TEMPLATE" | grep -q '\*\*C-1\*\*'; then
  ok "the template numbers the conditions"
else
  bad "the template numbers the conditions" "no C-1: nothing downstream could cite a condition"
fi

# --- every intent in the tree

shopt -s nullglob
intents=0
for f in "$ROOT"/INTENT_*.md; do
  name="$(basename "$f")"
  intents=$((intents + 1))
  problems="$(check_intent "$f")"
  if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
done
expect_counted "$intents" "intents"

# The fixtures and the single-file case run only at the top level: that case
# re-runs this suite, and a child that ran the fixtures would do so forever.
[ -z "${FORMAT_SUITE_CHILD:-}" ] || { finish; exit; }

# --- and the checker itself catches what it claims to

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

make_intent() {
  cat > "$tmp/INTENT_X.md" <<EOF
# Intent: x

## Problem
x

## Evidence
x

## Done when
$1

## Constraints
x
EOF
}

make_intent "- **C-1** a
- **C-2** b"
result="$(check_intent "$tmp/INTENT_X.md")"
[ -z "$result" ] \
  && ok "a well-formed intent passes" \
  || bad "a well-formed intent passes" "$result"

make_intent "- **C-1** a
- **C-3** b"
case "$(check_intent "$tmp/INTENT_X.md")" in
  *"not contiguous"*) ok "a gap in the numbering is caught" ;;
  *) bad "a gap in the numbering is caught" "accepted C-1 followed by C-3" ;;
esac

make_intent "Anyone could tell whether this holds."
case "$(check_intent "$tmp/INTENT_X.md")" in
  *"no numbered conditions"*) ok "unnumbered conditions are caught" ;;
  *) bad "unnumbered conditions are caught" "accepted prose under ## Done when" ;;
esac

# --- and it can be pointed at one artifact
#
# `/verify` reviews the artifact of one stage, not the tree. Without this it
# would have to re-derive by reading what a grep already knows.

make_intent "- **C-1** a"
out="$(FORMAT_SUITE_CHILD=1 timeout 20 "$0" "$tmp/INTENT_X.md" 2>&1)"; rc=$?
case "$out:$rc" in
  *"ok    INTENT_X.md conforms"*":0") ok "a path checks that file" ;;
  *) bad "a path checks that file" "rc=$rc"$'\n'"$out" ;;
esac
case "$out" in
  *"INTENT_PROCESS_COST"*) bad "a path checks nothing else" "the tree was walked too" ;;
  *) ok "a path checks nothing else" ;;
esac

finish
