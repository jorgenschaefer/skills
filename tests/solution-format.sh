#!/usr/bin/env bash
#
# The tests for the solution format: that `solve/SOLVE_FORMAT.md` specifies a
# spec whose criteria can be traced, and that every solution in the tree holds
# that shape - in both directions.
#
#   tests/solution-format.sh
#
# A solution is the middle of the chain. Its criteria are what tickets copy and
# what the verdict is ultimately measured against, so an untagged criterion is
# work no condition asked for, and a condition no criterion carries is a
# ratified sentence nothing will build. Neither is visible without ids.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
FORMAT="$ROOT/solve/SOLVE_FORMAT.md"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

REQUIRED=("Intent" "Approach" "Behaviour" "Accepted tradeoffs" "Ruled out")
DROPPED=("Domain" "Journeys" "Defaults" "ADRs")

# One criterion per line, however the bullet was wrapped.
criteria_of() {
  section_body "$1" "Behaviour" \
    | awk '/^- \*\*AC-[0-9]+\*\*/{if(c)print c; c=$0; next} c{c=c" "$0} END{if(c)print c}'
}

check_solution() {
  local file="$1" problems="" section
  for section in "${REQUIRED[@]}"; do
    grep -q "^## $section\$" "$file" || problems+="missing section: ## $section"$'\n'
  done

  local body chunks seen claimed
  body="$(section_body "$file" "Behaviour")"
  chunks="$(criteria_of "$file")"
  claimed=$(printf '%s' "$body" | grep -c '\*\*AC-[0-9]\+\*\*')
  seen=$(printf '%s' "$chunks" | grep -c '.' )
  [ "$claimed" -gt 0 ] || problems+="no numbered criteria under ## Behaviour"$'\n'

  # The count the enforcement below sees, against the count the document
  # contains. They diverge when a criterion is indented, or continues a line, or
  # is anything other than a top-level bullet - and a criterion this loop cannot
  # see is a criterion nothing checks.
  [ "$claimed" = "$seen" ] || problems+="$claimed criteria written, $seen readable as bullets: one is shaped so nothing can check it"$'\n'

  local n=0 id
  while IFS= read -r chunk; do
    [ -n "$chunk" ] || continue
    id="$(printf '%s' "$chunk" | grep -o 'AC-[0-9]\+' | head -1 | grep -o '[0-9]\+')"
    n=$((n + 1))
    [ "$id" = "$n" ] || { problems+="criteria are not contiguous: expected AC-$n, found AC-$id"$'\n'; break; }
    printf '%s' "$chunk" | grep -qE '\(([a-z]+:)?C-[0-9]' \
      || problems+="AC-$id carries no condition tag"$'\n'
  done <<< "$chunks"

  local s
  for s in "Accepted tradeoffs" "Ruled out"; do
    [ -n "$(section_body "$file" "$s" | tr -d '[:space:]')" ] || problems+="## $s is empty"$'\n'
  done

  # The other direction: every condition of every intent this solution names is
  # carried by some criterion. This is the half a solution cannot fail by
  # omission from its own text - the missing thing is in another file.
  local intents tags intent prefix cid last
  # Every tag, not just the first of each group: `(cost:C-1, cost:C-3)` is two.
  # The criterion ids go first, because `AC-1` contains `C-1` and would otherwise
  # have every criterion quietly satisfying the condition of the same number.
  tags="$(printf '%s' "$chunks" | sed 's/AC-[0-9]*//g' | grep -oE '([a-z]+:)?C-[0-9]+')"
  intents="$(section_body "$file" "Intent" | grep -o 'INTENT_[A-Z_]*\.md' | sort -u)"
  for intent in $intents; do
    [ -f "$ROOT/$intent" ] || { problems+="## Intent names $intent, which does not exist"$'\n'; continue; }
    # The prefix is declared on the bullet naming the intent, which wraps.
    prefix="$(section_body "$file" "Intent" | grep -A2 -- "$intent" | grep -o '[a-z]\+:C-' | head -1 | sed 's/C-$//')"
    last="$(sed -n '/^## Done when$/,/^## /p' "$ROOT/$intent" | grep -o '\*\*C-[0-9]\+\*\*' | grep -o '[0-9]\+' | tail -1)"
    [ -n "$last" ] || continue
    for cid in $(seq 1 "$last"); do
      printf '%s\n' "$tags" | grep -qx "${prefix}C-$cid" \
        || problems+="${intent%.md}'s ${prefix}C-$cid is carried by no criterion"$'\n'
    done
  done

  printf '%s' "$problems"
}

# --- the format document

TEMPLATE="$(template_of "$FORMAT")"
expect_sections "$TEMPLATE" "$FORMAT" "${REQUIRED[@]}" "Routed back"
expect_dropped "$TEMPLATE" "${DROPPED[@]}"

if printf '%s' "$TEMPLATE" | grep -q '\*\*AC-1\*\*'; then
  ok "the template numbers the criteria"
else
  bad "the template numbers the criteria" "no AC-1: nothing could copy a criterion into a ticket"
fi

if printf '%s' "$TEMPLATE" | grep -qE '\(([a-z]+:)?C-[0-9]'; then
  ok "the template tags criteria with conditions"
else
  bad "the template tags criteria with conditions" "no C-n tag: the chain back to the intent is broken"
fi

# --- every solution in the tree

shopt -s nullglob
solutions=0
for f in "$ROOT"/SOLUTION_*.md; do
  name="$(basename "$f")"
  solutions=$((solutions + 1))
  problems="$(check_solution "$f")"
  if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
done
expect_counted "$solutions" "solutions"

# --- and the checker catches what it claims to

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ROOT_REAL="$ROOT"

make_solution() {
  cat > "$tmp/SOLUTION_X.md" <<EOF
# Solution: x

## Intent
INTENT_X.md

## Approach
x

## Behaviour
$1

## Accepted tradeoffs
$2

## Ruled out
- doing nothing, because x
EOF
  cat > "$tmp/INTENT_X.md" <<EOF
## Done when
- **C-1** a
- **C-2** b

## Constraints
EOF
}

# The fixtures live in their own tree, so the reverse walk resolves there.
ROOT="$tmp"

make_solution "- **AC-1** a *(C-1)*
- **AC-2** b
  *(C-2)*" "- costs x"
result="$(check_solution "$tmp/SOLUTION_X.md")"
[ -z "$result" ] && ok "a well-formed solution passes" || bad "a well-formed solution passes" "$result"

make_solution "- **AC-1** a *(C-1)*
- **AC-3** b *(C-2)*" "- costs x"
case "$(check_solution "$tmp/SOLUTION_X.md")" in
  *"not contiguous"*) ok "a gap in the criteria is caught" ;;
  *) bad "a gap in the criteria is caught" "accepted AC-1 followed by AC-3" ;;
esac

make_solution "- **AC-1** a *(C-1)*
- **AC-2** b" "- costs x"
case "$(check_solution "$tmp/SOLUTION_X.md")" in
  *"carries no condition tag"*) ok "an untagged criterion is caught" ;;
  *) bad "an untagged criterion is caught" "accepted a criterion no condition asked for" ;;
esac

make_solution "- **AC-1** a *(C-1)*
- **AC-2** b *(C-1)*" "- costs x"
case "$(check_solution "$tmp/SOLUTION_X.md")" in
  *"C-2 is carried by no criterion"*) ok "a condition nothing builds is caught" ;;
  *) bad "a condition nothing builds is caught" "accepted an intent condition no criterion carries" ;;
esac

make_solution "  - **AC-1** a *(C-1)*
  - **AC-2** b *(C-2)*" "- costs x"
case "$(check_solution "$tmp/SOLUTION_X.md")" in
  *"shaped so nothing can check it"*) ok "criteria the checker cannot see are caught" ;;
  *) bad "criteria the checker cannot see are caught" "indenting every criterion hid them all" ;;
esac

make_solution "- **AC-1** a *(C-1)*
- **AC-2** b *(C-2)*" ""
case "$(check_solution "$tmp/SOLUTION_X.md")" in
  *"Accepted tradeoffs is empty"*) ok "an empty tradeoff list is caught" ;;
  *) bad "an empty tradeoff list is caught" "accepted a solution that costs nothing" ;;
esac

ROOT="$ROOT_REAL"
finish
