#!/usr/bin/env bash
#
# The tests for the split of `coding-conventions` into two skills.
#
#   tests/standard-split.sh
#
# One standard was read at two different moments by two different readers: the
# agent writing code, and whoever is deciding the shape of a change. Splitting
# it by when it is read is only safe if nothing falls between the halves, so
# that is what these cases hold: every section of the original is in exactly one
# of them, and neither carries the other's kind of rule.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
STANDARD="$ROOT/coding-standard/SKILL.md"
DESIGN="$ROOT/coding-conventions/SKILL.md"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

# The sections that are design guidance, and must not be in the write-time
# standard. Named rather than inferred, because the split was a decision.
DESIGN_SECTIONS=("Domain layering" "Anchor names in the domain" "The seams"
                 "Domain objects across the seams" "Conceptual granularity, not premature abstraction")

headings() { grep -o '^#\{2,3\} .*' "$1" | sed 's/^#* //'; }

[ -f "$STANDARD" ] || bad "the standard is its own skill" "no $STANDARD"

if [ -f "$STANDARD" ]; then
  ok "the standard is its own skill"

  # Nothing lost: every section the original carried is in exactly one half.
  before="$(git -C "$ROOT" show c6bfc1d:coding-conventions/SKILL.md | grep -o '^#\{2,3\} .*' | sed 's/^#* //')"
  missing="" doubled=""
  while IFS= read -r h; do
    in_standard=0 in_design=0
    headings "$STANDARD" | grep -qxF "$h" && in_standard=1
    headings "$DESIGN"   | grep -qxF "$h" && in_design=1
    case "$in_standard$in_design" in
      00) missing+="$h"$'\n' ;;
      11) doubled+="$h"$'\n' ;;
    esac
  done <<< "$before"
  [ -z "$missing" ] && ok "the split loses no section" || bad "the split loses no section" "$missing"
  [ -z "$doubled" ] && ok "the split duplicates no section" || bad "the split duplicates no section" "$doubled"

  # And neither half carries the other's kind of rule.
  stray=""
  for section in "${DESIGN_SECTIONS[@]}"; do
    headings "$STANDARD" | grep -qxF "$section" && stray+="$section"$'\n'
  done
  [ -z "$stray" ] && ok "the standard carries no design guidance" \
                  || bad "the standard carries no design guidance" "$stray"

  # A standard read only under a ticket is the thing this split exists to avoid.
  case "$(sed -n '/^description:/p' "$STANDARD")" in
    *ticket*) bad "the standard is not scoped to tickets" "its description names a ticket" ;;
    *) ok "the standard is not scoped to tickets" ;;
  esac
fi

# Whoever names a standard must name one that is there.
for skill in "$ROOT"/*/SKILL.md; do
  while read -r named; do
    [ -d "$ROOT/$named" ] || bad "$(basename "$(dirname "$skill")") names a skill that exists" "$named"
  done < <(grep -o '`/\?\(coding-standard\|coding-conventions\|software-design\)`' "$skill" | tr -d '`/' | sort -u)
done
ok "every reference to a standard names a skill that exists"

finish
