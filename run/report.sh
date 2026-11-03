# shellcheck shell=bash
#
# The end of a run: the final review over the whole change, and the report
# every run ends with.
#
# Nobody watches a run, so whatever needs a person is printed at the end of it,
# however it ended - and only that, last, where the screen stops: a halt and the
# whole of why, or where to go on. What a finished run leaves open waits for
# acceptance, which reads every chunk's Left standing and REVIEW.md whole and
# puts each item to the person; printed here too, it was only a preview of that
# list. Pages of Left standing printed here once buried the one halt that
# stopped a run. Acceptance is pointed to only when there is something to
# accept.
#
# Sourced by run.sh, never run.

# Told what stopped the run by whoever stopped it: a usage limit or a review
# that did not finish leaves no halt in a part to find.
end_run() {  # exit status, what stopped the run: the chunk that halted it, or why in a line
  local t why="${2:-}" built=0
  for t in "${CHUNK_FILES[@]}"; do
    [ "$(field "$t" status)" != "done" ] || built=$((built + 1))
  done
  # Nothing named it where the loop found no part it could pick: the parts are
  # built in order, so the first one not done stopped it - a halt, as a rule -
  # and the rest are listed under it.
  if [ "$1" != 0 ] && [ -z "$why" ]; then
    for t in "${CHUNK_FILES[@]}"; do
      [ "$(field "$t" status)" = halted ] && { why="$t"; break; }
    done
    why="${why:-no part left is ready}"
  fi
  printf '\n%s of %s parts done\n' "$built" "${#CHUNK_FILES[@]}"
  if [ "$1" != 0 ]; then
    if [ -f "$why" ]; then
      printf '\nRUN STOPPED: %s %s\n\n' "$(basename "$why")" "$(halt_label "$why")"
      section "$why" Halt | awk 'NR <= 20 { print (NF ? "  " $0 : "") } NR == 21 { print "  ... (rest in the part)" }'
      printf '\n  part:   %s\n' "$why"
      # The last session's log, where that session was this part's.
      case "$(basename "${LOG:-}")" in
        "$(basename "$why" .md)"-*) printf '  log:    %s\n' "$LOG" ;;
      esac
    else
      printf '\nRUN STOPPED: %s\n' "$why"
    fi
    for t in "${CHUNK_FILES[@]}"; do
      [ "$t" = "$why" ] || [ "$(field "$t" status)" = "done" ] \
        || printf '  %s\n' "$(unfinished_line "$t")"
    done
  else
    printf 'next: /accept-change %s\n' "$CHANGE_DIR"
  fi
  exit "$1"
}

unfinished() {  # the chunks not done, one line each, saying why
  local t
  for t in "${CHUNK_FILES[@]}"; do
    [ "$(field "$t" status)" = "done" ] || unfinished_line "$t"
  done
}

unfinished_line() {  # chunk -> why it is not done
  case "$(field "$1" status)" in
    halted) printf '%s: %s\n' "$(basename "$1")" "$(halt_label "$1")" ;;
    *)      printf '%s: %s\n' "$(basename "$1")" "$(field "$1" status)" ;;
  esac
}

# A section as its writer wrote it, up to the next heading of its level, blank
# lines at either end dropped.
section() {  # file, heading
  sed -n "/^## $2\$/,/^## /{/^## /d;p;}" "$1" \
    | awk 'NF { if (seen) for (; blank > 0; blank--) print ""; blank = 0; seen = 1; print; next } { blank++ }'
}

halt_label() {  # chunk -> "halted (<kind>)"
  printf 'halted (%s)' "$(halt_kind "$1" | grep . || echo 'kind not named')"
}

left_standing() {  # chunk -> its ## Left standing, blank lines dropped
  section "$1" 'Left standing' | sed '/^[[:space:]]*$/d'
}

# Each build was reviewed on its own, which cannot see what lies between them.
# Over one chunk there is nothing between. REVIEW.md committed is how the
# review is known to have finished, so a run started again once it has does not
# review again - a new split deletes it, because it reviewed what is changing.
# It runs the checks again, though: whatever stopped the last run may have
# stopped it before they were green on the review's commits, and nothing points
# on to acceptance with a red check. With no review session left to hand them
# to, a red one is the developer's to settle.
#
# A review that ends its turn while its reviewer still runs is ended by `-p`,
# the reviewer killed - one did, and its run stopped with nothing reviewed. It is
# resumed once, as a build that stops short is, since what it found so far is in
# its context.
final_review() {
  local id rc head_before
  [ "${#CHUNK_FILES[@]}" -gt 1 ] || return 0
  if git cat-file -e "HEAD:./$REVIEW" 2>/dev/null; then
    run_checks || end_run 1 "the final review is committed and the checks are red on it: $RED - fix them by hand, then run again"
    say "the checks pass"
    return 0
  fi
  [ -n "$CHECKED" ] || verify
  id="$(new_session_id)" head_before="$(git rev-parse HEAD)"
  claude_through_limits review "$(review_brief)" --session-id "$id"; rc=$?
  if [ "$rc" = 0 ] && ! git cat-file -e "HEAD:./$REVIEW" 2>/dev/null; then
    say "final review stopped without committing $REVIEW - resuming it"
    claude_through_limits review "$REVIEW_STOPPED_EARLY" --resume "$id"; rc=$?
  fi
  [ "$rc" = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait in the final review - run again once it has lifted"
  git cat-file -e "HEAD:./$REVIEW" 2>/dev/null \
    || end_run 1 "the final review did not finish: it committed no $REVIEW - see $LOG"
  # A review is held to the journeys as a build is. It has no chunk to halt
  # in, so the run's last lines say it.
  [ -z "$(journeys_touched "$head_before")" ] \
    || end_run 1 "the final review changed journeys the developer approved before the build: $(journeys_touched "$head_before" | tr '\n' ' ')- decide whether they should change; where they should not, revert the review's commits since $(git rev-parse --short "$head_before") and run again"
  review_checks "$id"
}

# The review fixes what it finds and commits, and its session's account of the
# checks is an account, as a build's is. A red one goes back to it, on the
# budget a chunk's red checks spend: the first free, each after it an attempt.
# The review has no chunk to write a halt into, so the run's last lines name
# the red check. What it leaves uncommitted is put aside first, as a build's
# is: a fix it never committed turned the checks green on a red HEAD.
review_checks() {  # the review's session id
  local attempts=1 reds=0
  until put_aside "$REVIEW" "$attempts"; run_checks; do
    reds=$((reds + 1))
    if [ "$reds" -gt 1 ]; then
      attempts=$((attempts + 1))
      [ "$attempts" -le "$MAX_ATTEMPTS" ] \
        || end_run 1 "the checks stayed red on the final review's commits through $MAX_ATTEMPTS attempts: $RED - fix them by hand, then run again; \`git stash list\` holds what each attempt left uncommitted"
    fi
    say "the checks fail on the final review's commit - handing it back to its session, attempt $attempts of $MAX_ATTEMPTS: $RED"
    claude_through_limits review "$(red_review_checks)" --resume "$1"
    [ $? = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait while the final review fixed red checks: $RED - fix them by hand, then run again"
  done
  say "the checks pass"
}

# The change starts where its parts were first added to plan/: every build
# since is part of it, whatever the branch it came from is called. The final
# review only runs where there are parts, so there always are.
# accept-change/signals.sh starts earlier, at the change's first file:
# acceptance answers for the journeys the change edited too.
review_base() {
  local added
  added="$(git log --diff-filter=A --format=%H -- "$PARTS" | tail -1)"
  git rev-parse -q --verify "$added^" || git hash-object -t tree /dev/null
}
