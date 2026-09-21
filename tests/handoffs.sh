#!/usr/bin/env bash
#
# The test that each stage names the next one.
#
#   tests/handoffs.sh
#
# Measured, not assumed: `/slice`'s description fired about three times in four
# in an empty project and zero times in five in a project holding these twelve
# skills. A stage reached only by a description is a stage that can stop being
# reached without anything failing, so the stages that must be reachable are
# typed, and each one names the next by hand.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

# A stage a person opens or closes, or one the pipeline's own path depends on
# reaching. Each is typed, so none of them rests on being discovered.
TYPED=(solve slice accept verify)
for skill in "${TYPED[@]}"; do
  grep -q '^disable-model-invocation: true' "$ROOT/$skill/SKILL.md" \
    && ok "$skill is typed rather than discovered" \
    || bad "$skill is typed rather than discovered" "no disable-model-invocation in $skill/SKILL.md"
done

# `/idea` is the exception and stays discoverable: it is the door, and the
# competition trial measured it firing on "I have an idea..." and on a request
# introducing a new concept. A door nobody can walk into by accident is not one.
grep -q '^disable-model-invocation: true' "$ROOT/idea/SKILL.md" \
  && bad "idea stays discoverable" "it was made typed; the door has to be findable" \
  || ok "idea stays discoverable"

# And the chain is named: whoever finishes a stage says what the next one is.
handoff() {
  grep -q "$2" "$ROOT/$1/SKILL.md" \
    && ok "$1 names $3" \
    || bad "$1 names $3" "no mention of $3 in $1/SKILL.md"
}
handoff idea   '/solve'        "the stage that designs against the intent"
handoff solve  '/slice'        "the stage that turns the spec into work"
handoff slice  'run.sh'        "the runner that builds the tickets"
handoff implement '/critique'    "the session that reviews what it built"
handoff accept    'accept-run.sh' "the script that retires the paper"

# (d) to (e): the runner finishes, and something has to say what closes the run.
grep -q '/accept' "$ROOT/run.sh" \
  && ok "the runner names the stage that closes the run" \
  || bad "the runner names the stage that closes the run" "nothing in run.sh names /accept"

finish
