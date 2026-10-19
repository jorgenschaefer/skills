---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6
advances:
after:
status:    done
attempts:  0
---

## Build
On `main`/`master`, `run.sh` creates a branch named after the change directory and runs there, instead of refusing; where that branch already exists it refuses.

## Done when
> **AC-1** Started on `main` or `master` with nothing else to refuse, `./run.sh changes/<dir>/tickets` creates a branch named `<dir>` - the change directory's own name, e.g. `2026-10-19-run-sh-branch-on-main` - at the commit it was started on, checks it out, and the run goes on there; `main`/`master` gains no commit from the run.

> **AC-2** Whenever the run creates the branch, it prints a line, at that moment, naming the branch it created and the branch it left.

> **AC-3** Started on `main`/`master` while a branch named `<dir>` already exists, the run exits non-zero, launches nothing, creates no branch, moves none, and leaves the checkout on `main`/`master`; the message names the existing branch.

> **AC-4** Started on `main`/`master` where any other refusal applies - no ticket directory, no commits, no tickets, a dirty tree, another run holding the lock, no `claude` on PATH, a branch name git will not accept - the run refuses as it does today, creates no branch and leaves the checkout on `main`/`master`.

> **AC-5** Started on any branch other than `main`/`master`, the run creates and switches no branch, exactly as today.

> **AC-6** Where a run started on `main`/`master` creates the branch and `preflight` then stops it, the run ends with the checkout on the new branch, and any halt it commits is on that branch, not on `main`/`master`; started again on that branch, it carries on as any run started again does.

## Technical decisions
> **Stored formats** none.

> **Wire formats** On `main`/`master`, `run.sh` no longer exits 2 at the start: it goes on as on any other branch, except where a branch named after the change directory already exists, where it exits 2, and so does a branch name git will not accept. Every other exit code is unchanged.

> **Trust boundaries** none. The branch name comes from the ticket path the user passes in; a name git will not accept is a refusal (AC-4).

> **Dependencies** none.

## Nudges
> Create the branch after the last refusal (`check_tree`) and before `preflight`, so that a refused run leaves no branch and everything the run writes, a halt from `preflight` included, lands on the branch.

> Derive the branch name from the change directory in one place in `run.sh`; do not spell the rule out a second time.

> Reword what describes the main-branch refusal: the comment and the "no commits" message at `run.sh:67-74`, and `README.md:88`.

> Replace the "refuses to run on the main branch" test in `tests/run.sh:21-28` with tests started on `main` for AC-1 to AC-4 and AC-6. The existing refusal tests run on `topic` (`workspace()` in `tests/run/harness.sh`), so AC-4 needs its own cases on `main`: at least one refusal before the branch step, and the dirty tree at `check_tree`. The "no commits" test's grep for `branch refusal` (`tests/run.sh:46`) changes with the reworded message.

## Context
Today `run.sh` refuses on `main`/`master` in its refusal section, before the lock and `check_tree`. The change directory is the parent of the ticket directory passed as the argument. The test harness (`tests/run/harness.sh`) puts every workspace on a branch `topic` after committing on `main`, so a test that starts on `main` checks it out first, as the current main-branch test does.

## Not here
- A detached HEAD, and default branches with other names (`trunk`, `develop`).
- Deleting the branch after the change is accepted.
- Working beside a run in a separate worktree.

## Left standing
- AC-4: the missing ticket directory, the dirty tree and a name git rejects are tested on `main`. The lock, `claude` on PATH, no tickets and no commits are not: they come before the branch step in `run.sh`, and the dirty-tree test on `main` fails if the branch step moves above `check_tree`.
