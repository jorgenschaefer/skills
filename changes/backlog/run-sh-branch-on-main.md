---
effort: XS
utility: S
---

# run.sh should create a new branch on main instead of refusing

Started on `main` or `master`, `run.sh` stops with "refusing to run on
main: a run belongs on a branch of its own" (`run.sh:76-79`). The run
then has to be started again after switching to a new branch by hand.
Instead, run.sh should create a new branch itself when it is on main.
