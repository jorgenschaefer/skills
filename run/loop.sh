# shellcheck shell=bash
#
# The loop: claim a chunk, build it, and either finish it or send it back,
# until no chunk is ready. A chunk a killed runner left in flight is settled
# first, from whatever its chunk file and claim record say.
#
# Sourced by run.sh, never run.

drive() {
  # What the next resume of a claimed session is told, where it is not that the
  # run was interrupted; and how often this claim's checks came back red.
  local chunk attempts id head_before rc resume_with="" reds=0

  while :; do
    # A chunk in flight at the top of the loop is one a killed runner left: every
    # pass below settles its chunk and releases the record. What the record says
    # - which session, and where HEAD was - is picked up wherever the kill
    # interrupted it. Where there is no record it was killed around the session
    # rather than in it, and there is nothing to resume.
    if chunk="$(claimed)" && [ -n "$chunk" ]; then
      attempts="$(field "$chunk" attempts)"
      if ! read -r id head_before 2>/dev/null < "$(claim_record "$chunk")"; then
        say "$(basename "$chunk") was claimed and no session is on record - back to ready"
        put_aside "$chunk" "$attempts"
        set_field "$chunk" status ready
        continue
      fi
      case "$(field "$chunk" status)" in
        doing) say "carrying on with $(basename "$chunk"), attempt $attempts of $MAX_ATTEMPTS"
               session "$chunk" --resume "$id" "${resume_with:-$INTERRUPTED}"; rc=$?
               resume_with="" ;;
        *)     say "settling $(basename "$chunk"), left at $(field "$chunk" status)"; rc=0 ;;
      esac
    else
      chunk="$(ready_chunk)" || break
      # Run here rather than at startup: a run started again runs them only once
      # the chunk it was killed in is finished, never on its half-built work.
      [ -n "$CHECKED" ] || verify

      attempts=$(( $(field "$chunk" attempts) + 1 ))
      if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
        halt "$chunk" exhausted "$MAX_ATTEMPTS attempts spent without a build that stuck - read the build output and \`git stash list\`, which holds what each attempt left uncommitted, and decide whether to raise the budget or split the change again"
        end_run 1 "$chunk"
      fi
      set_field "$chunk" attempts "$attempts"
      set_field "$chunk" status doing
      say "claimed $(basename "$chunk"), attempt $attempts of $MAX_ATTEMPTS"

      # Where HEAD was before the build, so that `done` can be checked against
      # what the session did rather than only against what it says it did. On
      # record with the session, because a runner killed during the build is
      # started again with neither.
      head_before="$(git rev-parse HEAD)"
      id="$(new_session_id)" reds=0
      printf '%s %s\n' "$id" "$head_before" > "$(claim_record "$chunk")"
      session "$chunk" --session-id "$id"; rc=$?
    fi

    # A session that ended its turn with the chunk still claimed stopped short -
    # one did so with its build done and reviewed, waiting on a check the CLI of
    # the day killed when the turn ended; another committed its build and stopped
    # on the checks it had started, and with nothing uncommitted it was claimed
    # again from scratch and halted over a build already in HEAD. Nothing runs in
    # the background now, but a session can still stop short, and this costs
    # nothing when none does. It is resumed once rather than started over,
    # because everything it did is still in the tree, the commits and its context.
    if [ "$rc" = 0 ] && [ "$(field "$chunk" status)" = doing ]; then
      say "session stopped with the part unfinished - resuming it"
      session "$chunk" --resume "$id" "$STOPPED_EARLY"; rc=$?
    fi
    if [ "$rc" = "$EX_LIMIT" ]; then
      # A limit that outlasted every wait says nothing about the chunk, so it is
      # handed back as it was claimed, attempt and all, rather than left for the
      # budget to halt.
      if [ "$(field "$chunk" status)" = doing ]; then
        set_field "$chunk" status ready
        set_field "$chunk" attempts "$((attempts - 1))"
      fi
      release "$chunk"
      end_run 1 "a usage limit outlasted every wait - $(basename "$chunk") is at $(field "$chunk" status), run again once it has lifted"
    fi

    # Read off the chunk whatever the exit status: a session that crashed after
    # committing its build has built it, and one that crashed before has left the
    # claim for the runner to put back. The attempt is spent either way.
    case "$(field "$chunk" status)" in
      halted) commit_halt "$chunk" "$(halt_kind "$chunk")"; release "$chunk"; end_run 1 "$chunk" ;;
      done) ;;
      *) say "session left $(basename "$chunk") at $(field "$chunk" status) - back to ready"
         put_aside "$chunk" "$attempts"
         set_field "$chunk" status ready; release "$chunk"; continue ;;
    esac

    # A session that says `done` without a commit built nothing, and accepting
    # it is how a chunk reaches done unbuilt - nothing else looks at the commit.
    # Given the same tolerance as a crash, because it is the same kind of failure
    # - a session that did not do what it was launched for - and the halt at the
    # end of it says that, rather than that a budget ran out. Which is why the
    # edge here is `-ge` where the selection above is `-gt`: this fires on the
    # attempt that spends the last of the budget, because falling through to the
    # next pass would halt as `exhausted` and lose the thing worth saying.
    if [ "$(git rev-parse HEAD)" = "$head_before" ]; then
      if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
        halt "$chunk" unbuilt "the session reported a build and committed nothing, and the last of $MAX_ATTEMPTS attempts is spent - read the build output for what stopped it committing, and \`git stash list\` for what each attempt left uncommitted"
        release "$chunk"
        end_run 1 "$chunk"
      fi
      echo "unbuilt: $chunk reported a build and committed nothing - building it again" >&2
      put_aside "$chunk" "$attempts"
      set_field "$chunk" status ready
      release "$chunk"
      continue
    fi

    # The journeys were approved before the build, and a build that changes one
    # has changed what the developer agreed to. That is theirs to decide, so the
    # run stops here, with the build's commits standing for them to keep or
    # revert.
    if [ -n "$(journeys_touched "$head_before")" ]; then
      halt "$chunk" departure "the build changed journeys the developer approved before it: $(journeys_touched "$head_before" | tr '\n' ' ')- decide whether they should change; where they should not, revert the build's commits since $(git rev-parse --short "$head_before") and run again"
      release "$chunk"
      end_run 1 "$chunk"
    fi

    # A chunk the session left out of its commit goes into it all the same: left
    # uncommitted, `done` - and the claim and counter under it - was every later
    # session's "someone else's change", and lost to anything that reset the tree.
    # Into the build's own commit rather than one of the runner's, because a
    # commit message needs a session and amending keeps the one it wrote.
    if ! git diff --quiet HEAD -- "$chunk"; then
      git commit -q --amend --no-edit -- "$chunk" \
        || end_run 1 "could not amend $chunk into $(git rev-parse --short HEAD)"
    fi
    say "done: $(basename "$chunk") at $(git rev-parse --short HEAD)"
    # Whatever the build left lying around besides its commit is not the next
    # chunk's, and would read to its session as its own work - nor the checks':
    # an untracked file failed the lint of every session in one run.
    put_aside "$chunk" "$attempts"

    # The build's checks are its session's account of them. The runner runs them
    # on the commit, and a red one goes back to the session that made it, which
    # still has the build in its context - so the claim stands until they are
    # green. The first red is free, as a session stopping early is; each one after
    # it spends an attempt, and the budget halts it as it halts any other. The
    # commands are read again from the commit, which may be the one declaring them.
    if ! run_checks; then
      reds=$((reds + 1))
      if [ "$reds" -gt 1 ]; then
        attempts=$((attempts + 1))
        if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
          halt "$chunk" exhausted "the project's checks stayed red on its build through $MAX_ATTEMPTS attempts: $RED"
          release "$chunk"
          end_run 1 "$chunk"
        fi
        set_field "$chunk" attempts "$attempts"
      fi
      say "the checks fail on $(basename "$chunk")'s build - handing it back to its session: $RED"
      set_field "$chunk" status doing
      printf '%s %s\n' "$id" "$(git rev-parse HEAD)" > "$(claim_record "$chunk")"
      resume_with="$(red_checks)"
      continue
    fi
    say "the checks pass"
    release "$chunk"
    run_skill
  done
}

# The parts are built one after the other, in the order of their numbers: a
# part rests on what the parts before it built. So the next part is the first
# one not done, and where that one is not ready - halted, say - nothing after it
# is either.
ready_chunk() {  # -> the next part to build
  local t
  for t in "${CHUNK_FILES[@]}"; do
    case "$(field "$t" status)" in
      done) ;;
      ready) printf '%s' "$t"; return 0 ;;
      *) return 1 ;;
    esac
  done
  return 1
}
