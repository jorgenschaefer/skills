#!/usr/bin/env bash
#
# The tests for run/run-skill.sh: the run skill the runner has
# /run-skill-generator write, where the project has none.
#
#   tests/run/run-skill.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

generator_calls() { grep -c '| /run-skill-generator$' "$STUB_ARGS"; }
skill_committed() { git -C "$WORK" cat-file -e HEAD:.claude/skills/run-app/SKILL.md 2>/dev/null; }

# --- a project with no run skill gets one after its first part

workspace
STUB_RUN_SKILL='write'; export STUB_RUN_SKILL
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && skill_committed && [ -z "$(git -C "$WORK" status --porcelain)" ]; then
  ok "the run skill the generator writes is committed"
else bad "the run skill the generator writes is committed" "rc=$rc $(git -C "$WORK" status --porcelain) $(out)"; fi
if [ "$(generator_calls)" = 1 ] \
   && [ "$(grep -n -e '| /run-skill-generator$' -e '| Use /implement-plan' "$STUB_ARGS" | cut -d'|' -f2- | sed 's/ on .*//' | tr -d ' ' | tr '\n' ,)" = "Use/implement-plan,/run-skill-generator,Use/implement-plan," ]; then
  ok "the generator runs once, after the first part"
else bad "the generator runs once, after the first part" "$(generator_calls) $(cut -c1-200 "$STUB_ARGS")"; fi
if [ "$(git -C "$WORK" log --format=%s -1 -- .claude/skills/run-app)" = "Add the project's run skill, written by /run-skill-generator" ] \
   && [ "$(git -C "$WORK" log --format=%s --grep='run skill' | wc -l)" = 1 ]; then
  ok "the run skill is committed on its own"
else bad "the run skill is committed on its own" "$(git -C "$WORK" log --format=%s)"; fi

# --- a project that has one is left alone

workspace
mkdir -p "$WORK/.claude/skills/run-web"; printf 'x\n' > "$WORK/.claude/skills/run-web/SKILL.md"; commit
STUB_RUN_SKILL='write'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(generator_calls)" = 0 ]; then ok "a project with a run skill never runs the generator"
else bad "a project with a run skill never runs the generator" "rc=$rc $(generator_calls) $(out)"; fi

# Builds used to write it as .claude/skills/run/.
workspace
mkdir -p "$WORK/.claude/skills/run"; printf 'x\n' > "$WORK/.claude/skills/run/SKILL.md"; commit
STUB_RUN_SKILL='write'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(generator_calls)" = 0 ]; then ok "a run skill under the older name counts as one"
else bad "a run skill under the older name counts as one" "rc=$rc $(generator_calls) $(out)"; fi

# --- a generator that writes none is not asked again

workspace
STUB_RUN_SKILL='stray'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(generator_calls)" = 1 ] && grep -q 'wrote no run skill' "$WORK/.out"; then
  ok "a generator that writes no run skill is not asked again in the same run, and the run says so"
else bad "a generator that writes no run skill is not asked again in the same run, and the run says so" "rc=$rc $(generator_calls) $(out)"; fi
if ! git -C "$WORK" cat-file -e HEAD:run-notes.txt 2>/dev/null && [ "$(field 02 status)" = "done" ]; then
  ok "what it wrote instead is set aside, and the next part builds on a clean tree"
else bad "what it wrote instead is set aside, and the next part builds on a clean tree" "$(out)"; fi

# --- a run skill that turns the fast check red is dropped

workspace
STUB_RUN_SKILL='broken'
STUB_VERIFY='! [ -e .claude/skills/run-app/broken ]'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! skill_committed && [ ! -e "$WORK/.claude/skills/run-app" ] && grep -q 'it is dropped' "$WORK/.out"; then
  ok "a run skill that turns the fast check red is dropped, and the run says so"
else bad "a run skill that turns the fast check red is dropped, and the run says so" "rc=$rc $(git -C "$WORK" log --format=%s) $(out)"; fi
if [ "$(generator_calls)" = 1 ] && [ "$(field 02 status)" = "done" ]; then
  ok "the run carries on without it, and does not ask again"
else bad "the run carries on without it, and does not ask again" "$(generator_calls) $(out)"; fi

# The generator may commit what it wrote itself, and that is checked the same way.
workspace
STUB_RUN_SKILL='committed'
STUB_VERIFY='! [ -e .claude/skills/run-app/broken ]'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! skill_committed && [ "$(field 02 status)" = "done" ] && grep -q 'it is dropped' "$WORK/.out"; then
  ok "a red run skill the generator committed itself is dropped too"
else bad "a red run skill the generator committed itself is dropped too" "rc=$rc $(git -C "$WORK" log --format=%s) $(out)"; fi

finish
