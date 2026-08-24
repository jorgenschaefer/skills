# Plan: ratify at the front, report at the back

The decided rework of the pipeline, extracted from `IDEAS.md` because it is
settled work rather than a candidate for it. `IDEAS.md` keeps what is still
being weighed; this file is what gets built, and it lands in one branch - steps
1 to 5 change what a spec says and steps 6 to 9 change what the loop does with
one, so a spec written before step 5 and built after step 8 is the case to
avoid.

## Why

The pipeline collects the user's judgment at the wrong end. `/discovery`
settles the feature; `/decision-brief` then ranks the decisions worth a veto and
is thrown away unwritten; a run builds for hours; `/handover` reconstructs a
second ranked list out of the tickets and asks the user to ratify choices made
in arguments they never saw. Both closing steps hand over a list after the
fact, out of context, with no live memory of the reasoning behind any item on
it. That is one defect, and it is why the human half of `/handover` - the
second, present invocation that actually accepts a run (`handover/SKILL.md`,
`## Accept`) - has never once been run.

This moves every ratification to the moment its decision is live, makes the
durable half executable instead of written, and leaves the run with a report
rather than a conversation. It deletes two skills and adds one.

## The shape

### Three tiers, ratified in flight

Every decision a feature forces lands in one of three tiers, and the tier fixes
who must agree and how long the answer lives.

- **Permanent.** Terms, architectural decisions, and the workflows the
  application must always support. These bind every future feature, so a wrong
  one is paid for by work nobody has scoped yet. Each gets an explicit *yes*,
  given in the conversation at the moment it is proposed - never batched into a
  closing block, which is `/decision-brief` rebuilt inside `/discovery`. What
  legitimately comes at the end is a five-line receipt naming what becomes
  permanent, because each yes was given without the others in view - and seeing
  the set together is allowed to change one. Reopening an item there is a normal
  move rather than a failure of the interview: it is the last cheap moment to
  make it, and a receipt nothing may be taken back at is ceremony.
- **Binding for this feature.** Stories, acceptance criteria, constraints,
  non-goals - what the spec carries today. Needs an *ok*; dies with the spec.
- **Defaults.** Sensible, waved through, and *marked* as defaults.

The third tier is the one the spec cannot express today. `SPEC_FORMAT.md`'s
marker points one way only: a decision that was the user's to make says so in
its `_Why:_` "so a later reader or reviewer knows it's settled, not open to
challenge". A spec can promote something to binding and cannot demote anything,
so the force is uniform. `/implement` reads "where the two seem to differ the
spec wins", and the `Record` it writes is filtered to where the spec was
**silent** - the log itself has four triggers, but the one that reaches the user
does not. kh-finder therefore froze `lies_versorgungsuebersicht()` becoming
`lies_dokumentbestand()` - a naming call - at exactly the force of a business
rule, and an implementer holding a better name had two legal moves: obey, or
halt `blocked`.

A marked default gives it a third. The framing is what bounds the tier: a
default is not "we weren't sure", it is **decided without the evidence the
builder will have** - discovery settles with the codebase skimmed, the
implementer is the first party with it open. So a default is overturnable on
evidence found in the code, never on taste, and the cost of overturning one is a
`Record` -> `Decisions` entry rather than a halt.

Two things have to hold, or the tier is a licence rather than a third move.

**The overturn is checked, not merely instructed.** "On evidence, never on
taste" is the same self-discipline this plan refuses to trust in a reviewer
below, asked here of the one agent with no human present. The check is cheap
because the machinery is already there: `/implement`'s quality review runs first
and already reads the ticket, so hand it the ticket's marked defaults and have
it ask of each overturn whether the evidence cited is in the code. And an
overturn is only cheaper than a halt if somebody sees it, which is what the
stakes-marked `Record` entry further down is for.

**A default more than one ticket touches is not a default but a contract.**
Explicit because the failure is invisible by construction: without it, ticket 3
and ticket 9 each overturn it their own way, cold, and nothing notices. `/plan`
promotes it by marking it binding in the spec's own defaults list, before it
computes `spec_hash` - promotion changes the item's tier, not its carrier. Not
into a `Provides`: that surface is durable intent about behaviour a later ticket
consumes, `/plan` is told to keep it as small as it can, and an error-shape or
date-format convention pushed in there inflates exactly that surface and
manufactures a `drift` halt out of a decision nothing was ever built against.

### The journey is written down

`/discovery` identifies "the user journey (or journeys) and the tasks that
compose it", but only as a means to a story per task: `grep journey
discovery/SPEC_FORMAT.md` returns nothing. The journey is analysis, discarded
the way the domain story is - "the domain story is the analysis; the user story
is what you record". That was survivable while nothing downstream needed it.

It is not survivable now, because the permanent tier is journey-shaped. A
workflow test pins a journey, and `spec_hash` freezes a file with no journey in
it, so `/plan` would reconstruct from stories what the user actually ratified.
`SPEC_FORMAT.md` gains a `## Journeys` section, written by `/discovery`, and per
journey it carries four things:

- **The trigger** - when and why the user starts down this path. Nothing asks
  for this today, and it is the half of a journey that stories never imply.
- **The steps in sequence**, including where each terminal action puts the user
  down afterwards.
- **The domain effect** - which actors act on which work objects, and what
  events that raises.
- **The screens it passes through**, as a walk rather than a list.

A ratified workflow test then quotes its journey instead of deriving from it, so
what the user said yes to and what the test asserts are the same words.

Two entries from `IDEAS.md` are absorbed here, because both are the same
omission seen from different sides and both become load-bearing once a journey
has to be written down.

**The domain model is shown, not just recorded.** Discovery models actors, work
objects, entities, aggregates, actions and events thoroughly, and never puts the
model in front of the user as a proposal. The cause is a misfiling: "where an
aggregate boundary falls" sits in bucket 2 - decide it yourself, surface it for
a veto - alongside how to wrap a dependency. But a boundary "dictates what can
change together and what must stay consistent", which is a statement about what
the business will tolerate being briefly wrong, and that is bucket 3. Show the
domain stories the skill already traces internally, plus per aggregate what
changes together and the invariant the root holds, in its own turn rather than
buried in a ten-item assumption list. Foreground what can actually be vetoed:
these two things are one thing, X may lag Y, that is not what we call it, you
have missed an actor. Entity-versus-value-object is not something to put in
front of a user. Show it after the journey is understood and before criteria
harden - the model changes which criteria are needed, so a later showing is a
rubber stamp. Work objects stop being a conditional section and become what was
ratified.

**The mockup binds to the journey, not to one open decision.** `Show, don't
tell` fires "when a UI decision is genuinely open" - per decision, never per
journey - so it can produce a component or two layouts side by side and
structurally cannot produce screen 1 to screen 5. On a project with an
established design language most screen decisions resolve into bucket 1, the
codebase answers it, and nothing is shown at all. That is correct for a
component and wrong for a flow: **the codebase can answer what a button looks
like; it can never answer where the user goes next.** The everlast spec gave a
twelve-story, multi-screen product 13 lines of Design and said nowhere what
happens to a reader after a deletion; three of its sixteen review-filed tickets
were that one question. A transition between two screens owned by two tickets is
owned by neither, and `/implement` builds each ticket cold. Same disposal
policy - the mockup is a communication device, kept only where the visual is the
record.

This does not move `## Design` back into `/discovery`. The journey says where
the user goes and what that means in the domain; the design says what the screen
is made of. The first is the what, the second is the how, and the seam holds.

### Permanent means executable

The permanent tier has three kinds and each needs its own answer to drift.
Terminology is a dictionary and has the glossary. Architectural decisions are a
dated log, appended and superseded rather than edited, and have ADRs. Functional
requirements are the hard one: a maintained prose list of what the system does
is the living capability spec `IDEAS.md` rejects, on the grounds that stale
specs are worse than none.

So they are executable. A ratified workflow ships as a **workflow test** under
`tests/workflows/`, named for the journey in the user's language: the test is
the record, and there is no companion document to go stale.

What that buys is drift resistance, and the claim stops there. A test cannot go
quietly stale, because the suite fails the moment the system stops doing what it
asserts - which is the whole reason the executable form beats a maintained prose
list. It can still pin the wrong thing just as silently as prose can lie: what
the user ratified is the `## Journeys` entry, and what runs is a test one
implementer wrote from it, joined to it by quoting rather than paraphrase - a
prose discipline holding an executable record in place.
Closing that gap is what `IDEAS.md` #8 is for, and this does not close it.

They are rare by construction. `/discovery` already separates the journey from
the tasks that compose it, so the bar writes itself: **a workflow test pins a
journey; per-task criteria stay in the spec as ordinary tests.** Most features
extend an existing journey and ratify none, and the skill has to say so or every
feature will invent one to feel thorough. What the ticket builds from is the
`## Journeys` entry above, quoted rather than paraphrased - precise enough to
become a test in a ticket nobody discusses.

The second effect is larger than the record-keeping. The workflow suite runs in
the project's check command, so feature 12's run keeps feature 3's journeys
green at every ticket. The green suite already guards a shipped feature's
tests - `/implement` runs the check command before its reviews - but nothing
holds a *ratified, journey-level* record that a later feature may not quietly
redefine: `/trace` checks the current spec and `/critique` is spec-blind, so a
journey nobody wrote a test for in feature 3 is nobody's business in feature 12.
Where a project's workflow suite is too slow to run at every ticket, the
fallback is the run's final gate - a per-project call worth stating rather than
leaving implied, and worth stating on honest terms: it does not defer the
at-every-ticket property, it gives it up. What is left is what the end-of-run
checks already do. The thing traded away is the halt landing on the ticket that
caused the regression instead of ten tickets later.

Consent to change one is granted before the loop starts. `/discovery` reads the
existing workflow tests, and a feature that alters a journey ratifies **that
alteration** as a permanent-tier item - as does one that retires a journey
outright, which is the same permanence being spent and needs the same yes.
`/plan` writes the authorisation into exactly one ticket. `loop.sh` halts any
ticket whose diff touches the directory without it - strict, so an unattended
agent can never quietly edit the definition of correct.

Two things make that strictness affordable.

**The rename cost moves to planning time.** The discipline that keeps a workflow
test out of the implementation's way is to assert where nothing moves - the
public API, or the text a user reads - and that is precisely what a later
feature renames. Left alone, one rename in feature 20 trips a dozen guards, each
hours into an unattended run, each costing a human round trip for a mechanical
edit. `/plan` already reads the codebase and now reads the workflow tests too,
so it can see which of them a ticket's work reaches and pre-write the
authorisation into that ticket, mechanical renames included. The guard stays
strict; what changes is that the expensive halts are anticipated rather than
discovered.

**The halt has a defined recovery**, because this is the pipeline's first
driver-initiated halt and its first post-commit one. Every halt today is the
implementer's, taken before it commits, leaving partial work in the tree. Here
the ticket is committed by the time the driver reads the diff, so the driver
sets `status: blocked` and appends a fixed `## Halt` block naming the reason,
the commit sha and the paths touched - mechanical text, no judgement, which is
all a bash driver should be writing. It stops with the commit intact; reverting
is the human's call, since the rest of the ticket may be fine. Without the mark
the ticket stays `done` and the next run walks straight past it. The documented
resolution is to add the authorisation to the ticket and re-run, not to
re-plan.

### The what and the how, one spec

`/discovery` keeps the what - problem, journeys, stories, criteria, domain,
constraints. A new `/solution` takes the how - design, ADRs, implementation
decisions. `SPEC_FORMAT.md` already carries the seam, so this is two skills and
one artifact: discovery writes through `## User Stories`, solution appends
`## Design` and `## Implementation decisions` to the same file, and there is one
`spec_hash`, one thing to delete. (README's "two front doors" already names
`/discovery` and `/propose-change`; this is a split inside one of them, and the
README has to keep that phrase for the lanes.)

Four things pay for the split. **Authority**: the what is the user's call, the
how is the agent's with a veto, and today they switch roles inside one
interview. **Reading**: solution needs `coding-conventions` and the ADRs,
discovery needs the glossary and the workflow tests - which is how the standard
finally reaches the step that settles the design language, the data shapes and
the aggregate boundaries, having bound only the builder and the reviewer until
now. **Context**: each half loads what it uses. **Restartability**: a wrong
design is re-run against settled requirements instead of re-entering one
enormous interview - cheap up to the moment `/plan` freezes the spec, after
which re-running `/solution` rewrites the file its hash was taken over and every
ticket halts `stale-spec`. Past that point the cheap move is `/plan --refresh`,
and saying so keeps the benefit from being claimed where it no longer holds.

`/solution` ratifies in flight like everything else. Its tier-2 calls surface
for a veto as they are decided, never collected into a closing block - a design
handed over whole at the end is `/decision-brief` one altitude down, and it
would be strange to delete that skill and rebuild it inside the new one. Its
permanent-tier items - an ADR, a unification with architectural consequence -
each get their own yes in the conversation.

Which means the seam is about subject matter, not about who decides. Discovery
owns the what and solution the how; both halves contain decisions of both
authorities, and ADRs are where that is most obvious - permanent-tier, the
user's yes, argued inside the agent's half. "The what is the user's call, the
how is the agent's" says where the weight sits, not who may speak.

The gate is not one-way, because problem and solution co-evolve. `/solution`
will sometimes find a ratified requirement infeasible or absurdly priced, and
sending it back is a named legal move rather than something to quietly design
around. `/discovery` stays feasibility-aware - it skims the code, it just does
not settle the how, and it must not promise what the code makes impossible.

Not folded into `/plan` instead, which is the tempting two-step version:
`/plan`'s value is that it audits the spec cold and sends an oversized one back,
and no step can adversarially review a design it just argued for.

### `/solution` surveys before it decides

Keeping prior solutions working is what the workflow tests are for. Unifying
similar approaches is nobody's job. `coding-conventions` carries "no
duplication" and "duplication is justified or removed", but as a rubric
`/critique` applies to a diff - after the fact, on the code this run wrote.
everlast found duplication once three copies existed and a vocabulary split
later still, which is what after-the-fact costs in a codebase that has had
twenty features through it.

So `/solution` opens with a survey rather than a design: what already exists
that resembles what this feature needs, module by module, and for each one
whether the new work reuses it, extends it, absorbs it, replaces it, or
deliberately sits beside it - with the reason. That goes into `Implementation
decisions`, and the list of affected modules falls out of the same pass, which
nothing asks for today either.

Bound it, or it becomes a licence to rewrite the codebase on a feature's budget:
the survey decides what *this feature* touches. An `absorb` or a `replace` no
criterion requires goes to `IDEAS.md` like any other parked scope; one that is
required is architecturally consequential by construction and gets an ADR and a
yes, like any other permanent-tier item.

Two mechanics, because prose alone would not hold this. Every verdict is
recorded in `Implementation decisions`, the ones that reuse and sit beside
included - otherwise `/trace`'s orphan sweep meets absorbed work, finds it
traces to no criterion, and files a ticket to remove what `/solution`
deliberately decided, the plan's own sweep fighting the plan's own survey. And a
verdict reached with the codebase surveyed rather than open is, by the
definition three sections up, a **default**: mark it as one, so an implementer
who finds the absorption worse than it looked overturns it on the evidence
instead of choosing between obeying and halting.

### ADRs get a source and a reader

`grep -rln ADR --include=SKILL.md` returns one file today, and it is the one
being deleted. Handover was the right *moment* to write an ADR - the acceptance
moment, the user present - and the wrong *place*: three steps downstream of
where the alternatives were argued, with everything in between deleted on
purpose. The rejected alternative, which is the reason ADRs exist at all, was
gone by the time anything asked for one. `/solution` is where the alternatives
are live.

The other half is that nothing has ever read one. `/discovery`, `/solution` and
`/plan` read the ADRs the way discovery already reads `UBIQUITOUS_LANGUAGE.md`,
and `/critique` treats contradicting a ratified ADR as a finding. Without the
reader, feature 12 contradicts a decision ratified at feature 3 and nothing
notices - the exact failure ADRs exist to prevent - and an explicit ratification
has been spent on a write-only file. Needs a location convention and a short
`ADR_FORMAT.md`. Never written autonomously: an ADR is a permanent-tier item and
gets its own yes.

### Reviews stop finding requirements

everlast's ticket 25 built an owner-filter scanner; 27 found it blind to
`$executeRaw`; 29 found it blind to a nested `deleteMany:`. All three open by
stating that no user is exposed and the module is correct as it stands. Each was
filed by whichever reviewer had not filed the last, each overturns the previous
ticket's `Unresolved` adjudication, the last three critique passes read a
**test-only** diff, and ticket 29 is still `todo`.

Read that as what it is before generalising from it. It is not three security
findings; it is one finding relitigated twice, by a second and a third agent,
against an adjudication the first ticket had already made with nobody present.
The engine is the reopening, so the reopening is what to shut off. A rule that
instead barred reviews from filing anything the spec does not name would shut
off the findings the pipeline exists for: `coding-conventions` says of its
entire security section that these properties "hold even when the spec doesn't
name them". A missing object-level authorization check, an id interpolated into
SQL, a guard a scanner cannot see: these trace to no criterion by construction,
and they are the findings that most deserve a ticket. Sending them to `IDEAS.md`
would buy a bounded loop by giving up what the loop is for.

So the bar is three conjuncts, and a finding is work only when all three hold.

- **A constructed trigger.** It names the concrete input or state that drives
  the code to a wrong result, a crash, or a breach. This is
  `critique/SKILL.md`'s existing rule rather than a new one - it already drops
  what nobody can construct, and it deliberately does not require the trigger to
  sit on a happy path. Whoever reaches it need not be the end user: an
  authorization gap behind a flag is reachable by whoever holds the flag, and
  that is a trigger.
- **A destination.** It traces to a numbered criterion, a constraint or a
  workflow, or to one of `coding-conventions`' security and data-loss
  properties, which bind unstated. Anything else is a new requirement, and new
  requirements go to `IDEAS.md`, never to a ticket. The line that matters is
  pinning a stated requirement versus hardening a guard - "no test-only ticket"
  would forbid trace's whole job, which is finding a criterion no test pins.
- **No reopening.** A finding that overturns a prior ticket's `Unresolved`
  adjudication on the same code may not be filed at all; it makes the run
  **requires human review** instead. The adjudication was made with no human
  present and a second agent now disagrees with it, which is an argument to put
  in front of a person rather than a third opinion to build. This conjunct alone
  stops 27 and 29.

Two further bars, and each has to bind or the engine simply moves.

- **A surviving mutant is a gap only on code implementing one of those.**
  Mutants are not a finite set, so trace inherits the regress otherwise -
  25/27/29 were mutation-shaped hardening of a scanner nobody could reach.
- **`/implement`'s own quality and code reviews take the same bar.** The
  evidence is cross-ticket, but the same unbounded taste runs inside every
  ticket and can inflate it there instead.

Two carve-outs, or the trade is a regress for a lie. A comment that states
something false is a defect about the code and keeps its severity, since tickets
are deleted at acceptance and the comment outlives them. And **coverage that
existed before the run and does not exist after it is work**, even though it
traces to no criterion in this spec: the criterion it pinned belongs to a
deleted spec, so the trace-to-a-criterion half of the bar cannot see it. Without
this the bar forbids the everlast 26/28 finding outright.

Severity gets the same treatment, because "assign it by what happens if nobody
fixes this" is what priced hypotheticals as defects. A **blocker** is a wrong
result, a crash, a loss or a breach with a trigger somebody constructed - the
input or the state, named. Not what this could become if left; not, either, "no
user is exposed", which is a claim about who is currently looking rather than
about whether the defect is there.

`/critique` also leaves the pass loop. It read the whole diff on pass 1 and a
test-only diff on passes 2 and 3 because it re-ran after every trace pass;
instead it runs once over the run's whole diff, after the last drain. What it
files then drains, and it re-reads only those commits - the narrowing `loop.sh`
already does with `CHECKED_AT`.

The bars shrink what a pass can produce; they do not close it. Trace still
regresses inside its own bar - a remediation ticket produces code, and the next
pass can find a different criterion unpinned in that code - so `MAX_PASSES=2`
stays the backstop rather than becoming decoration. What this plan does not
touch is the hole `IDEAS.md` already names: re-running `loop.sh` resets both the
pass count and `CHECKED_AT`, which is how everlast routed around the ceiling
five times. That stays open.

### The run reports, and a clean run's report is the deletion commit

`/handover` goes. Its promotion job moved upstream, and what is left is what the
implementers settled where nothing had settled it - which cannot move upstream,
because it does not exist until the run happens. Most of that is overturned
defaults, and those want reporting rather than ranking. `Unresolved` is the
exception and does not belong in the same sentence: a review raised it and the
implementer argued it down with nobody present, which is not a default being
overturned but an adjudication nobody has checked.

**The report is produced on every terminal path.** `/critique`'s review, plus
every ticket's `Record` -> `Decisions` and `Unresolved` entries, collected
mechanically. A run that ends *requires human review* or *halted* is the run
whose reader most needs one, and tying the report to the clean path hands them
nothing; there the driver prints it and deletes nothing, the way `loop.sh`
prints handover whole today. The spec and the tickets stay, because they are the
input to whatever happens next.

**On a clean run that same report is the message of the deletion commit** - one
commit that deletes the spec and the `tickets/` directory and carries the
report. That answers three things at once. The paper never reaches the default
branch, which merging alone would not achieve - a merge brings added files with
it, squash or not, so "acceptance is the merge" only works if something deleted
them first. The report is durable without being a file to clean up later, and
`loop.sh`'s "leave no paper behind in the working tree" holds. And a grep cannot
disagree with the review it summarises, which a second derivation at 7am could
and would.

**The stakes are marked when the entry is written, not derived when it is
read.** Forty entries in a flat list is a list nobody reads to the end, which is
how the one that mattered gets missed - the failure a closing ranked brief was
invented for and died of, and re-proposing that brief as "but shorter" is the
same shape. The way out is this plan's own principle applied to reporting:
`/implement` marks each `Decisions` and `Unresolved` entry with its stakes at
the moment it writes it, while the reasoning is live, and the driver's grep
sorts on a field. Nothing is derived at the end, nothing can disagree with the
review, and no step has been added.

Acceptance is then the merge, with nothing to run first. A rejected run is the
same commit not made: the tickets stay, and they are the input to the next run.

`/critique` closes with a fixed verdict line - blockers, should-fixes, nits - so
the driver reads the count without spending a second agent on the first one's
prose. Blockers make the run **requires human review**, which gives it three
terminal states rather than two: **clean**, **requires human review**,
**halted**. "Finished" today means only that nothing stopped it.

*Requires human review* needs a way back, or the hand-fix lands behind every
check the run performed - the failure the loop exists to prevent, arriving as
the standard path. It is machinery that already exists: the human resolves the
standing blockers, then re-runs `loop.sh`, which drains whatever that produced,
re-traces, re-critiques over the new commits, and makes the deletion commit if
it comes back clean. Nothing about acceptance is hand-made.

One invariant falls out and is worth stating outright: **the run has no
promotion step because the run has no authority to create permanent records.**
A ticket that hits an architectural fork the spec does not cover halts
`blocked`, which is already the contract.

### The small lane gets the same discipline

`/propose-change` runs with the user present, so it can ratify a permanent-tier
item itself - a term, an ADR, a workflow change - which is the promotion step
that lane never had. It had none because promotion happened at the end of a
feature run and the small lane has no end; now it happens where the user is.
Tier 2 is the ticket's stated behaviour, tier 3 defaults are marked so
`/implement` can overturn them on evidence, and the workflow guard applies
unchanged: a bugfix touching `tests/workflows/` needs the same explicit yes a
feature would.

## Sequence

**0. Pin the machinery step 8 rewrites.** `tests/run.sh` covers a clean run,
rate limits, retries, unreachable queues, the ticket directory, `REVIEWS=code`
and handover's printing - and nothing else. No fixture files a ticket, so the
re-drain (`loop.sh:455-460`), `CHECKED_AT` narrowing the second pass
(`:414-432`) and the non-convergence exit (`:463-466`) are untested, and those
are exactly what step 8 rewrites. Write the fixture and those three cases
against today's behaviour first, so the rewrite has a baseline that fails when
it breaks something.

**1. `discovery/SPEC_FORMAT.md`** - the tier markers, the defaults list beside
Implementation decisions, the new `## Journeys` section, and the seam:
everything through `## User Stories` belongs to `/discovery`, `## Design` and
`## Implementation decisions` to `/solution`.

**2. `ADR_FORMAT.md` and the location convention**, plus the reader line in
discovery, solution, plan and critique.

**3. `discovery/SKILL.md`** - cut to the what; ratification in flight and the
closing receipt, which an item may be reopened at; reads the existing workflow
tests and the ADRs, so altering or retiring a journey is ratified as the
permanent-tier item it is; writes the journeys, shows the domain model in its
own turn, and binds `Show, don't tell` to the journey rather than to one open
decision; the `/decision-brief` close goes.

**4. `solution/SKILL.md`** - new; the survey first, then the how; every survey
verdict recorded in `Implementation decisions` and the ones reached without the
code open marked as defaults; ratification in flight, tier-2 calls surfaced for
veto as they are decided and each permanent-tier item given its own yes; reads
`coding-conventions` and the ADRs; may send requirements back.

**5. `plan/SKILL.md`** - the workflow-test ticket ordered last, the multi-ticket
default marked binding in the spec's defaults list before `spec_hash` is
computed, the ratified alteration's authorisation written into exactly one
ticket, the workflow tests read so that authorisation is pre-written into any
other ticket whose work reaches one, and the `## Hand off` close on
`/decision-brief` goes. Ordering the workflow test last cuts against plan's own
uncertainty-first rule and has to say why it is not an exception to it: the
ticket carries no uncertainty - its content was ratified before the run - only a
dependency on every ticket before it, since a journey test cannot pass until the
journey exists.

**6. The bars.** `critique/SKILL.md` - the three conjuncts, the
constructed-trigger severity rule, and the verdict line; the paragraph handing a
caller `TICKET_FORMAT.md` for findings written up as work orders stays, because
critique still files. `trace/SKILL.md` - the mutant bar and the
pre-existing-coverage carve-out. `implement/SKILL.md` - the same bar inside the
ticket, the marked default it may overturn and the evidence its quality review
holds that overturn to, and the stakes mark on every `Decisions` and
`Unresolved` entry.

**7. The ticket format and the skills that name the deleted steps.** All five
`TICKET_FORMAT.md` copies say `Decisions` "is what the handover brief aggregates
at the end of a run"; it now feeds the run's report, and each entry carries the
stakes its writer marked. All five stay - critique still files, so its copy is
still the shape it files in, and the byte-identical parity `IDEAS.md` keeps
deliberately is unbroken. Also `plan/SKILL.md` ("their `Record` sections feed
the handover"), `trace/SKILL.md` ("for the human to ratify at handover", "goes
to handover as a finding") and `propose-change/SKILL.md` ("No decision brief
here.").

**8. `loop.sh`** - the workflow-test guard on every ticket's diff, and with it
the `status: blocked` mark and fixed `## Halt` block the driver writes when the
guard fires; critique moved out of the pass loop to one whole-diff run after the
last drain, narrowed by `CHECKED_AT` over what it files; the report emitted on
all three terminal paths and carried as the deletion commit's message on the
clean one, ordered by the stakes each entry was marked with; the three terminal
states and the re-run path out of *requires human review*; `MAX_PASSES` kept as
the backstop; the handover step and `BRIEF_FILTER` gone. The deletion commit's
subject follows `git-commit-message`; its body is a collected report and is not
held to those rules. `tests/run.sh` extended, written failing first as in step
0.

**9. Delete `handover/` and `decision-brief/`**; `propose-change/SKILL.md` gets
the tiers; `README.md` gets the new shape.

## Settled while writing

- **`tests/workflows/` is `loop.sh` config; the ADR directory is a fixed
  convention.** The guard forces the first: the driver enforces it and must
  therefore be told the path. The ADR path is only ever read by skills, which
  can look.

## Open at the time of writing

- What `/solution` does to `IDEAS.md`'s craft-versus-loop split. It is a new
  tier-1 skill and that entry's naming principle - tier 1 named for the
  activity, tier 2 for the artifact - would have an opinion about the name.
