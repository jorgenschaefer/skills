---
id: 02
status: done
depends_on: []
---

# Hand a reviewer the proof and say where the ticket stands

## Why

A reviewer is dispatched at the one moment the ticket is guaranteed to look
unfinished. `## Record` is written in `## Finish`, after both reviews, and
`status` stays `todo` until then, so a reviewer that reads `TICKET_FORMAT.md` to
learn the shape correctly observes a ticket that does not conform, and files it.
Four times now: once on 2026-08-27, three times in the run of 2026-08-29, where
both reviewers raised it on the first round and the code review raised it again
on the second. Every one was unanswerable from where the reviewer stood, and
every one was adjudicated away by the builder. That is the cost - not the round,
but a builder rehearsing the move of talking a blocker down, which is the failure
an adversarial review exists to prevent.

Underneath it is a narrower gap the same ordering creates. `/implement` proves
every criterion before the reviews - `### Prove the contract before the reviews
see it` runs ahead of `## Review it` - and writes none of it down until after
them. So a reviewer cannot see which test pins which criterion or how it was
proved, and a claim about what was proved has nowhere to be settled but in the
builder's own judgement. The 2026-08-27 blocker was partly this: it claimed a
walkthrough had not run.

Both are failures of what the dispatch carries, not of what the ticket contains.
Afterwards a reviewer is told where the ticket stands and is handed the proof the
builder has already produced.

## Satisfies

- **AC-1** - **Given** the rules governing both dispatches in `## Review it`,
  **when** a reviewer is handed the ticket, **then** it has been told as a plain
  fact where the ticket stands - that `Commit`, `Decisions`, `Unresolved`,
  `Left open` and `status: done` are written after the reviews return - and
  nothing more. It is not told that their absence is not a finding, or anything
  else about what to conclude: `## Review it` forbids telling a reviewer what not
  to flag, and that rule is left standing.

- **AC-2** - **Given** the builder has finished `### Prove the contract before
  the reviews see it`, **when** it dispatches the quality review, **then** the
  dispatch carries what that step produced: per `Satisfies` id - or per behaviour
  the diff touches, where the ticket claims no ids - the test that fails without
  it, and how that was established.

- **AC-3** - **Given** the code review, which `## Review it` today dispatches
  with the ticket's diff and `coding-conventions` and nothing else, **when** it
  is dispatched, **then** its inputs are named in full rather than left for a
  builder to complete, and they include the same proof list, which its own
  coverage bullet cannot be answered without.

- **AC-4** - **Given** a review fix that adds or changes a test after the first
  dispatch, **when** the code review is re-dispatched over those fixes, **then**
  the proof list it is handed reflects them. The dispatch is composed at the
  moment of dispatch, so this is a property of the instruction rather than of a
  record anyone has to remember to refresh.

## Touches

- `implement/SKILL.md`, `## Review it` - the shared bullets governing both
  dispatches, and the two numbered paragraphs that name each review's inputs.

## Provides

- A proof list in front of a reviewer, which is the first evidence it receives
  that is not the builder's own summary of its own work.

## Out of scope

- **Writing anything into the ticket before `## Finish`.**
  `TICKET_FORMAT.md:134` gives a ticket two states, intent before the run and a
  record after it; a partial `## Record` invents a third. It also breaks the halt
  path: an unattended halt commits the ticket alone with the work left
  uncommitted, so a pre-written `Pinned by` would name tests git does not
  contain.
- **Any change to `TICKET_FORMAT.md`** or its five copies. Nothing here changes
  what a finished ticket looks like.
- **A new `status` value.** `todo | done | blocked` is the loop's durable state
  and `loop.sh` selects on it at `:347`, `:370` and `:385`; a fourth value
  touches the driver's state machine to solve what a sentence in the dispatch
  solves.
- **Asking a reviewer to break behaviour in the tree to test the proof.** It
  contradicts `## Review it`'s own "a tree you must not disturb", and the parked
  entry *A review subagent can destroy the work it was sent to read* is open
  against that exact hazard. The vocabulary for it would also trip the check at
  `tests/run.sh:906`, whose needles are `mutation|mutant|…|survivor`.
- **Whether a prose criterion needs a test at all** - `TICKET_FORMAT.md:120`.
  Raised in the discovery that produced this ticket and deliberately left
  unparked, so it is scoped out here rather than deferred to a record. This
  ticket inherits the tension; see `## Verification`.
- **That a spec-less ticket's `## Defaults` section is defined by `/discovery`
  and by no `TICKET_FORMAT.md` copy**, so it is unclear whether it binds a
  builder at all. Found here, not fixed here.

## Defaults

- **D-1: everything travels in the dispatch; nothing is written into the ticket
  early.** The dispatch is composed fresh at each dispatch, which makes it
  current by construction, costs no format change, and leaves the ticket's two
  states alone. *Overturned by* finding a reviewer needs the evidence to persist
  past the review that read it.
- **D-2: the lifecycle sentence states a fact and stops.** Not "so their absence
  is not a finding", which is telling a reviewer what not to flag - the thing
  `## Review it` forbids in terms. A reviewer given the fact can draw its own
  conclusion, and one that files anyway has found something the fact did not
  cover. *Overturned by* reviewers still filing the lifecycle finding when told
  only the fact.
- **D-3: the proof list is what `### Prove the contract` already produces, not a
  new artifact.** That step already names a test per id and executes the failure;
  this hands over what it establishes rather than asking for anything more.
  *Overturned by* the step turning out not to leave the builder with something
  statable per id.

## Verification

This ticket touches one file and breaks no invariant: it changes no shared copy,
so the parity check at `tests/run.sh:889` is not in play, and it adds no
vocabulary the needle check at `:906` would catch - which the `Out of scope`
bullet above is there to keep true.

AC-1 through AC-4 are prose, verified by reading `## Review it` against each
criterion. No wording assertion is written for them: a check that fails when a
sentence is rephrased pins the phrasing rather than the rule, and this repo's two
existing content checks are both invariants over prose rather than paraphrases
of it.

That is a stated exception to `TICKET_FORMAT.md:120`, which does not leave this
open - its last sentence prescribes exactly the assertion being declined. The
exception is recorded rather than worked around, and it is why `:120` is the
prerequisite this ticket was deliberately built without.

## Record

**Commit:** 1044d39

**Pinned by:**
- **AC-1** - nothing pins it. Verified by reading `implement/SKILL.md:114`
  against the criterion. No deletion or edge proof was run, because no test
  exists to run one against: `tests/run.sh` reads no line of any `SKILL.md`,
  which both code-review rounds confirmed independently.
- **AC-2** - nothing pins it. Read `implement/SKILL.md:115` (what the list
  carries) and `:120` (the quality dispatch naming it) against the criterion.
- **AC-3** - nothing pins it. Read `implement/SKILL.md:122` against the
  criterion; before this change that paragraph named only the diff and
  `coding-conventions`.
- **AC-4** - nothing pins it. Read `implement/SKILL.md:115`, the compose-as-you-
  dispatch sentence, against the criterion.

**Decisions:**
- **[medium]** No wording assertion written for any criterion -
  `implement/SKILL.md:114-115`, `:120`, `:122`. Facing `TICKET_FORMAT.md:120`,
  which prescribes asserting on the file's text, chose the ticket's stated
  `## Verification` exception because the user ruled on it directly before this
  build. Rejected writing a presence check per criterion, which is what both
  reviewers asked for; that argument is live and is recorded below rather than
  answered here.
- **[medium]** Both new rules placed in the shared bullets of `## Review it`
  rather than beside `### Prove the contract`, which is what produces the proof
  list - `implement/SKILL.md:114-115`. The ticket's `Touches` names `## Review
  it` alone, and a definition beside the producing step would have been built
  outside it. The cost is that the list is defined forty lines from the step
  that fills it.
- **[low]** AC-1 names `Commit`, `Decisions`, `Unresolved`, `Left open` and
  `status: done`; the bullet says "`## Record` and its `status: done`" instead -
  `implement/SKILL.md:114`. `## Finish` defines `## Record` as exactly those
  fields plus `Pinned by`, so naming the section carries more than the list
  does, and a dispatch that enumerates five fields reads as a checklist rather
  than the plain fact D-2 asks for.

**Unresolved:**
- **[medium]** *Nothing pins the rule that both dispatch paragraphs name the
  proof list.* Filed by the quality review and again by the code review, which
  reached it independently in both rounds. Their argument: a presence check -
  that the two dispatch paragraphs contain "proof list" - is an invariant over
  prose in the same shape as `tests/run.sh:906`, not the phrasing-pin the
  ticket's `## Verification` argues against, and it costs one coined term. The
  trigger they construct: a later change consolidates `## Review it`, drops the
  proof list from `:122`, the suite stays green, and the defect this ticket
  fixed returns silently once the ticket is deleted on acceptance. It is not
  adjudicated down on technical grounds. It was declined because the user ruled
  that prose changes get no tests, which is the ground the ticket's
  `## Verification` stands on, and reversing that is theirs and not a builder's.

**Left open:**
- The lifecycle fact at `implement/SKILL.md:114` is a second representation of
  `## Finish` at `:151-152`. D-1's own overturn clause - a reviewer needing the
  evidence to persist - is the live path to moving `## Record` earlier, and
  whoever takes it must change both or the bullet will instruct builders to
  state a falsehood to a reviewer. Same file, forty lines apart, so the hazard
  is small; no criterion covers it.
- This ticket's `Out of scope` cites `loop.sh:347` for status selection. The
  selection is at `:362`, `:370`, `:381`, `:385` and `:400`; `:347` is the
  frontmatter reader that feeds them. The claim holds, the line does not.
