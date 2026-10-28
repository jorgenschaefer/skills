---
criteria:  CRITERIA.md
closes:
advances:
after:
status:    ready
attempts:  0
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
