#!/usr/bin/env bash
#
# The tests for the intent format: that `idea/INTENT_FORMAT.md` specifies the
# shape everything downstream addresses, and that every intent in the tree
# actually holds that shape.
#
#   tests/intent-format.sh
#
# An intent is the only artifact written before anything else exists, and the
# only one a person ratifies. Every later stage addresses it by section and by
# condition id, so a drifting intent is not a cosmetic problem: `/solve` tags
# criteria against `C-n`, and `/accept` walks them back. These cases are those
# expectations, written down where they can fail.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
FORMAT="$ROOT/idea/INTENT_FORMAT.md"
passed=0 failed=0

ok()  { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
        [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }

# The sections every intent carries. `Not this`, `Whatever they arrived with`
# and `Open questions` are real but conditional, so they are not checked here.
REQUIRED=("Problem" "Evidence" "Done when" "Constraints" "Ratified" "Routed back")

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

  # An unratified intent is a draft. Saying so is fine; saying nothing is not.
  local ratified
  ratified=$(sed -n '/^## Ratified$/,/^## /p' "$file" | sed '1d;/^## /d' | tr -d '[:space:]')
  [ -n "$ratified" ] || problems+="## Ratified is empty"$'\n'

  printf '%s' "$problems"
}

# --- the format document itself

for section in "${REQUIRED[@]}"; do
  if grep -q "^## $section\$" "$FORMAT"; then
    ok "format specifies ## $section"
  else
    bad "format specifies ## $section" "not found in $FORMAT"
  fi
done

if grep -q 'C-1' "$FORMAT"; then
  ok "format numbers the conditions"
else
  bad "format numbers the conditions" "no C-1 in the template: nothing downstream could cite a condition"
fi

if grep -q 'Proposed outcome' "$FORMAT"; then
  bad "format drops the unnumbered Proposed outcome" "still present"
else
  ok "format drops the unnumbered Proposed outcome"
fi

# --- every intent in the tree

shopt -s nullglob
for f in "$ROOT"/INTENT_*.md; do
  name="$(basename "$f")"
  problems="$(check_intent "$f")"
  if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
done

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

## Ratified
$2

## Routed back
Nothing yet.
EOF
}

make_intent "- **C-1** a
- **C-2** b" "yes, by someone"
[ -z "$(check_intent "$tmp/INTENT_X.md")" ] \
  && ok "a well-formed intent passes" \
  || bad "a well-formed intent passes" "$(check_intent "$tmp/INTENT_X.md")"

make_intent "- **C-1** a
- **C-3** b" "yes, by someone"
case "$(check_intent "$tmp/INTENT_X.md")" in
  *"not contiguous"*) ok "a gap in the numbering is caught" ;;
  *) bad "a gap in the numbering is caught" "accepted C-1 followed by C-3" ;;
esac

make_intent "- **C-1** a" ""
case "$(check_intent "$tmp/INTENT_X.md")" in
  *"Ratified is empty"*) ok "an empty ratification is caught" ;;
  *) bad "an empty ratification is caught" "accepted a blank ## Ratified" ;;
esac

make_intent "Anyone could tell whether this holds." "yes, by someone"
case "$(check_intent "$tmp/INTENT_X.md")" in
  *"no numbered conditions"*) ok "unnumbered conditions are caught" ;;
  *) bad "unnumbered conditions are caught" "accepted prose under ## Done when" ;;
esac

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
