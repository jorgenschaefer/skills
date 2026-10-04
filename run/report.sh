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

end_run() {  # exit status
  local t left halted="" done=0
  for t in "${TICKET_FILES[@]}"; do
    case "$(field "$t" status)" in
      done) done=$((done + 1)) ;;
      halted) [ -n "$halted" ] || halted="$t" ;;
    esac
  done
  printf '\n%s of %s tickets done\n' "$done" "${#TICKET_FILES[@]}"
  if [ -n "$halted" ]; then
    printf '\nRUN STOPPED: %s halted (%s)\n\n' "$(basename "$halted")" "$(halt_kind "$halted")"
    section "$halted" Halt | awk 'NR <= 20 { print (NF ? "  " $0 : "") } NR == 21 { print "  ... (rest in the ticket)" }'
    printf '\n  ticket: %s\n' "$halted"
    [ -z "${LOG:-}" ] || printf '  log:    %s\n' "$LOG"
    for t in "${TICKET_FILES[@]}"; do
      [ "$t" = "$halted" ] || [ "$(field "$t" status)" = "done" ] \
        || printf '  %s\n' "$(unfinished_line "$t")"
    done
  elif [ "$1" != 0 ]; then
    printf '\nRUN STOPPED with work left:\n'
    unfinished | sed 's/^/  /'
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
    halted) printf '%s: halted - %s\n' "$(basename "$1")" "$(halt_kind "$1")" ;;
    *)      printf '%s: %s, after: %s\n' "$(basename "$1")" "$(field "$1" status)" "$(field "$1" after)" ;;
  esac
}

# A section as its writer wrote it, up to the next heading of its level, blank
# lines at either end dropped.
section() {  # file, heading
  sed -n "/^## $2\$/,/^## /{/^## /d;p;}" "$1" \
    | awk 'NF { if (seen) for (; blank > 0; blank--) print ""; blank = 0; seen = 1; print; next } { blank++ }'
}

left_standing() {  # ticket -> its ## Left standing, blank lines dropped
  sed -n '/^## Left standing$/,/^#/{/^#/d;p;}' "$1" | sed '/^[[:space:]]*$/d'
}

# Each build was reviewed on its own, which cannot see what lies between them.
# Over one ticket there is nothing between. REVIEW.md committed is how the
# review is known to have finished, so a run started again once it has does not
# review again - a re-slice deletes it, because it reviewed what is changing.
final_review() {
  [ "${#TICKET_FILES[@]}" -gt 1 ] || return 0
  git cat-file -e "HEAD:./$REVIEW" 2>/dev/null && return 0
  [ -n "$VERIFY" ] || verify
  claude_through_limits review "$(review_brief)" --session-id "$(new_session_id)"
  [ $? = "$EX_LIMIT" ] && end_run 1
  git cat-file -e "HEAD:./$REVIEW" 2>/dev/null \
    || { echo "the final review did not finish: it committed no $REVIEW - see $LOG" >&2; end_run 1; }
}

# The change starts where its tickets were first added: every build since is
# part of it, whatever the branch it came from is called.
review_base() {
  local added
  added="$(git log --diff-filter=A --format=%H -- "$TICKETS" | tail -1)"
  git rev-parse -q --verify "$added^" || git hash-object -t tree /dev/null
}
