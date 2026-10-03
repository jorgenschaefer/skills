#!/usr/bin/env bash
#
# The tests for run/tickets.sh: the tree a run refuses to start on, and the
# halts the runner writes.
#
#   tests/run/tickets.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# Whatever is lying around uncommitted is someone's, and a session cannot tell
# it from its own work: it lints it, reviews it, and has to carve it out of
# every diff. Untracked files count - an untracked mockup broke the lint of a
# whole run.
workspace
printf 'x\n' > "$WORK/stray"
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'stray' "$WORK/.out"; then
  ok "it refuses a dirty tree, and names what is in it"
else bad "it refuses a dirty tree, and names what is in it" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "a dirty tree launches nothing"
else bad "a dirty tree launches nothing" "$(calls)"; fi

# The ticket files are the runner's bookkeeping and nothing else in their
# directory is: someone's notes there are still someone's.
workspace
plan claim-only claim-only
run > /dev/null
printf 'notes\n' > "$WORK/changes/x/tickets/notes.md"
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'dirty tree' "$WORK/.out" && grep -q 'notes.md' "$WORK/.out"; then
  ok "an uncommitted file beside the tickets is refused, bookkeeping or not"
else bad "an uncommitted file beside the tickets is refused, bookkeeping or not" "rc=$rc $(out)"; fi

# The runner's own halts are committed: a halt is the one thing a run leaves for
# a person, and uncommitted it was every later session's someone else's change.
workspace
plan claim-only claim-only
run > /dev/null
if [ "$(field 1-one status)" = halted ] && [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD:changes/x/tickets/1-one.md | sed -n 's/^status: *//p')" = halted ]; then
  ok "a halt the runner writes is committed"
else bad "a halt the runner writes is committed" "$(git -C "$WORK" status --porcelain) $(git -C "$WORK" log --oneline | head -3)"; fi

# A drift nobody has resolved is the same halt on every start, not one more.
workspace
sed -i 's/the second thing happens\./the second thing happens, reworded./' "$WORK/changes/x/CRITERIA.md"; commit
plan build build review
run > /dev/null; run > /dev/null
if [ "$(grep -c '^## Halt' <(tkt 2-two))" = 1 ]; then
  ok "starting again on an unresolved drift does not halt it twice"
else bad "starting again on an unresolved drift does not halt it twice" "$(tkt 2-two)"; fi

# One runner leaves one claim.
workspace
sed -i 's/^status: .*/status:    doing/' "$WORK"/changes/x/tickets/*.md; commit
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'more than one' "$WORK/.out" && grep -q '1-one' "$WORK/.out" && grep -q '2-two' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "two claimed tickets are refused, named, and nothing is launched"
else bad "two claimed tickets are refused, named, and nothing is launched" "rc=$rc $(out) $(calls)"; fi

finish
