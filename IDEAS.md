# Ideas

Feature ideas for this repository, ordered by what each buys against what it
costs. The measure is the pipeline's own goal: correct, usable, high-quality,
maintainable software. An idea that buys wall clock or tidiness ranks below one
that closes a hole in what the pipeline can prove.

`/discovery` reads this file as its parking lot, so every entry says what
problem it solves, what it would touch, and what it costs.

## Two runs, cited throughout

Entries 6 to 9 argue from the same two runs, so the accounting sits here once
rather than four times.

`kh-finder` (`spec-dokumentbestand`) finished at 15 tickets: 4 planned, 11
filed by `/trace` and `/critique` during the run. `everlast-notebooklm`
(`notebooklm-mvp`, then `finalize`) finished at 29 and **has not converged**:
13 planned, 16 filed, ticket 29 still `todo`, five restarts across two branch
names, and the last three critique passes spent on a test-only diff.

Not all 27 late tickets are defects in the pipeline. Duplication found once
three copies existed, a vocabulary split, a suite poisoning its own database,
and a defect in a late fix caught by critique after trace are the yield the
reviews exist for. Entries 6 to 9 are the ones that should not have got that
far, and each names the tickets it claims.

Transcripts under `/tmp/loop-spec-dokumentbestand-*`,
`/tmp/loop-notebooklm-mvp-*` and `/tmp/loop-finalize-*`; the tickets themselves
under each project's `docs/tickets/`.

## 1. Give ADRs a reader, and a source

Two defects at opposite ends of the same record.

**No reader.** `grep -rln ADR --include=SKILL.md` returns one file: `handover`.
It can promote an architecturally consequential choice into an ADR, and nothing
ever reads one again - not discovery, not plan, not implement, not critique. The
only durable decision record the pipeline produces has no consumer. Feature 12
can contradict a decision ratified at feature 3 and nothing notices, which is
the exact failure ADRs exist to prevent.

Fix: discovery and plan read the ADRs the way discovery already reads
`UBIQUITOUS_LANGUAGE.md`, and critique treats contradicting a ratified ADR as a
finding.

**No source.** Handover is the right place to *write* an ADR - it is the
acceptance moment, the user is present, and only there is it known what survived
a halt or a `--refresh`. But it sits three steps downstream of where the content
exists, and everything in between is deleted on purpose. The alternatives argued
in the discovery interview reach the spec only as a one-line `_Why:_` naming the
choice that won; `/decision-brief` recomputes them as neutral tradeoffs and is
then explicitly never written down, because a brief is spent when its reader
decides. So the rejected alternative - the reason ADRs exist at all - is nowhere
by the time handover asks for one, and a decision the user overruled leaves no
trace, since only the chosen path exists in the code.

Fix: for hard-to-reverse decisions, the spec's `Implementation decisions`
records the alternative rejected alongside the choice, and where the brief
surfaces a tradeoff the spec doesn't carry, it goes back into the spec before
`spec_hash` freezes it. Handover's promotion then lifts rather than
reconstructs.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md, plan/SKILL.md,
critique/SKILL.md, handover/SKILL.md. Still bullets and a clause - the cheapest
entry on this list by a wide margin.

## 2. Let the standard reach the skills that decide what gets built

`coding-conventions` is read by cleanup-repo, critique, plan, implement,
handover and itself. Not discovery - which settles the design language, the data
shapes, the aggregate boundaries and the whole Implementation decisions section.
Not propose-change, which picks an approach and writes it into a ticket.

So a ticket can be born violating the layering doctrine, `/implement` builds it
faithfully, and the code review flags a structure the ticket mandated. The
rubric binds the builder and the reviewer but not the designer.

Touches: discovery/SKILL.md, propose-change/SKILL.md. One line each.

## 3. Make the skills fire

Two of sixteen skills still have one problem: the skill does not fire, and a
skill that does not fire is worth zero however good its contents.

- `/critique` competes with the built-in code-review skill and loses by
  default. The only one left that a `description` can fix, and the reason
  critique stayed model-invoked while the rest of the loop's skills did not.
- `upgrade-dependencies` is user-invoked and nothing routes maintenance work
  to it, so it is never reached. That is #19's missing lane, not a trigger
  problem - a better `description` would not help, because nobody is looking
  for it.

`/plan` and `/implement` were on this list and came off it by the opposite
move. Both are user-invoked now, with `/trace` and `/handover`: the loop
drives all four by typed name, so the model-reach they paid context for was
never used. `/implement` no longer wants a broader trigger because it has
none, and `/plan` can no longer be autonomously confused with the harness's
plan mode.

What survives of the `/plan` collision is the naming question for the human
who types it, and the rename cost if the answer is yes: `/plan` is named in
README.md, discovery/SKILL.md, implement/SKILL.md, propose-change/SKILL.md,
decision-brief/SKILL.md, SPEC_FORMAT.md and all five copies of
TICKET_FORMAT.md. #23 carries that question now: the rename is one part of
splitting the craft tier from the loop tier, and paying the cost twice would
be the waste.

## 4. Show the user the domain model

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

## 5. Mock the journey, not the decision

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
what the spec never said - #6 to #9 all assume the criterion exists.

Touches: discovery/SKILL.md (`Show, don't tell`, Process),
discovery/SPEC_FORMAT.md (Design).

## 6. Pin what the ticket claims, and notice when a pin leaves

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

## 7. Let a constraint that covers a set name its members

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

## 8. Grade a check by what it lets through today

critique assigns severity "by what happens if nobody fixes this". Applied to a
hole in a guard, that scores what a future edit might slip past it - a
hypothetical priced as a defect.

The result is a regress that has not stopped. everlast's ticket 25 built an
owner-filter scanner over `notebookStore.ts`; 27 found the scanner blind to
`$executeRaw`; 29 found it blind to a nested `deleteMany:` as well. All three
open by stating that no user is exposed and the module is correct as it stands.
Each was filed by whichever reviewer had not filed the last, each overturns the
previous ticket's `Unresolved` adjudication, the last three critique passes
read a **test-only** diff, and the standing nit list names the next candidates.
Ticket 29 is still `todo`.

Fix: a finding about production behaviour keeps its severity; a finding about a
test or a check is graded by what the product actually lets through today. A
door nobody has walked through is a nit for handover, not a should-fix worth a
ticket. This does not demote ticket 25 - a surviving mutant on a live owner
filter in the module C-1 rests on, one edit from exposure.

One carve-out, or the trade is a regress for a lie. Ticket 29's real complaint
was that ticket 27's rewritten comment **states something false**, and tickets
are deleted at acceptance while the comment outlives them. A comment that lies
is a defect about the code and keeps its severity.

Touches: critique/SKILL.md.

## 9. Give the implementer's out-of-scope finding a destination

An implementer deep in the code is the cheapest finder in a run, and what it
finds outside its own ticket reaches nothing the loop reads. kh-finder's ticket
04 invented a section header by hand - "Gemeldet, nicht hier geschlossen" - for
two gaps it hit while writing prose. Both landed in `Record`, which only
handover reads, so trace rediscovered them a pass later.

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

The cheapest of these four, and the only one with a driver test.

Touches: the five TICKET_FORMAT.md copies, trace/SKILL.md, loop.sh,
tests/run.sh.

## 10. Give the small-change lane somewhere to promote

`/propose-change` -> one ticket -> `/implement` ends at a commit. There is no
handover on that lane, so it has no promotion step at all: no glossary update,
no comment, no ADR. A bugfix that forces an architecturally consequential choice
- a cache layer, a new repository seam - has nowhere durable to put it, and
`/implement` cannot be that place, since it never asks a question and an ADR is
never written autonomously.

Not the wrong place, the way #1 is. No place. The cheap form is pointing
`/handover` at a single-ticket run, where its delete-the-paper step maps neatly
onto the one ticket. The decision it gates is whether a one-ticket change earns
that ceremony at all, or only when the ticket's `Decisions` came back non-empty.

Touches: handover/SKILL.md, propose-change/SKILL.md. A decision first, then two
small edits.

## 11. Let the caller tell handover whether anyone is there

`/critique` closes with "the caller knows about tickets, the reviewer doesn't",
and keeps its ticket knowledge in `loop.sh`. `/trace` is told where to file a
gap. `/handover` is the one that settled it for itself - its `## Accept`
section reads "the driver runs this step at the end of an unattended run, where
there is nobody to answer: present the brief, name the promotions you would
propose, and stop."

Nothing is at risk: the guard works and an unattended run deletes nothing. The
defect is where the guard lives. The driver passes no mode at all - `run_step
"handover" "/handover $SPEC_DIR" "$BRIEF_FILTER"`, where the third argument is
an output filter - so the skill knows its caller instead of the caller knowing
its skill, backwards by the suite's own doctrine. And because the skill decided
it unilaterally, the rule is now written three times: the skill's `## Accept`,
loop.sh's closing comment and two `echo` lines, and the README's "accepting the
work ... is a step you run yourself afterwards". This repo has a commit named
*Say each shared rule once, in one wording*.

**The brief is written for a sleeping reader and then thrown away.** The skill:
"the briefs need no deleting; they are presented inline and never written down,
since a brief is spent the moment its reader decides." That is inherited from
`/decision-brief`, where producer and reader share a conversation and it is
right. Here they are separated by a night, and the brief survives only as a
`$TMPDIR` JSONL. So the morning `/handover` re-derives the whole thing from
every ticket in order to execute a decision already made - and the two
derivations will not be identical, which is how a reader ends up acting on a
brief that differs from the one they read.

Fix, in two halves. **The caller declares the mode**: nobody is present,
produce the brief, name the promotions you would propose, change nothing,
delete nothing. The skill's `## Accept` then says only that acceptance needs
the user's word, and handover becomes caller-agnostic like critique. **And the
brief is written down**, beside the spec, committed like the tickets and
deleted with them on acceptance - not a new policy but the existing paper
policy applied to a document that was exempted by a rule borrowed from a
different situation. The morning session reads it instead of rebuilding it.

Two roads not taken. Splitting handover the way #23 splits `/implement` does
not pay: the brief and the promotion list are one derivation, and two skills
would duplicate it. And ending the loop at `/critique` - the shape this was an
open question about - is a regression, because the question at 7am is whether
the run is worth accepting and answering it needs the brief to already exist.

Unexercised, like #10 and for the same reason: handover has never been run.
That is what holds it here rather than beside the entries with shipped defects
behind them.

Touches: handover/SKILL.md (`## Accept`, and the no-file rule), loop.sh (a
handover prompt, and the closing echoes it replaces), tests/run.sh, README.md.

## 12. Review with a different model than the one that wrote the code

Every step is `claude -p` with one model in a fresh serial session. Two
deterministic checks sit under four prose reviews - quality, code, `/trace`,
`/critique` - all of them the same model marking its own homework.

A different model for the reviews is the cheapest available gain in
independence: a flag, not a redesign. The same argument applies to reasoning
effort, where `/plan` - decomposition, the costliest mistake in the pipeline -
and a sha256 comparison get the same budget today.

Touches: loop.sh (`run_step`), implement/SKILL.md (the review dispatches).

## 13. Let the driver recover from drift

`drift` and `stale-spec` have a documented mechanical recovery - `/plan
--refresh` - and the driver never calls it. It retries infrastructure failure
seven times over about three hours (`RETRY_DELAYS`) but gives up on a rename at
2am.

A refresh is not a guess; it re-derives from the code as it is. Bound it to one
per run and to those two halt reasons and the no-guessing contract holds.
`blocked` and `mystery` still need a human.

Touches: loop.sh (the halt path).

## 14. Keep the evidence a run produces

`LOG_DIR` lands under `$TMPDIR` and the transcripts are framed as debugging
aids, not artifacts. So nothing accumulates across runs: which halt reasons
recur, which convention findings repeat, how often the second review pass finds
anything, cost per ticket.

That is the only empirical input `/improve-skill` could have. Today the skills
are iterated by feel.

Touches: loop.sh (`LOG_DIR`, drain, the halt path), improve-skill/SKILL.md.

## 15. Turn /trace into the Abnahme, so something runs the software

Verification is one check command, the test suite, and four prose reviews.
`SPEC_FORMAT.md` has a Design section with screens and states - empty, loading,
error, partial, disabled - plus accessibility criteria, and no step ever renders
one.

A feature can be green, traced, critiqued and handed over while failing to boot.
This ranks above mutation testing (#16) for that reason: a suite can be fully
mutation-killed on an app that does not start. It is also the only entry here
that touches *usable* rather than *correct*.

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
- **Whether each test is worth anything on its own.** That is #16 - the mutation
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

## 16. Mutation testing per ticket, which means the tooling ban goes

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

## 17. Separate now from later in discovery

Discovery holds scope to one shippable feature and parks the rest, but nothing
makes the spec state the smallest version worth shipping and what deliberately
comes after it. The split test catches a second feature hiding inside the first;
it does not catch a single feature specified past its MVP.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.

## 18. Separate what the spec settled from what it merely defaulted

SPEC_FORMAT's marker points one way only. A decision that was the user's to
make - "a business rule, not a reversible default" - says so in its `_Why:_`
"so a later reader or reviewer knows it's settled, not open to challenge".
A spec can promote something to binding. It cannot demote anything, and nothing
downstream infers a demotion.

So the force is uniform. `/implement` reads "where the two seem to differ the
spec wins", and its decision log fires only where "the spec or ticket was
**silent** or ambiguous". Binary: the spec speaks and binds, or is silent and
the implementer defaults and logs it. kh-finder therefore froze
`lies_versorgungsuebersicht()` becoming `lies_dokumentbestand()` - a naming
call - under `spec_hash` at exactly the force of "the file cut follows who
writes, and that was the user's decision". An implementer holding a better name
has two legal moves: obey, or halt `blocked`.

The ranking that would fix this is already computed and then destroyed.
`/decision-brief` surfaces "the consequential, contentious, load-bearing, or
hard-to-reverse" decisions ranked by stakes, and briefs "are never written down
at all". The pipeline works out the stakes of every decision exactly once and
deletes the answer, leaving the artifact that binds carrying none of it.

The fix is a second list beside Implementation decisions: the reversible
defaults. The format already names the concept without providing the slot.

What bounds the tier is the framing, not the wording. A default is not "we
weren't sure" - it is **decided without the evidence the builder will have**.
Discovery settles with the codebase skimmed; the implementer is the first party
with it open. So a default is overturnable on evidence found in the code, never
on taste.

Downstream it is all existing machinery. `/implement` may choose differently at
the cost of a `Record` -> `Decisions` entry rather than a `blocked` halt, which
is the whole win. `/plan` may where decomposition gives it a reason, and says so
in the brief. `/trace` does not read the deviation as work tracing to nothing,
since the behaviour still traces to its criterion; `/critique` is spec-blind and
unaffected. No driver change, and `spec_hash` is untouched because the file is.

One guard, and it has to be explicit because the failure is invisible by
construction: **a default more than one ticket touches is not a default but a
contract**, and `/plan` promotes it into a `Provides`. Without that, ticket 3
and ticket 9 each overturn it their own way, cold, and nothing ever notices.

Touches: discovery/SPEC_FORMAT.md, discovery/SKILL.md, implement/SKILL.md,
plan/SKILL.md.

## 19. A lane for the work that keeps code maintainable

propose-change bounces it explicitly: nobody outside the code can observe a
refactor, so it is below the floor and "wants doing directly". cleanup-repo is
manual and stops for approval. upgrade-dependencies is wired into nothing.

So a suite whose goal is maintainable software routes every maintenance activity
outside its own TDD and review discipline. Features get four reviews; the work
that keeps the codebase alive gets none.

The objection is real - a refactor has no new behavior, so nothing can be
written RED. But that is the criterion, not a disqualification: the existing
suite stays green and the diff provably changes no behavior, which is checkable,
and is what #16 is for. `TICKET_FORMAT.md` already carries a second ticket kind
for `/trace`'s remediation tickets; a third kind is the natural home.

A decision, not an edit. Touches: TICKET_FORMAT.md (all five copies),
propose-change/SKILL.md.

## 20. A durable system description, regenerated rather than maintained

Deleting the spec and tickets at handover is right, and worth keeping. But after
twenty features there is a glossary, some comments, a few ADRs, and no document
saying what the system does or how it is shaped. repo-overview prints to the
conversation and is explicitly told not to save a file.

The move is regenerate-instead-of-maintain: repo-overview writes
`ARCHITECTURE.md`, marked as re-derived from code and never hand-patched. That
keeps the anti-stale principle - it is a build artifact, not a maintained doc -
and closes the gap the delete policy leaves open. Same entry covers the standing
complaint about the overview itself: it should name the domain modules and
objects and the domain actions each supports, which is what someone new
actually needs.

Touches: repo-overview/SKILL.md.

## 21. Check hard-to-reverse external choices against a primary source

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

## 22. State the iron law once, in the one place that owns shared rules

"Don't report done on something you didn't run" exists across the pipeline only
in partial, skill-local forms: implement's RED confirmation, critique's
verify-before-reporting, trace's evidence rules. cleanup-repo, handover,
repo-overview and propose-change state nothing of the kind.

coding-conventions exists precisely so rules live in one place instead of
drifting across skills, and this rule is not in it.

Touches: coding-conventions/SKILL.md, and a reference from the skills that
currently restate a fragment of it.

## 23. Split the craft from the loop that drives it

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
  no generic core to extract. This is where #3's surviving naming question
  lands; `/decompose` or `/to-tickets`, with the rename cost #3 enumerates.

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

Context is free either way: plan, implement, trace and handover are already
user-invoked, so a tier-2 description never loads. Skill-reads-skill is
already precedent - six skills read coding-conventions.

Ranked here because it buys maintainability of the suite and reuse rather than
closing a hole in what the pipeline can prove, which is this list's measure.
Same family as #22: a rule that belongs in one place, restated in several. It
also unblocks #19, whose maintenance lane would reuse the craft tier rather
than route around the pipeline.

The cost is a collision. #6 to #9 target implement/SKILL.md, trace/SKILL.md,
critique/SKILL.md and all five TICKET_FORMAT.md copies - every file this would
move. They are evidence-driven from two runs; this is structural with no
evidence of harm yet, and a refactor goes on green. Against that: #6 and #9
both touch all five format copies, which this cuts to three.

Touches: implement/SKILL.md (the extraction), critique/SKILL.md and
trace/SKILL.md (the subtraction), plan/SKILL.md (the rename), loop.sh (the
prompts that inherit what the skills drop), tests/run.sh, and the
TICKET_FORMAT.md copies that go.

## 24. Build the independent tail in parallel

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
  leans on. #15 pushes the other way: an Abnahme that drives the application has
  less in common with a code review than trace does today, and it is critique
  that would inherit the coverage mapping.
- **Should the driver notice it is being restarted onto unconverged work?**
  `MAX_PASSES=2` exists so non-convergence reaches a human, and relaxing it is
  in *Rejected* below for the right reason. On everlast the signal fired and was
  answered by re-running `loop.sh` five times, twice under a new branch name -
  which resets both the pass count and `CHECKED_AT`, so the ceiling never bit.
  #8 should stop that particular regress, which is the argument for leaving the
  driver alone; against it, the restart is silent, and a ceiling routed around
  without anyone deciding to is not a ceiling.
- **Is `/debug` worth keeping?**
- **Is `ubiquitous-language-init` still useful?**
- **Should `/decision-brief` become a summary of the discovery spec** rather
  than a separate brief?
- **Should `upgrade-dependencies` cover adding a new dependency**, not only
  upgrading existing ones?
- **Should `/critique` generalise** to fire on any code review request, instead
  of competing with the built-in skill?
- **handover and propose-change have never been run.** Both sit in the main
  path. Whatever is wrong with them is still undiscovered - #11 is what reading
  the skill turns up, not what running it would.

## Rejected

Kept here so they don't get re-proposed.

- **Warming context across tickets.** The cold start is why a ticket is a closed
  unit. At most prime facts (check command, baseline sha), never judgment.
- **Relaxing `MAX_PASSES=2`.** Non-convergence is a signal, not a budget
  problem.
- **OpenSpec's living capability specs**, updated by ADDED/MODIFIED/REMOVED
  deltas and archived per change. Stale specs are worse than none; the archive
  discipline is the maintenance burden the delete policy avoids on purpose. #20
  is the missing complement, not a replacement.
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
