---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-10
advances:
after:     01-skills-name-both-checks
status:    ready
attempts:  0
---

## Build
`run.sh` reads the fast and the slow check from `CLAUDE.md`, has its sessions run only the fast check, and runs both itself before the first build, after each ticket's commit and after the final review's commit.

## Done when
> **AC-1** A project declares its checks in `CLAUDE.md`, in the same strict form as `Check:` today. `Fast check:` is what every build runs. `Slow check:` holds the tests that can't be made fast. A `Check:` line without a `Fast check:` line is the fast check, so a project with only `Check:` works as today, with no slow check. Where no line names a fast check, a session names one command once per run, as today, and that command is the fast check. A line a build adds is run from that build's own commit on, as `Check:` is today.

> **AC-2** In a pipeline run, a build session, the final review session and their reviews run only the fast check. A session handed back a red slow check may run the slow check to confirm its fix. `critique` in a pipeline run is handed the result of the runner's last run of both checks, or of the session's fast check, and says which.

> **AC-3** Before the first build, the runner runs the fast and the slow check. If either is red, the run does not start, and the runner says which one is red.

> **AC-4** After each ticket's commit, the runner runs the fast and the slow check once. A red result goes back to that ticket's session, as it does today: the first red is free, and later ones cost attempts. The session is told which check failed and where its output is.

> **AC-5** After the final review commits, the runner runs both once more. A red result goes back to the review session. The first red is free, and later ones use the same attempt budget as a ticket. If it stays red, the run halts and says which check is red and where its output is, for the developer to settle. A run started again after the review was committed runs both checks before it finishes, and halts again while either is red, so a run never points on to acceptance with a red check.

> **AC-10** If a project has both a `Check:` and a `Fast check:` line, the runner refuses to start and says to remove `Check:`. Where a build's commit has both, the runner treats it as a red check and hands it back to that session. `critique` reports both lines as a should-fix.

## Technical decisions
> **Concepts** A project's checks are a *fast check* and a *slow check*, and the two together are the full check.

> **Wire formats** The `CLAUDE.md` lines `` Fast check: `…` `` and `` Slow check: `…` ``, in the same strict form as `Check:`. A `Check:` without `Fast check:` is read as the fast check. A project with both `Check:` and `Fast check:` is refused. The runner's exit codes stay as they are.

> **Hard to reverse** none

## Context
Today `run/checks.sh` reads one command from the `Check:` line of `HEAD:CLAUDE.md` before every run of the checks, and asks a session for one, once per run, where there is none. `run/loop.sh` runs the checks before the first build and on every build's commit, and hands a red result back to the session: the first is free, each later one spends an attempt. `run/report.sh`'s `final_review` runs no checks after the review commits, and returns at once where `REVIEW.md` is already committed. What sessions are told about the checks is in `run/prompts.sh`: the build brief, `red_checks`, `checks_question` and `review_brief`. The tests are in `tests/run/`, with `tests/stub-session` standing in for `claude`; its `build-declare` step is how a build adds a check line in a test.

Ticket 01 changes the skills. Its `/implement`, told by its caller that the caller runs the slow check on the commit, runs only the fast check: the build brief says so. Its `critique` says which result it was handed, so the review brief names which one it hands over.

A project with no slow check has only the fast check to run. The final review has no ticket file to write a halt into, so a red check that ends the run is named in the run's last lines, as other run-level stops are.

The groups What production must show, Security policy and Information model each say "None.".

## Not here
- The standard and every skill's text, the README's descriptions of the skills included: ticket 01.
- Making tests faster outside the preparatory ticket of AC-12 - this repository's own `./test.sh` included, slow as it is.

## Left standing
