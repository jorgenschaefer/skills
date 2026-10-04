#!/usr/bin/env bash
#
# The tests for run/report.sh: the final review over the whole change, and what
# every run prints at its end.
#
#   tests/run/report.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the final review
#
# Each build is reviewed on its own, which cannot see what lies between them:
# the same thing built twice, two names for one concept, seams that do not line
# up. One session reviews the whole change once every ticket is built.

workspace
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ] && grep -q 'critique' <(tail -1 "$STUB_CALLS"); then
  ok "once every ticket is done, one session reviews the whole change"
else bad "once every ticket is done, one session reviews the whole change" "rc=$rc $(calls) $(out)"; fi

# Tickets added in the very first commit have no commit before them, and the
# change is then everything.
workspace
rm -rf "$WORK/.git"
git -C "$WORK" init -q -b main
git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
printf '/.*\n' >> "$WORK/.git/info/exclude"
git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm paper
git -C "$WORK" checkout -q -b topic
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -qF "$(git -C "$WORK" hash-object -t tree /dev/null)" <(tail -1 "$STUB_CALLS"); then
  ok "tickets added in the first commit are reviewed from the empty tree"
else bad "tickets added in the first commit are reviewed from the empty tree" "rc=$rc $(tail -1 "$STUB_CALLS") $(out)"; fi

# One ticket was reviewed whole by its own build.
workspace
rm "$WORK/changes/x/tickets/2-two.md"
sed -i '/^- \*\*AC-2\*\*/d' "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 1 ] && [ ! -e "$WORK/changes/x/REVIEW.md" ]; then
  ok "a single ticket gets no final review"
else bad "a single ticket gets no final review" "rc=$rc $(calls) $(out)"; fi
if grep -q 'left by 1-one.md' "$WORK/.out" && tail -1 "$WORK/.out" | grep -q '/accept-criteria'; then
  ok "with no review, the one ticket's Left standing is what the run ends with"
else bad "with no review, the one ticket's Left standing is what the run ends with" "$(out)"; fi

workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 2 ]; then
  ok "a run with a halt gets no final review"
else bad "a run with a halt gets no final review" "rc=$rc $(calls) $(out)"; fi

# REVIEW.md is how the review is known to have finished, so a session that
# ended without one has not.
workspace
plan build build review-dies review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'the final review did not finish' "$WORK/.out"; then
  ok "a final review that ends without committing REVIEW.md fails the run, and says so"
else bad "a final review that ends without committing REVIEW.md fails the run, and says so" "rc=$rc $(out)"; fi
if ! grep -q '/accept-criteria' "$WORK/.out"; then
  ok "a run whose review did not finish does not point on to acceptance"
else bad "a run whose review did not finish does not point on to acceptance" "$(out)"; fi

# Started again, the review runs where it did not finish - and the checks are
# run first, because nothing in this run has run them yet.
rc="$(run)"
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if [ "$rc" = 0 ] && git -C "$WORK" cat-file -e HEAD:changes/x/REVIEW.md 2>/dev/null \
   && grep -q '`true`' <(tail -1 "$STUB_CALLS"); then
  ok "a run started again after a failed review runs it again, told the checks"
else bad "a run started again after a failed review runs it again, told the checks" "rc=$rc $(calls) $(out)"; fi

# And where it did finish, it does not run again.
workspace
plan build build review
run > /dev/null
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ] && grep -q 'the review left: a seam' "$WORK/.out"; then
  ok "a run started again after its review reprints it rather than reviewing again"
else bad "a run started again after its review reprints it rather than reviewing again" "rc=$rc $(calls) $(out)"; fi

# --- the end of a run
#
# Nobody watches a run, so what needs a person is printed at the end of it,
# however it ended - and only that, last, where the screen stops. One run that
# halted ended in pages of what every build left standing, and nothing near
# the end said a ticket had halted, or why.

# Everything from the line the end of the run starts at: what follows the last
# line the loop printed, which all start with the time.
ending() { sed -n '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9] /=' "$WORK/.out" | tail -1 \
             | { read -r n; sed -n "$(( ${n:-0} + 1 )),\$p" "$WORK/.out"; }; }

workspace
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ending | grep -q 'the review left: a seam'; then
  ok "a finished run ends with what REVIEW.md leaves for the person"
else bad "a finished run ends with what REVIEW.md leaves for the person" "rc=$rc $(out)"; fi
if ! grep -q "the review's detail" "$WORK/.out"; then ok "the rest of REVIEW.md is left for acceptance"
else bad "the rest of REVIEW.md is left for acceptance" "$(out)"; fi
if ! grep -q 'left by' "$WORK/.out"; then ok "what each build left standing is not printed - the review has it"
else bad "what each build left standing is not printed - the review has it" "$(out)"; fi
if tail -1 "$WORK/.out" | grep -q '/accept-criteria .*changes/x'; then
  ok "a finished run ends pointing on to /accept-criteria"
else bad "a finished run ends pointing on to /accept-criteria" "$(out)"; fi

# A REVIEW.md written before it had a section for the person is still shown,
# from its top - as far as fits a page.
seq -f 'line %g of an old review' 50 > "$WORK/changes/x/REVIEW.md"; commit
rc="$(run)"
if [ "$rc" = 0 ] && ending | grep -qx 'line 40 of an old review' && ! ending | grep -qx 'line 41 of an old review'; then
  ok "a REVIEW.md with nothing marked for the person is printed from its top, 40 lines of it"
else bad "a REVIEW.md with nothing marked for the person is printed from its top, 40 lines of it" "rc=$rc $(out)"; fi

workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: 2-two.md halted (blocked)' \
   && ending | grep -q 'blocked - the stub was told to' && ending | grep -q 'second line of the halt'; then
  ok "a run that halts ends saying which ticket halted, and the whole of why"
else bad "a run that halts ends saying which ticket halted, and the whole of why" "rc=$rc $(out)"; fi
if ending | grep -q 'changes/x/tickets/2-two.md'; then ok "a halt names the ticket file to read"
else bad "a halt names the ticket file to read" "$(out)"; fi
if ! grep -q 'left by' "$WORK/.out" && ! grep -q 'context read' "$WORK/.out"; then
  ok "a run that halts prints neither what the builds left standing nor what they cost"
else bad "a run that halts prints neither what the builds left standing nor what they cost" "$(out)"; fi
if ! grep -q '/accept-criteria' "$WORK/.out"; then ok "a run that halts does not point on to acceptance"
else bad "a run that halts does not point on to acceptance" "$(out)"; fi

# A halt in a shape the runner did not ask for still names its kind.
workspace
plan build 'halt:**Kind:** undecided'
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: 2-two.md halted (undecided)'; then
  ok "a halt is named by its kind wherever its first line puts it"
else bad "a halt is named by its kind wherever its first line puts it" "rc=$rc $(out)"; fi

# A halt runs on for as long as its session wrote it; the end of the run does not.
workspace
plan halt:mystery
printf '%s\n' "$(seq -f 'line %g of the halt' 30)" > "$WORK/.halt-extra"
rc="$(STUB_HALT_EXTRA="$WORK/.halt-extra" run)"
# Twenty lines of it: the stub's own three, then the first seventeen of these.
if [ "$rc" != 0 ] && ending | grep -q 'line 17 of the halt' && ! ending | grep -q 'line 18 of the halt' \
   && ending | grep -q 'rest in the ticket'; then
  ok "a long halt is cut short, saying where the rest is"
else bad "a long halt is cut short, saying where the rest is" "rc=$rc $(out)"; fi

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: 1-one.md halted (drift)' && ending | grep -q 're-slice'; then
  ok "a run stopped by drift ends with the halt"
else bad "a run stopped by drift ends with the halt" "rc=$rc $(out)"; fi

# A halt whose first line names no kind still reads as a halt.
workspace
plan 'halt:the migration tool is not installed'
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: 1-one.md halted (kind not named)'; then
  ok "a halt that names no kind says so"
else bad "a halt that names no kind says so" "rc=$rc $(out)"; fi

# A run started again over a halt nobody settled builds what does not wait on
# it - and what stops it then is what the end of the run names, not the halt it
# started with.
workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan halt:blocked
run > /dev/null
plan halt:mystery
: > "$STUB_CALLS"
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: 2-two.md halted (mystery)' \
   && ! ending | grep -q 'RUN STOPPED: 1-one'; then
  ok "a run started again over an old halt ends naming the halt that stopped it"
else bad "a run started again over an old halt ends naming the halt that stopped it" "rc=$rc $(out)"; fi
if ending | grep -q 'log: .*/2-two-' && ending | grep -q '1-one.md: halted (blocked)'; then
  ok "the halt that stopped it comes with its own session's log, and the old halt is listed"
else bad "the halt that stopped it comes with its own session's log, and the old halt is listed" "$(out)"; fi

workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan halt:blocked
run > /dev/null
plan limit limit
: > "$STUB_CALLS"
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=1 \
           bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: .*usage limit' && ending | grep -q '2-two.md' \
   && ! ending | grep -q 'RUN STOPPED: 1-one'; then
  ok "a limit that stops a run started over an old halt is what the end of the run names"
else bad "a limit that stops a run started over an old halt is what the end of the run names" "rc=$rc $(out)"; fi
if ! ending | grep -q 'log:'; then ok "a stop that is not a halt is given no halt's log"
else bad "a stop that is not a halt is given no halt's log" "$(out)"; fi

# Every ticket done, and the review did not finish: the end says that, not that
# work is left.
workspace
plan build build review-dies
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED: the final review did not finish' \
   && ! grep -q 'work left' "$WORK/.out"; then
  ok "a run whose review did not finish ends saying so"
else bad "a run whose review did not finish ends saying so" "rc=$rc $(out)"; fi

# With no review, Left standing is printed whole, subheadings and all.
workspace
rm "$WORK/changes/x/tickets/2-two.md"
sed -i '/^- \*\*AC-2\*\*/d' "$WORK/changes/x/CRITERIA.md"; commit
printf '%s\n' '' '### Checks' '' '- the lint was not run' >> "$WORK/.left-extra"
plan build
rc="$( STUB_LEFT_EXTRA="$WORK/.left-extra" run )"
if [ "$rc" = 0 ] && grep -q 'left by 1-one.md' "$WORK/.out" && grep -q 'the lint was not run' "$WORK/.out"; then
  ok "a Left standing with subheadings is printed to its end"
else bad "a Left standing with subheadings is printed to its end" "rc=$rc $(out)"; fi

# --- nothing selectable is not the same as everything finished

workspace
sed -i 's/^after: .*/after:     9-ghost/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && ending | grep -q 'RUN STOPPED' && ending | grep -q '9-ghost'; then
  ok "a dependency nobody can satisfy is named"
else bad "a dependency nobody can satisfy is named" "rc=$rc $(out)"; fi

finish
