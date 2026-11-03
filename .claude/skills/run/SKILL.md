---
name: run
description: Drive this repository's runner, run.sh, by hand in a throwaway repository with a stub in place of `claude` - to see a change to the runner working, not just its tests.
---

# Run the runner

`run.sh` drives `claude` sessions unattended. To watch it without launching real ones, drive it in a throwaway repository built by the runner's own test harness, with `tests/stub-session` on PATH as `claude`.

```bash
. .claude/skills/run/demo-repo.sh   # fresh repo in $WORK, change dir changes/2026-01-01-demo on its own branch
plan build build review             # what the stub's next sessions do - see tests/stub-session's header
R                                   # ./run.sh changes/2026-01-01-demo; R <path> for another
st                                  # branch checked out, commit graph, sessions launched
demo_done                           # remove $WORK
```

Everything around the sessions - refusals, claims, checks, halts - is the real script; what a session does is the stub's plan. The change's `plan.md` is already split into two parts in `plan/`; `git rm -r changes/2026-01-01-demo/plan` and a commit leave `plan.md` for the split session to judge, with `plan split-two build build review`. Each source makes a new temporary repository, so call `demo_done` before sourcing again. `git checkout main` shows the refusal on main.
