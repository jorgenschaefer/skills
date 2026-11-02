---
effort: M
utility: L
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

## Problems with the skills, found in the projects' friction notes

The user agreed on 2026-11-02, after a review of the friction notes in five
projects: problems with these skills need a way back to this repository.
Today the builders write them into the project's `changes/friction/`. The
project's refactor cannot fix a skill, and nothing brings them here.

- `../haushaltsbuch/changes/friction/2026-11-01-walker-auf-ungespeichertem-stand.md`:
  `.claude/skills/run/start.sh` starts a worktree on a commit, but a
  chunk's work is committed only after the review. The builder worked
  around it with `git add` and `git stash create`, and asks for a sentence
  in `implement-change` or an option in `start.sh`.
- `../workout-tracker/changes/friction/2026-11-02-projekt-anlegen.md`:
  `nextjs-project-setup` lets Biome 2.6 format `.md` files, which changed
  `journeys/*.md`; `npm install prisma` fetches `8.0.0-rc.29`; npm 11
  blocks install scripts until `npm install-scripts approve`; Playwright
  loads its config as CommonJS without `"type": "module"`.
- `../workout-tracker-1/changes/friction/2026-10-31-uebungen-ansehen.md`,
  `2026-10-31-uebungen-bearbeiten.md`, `2026-10-31-plan-editor.md`: three
  times the walkers needed data no page could make yet, and got it from
  hand-written SQL in `/tmp/walk0N/seed.sql`, which is not committed.
- `../haushaltsbuch/changes/friction/2026-11-02-ausgaben-import-findings.md`:
  the mock's ids clash with real data in the database copy the run skill
  makes. The walker: "The mock needs IDs that cannot clash with real data,
  or the run skill should say so."
