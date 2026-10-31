---
effort: L
utility: L
---

# Designs declare what must be true, and builds work until it is

The user, on 2026-10-31, asked whether this fits the pipeline: the design
skills declare "what needs to be true", a goal state, and the implement
skills work until that goal is true.

## Where it came from

A project built with the pipeline gets feature requests, and some problems
are about the code and change no journey: security hardening, alerts in
production, what happens to data that already exists, a journey that no test
walks. `/idea` offers two ways on: `/design-user-journeys` where a journey
changes, `/solve-problem` where none does (`idea/SKILL.md:57`). So these go
to `/solve-problem`. It writes no test, does not use `review-change`, does
not require the journey tests to pass unchanged, and writes no friction
notes. `security-beyond-access.md` is one of these problems.

## What the pipeline already does

The journeys are a goal state of one kind: written before the build, checked
by a test per step or marked *(judged)*. The other skills have one too,
unnamed:

- `/idea`: "what would be true instead", agreed by the developer;
- `/debug`: a test that fails before the fix and passes after;
- `/refactor-codebase`: the journey tests pass unchanged;
- `/upgrade-dependencies`: latest versions, checks green.

## What it has to keep, from SDLC.md

- Acceptance holds the change against the problem, not the goal state: "If
  the software does what we designed but does not solve my problem, we go
  back to the interview."
- The goal state is fixed before the build, and the build cannot change it.
  Today this holds for `journeys/` only (`CHANGE_FORMAT.md`: "no build
  commit touches `journeys/`").
- Each statement says how it is checked: a test from the outside, a
  reviewer, or *(judged)*.
- The developer approves it without reading the code.
- A statement that must last needs a permanent place. Journeys have one;
  `CHANGE.md` is deleted at acceptance. SDLC: whatever the next agent needs
  is "in the journeys, the tests and the code".
- Where the user sees the result, the agreed design is part of the goal
  state, not only what it achieves.

## What it touches

`SDLC.md`; the four copies of `CHANGE_FORMAT.md` (accept-change,
design-user-journeys, implement-change, split-change-into-chunks) and their
`journeys:` frontmatter, which `run/drift.sh` and `run/chunks.sh` check;
the routing in `idea/SKILL.md`; `design-user-journeys`, `implement-change`
and `review-change`.
