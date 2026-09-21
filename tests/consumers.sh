#!/usr/bin/env bash
#
# The test for C-2 of INTENT_PROCESS_COST.md: every section every artifact
# requires has a named consumer.
#
#   tests/consumers.sh
#
# The whole complaint behind this pipeline was paper produced and read by
# nobody, and nobody could say which sections those were. So the map is written
# down - `tests/fixtures/consumers.txt` - and this checks the two directions
# that make it worth having: no section without a reader, and no reader that is
# not a skill, a script, or a person at a stated moment.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
MAP="$HERE/fixtures/consumers.txt"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

FORMATS=(idea/INTENT_FORMAT.md solve/SOLVE_FORMAT.md slice/SLICE_FORMAT.md accept/VERDICT_FORMAT.md)

missing="" unknown="" stale=""
for f in "${FORMATS[@]}"; do
  while read -r section; do
    grep -q "^$f :: $section :: ." "$MAP" || missing+="$f :: $section"$'\n'
  done < <(template_of "$ROOT/$f" | grep -o '^## .*' | sed 's/^## //')
done
[ -z "$missing" ] \
  && ok "every section has a named consumer" \
  || bad "every section has a named consumer" "$missing"

# The other direction: a mapping for a section that no longer exists is a reader
# waiting for paper nobody writes.
while IFS=$'\t' read -r f section; do
  template_of "$ROOT/$f" | grep -q "^## $section\$" || stale+="$f :: $section"$'\n'
done < <(grep -v '^#' "$MAP" | grep ' :: ' | awk -F' :: ' '{print $1 "\t" $2}')
[ -z "$stale" ] \
  && ok "no consumer waits for a section that was removed" \
  || bad "no consumer waits for a section that was removed" "$stale"

# A reader has to be something that exists.
# Each clause of a multi-reader mapping, not just the first: six of them name a
# second reader, and truncating at the semicolon left those unchecked.
while IFS= read -r reader; do
  reader="${reader# }"
  case "$reader" in
    "a person,"*) continue ;;
    "a person"*) unknown+="$reader (a person, at which moment?)"$'\n'; continue ;;
  esac
  for name in $(printf '%s' "$reader" | grep -o '^[a-z][a-z/.-]*'); do
    [ -d "$ROOT/$name" ] || [ -f "$ROOT/$name" ] || unknown+="$reader"$'\n'
  done
done < <(grep -v '^#' "$MAP" | grep ' :: ' | sed 's/.* :: //' | tr ';' '\n' | sort -u)
[ -z "$unknown" ] \
  && ok "every named consumer is a skill, a script or a person" \
  || bad "every named consumer is a skill, a script or a person" "$unknown"

finish
