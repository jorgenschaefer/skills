# shellcheck shell=bash
#
# The loop: claim a ticket, build it, and either finish it or send it back,
# until no ticket is ready. A ticket a killed runner left in flight is settled
# first, from whatever its ticket file and claim record say.
#
# Sourced by run.sh, never run.

drive() {
  # What the next resume of a claimed session is told, where it is not that the
  # run was interrupted; and how often this claim's checks came back red.
  local ticket attempts id head_before rc resume_with="" reds=0

  while :; do
    preflight || end_run 2 "$HALTED"

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
        end_run 1 "$ticket"
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

    # A session that ended its turn with the ticket still claimed stopped short -
    # one did so with its build done and reviewed, waiting on a check the CLI of
    # the day killed when the turn ended; another committed its build and stopped
    # on the checks it had started, and with nothing uncommitted it was claimed
    # again from scratch and halted over a build already in HEAD. Nothing runs in
    # the background now, but a session can still stop short, and this costs
    # nothing when none does. It is resumed once rather than started over,
    # because everything it did is still in the tree, the commits and its context.
    if [ "$rc" = 0 ] && [ "$(field "$ticket" status)" = doing ]; then
      say "session stopped with the ticket unfinished - resuming it"
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
      release "$ticket"
      end_run 1 "a usage limit outlasted every wait - $(basename "$ticket") is at $(field "$ticket" status), run again once it has lifted"
    fi

    # Read off the ticket whatever the exit status: a session that crashed after
    # committing its build has built it, and one that crashed before has left the
    # claim for the runner to put back. The attempt is spent either way.
    case "$(field "$ticket" status)" in
      halted) commit_halt "$ticket" "$(halt_kind "$ticket")"; release "$ticket"; end_run 1 "$ticket" ;;
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
        end_run 1 "$ticket"
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
        || end_run 1 "could not amend $ticket into $(git rev-parse --short HEAD)"
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
          end_run 1 "$ticket"
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
}

ready_ticket() {  # the first ticket whose dependencies are done
  local t dep ok
  for t in "${TICKET_FILES[@]}"; do
    [ "$(field "$t" status)" = ready ] || continue
    ok=yes
    for dep in $(field "$t" after | tr ',' ' '); do
      [ "$(field "$TICKETS/$dep.md" status)" = "done" ] 2>/dev/null || ok=no
    done
    [ "$ok" = yes ] && { printf '%s' "$t"; return 0; }
  done
  return 1
}
