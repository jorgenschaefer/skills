# shellcheck shell=bash
# shellcheck disable=SC2154
#
# The drift pre-flight: before each pass, in both directions. A session never
# reads CRITERIA.md and a committed ticket is revisited by nobody but a
# re-slice, so this is the only place the two can be found to disagree - and
# the report has to say which way, because an edit upstream and a slicing that
# lost something need different answers.
#
# Sourced by run.sh, never run. Reads its `files` and `TICKETS`, and calls its
# `field` and `halt`.

preflight() {
  local t criteria id dep nudge problems="" culprit="" all_criteria=() closers=()
  for t in "${files[@]}"; do
    # Resolved beside the tickets/ directory, not from the working directory:
    # the frontmatter says `CRITERIA.md` and means the one this slicing came
    # from, whatever the runner was invoked from.
    criteria="$(dirname "$TICKETS")/$(field "$t" criteria)"
    if [ ! -f "$criteria" ]; then
      problems+="$(basename "$t"): names $criteria, which is not there"$'\n'
      [ -n "$culprit" ] || culprit="$t"
      continue
    fi
    [[ " ${all_criteria[*]-} " == *" $criteria "* ]] || all_criteria+=("$criteria")
    # A deleted ticket leaves the ones after it waiting on something that will
    # never be done, and the loop would only say so once it had run out of work.
    for dep in $(field "$t" after | tr ',' ' '); do
      if ! grep -qs '^criteria:' "$TICKETS/$dep.md"; then
        problems+="$(basename "$t"): after: names $dep, which is not a ticket"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    for id in $(quoted "$t"); do
      # A criterion deleted upstream and one reworded need the same re-slice,
      # but the person reading the halt should not have to diff to tell which.
      if [ -z "$(text_of "$criteria" "$id")" ]; then
        problems+="$(basename "$t"): $id is gone from $criteria"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      elif [ "$(text_of "$t" "$id")" != "$(text_of "$criteria" "$id")" ]; then
        problems+="$(basename "$t"): $id no longer matches $criteria"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    # Coverage is counted from the frontmatter and the builder reads the quote.
    for id in $(claims "$t"); do
      if ! quoted "$t" | grep -qx "$id"; then
        problems+="$(basename "$t"): claims $id and does not quote it"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    for id in $(quoted "$t"); do
      if ! claims "$t" | grep -qx "$id"; then
        problems+="$(basename "$t"): quotes $id and neither closes nor advances it"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    while IFS= read -r nudge; do
      if ! nudges_of "$criteria" - | grep -qxF -- "$nudge"; then
        problems+="$(basename "$t"): a nudge it quotes is not in $criteria word for word: $nudge"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done < <(nudges_of "$t" '>')
  done
  # Once per CRITERIA.md, not once per ticket: this direction asks something of
  # the directory as a whole, and asking it inside the loop above reported a
  # lost criterion once for every ticket that had not lost it.
  for criteria in ${all_criteria[@]+"${all_criteria[@]}"}; do
    # Exactly one ticket closes each criterion - the one after which it is
    # true, and which writes its test - and it comes after every ticket that
    # advances it, or that test is red for want of work still to run.
    for id in $(declared "$criteria"); do
      closers=()
      for t in "${files[@]}"; do
        field "$t" closes | grep -qw -- "$id" && closers+=("$t")
      done
      case "${#closers[@]}" in
        0) problems+="$criteria: $id is closed by no ticket"$'\n'
           [ -n "$culprit" ] || culprit="${files[0]}" ;;
        1) for t in "${files[@]}"; do
             field "$t" advances | grep -qw -- "$id" || continue
             comes_after "${closers[0]}" "$(basename "$t" .md)" && continue
             problems+="$(basename "${closers[0]}"): closes $id and does not come after $(basename "$t" .md), which advances it"$'\n'
             [ -n "$culprit" ] || culprit="${closers[0]}"
           done ;;
        *) problems+="$criteria: $id is closed by more than one ticket: $(for t in "${closers[@]}"; do basename "$t" .md; done | tr '\n' ' ' | sed 's/ $//')"$'\n'
           [ -n "$culprit" ] || culprit="${closers[0]}" ;;
      esac
    done
  done
  if [ -n "$problems" ]; then
    printf 'drift - the tickets and CRITERIA.md disagree:\n%s' "$problems" >&2
    # The stop is named in the ticket, not only on someone's terminal - nobody is
    # watching the terminal, which is the whole premise. The first offender
    # carries it, because that is where a person will look; where the offence
    # belongs to the directory rather than to one ticket, the first ticket does.
    #
    # Carried alongside the message rather than parsed back out of it. Reading
    # the ticket off the text meant two of the three messages named no ticket
    # the `-f` guard could find, and both fell through it silently.
    [ -n "$culprit" ] && halt "$culprit" drift \
      "CRITERIA.md and this ticket no longer agree - re-slice the unbuilt tickets with /criteria-to-tickets"
    return 1
  fi
}

# The criteria a ticket quotes, and the criteria CRITERIA.md carries, in the
# one shape both can be compared in.
quoted()   { grep -o '^> \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
claims()   { printf '%s %s\n' "$(field "$1" closes)" "$(field "$1" advances)" | grep -o 'AC-[0-9]\+' | sort -u; }
declared() { grep -o '^- \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
text_of()  { # file, id -> the criterion as written, marker stripped
  # A blank line ends a criterion unless an indented line follows it: that is
  # a further paragraph of the same list item, as Markdown reads it. A ticket
  # quotes the blank line as a bare `>`, which is no blank line at all.
  awk -v id="$2" '
    index($0, "- **" id "**") == 1 || index($0, "> **" id "**") == 1 { found = 1; print; next }
    found && (/^[->] \*\*AC-/ || /^#/) { exit }
    found && /^$/ { blank = 1; next }
    found && blank && !/^[[:space:]]/ { exit }
    found { blank = 0; print }
  ' "$1" | sed 's/^> \{0,1\}//; s/^[[:space:]]*- //; s/^[[:space:]]*//' | tr '\n' ' ' | sed 's/  */ /g; s/ *$//'
}
# Whether a ticket comes after another, directly or by way of others.
comes_after() {  # ticket, slug of the other
  local target="$2" dep seen=" " todo more
  read -ra todo <<< "$(field "$1" after | tr ',' ' ')"
  while [ "${#todo[@]}" -gt 0 ]; do
    dep="${todo[0]}"; todo=("${todo[@]:1}")
    [ "$dep" = "$target" ] && return 0
    [[ "$seen" == *" $dep "* ]] && continue
    seen+="$dep "
    [ -f "$TICKETS/$dep.md" ] && read -ra more <<< "$(field "$TICKETS/$dep.md" after | tr ',' ' ')" && todo+=(${more[@]+"${more[@]}"})
  done
  return 1
}
# A nudge has no id, so it is found by its words: one per line, whitespace
# flattened, as a `- ` item in CRITERIA.md and as a `> ` quote in a ticket.
nudges_of() {  # file, the marker its nudges start with
  awk -v m="$2" '
    function flush() { if (item != "") print item; item = "" }
    /^#/ { flush(); in_nudges = ($0 == "## Nudges"); next }
    !in_nudges { next }
    /^[[:space:]]*$/ { flush(); next }
    index($0, m) == 1 { if (m == "-") flush(); sub(/^[->][[:space:]]*/, "") }
    { gsub(/[[:space:]]+/, " "); sub(/^ /, ""); sub(/ $/, ""); item = item (item == "" ? "" : " ") $0 }
    END { flush() }
  ' "$1"
}
