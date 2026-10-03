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
# however it ended: the halts, what each build left standing, what the final
# review left, and where to go next.

workspace
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'left by 1-one.md' "$WORK/.out" && grep -q 'left by 2-two.md' "$WORK/.out"; then
  ok "each ticket's Left standing is printed at the end"
else bad "each ticket's Left standing is printed at the end" "rc=$rc $(out)"; fi
if grep -q 'the review left: a seam' "$WORK/.out"; then ok "REVIEW.md is printed at the end"
else bad "REVIEW.md is printed at the end" "$(out)"; fi
if grep -q '/accept-criteria .*changes/x' "$WORK/.out"; then
  ok "a finished run points on to /accept-criteria"
else bad "a finished run points on to /accept-criteria" "$(out)"; fi

workspace
plan build halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '2-two.md: halted - blocked' "$WORK/.out" && grep -q 'left by 1-one.md' "$WORK/.out"; then
  ok "a run that halts ends with the halt and what the builds left standing"
else bad "a run that halts ends with the halt and what the builds left standing" "rc=$rc $(out)"; fi
if ! grep -q '/accept-criteria' "$WORK/.out"; then ok "a run that halts does not point on to acceptance"
else bad "a run that halts does not point on to acceptance" "$(out)"; fi

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: halted - drift' "$WORK/.out"; then
  ok "a run stopped by drift ends with the halt"
else bad "a run stopped by drift ends with the halt" "rc=$rc $(out)"; fi

# --- nothing selectable is not the same as everything finished

workspace
sed -i 's/^after: .*/after:     9-ghost/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '9-ghost' "$WORK/.out"; then
  ok "a dependency nobody can satisfy is named"
else bad "a dependency nobody can satisfy is named" "rc=$rc $(out)"; fi

finish
