---
criteria:  CRITERIA.md
closes:    AC-6, AC-7, AC-8, AC-9, AC-11, AC-12
advances:  AC-1, AC-2, AC-10
after:
status:    done
attempts:  1
---

## Build
The standard and every skill that writes, names or runs the project's checks speak of a fast check and a slow check: `CODING_STANDARDS.md`, `SECURITY_POLICY_FORMAT.md`, `/implement`, `critique`, `restructure`, `upgrade-dependencies`, `init-security-policy`, `/criteria-to-tickets` and `/accept-criteria`.

## Done when
> **AC-6** When `/implement` builds outside the runner, from one ticket, from `CRITERIA.md` or from a plain request, it runs the fast check while it works. It runs the slow check once, before its commit. A red slow check is fixed like any red check, and nothing is committed while it is red. Where the build cannot make it green, it stops and its report names the red check.

> **AC-7** A test moved from the fast check to the slow check is reported like a weakened check. The report says which test moved, why it couldn't be made fast, and what the fast check no longer catches. The developer sees it at acceptance. The reason is also written beside the moved test, where the diff shows it, and `critique` reports a move whose reason is missing there as a should-fix.

> **AC-8** The standard says a new test goes into the fast check. It goes into the slow check only when it can't be made fast, and end-to-end tests belong there from the start. A pre-commit hook runs the fast check, and CI runs both. `restructure`, where it makes the hook and CI run the checks, wires them that way.

> **AC-9** `restructure` rewrites a `Check:` line without a `Fast check:` line into `Fast check:`, and `critique` reports such a `Check:` line as a should-fix, as it does any line not in the standard's form. Every skill that writes or names the check line today names the new lines. `upgrade-dependencies` runs both checks wherever it runs the checks today. For `init-security-policy`, that means the policy check goes into the fast check. Only if it can't be made fast does it go into the slow check, and then the skill says so when it asks the developer to look.

> **AC-11** `critique` run on its own, not handed any check results, runs both checks.

> **AC-12** The standard says the fast check takes at most 30 seconds. `/criteria-to-tickets` times the fast check when it slices a change. Where it takes longer, the first ticket is a preparatory one, and every other ticket comes after it: it makes the slowest tests fast where it can, and moves the rest to the slow check, each move reported as AC-7 says. That ticket reports how long the fast check took before and after. The developer sees the time measured while slicing when they approve the tickets, and the before and after at acceptance.

Toward AC-1: the standard gives the `Fast check:` and `Slow check:` lines in the strict form it gives `Check:` today, and says that a `Check:` line without a `Fast check:` line is the fast check.

Toward AC-2: `/implement`, when its caller says the caller runs the slow check on the commit, runs only the fast check. `critique`, handed a check result, says whether it was the result of both checks or of the fast check alone.

Toward AC-10: `critique` reports a project whose `CLAUDE.md` has both a `Check:` and a `Fast check:` line as a should-fix.

## Toward
> **AC-1** A project declares its checks in `CLAUDE.md`, in the same strict form as `Check:` today. `Fast check:` is what every build runs. `Slow check:` holds the tests that can't be made fast. A `Check:` line without a `Fast check:` line is the fast check, so a project with only `Check:` works as today, with no slow check. Where no line names a fast check, a session names one command once per run, as today, and that command is the fast check. A line a build adds is run from that build's own commit on, as `Check:` is today.

> **AC-2** In a pipeline run, a build session, the final review session and their reviews run only the fast check. A session handed back a red slow check may run the slow check to confirm its fix. `critique` in a pipeline run is handed the result of the runner's last run of both checks, or of the session's fast check, and says which.

> **AC-10** If a project has both a `Check:` and a `Fast check:` line, the runner refuses to start and says to remove `Check:`. Where a build's commit has both, the runner treats it as a red check and hands it back to that session. `critique` reports both lines as a should-fix.

## Technical decisions
> **Concepts** A project's checks are a *fast check* and a *slow check*, and the two together are the full check.

> **Wire formats** The `CLAUDE.md` lines `` Fast check: `…` `` and `` Slow check: `…` ``, in the same strict form as `Check:`. A `Check:` without `Fast check:` is read as the fast check. A project with both `Check:` and `Fast check:` is refused. The runner's exit codes stay as they are.

> **Hard to reverse** none

## Context
This repository is the suite of skills. A skill only sees its own directory, so a file two skills need is copied into each, and `./test.sh` fails when the copies differ: `CODING_STANDARDS.md` is held by `implement`, `critique`, `find-criteria`, `criteria-to-tickets` and `restructure`, and `SECURITY_POLICY_FORMAT.md` by `init-security-policy`, `find-criteria`, `implement` and `accept-criteria`. An edit to one copy is an edit to all of them, in the same commit.

Where the check line lives today: the standard's paragraph "The suite runs with one command" (`CODING_STANDARDS.md:56`); the policy check paragraph in `SECURITY_POLICY_FORMAT.md:43`; `implement/SKILL.md:24,28,36,58`; `critique/SKILL.md:28`; `restructure/SKILL.md:21`; `init-security-policy/SKILL.md:17,25,45,53`; `upgrade-dependencies/SKILL.md:14-47`; `criteria-to-tickets/SKILL.md:43`, `VERIFY.md:9-10` and `TICKET_FORMAT.md:53`, for the preparatory ticket; the weakened checks `accept-criteria/SKILL.md:50` lists; and the README's descriptions of these skills.

Ticket 02 changes the runner. Its brief tells each build that the runner runs the slow check on the build's commit, and this ticket's `/implement` is what reads that: told so by its caller, it runs only the fast check, and otherwise it does as AC-6 says. The final review's brief hands `critique` the result of the runner's last run of both checks, or of the session's own fast check, and names which.

The groups What production must show, Security policy and Information model each say "None.".

## Not here
- `run.sh`, `run/`, the runner's tests and the README's section on the runner: ticket 02.
- `restructure` splitting an existing suite when it rewrites a `Check:` line: ruled out in `CRITERIA.md`, as a split belongs to a ticket the developer approves.
- This repository's own `Check:` line and `./test.sh`: no AC asks this change to rewrite or split them.

## Left standing
- **No automated test proves any criterion this ticket closes or advances.** They are all wording in skills, and `./test.sh` checks only that the shared files' copies are identical. Two fresh `critique` reviews checked each AC by reading the text. No task was driven in a running product.
- **Fixes made after the last review**, which no reviewer saw. Both answer findings from round 2:
  - `init-security-policy/SKILL.md`: where the skill declares a new `Slow check:` line, it now also makes CI run it (should-fix: otherwise CI might never run a policy check that went into the slow check).
  - `criteria-to-tickets/SKILL.md`: the "No fast check" bullet is split into short sentences, with the same meaning (nit: it was hard to read on the first pass).
- **Review nit not fixed:** `criteria-to-tickets/SKILL.md` and `VERIFY.md` each have two preparatory tickets that come "first". Where a `Check:` line is malformed and also slow, both apply, and nothing says which comes first. This is rare, and fixing it means a rule for ordering preparatory tickets, which no AC asks for.
- **Decided here, not settled by the criteria:**
  - `critique` given a `CLAUDE.md` with both `Check:` and `Fast check:` runs the `Fast check:` command.
  - `/criteria-to-tickets` shows the fast check's timed duration at every approval, not only when it is over 30 seconds. It also hands that duration to its verifier, so the verifier can check the preparatory ticket.
- **Before ticket 02 lands,** the runner reads only `Check:`. A project that `restructure` or a preparatory ticket moves to `Fast check:` therefore falls back to a session naming the command once per run, until the runner reads the new lines.
