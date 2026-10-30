#!/usr/bin/env bash
#
# The tests for run/drift.sh: the pre-flight that stops a run where CHANGE.md,
# its journeys and its chunks no longer agree, and the halt on a build that
# changes a journey the developer approved.
#
#   tests/run/drift.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the drift pre-flight
#
# A session reads its own chunk and no other, and a committed chunk is
# revisited by nobody but a new split, so this is the only place they can be
# found to disagree.

drifted() {  # what the case is, the chunk that should carry the halt
  if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out" && [ ! -s "$STUB_CALLS" ] \
     && [ "$(field "$2" status)" = halted ] && grep -q 'drift' <(chk "$2"); then
    ok "$1 stops the run before any session, halted in $2"
  else bad "$1 stops the run before any session, halted in $2" "rc=$rc $(calls) $(out) $(chk "$2")"; fi
}

workspace
sed -i 's/^x$/a different problem/' "$WORK/changes/x/CHANGE.md"; commit
plan build
rc="$(run)"
drifted "CHANGE.md's Problem edited after the split" 1-one
if grep -q '1-one.md: its Problem no longer matches CHANGE.md' "$WORK/.out" \
   && grep -q '2-two.md: its Problem no longer matches CHANGE.md' "$WORK/.out"; then
  ok "each chunk whose Problem no longer matches is named"
else bad "each chunk whose Problem no longer matches is named" "$(out)"; fi

workspace
git -C "$WORK" rm -q journeys/two.md; commit
plan build
rc="$(run)"
drifted "a journey CHANGE.md names and that is not there" 1-one
if grep -q 'CHANGE.md: names journeys/two.md, which is not there' "$WORK/.out"; then
  ok "the missing journey is named"
else bad "the missing journey is named" "$(out)"; fi

workspace
sed -i 's#^journeys: .*#journeys:  journeys/one.md, journeys/two.md, journeys/three.md#' "$WORK/changes/x/CHANGE.md"
printf '# Three\n' > "$WORK/journeys/three.md"; commit
plan build
rc="$(run)"
drifted "a journey no chunk names" 1-one
# Reported once, not once per chunk.
if [ "$(grep -c 'journeys/three.md is named by no chunk' "$WORK/.out")" = 1 ]; then
  ok "a journey no chunk names is reported once, not once per chunk"
else bad "a journey no chunk names is reported once, not once per chunk" "$(out)"; fi

workspace
sed -i 's#^journeys: .*#journeys:  journeys/two.md, journeys/three.md#' "$WORK/changes/x/chunks/2-two.md"
printf '# Three\n' > "$WORK/journeys/three.md"; commit
plan build
rc="$(run)"
drifted "a chunk naming a journey CHANGE.md does not" 2-two
if grep -q '2-two.md: names journeys/three.md, which CHANGE.md does not' "$WORK/.out"; then
  ok "the journey CHANGE.md does not name is named"
else bad "the journey CHANGE.md does not name is named" "$(out)"; fi

# A deleted chunk leaves the ones after it waiting on something that will never
# be done.
workspace
sed -i 's/^after: .*/after:     9-gone/' "$WORK/changes/x/chunks/2-two.md"; commit
plan build
rc="$(run)"
drifted "an after: naming no chunk" 2-two

# Where the change was not split, CHANGE.md carries the halt.
workspace; unsplit
plan split-none
git -C "$WORK" rm -q journeys/two.md; commit
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out" && [ "$(field CHANGE status)" = halted ] && grep -q 'drift' <(chk CHANGE); then
  ok "an unsplit change whose journey is missing halts in CHANGE.md"
else bad "an unsplit change whose journey is missing halts in CHANGE.md" "rc=$rc $(out) $(chk CHANGE)"; fi

# A preparatory chunk builds no journey, and is no drift.
workspace
chunk 0-prep "" ""
sed -i 's/^after: .*/after:     0-prep/' "$WORK/changes/x/chunks/1-one.md"; commit
plan build build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out" && [ "$(field 0-prep status)" = "done" ]; then
  ok "a chunk that names no journey is no drift"
else bad "a chunk that names no journey is no drift" "rc=$rc $(out)"; fi

# Journeys listed with uneven spacing are the same journeys.
workspace
sed -i 's#^journeys: .*#journeys:  journeys/one.md ,journeys/two.md #' "$WORK/changes/x/CHANGE.md"; commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "journeys listed with uneven spacing are no drift"
else bad "journeys listed with uneven spacing are no drift" "rc=$rc $(out)"; fi

# A drift nobody has resolved is the same halt on every start, not one more.
workspace
sed -i 's/^x$/a different problem/' "$WORK/changes/x/CHANGE.md"; commit
plan build
run > /dev/null; rc="$(run)"
if [ "$rc" != 0 ] && [ "$(grep -c '^## Halt' <(chk 1-one))" = 1 ]; then
  ok "starting again on an unresolved drift stops again, halting once"
else bad "starting again on an unresolved drift stops again, halting once" "rc=$rc $(chk 1-one)"; fi

# --- the journeys stay as the developer approved them
#
# They were changed and committed with CHANGE.md, before the build. A build or
# a review that changes one has changed what the developer agreed to.

workspace
plan build-journey build review
rc="$(run)"
if [ "$rc" = 1 ] && [ "$(field 1-one status)" = halted ] && grep -q '^departure' <(sed -n '/^## Halt$/,$p' "$(chunk_path 1-one)" | sed -n 3p) \
   && grep -q 'journeys/one.md' <(chk 1-one) && [ "$(wc -l < "$STUB_CALLS")" = 1 ]; then
  ok "a build that changes a journey halts as a departure, naming it"
else bad "a build that changes a journey halts as a departure, naming it" "rc=$rc $(chk 1-one) $(out)"; fi
if grep -q 'RUN STOPPED: 1-one.md halted (departure)' "$WORK/.out" \
   && git -C "$WORK" log --format=%s | grep -q '^build 1-one.md' && [ -z "$(git -C "$WORK" status --porcelain)" ]; then
  ok "the build's commit stands for the developer, and the halt is committed"
else bad "the build's commit stands for the developer, and the halt is committed" "$(out) $(git -C "$WORK" status --porcelain)"; fi

workspace
plan build build review-journey
rc="$(run)"
if [ "$rc" = 1 ] && grep -q 'RUN STOPPED: the final review changed journeys' "$WORK/.out" \
   && grep -q 'journeys/one.md' "$WORK/.out" && ! grep -q '/accept-change' "$WORK/.out"; then
  ok "a final review that changes a journey stops the run, naming it"
else bad "a final review that changes a journey stops the run, naming it" "rc=$rc $(out)"; fi

finish
