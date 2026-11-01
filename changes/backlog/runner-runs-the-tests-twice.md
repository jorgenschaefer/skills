---
effort: M
utility: M
---

# The slow check should be a full check that includes the fast check

The skills and the runner call a project's two checks the fast check and the
slow check, as if the slow check were a separate set of slow tests. Projects
include the fast check in it instead. So the second check should be called
the full check: it runs everything, and the fast check is a fast subset of it.

The name "slow check" is in the README, `run.sh`, `run/checks.sh`,
`run/prompts.sh`, their tests, and the skills `implement-change`,
`review-change`, `debug`, `refactor-codebase`, `accept-change`,
`split-change-into-chunks` and `upgrade-dependencies`, and on the
`Slow check:` line of each project's `CLAUDE.md`.

## The runner runs the tests twice in a row

After every build, `run_checks` (`run/checks.sh`) runs the fast check and then
the slow check. The comment at the top of that file says the slow check is
"for the tests that can't be made fast". But a project may define its slow
check as the fast check plus more. The workout tracker does:

```
"check:fast": "docker compose up -d --wait && tsc --noEmit && npm run lint && npm test",
"check": "npm run check:fast && npm run build && ...",
```

Its `CLAUDE.md` says: "The slow check runs the fast check, then builds". So
after every chunk the whole test suite ran twice, back to back. The build
session had just run it once more on the same commit.

The suite grew with every chunk, from 0.3 seconds after chunk 01 to 77
seconds after chunk 14 (736 tests). By the end of the run the second run cost
about 80 seconds per chunk, about 20 minutes over the run, and it keeps
growing.

Evidence: the `fast-check-*.log` and `slow-check-*.log` files in
`~/Projects/workout-tracker/.git/run-logs`, run of 2026-10-31.
