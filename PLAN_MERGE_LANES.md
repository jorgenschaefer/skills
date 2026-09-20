# Plan: one front door, and the ceremony only where it is collected

Source: a conversation on 2026-09-20 about whether lane 1 (`/discovery` →
`/spec-to-tickets` → `/implement`) earns its paper. The decisive fact came from
the user: **`loop.sh` is used for greenfield, full-product changes - a big
build, not the normal case.**

## The problem

Every artifact lane 1 produces is a mechanism for *unattendedness*, not for
code quality. Walk them:

- **The spec** is what `spec_hash` freezes. Tickets cite criteria by id rather
  than copying them, so the hash is the only thing that detects requirements
  moving under an unbuilt ticket. Meaningless in one conversation.
- **A ticket** is one context window of work with nobody present, plus a halt
  vocabulary (`drift`, `stale-spec`, `blocked`, `mystery`), plus a dependency
  order, plus `Provides`/`Preconditions` so session 9 can rely on what session
  4 built without having seen it.
- **The `AC-n`/`C-n` id scheme** is an addressing system for coverage
  arithmetic - every criterion claimed by exactly one ticket, with
  `/check-against-spec` sweeping for orphans. It buys something only when no
  human reads the diff between ticket 4 and ticket 5.
- **The three tiers** (permanent / binding / default) tell an agent what it may
  overturn *when it cannot ask*. With the user present, all three collapse into
  asking.

None of that is overhead for the model's understanding. It is the price of
`loop.sh`. And `/discovery` charges it on every change - a bugfix, a small
behaviour change - for a decomposer that runs a handful of times a year.

**The tax is the four-phase interview, not the skills.** `/discovery` is one
door (`discovery/SKILL.md:13`) and its phase 3 and id scheme exist to feed
`/spec-to-tickets`. Work that will never reach a decomposer pays for both.

## The solution, and the ones ruled out

Move the seam. **One front door for everything; `/spec-to-tickets` becomes a
step added only when a big build is about to start.**

```
  /idea ──→ /to-solution ──┬──→ /plan → auto mode          (the normal case)
                           ├──→ /spec-to-tickets → loop.sh (greenfield)
                           └──→ a block
```

`/spec-to-tickets`, `TICKET_FORMAT.md`, the halt vocabulary,
`/implement-ticket` and `loop.sh` survive untouched. They stop taxing the
common path, which is the whole of the change.

**Ruled out: an auto-discoverable "when writing code, use this" skill carrying
the build protocol.** The knowledge half already exists and already fires -
that is `coding-conventions`, read by `/implement` (`implement/SKILL.md:26`)
and by `/critique`. What `/implement` adds is a *sequence* with bounded attempt
counts - green baseline, reconcile, red/green/refactor, design pass, break it
twice, worktree, two reviews on a different model, commit. A skill fires on
description match, which is a probability. Trading a driver's call for a
probability is acceptable for a standard and not for `break it twice`, which is
precisely the check that is not a model judging a model. Deterministic checks
belong in **hooks**, which cannot be skipped by a description not matching.

**Ruled out: deleting the spec and the tickets outright.** They are what
`loop.sh` consumes, and `loop.sh` still has a job.

**Ruled out: keeping `/discovery` and trimming its phase 3.** A trimmed
`/discovery` is `/to-solution` with a worse seam. The README already argues
against itself here: the two-session split exists because "the session that
finds the problem is not the session that should design against it", and the
cold re-derivation in `/to-solution` is a real mechanism that `/discovery`
structurally cannot have. If that claim holds, `/discovery` is the weaker of
the two *even for code*.

## The change

`/to-solution` already does most of `/discovery` phase 2: read the corpus, find
the standards, candidates that differ in kind, show specimens rather than
describe them, survey what exists with reuse/extend/absorb/replace/sit-beside
verdicts (`to-solution/SKILL.md:80`), break the design into parts
(`:82`), and a cold read for the first thing a builder would guess. The formats
line up on `Why`, `Solution`, `Success criteria`, `Constraints`, `Design`, and
`Scope` ≈ `Now and later`. `SOLUTION_FORMAT.md:28`'s `## Parts` is already
proto-tickets.

Four steps, each useful on its own.

### 1. Teach `/to-solution` the `D-n` scheme and domain modelling

**Defaults.** `SOLUTION_FORMAT.md` has no equivalent of
`SPEC_FORMAT.md:83`. This is the load-bearing gap: `D-n` is the protocol that
lets a builder deviate *only* on named evidence found in the code, and
`/spec-to-tickets` promotes the shared ones to `(binding)` before hashing
(`spec-to-tickets/SKILL.md:67`). Without it, two sessions can build on
contradictory assumptions with two green suites.

The content already exists. `/to-solution` sorts every decision into
codebase-answers-it / defensible-answer-surface-for-veto / genuinely-yours and
keeps "the running list of what you defaulted" (`to-solution/SKILL.md:96`).
What is missing is the id and the `_Overturnable on:_` clause. Promote the list
into an addressable form in `SOLUTION_FORMAT.md`; leave `(binding)` where it
is, in `/spec-to-tickets`.

**Domain modelling.** Port `## Domain` (`SPEC_FORMAT.md:41`) and discovery's
*Model the domain* into `/to-solution`'s weighing. This is not a concession to
lane 1: where an aggregate boundary sits is usually what makes one candidate
fit and another not, which is the judgement `/to-solution` is already making.
It improves the non-code lane too.

**Fix the `Criteria` collision before anything downstream reads it.** In
`SOLUTION_FORMAT.md:19` `## Criteria` is the *ranked decision criteria* used to
score candidates; in `SPEC_FORMAT.md` criteria are the ids tickets claim.
`SOLUTION_FORMAT.md:37` disambiguates with `## Success criteria`, but merged
into one lane with `/spec-to-tickets` reading downstream, this produces a wrong
ticket set exactly once and is expensive to find. Rename the decision criteria
to something that cannot be read as an acceptance criterion.

### 2. Make `/spec-to-tickets` read a solution spec

After step 1 the gap is `## Journeys` and `## User Stories`. Decide there
whether `## Parts` plus success criteria is enough to decompose from, or
whether journeys have to be ported too - see *Where this is most likely wrong*.

Prove it on one real feature before touching `/discovery`.

### 3. Split `/implement`

The build protocol - TDD, the design pass, break it twice, the review round -
becomes a skill that fires when writing code, with the halt machinery replaced
by asking. `/implement-ticket` stays as the unattended wrapper that supplies
the halts, which is already its stated job.

Put the deterministic checks in hooks rather than in the skill's prose: the
project's check command, and a refusal to commit on a red suite.

### 4. Retire `/discovery`

Delete the skill, `SPEC_FORMAT.md`, `ADR_FORMAT.md` and
`UBIQUITOUS_LANGUAGE_FORMAT.md` once whatever they hold that survives has moved.
Rewrite the README's pipeline section around one door. Not before step 2 has
been proved on a real feature.

## Decisions made, for veto

- **The normal path runs one adversarial code review in a fresh context, not
  two reviews.** The quality review asks whether the right thing was built -
  with the user present and reading the diff, that is what they are doing. The
  code review catches what a reader skims past, and **fresh context is the
  property that makes it worth anything**: a builder that has just spent a
  context window convincing itself the design is right cannot see past its own
  path-dependency, and no prompt undoes that. A different model is a second,
  narrower effect - it catches a model's systematic habits - and it is not what
  the review rests on. The repo already relies on freshness alone twice, in
  `/to-solution`'s cold re-derivation and `/spec-to-tickets`' falsification
  reviewer, neither of which requires a different model. Unattended keeps both
  reviews (`implement/SKILL.md:161`). *Rejected: dropping both, which gives up
  the only read of the diff that is not path-dependent on having written it.*
- **`/to-solution` always emits `D-n` with `_Overturnable on:_`, rather than
  only when the spec is headed for `loop.sh`.** The clause is cheap, and it
  documents what a default rests on even for a human reader. A mode switch
  would make the skill know its own downstream, which is the coupling this plan
  is removing. *Rejected: conditional emission.*
- **`tests/workflows/` and `IDEAS.md` are untouched.** The first is a test
  practice that stands alone - feature twelve keeping feature three green is
  worth having in either lane. The second is read by both lanes already.
- **`/discovery` retires rather than being trimmed**, per *the ones ruled out*.

## Scope

**Now:** steps 1 and 2, and the `Criteria` rename.

**Later:** step 3, then step 4. Both depend on step 2 having been proved.

**Not:** `find-solution`, `critique`, `coding-conventions`, `cleanup-repo`,
`repo-overview`, `upgrade-dependencies`, `handover`, `check-against-spec`,
`accept.sh`, `loop.sh`, `TICKET_FORMAT.md`. Also not the ratification tiers as
they apply to an unattended run - they are correct there.

## Verification

- **Step 1** - a `/to-solution` run on a code change produces a spec whose
  defaults each carry an `_Overturnable on:_` clause naming something checkable
  in the code, and whose domain section names the aggregate the change sits in.
- **Step 2** - the real test, and the one that decides the plan: take one
  feature already built through lane 1, re-run it through `/idea` →
  `/to-solution` → `/spec-to-tickets`, and compare the ticket set against the
  one lane 1 produced. Same seams, same coverage, nothing a builder would have
  to guess. A worse set here stops the plan at step 2.
- **Step 3** - a small change built with the split protocol and no ticket,
  where the hooks fire and the single review produces a finding with a
  constructed trigger.
- **Step 4** - `grep -r discovery` over the repo returns nothing but history.

## Sequencing

1 → 2 → *stop and judge* → 3 → 4. Step 2's comparison is the gate; everything
after it is expensive to unwind and nothing before it is.

## Where this is most likely wrong

**Journeys.** `SPEC_FORMAT.md:58` journeys feed four things downstream, and two
of them survive this plan: the ratified ones become `tests/workflows/`, and
`/check-against-spec` drives the feature the way its user would. If
`/spec-to-tickets` turns out to need journeys to place seams, step 1 grows a
third port and step 2 gets harder. This is the most likely place the plan costs
more than it looks.

**The claim that a human present replaces the halts.** It is true for
ambiguity, which is a question. It is less obviously true for `drift` - a
codebase that contradicts the plan is something a present human may also skim
past, and the halt is what makes it unmissable. Step 3 should watch for this
rather than assume it.

**A consequence outside this plan's scope.** If fresh context rather than model
difference is what a review rests on, two things in the repo are argued on the
wrong axis and should be revisited separately: `implement/SKILL.md`'s *They are
a second opinion* bullet, and `loop.sh`'s refusal to start with `BUILD_MODEL`
and `REVIEW_MODEL` set to the same thing. The second is a hard refusal
defending a property that is not the load-bearing one. Neither is changed here.

**The split lane's premise.** The whole case for retiring `/discovery` rests on
the cold re-derivation being worth more than the continuity of one interview.
That is the README's claim, not a measured result, and step 2's comparison is
the first evidence either way.
