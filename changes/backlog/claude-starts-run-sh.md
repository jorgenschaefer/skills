---
effort: M
utility: L
---

# Claude starts run.sh itself

After `/criteria-to-tickets` writes several tickets, the user has to start
`./run.sh changes/<slug>/tickets` by hand. Claude Code should find the
runner and start it itself, and when the run ends, tell how it ended and what
comes next.

## Claude cannot find it

In a project that installed the skills, `run.sh` is not there.
`npx skills add` and `sync.sh` copy or link skill directories only, and
`run.sh` and `run/` sit beside them at the repository root, with no
`SKILL.md` (README "`run.sh` is a script rather than a skill"; `sync.sh`
skips directories without a `SKILL.md`). The hand-off in
`criteria-to-tickets/SKILL.md:95` names `./run.sh`, which resolves only in
this repository.

What the user had in mind: move `run.sh` and `run/` into a skill directory
of their own, for example `run-tickets/`, whose `SKILL.md` has Claude run
`${CLAUDE_SKILL_DIR}/run.sh changes/<slug>/tickets` with
`run_in_background`. Claude Code documents `${CLAUDE_SKILL_DIR}` as the
directory that holds the skill's `SKILL.md` (code.claude.com/docs/en/skills).
A skill of its own, not a file in `criteria-to-tickets`, because a re-slice
from `/accept-criteria` and a restart after a halt also start the runner.
The script still enforces everything. The skill only starts it.

Touched by the move: `test.sh:68` (shellcheck over `run.sh` and `run/*.sh`),
`tests/run.sh` and the suites beside it, the demo skill
`.claude/skills/run`, whose name would clash with a skill named `run`, the
README's runner section and pipeline diagram, and the hand-off lines in
`criteria-to-tickets` and `accept-criteria`.

## What happens to a background run (from the Claude Code docs)

- In an interactive session a background command has no time limit. The
  session is called back when the command exits and uses no tokens while
  it waits (tools-reference, interactive-mode).
- Quitting Claude Code stops background tasks, including processes started
  under `setsid` (interactive-mode). So the run lives only as long as the
  terminal does. "Move to background and exit" in the exit dialog keeps it
  running (agent-view). The run can be started again after a kill, so
  nothing is lost.
- The build sessions' usage limits are handled already:
  `claude_through_limits` (`run/session.sh:27`) waits out up to `MAX_WAITS`
  limits.
- The session that started the run draws on the same quota, so it is likely
  limited at the very moment a run gives up on a limit. The docs say nothing
  about whether the exit callback is queued, retried or lost while the
  session is limited. Assume it can be lost.

## The output a reader that sees only the end needs

- **The end report in a file as well**, e.g. `.git/run-logs/<change>.end`,
  written by `end_run` (`run/report.sh:21`) before it exits. Then a lost
  callback costs nothing: any later turn reads one small file.
- **A fixed marker before the end report**, for every ending. `RUN STOPPED`
  exists; a finished run prints only `next: /accept-criteria ...`. A run
  prints one line per tool call for hours. When a command's output passes
  about 30,000 characters, Claude Code shows only the first 2,000 characters
  and the file's path, which is the wrong end.
- **One exit code per outcome**, because Claude acts differently on each:
  - finished → `/accept-criteria`
  - halted → relay `## Halt` and stop, since settling it is the user's
    decision
  - a usage limit outlasted every wait → start again after the reset
  - refused to start → report the refusal

  Today `EX_LIMIT=75` (`run/session.sh:26`) never becomes the script's exit
  code: every limit ending is `end_run 1`, the same code as a halt
  (`run/loop.sh:82`, `run/checks.sh:41`, `run/report.sh:106`). A refusal
  (`die`, `run.sh:36`) and a preflight halt (`run.sh:129`,
  `run/loop.sh:15`) both exit 2.
- The halt excerpt cut at 20 lines can stay, since Claude can open the
  ticket.
