#!/usr/bin/env bash
#
# The tests for run/checks.sh: the project's checks, found by a session and run
# by the runner before any build.
#
#   tests/run/checks.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the project's checks, before any build
#
# A build told the checks were green on HEAD cannot mistake a failure that was
# already there for its own, or halt over one. So they are run first, by the
# runner, and a run that starts red does not start.

workspace
STUB_VERIFY=false
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'false' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "checks that fail before any build stop the run, naming the command"
else bad "checks that fail before any build stop the run, naming the command" "rc=$rc $(out) $(calls)"; fi

# A new project has no checks until a build sets them up.
workspace
STUB_VERIFY=
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'no checks yet' "$WORK/.out" && [ "$(grep -c -- '--json-schema' "$STUB_ARGS")" = 1 ]; then
  ok "where a session names no verification command, the run builds without checks, asking once"
else bad "where a session names no verification command, the run builds without checks, asking once" "rc=$rc $(out) $(calls)"; fi
if grep -q 'no checks yet.*Fast check:' <(head -1 "$STUB_CALLS"); then
  ok "a build in a project with no checks is told to declare the one it sets up"
else bad "a build in a project with no checks is told to declare the one it sets up" "$(calls)"; fi

workspace
STUB_VERIFY=
export STUB_DECLARE='touch .declared'
plan build-declare build review
rc="$(run)"
if [ "$rc" = 0 ] && [ -f "$WORK/.declared" ] && grep -q 'touch .declared' <(sed -n 2p "$STUB_CALLS"); then
  ok "a check a build declares in a project that had none runs from its commit on"
else bad "a check a build declares in a project that had none runs from its commit on" "rc=$rc $(out) $(calls)"; fi

workspace
STUB_VERIFY='touch .verified'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ -f "$WORK/.verified" ]; then
  ok "the command the session named is what the runner runs"
else bad "the command the session named is what the runner runs" "rc=$rc $(out)"; fi
if grep -q 'touch .verified' <(head -1 "$STUB_CALLS"); then
  ok "the build is told the command, and that it was green"
else bad "the build is told the command, and that it was green" "$(calls)"; fi

# A FAST_CHECK in the caller's environment is not a check that passed.
workspace
STUB_VERIFY=false
plan build build review
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" FAST_CHECK=true bash "$RUNNER" changes/x > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a FAST_CHECK already in the environment does not skip the checks"
else bad "a FAST_CHECK already in the environment does not skip the checks" "rc=$rc $(out)"; fi

# --- the command the project declares
#
# A Check: line in CLAUDE.md is the project's own answer, read with a grep before
# every run of the checks. A session is asked only where there is none, and only
# once in a run.

questions() { grep -c -- '--json-schema' "$STUB_ARGS"; }

workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nCheck: `touch .declared`\n' > "$WORK/CLAUDE.md"; commit
STUB_VERIFY='touch .asked'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ -f "$WORK/.declared" ] && [ ! -f "$WORK/.asked" ] && [ "$(questions)" = 0 ]; then
  ok "a Check: line in CLAUDE.md is run, and no session is asked"
else bad "a Check: line in CLAUDE.md is run, and no session is asked" "rc=$rc questions=$(questions) $(out)"; fi

workspace
STUB_VERIFY='touch .asked'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(questions)" = 1 ]; then
  ok "without a Check: line, a session is asked once for the whole run"
else bad "without a Check: line, a session is asked once for the whole run" "rc=$rc questions=$(questions) $(out)"; fi

workspace
STUB_VERIFY='touch .asked'
export STUB_DECLARE='touch .declared'
plan build-declare build review
rc="$(run)"
if [ "$rc" = 0 ] && [ -f "$WORK/.declared" ] && [ "$(questions)" = 1 ]; then
  ok "a Check: line a build adds is run from its commit on, without asking again"
else bad "a Check: line a build adds is run from its commit on, without asking again" "rc=$rc questions=$(questions) $(out)"; fi
if grep -q 'touch .declared' <(sed -n 2p "$STUB_CALLS"); then
  ok "the next build is told the command the project declared"
else bad "the next build is told the command the project declared" "$(calls)"; fi

# --- the fast check and the slow check
#
# A project's checks are a fast check, which every build runs, and a slow check
# for the tests that can't be made fast. The runner runs both, before any build
# and on every build's commit, so no build has to run the slow one.

# One line per run of the command, in the file it names.
counts() { if [ -f "$WORK/$1" ]; then wc -l < "$WORK/$1"; else echo 0; fi; }

workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nFast check: `echo x >> .fast`\nSlow check: `echo x >> .slow`\n' > "$WORK/CLAUDE.md"; commit
STUB_VERIFY='touch .asked'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(counts .fast)" -ge 3 ] && [ ! -f "$WORK/.asked" ] && [ "$(questions)" = 0 ]; then
  ok "a Fast check: line is run before any build and on every build, and no session is asked"
else bad "a Fast check: line is run before any build and on every build, and no session is asked" "rc=$rc fast=$(counts .fast) questions=$(questions) $(out)"; fi
if [ "$(counts .slow)" -ge 3 ] && [ "$(counts .slow)" = "$(counts .fast)" ]; then
  ok "the slow check runs wherever the runner runs the fast check"
else bad "the slow check runs wherever the runner runs the fast check" "fast=$(counts .fast) slow=$(counts .slow) $(out)"; fi

workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nSlow check: `echo x >> .slow`\n' > "$WORK/CLAUDE.md"; commit
STUB_VERIFY='echo x >> .fast'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(questions)" = 1 ] && [ "$(counts .fast)" -ge 3 ] && [ "$(counts .slow)" = "$(counts .fast)" ]; then
  ok "with a Slow check: line and no fast one, a session names the fast check once, and both run"
else bad "with a Slow check: line and no fast one, a session names the fast check once, and both run" "rc=$rc questions=$(questions) fast=$(counts .fast) slow=$(counts .slow) $(out)"; fi

workspace
STUB_VERIFY=true
export STUB_DECLARE='echo x >> .slow' STUB_DECLARE_AS='Slow check'
plan build-declare build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(counts .slow)" -ge 2 ]; then
  ok "a Slow check: line a build adds is run from its commit on"
else bad "a Slow check: line a build adds is run from its commit on" "rc=$rc slow=$(counts .slow) $(out)"; fi
unset STUB_DECLARE_AS

workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nFast check: `true`\nSlow check: `echo SLOWRED; false`\n' > "$WORK/CLAUDE.md"; commit
plan build build review
rc="$(run)"
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if [ "$rc" != 0 ] && grep -qF 'the slow check, `echo SLOWRED; false`, is red' "$WORK/.out" && ! grep -qF 'the fast check, `' "$WORK/.out" \
   && grep -q 'SLOWRED' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a slow check red before any build stops the run, saying it is the slow check"
else bad "a slow check red before any build stops the run, saying it is the slow check" "rc=$rc $(out) $(calls)"; fi

workspace
STUB_VERIFY=false
plan build build review
run > /dev/null
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -qF 'the fast check, `false`, is red' "$WORK/.out"; then
  ok "a fast check red before any build stops the run, saying it is the fast check"
else bad "a fast check red before any build stops the run, saying it is the fast check" "$(out)"; fi

# Two lines that both say what every build runs leave it to chance which one
# does.
workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nCheck: `true`\nFast check: `true`\n' > "$WORK/CLAUDE.md"; commit
plan build build review
rc="$(run)"
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if [ "$rc" != 0 ] && grep -q 'remove `Check:`' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a CLAUDE.md with both Check: and Fast check: is refused, saying to remove Check:"
else bad "a CLAUDE.md with both Check: and Fast check: is refused, saying to remove Check:" "rc=$rc $(out) $(calls)"; fi

workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nCheck: `true`\n' > "$WORK/CLAUDE.md"; commit
export STUB_DECLARE='true' STUB_DECLARE_AS='Fast check'
plan build-declare halt:blocked
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ] && grep -q 'remove `Check:`' <(sed -n 2p "$STUB_CALLS") \
   && ! grep -q 'printed are below' <(sed -n 2p "$STUB_CALLS"); then
  ok "a build that leaves both Check: and Fast check: is handed back, told to remove Check:"
else bad "a build that leaves both Check: and Fast check: is handed back, told to remove Check:" "rc=$rc $(cat "$STUB_SESSIONS") $(calls) $(out)"; fi
unset STUB_DECLARE_AS

finish
