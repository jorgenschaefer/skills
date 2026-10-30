# shellcheck shell=bash
#
# The drift pre-flight, before each pass. A session reads its own chunk and no
# other, and a committed chunk is revisited by nobody but a new split, so this
# is the only place CHANGE.md and the chunks can be found to disagree - and
# CHANGE.md and the journeys it names.
#
# Sourced by run.sh, never run.

preflight() {
  local t dep j named problems="" culprit=""
  for t in "${CHUNK_FILES[@]}"; do
    # A deleted chunk leaves the ones after it waiting on something that will
    # never be done, and the loop would only say so once it had run out of work.
    for dep in $(field "$t" after | tr ',' ' '); do
      if ! grep -qs '^journeys:' "$CHUNKS/$dep.md"; then
        problems+="$(basename "$t"): after: names $dep, which is not a chunk"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
  done
  for j in $(journeys_of "$CHANGE"); do
    if [ ! -f "$(git rev-parse --show-toplevel)/$j" ]; then
      problems+="CHANGE.md: names $j, which is not there"$'\n'
      [ -n "$culprit" ] || culprit="${CHUNK_FILES[0]}"
    fi
  done
  if is_split; then
    for t in "${CHUNK_FILES[@]}"; do
      # A chunk carries CHANGE.md's problem word for word, so an edit to
      # CHANGE.md after the split shows here rather than in a build of the old one.
      if [ "$(section "$t" Problem)" != "$(section "$CHANGE" Problem)" ]; then
        problems+="$(basename "$t"): its Problem no longer matches CHANGE.md"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
      for j in $(journeys_of "$t"); do
        if ! journeys_of "$CHANGE" | grep -xF -- "$j" >/dev/null; then
          problems+="$(basename "$t"): names $j, which CHANGE.md does not"$'\n'
          [ -n "$culprit" ] || culprit="$t"
        fi
      done
    done
    # Once for the change, not once per chunk: this asks something of the
    # chunks as a whole.
    #
    # No `grep -q` at the end of a pipe in here: it stops reading at the first
    # match, the writer before it dies of SIGPIPE, and under pipefail a match
    # found reads as none - drift on whatever the race picked that run.
    for j in $(journeys_of "$CHANGE"); do
      named=""
      for t in "${CHUNK_FILES[@]}"; do
        journeys_of "$t" | grep -xF -- "$j" >/dev/null && named=yes
      done
      if [ -z "$named" ]; then
        problems+="CHANGE.md: $j is named by no chunk"$'\n'
        [ -n "$culprit" ] || culprit="${CHUNK_FILES[0]}"
      fi
    done
  fi
  if [ -n "$problems" ]; then
    printf 'drift - CHANGE.md, its journeys and its chunks disagree:\n%s' "$problems" >&2
    # The stop is named in the chunk, not only on someone's terminal - nobody is
    # watching the terminal, which is the whole premise. The first offender
    # carries it, because that is where a person will look; where the offence
    # belongs to the change rather than to one chunk, the first chunk does.
    halt "$culprit" drift \
      "CHANGE.md, its journeys and the chunks no longer agree - fix CHANGE.md or the journeys, or split the change again with /split-change-into-chunks"
    return 1
  fi
}

# The journeys a chunk names, one path per line, relative to the repository.
journeys_of() { field "$1" journeys | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sed '/^$/d' | sort -u; }

# The journeys a session's commits changed since the given commit, one per
# line: approved before the build, so a change to one is a departure.
journeys_touched() {  # commit
  git diff --name-only "$1" HEAD -- "$(git rev-parse --show-toplevel)/journeys"
}
