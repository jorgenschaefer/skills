---
effort: XL
utility: XL
---

# What the human approved outlives the change, and acceptance shows the evidence

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

The evidence at acceptance below builds on this: it needs tests that say
which approved criterion they prove. `refactor-phase` also builds on it: the approved criteria are the list of
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

## Acceptance shows evidence a script reran, not the agent's account

Merged from `acceptance-evidence-from-a-script` on 2026-10-29: its evidence
needs the tests this item names after what was approved, and both change
what `/accept-criteria` shows and deletes.

At acceptance the developer, who does not read the code, gets the agent's
account of each criterion: "for each one say what you did and what you saw"
(`accept-criteria/SKILL.md:25`). Tests come in only where an AC is not met
(`:35`). The developer cannot tell an executed proof from a judgement.

`MANIFESTO.md`, under Utility: "The report shows the evidence, rerun by a
script rather than reported by the writer", and "Where no check can show it,
it is marked as judged." For every goal: "Where a criterion can only be
judged, the review is adversarial." Showing example runs, listing tests by
what they prove, and marking a check that only approximates a criterion left
the manifesto and are not yet in `PIPELINE.md`.

Evidence:

- The runner reruns the checks itself (`run/checks.sh`), but as one
  pass/fail for the whole suite; nothing turns that into evidence per AC.
- Whether an AC is executed or judged is decided by the builder after the
  fact: Left standing lists "each criterion no automated test proves, and
  how it was checked instead" (`implement/SKILL.md`, "Finish"). `CRITERIA_FORMAT.md` has no
  place to mark an AC as judged, or a check as only approximating it, at
  approval time.
- Nothing hands the judged ACs to a reviewer whose job is to show they are
  not met. `critique` refutes its own findings, which is a different thing.

- critique's output now opens with a Tasks section: one line per AC its
  driver was handed, completed, given up or skipped and why
  (`critique/SKILL.md`, "Output"). It is a per-AC record of the judged
  usability check, but it reaches the developer only where a caller passes
  it on - `implement`'s Left standing and `REVIEW.md` carry findings, not
  tasks - and a hesitation the build fixed reaches them not at all.

From the review: the walk stays, for usability and for the problem as a
whole; the script-made table comes before it.

## A deployment checklist for the steps a change leaves for deployment

Merged from `deployment-checklist` on 2026-10-29: where the checklist lives
once acceptance deletes the change's directory is the question this item
answers.

Some steps can only happen at deployment, after acceptance: a DNS entry, a
related service deployed, data created in production. The user wants these
in a deployment checklist rather than in a ticket.

Today `/criteria-to-tickets` keeps them out of every build and puts each in
a ticket's `## Not here` as a line beginning "At deployment, a person"
(`criteria-to-tickets/SKILL.md`, "What slicing turns up"), and
`/accept-criteria` lists those lines under "Blast radius and revert". That is
a stopgap: `## Not here` is meant for the boundary against other tickets, and
`/accept-criteria` deletes the change's directory, so the steps survive
acceptance only in git history and in the report on screen.

Instances:

- `drk-barmbek` b8ca07a7: "Before this deploy, `F128222P0504` is created by
  hand in the BGM-Verwaltung", and removing the pre-check "is done by hand
  once production runs this change", both in a ticket's Context.
- `weight-tracker`, the weight trend change: a DNS entry for
  `gewicht.jorgenschaefer.de` "vor dem Deployment", inside the Wire formats
  decision.
- `dom` 2446618: the passwords in `secrets.prod.env`, which only
  `bin/deploy-prod` decrypts.

What the report shows is now the bold items in `MANIFESTO.md`, and the
steps fall under blast radius and revert: "what a revert would not undo".

Open: where the checklist lives once acceptance deletes the change's
directory, who hands it over, and when.
