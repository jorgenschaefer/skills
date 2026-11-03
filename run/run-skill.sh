# shellcheck shell=bash
#
# The project's run skill: how agents build, start and drive the software.
#
# Every walker used to set up the software and a browser on its own, each a
# little differently, and walks took more than half of a run's time. A run skill
# says once how to start the software, and for a web app it comes with a driver
# for the browser. Claude Code's `/run-skill-generator` writes one, into
# `.claude/skills/run-<name>/`. It can only be started as a session's prompt,
# never from inside a session, so the runner starts it.
#
# After a part's checks pass, because before that a new project has nothing to
# run, and at most once per run: a generator that wrote nothing - it asks which
# app where a repository has several, and nobody is here to answer - would
# write nothing again after the next part. What it writes, and whatever it
# committed itself, is kept only if the fast check stays green: no build's
# review looks at it, and the next build would be told the red was its own.
# Without a run skill, the walker at acceptance starts the software as it did
# before.
#
# A project may still have a run skill under the older name,
# `.claude/skills/run/`, which builds used to write. That one counts too.
#
# Sourced by run.sh, never run.

RUN_SKILL_TRIED=""   # set once the generator has run in this run

has_run_skill() {
  local top
  top="$(git rev-parse --show-toplevel)"
  [ -f "$top/.claude/skills/run/SKILL.md" ] || compgen -G "$top/.claude/skills/run-*/SKILL.md" >/dev/null
}

run_skill() {
  local before rc
  [ -z "$RUN_SKILL_TRIED" ] || return 0
  has_run_skill && return 0
  RUN_SKILL_TRIED=yes
  say "the project has no run skill - a session runs /run-skill-generator"
  before="$(git rev-parse HEAD)"
  claude_through_limits run-skill "/run-skill-generator" --session-id "$(new_session_id)"; rc=$?
  [ "$rc" = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait while writing the run skill - run again once it has lifted"
  if ! has_run_skill; then
    git reset -q --keep "$before" || end_run 1 "could not undo what the run skill generator committed - reset to $(git rev-parse --short "$before") by hand"
    put_aside "run-skill" 1
    say "the generator wrote no run skill - the walker at acceptance starts the software as before"
    return 0
  fi
  if [ -n "$(left_behind)" ]; then
    git add -A -- "${NOT_PARTS[@]}"
    git commit -q -m "Add the project's run skill, written by /run-skill-generator" \
      || end_run 1 "could not commit the run skill"
  fi
  if [ "$(git rev-parse HEAD)" = "$before" ]; then
    say "the run skill is there but nothing was committed - is .claude/ ignored? The walker at acceptance can use it all the same"
    return 0
  fi
  read_checks
  if [ -n "$FAST_CHECK" ] && ! run_check fast "$FAST_CHECK"; then
    git reset -q --keep "$before" || end_run 1 "the fast check is red with the run skill, and it could not be dropped - reset to $(git rev-parse --short "$before") by hand: $RED"
    say "the fast check is red with the run skill - it is dropped: $RED"
    RED=""
    return 0
  fi
  say "the run skill is committed at $(git rev-parse --short HEAD)"
}
