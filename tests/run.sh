#!/usr/bin/env bash
#
# The tests: the invariants this repository holds across its skills, and every
# suite that checks one kind of artifact.
#
#   tests/run.sh
#
# Plain bash, because a repository of Markdown skills and two scripts should not
# have to install a test framework to check them. The suites below each build
# what they need and clean up after themselves; this file holds only what is
# true of the repository as a whole, and then runs them.
#
# It used to hold nine hundred lines of cases for `loop.sh` and `accept.sh`,
# which the new pipeline replaced. Those went with the scripts.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

# --- the skills' shared files ---------------------------------------------------

# After the old pipeline was retired every format document has exactly one copy,
# so the loop below skips them all and prints nothing. A section that asserts
# nothing should say so rather than look green.
shared=0

# A format document two skills both need is copied into each, because a skill
# installs alone and cannot reach into a sibling's directory. Identical is the
# whole point, and an n-way edit is easy to make (n-1)-way by accident.
#
# Quantified over the groups rather than over a count of any one of them: the
# holders move as skills come and go, and an assertion pinned to a number is one
# that gets edited to match whatever it found rather than read.

names=()
for format in "$HERE"/../*/*_FORMAT.md; do
  name="$(basename "$format")"
  [[ " ${names[*]} " == *" $name "* ]] || names+=("$name")
done

# The other half, and the one the count used to carry: a skill that names a
# format document has to hold it. Byte-identical copies are worth nothing if a
# skill installs without the file it was told to read, and the copies check
# cannot see that - a format with one copy has nothing to differ from.

# SKILL.md only. A format document names the other formats it sits next to -
# SOLUTION_FORMAT.md points at ADR_FORMAT.md for a shape - and it carries those
# mentions into every copy of itself. A mention is not a dependency; what the
# skill's own instructions tell the agent to read is.

for skill in "$HERE"/../*/SKILL.md; do
  dir="$(dirname "$skill")"
  for name in $(grep -o '[A-Z_]*_FORMAT\.md' "$skill" | sort -u); do
    [ -e "$dir/$name" ] \
      && ok "$(basename "$dir") holds the $name it reads" \
      || bad "$(basename "$dir") holds the $name it reads" "missing $dir/$name"
  done
done

for name in "${names[@]}"; do
  copies=("$HERE"/../*/"$name")
  [ "${#copies[@]}" -ge 2 ] || continue
  shared=$((shared + 1))
  [ "$(md5sum "${copies[@]}" | awk '{print $1}' | sort -u | wc -l)" = 1 ] \
    && ok "every copy of $name is byte-identical" \
    || bad "every copy of $name is byte-identical" "$(md5sum "${copies[@]}")"
done

# The mutation gate a build used to run at every ticket is gone, and what took
# its place is prose - a skill that starts asking for the tooling again asks for
# something no project here has ever had, which is how the gate came to be
# deliberated at ten tickets and run at none. Nothing else would notice.
#
# Every tool the retired prose named is a needle, since a regression is likelier
# to name one than to use the word "mutation". The parking lot and the tickets
# are where the gate is remembered on purpose, so they are the exemptions.
#
# "survivor" was a needle and is not one any more: it is an English word first,
# and it fired on a sentence about criteria ranking the survivors. A regression
# that means the mutation-testing sense says mutant or mutation too.

asks="$(grep -lriE 'mutation|mutant|stryker|mutmut|cargo-mutants|infection|\bpit\b' \
  --include='*.md' --exclude=IDEAS.md --exclude-dir=tickets --exclude-dir=.git "$HERE/..")"
# grep says 1 for no match and 2 for a broken pattern or an unreadable path, and
# both leave `asks` empty - so without this the check reports clean on the day it
# stops working.
asks_rc=$?
case $asks_rc in
  1) ok "no skill asks a build or an acceptance to run a mutation testing tool" ;;
  0) bad "no skill asks a build or an acceptance to run a mutation testing tool" "$asks" ;;
  *) bad "the check for a returning mutation gate could not run" "grep exited $asks_rc" ;;
esac

[ "$shared" -gt 0 ] \
  || ok "no format document is held by two skills, so there is nothing to keep identical"

# ------------------------------------------------------------------------------

# A skill that tells an agent to run a command is only as good as the command
# still being there. The paths drift when a suite is renamed, and nothing else
# would notice until an agent followed the instruction and found nothing.
missing="" named=0
while read -r path; do
  named=$((named + 1))
  [ -x "$HERE/../$path" ] || missing+="$path"$'\n'
done < <(grep -hoE 'tests/[A-Za-z0-9_/-]+\.sh' "$HERE"/../*/*.md | sort -u)
# Zero matches is zero failures, which reads as success - the same hole the
# format suites close with their own count.
[ "$named" -gt 0 ] || missing+="no skill names a suite at all: this check found nothing to check"$'\n'

[ -z "$missing" ] \
  && ok "every suite a skill tells you to run is there and runnable" \
  || bad "every suite a skill tells you to run is there and runnable" "$missing"

# The format suite is a separate file because what it checks is a different kind of
# thing - documents rather than script behaviour - but a suite nobody runs is a suite
# that goes stale, so this is the one command.
printf '\n'
# env -u, because an inherited FORMAT_SUITE_CHILD would quietly cut each suite
# to its tree cases and still exit 0.
env -u FORMAT_SUITE_CHILD "$HERE/intent-format.sh"   || failed=$((failed + 1))
printf '\n'
env -u FORMAT_SUITE_CHILD "$HERE/solution-format.sh" || failed=$((failed + 1))
printf '\n'
env -u FORMAT_SUITE_CHILD "$HERE/ticket-format.sh"   || failed=$((failed + 1))
printf '\n'
"$HERE/standard-split.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/build-contract.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/runner.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/accept.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/consumers.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/handoffs.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/no-dangling.sh" || failed=$((failed + 1))

printf '\n%d passed, %d failed, of the cases above\n' "$passed" "$failed"
[ "$failed" -eq 0 ]

