---
effort: M
utility: M
---

# The runner starts fewer processes

One run of `run.sh` starts about 1,300 processes and takes about 1.5
seconds. Most are `sed`, `grep`, `head` and `awk`, started by small helpers
called in loops. `field` (`run.sh:40`) starts a `sed` and a `head` on every
call, and the runner's library calls it from 41 places. The drift pre-flight
is the biggest part.

Every test case runs the real runner, so the fast check is fast only because
`test.sh` runs its suites side by side (see the comment above the parallel
start). It takes 22 seconds on 24 cores, 35 on 4 and 67 on 2: over the
standard's 30-second limit on a machine with fewer than about 6 cores. Run
alone, `tests/run/report.sh` takes about 30 seconds and `tests/run/drift.sh`
about 26.

On a laptop, then, every fast check runs over the limit, and the runner runs
the fast check after every build.
