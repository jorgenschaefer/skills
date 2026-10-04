#!/usr/bin/env bash
#
# Drive a ticket directory to completion with nobody watching.
#
#   ./run.sh changes/<slug>/tickets
#
# Everything here is something that has to hold when a session is dead or
# misbehaving, which is why it is a script and not a skill. A session cannot
# enforce a budget it is spending, cannot reset a claim it is holding when it
# dies, and cannot wait out a limit that has already stopped it.
#
# The loop per ticket: claim it, build it, and either finish it or send it
# back. The runner owns `doing`, and a session writes `done` or `halted` and
# nothing else. A `done` is the session's claim, which the runner checks against
# the commit - a claim with no commit behind it is sent back - so nothing reaches
# `done` unbuilt, and a run killed at any point is started again from whatever
# the ticket files and the claim record say.
#
# There is no review pass per ticket. `/implement` spawns its own reviewer in a
# subagent that did not write the code, which is the property a second session
# used to buy, and a second review of a reviewed commit reviews a review. What
# no ticket's review can see - what lies between the tickets - gets one review
# of the whole change at the end.

set -uo pipefail

TICKETS="${1:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # builds of one ticket before it is exhausted
WAIT_SECONDS="${WAIT_SECONDS:-300}"   # after a usage limit that names no reset time
LIMIT_MARGIN="${LIMIT_MARGIN:-120}"   # past a limit's reset time, before carrying on
MAX_WAITS="${MAX_WAITS:-8}"           # limits in a row before the run gives up
VERIFY=""                             # the checks, once they have passed - never from outside
HALTED=""                             # the ticket last halted in this run, for its end to name

die() { printf '%s\n' "$*" >&2; exit 2; }
say() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*"; }

field()     { sed -n "2,/^---$/s/^$2: *//p" "$1" | head -1; }
# Scoped to the frontmatter: a ticket about the ticket format has lines in its
# body that look exactly like fields, and this repo's tickets are full of them.
set_field() { sed -i "2,/^---$/s|^$2:.*|$2:$(printf '%*s' $((10 - ${#2})) '')$3|" "$1"; }

# The library this script is written in, beside it. It only defines things:
# what runs, and in which order, is below.
LIB="$(dirname "${BASH_SOURCE[0]}")/run"
# shellcheck source=run/tickets.sh
. "$LIB/tickets.sh"
# shellcheck source=run/drift.sh
. "$LIB/drift.sh"
# shellcheck source=run/loop.sh
. "$LIB/loop.sh"
# shellcheck source=run/session.sh
. "$LIB/session.sh"
# shellcheck source=run/prompts.sh
. "$LIB/prompts.sh"
# shellcheck source=run/checks.sh
. "$LIB/checks.sh"
# shellcheck source=run/report.sh
. "$LIB/report.sh"

# --- refusals, before anything is launched

[ -n "$TICKETS" ] || die "usage: run.sh changes/<slug>/tickets"
[ -d "$TICKETS" ] || die "no ticket directory: $TICKETS"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"
# The branch refusal just above passes by accident in a repository with no
# commits: it reads the branch that has nothing on it yet. The HEAD check below
# would survive there - `rev-parse HEAD` prints the literal `HEAD` when it
# fails, so a build still moves it and a claim still does not - but a
# correctness check resting on a command echoing its own argument back is not
# one to leave standing.
git rev-parse HEAD >/dev/null 2>&1 \
  || die "no commits here: the branch refusal passes in an empty repository, and the build check would rest on rev-parse echoing HEAD back - commit something first"

branch="$(git rev-parse --abbrev-ref HEAD)"
case "$branch" in
  main|master) die "refusing to run on $branch: a run belongs on a branch of its own" ;;
esac

command -v claude >/dev/null || die "no claude on PATH: the runner drives sessions, it does not do the work"

# One runner per repository. A second one started beside a live run took over
# its claim and resumed the session it was running. The lock is held on a
# descriptor every session inherits, so a session that outlives a killed runner
# still holds it and is still building; what that session starts does not
# inherit it, so a server left running does not.
LOCK="$(git rev-parse --absolute-git-dir)/run.lock"
exec 9>"$LOCK"
flock -n 9 || die "another run, or a session one started, is still working this repository (pids:$(exec 9>&-; fuser "$LOCK" 2>/dev/null | tr -s ' ' '\n' | grep -vx "$$" | tr '\n' ' ')) - let it finish or stop it, then start again"

shopt -s nullglob
TICKET_FILES=()
for f in "$TICKETS"/*.md; do
  # A ticket is a file with criteria behind it. Anything else in the directory
  # is someone's notes, and reading it as a ticket fails every pass.
  grep -q '^criteria:' "$f" && TICKET_FILES+=("$f") || printf 'ignoring %s: not a ticket\n' "$f" >&2
done
[ "${#TICKET_FILES[@]}" -gt 0 ] || die "no tickets in $TICKETS"

# Where each session's full event stream goes. Inside the git directory, so a
# session that commits everything it sees cannot commit its own transcript.
LOG_DIR="${LOG_DIR:-$(git rev-parse --absolute-git-dir)/run-logs}"
mkdir -p "$LOG_DIR"

# Everything but the ticket files, as a pathspec: what is uncommitted in them is
# the runner's own bookkeeping, and a run started again carries on from it.
NOT_TICKETS=(':/')
for t in "${TICKET_FILES[@]}"; do NOT_TICKETS+=(":!$t"); done
check_tree

# Where the token log goes - one file per change - and what it counts is in
# run/session.sh.
TOKENS="$LOG_DIR/$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$(dirname "$TICKETS")" | tr / _).tokens"

# The final review leaves its findings here, and its being committed is how the
# review is known to have finished.
REVIEW="$(dirname "$TICKETS")/REVIEW.md"

preflight || end_run 2 "$HALTED"

drive

# Nothing selectable is not the same as everything finished: a halt and a
# dependency nobody can satisfy look identical from inside the loop, and the
# report says which.
[ -z "$(unfinished)" ] || end_run 1

final_review
end_run 0
