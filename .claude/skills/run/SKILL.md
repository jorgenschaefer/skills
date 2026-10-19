---
name: run
description: Drive this repository's runner, run.sh, by hand in a throwaway repository with a stub in place of `claude` - to see a change to the runner working, not just its tests.
---

# Run the runner

`run.sh` drives `claude` sessions unattended. To watch it without launching real ones, drive it in a throwaway repository built by the runner's own test harness, with `tests/stub-session` on PATH as `claude`.

```bash
. .claude/skills/run/demo-repo.sh   # fresh repo in $WORK, on main, change dir changes/2026-01-01-demo
plan build build review             # what the stub's next sessions do - see tests/stub-session's header
R                                   # ./run.sh changes/2026-01-01-demo/tickets; R <path> for another
st                                  # branch checked out, commit graph, sessions launched
demo_done                           # remove $WORK
```

Everything up to the first session - refusals, branch handling, preflight - is the real script; what a session does is the stub's plan. Each source makes a new temporary repository, so call `demo_done` before sourcing again. `topic` holds the same commits as `main`, for a run on a branch other than main.
