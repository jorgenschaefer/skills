# Solution: one door into the pipeline, and the unattended ceremony behind it

## Why

The craft of turning a request into something buildable is written down
three times in this repo: `/discovery`'s phases 1 and 2, `/idea` plus
`/to-solution`, and `/find-solution`. Every sharpening lands in one copy and
reaches the others only by hand. `9b4243f` is the instance - three moves
lifted out of `/discovery` into `/to-solution`, one way only, leaving
`/find-solution` with neither the specimen rule nor the survey the same day.
The recurrence rate is every improvement to any of them: 13 of this repo's
15 active weeks touch one of the four files.

The intent counted two copies. The cold re-derivation found three, which
widens the problem without changing it. `writing-great-skills` names the
failure **duplication** - "the same meaning in more than one place. Costs
maintenance and tokens, and inflates a meaning's prominence on the ladder
past its real rank."

**The craft**, used throughout this spec with one meaning: excavating the
problem beneath the request, building a field of candidates that differ in
kind, weighing them against criteria agreed before anything is scored, and
choosing one or blocking. Numbering, seams, ordering and hashing are not
craft - they are decomposition, and they belong wherever the unattended run
is served.

## Solution

- **Chosen** - one entry point for all work, code or not. `/idea` finds the
  problem and may end there; `/to-solution` designs against the intent and
  writes a solution spec; `/spec-to-tickets` hardens that spec into the
  anchors an unattended run needs, but only when one is about to start.
  `/discovery` and `/find-solution` both retire. This extends the existing
  second lane rather than introducing a third shape.

- **Rejected - the craft as a shared file, duplicated byte-identical** into
  each skill the way `TICKET_FORMAT.md` already is (five copies,
  `md5sum`-identical today). It fixes the drift for roughly a fifth of the
  effort, deletes nothing, and is reversible by `cat`. It lost to criterion
  4: it leaves three entry points and you still have to pick one. The
  strongest loser, and the first thing to reopen if the cost below proves
  mispriced.

- **Rejected - one prose body** with the code-specific moves generalised in
  place and conditioned by "omit where it does not apply". Lost to criterion
  2: the conditioning is a judgement remade each run.

- **Rejected - a `designing-a-code-change` standard**, read by
  `/to-solution` when the corpus is a codebase, the way it already reads
  `coding-conventions`. Lost on evidence: it gates on *is this work code*,
  and the measurement says the material's real seam is *will this be built
  unattended*. Under it, a code change built with you present still collects
  anchors nothing will read.

- **Rejected - do nothing.** The number every candidate had to beat, and not
  cheap: a hand-port per improvement, most weeks, plus the ports that
  silently do not happen, until the copies are different crafts.

## What decided it

Ranked, and agreed before anything was scored:

1. Drift cost per improvement - how much work a change to the craft costs
   afterwards, and whether it can be skipped silently.
2. How structurally the code-specific material is kept out of a non-code
   session - a gate, or a judgement remade each run.
3. Cost to get there, and how cheaply it unwinds.
4. One door, reached without first classifying the work.
5. Every piece of `/discovery`'s code-specific material ends with a recorded
   verdict.

**Criterion 4 was corrected upward at the comparison**, which is what
decided between the chosen candidate and the shared-file one. Recorded
because the two are otherwise close and the ranking is the only thing
separating them.

## Standards

- **`writing-great-skills`** (`.agents/skills/writing-great-skills/`) - the
  standard for the deliverable, since every artifact here is a skill.
  Binding shapes: **duplication** and **sprawl** as named failure modes; the
  information hierarchy, which puts a format document behind a context
  pointer rather than inline; **single source of truth**; invocation chosen
  by whether the agent must reach the skill on its own.
- **This repo's shared-format convention** - a document two skills both need
  is copied byte-identical into each, never cross-referenced by relative
  path, because skills install independently and `diff` is then the parity
  check. It reads as duplication under the standard above and is a
  deliberate exception with a named reason. This design adds copies of two
  existing format documents and creates no new shared document.
- **`coding-conventions`** - binding only for P7's edits to `loop.sh`, which
  are prose: one comment and one narration string naming a skill that will
  no longer exist. No behaviour in either script changes.

No contradiction between them was left unresolved.

## Design

The seams, written out as they would read:
**[the specimen](SPECIMEN_MERGE_LANES.md)**.

### Where the anchors go

`/spec-to-tickets` **hardens the solution spec in place** and hashes the
file it leaves. This is what it already does - it marks `(binding)` on the
defaults before hashing (`spec-to-tickets/SKILL.md:90`) - extended from one
mark to the full set of anchors. So `SOLUTION_FORMAT.md` describes two
states of one file:

- **As written by `/to-solution`** - `## Why`, `## Solution`, `## What
  decided it`, `## Standards`, `## Domain`, `## Design`, `## Implementation
  decisions`, `## Parts`, `## Scope`, `## Success criteria`,
  `## Constraints`, `## Defaults`, `## ADRs`, `## Open concerns`. No
  journeys, no numbered criteria. A spec for a document or a process stops
  here and is complete.
- **As hardened by `/spec-to-tickets`** - the same file, plus `## Journeys`,
  plus `US-n.m` criteria, plus `C-n` on the constraints, plus `(binding)`
  marks, then hashed.

**Two levels of criteria, so `/check-against-spec` keeps the distinction it
already draws** between a success criterion no ticket claims
(`check-against-spec/SKILL.md:50`) and a numbered criterion (`:51`):
`## Success criteria` stay feature-level and unnumbered; `/spec-to-tickets`
derives the testable `US-n.m` from each part's *Done when* plus `## Design`,
with `n` the part's index. The id shape is unchanged because
`TICKET_FORMAT.md` and `/check-against-spec` already read it; the `US`
prefix outlives the user stories it was named for, and that is cheaper than
a rename reaching five format copies.

Deriving is not deciding. The journeys come out of `## Design` and
`## Parts`, and are shown back before decomposition - a journey invented at
this step is an acceptance script for a feature nobody designed.

### Where the paper lives

`accept.sh:54-56` refuses a spec directory holding more than one `.md`, and
`loop.sh:798` ends every clean run pointing at it. So:

- The **intent** lives outside the spec directory. `/idea` already asks
  where to write it, and it is the design record rather than the run's
  paper.
- The **hardened spec** is the one `.md` in the spec directory.
- The **winning specimen** goes in `mockups/` beside it, which `accept.sh`
  already deletes with the rest of the paper.

`accept.sh` is untouched.

### The four changes that carry the rest

1. `SOLUTION_FORMAT.md` gains `## Domain`, `## Defaults` (`D-n` with
   `_Overturnable on:_`), `## Implementation decisions` carrying the
   duplication survey's verdicts numbered in place, and `## ADRs`; and
   `## Criteria` is renamed `## What decided it`, because one step
   downstream *criteria* means the ids tickets claim.
2. `/spec-to-tickets` gains the hardening front half, and loses every route
   back to `/discovery`.
3. `/to-solution` learns that a codebase is a corpus - one paragraph naming
   what *read the corpus* and *find the standards* mean when the corpus is
   code - gains the domain model in its weighing, and absorbs the two moves
   `/find-solution` holds alone: *reversibility breaks near-ties*
   (`find-solution/SKILL.md:52`) and *the four kinds are a floor, not the
   exercise* (`:31`).

   **Port process, not explanation.** Everything moved out of `/discovery`
   passes the no-op test first: does this line change what a model does, or
   does it define a term the model already holds? The domain section is
   where this bites hardest - bounded context, actor, entity, aggregate,
   action and domain event are textbook terms sitting in pretraining, and
   `writing-great-skills` says a **leading word** earns its place by
   recruiting those priors rather than restating them. So *aggregate* is
   used and never defined, and what ports is the judgement around it: that
   the boundary is usually what makes one candidate fit and another not
   (`discovery/SKILL.md:115`); that a traced domain story announces its own
   missing steps - an action with no actor, a work object nobody creates, an
   event nothing reacts to (`:119`); that bounded context is noted only when
   the change crosses or establishes one (`:111`); and that the show-back is
   in the user's language, because whether something is an entity or a value
   object is the model's problem and not theirs (`:121`). Stripped of its
   definitions the section is under 200 words, which is why it lives inline
   rather than in a sibling file.

   **The domain model is modelled in phase 2 and shown at stop 2**, not in a
   stop of its own. `/discovery` gives it a separate show-back turn
   (`discovery/SKILL.md:121`) because a model presented as a finished
   picture gets nodded at; here the comparison is already the turn where the
   candidates are laid out to be corrected, and how each one carves the
   domain is part of what separates them. So the model rides on stop 2 with
   the same vetoes foregrounded - these two are one thing, this may lag
   that, that is not what we call it here, you have missed an actor. The
   three stops stay three.
4. `/idea` becomes model-invoked, so work reaches the lane without anyone
   first deciding which skill it belongs to.

`/idea` and `/to-solution` stay two skills, because `/idea` is a place to
stop: noting an idea and being done with it is a whole use of the lane. The
README's current explanation - that the session which finds the problem
should not be the session that designs against it - is not the reason and is
corrected in P7. The cold re-derivation remains a property of
`/to-solution`; it is no longer load-bearing for anything.

### What the measurement settled

43 run transcripts across 9 projects, plus every downstream reader:

| Material | Evidence | Verdict |
|---|---|---|
| Criteria `US-n.m` | claimed by tickets, written RED first, orphan-swept | keep; `/spec-to-tickets` derives and numbers them |
| Constraints `C-n` | `C-1..C-4` driven in the `zugang` acceptance | keep; numbered at hardening |
| Defaults `D-n` | `D-1..D-27` verified in the same run | keep; `/to-solution` writes them, `/spec-to-tickets` marks `(binding)` |
| Duplication survey verdicts | `spec-to-tickets:69`, `check-against-spec:55` both read them | keep; `## Implementation decisions` |
| Dependency edges | `/spec-to-tickets` decomposes along them | keep; already `## Parts`' *Depends on* |
| Journeys `J-n` | driven live in 10/10 acceptance runs | keep; derived at hardening |
| User-story *form* | consumed by nothing downstream | drop |
| `## Non-goals` | `check-against-spec:53` sweeps them | keep, as `## Scope`'s *Never* |
| `## Preconditions` | nothing downstream reads it | drop; `## Parts`' *Depends on* covers build order |
| `## Implementation decisions` | `/implement` builds against it | keep |
| Bounded context, Roles, Domain events | subsections of `## Domain` | keep, under `## Domain` |
| The three-tier text | `/implement` and `/spec-to-tickets` rely on it | keep; moves into `SOLUTION_FORMAT.md`'s preamble |
| Mockup walk | already generalised as the specimen rule in `9b4243f` | already ported |
| Domain model | use not separable from format-file reads | keep, on argument not evidence |
| Lifecycle / actor sweeps | produce no artifact | session technique, not spec material |
| `### Name the lane` | selects spec vs ticket vs no | drop; a one-part spec is one ticket |
| `tests/workflows/` | never existed in any project; 37 tickets say so verbatim | not carried forward |

Ratified journeys are dropped as a concept, so the permanent tier is two
members - a term and an ADR - rather than three.

### Survey of what already exists

- **`/idea`** - extend. Model-invoked description; the ending at an intent
  stated as an ending, including the ending that writes no file.
- **`idea/INTENT_FORMAT.md`** - reuse unchanged.
- **`/to-solution`** - extend, per *The four changes* above.
- **`to-solution/SOLUTION_FORMAT.md`** - extend, per *Where the anchors go*.
- **`/spec-to-tickets`** - extend with the hardening front half; its
  `## Before starting` loses `SPEC_FORMAT.md` and `tests/workflows/`, and
  its five routes back to `/discovery` become questions asked of the user,
  who is present.
- **`discovery/SPEC_FORMAT.md`** - absorb into `SOLUTION_FORMAT.md` and
  `/spec-to-tickets`, then delete.
- **`discovery/SKILL.md`** - replace, by `/idea` plus `/to-solution`.
- **`find-solution/SKILL.md`** - replace. Its craft is the same craft; its
  two unique moves are absorbed into `/to-solution`, and its ending - a
  recommendation recorded only where the decision will be re-argued (`:62`)
  - becomes `/to-solution`'s third ending beside the spec and the block.
- **`discovery/ADR_FORMAT.md`**, **`discovery/UBIQUITOUS_LANGUAGE_FORMAT.md`**
  - reuse, relocated: byte-identical copies into `to-solution/`, which now
  proposes both, and into `handover/`, which names `ADR_FORMAT.md` at
  `:34` without holding a copy - a live break under the shared-format
  convention, fixed here.
- **`ubiquitous-language-init/UBIQUITOUS_LANGUAGE_FORMAT.md`** - reuse,
  `md5`-identical to discovery's today and one of the copies P3's parity
  check quantifies over.
- **`/check-against-spec`** - reuse. It reads the hardened spec, which still
  carries `## Journeys`, `US-n.m`, `C-n`, the survey verdicts and the
  non-goals it sweeps. Its two references to ratified journeys and
  `tests/workflows/` are edited to drop a concept that no longer exists.
- **`/implement`, `/implement-ticket`, `loop.sh`, `accept.sh`** - sit
  beside, behaviourally. The tickets they consume keep their shape and their
  anchors. Each carries prose naming `/discovery` that P7 rewrites; no logic
  changes.
- **`TICKET_FORMAT.md` × 5** - extend, textually: six references each to
  `/discovery` and its small lane, rewritten to name the merged lane and
  re-copied byte-identical. The ticket's shape is unchanged.
- **`README.md`** - extend: the pipeline section rewritten around one door,
  the split's stated reason corrected, and `/discovery` and `/find-solution`
  removed from the skill list.

Mostly reuse and extend, three replacements. The candidate does not diverge
from what the repo already does.

## Parts

- **P1 Rename the decision criteria.** `## Criteria` becomes `## What
  decided it` in `SOLUTION_FORMAT.md`, and `/to-solution`'s three uses of
  the word *criteria* (`:15`, `:41`, `:62`) are disambiguated so each names
  which kind it means. Depends on: nothing. Done when: `SOLUTION_FORMAT.md`
  carries a `## What decided it` section and no `## Criteria` section, and
  no sentence in `/to-solution` uses *criteria* without saying which kind.

- **P2 Teach `/to-solution` that a codebase is a corpus.** The paragraph,
  the absorbed `/find-solution` moves, plus byte-identical copies of
  `ADR_FORMAT.md` and `UBIQUITOUS_LANGUAGE_FORMAT.md` into `to-solution/`
  and `handover/`. Depends on: nothing. Done when: `diff` across all four
  copies of `UBIQUITOUS_LANGUAGE_FORMAT.md` and all three of
  `ADR_FORMAT.md` is clean, and a `/to-solution` run on a code change reads
  the codebase, `UBIQUITOUS_LANGUAGE.md` and the project's ADRs.

- **P3 Give the solution spec its anchors.** `## Domain`, `## Defaults` with
  `D-n` and `_Overturnable on:_`, `## Implementation decisions` with the
  survey verdicts numbered in place, `## ADRs`, the tier preamble, and the
  matching moves in `/to-solution`, each ported by *Port process, not
  explanation*. Depends on: P1, P2. Done when: no ported line defines a term
  the model already holds, and a `/to-solution` run on a code change
  produces a spec whose every default carries an `_Overturnable on:_` clause
  naming something checkable in the code, whose domain section names the
  aggregate the change sits in, and whose every survey verdict is numbered.

- **P4 Make `/spec-to-tickets` read a solution spec.** The hardening front
  half - number the criteria from each part's *Done when*, number the
  constraints, derive and show the journeys, mark the binding defaults, hash
  the file it leaves - plus the removal of its `SPEC_FORMAT.md` and
  `tests/workflows/` reads and its five routes back to `/discovery`.
  Depends on: P3. Done when: it turns a `SOLUTION_FORMAT.md` spec into a
  hardened spec and a ticket set that passes its own falsification review,
  and it still accepts a `SPEC_FORMAT.md` spec so that stopping at P5 leaves
  a working decomposer.

- **P5 The proving run.** Re-run one feature already built through the old
  lane through `/idea` → `/to-solution` → `/spec-to-tickets`. Use `zugang`:
  its spec and ticket set were deleted by the accept commit `e89d1308` in
  `drk-barmbek/kh` and are recoverable whole from `8e91c9d0`, and its
  acceptance transcript records what the old lane's set achieved. Depends
  on: P4. Done when: the new ticket set has the same seams and the same
  criterion coverage as the recovered one, and nothing a builder would have
  to guess that the old lane had answered. **This is the gate.** A worse set
  stops the work here, with P1-P4 standing on their own.

- **P6 Make `/idea` the door.** Drop `disable-model-invocation`; write a
  model-facing description covering a feature, a bug, a refactor and a
  passing idea, disambiguated from `/to-solution`; state ending at the
  intent as an ending, including with no file written. Depends on: P5. Done
  when: a request that would have fired `/discovery` fires `/idea` instead,
  and a session that stops at the intent ends without being routed onward.

- **P7 Retire `/discovery`.** Delete `discovery/`. Then clear every live
  pointer to it: ten in `/spec-to-tickets`, six in each of the five
  `TICKET_FORMAT.md` copies (re-copied byte-identical), the description in
  `implement/SKILL.md:3`, three in `handover/SKILL.md`, one comment and one
  narration string in `loop.sh`, and the README's pipeline section -
  rewritten around one door, with the split's stated reason corrected.
  Depends on: P5, P6. Done when: `grep -rn discovery` over the repo returns
  only `IDEAS.md`, the vendored `writing-great-skills/GLOSSARY.md`, this
  spec's own paper, and git history.

- **P8 Retire `/find-solution`.** Delete `find-solution/`, having absorbed
  its two moves in P2 and its recommendation-only ending into
  `/to-solution`; clear its pointer at `/discovery` (`:64`) by deletion, and
  remove it from the README. Depends on: P2, P5. Done when: `grep -rn
  find-solution` returns only `IDEAS.md`, this spec's paper and history, and
  `/to-solution` states three endings.

## Scope

- **Now** - P1 through P8: one entry point for all work, `/discovery` and
  `/find-solution` retired, and the unattended anchors added by
  `/spec-to-tickets`.
- **Later** - delete the workflow-test apparatus now that ratification is
  dropped: `loop.sh`'s guard and its four functions, `/spec-to-tickets`'
  authorisation section, and the `## Workflow tests` section in the five
  `TICKET_FORMAT.md` copies. Separable, worth doing on its own, and the only
  part of this area that changes behaviour rather than prose. Then split
  `/implement` so the build protocol fires without a ticket.
- **Never** - `TICKET_FORMAT.md`'s *shape*, with two stated exceptions: the
  prose in it that names `/discovery`, which P7 rewrites, and its
  `## Workflow tests` section, which *Later* removes. `loop.sh`'s ticket
  contract and control flow;
  `accept.sh`; `/critique`; `coding-conventions`; `tests/run.sh`;
  `tests/workflows/` as a working feature.

## Success criteria

- The craft, as defined in `## Why`, appears in `/idea` and `/to-solution`
  and nowhere else. Checkable after P8 by reading those two skills and
  confirming no third file states a rule about excavating a problem,
  building a field, weighing it, or choosing.
- Starting a piece of work fires `/idea` without anyone naming a skill,
  whatever kind of work it is.
- Every piece of material in *What the measurement settled* has a verdict
  with its consumer named or the evidence for dropping it.
- A `/to-solution` session about a skill, a process or a document produces
  no journeys and no numbered criteria, and its spec is complete without
  them.
- `/spec-to-tickets` turns a `SOLUTION_FORMAT.md` spec into a ticket set
  `loop.sh` builds unattended: `spec_hash` stamped, every criterion claimed
  exactly once, every constraint at least once.
- `./accept.sh` accepts a run the merged lane produced, without
  modification.

## Constraints

- **The non-code lane does not get worse for non-code work.** Verified by
  running `/to-solution` on a non-code intent after P3 and confirming it
  surveys no codebase, writes no user stories and produces no mockup.
- **The unattended build keeps its input.** Verified by P5: the ticket set
  will be stamped with `spec_hash`, cite criteria by id, and carry the
  tiers, and `loop.sh` and `accept.sh` will consume the run without
  modification.
- **No must-happen step rests on a description matching.** Verified by
  inspection after P6: `/idea`'s model-invocation is a door, and a door that
  fails to fire is typed by hand; every step downstream is reached by name
  from the step before.
- **`/spec-to-tickets` still does not decide what the system does.**
  Verified by inspection after P4: it numbers, derives, orders and hashes,
  and the journeys it writes come out of `## Design` and `## Parts`.

## Open concerns

- **The small lane gets longer, not shorter.** `/discovery` took a bugfix to
  a ticket in about five turns; the merged path is `/idea`, then
  `/to-solution`, then a one-part spec. Assumed acceptable because `/idea`
  is a place to stop and a one-part spec is already one ticket. What would
  settle it: P5 run a second time on a bugfix rather than a feature. If it
  is worse, the answer is a stated short path through `/to-solution`, not a
  second door back.
- **Non-code work has no unattended exit, and P5 does not test one.**
  `/spec-to-tickets` refuses work not observable outside the code
  (`spec-to-tickets/SKILL.md:34`), so a spec for a skill or a document
  cannot reach `loop.sh` - which is the class of work this repo mostly does.
  Assumed acceptable because non-code work is built with you present and
  needs no anchors. What would settle it: the first time you want a skill
  change built unattended.
- **Domain modelling generalising off a codebase is argued, not measured.**
  The transcripts cannot separate real use from format-file reads.
  `PLAN_MERGE_LANES.md` asserts the same thing and never tested it either.
  What would settle it: the first non-code `/to-solution` run after P3 that
  either finds the domain turn load-bearing or skips it.
- **Journeys move from agreed-with-you to derived-by-a-skill.**
  `/check-against-spec` drives them, so a wrong journey is a wrong
  acceptance script. Mitigated by showing them back before decomposing.
  What would settle it: whether P5's derived journeys match the ones the old
  lane agreed with you for `zugang`.
