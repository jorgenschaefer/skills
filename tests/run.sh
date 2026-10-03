#!/usr/bin/env bash
#
# The tests for the runner: what it does with a ticket directory when nobody is
# watching.
#
#   tests/run.sh
#
# Everything `run.sh` holds is something that has to be true when a session is
# dead or lying, which is why it is a script and not a skill. This file holds
# what run.sh does itself - its refusals, the lock, the frontmatter - and each
# file of its library under run/ has its suite under tests/run/. What every
# case stands on is in run/harness.sh.

set -uo pipefail

# shellcheck source=run/harness.sh
. "$(dirname "$0")/run/harness.sh"

# --- refusals, before anything is launched

workspace; git -C "$WORK" checkout -q main
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -qi 'branch' "$WORK/.out"; then
  ok "it refuses to run on the main branch"
else bad "it refuses to run on the main branch" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "it launches nothing when it refuses"
else bad "it launches nothing when it refuses" "$(calls)"; fi

workspace
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" changes/x/nope >"$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ]; then ok "it refuses a ticket directory that is not there"
else bad "it refuses a ticket directory that is not there" "$(out)"; fi

# A repository with nothing committed yet is inside a work tree and has a branch
# name, so the two refusals above pass it. The HEAD check would in fact get it
# right - `rev-parse HEAD` prints the literal `HEAD` when it fails - but a
# correctness check resting on a command echoing its argument back is not one to
# leave standing, and the message says so.
workspace
rm -rf "$WORK/.git"
git -C "$WORK" init -q -b topic
git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'no commits' "$WORK/.out" && grep -q 'branch refusal' "$WORK/.out"; then
  ok "it refuses a repository with no commits, for the reason it gives"
else bad "it refuses a repository with no commits, for the reason it gives" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "a repository with no commits launches nothing"
else bad "a repository with no commits launches nothing" "$(calls)"; fi

# Someone's notes in the ticket directory are not a ticket.
workspace
printf '# notes\n' > "$WORK/changes/x/tickets/README.md"; commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'ignoring' "$WORK/.out"; then
  ok "a file that is not a ticket is ignored, and said so"
else bad "a file that is not a ticket is ignored, and said so" "rc=$rc $(out)"; fi

# --- one runner at a time
#
# A second runner started on a tree another is working took over its claim and
# resumed the session it was running. It stops instead, touching nothing - and a
# session that outlived a killed runner counts, since it is still building.

workspace
lock="$WORK/.git/run.lock"
( flock "$lock" sh -c ": > '$WORK/.locked'; exec /bin/sleep 5" ) &
until [ -e "$WORK/.locked" ]; do /bin/sleep 0.1; done
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'still' "$WORK/.out" && [ ! -s "$STUB_CALLS" ] \
   && [ -z "$(git -C "$WORK" status --porcelain)" ]; then
  ok "a run started while another holds the repository stops, touching nothing"
else bad "a run started while another holds the repository stops, touching nothing" "rc=$rc $(out)"; fi

workspace
plan orphaned build build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'still' "$WORK/.out" && [ "$(field 1-one status)" = doing ] \
   && [ "$(wc -l < "$STUB_CALLS")" = 1 ]; then
  ok "a run started while a killed run's session still runs stops, touching nothing"
else bad "a run started while a killed run's session still runs stops, touching nothing" "rc=$rc $(out)"; fi
flock -w 10 "$WORK/.git/run.lock" true
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 1-one status)" = "done" ] && grep -q '^resume' "$STUB_SESSIONS"; then
  ok "once that session has ended, a run carries on with its claim"
else bad "once that session has ended, a run carries on with its claim" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

# What the checks start in the background is not a session: it must not hold the
# lock after the run, or every later start is refused.
workspace
STUB_VERIFY='(/bin/sleep 3 >/dev/null 2>&1 &)'
plan build build review
run > /dev/null
rc="$(run)"
if [ "$rc" = 0 ]; then ok "a process the checks leave running does not hold the lock"
else bad "a process the checks leave running does not hold the lock" "rc=$rc $(out)"; fi

# --- the frontmatter, and only the frontmatter
#
# A ticket about the ticket format has body lines that look exactly like fields,
# and this repository's own tickets are full of them.

workspace
# shellcheck disable=SC2016 # a Markdown fence, written literally
printf '\n## Left standing\n\n```\nstatus:    review\nattempts:  7\n```\n' >> "$WORK/changes/x/tickets/1-one.md"; commit
plan build build review
run > /dev/null
if [ "$(grep -c '^status:    review' "$WORK/changes/x/tickets/1-one.md")" = 1 ]; then
  ok "only the frontmatter is rewritten"
else bad "only the frontmatter is rewritten" "$(tkt 1-one)"; fi

# --- the usage line

workspace
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && grep -qF 'run.sh changes/<slug>/tickets' "$WORK/.out"; then
  ok "the usage line names the change's ticket directory"
else bad "the usage line names the change's ticket directory" "rc=$rc $(out)"; fi

finish
