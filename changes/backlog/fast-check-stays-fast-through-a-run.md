---
effort: M
utility: L
---

# The fast check stays fast through a run

In the `workout-tracker` run of 2026-11-02, the fast check (`npm run check`)
grew from 6 seconds after chunk 01 to 4.9 minutes at the end: 132 Playwright
tests, run with `workers: 1` and `fullyParallel: false`
(`playwright.config.ts`), each run starting with a fresh `next build`. The
project has no slow check.

It ran about four times per chunk: before the first review, before the
second, before the commit, and once more by the runner on the commit. Tests
took about 195 minutes of the 9-hour run: about 95 in full checks inside the
build sessions, about 32 in the runner's checks, about 68 in single test
files (35 of those chasing one flaky test).

What exists and did not hold: `split-change-into-chunks/SKILL.md` makes the
first chunk speed up a fast check over 30 seconds. It is applied once,
before the first build, when this project had no tests yet.

Proposed in the retro:

- `nextjs-project-setup` sets up Playwright to run in parallel, each worker
  with its own database. It says nothing about Playwright today.
- Under `run.sh`, the build skips its own full check before the commit: the
  runner checks the commit anyway, and a red check goes back to the session
  without costing an attempt.
- The runner tells each build how long the fast check took.

Related: `runner-runs-the-tests-twice.md`, where the slow check repeats the
fast one.

Evidence: `fast-check-*.log` and the session logs in
`~/Projects/workout-tracker/.git/run-logs/`.
