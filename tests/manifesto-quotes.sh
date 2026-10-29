#!/usr/bin/env bash
#
# The test that PIPELINE.md quotes the manifesto word for word.
#
#   tests/manifesto-quotes.sh
#
# Each stage and rule in PIPELINE.md names the manifesto line it serves by
# quoting it on a *Serves* line. When the manifesto is reworded, a quote can
# stay as it was and still read as a sensible sentence, so nobody notices that
# the stage now cites a reason the manifesto no longer gives.
#
# The cases first run the check on throwaway files, to show what it catches,
# and then on the real two.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."

# shellcheck source=lib.sh
. "$HERE/lib.sh"

# Prints one line for each problem with the quotes on the Serves lines of a
# pipeline file, and nothing when there is none.
quote_problems() {  # pipeline manifesto
  local file missing=0
  for file in "$1" "$2"; do
    [ -f "$file" ] || { printf '%s: not found\n' "$file"; missing=1; }
  done
  [ "$missing" -eq 0 ] || return 0
  awk -v name="$(basename "$1")" '
    BEGIN { any_serves = "^[ \t>#*_0-9.-]*[Ss][Ee][Rr][Vv][Ee][Ss][*_:]" }
    FILENAME == ARGV[1] { manifesto = manifesto " " $0; next }
    FNR == 1 { manifesto = squeezed(manifesto) }

    # A Serves line runs on over the lines after it, up to a blank line or the
    # next item or label: Markdown wraps it there, and a quote can span the break.
    lines && (/^[ \t]*$/ || /^[ \t]*- / || /^\*[A-Za-z]+:\*/ || $0 ~ any_serves) { check_serves() }
    lines { add_line(); next }
    /^\*Serves:\*/ || /^- \*\*Serves:\*\*/ { first = FNR; add_line(); next }
    # Any other form would have its quotes skipped without a word.
    $0 ~ any_serves { printf "%s:%d: a Serves line in a form the check does not read: use *Serves:* or - **Serves:**\n", name, FNR }
    END {
      if (lines) check_serves()
      if (!found) printf "%s: found no quote on a Serves line, so nothing was checked\n", name
    }

    function add_line() { start[lines++] = length(serves) + 1; serves = serves $0 " " }

    function check_serves(   rest, offset, quote, quotes) {
      rest = serves; offset = 0; quotes = 0
      while (match(rest, /"[^"]*"/)) {
        quote = squeezed(substr(rest, RSTART + 1, RLENGTH - 2))
        if (!index(manifesto, quote))
          printf "%s:%d: not in the manifesto: \"%s\"\n", name, line_at(offset + RSTART), quote
        offset += RSTART + RLENGTH - 1; rest = substr(rest, RSTART + RLENGTH); quotes++
      }
      if (index(rest, "\""))
        printf "%s:%d: a double quote is never closed\n", name, first
      else if (!quotes && !index(serves, "no manifesto line"))
        printf "%s:%d: no quote in straight double quotes, and it does not say it serves no manifesto line\n", name, first
      found += quotes; lines = 0; serves = ""
    }

    function line_at(position,   i) {
      for (i = lines - 1; start[i] > position; i--) ;
      return first + i
    }

    function squeezed(text) { gsub(/[ \t]+/, " ", text); return text }
  ' "$2" "$1"
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The case's own PIPELINE.md and MANIFESTO.md, each from a string.
files() {  # pipeline-text manifesto-text
  printf '%s\n' "$1" > "$WORK/PIPELINE.md"
  printf '%s\n' "$2" > "$WORK/MANIFESTO.md"
}
problems() { quote_problems "$WORK/PIPELINE.md" "$WORK/MANIFESTO.md"; }

# The case passes when the check prints a line holding each expected text,
# and only as many lines as there are texts. With no texts, it prints nothing.
expect() {  # case-name expected-text...
  local out lines missed="" text
  out="$(problems)"; lines="$(grep -c . <<<"$out")"
  for text in "${@:2}"; do [[ "$out" == *"$text"* ]] || missed+="$text"$'\n'; done
  if [ -z "$missed" ] && [ "$lines" -eq "$(($# - 1))" ]; then ok "$1"
  else bad "$1" "expected: ${*:2}"$'\n'"got: $out"; fi
}

files $'*Serves:* "do not read the code." And "**Agents** write it".\n\n- **Serves:** no manifesto line.\n- **Serves:** "do not read"' \
  $'Humans do not read the code. **Agents** write it.'
expect "quotes found word for word in the manifesto, in both forms of Serves line, pass"

files $'# Pipeline\n\n*Serves:* "Nobody reads the code."' "Humans do not read the code."
expect "a quote the manifesto does not have is named with its line" \
  'PIPELINE.md:3: not in the manifesto: "Nobody reads the code."'

files '- **Serves:** "do not read the code"' $'Humans  do not read\nthe   code.'
expect "spaces and line breaks in the manifesto count as one space"

files $'*Serves:* "do not  read\nthe code". And "Agents\nwrite it".\n\n*Adds:* "x"' "Humans do not read the code."
expect "spaces and line breaks in a quote count as one space, and a quote is named by the line it starts on" \
  'PIPELINE.md:2: not in the manifesto: "Agents write it"'

files '*Serves:* "Agents write it"' 'Humans do not read the code. **Agents** write it.'
expect "a quote that loses the ** around a term is not found" \
  'PIPELINE.md:1: not in the manifesto: "Agents write it"'

files $'*Serves:* "do not read the code"\n\nA later reader would "fix" them.\n*Adds:* "fix" too.' "Humans do not read the code."
expect "double quotes outside a Serves line are not checked"

files $'x\n- **Serves:** that humans do not read the code.\n*Serves:* “do not read the code”\n*Serves:* "do not read the code"' "Humans do not read the code."
expect "a Serves line with a paraphrase or curly quotes is named with its line" \
  'PIPELINE.md:2: no quote' 'PIPELINE.md:3: no quote'

files $'*Serves:* "do not read the code"\n\n*Serves:* "do not read the code\n\n*Serves:* "the code" and "do' "Humans do not read the code."
expect "a Serves line with a double quote that is never closed is named with its line" \
  'PIPELINE.md:3: a double quote is never closed' 'PIPELINE.md:5: a double quote is never closed'

files $'*Serves* "do not read the code"\n\nServes: "do not read the code"' "Humans do not read the code."
expect "a pipeline with no Serves line in either form fails" \
  'PIPELINE.md:1: a Serves line in a form' 'PIPELINE.md:3: a Serves line in a form' \
  'PIPELINE.md: found no quote on a Serves line'

files '*Serves:* no manifesto line.' "Humans do not read the code."
expect "a pipeline whose Serves lines serve no manifesto line fails, since it checks nothing" \
  'PIPELINE.md: found no quote on a Serves line'

files $'*Serves:* "do not read the code"\n**Serves:** "a"\n  - **Serves:** "b"\nServes: "c"\n_Serves:_ "d"\n*Serves* "e"\n*serves:* "f"\n### Serves: "g"\n1. **Serves:** "h"' "Humans do not read the code."
expect "a Serves line in a form the check does not read is named with its line" \
  'PIPELINE.md:2: a Serves line in a form' 'PIPELINE.md:3: a Serves line in a form' \
  'PIPELINE.md:4: a Serves line in a form' 'PIPELINE.md:5: a Serves line in a form' \
  'PIPELINE.md:6: a Serves line in a form' 'PIPELINE.md:7: a Serves line in a form' \
  'PIPELINE.md:8: a Serves line in a form' 'PIPELINE.md:9: a Serves line in a form'

files '*Serves:* "do not read the code"' "Humans do not read the code."
rm "$WORK/PIPELINE.md"
expect "a missing pipeline fails" "PIPELINE.md: not found"

files '*Serves:* "do not read the code"' "Humans do not read the code."
rm "$WORK/MANIFESTO.md"
expect "a missing manifesto fails" "MANIFESTO.md: not found"

files '*Serves:* "do not read the code"' ''
: > "$WORK/MANIFESTO.md"
expect "an empty manifesto has none of the quotes" \
  'PIPELINE.md:1: not in the manifesto: "do not read the code"'

# --- the real files -----------------------------------------------------------

out="$(quote_problems "$ROOT/PIPELINE.md" "$ROOT/MANIFESTO.md")"
if [ -z "$out" ]; then ok "every quote on a Serves line of PIPELINE.md is in MANIFESTO.md"
else bad "every quote on a Serves line of PIPELINE.md is in MANIFESTO.md" "$out"; fi

finish
