#!/usr/bin/env bash
#
# The tests for run/chunks.sh: the split on a first start, the tree a run
# refuses to start on, and the halts the runner writes.
#
#   tests/run/chunks.sh

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

# The part files are the runner's bookkeeping and nothing else in their
# directory is: someone's notes there are still someone's.
workspace
plan claim-only claim-only
run > /dev/null
printf 'notes\n' > "$WORK/changes/x/plan/notes.md"
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'dirty tree' "$WORK/.out" && grep -q 'notes.md' "$WORK/.out"; then
  ok "an uncommitted file beside the parts is refused, bookkeeping or not"
else bad "an uncommitted file beside the parts is refused, bookkeeping or not" "rc=$rc $(out)"; fi

# The runner's own halts are committed: a halt is the one thing a run leaves for
# a person, and uncommitted it was every later session's someone else's change.
workspace
plan claim-only claim-only
run > /dev/null
if [ "$(field 01 status)" = halted ] && [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD:changes/x/plan/01.md | sed -n 's/^status: *//p')" = halted ]; then
  ok "a halt the runner writes is committed"
else bad "a halt the runner writes is committed" "$(git -C "$WORK" status --porcelain) $(git -C "$WORK" log --oneline | head -3)"; fi

# One runner leaves one claim.
workspace
sed -i 's/^status: .*/status:    doing/' "$WORK"/changes/x/plan/*.md; commit
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'more than one' "$WORK/.out" && grep -q 'plan/01.md' "$WORK/.out" && grep -q 'plan/02.md' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "two claimed parts are refused, named, and nothing is launched"
else bad "two claimed parts are refused, named, and nothing is launched" "rc=$rc $(out) $(calls)"; fi

# --- the split, on a first start
#
# plan.md is split where one agent cannot build it within one context, and
# built as it is where it can. The split asks nobody anything.

workspace; unsplit
plan split-two build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 01 status)" = "done" ] && [ "$(field 02 status)" = "done" ] \
   && grep -q 'split into 2 parts' "$WORK/.out" && grep -qF "/split-plan on $(realpath "$WORK")/changes/x/plan.md." <(head -1 "$STUB_CALLS") \
   && grep -qF "Use /implement-plan on $(realpath "$WORK")/changes/x/plan/01.md." <(sed -n 2p "$STUB_CALLS"); then
  ok "a plan split on a first start by /split-plan builds the parts it wrote"
else bad "a plan split on a first start by /split-plan builds the parts it wrote" "rc=$rc $(calls) $(out)"; fi
# Its status is the end review's once there are parts, so its attempts and the
# briefs say whether it was built.
if [ "$(field PLAN attempts)" = 0 ] && ! grep -qF "Use /implement-plan on $(realpath "$WORK")/changes/x/plan.md." "$STUB_CALLS"; then
  ok "once split, plan.md itself is not built"
else bad "once split, plan.md itself is not built" "$(chk PLAN)"; fi

workspace; unsplit
plan split-none build
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field PLAN status)" = "done" ] && [ "$(wc -l < "$STUB_CALLS")" = 2 ] \
   && grep -q 'building plan.md as it is' "$WORK/.out" \
   && grep -qF "Use /implement-plan on $(realpath "$WORK")/changes/x/plan.md." <(sed -n 2p "$STUB_CALLS"); then
  ok "a plan that fits one agent is built as plan.md, with no final review"
else bad "a plan that fits one agent is built as plan.md, with no final review" "rc=$rc $(calls) $(out)"; fi

# Once plan.md is claimed its attempts count, and a run started again does
# not split it again.
workspace; unsplit
plan split-none die build
run > /dev/null
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(grep -c '^/split-plan' "$STUB_CALLS")" = 1 ] && [ "$(field PLAN status)" = "done" ]; then
  ok "a run started again after the split does not split again"
else bad "a run started again after the split does not split again" "rc=$rc $(calls) $(out)"; fi

# A limit that outlasts every wait hands a part its attempt back, but plan.md
# at no attempts reads as a first start: a run started again split it again,
# on a tree its build had already committed to.
workspace; unsplit
plan split-none limit build
MAX_WAITS=0 run > /dev/null
before="$(field PLAN status) $(field PLAN attempts)"
rc="$(run)"
if [ "$before" = "ready 1" ] && [ "$rc" = 0 ] && [ "$(grep -c '^/split-plan' "$STUB_CALLS")" = 1 ] \
   && [ "$(field PLAN status)" = "done" ]; then
  ok "a run started again after a limit stopped plan.md's build does not split again"
else bad "a run started again after a limit stopped plan.md's build does not split again" "before=$before rc=$rc $(calls) $(out)"; fi

workspace; unsplit
plan halt:blocked
rc="$(run)"
if [ "$rc" = 1 ] && [ "$(field PLAN status)" = halted ] && [ "$(wc -l < "$STUB_CALLS")" = 1 ] \
   && grep -q 'RUN STOPPED: plan.md halted (blocked)' "$WORK/.out" \
   && [ "$(git -C "$WORK" show HEAD:changes/x/plan.md | sed -n 's/^status: *//p')" = halted ]; then
  ok "a split that halts ends the run before anything is built, the halt committed"
else bad "a split that halts ends the run before anything is built, the halt committed" "rc=$rc $(calls) $(out)"; fi

workspace; unsplit
plan split-dirty
rc="$(run)"
if [ "$rc" = 1 ] && grep -q 'the split left work uncommitted' "$WORK/.out" && grep -q 'plan/' "$WORK/.out" \
   && [ "$(wc -l < "$STUB_CALLS")" = 1 ]; then
  ok "a split that leaves its parts uncommitted ends the run, naming them"
else bad "a split that leaves its parts uncommitted ends the run, naming them" "rc=$rc $(calls) $(out)"; fi

workspace; unsplit
plan die
rc="$(run)"
if [ "$rc" = 1 ] && grep -q 'the split failed' "$WORK/.out" && [ "$(field PLAN attempts)" = 0 ]; then
  ok "a split that crashes ends the run, and the next start splits again"
else bad "a split that crashes ends the run, and the next start splits again" "rc=$rc $(calls) $(out)"; fi

finish
