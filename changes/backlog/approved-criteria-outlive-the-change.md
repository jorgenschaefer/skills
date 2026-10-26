---
effort: L
utility: XL
---

# What the human approved outlives the change

Once a change is accepted, nothing a fresh agent can find says what a human
approved, or which test is the check for it. A later change can undo an
approved behaviour, policy or data rule, delete or weaken its test, and
nobody notices that this was a decision for the human.

`MANIFESTO.md` asks for the opposite: "Changing anything they approved is
theirs to decide"; the checkers "show each criterion with a check that
executes and stays, since the next agent will not remember it"; "A check for
anything the developer approved counts only if it fails when the code breaks
it, and that is confirmed on every change"; "Weakening or deleting one is a
decision about what it checks, and reported as one."

Evidence:

- `/accept-criteria` deletes the change's directory, `CRITERIA.md` included
  (`accept-criteria/SKILL.md`, "Once the user accepts"; README.md:28). What
  it was for "survives in git history", which a fresh agent does not search.
- Tests name the ACs they pin by id (`implement/SKILL.md:18`), and every
  change numbers its ACs from `AC-1`, so after deletion `AC-3` in a test
  name points at nothing and is ambiguous across changes.
- README.md:185 says a criterion "is pinned by breaking the behaviour and
  watching its named test fail - deleted, and its edges moved". No skill or
  script does this. The only failure ever watched is TDD's RED run, once,
  at build time (`CODING_STANDARDS.md`, "Use TDD").
- `critique` reports lost tests as a finding for the builder to fix
  ("Tests that left", `critique/SKILL.md`), not as a decision for the human,
  and cannot tell an approved constraint's test from any other.

From the review: deleting the paperwork to keep stale documents away is a
sound instinct. The direction discussed was to let the checks carry the
approval - tests named by the approved behaviour in plain words - and to
break the code on approved tests whose code a diff touches, rather than
mutation-testing everything on every change. Only what no check can hold
stays written down.

`acceptance-evidence-from-a-script` builds on this: its per-criterion
evidence needs tests that say which approved criterion they prove.

Depends on `critical-user-journeys`, which gives accepted criteria a place to
live on.
