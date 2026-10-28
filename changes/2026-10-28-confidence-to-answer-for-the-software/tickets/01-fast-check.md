---
criteria:  CRITERIA.md
closes:
advances:
after:
status:    done
attempts:  1
---

## Build
Make the project's fast check fast: `./test.sh` took 187 seconds when timed
while slicing.

## Done when
`CLAUDE.md` declares a fast check on a `Fast check:` line, and it runs in at
most 30 seconds. The slowest tests are made fast where they can be. The rest
move to a slow check declared on a `Slow check:` line, each move reported as
`/implement` reports a moved test. The report gives how long the fast check
took before and after. Behaviour is unchanged and both checks are green.

## Technical decisions
> **Concepts** none

> **Wire formats** none

> **Hard to reverse** none

## Context
`CLAUDE.md` names the check today on a `Check: ./test.sh` line. The runner
reads `Fast check:` and `Slow check:` lines, and refuses a `CLAUDE.md` that
has both `Check:` and `Fast check:` (README, "The runner"). What production
must show, Security policy and Information model say "None.".

## Not here
- `MANIFESTO.md` and the backlog items are ticket 02's.

## Left standing
- **The fast check's time, before and after:** 180 seconds before (187 when
  timed while slicing), 22 seconds after, over five runs on a 24-core machine.
  Almost all of the gain comes from running the suites side by side, so it
  depends on the machine. The reviewer pinned the check to fewer cores: 35
  seconds on 4 cores, 67 seconds on 2. On a machine with fewer than about 6
  cores the fast check is over 30 seconds again.
- **No test moved to a slow check.** Every test could be made fast enough, so
  `CLAUDE.md` has no `Slow check:` line.
- **Fix after the last review:** the review's only finding, a nit, said the
  comment above the parallel start in `test.sh` described the old code and
  gave a case count that was already out of date. I rewrote it in the present
  tense, without the count. Only the comment changed, and the fast check is
  green after it.
- **Tradeoff:** to run in parallel, `tests/run/loop.sh` is split into
  `loop.sh`, `loop-sessions.sh` and `loop-checks.sh`, along its sections. Each
  file of run.sh's library now has one or more suites named after it, instead
  of exactly one. I preferred that to rewriting the cases as functions the
  harness could run in parallel, which would have changed every line.
- **What was hard, and a suggestion:** no test is slow. Each case runs the real
  runner, and one run takes about 1.5 seconds because it starts about 1,300
  processes (`sed`, `grep`, `head` and `awk` from small helpers like `field`,
  called in loops). The drift pre-flight is the biggest part of that. Making
  the runner start fewer processes would make the suite fast on small machines
  too. That is a change to the runner, and a change of its own.
- **No pre-commit hook and no CI workflow.** The standard says the pre-commit
  hook runs the fast check and CI runs both checks. This repository has
  neither, before or after this change. Adding them is a change of its own.
