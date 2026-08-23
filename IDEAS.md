# Ideas

Feature ideas for this repository, ordered by what each buys against what it
costs. The measure is the pipeline's own goal: correct, usable, high-quality,
maintainable software. An idea that buys wall clock or tidiness ranks below one
that closes a hole in what the pipeline can prove.

`/discovery` reads this file as its parking lot, so every entry says what
problem it solves, what it would touch, and what it costs.

## Two runs, cited throughout

Entries 5 to 7 and #1's review discipline argue from the same two runs, so the
accounting sits here once rather than four times.

`kh-finder` (`spec-dokumentbestand`) finished at 15 tickets: 4 planned, 11
filed by `/trace` and `/critique` during the run. `everlast-notebooklm`
(`notebooklm-mvp`, then `finalize`) finished at 29 and **has not converged**:
13 planned, 16 filed, ticket 29 still `todo`, five restarts across two branch
names, and the last three critique passes spent on a test-only diff.

Not all 27 late tickets are defects in the pipeline. Duplication found once
three copies existed, a vocabulary split, a suite poisoning its own database,
and a defect in a late fix caught by critique after trace are the yield the
reviews exist for. Entries 5 to 7, and the regress #1 claims, are the ones that
should not have got that far, and each names the tickets it claims.

Transcripts under `/tmp/loop-spec-dokumentbestand-*`,
`/tmp/loop-notebooklm-mvp-*` and `/tmp/loop-finalize-*`; the tickets themselves
under each project's `docs/tickets/`.

## 1. Ratify at the front, report at the back

The pipeline collects the user's judgment at the wrong end. `/discovery`
settles the feature; `/decision-brief` then ranks the decisions worth a veto and
is thrown away unwritten; a run builds for hours; `/handover` reconstructs a
second ranked list out of the tickets and asks the user to ratify choices made
in arguments they never saw. Both closing steps hand over a list after the fact,
out of context, with no live memory of the reasoning behind any item on it.
That is one defect, and it is why both are the steps nobody wants to run.

The rework moves every ratification to the moment its decision is live, makes
the durable half executable instead of written, and leaves the run with a report
rather than a conversation. It deletes two skills and adds one.

### Three tiers, ratified in flight

Every decision a feature forces lands in one of three tiers, and the tier fixes
who must agree and how long the answer lives.

- **Permanent.** Terms, architectural decisions, and the workflows the
  application must always support. These bind every future feature, so a wrong
  one is paid for by work nobody has scoped yet. Each gets an explicit *yes*,
  given in the conversation at the moment it is proposed - never batched into a
  closing block, which is `/decision-brief` rebuilt inside `/discovery`. What
  legitimately comes at the end is a five-line receipt naming what becomes
  permanent, because each yes was given without the others in view.
- **Binding for this feature.** Stories, acceptance criteria, constraints,
  non-goals - what the spec carries today. Needs an *ok*; dies with the spec.
- **Defaults.** Sensible, waved through, and *marked* as defaults.

The third tier is the one the spec cannot express today. SPEC_FORMAT's marker
points one way only: a decision that was the user's to make says so in its
`_Why:_` "so a later reader or reviewer knows it's settled, not open to
challenge". A spec can promote something to binding and cannot demote anything,
so the force is uniform. `/implement` reads "where the two seem to differ the
spec wins", and its decision log fires only where the spec was **silent**.
kh-finder therefore froze `lies_versorgungsuebersicht()` becoming
`lies_dokumentbestand()` - a naming call - at exactly the force of a business
rule, and an implementer holding a better name had two legal moves: obey, or
halt `blocked`.

A marked default gives it a third. The framing is what bounds the tier: a
default is not "we weren't sure", it is **decided without the evidence the
builder will have** - discovery settles with the codebase skimmed, the
implementer is the first party with it open. So a default is overturnable on
evidence found in the code, never on taste, and the cost of overturning one is a
`Record` -> `Decisions` entry rather than a halt. One guard, explicit because
the failure is invisible by construction: **a default more than one ticket
touches is not a default but a contract**, and `/plan` promotes it into a
`Provides`. Without that, ticket 3 and ticket 9 each overturn it their own way,
cold, and nothing notices.

### Permanent means executable

The permanent tier has three kinds and each needs its own answer to drift.
Terminology is a dictionary and has the glossary. Architectural decisions are a
dated log, appended and superseded rather than edited, and have ADRs. Functional
requirements are the hard one: a maintained prose list of what the system does
is the living capability spec this file rejects in *Rejected* below, on the
grounds that stale specs are worse than none.

So they are executable. A ratified workflow ships as a **workflow test** under
`tests/workflows/`, named for the journey in the user's language: the test is
the record, and there is no companion document to go stale. Prose can lie
silently; a test cannot.

They are rare by construction. `/discovery` already separates the journey from
the tasks that compose it, so the bar writes itself: **a workflow test pins a
journey; per-task criteria stay in the spec as ordinary tests.** Most features
extend an existing journey and ratify none, and the skill has to say so or every
feature will invent one to feel thorough. A ratified workflow is written out as
its steps and its observable outcome, not as a title - it has to be precise
enough to become a test in a ticket nobody discusses.

The second effect is larger than the record-keeping. The workflow suite runs in
the project's check command, so feature 12's run keeps feature 3's journeys
green at every ticket. Nothing protects a shipped feature during the next one
today: `/trace` checks the current spec and `/critique` is spec-blind. Where a
project's workflow suite is too slow to run at every ticket, the fallback is the
run's final gate - regressions still caught, just at the end of the run rather
than at the ticket that caused them - and that is a per-project call worth
stating rather than leaving implied.

Consent to change one is granted before the loop starts. `/discovery` reads the
existing workflow tests, and a feature that alters a journey ratifies **that
alteration** as a permanent-tier item; `/plan` writes the authorisation into
exactly one ticket. `loop.sh` halts any ticket whose diff touches the directory
without it - strict, so an unattended agent can never quietly edit the
definition of correct. The cost is a halt when a workflow test was written close
enough to the implementation that a rename reaches it, which is the signal that
it was written at the wrong seam. The discipline that keeps it rare is to assert
where nothing moves: the public API, or the text a user reads.

### Two front doors, one spec

`/discovery` keeps the what - problem, journeys, stories, criteria, domain,
constraints. A new `/solution` takes the how - design, ADRs, implementation
decisions. `SPEC_FORMAT.md` already carries the seam, so this is two skills and
one artifact: discovery writes down to `## Domain`, solution appends `## Design`
and `## Implementation decisions` to the same file, and there is one
`spec_hash`, one thing to delete.

Four things pay for the split. **Authority**: the what is the user's call, the
how is the agent's with a veto, and today they switch roles inside one
interview. **Reading**: solution needs `coding-conventions` and the ADRs,
discovery needs the glossary and the workflow tests - which is how the standard
finally reaches the step that settles the design language, the data shapes and
the aggregate boundaries, having bound only the builder and the reviewer until
now. **Context**: each half loads what it uses. **Restartability**: a wrong
design is re-run against settled requirements instead of re-entering one
enormous interview.

The gate is not one-way, because problem and solution co-evolve. `/solution`
will sometimes find a ratified requirement infeasible or absurdly priced, and
sending it back is a named legal move rather than something to quietly design
around. `/discovery` stays feasibility-aware - it skims the code, it just does
not settle the how, and it must not promise what the code makes impossible.

Not folded into `/plan` instead, which is the tempting two-step version:
`/plan`'s value is that it audits the spec cold and sends an oversized one back,
and no step can adversarially review a design it just argued for.

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
`ADR_FORMAT.md`. Never written autonomously: an ADR is a permanent-tier item
and gets its own yes.

### Reviews stop finding requirements

everlast's ticket 25 built an owner-filter scanner; 27 found it blind to
`$executeRaw`; 29 found it blind to a nested `deleteMany:`. All three open by
stating that no user is exposed and the module is correct as it stands. Each was
filed by whichever reviewer had not filed the last, each overturns the previous
ticket's `Unresolved` adjudication, the last three critique passes read a
**test-only** diff, and ticket 29 is still `todo`.

The fix is structural rather than a severity rule, because every reviewer can
rationalise its own finding as correctness. **Only `/trace` may add work.** It
checks against the spec, so its output is bounded by a finite and shrinking set
- criteria nothing pins. `/critique` has no spec, so its output is bounded by
taste, and taste does not run out. It returns a review to its caller, which is
what the skill already says it does; the ticket-filing lives in
`loop.sh:critique_prompt()` and comes out. That also bounds the passes by
construction, so `MAX_PASSES=2` stops being the thing holding the loop shut.

Three bars follow, and each has to bind or the engine simply moves.

- **A finding is work only if it names a wrong behaviour reachable today with
  concrete inputs, and traces to a numbered criterion, a constraint, or a
  workflow.** A finding that traces to nothing in the spec is a new requirement,
  and new requirements come to this file, never to a ticket. The line that
  matters is pinning a stated requirement versus hardening a guard - "no
  test-only ticket" would forbid trace's whole job, which is finding a criterion
  no test pins.
- **A surviving mutant is a gap only on code implementing one of those.**
  Mutants are not a finite set, so trace inherits the regress otherwise -
  25/27/29 were mutation-shaped hardening of a scanner nobody could reach.
- **`/implement`'s own quality and code reviews take the same bar.** The
  evidence is cross-ticket, but the same unbounded taste runs inside every
  ticket and can inflate it there instead.

One carve-out survives, or the trade is a regress for a lie: a comment that
states something false is a defect about the code and keeps its severity, since
tickets are deleted at acceptance and the comment outlives them.

`/critique` also leaves the pass loop. It read the whole diff on pass 1 and a
test-only diff on passes 2 and 3; with nothing to file, it belongs once, over
the run's whole diff, at the end.

### The run reports, and the report has a home

`/handover` goes. Its promotion job moved upstream, and what is left is the
spec-silent calls the implementers made - which cannot move upstream, because
they do not exist until the run happens. Under the tiers those are all
overturned defaults, so they want reporting, not ranking: `loop.sh` collects
each ticket's `Record` -> `Decisions` and `Unresolved` entries mechanically,
beside `/critique`'s review, and writes the lot next to the spec, committed like
the tickets and gone at the merge. A grep cannot disagree with the review it
summarises, which a second derivation at 7am could and would.

That the report is a *file* is the point. We criticise handover for surviving
only as a `$TMPDIR` JSONL; terminal output from a run nobody watched is the same
defect with fewer steps.

`/critique` closes with a fixed verdict line - blockers, should-fixes, nits - so
the driver reads the count without spending a second agent on the first one's
prose, and cannot disagree with it. Blockers make the run **requires human
review**, which gives it three terminal states rather than two: **clean**,
**requires human review**, **halted**. "Finished" today means only that nothing
stopped it. Under the reachable-today bar, blocker means a user-visible wrong
behaviour reachable today - not "what happens if nobody fixes this", which is
what priced hypotheticals as defects.

Acceptance is the merge. The spec, the tickets and the report live on the
feature branch; merging drops them and history keeps them, so nothing needs a
deletion step and no skill needs the user's authority to run it.

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

### Edit sequence

1. `discovery/SPEC_FORMAT.md` - the tier markers, the defaults list beside
   Implementation decisions, the seam between the two front doors.
2. `ADR_FORMAT.md` and the location convention, plus the reader line in
   discovery, solution, plan and critique.
3. `discovery/SKILL.md` - cut to the what; ratification in flight and the
   closing receipt; reads the existing workflow tests and the ADRs; the
   `/decision-brief` close goes.
4. `solution/SKILL.md` - new; the how; reads `coding-conventions` and the ADRs;
   may send requirements back.
5. `plan/SKILL.md` - the workflow-test ticket ordered last, the multi-ticket
   default promoted to a `Provides`, the workflow authorisation written into
   the one ticket that carries it.
6. The bars: `critique/SKILL.md` (reachable-today, the verdict line),
   `trace/SKILL.md` (the mutant bar), `implement/SKILL.md` (the same bar inside
   the ticket, and the marked default it may overturn).
7. `loop.sh` - the workflow guard, critique out of the pass loop and filing
   nothing, the report file, the three terminal states, the handover step gone.
   `tests/run.sh` first, since the driver's tests are written failing.
8. Delete `handover/` and `decision-brief/`; `propose-change/SKILL.md` gets the
   tiers; README.md gets the new shape.

Steps 1 to 5 change what a spec says and steps 6 to 8 change what the loop does
with one, so a spec written before step 5 and built after step 7 is the case to
avoid: land it in one branch rather than shipping the front door and the driver
separately.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md, a new solution/SKILL.md,
a new ADR_FORMAT.md, plan/SKILL.md, critique/SKILL.md, trace/SKILL.md,
implement/SKILL.md, propose-change/SKILL.md, loop.sh, tests/run.sh, README.md,
and the deletion of handover/ and decision-brief/.

## 2. Make the skills fire

Two of sixteen skills still have one problem: the skill does not fire, and a
skill that does not fire is worth zero however good its contents.

- `/critique` competes with the built-in code-review skill and loses by
  default. The only one left that a `description` can fix, and the reason
  critique stayed model-invoked while the rest of the loop's skills did not.
- `upgrade-dependencies` is user-invoked and nothing routes maintenance work
  to it, so it is never reached. That is #14's missing lane, not a trigger
  problem - a better `description` would not help, because nobody is looking
  for it.

`/plan` and `/implement` were on this list and came off it by the opposite
move. Both are user-invoked now, with `/trace`: the loop
drives all three by typed name, so the model-reach they paid context for was
never used. `/implement` no longer wants a broader trigger because it has
none, and `/plan` can no longer be autonomously confused with the harness's
plan mode.

What survives of the `/plan` collision is the naming question for the human
who types it, and the rename cost if the answer is yes: `/plan` is named in
README.md, discovery/SKILL.md, implement/SKILL.md, propose-change/SKILL.md,
solution/SKILL.md, SPEC_FORMAT.md and all five copies of
TICKET_FORMAT.md. #18 carries that question now: the rename is one part of
splitting the craft tier from the loop tier, and paying the cost twice would
be the waste.

## 3. Show the user the domain model

Discovery models the domain thoroughly - actors, work objects, entities,
aggregates, actions, events - and then says outright that "the domain story is
the analysis; the user story is what you record". The model reaches the spec's
Domain section, but it is never put in front of the user as a proposal during
the interview.

The cause is a misfiling. Discovery's three-bucket sort names "where an
aggregate boundary falls" in bucket 2 - decide it yourself, surface it for a
veto - alongside how to wrap a dependency and where a seam sits. So by the
skill's own rules the user is never asked; they are told, inside a bundled
"I'm assuming X and Y unless you say otherwise" turn built to be skimmed. It is
misfiled by the skill's own definition: the boundary "dictates what can change
together and what must stay consistent", which is a statement about what the
business will tolerate being briefly wrong, and bucket 3 is exactly "a business
rule the code cannot imply". A third gate closes behind those two -
SPEC_FORMAT's Work objects are included "only when identity, boundary, or an
invariant is non-obvious enough that a wrong default would hurt", so the model
can legitimately be omitted whole.

**Shown, not asked** - settled. What kills a proposal is collapsing it back
into the ten-default list, since one bullet among ten is buried rather than
shown. The rule that saves it already exists and is never invoked here:
confirming assumptions "gets its own turn, never mixed with a question".

Show the domain stories the skill already traces internally - this actor does
this action on this work object, which raises this event - plus, per aggregate,
what changes together and the invariant the root holds. That is nearly free,
being work already done rather than a new step. Foreground what can actually be
vetoed: these two things are one thing, X may lag Y, that is not what we call
it, you have missed an actor. Entity-versus-value-object is not something to put
in front of a user. Prose or a small table by default; a diagram only where the
relations are dense enough that prose fails, on the same reasoning that gates
the HTML mockup. Show it after the journey is understood and before criteria
harden - the model changes which criteria are needed, so a later showing is a
rubber stamp.

Two consequences. Work objects stop being conditional and become "what was
ratified". And the durable half splits: vocabulary has the glossary, but a
**consistency boundary has no home** and dies with the deleted spec, though it
outlives the run and is exactly what #1's ADRs are for.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.

## 4. Mock the journey, not the decision

`Show, don't tell` fires on "when a UI **decision** is genuinely open" - per
decision, never per journey. So it produces a component, or two layouts side by
side, and structurally cannot produce screen 1 to screen 5. The mockup is then
disposable and scoped to that one decision, so nothing accumulates into a flow.
SPEC_FORMAT matches it: Design is "for each screen: layout and components,
states" - a list of screens with nothing between them.

That also explains why mockups appear only sometimes. On a project with an
established design language most screen decisions resolve into bucket 1, the
codebase answers it, and nothing is shown at all. Correct for a component and
wrong for a flow: **the codebase can answer what a button looks like; it can
never answer where the user goes next.**

Evidenced. The everlast spec gives a twelve-story, multi-screen product 13 lines
of Design and says nowhere what happens to a reader after a deletion. Three of
its sixteen review-filed tickets are that one question - 20 "pin where a reader
is put down after a removal", 22 "keep a walked-away deletion from moving its
reader", 23 "name a notebook's own page in one place". Structural rather than
bad luck: a transition between two screens owned by two tickets is owned by
neither, and `/implement` builds each ticket cold. Flow is what per-ticket
construction is least able to see and what the spec records least.

Bind the mockup to the journey instead - the screens in sequence, including
where each terminal action puts the reader down - and let the Design section
carry the walk rather than only the stops. Same disposal policy; the deletion
rule is unchanged. It is also the honest source of the `Depends on` notes
`/plan` already asks for.

Ranks above the four that follow because a whole class of requirement is here
not merely unproven but unstated, and no discipline downstream closes a hole in
what the spec never said - #5 to #7 all assume the criterion exists.

Touches: discovery/SKILL.md (`Show, don't tell`, Process),
discovery/SPEC_FORMAT.md (Design).

## 5. Pin what the ticket claims, and notice when a pin leaves

The pipeline's central claim is that every criterion is met *and* pinned by a
test that would fail without it. Four mechanisms let one through unpinned, and
the two runs found eleven tickets' worth between them.

**The completion rule is scoped to the diff, not the contract.** implement's
*Build it* opens: the ticket is done when "every behavior it adds" traces to a
red-first test. The ticket's contract is the criteria it *claims*. US-1.5's
abort already existed in `pdf_parse.py` when kh-finder's ticket 02 claimed it;
US-9.3's comment was rewritten as a side effect of ticket 01. Nothing was
added, so nothing had to be pinned, and both closed green - with `REVIEWS=full`
over a ticket claiming nineteen criteria. everlast repeats it over CI config
and a hook (14, 15, 20). Fix: for each id in `Satisfies`, name the test; where
the ticket wrote a RED run, that run *is* the proof; where it did not, break
the behaviour, watch the named test fail, restore. Cost is proportional to the
gap and normally zero - five deliberate breaks on kh-finder.

**`Verification` is allowed to say there is no test.** kh-finder ticket 04's
reads "Kein Test. Die Kriterien sind Aussagen über Prosa", which trace's rule
flatly contradicts. The implementer argued in its `Record` that it read as
"kein Test *nötig*, nicht als Verbot", pinned one criterion of five, and the
other four came back as tickets 06 and 07. Fix: the section says *how* a
criterion is pinned, never that it isn't; a criterion nothing can pin is a
discovery defect and a `blocked` halt. Name the non-code case, since five late
tickets across the two runs were criteria over a README, a glossary, a module
comment, ARCHITECTURE.md and a GitHub workflow - each pinned by asserting on
the file's text, which kh-finder already had `glossar.test.js` for.

**Nothing notices a test that leaves.** Deleting one never turns anything red.
everlast's ticket 26 consolidated two caller suites into one protocol test and
removed coverage that had existed before the run; ticket 28 found it a pass
later - "the coverage existed before this run and does not exist after it".
kh-finder's second trace pass checked exactly this by hand and reported the
counts, but as one pass's initiative rather than a rule. Fix: a test removed,
renamed away or weakened over the run's diff is a finding for trace, and a
ticket-scoped one for implement's code review, which catches a consolidation at
the moment it consolidates.

**A remediation ticket fixes the half the mutation reached.** everlast's US-0.1
has two halves - the gate that blocks a red deploy, and the throwaway database
the suite runs against. Ticket 14 pinned the half trace had mutated; ticket 15
pinned the other a pass later. Fix: the ticket names the whole criterion and
every part of it left unpinned.

Touches: implement/SKILL.md, trace/SKILL.md, the five TICKET_FORMAT.md copies.

## 6. Let a constraint that covers a set name its members

plan requires a criterion be claimed by exactly one ticket and a constraint by
*at least* one. A constraint naming one property - a latency budget, a retry
rule - is served by that. One quantifying over a set is not: kh-finder's C-2,
"bei jeder Unklarheit abbrechen und die Stelle nennen", was claimed by four
tickets and therefore owned by none. Each pinned the abort conditions its own
stories named, and the conditions no story named belonged to nobody. They came
back as tickets 10, 11 and 14.

The implementers saw it and had no move. Ticket 11 wrote "der Fall gehört damit
derzeit niemandem, obwohl C-2 ihn meint"; ticket 10 handed the section level
away in as many words. Trace's second pass named the mechanism: "nicht durch
diese Commits entstanden, aber durch sie herrenlos geworden."

Fix: a constraint quantifying over a set is not claimable until the set is
enumerated against the real code, and then either every member is assigned to a
ticket or one ticket owns the class with the list in it. plan already reads the
codebase for the structures the spec names, so it is set up for the work.

Same defect one step upstream. SPEC_FORMAT's own example is right - "Verified
by an integration test with the service stubbed to fail", future and passive -
but kh-finder's spec wrote "_Verified: `pdf_parse.py` importiert nur die
Standardbibliothek_" and "_wie in `tools/test_merge.py` **bereits angelegt**_":
assertions of present fact, false for C-1 and partial for C-2, which everyone
downstream read as settled. The clause names the check that *will* exist, never
claims one already does.

Touches: plan/SKILL.md, discovery/SPEC_FORMAT.md, discovery/SKILL.md.

## 7. Give the implementer's out-of-scope finding a destination

An implementer deep in the code is the cheapest finder in a run, and what it
finds outside its own ticket reaches nothing the loop reads. kh-finder's ticket
04 invented a section header by hand - "Gemeldet, nicht hier geschlossen" - for
two gaps it hit while writing prose. Both landed in `Record`, which nothing
that could act on them reads, so trace rediscovered them a pass later.

Fix, without giving the implementer the power to add work: `Record` gains a
third subsection beside `Decisions` and `Unresolved`, for a gap found and
deliberately not closed here, carrying what is wrong, where, and which criterion
or constraint the writer thinks covers it. Trace reads the done tickets'
`Record` sections alongside the spec and the diff, treating an entry as a
**lead, not a verdict** - it still verifies adversarially and decides for
itself. One line in loop.sh's `trace_prompt`, which already scopes a later pass
to the commits since `CHECKED_AT`, and one `expect_prompt` case in tests/run.sh
written failing first, where `prompt_for` and the existing trace assertions are
the pattern.

The cheapest of these three, and the only one with a driver test.

Touches: the five TICKET_FORMAT.md copies, trace/SKILL.md, loop.sh,
tests/run.sh.

## 8. Review with a different model than the one that wrote the code

Every step is `claude -p` with one model in a fresh serial session. Two
deterministic checks sit under four prose reviews - quality, code, `/trace`,
`/critique` - all of them the same model marking its own homework.

A different model for the reviews is the cheapest available gain in
independence: a flag, not a redesign. The same argument applies to reasoning
effort, where `/plan` - decomposition, the costliest mistake in the pipeline -
and a sha256 comparison get the same budget today.

Touches: loop.sh (`run_step`), implement/SKILL.md (the review dispatches).

## 9. Let the driver recover from drift

`drift` and `stale-spec` have a documented mechanical recovery - `/plan
--refresh` - and the driver never calls it. It retries infrastructure failure
seven times over about three hours (`RETRY_DELAYS`) but gives up on a rename at
2am.

A refresh is not a guess; it re-derives from the code as it is. Bound it to one
per run and to those two halt reasons and the no-guessing contract holds.
`blocked` and `mystery` still need a human.

Touches: loop.sh (the halt path).

## 10. Keep the evidence a run produces

`LOG_DIR` lands under `$TMPDIR` and the transcripts are framed as debugging
aids, not artifacts. So nothing accumulates across runs: which halt reasons
recur, which convention findings repeat, how often the second review pass finds
anything, cost per ticket.

That is the only empirical input `/improve-skill` could have. Today the skills
are iterated by feel.

Touches: loop.sh (`LOG_DIR`, drain, the halt path), improve-skill/SKILL.md.

## 11. Turn /trace into the Abnahme, so something runs the software

Verification is one check command, the test suite, and four prose reviews.
`SPEC_FORMAT.md` has a Design section with screens and states - empty, loading,
error, partial, disabled - plus accessibility criteria, and no step ever renders
one.

A feature can be green, traced and critiqued while failing to boot. This ranks
above mutation testing (#12) for that reason: a suite can be fully
mutation-killed on an app that does not start. It is also the only entry here
that touches *usable* rather than *correct*.

#1's workflow tests take the largest bite out of this: a permanent suite that
drives the main journeys at every ticket cannot stay green on an app that does
not start. What they do not reach is the feature's own criteria - they are rare
by construction, one per journey, and a screen's empty and error states are not
journeys. So this survives, narrowed to what the permanent suite does not
cover.

The cheap shape is not a new skill beside `/trace` but `/trace` itself. It
already runs after the loop drains, already reads the spec whole, and already
files a ticket per gap so a failure re-enters the loop instead of being patched
in behind the checks. What changes is the evidence: drive the running feature
the way a user would, against the criteria, the way an Abnahme is done, rather
than read the code and judge. The tooling is present - the harness ships a `run`
skill and claude-in-chrome.

What that displaces is the real question. Trace carries two test-quality checks
today and neither survives the move unchanged:

- **Every criterion pinned by a test that would fail without it.** `/critique`
  already establishes the same property under Coverage maps, one altitude down.
  Consolidating there is the obvious move, and the cost is the reason it needs
  deciding: critique is deliberately spec-blind, so it can map a test to the
  logic it pins but not to the criterion that asked for it.
- **Whether each test is worth anything on its own.** That is #12 - the mutation
  check becomes a per-ticket gate in `/implement`, where a survivor lands on the
  ticket nothing is built on yet.

Two things the move must not lose. Trace is the only step that reads the spec
whole, so the orphan sweep - a criterion no ticket claimed, a constraint nothing
verified, a non-goal built anyway, behavior that traces to nothing - has to
survive wherever it lands. A per-ticket check structurally cannot find what no
ticket claimed. And not every criterion is observable from outside: a retry
policy, an invariant, a performance budget. An Abnahme needs both modes - drive
it where a user could see it, fall back to code and test evidence where nobody
can - and which criteria got which is the report.

Touches: trace/SKILL.md, critique/SKILL.md, implement/SKILL.md. Cheaper than the
new-skill version it replaces - nothing new to write, and loop.sh's drain is
unchanged - so it may belong above the rank it has here.

## 12. Mutation testing per ticket, which means the tooling ban goes

Everything the pipeline claims rests on one property - every behavior pinned by
a test that would fail without it - and today that property is asserted by the
model that wrote the test. Mutation testing is the executable form of the same
sentence.

Make it a per-ticket gate rather than an end-of-run check: it catches the gap on
the ticket nothing is built on yet instead of ten tickets later. Let it replace
the quality review rather than join it - that review runs once, is the first
thing dropped under `REVIEWS=code`, and a surviving mutant answers its core
question objectively.

The blocker is ours. trace/SKILL.md:46 says "Don't install tooling to satisfy
this", so most projects get the fallback trace itself calls "proves less". That
rule is what has to go, at the cost of a one-time tooling ticket per project.

Touches: trace/SKILL.md (the ban), implement/SKILL.md (Review it), loop.sh
(`REVIEWS`).

## 13. Separate now from later in discovery

Discovery holds scope to one shippable feature and parks the rest, but nothing
makes the spec state the smallest version worth shipping and what deliberately
comes after it. The split test catches a second feature hiding inside the first;
it does not catch a single feature specified past its MVP.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.

## 14. A lane for the work that keeps code maintainable

propose-change bounces it explicitly: nobody outside the code can observe a
refactor, so it is below the floor and "wants doing directly". cleanup-repo is
manual and stops for approval. upgrade-dependencies is wired into nothing.

So a suite whose goal is maintainable software routes every maintenance activity
outside its own TDD and review discipline. Features get four reviews; the work
that keeps the codebase alive gets none.

The objection is real - a refactor has no new behavior, so nothing can be
written RED. But that is the criterion, not a disqualification: the existing
suite stays green and the diff provably changes no behavior, which is checkable,
and is what #12 is for. `TICKET_FORMAT.md` already carries a second ticket kind
for `/trace`'s remediation tickets; a third kind is the natural home.

A decision, not an edit. Touches: TICKET_FORMAT.md (all five copies),
propose-change/SKILL.md.

## 15. A durable system description, regenerated rather than maintained

Deleting the spec and tickets at the merge is right, and worth keeping. But
after twenty features there is a glossary, some comments, a few ADRs, a handful
of workflow tests, and no document saying what the system does or how it is
shaped. repo-overview prints to the
conversation and is explicitly told not to save a file.

The move is regenerate-instead-of-maintain: repo-overview writes
`ARCHITECTURE.md`, marked as re-derived from code and never hand-patched. That
keeps the anti-stale principle - it is a build artifact, not a maintained doc -
and closes the gap the delete policy leaves open. Same entry covers the standing
complaint about the overview itself: it should name the domain modules and
objects and the domain actions each supports, which is what someone new
actually needs.

Touches: repo-overview/SKILL.md.

## 16. Check hard-to-reverse external choices against a primary source

No skill does external research. Discovery names "language, frameworks, data
models" as the decisions to be most careful about, and settles them from weights
that are months stale.

We already accept this argument at a smaller scale: coding-conventions requires
checking a package's registry entry and looking its version up, "because memory
is almost always stale". It applies with more force to choosing the library than
to pinning its version.

Touches: discovery/SKILL.md - any hard-to-reverse external choice checked
against current docs before it is recorded, with the citation in Implementation
decisions.

## 17. State the iron law once, in the one place that owns shared rules

"Don't report done on something you didn't run" exists across the pipeline only
in partial, skill-local forms: implement's RED confirmation, critique's
verify-before-reporting, trace's evidence rules. cleanup-repo, repo-overview
and propose-change state nothing of the kind.

coding-conventions exists precisely so rules live in one place instead of
drifting across skills, and this rule is not in it.

Touches: coding-conventions/SKILL.md, and a reference from the skills that
currently restate a fragment of it.

## 18. Split the craft from the loop that drives it

Two tiers: skills that are useful on their own, and skills that tie them into
the spec/ticket workflow. Half of it is already the stated design. critique
closes with "the caller knows about tickets, the reviewer doesn't", and the
ticket knowledge sits in `loop.sh:critique_prompt()` - four lines of it. trace
is the same shape, generic body with one ticket-shaped paragraph in `Output`.

implement is the outlier, ticket-bound throughout: `spec_hash`, `depends_on`,
four halt codes, `Record`, `status`. 33 of its 158 lines are unattendedness
rather than building - *Say what you are doing* (6), *Nothing runs in the
background* (8), *Halting* (15), the no-questions preamble (3), the
`REVIEWS=code` paragraph (1). A fifth of the longest skill in the suite after
coding-conventions is a concern that has nothing to do with code.

**The cut is not generic-vs-ticket.** That puts the two tiers in conflict over
implement's most load-bearing rule: a generic implement invoked on a line of
prompt *should* ask when the requirement is ambiguous, and a ticket implement
must never. Splitting that way means the wrapper overrides the inner skill's
core contract, which is the leakiest seam available. The boundary is craft vs
**mode** - tier 2 owns the ticket contract, unattendedness and the loop's
position and resumption together, and the craft tier holds no opinion about
who is watching.

The shape that follows is not three twins. Build a wrapper only where the
workflow knowledge is too big for a prompt line:

- **implement** earns one - a whole contract, not four lines.
- **critique and trace** need subtraction, not a twin: drop the ticket
  paragraph and the `TICKET_FORMAT.md` copy, and let the driver's prompt carry
  what it already carries. Five byte-identical copies become three.
- **plan** is definitionally tier 2 - it exists to produce tickets, so there is
  no generic core to extract. This is where #2's surviving naming question
  lands; `/decompose` or `/to-tickets`, with the rename cost #2 enumerates.

Naming principle if it goes ahead: tier 1 named for the activity, tier 2 for
the artifact. discovery, implement, critique, trace against decompose,
build-ticket.

**The open call is wrapper skill or mode-dispatch.** The cheaper mechanism is
the one already in use: implement stays one installable skill with a sibling
`TICKET_MODE.md`, dispatching on whether its input is a ticket path or a
sentence. That buys both stated goals - generic use outside the loop, loop
details out of the generic reading path - with no install-time dependency and
no second registry entry. A wrapper buys a distinct invocation name, a
distinct description, and hard enforcement that the generic path cannot read
the ticket rules. Indirection has to pay for itself, and mode-dispatch is the
smaller bet.

Context is free either way: plan, solution, implement and trace are already
user-invoked, so a tier-2 description never loads. Skill-reads-skill is
already precedent - six skills read coding-conventions.

Ranked here because it buys maintainability of the suite and reuse rather than
closing a hole in what the pipeline can prove, which is this list's measure.
Same family as #17: a rule that belongs in one place, restated in several. It
also unblocks #14, whose maintenance lane would reuse the craft tier rather
than route around the pipeline.

The cost is a collision, and #1 makes it worse: #1 and #5 to #7 all target
implement/SKILL.md, trace/SKILL.md, critique/SKILL.md and the five
TICKET_FORMAT.md copies - every file this would move, and #1 lands first. They
are evidence-driven from two runs; this is structural with no evidence of harm
yet, and a refactor goes on green. Against that: #5 and #7
both touch all five format copies, which this cuts to three.

Touches: implement/SKILL.md (the extraction), critique/SKILL.md and
trace/SKILL.md (the subtraction), plan/SKILL.md (the rename), loop.sh (the
prompts that inherit what the skills drop), tests/run.sh, and the
TICKET_FORMAT.md copies that go.

## 19. Build the independent tail in parallel

Wall clock is the sum of all tickets although `depends_on` already declares the
DAG. Keep the uncertainty-first prologue serial - that ordering is why a halt
costs one ticket instead of ten - and parallelise the independent tail in
worktrees. Then `REVIEWS=code` can die: it trades quality for time, while
parallelism trades money for time, which is the better trade.

Last because it buys wall clock rather than quality, and it is the most
expensive change on this list.

Touches: loop.sh (`run_step`, drain), plan/SKILL.md (its ordering rule already
fits).

## Open questions

Decisions, not edits. Each gates work that isn't worth starting until it is
settled.

- **Should `/trace` merge into `/critique`?** Both are reviews, but trace checks
  traceability to the spec rather than the code itself - and critique
  deliberately does not know about tickets or specs, a separation the pipeline
  leans on. #11 pushes the other way: an Abnahme that drives the application has
  less in common with a code review than trace does today, and it is critique
  that would inherit the coverage mapping. #1 raises the price: it makes trace
  the only step that may add work, precisely because it checks against a finite
  spec, so merging it into the spec-blind reviewer hands that power to the one
  bounded by nothing but taste.
- **Should the driver notice it is being restarted onto unconverged work?**
  `MAX_PASSES=2` exists so non-convergence reaches a human, and relaxing it is
  in *Rejected* below for the right reason. On everlast the signal fired and was
  answered by re-running `loop.sh` five times, twice under a new branch name -
  which resets both the pass count and `CHECKED_AT`, so the ceiling never bit.
  #1 should stop that particular regress, which is the argument for leaving the
  driver alone; against it, the restart is silent, and a ceiling routed around
  without anyone deciding to is not a ceiling.
- **Is `/debug` worth keeping?**
- **Is `ubiquitous-language-init` still useful?**
- **Should `upgrade-dependencies` cover adding a new dependency**, not only
  upgrading existing ones?
- **Should `/critique` generalise** to fire on any code review request, instead
  of competing with the built-in skill?
- **propose-change has never been run.** It sits in the main path, and whatever
  is wrong with it is still undiscovered - reading a skill turns up less than
  running it does.

## Rejected

Kept here so they don't get re-proposed.

- **Warming context across tickets.** The cold start is why a ticket is a closed
  unit. At most prime facts (check command, baseline sha), never judgment.
- **Relaxing `MAX_PASSES=2`.** Non-convergence is a signal, not a budget
  problem.
- **OpenSpec's living capability specs**, updated by ADDED/MODIFIED/REMOVED
  deltas and archived per change. Stale specs are worse than none; the archive
  discipline is the maintenance burden the delete policy avoids on purpose. #1
  answers the same need from the opposite side - the durable functional record
  is executable, so it cannot go stale unnoticed - and #15 is the missing
  complement, not a replacement.

- **A closing step that ratifies decisions after the run.** Both `/handover` and
  `/decision-brief` died of it. A ranked list handed to a reader with no live
  memory of the argument behind any item on it gets skimmed, not decided.
  Ratification belongs at the moment the decision is live; what follows a run is
  a report. Re-proposing it as "but shorter" is the same shape.
- **The byte-identical TICKET_FORMAT copies.** Deliberate - diff is the parity
  check, and cross-skill relative paths break on independent install.
- **A shared file for the split test and the other cross-skill rules.** The
  split test, the one-question-per-turn rule and treat-the-verdict-as-a-claim
  each live at three sites. They were reconciled in place instead: a file per
  rule buys parity for three sentences and costs another artifact to keep in
  step. The copies now read identically, so a grep is the check.
- **The two-door structure, the split test, and `/implement`'s no-questions
  contract.** All hold up.
- **BMAD's named persona agents.** Ceremony without gain; the rule that the
  reviewer does not know about tickets is the better instinct.
- **Spec Kit's article that every feature must begin as a standalone library.**
  Flatly contradicts YAGNI and deep-modules.
