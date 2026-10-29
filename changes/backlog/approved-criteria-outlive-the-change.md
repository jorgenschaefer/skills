---
effort: XL
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
it, and that is confirmed for every change before it is accepted"; "Weakening
or deleting one is a decision about what it checks, and reported as one."

Evidence:

- `/accept-criteria` deletes the change's directory, `CRITERIA.md` included
  (`accept-criteria/SKILL.md`, "Once the user accepts"; `PIPELINE.md`, "What outlives a change"). What
  it was for "survives in git history", which a fresh agent does not search.
- Tests name the ACs they pin by id (`implement/SKILL.md:18`), and every
  change numbers its ACs from `AC-1`, so after deletion `AC-3` in a test
  name points at nothing and is ambiguous across changes.
- `PIPELINE.md` (ACCEPT, "Before acceptance") says every check for
  something the developer approved "is shown to fail when the code breaks
  it". No skill or script does this. The only failure ever watched is TDD's RED run, once,
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

In the weight tracker, the developer approved each fix to the "gaining
weight" rule, one at a time. Nobody saw the fixes add up to a pile of
special cases instead of one approach. In the end the developer could no
longer say what the rule was meant to do, and nothing written down said it
either.

The manifesto says, in the first line under "For every goal": "The
developer answers for the software as a whole, not for one change at a
time." This item carries one part of that: where a later change quietly
alters behaviour the developer approved earlier, that reaches them without
their having to notice or ask.

The user, on 2026-10-28, writing down what the pipeline is meant to be: "The
main thing I'm unsure right now is the artifacts that create confidence. We
already have SECURITY_POLICY.md. In my mind, there's also the domain model
(ER-style) and domain actions, but this is all very vague and not settled at
all." So which approved artifacts outlive a change - beside
`SECURITY_POLICY.md` perhaps a domain model, domain actions, the critical
user journeys below, the approved criteria - is open, and `PIPELINE.md`
names only the security policy until this item settles the rest.

`acceptance-evidence-from-a-script` builds on this: its per-criterion
evidence needs tests that say which approved criterion they prove.
`refactor-phase` also builds on it: the approved criteria are the list of
behaviours it ranks.

## Critical user journeys

Merged from `critical-user-journeys` on 2026-10-29: when `PIPELINE.md` was
written, the developer moved journeys among the artifacts that create
confidence, which this item settles.

Nothing the pipeline uses or writes says what the software is for: the two or
three critical user journeys (CUJs) - the end-to-end paths that make it worth
using, such as "a customer finds a product and pays for it". They sit far above
the acceptance criteria: a handful per product against hundreds of ACs, each a
happy path at the level of the user's goal, without error cases, which are too
many and too detailed at that level. A change's ACs say how that change moves a
journey; the journey itself is never written down or approved.

Evidence:

- `CODING_STANDARDS.md:89` (five copies) asks "Does the software support the
  main workflows smoothly?" and nothing defines them.
- `repo-overview` writes "Main workflows" into `ARCHITECTURE.md`
  (`repo-overview/SKILL.md:77`), derived from the code: what is, not what was
  meant, and approved by nobody.
- The usability check completes the change's ACs as tasks
  (`MANIFESTO.md`, Usability), so a change that breaks a journey it did not
  touch goes unnoticed; acceptance holds the change against its own Problem,
  never against the journey.
- `ubiquitous-language` walks "each major workflow" through its terms
  (`ubiquitous-language/SKILL.md:62`) and invents the workflows each time.

How it was discussed to fit:

- **Manifesto:** the developer owns the journeys - the top of what the
  developer decides, "what the software does", and the one approval that
  outlives every change. Changing one is a decision the plan didn't cover.
  The usability agent completes the journeys through the real interface, not
  only the change's ACs. Each journey is held by an end-to-end check; its
  written form stays short: who, what they want to get done, a few steps in
  their words.
- **A lasting file**, e.g. `JOURNEYS.md` beside `UBIQUITOUS_LANGUAGE.md`,
  with a format file copied into each skill that uses it. Accepted ACs live
  on as tests grouped under the journey they serve.
- `idea` places the problem on a journey; one that fits none is either a new
  journey or not worth doing.
- `find-criteria`: `CRITERIA.md` names the journey the change serves; adding
  or changing a journey is approved explicitly, one more approval beside the
  four AC groups and three technical decisions. Where the project has none,
  the first change writes them.
- `implement` / `critique`: the usability driver also gets the journeys the
  change touches; a journey check weakened or deleted is reported as a
  decision.
- `accept-criteria` walks the change's journey end to end and holds the
  result against it as well as against the Problem.
- `repo-overview`'s "Main workflows" become the draft for an existing
  project's first journeys, and later show where code and journeys differ.
- `restructure`: a feature that serves no journey is a candidate among
  "features that cost more than they give"; `backlog` ranks utility by the
  journey an item serves; `ubiquitous-language` walks the approved journeys;
  `explain-diff` places a change's happy path on its journey.

Journeys carry the parts of the software that no recent change touched. A
journey's end-to-end check is the most direct evidence that the software as
a whole works. When a journey breaks, the developer hears of it without
having to notice or ask.

Open:

- When the journey checks run: end-to-end checks are slow and flaky, but
  every check for something approved has to fail when the code breaks it,
  confirmed for every change. Part of this is settled: end-to-end tests
  belong in the project's slow check (`CODING_STANDARDS.md`, _Test
  Coverage_), and `run.sh` runs the slow check before the first build, after
  every ticket and after the final review.
- Whether `find-criteria` writes the first journeys, or something else does.
