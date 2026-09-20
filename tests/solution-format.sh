#!/usr/bin/env bash
#
# The tests for the solution format: that `solve/SOLUTION_FORMAT.md` specifies a
# spec whose criteria can be traced, and that every solution in the tree holds
# that shape.
#
#   tests/solution-format.sh
#
# A solution is the middle of the chain. Its criteria are what tickets copy and
# what the verdict is ultimately measured against, so an untagged criterion is a
# criterion no condition asked for, and a condition no criterion carries is a
# condition nothing will build. Both are invisible without ids.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
# `solve/FORMAT.md`, not `SOLUTION_FORMAT.md`: the superseded copies in
# `to-solution/` and `spec-to-tickets/` still carry that name, and the repo requires
# every copy of a shared format file to be byte-identical. The name comes back when
# those two skills go.
FORMAT="$ROOT/solve/FORMAT.md"
passed=0 failed=0

ok()  { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
        [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }

REQUIRED=("Intent" "Approach" "Behaviour" "Accepted tradeoffs" "Ruled out")

# The sections the lean format drops. They are listed by name because dropping
# them was a decision, and a decision that quietly reverts is worse than one
# never made.
DROPPED=("Domain" "Journeys" "Defaults" "ADRs")

section_body() { sed -n "/^## $2\$/,/^## /p" "$1" | sed '1d;/^## /d'; }

check_solution() {
  local file="$1" problems="" section
  for section in "${REQUIRED[@]}"; do
    grep -q "^## $section\$" "$file" || problems+="missing section: ## $section"$'\n'
  done

  # Criteria are AC-1..AC-n, contiguous, and each carries at least one condition
  # tag - `(C-2)`, or `(cost:C-2)` where the solution answers more than one intent.
  local body n=0
  body="$(section_body "$file" "Behaviour")"
  if [ -z "$(printf '%s' "$body" | grep -o '\*\*AC-[0-9]\+\*\*')" ]; then
    problems+="no numbered criteria under ## Behaviour"$'\n'
  fi
  while IFS= read -r chunk; do
    [ -n "$chunk" ] || continue
    local id
    id="$(printf '%s' "$chunk" | grep -o 'AC-[0-9]\+' | head -1 | grep -o '[0-9]\+')"
    n=$((n + 1))
    [ "$id" = "$n" ] || { problems+="criteria are not contiguous: expected AC-$n, found AC-$id"$'\n'; break; }
    printf '%s' "$chunk" | grep -qE '\(([a-z]+:)?C-[0-9]' \
      || problems+="AC-$id carries no condition tag"$'\n'
  done < <(printf '%s\n' "$body" | awk '/^- \*\*AC-[0-9]+\*\*/{if(c)print c; c=$0; next} c{c=c" "$0} END{if(c)print c}')

  # A tradeoff list with nothing in it, or a field of one candidate, is the
  # failure this format exists to prevent: a choice presented as inevitable.
  local s
  for s in "Accepted tradeoffs" "Ruled out"; do
    [ -n "$(section_body "$file" "$s" | tr -d '[:space:]')" ] || problems+="## $s is empty"$'\n'
  done

  printf '%s' "$problems"
}

# --- the format document

if [ -f "$FORMAT" ]; then
  TEMPLATE="$(sed -n '/^```markdown$/,/^```$/p' "$FORMAT")"
else
  TEMPLATE=""
  bad "the format document exists" "no $FORMAT"
fi

for section in "${REQUIRED[@]}"; do
  if printf '%s' "$TEMPLATE" | grep -q "^## $section\$"; then
    ok "the template specifies ## $section"
  else
    bad "the template specifies ## $section" "not in the fenced block of $FORMAT"
  fi
done

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

for section in "${DROPPED[@]}"; do
  if printf '%s' "$TEMPLATE" | grep -q "^#\+ $section\$"; then
    bad "the template drops ## $section" "still present: it was dropped deliberately"
  else
    ok "the template drops ## $section"
  fi
done

# --- every solution in the tree

shopt -s nullglob
solutions=0
for f in "$ROOT"/SOLUTION_*.md; do
  name="$(basename "$f")"
  solutions=$((solutions + 1))
  problems="$(check_solution "$f")"
  if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
done
[ "$solutions" -gt 0 ] \
  && ok "there are solutions to check" \
  || bad "there are solutions to check" "no SOLUTION_*.md found: the cases above checked nothing"

# --- and the checker catches what it claims to

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

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
}

make_solution "- **AC-1** a *(C-1)*
- **AC-2** b
  *(cost:C-2)*" "- costs x"
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

make_solution "- **AC-1** a *(C-1)*" ""
case "$(check_solution "$tmp/SOLUTION_X.md")" in
  *"Accepted tradeoffs is empty"*) ok "an empty tradeoff list is caught" ;;
  *) bad "an empty tradeoff list is caught" "accepted a solution that costs nothing" ;;
esac

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
