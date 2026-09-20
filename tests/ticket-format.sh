#!/usr/bin/env bash
#
# The tests for the ticket format: that `slice/SLICE_FORMAT.md` specifies the
# unit an unattended run consumes, and that every ticket in the tree holds that
# shape - including the one property the whole design rests on, that a ticket's
# criteria are copied from its solution rather than summarised.
#
#   tests/ticket-format.sh [ticket ...]
#
# A ticket is what a session is handed when nobody is watching. It carries its
# criteria verbatim because that is what replaced the spec hash: a ticket that
# quotes its solution cannot be silently redefined by an edit to it, and a
# ticket that paraphrases has already redefined itself.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
FORMAT="$ROOT/slice/SLICE_FORMAT.md"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

REQUIRED=("Build" "Done when" "Context" "Not here")
KEYS=("solution" "satisfies" "after" "status" "attempts" "reviews")

frontmatter() { sed -n '2,/^---$/p' "$1"; }
key_of() { frontmatter "$1" | sed -n "s/^$2: *//p" | head -1; }

# Whitespace and wrapping differ between a bullet in a spec and a blockquote in
# a ticket; nothing else may.
# The quote marker and the bullet are the shapes the same words take in the two
# documents; the words themselves are what has to match.
flatten() { sed 's/^[[:space:]]*[->][[:space:]]*//' | tr '\n' ' ' | sed 's/  */ /g; s/^ //; s/ *$//'; }

criterion_text() {  # solution, id -> the criterion as written, tag stripped
  sed -n "/^- \*\*$2\*\*/,/^- \*\*AC-/p" "$1" \
    | sed '$ { /^- \*\*AC-/d; }' \
    | sed 's/\*([a-z:, C0-9-]*)\*//' \
    | flatten
}

check_ticket() {
  local file="$1" problems="" key section
  for key in "${KEYS[@]}"; do
    frontmatter "$file" | grep -q "^$key:" || problems+="frontmatter has no $key"$'\n'
  done
  for section in "${REQUIRED[@]}"; do
    grep -q "^## $section\$" "$file" || problems+="missing section: ## $section"$'\n'
  done

  case "$(key_of "$file" status)" in
    ready|doing|review|done|halted) ;;
    *) problems+="status is not one the runner knows: $(key_of "$file" status)"$'\n' ;;
  esac

  local solution ids quoted id
  solution="$(key_of "$file" solution)"
  ids="$(key_of "$file" satisfies | tr ',' ' ')"
  [ -n "$ids" ] || problems+="satisfies is empty: this ticket serves no criterion"$'\n'

  if [ ! -f "$ROOT/$solution" ]; then
    problems+="solution: names $solution, which is not there"$'\n'
  else
    # The claim and the quotation have to agree, both ways: a criterion claimed
    # and not quoted is a criterion the builder never sees, and one quoted and
    # not claimed is work no coverage check knows about.
    quoted="$(grep -o '^> \*\*AC-[0-9]\+\*\*' "$file" | grep -o 'AC-[0-9]\+' | sort -u | tr '\n' ' ')"
    for id in $ids; do
      printf '%s' "$quoted" | grep -qw "$id" || problems+="$id is claimed but not quoted"$'\n'
    done
    for id in $quoted; do
      printf '%s' "$ids" | grep -qw "$id" || problems+="$id is quoted but not claimed"$'\n'
    done

    for id in $ids; do
      local want got
      want="$(criterion_text "$ROOT/$solution" "$id")"
      got="$(sed -n "/^> \*\*$id\*\*/,/^$/p" "$file" | flatten)"
      [ -n "$want" ] || { problems+="$id is not in $solution"$'\n'; continue; }
      case "$want " in
        "$got"*) ;;
        *) problems+="$id is not quoted verbatim from $solution"$'\n'"    spec:   $want"$'\n'"    ticket: $got"$'\n' ;;
      esac
    done
  fi
  printf '%s' "$problems"
}

# Given paths, check those and nothing else - how `/verify` asks about a slicing.
if [ "$#" -gt 0 ]; then
  for f in "$@"; do
    name="$(basename "$f")"
    if [ ! -f "$f" ]; then bad "$name conforms" "no such file: $f"; continue; fi
    problems="$(check_ticket "$f")"
    if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
  done
  finish
  exit
fi

# --- the format document

TEMPLATE="$(template_of "$FORMAT")"
expect_sections "$TEMPLATE" "$FORMAT" "${REQUIRED[@]}" "Record" "Findings" "Halt"

for key in "${KEYS[@]}"; do
  if printf '%s' "$TEMPLATE" | grep -q "^$key:"; then
    ok "the template carries $key"
  else
    bad "the template carries $key" "not in the fenced block of $FORMAT"
  fi
done

# --- every ticket in the tree

shopt -s nullglob
tickets=0
for f in "$ROOT"/tickets/*/*.md; do
  name="$(basename "$(dirname "$f")")/$(basename "$f")"
  tickets=$((tickets + 1))
  problems="$(check_ticket "$f")"
  if [ -z "$problems" ]; then ok "$name conforms"; else bad "$name conforms" "$problems"; fi
done
expect_counted "$tickets" "tickets"

# Backward coverage, over the directory rather than the file: a criterion that
# landed in no ticket is the solution's sentence nothing will build.
for d in "$ROOT"/tickets/*/; do
  solution="$(key_of "$(ls "$d"*.md | head -1)" solution)"
  [ -f "$ROOT/$solution" ] || continue
  uncovered=""
  claimed="$(for f in "$d"*.md; do key_of "$f" satisfies | tr ',' '\n'; done | tr -d ' ' | sort -u)"
  while read -r id; do
    printf '%s\n' "$claimed" | grep -qx "$id" || uncovered+="$id "
  done < <(grep -o '^- \*\*AC-[0-9]\+\*\*' "$ROOT/$solution" | grep -o 'AC-[0-9]\+')
  [ -z "$uncovered" ] \
    && ok "$(basename "$d") covers every criterion of $solution" \
    || bad "$(basename "$d") covers every criterion of $solution" "not claimed by any ticket: $uncovered"
done

finish
