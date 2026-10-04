# shellcheck shell=bash
#
# The end of a run: the final review over the whole change, and the report
# every run ends with.
#
# Nobody watches a run, so whatever needs a person is printed at the end of it,
# however it ended. Acceptance is pointed to only when there is something to
# accept.
#
# Sourced by run.sh, never run.

end_run() {  # exit status
  local t left
  if [ -n "$(unfinished)" ]; then
    printf 'stopped with work left in %s:\n%s' "$TICKETS" "$(unfinished)" >&2
  fi
  for t in "${TICKET_FILES[@]}"; do
    left="$(left_standing "$t")"
    [ -z "$left" ] || printf '\n%s left standing:\n%s\n' "$(basename "$t")" "$left"
  done
  [ ! -f "$REVIEW" ] || printf '\nthe final review left:\n%s\n' "$(cat "$REVIEW")"
  token_summary
  [ "$1" != 0 ] || printf '\nevery ticket in %s is done - walk it with /accept-criteria %s\n' \
                          "$TICKETS" "$(dirname "$TICKETS")"
  exit "$1"
}

unfinished() {  # the tickets not done, one line each, saying why
  local t
  for t in "${TICKET_FILES[@]}"; do
    case "$(field "$t" status)" in
      done) ;;
      halted) printf '%s: halted - %s\n' "$(basename "$t")" "$(sed -n '/^## Halt$/,$p' "$t" | sed -n '3p')" ;;
      *)      printf '%s: %s, after: %s\n' "$(basename "$t")" "$(field "$t" status)" "$(field "$t" after)" ;;
    esac
  done
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
