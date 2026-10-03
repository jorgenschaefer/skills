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

die() { printf '%s\n' "$*" >&2; exit 2; }
say() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*"; }

# The library this script is written in, beside it.
LIB="$(dirname "${BASH_SOURCE[0]}")/run"

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
files=()
for f in "$TICKETS"/*.md; do
  # A ticket is a file with criteria behind it. Anything else in the directory
  # is someone's notes, and reading it as a ticket fails every pass.
  grep -q '^criteria:' "$f" && files+=("$f") || printf 'ignoring %s: not a ticket\n' "$f" >&2
done
[ "${#files[@]}" -gt 0 ] || die "no tickets in $TICKETS"

field()     { sed -n "2,/^---$/s/^$2: *//p" "$1" | head -1; }
# Scoped to the frontmatter: a ticket about the ticket format has lines in its
# body that look exactly like fields, and this repo's tickets are full of them.
set_field() { sed -i "2,/^---$/s|^$2:.*|$2:$(printf '%*s' $((10 - ${#2})) '')$3|" "$1"; }

# Where each session's full event stream goes. Inside the git directory, so a
# session that commits everything it sees cannot commit its own transcript.
LOG_DIR="${LOG_DIR:-$(git rev-parse --absolute-git-dir)/run-logs}"
mkdir -p "$LOG_DIR"

# shellcheck source=run/tickets.sh
. "$LIB/tickets.sh"

# Everything but the ticket files, as a pathspec: what is uncommitted in them is
# the runner's own bookkeeping, and a run started again carries on from it.
not_tickets=(':/')
for t in "${files[@]}"; do not_tickets+=(":!$t"); done
check_tree

# shellcheck source=run/drift.sh
. "$LIB/drift.sh"

# Where the token log goes - one file per change - and what it counts is in
# run/session.sh.
TOKENS="$LOG_DIR/$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$(dirname "$TICKETS")" | tr / _).tokens"

# shellcheck source=run/session.sh
. "$LIB/session.sh"

# shellcheck source=run/prompts.sh
. "$LIB/prompts.sh"

# shellcheck source=run/checks.sh
. "$LIB/checks.sh"

# The final review leaves its findings here, and its being committed is how the
# review is known to have finished.
REVIEW="$(dirname "$TICKETS")/REVIEW.md"

# shellcheck source=run/report.sh
. "$LIB/report.sh"

preflight || end_run 2

# --- the loop

ready_ticket() {  # the first ticket whose dependencies are done
  local t dep ok
  for t in "${files[@]}"; do
    [ "$(field "$t" status)" = ready ] || continue
    ok=yes
    for dep in $(field "$t" after | tr ',' ' '); do
      [ "$(field "$TICKETS/$dep.md" status)" = "done" ] 2>/dev/null || ok=no
    done
    [ "$ok" = yes ] && { printf '%s' "$t"; return 0; }
  done
  return 1
}

# What the next resume of a claimed session is told, where it is not that the
# run was interrupted; and how often this claim's checks came back red.
resume_with="" reds=0

while :; do
  preflight || end_run 2

  # A ticket in flight at the top of the loop is one a killed runner left: every
  # pass below settles its ticket and releases the record. What the record says
  # - which session, and where HEAD was - is picked up wherever the kill
  # interrupted it. Where there is no record it was killed around the session
  # rather than in it, and there is nothing to resume.
  if ticket="$(claimed)" && [ -n "$ticket" ]; then
    attempts="$(field "$ticket" attempts)"
    if ! read -r id head_before 2>/dev/null < "$(claim_record "$ticket")"; then
      say "$(basename "$ticket") was claimed and no session is on record - back to ready"
      put_aside "$ticket" "$attempts"
      set_field "$ticket" status ready
      continue
    fi
    case "$(field "$ticket" status)" in
      doing) say "carrying on with $(basename "$ticket"), attempt $attempts of $MAX_ATTEMPTS"
             session "$ticket" --resume "$id" "${resume_with:-$INTERRUPTED}"; rc=$?
             resume_with="" ;;
      *)     say "settling $(basename "$ticket"), left at $(field "$ticket" status)"; rc=0 ;;
    esac
  else
    ticket="$(ready_ticket)" || break
    # Run here rather than at startup: a run started again runs them only once
    # the ticket it was killed in is finished, never on its half-built work.
    [ -n "$VERIFY" ] || verify

    attempts=$(( $(field "$ticket" attempts) + 1 ))
    if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
      halt "$ticket" exhausted "$MAX_ATTEMPTS attempts spent without a build that stuck - read the build output and \`git stash list\`, which holds what each attempt left uncommitted, and decide whether to raise the budget or re-slice"
      end_run 1
    fi
    set_field "$ticket" attempts "$attempts"
    set_field "$ticket" status doing
    say "claimed $(basename "$ticket"), attempt $attempts of $MAX_ATTEMPTS"

    # Where HEAD was before the build, so that `done` can be checked against
    # what the session did rather than only against what it says it did. On
    # record with the session, because a runner killed during the build is
    # started again with neither.
    head_before="$(git rev-parse HEAD)"
    id="$(new_session_id)" reds=0
    printf '%s %s\n' "$id" "$head_before" > "$(claim_record "$ticket")"
    session "$ticket" --session-id "$id"; rc=$?
  fi

  # A session that ended its turn with its work uncommitted and the ticket still
  # claimed stopped short - one did so with its build done and reviewed, waiting
  # on a check the CLI of the day killed when the turn ended. The CLI now wakes a
  # session when its background work finishes, but a session can still stop
  # short, and this costs nothing when none does. It is resumed once rather than
  # started over, because everything it did is still in the tree and in its
  # context.
  if [ "$rc" = 0 ] && [ "$(field "$ticket" status)" = doing ] && [ -n "$(left_behind)" ]; then
    say "session stopped with its work uncommitted - resuming it"
    session "$ticket" --resume "$id" "$STOPPED_EARLY"; rc=$?
  fi
  if [ "$rc" = "$EX_LIMIT" ]; then
    # A limit that outlasted every wait says nothing about the ticket, so it is
    # handed back as it was claimed, attempt and all, rather than left for the
    # budget to halt.
    if [ "$(field "$ticket" status)" = doing ]; then
      set_field "$ticket" status ready
      set_field "$ticket" attempts "$((attempts - 1))"
    fi
    echo "$(basename "$ticket") is at $(field "$ticket" status) - run again once the limit has lifted" >&2
    release "$ticket"
    end_run 1
  fi

  # Read off the ticket whatever the exit status: a session that crashed after
  # committing its build has built it, and one that crashed before has left the
  # claim for the runner to put back. The attempt is spent either way.
  case "$(field "$ticket" status)" in
    halted) commit_halt "$ticket" "$(halt_kind "$ticket")"; release "$ticket"; end_run 1 ;;
    done) ;;
    *) say "session left $(basename "$ticket") at $(field "$ticket" status) - back to ready"
       put_aside "$ticket" "$attempts"
       set_field "$ticket" status ready; release "$ticket"; continue ;;
  esac

  # A session that says `done` without a commit built nothing, and accepting
  # it is how a ticket reaches done unbuilt - nothing else looks at the commit.
  # Given the same tolerance as a crash, because it is the same kind of failure
  # - a session that did not do what it was launched for - and the halt at the
  # end of it says that, rather than that a budget ran out. Which is why the
  # edge here is `-ge` where the selection above is `-gt`: this fires on the
  # attempt that spends the last of the budget, because falling through to the
  # next pass would halt as `exhausted` and lose the thing worth saying.
  if [ "$(git rev-parse HEAD)" = "$head_before" ]; then
    if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
      halt "$ticket" unbuilt "the session reported a build and committed nothing, and the last of $MAX_ATTEMPTS attempts is spent - read the build output for what stopped it committing, and \`git stash list\` for what each attempt left uncommitted"
      release "$ticket"
      end_run 1
    fi
    echo "unbuilt: $ticket reported a build and committed nothing - building it again" >&2
    put_aside "$ticket" "$attempts"
    set_field "$ticket" status ready
    release "$ticket"
    continue
  fi

  # A ticket the session left out of its commit goes into it all the same: left
  # uncommitted, `done` - and the claim and counter under it - was every later
  # session's "someone else's change", and lost to anything that reset the tree.
  # Into the build's own commit rather than one of the runner's, because a
  # commit message needs a session and amending keeps the one it wrote.
  if ! git diff --quiet HEAD -- "$ticket"; then
    git commit -q --amend --no-edit -- "$ticket" \
      || { echo "could not amend $ticket into $(git rev-parse --short HEAD)" >&2; end_run 1; }
  fi
  say "done: $(basename "$ticket") at $(git rev-parse --short HEAD)"
  # Whatever the build left lying around besides its commit is not the next
  # ticket's, and would read to its session as its own work - nor the checks':
  # an untracked file failed the lint of every session in one run.
  put_aside "$ticket" "$attempts"

  # The build's checks are its session's account of them. The runner runs them
  # on the commit, and a red one goes back to the session that made it, which
  # still has the build in its context - so the claim stands until they are
  # green. The first red is free, as a session stopping early is; each one after
  # it spends an attempt, and the budget halts it as it halts any other.
  [ -n "$VERIFY" ] || find_checks
  if ! run_checks; then
    reds=$((reds + 1))
    if [ "$reds" -gt 1 ]; then
      attempts=$((attempts + 1))
      if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
        halt "$ticket" exhausted "the project's checks (\`$VERIFY\`) stayed red on its build through $MAX_ATTEMPTS attempts - the last output is in $CHECKS_LOG"
        release "$ticket"
        end_run 1
      fi
      set_field "$ticket" attempts "$attempts"
    fi
    say "the checks fail on $(basename "$ticket")'s build - handing it back to its session"
    set_field "$ticket" status doing
    printf '%s %s\n' "$id" "$(git rev-parse HEAD)" > "$(claim_record "$ticket")"
    resume_with="$(red_checks)"
    continue
  fi
  say "the checks pass"
  release "$ticket"
done

# Nothing selectable is not the same as everything finished: a halt and a
# dependency nobody can satisfy look identical from inside the loop, and the
# report says which.
[ -z "$(unfinished)" ] || end_run 1

final_review
end_run 0
