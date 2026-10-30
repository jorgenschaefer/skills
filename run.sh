#!/usr/bin/env bash
#
# Build a change with nobody watching.
#
#   ./run.sh changes/<slug>
#
# The change's CHANGE.md was agreed with the developer and committed on the
# change's branch with its journeys. On a first start a session splits it into
# chunks where one agent cannot build it within one context, and where it can,
# CHANGE.md is built as the one chunk.
#
# Everything here is something that has to hold when a session is dead or
# misbehaving, which is why it is a script and not a skill. A session cannot
# enforce a budget it is spending, cannot reset a claim it is holding when it
# dies, and cannot wait out a limit that has already stopped it.
#
# The loop per chunk: claim it, build it, and either finish it or send it
# back. The runner owns `doing`, and a session writes `done` or `halted` and
# nothing else. A `done` is the session's claim, which the runner checks against
# the commit - a claim with no commit behind it is sent back - so nothing reaches
# `done` unbuilt, and a run killed at any point is started again from whatever
# the chunk files and the claim record say.
#
# There is no review pass per chunk. `/implement-change` spawns its own
# reviewer in a subagent that did not write the code, and a second review of a
# reviewed commit reviews a review. What no chunk's review can see - what lies
# between the chunks - gets one review of the whole change at the end.

set -uo pipefail

CHANGE_DIR="${1:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # builds of one chunk before it is exhausted
WAIT_SECONDS="${WAIT_SECONDS:-300}"   # after a usage limit that names no reset time
LIMIT_MARGIN="${LIMIT_MARGIN:-120}"   # past a limit's reset time, before carrying on
MAX_WAITS="${MAX_WAITS:-8}"           # limits in a row before the run gives up
FAST_CHECK=""                         # the fast check, once the checks have run - never from outside
SLOW_CHECK=""                         # the slow check, where CLAUDE.md declares one
ASKED_FAST_CHECK=""                   # a session's answer where CLAUDE.md declares no fast check
HALTED=""                             # the chunk last halted in this run, for its end to name

die() { printf '%s\n' "$*" >&2; exit 2; }
say() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*"; }

field()     { sed -n "2,/^---$/s/^$2: *//p" "$1" | head -1; }
# Scoped to the frontmatter: a chunk about the chunk format has lines in its
# body that look exactly like fields, and this repo's chunks are full of them.
set_field() { sed -i "2,/^---$/s|^$2:.*|$2:$(printf '%*s' $((10 - ${#2})) '')$3|" "$1"; }

# The library this script is written in, beside it. It only defines things:
# what runs, and in which order, is below.
LIB="$(dirname "${BASH_SOURCE[0]}")/run"
# shellcheck source=run/chunks.sh
. "$LIB/chunks.sh"
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

[ -n "$CHANGE_DIR" ] || die "usage: run.sh changes/<slug>"
[ -f "$CHANGE_DIR/CHANGE.md" ] || die "no CHANGE.md in $CHANGE_DIR"
CHANGE_DIR="$(realpath -s --relative-to=. "$CHANGE_DIR")"
CHANGE="$CHANGE_DIR/CHANGE.md"
CHUNKS="$CHANGE_DIR/chunks"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"
# A repository with no commits has a branch with nothing on it yet. The HEAD
# check below would survive there - `rev-parse HEAD` prints the literal `HEAD`
# when it fails, so a build still moves it and a claim still does not - but a
# correctness check resting on a command echoing its own argument back is not
# one to leave standing.
git rev-parse HEAD >/dev/null 2>&1 \
  || die "no commits here: the build check would rest on rev-parse echoing HEAD back - commit something first"

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
load_chunks

# Where each session's full event stream goes. Inside the git directory, so a
# session that commits everything it sees cannot commit its own transcript.
LOG_DIR="${LOG_DIR:-$(git rev-parse --absolute-git-dir)/run-logs}"
mkdir -p "$LOG_DIR"

check_tree

# A change is built on its own branch, which /design-user-journeys made when
# it committed the journeys and CHANGE.md - so main never describes software
# that is not built yet.
branch="$(git rev-parse --abbrev-ref HEAD)"
case "$branch" in
  main|master) die "refusing to run on $branch: a change is built on the branch /design-user-journeys made for it - switch to it, then start again" ;;
esac

# Where the token log and the refused log go - one of each per change - and
# what they hold is in run/session.sh.
TOKENS="$LOG_DIR/$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$CHANGE_DIR" | tr / _).tokens"
REFUSED="${TOKENS%.tokens}.refused"

# The final review leaves its findings here, and its being committed is how the
# review is known to have finished.
REVIEW="$CHANGE_DIR/REVIEW.md"

split_change

preflight || end_run 2 "$HALTED"

drive

# Nothing selectable is not the same as everything finished: a halt and a
# dependency nobody can satisfy look identical from inside the loop, and the
# report says which.
[ -z "$(unfinished)" ] || end_run 1

final_review
end_run 0
