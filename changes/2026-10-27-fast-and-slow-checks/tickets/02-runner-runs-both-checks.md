---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-10
advances:
after:     01-skills-name-both-checks
status:    done
attempts:  1
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

- **Fixes made after the last review**, which no reviewer saw. Each answers a nit from round 2:
  - `run/prompts.sh`: the build brief says "when the criteria are green and the fast check passes", and the review brief says "run the fast check and commit". Both said "the checks" before, which a session could read as both checks, against AC-2.
  - `run/report.sh`: when the checks stay red after the final review, the run's last line also points at `git stash list`. That is where the review's uncommitted fixes go.
  - `tests/run/report.sh`: assertions on the review's hand-back line ("attempt N of M") and on what the review session is told (add the fix to REVIEW.md).
- **Review nits not fixed:**
  - Started on main, a run makes its branch and only then refuses a `CLAUDE.md` with both `Check:` and `Fast check:`. Starting again on main is then refused because the branch exists. Red checks at the start already behaved this way before this change, so moving the refusal earlier is a change of its own.
  - With `MAX_ATTEMPTS=1` the stop line reads "through 1 attempts". The ticket's halt already had this wording.
- **Decided here, not settled by the criteria:**
  - The runner runs the slow check even when the fast check is red. A session handed back red checks then learns about both at once, and does not spend an attempt finding the second. This costs the slow check's time on every red fast check.
  - A run started again over a committed review halts on red checks. It does not hand them back to the review session. A usage limit while the review fixes red checks ends the run the same way, and names the red checks.
  - The review session handed red checks is told to add its fix to REVIEW.md, among the fixes no reviewer saw.
  - A session given a `CLAUDE.md` with both lines is told only to remove `Check:`, with no test-first instruction and no output, because no check ran.
  - Check logs now have unique names (`fast-check-…-XXXX.log`, `slow-check-…`). Two runs in the same second used to share a log, and the green run overwrote the red log the session had been told to read.
- **Changed assertion:** in `tests/run/loop.sh`, the count of check runs in a two-ticket run went from 3 to 4, because of the run after the final review (AC-5). Coverage is not weaker.
- **Checks:** this repository has only `Check:` `./test.sh`, its fast check, and no slow check, so no slow check was run. No test moved between the checks.
- **Blast radius:** every pipeline run. A project whose `CLAUDE.md` has both `Check:` and `Fast check:` no longer starts. A project with a `Slow check:` line now has it run before the first build, after every build and after the final review. A revert undoes all of it; it changes no stored format.
- **Hard to change:** `tests/stub-session` takes the review's path from the first `REVIEW.md` in its prompt. A new sentence naming REVIEW.md, and one test's check command, both broke it. Suggestion: the stub could tell the review from a build by the brief's opening words instead.
