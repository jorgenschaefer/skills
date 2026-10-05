# shellcheck shell=bash
#
# The end of a run: the final review over the whole change, and the report
# every run ends with.
#
# Nobody watches a run, so whatever needs a person is printed at the end of it,
# however it ended - and only that, last, where the screen stops: a halt and the
# whole of why, or what is still open once the review is done. What each build
# left standing is in its ticket and what each cost in the token log; printed
# here, they buried the one halt that stopped a run. Acceptance is pointed to
# only when there is something to accept.
#
# Sourced by run.sh, never run.

# Told what stopped the run by whoever stopped it: a run started again over a
# halt nobody settled builds what does not wait on it, and one that ended named
# the first halt it found named the old one, with another session's log.
end_run() {  # exit status, what stopped the run: the ticket that halted it, or why in a line
  local t left why="${2:-}" built=0
  for t in "${TICKET_FILES[@]}"; do
    [ "$(field "$t" status)" != "done" ] || built=$((built + 1))
  done
  # Nothing named it where the loop ran out of tickets it could pick, and then
  # every halt and every dependency that cannot be met is why: the first halt
  # first, and the rest are listed under it.
  if [ "$1" != 0 ] && [ -z "$why" ]; then
    for t in "${TICKET_FILES[@]}"; do
      [ "$(field "$t" status)" = halted ] && { why="$t"; break; }
    done
    why="${why:-no ticket left is ready: each waits on one that is not done}"
  fi
  printf '\n%s of %s tickets done\n' "$built" "${#TICKET_FILES[@]}"
  if [ "$1" != 0 ]; then
    if [ -f "$why" ]; then
      printf '\nRUN STOPPED: %s %s\n\n' "$(basename "$why")" "$(halt_label "$why")"
      section "$why" Halt | awk 'NR <= 20 { print (NF ? "  " $0 : "") } NR == 21 { print "  ... (rest in the ticket)" }'
      printf '\n  ticket: %s\n' "$why"
      # The last session's log, where that session was this ticket's.
      case "$(basename "${LOG:-}")" in
        "$(basename "$why" .md)"-*) printf '  log:    %s\n' "$LOG" ;;
      esac
    else
      printf '\nRUN STOPPED: %s\n' "$why"
    fi
    for t in "${TICKET_FILES[@]}"; do
      [ "$t" = "$why" ] || [ "$(field "$t" status)" = "done" ] \
        || printf '  %s\n' "$(unfinished_line "$t")"
    done
  else
    if [ -f "$REVIEW" ]; then
      printf '\nstill open after the final review:\n\n'
      if grep -qx '## For you' "$REVIEW"; then
        section "$REVIEW" 'For you'
      else
        head -40 "$REVIEW"
      fi
      printf '\nfull review: %s\n' "$REVIEW"
    else
      for t in "${TICKET_FILES[@]}"; do
        left="$(left_standing "$t")"
        [ -z "$left" ] || printf '\n%s left standing:\n%s\n' "$(basename "$t")" "$left"
      done
    fi
    printf 'next: /accept-criteria %s\n' "$(dirname "$TICKETS")"
  fi
  exit "$1"
}

unfinished() {  # the tickets not done, one line each, saying why
  local t
  for t in "${TICKET_FILES[@]}"; do
    [ "$(field "$t" status)" = "done" ] || unfinished_line "$t"
  done
}

unfinished_line() {  # ticket -> why it is not done
  case "$(field "$1" status)" in
    halted) printf '%s: %s\n' "$(basename "$1")" "$(halt_label "$1")" ;;
    *)      printf '%s: %s, after: %s\n' "$(basename "$1")" "$(field "$1" status)" "$(field "$1" after)" ;;
  esac
}

# A section as its writer wrote it, up to the next heading of its level, blank
# lines at either end dropped.
section() {  # file, heading
  sed -n "/^## $2\$/,/^## /{/^## /d;p;}" "$1" \
    | awk 'NF { if (seen) for (; blank > 0; blank--) print ""; blank = 0; seen = 1; print; next } { blank++ }'
}

halt_label() {  # ticket -> "halted (<kind>)"
  printf 'halted (%s)' "$(halt_kind "$1" | grep . || echo 'kind not named')"
}

left_standing() {  # ticket -> its ## Left standing, blank lines dropped
  section "$1" 'Left standing' | sed '/^[[:space:]]*$/d'
}

# Each build was reviewed on its own, which cannot see what lies between them.
# Over one ticket there is nothing between. REVIEW.md committed is how the
# review is known to have finished, so a run started again once it has does not
# review again - a re-slice deletes it, because it reviewed what is changing.
#
# A review that ends its turn while its critique still runs is ended by `-p`,
# critique killed - one did, and its run stopped with nothing reviewed. It is
# resumed once, as a build that stops short is, since what it found so far is in
# its context.
final_review() {
  local id rc
  [ "${#TICKET_FILES[@]}" -gt 1 ] || return 0
  git cat-file -e "HEAD:./$REVIEW" 2>/dev/null && return 0
  [ -n "$VERIFY" ] || verify
  id="$(new_session_id)"
  claude_through_limits review "$(review_brief)" --session-id "$id"; rc=$?
  if [ "$rc" = 0 ] && ! git cat-file -e "HEAD:./$REVIEW" 2>/dev/null; then
    say "final review stopped without committing $REVIEW - resuming it"
    claude_through_limits review "$REVIEW_STOPPED_EARLY" --resume "$id"; rc=$?
  fi
  [ "$rc" = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait in the final review - run again once it has lifted"
  git cat-file -e "HEAD:./$REVIEW" 2>/dev/null \
    || end_run 1 "the final review did not finish: it committed no $REVIEW - see $LOG"
}

# The change starts where its tickets were first added: every build since is
# part of it, whatever the branch it came from is called.
review_base() {
  local added
  added="$(git log --diff-filter=A --format=%H -- "$TICKETS" | tail -1)"
  git rev-parse -q --verify "$added^" || git hash-object -t tree /dev/null
}
