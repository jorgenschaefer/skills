#!/usr/bin/env bash
#
# The tests for the split of the old `coding-conventions` into two skills:
# `coding-standard`, read while code is typed, and `software-design`, read while
# a change is shaped.
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
DESIGN="$ROOT/software-design/SKILL.md"

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

  # Nothing lost: every section the original carried is in exactly one half. The
  # before state is a fixture rather than a `git show`: a pinned commit stops
  # being reachable after a squash or a rebase, and a shallow clone never has it,
  # at which point the suite fails for a reason that has nothing to do with the
  # split and blames the split anyway.
  BEFORE="$HERE/fixtures/coding-conventions-headings.txt"
  if [ ! -s "$BEFORE" ]; then
    bad "the before state is readable" "missing or empty: $BEFORE"
    finish
    exit
  fi
  before="$(cat "$BEFORE")"
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

  # The design half owes two things the original never had: when a decision is
  # worth an ADR, and when the record gets written. Both are prose a model acts
  # on, so this only pins that they are still there.
  for heading in "The glossary" "What deserves an ADR"; do
    grep -q "^## $heading\$" "$DESIGN" \
      && ok "the design skill carries ## $heading" \
      || bad "the design skill carries ## $heading" "not in $DESIGN"
  done
  grep -q 'plan exit' "$DESIGN" \
    && ok "the design skill says when an ADR is written" \
    || bad "the design skill says when an ADR is written" "nothing in $DESIGN names the moment"
fi

# Whoever names a standard must name one that is there - and a section of it that
# is still in it. Sections were what moved, so a reference naming the right file
# and the wrong half is the failure this split can cause, and the only one a
# reader would not notice.
BEFORE="$HERE/fixtures/coding-conventions-headings.txt"
dangling=""
for skill in "$ROOT"/*/SKILL.md; do
  from="$(basename "$(dirname "$skill")")"
  while IFS= read -r line; do
    named=""
    case "$line" in *'`coding-standard`'*) named="coding-standard" ;; esac
    case "$line" in *'`software-design`'*) named="${named:-software-design}" ;; esac
    # A line naming both is ambiguous about which half it is attributing a
    # section to, and there is a legitimate one - `/critique` reads both.
    case "$line" in *'`coding-standard`'*'`software-design`'*|*'`software-design`'*'`coding-standard`'*) continue ;; esac
    [ -n "$named" ] || continue
    [ -d "$ROOT/$named" ] || { dangling+="$from names $named, which is not a skill"$'\n'; continue; }
    while read -r section; do
      # Only sections the split moved: a line may name any number of headings
      # belonging to a spec, a ticket or a format, and those are not ours.
      grep -qxF "$section" "$BEFORE" || continue
      grep -q "^#\{2,3\} $section\$" "$ROOT/$named/SKILL.md" \
        || dangling+="$from sends a reader to $named's ## $section, which is in the other half"$'\n'
    done < <(printf '%s\n' "$line" | grep -o '`## [^`]*`' | sed 's/`## //; s/`//')
  done < "$skill"
done
[ -z "$dangling" ] \
  && ok "every reference to a standard names a section it still holds" \
  || bad "every reference to a standard names a section it still holds" "$dangling"

finish
