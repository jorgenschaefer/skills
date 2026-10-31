---
effort: M
utility: M
---

# retro holds recent runs against SDLC.md

The user wants `retro` reworked so it is better suited to looking at
recent runs and finding improvements, judged against what developing with
these skills is meant to be.

`.claude/skills/retro/SKILL.md` looks back over one session or one `run.sh`
run. It reads the logs in `.git/run-logs/`, checks whether the fixes since
the previous run held, looks for moments (a person stepping in, defects
caught late, rules that did not hold, cost, searching, interference), and
fixes with the strongest mechanism that fits. It judges a run by whether it
went worse than it should have, not against `SDLC.md`. Nothing asks, for
example, whether a build changed a journey, whether the walker read the
code, whether a journey step got no test, or whether the developer had to
decide something at acceptance that the design should have settled.

It is linked from this repository's `.claude/skills` and not synced.

There are two retros: one improves these skills and the runner, and one
improves the process in the codebase they run in. This item is the first.
Today's `retro` does both, sorting each finding under "Pipeline or
project". The project side belongs with the refactor
(`refactor-decides-from-measurable-signals`); here a project finding is handed on,
not fixed.
