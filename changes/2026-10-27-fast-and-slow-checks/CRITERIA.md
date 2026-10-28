# Criteria: fast and slow checks

## Problem
In a pipeline run, a change waits for the project's full set of checks many times. Each ticket's build session runs them while it works, the runner runs them again after each build, and the review at the end runs them again. In dom, a full run takes about a minute, and 20 to 50 seconds of that is the security policy check alone. That is 2 to 6 full runs in each ticket session, and those sessions take 5 to 20 minutes. Another 1 to 3 runs come at the end, on top of what critique takes. Instead, neither a ticket's build nor the final review would spend minutes waiting for tests, and every check would still pass on the whole change before it is accepted.

The instance: dom's runs of 21 to 24 October 2026, in `~/Projects/dom/.git/run-logs`. `npm run check` (849 tests) takes about 58 seconds. Counted roughly from the session logs, each ticket session ran it 1 to 5 times, the runner once more after each build, and the final review 1 to 3 times. The developer says slow suites have slowed implementation runs like this before, in other projects.

## Acceptance criteria
### Behaviour
- **AC-1** A project declares its checks in `CLAUDE.md`, in the same strict form as `Check:` today. `Fast check:` is what every build runs. `Slow check:` holds the tests that can't be made fast. A `Check:` line without a `Fast check:` line is the fast check, so a project with only `Check:` works as today, with no slow check. Where no line names a fast check, a session names one command once per run, as today, and that command is the fast check. A line a build adds is run from that build's own commit on, as `Check:` is today.
- **AC-2** In a pipeline run, a build session, the final review session and their reviews run only the fast check. A session handed back a red slow check may run the slow check to confirm its fix. `critique` in a pipeline run is handed the result of the runner's last run of both checks, or of the session's fast check, and says which.
- **AC-3** Before the first build, the runner runs the fast and the slow check. If either is red, the run does not start, and the runner says which one is red.
- **AC-4** After each ticket's commit, the runner runs the fast and the slow check once. A red result goes back to that ticket's session, as it does today: the first red is free, and later ones cost attempts. The session is told which check failed and where its output is.
- **AC-5** After the final review commits, the runner runs both once more. A red result goes back to the review session. The first red is free, and later ones use the same attempt budget as a ticket. If it stays red, the run halts and says which check is red and where its output is, for the developer to settle. A run started again after the review was committed runs both checks before it finishes, and halts again while either is red, so a run never points on to acceptance with a red check.
- **AC-6** When `/implement` builds outside the runner, from one ticket, from `CRITERIA.md` or from a plain request, it runs the fast check while it works. It runs the slow check once, before its commit. A red slow check is fixed like any red check, and nothing is committed while it is red. Where the build cannot make it green, it stops and its report names the red check.
- **AC-7** A test moved from the fast check to the slow check is reported like a weakened check. The report says which test moved, why it couldn't be made fast, and what the fast check no longer catches. The developer sees it at acceptance. The reason is also written beside the moved test, where the diff shows it, and `critique` reports a move whose reason is missing there as a should-fix.
- **AC-8** The standard says a new test goes into the fast check. It goes into the slow check only when it can't be made fast, and end-to-end tests belong there from the start. A pre-commit hook runs the fast check, and CI runs both. `restructure`, where it makes the hook and CI run the checks, wires them that way.
- **AC-9** `restructure` rewrites a `Check:` line without a `Fast check:` line into `Fast check:`, and `critique` reports such a `Check:` line as a should-fix, as it does any line not in the standard's form. Every skill that writes or names the check line today names the new lines. `upgrade-dependencies` runs both checks wherever it runs the checks today. For `init-security-policy`, that means the policy check goes into the fast check. Only if it can't be made fast does it go into the slow check, and then the skill says so when it asks the developer to look.
- **AC-10** If a project has both a `Check:` and a `Fast check:` line, the runner refuses to start and says to remove `Check:`. Where a build's commit has both, the runner treats it as a red check and hands it back to that session. `critique` reports both lines as a should-fix.
- **AC-11** `critique` run on its own, not handed any check results, runs both checks.
- **AC-12** The standard says the fast check takes at most 30 seconds. `/criteria-to-tickets` times the fast check when it slices a change. Where it takes longer, the first ticket is a preparatory one, and every other ticket comes after it: it makes the slowest tests fast where it can, and moves the rest to the slow check, each move reported as AC-7 says. That ticket reports how long the fast check took before and after. The developer sees the time measured while slicing when they approve the tickets, and the before and after at acceptance.

### What production must show
None.

### Security policy
None.

### Information model
None.

## Agreed design
A project splits its checks into a fast check, which every build runs as often as it needs, and a slow check for the tests that can't be made fast, such as end-to-end tests. Tests are made fast first. Moving one to the slow check is reported like a weakened check. The runner runs both checks once before the first build, once after every ticket's commit, and once after the final review. A red result goes back to the session that made the commit.

## Technical decisions
- **Concepts** A project's checks are a *fast check* and a *slow check*, and the two together are the full check.
- **Wire formats** The `CLAUDE.md` lines `` Fast check: `…` `` and `` Slow check: `…` ``, in the same strict form as `Check:`. A `Check:` without `Fast check:` is read as the fast check. A project with both `Check:` and `Fast check:` is refused. The runner's exit codes stay as they are.
- **Hard to reverse** none

## Out of scope
- Making tests faster outside the preparatory ticket of AC-12.

## Ruled out
- **Only fewer full runs** - each run is still slow.
- **Only making the suites faster** - some tests, such as end-to-end tests, can't be made fast.
- **The full check in the background while the next ticket builds** - it is hard to tell which commit broke a check.
- **The slow check after each ticket as a per-project option** - the choice would sit in `CLAUDE.md` for every later agent to work around.
- **`Check:` as the fast check with only a new `Slow check:` line** - the developer chose explicit names for both.
- **Halting at once, or handing a red check at the end to acceptance** - the review session can fix it, and acceptance would get a change whose checks fail.
- **`restructure` splitting an existing suite when it rewrites a `Check:` line** - the split belongs where a change needs it, as a ticket the developer approves.
- **A time limit set per project** - one more `CLAUDE.md` line for agents to work around. 30 seconds is a starting value, to be changed if it proves wrong.
