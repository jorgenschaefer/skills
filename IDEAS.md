# Ideas

Feature ideas for this repository, ordered by what each buys against what it
costs. The measure is the pipeline's own goal: correct, usable, high-quality,
maintainable software. An idea that buys wall clock or tidiness ranks below one
that closes a hole in what the pipeline can prove.

`/discovery` reads this file as its parking lot, so every entry says what
problem it solves, what it would touch, and what it costs.

Work that is decided rather than weighed lives in a `PLAN_*.md` file instead.
`PLAN_RATIFICATION.md` holds the front-loaded-ratification rework, and several
entries below argue against it or wait on it. `PLAN_LAYERS.md` drafts #15.

## Two runs, cited throughout

Entries 2 to 4 and the review discipline in `PLAN_RATIFICATION.md` argue from
the same two runs, so the accounting sits here once rather than four times.

`kh-finder` (`spec-dokumentbestand`) finished at 15 tickets: 4 planned, 11
filed by `/trace` and `/critique` during the run. `everlast-notebooklm`
(`notebooklm-mvp`, then `finalize`) finished at 29 and **has not converged**:
13 planned, 16 filed, ticket 29 still `todo`, five restarts across two branch
names, and the last three critique passes spent on a test-only diff.

Not all 27 late tickets are defects in the pipeline. Duplication found once
three copies existed, a vocabulary split, a suite poisoning its own database,
and a defect in a late fix caught by critique after trace are the yield the
reviews exist for. Entries 2 to 4, and the regress `PLAN_RATIFICATION.md`
claims, are the ones that should not have got that far, and each names the
tickets it claims.

Transcripts under `/tmp/loop-spec-dokumentbestand-*`,
`/tmp/loop-notebooklm-mvp-*` and `/tmp/loop-finalize-*`; the tickets themselves
under each project's `docs/tickets/`.

## 1. Make the skills fire

Two of sixteen skills still have one problem: the skill does not fire, and a
skill that does not fire is worth zero however good its contents.

- `/critique` competes with the built-in code-review skill and loses by
  default. The only one left that a `description` can fix, and the reason
  critique stayed model-invoked while the rest of the loop's skills did not.
- `upgrade-dependencies` is user-invoked and nothing routes maintenance work
  to it, so it is never reached. That is #11's missing lane, not a trigger
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
TICKET_FORMAT.md. #15 carries that question now: the rename is one part of
splitting the craft tier from the loop tier, and paying the cost twice would
be the waste.

## 2. Pin what the ticket claims, and notice when a pin leaves

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
the moment it consolidates. `PLAN_RATIFICATION.md`'s work bar would forbid this
finding as written - coverage that pinned a deleted spec's criterion traces to
no criterion in this one - so the carve-out that keeps it legal lives there.

**A remediation ticket fixes the half the mutation reached.** everlast's US-0.1
has two halves - the gate that blocks a red deploy, and the throwaway database
the suite runs against. Ticket 14 pinned the half trace had mutated; ticket 15
pinned the other a pass later. Fix: the ticket names the whole criterion and
every part of it left unpinned.

Touches: implement/SKILL.md, trace/SKILL.md, the five TICKET_FORMAT.md copies.

## 3. Let a constraint that covers a set name its members

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

## 4. Give the implementer's out-of-scope finding a destination

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

## 5. Review with a different model than the one that wrote the code

Every step is `claude -p` with one model in a fresh serial session. Two
deterministic checks sit under four prose reviews - quality, code, `/trace`,
`/critique` - all of them the same model marking its own homework.

A different model for the reviews is the cheapest available gain in
independence: a flag, not a redesign. The same argument applies to reasoning
effort, where `/plan` - decomposition, the costliest mistake in the pipeline -
and a sha256 comparison get the same budget today.

Touches: loop.sh (`run_step`), implement/SKILL.md (the review dispatches).

## 6. Let the driver recover from drift

`drift` and `stale-spec` have a documented mechanical recovery - `/plan
--refresh` - and the driver never calls it. It retries infrastructure failure
seven times over about three hours (`RETRY_DELAYS`) but gives up on a rename at
2am.

A refresh is not a guess; it re-derives from the code as it is. Bound it to one
per run and to those two halt reasons and the no-guessing contract holds.
`blocked` and `mystery` still need a human.

Touches: loop.sh (the halt path).

## 7. Keep the evidence a run produces

`LOG_DIR` lands under `$TMPDIR` and the transcripts are framed as debugging
aids, not artifacts. So nothing accumulates across runs: which halt reasons
recur, which convention findings repeat, how often the second review pass finds
anything, cost per ticket.

That is the only empirical input `/improve-skill` could have. Today the skills
are iterated by feel.

Touches: loop.sh (`LOG_DIR`, drain, the halt path), improve-skill/SKILL.md.

## 8. Turn /trace into the Abnahme, so something runs the software

Verification is one check command, the test suite, and four prose reviews.
`SPEC_FORMAT.md` has a Design section carrying each screen's layout,
components and states, and `discovery/SKILL.md` names the ones a happy path
omits - empty, loading, error, partial, disabled - plus accessibility criteria.
No step ever renders one.

A feature can be green, traced and critiqued while failing to boot. This ranks
above mutation testing (#9) for that reason: a suite can be fully
mutation-killed on an app that does not start. It is also the only entry here
that touches *usable* rather than *correct*.

`PLAN_RATIFICATION.md`'s workflow tests take the largest bite out of this: a
permanent suite that drives the main journeys at every ticket cannot stay green
on an app that does not start. What they do not reach is the feature's own
criteria - they are rare by construction, one per journey, and a screen's empty
and error states are not journeys. Nor do they reach whether the journey runs
the way the user ratified it: a workflow test asserts what its implementer chose
to assert, and it is joined to the ratified journey by quotation, which is a
prose discipline. So this survives, narrowed to what the permanent suite does
not cover - the feature's own criteria, and the fidelity the suite assumes.

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
- **Whether each test is worth anything on its own.** That is #9 - the mutation
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

## 9. Mutation testing per ticket, which means the tooling ban goes

Everything the pipeline claims rests on one property - every behavior pinned by
a test that would fail without it - and today that property is asserted by the
model that wrote the test. Mutation testing is the executable form of the same
sentence.

Make it a per-ticket gate rather than an end-of-run check: it catches the gap on
the ticket nothing is built on yet instead of ten tickets later. Let it replace
the quality review rather than join it - that review runs once, is the first
thing dropped under `REVIEWS=code`, and a surviving mutant answers its core
question objectively.

The blocker is ours. trace/SKILL.md:47 says "Don't install tooling to satisfy
this", so most projects get the fallback trace itself calls "proves less". That
rule is what has to go, at the cost of a one-time tooling ticket per project.

Touches: trace/SKILL.md (the ban), implement/SKILL.md (Review it), loop.sh
(`REVIEWS`).

## 10. Separate now from later in discovery

Discovery holds scope to one shippable feature and parks the rest, but nothing
makes the spec state the smallest version worth shipping and what deliberately
comes after it. The split test catches a second feature hiding inside the first;
it does not catch a single feature specified past its MVP.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.

## 11. A lane for the work that keeps code maintainable

propose-change bounces it explicitly: nobody outside the code can observe a
refactor, so it is below the floor and "wants doing directly". cleanup-repo is
manual and stops for approval. upgrade-dependencies is wired into nothing.

So a suite whose goal is maintainable software routes every maintenance activity
outside its own TDD and review discipline. Features get four reviews; the work
that keeps the codebase alive gets none.

The objection is real - a refactor has no new behavior, so nothing can be
written RED. But that is the criterion, not a disqualification: the existing
suite stays green and the diff provably changes no behavior, which is checkable,
and is what #9 is for. `TICKET_FORMAT.md` already carries a second ticket kind
for `/trace`'s remediation tickets; a third kind is the natural home.

A decision, not an edit. Touches: TICKET_FORMAT.md (all five copies),
propose-change/SKILL.md.

## 12. A durable system description, regenerated rather than maintained

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

## 13. Check hard-to-reverse external choices against a primary source

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

## 14. State the iron law once, in the one place that owns shared rules

"Don't report done on something you didn't run" exists across the pipeline only
in partial, skill-local forms: implement's RED confirmation, critique's
verify-before-reporting, trace's evidence rules. cleanup-repo, repo-overview
and propose-change state nothing of the kind.

coding-conventions exists precisely so rules live in one place instead of
drifting across skills, and this rule is not in it.

Touches: coding-conventions/SKILL.md, and a reference from the skills that
currently restate a fragment of it.

## 15. Split the craft from the loop that drives it

Drafted in `PLAN_LAYERS.md`, which settles the boundary and the target skill
list and leaves the naming and the format copies open. The rest of this entry
is the argument that draft was built from.

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
  no generic core to extract. This is where #1's surviving naming question
  lands; `/decompose` or `/to-tickets`, with the rename cost #1 enumerates.

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
already precedent - five skills read coding-conventions, four once
`PLAN_RATIFICATION.md` deletes handover.

Ranked here because it buys maintainability of the suite and reuse rather than
closing a hole in what the pipeline can prove, which is this list's measure.
Same family as #14: a rule that belongs in one place, restated in several. It
also unblocks #11, whose maintenance lane would reuse the craft tier rather
than route around the pipeline.

The cost is a collision, and `PLAN_RATIFICATION.md` makes it worse: the plan, #2
and #4 all target implement/SKILL.md, trace/SKILL.md, critique/SKILL.md and the
TICKET_FORMAT.md copies - every file this would move, and the plan lands first.
The two entries are evidence-driven from two runs; this is structural with no
evidence of harm yet, and a refactor goes on green. Against that: #2 and #4 both
touch every format copy, and between them the plan and this entry take five down
to three.

Touches: implement/SKILL.md (the extraction), critique/SKILL.md and
trace/SKILL.md (the subtraction), plan/SKILL.md (the rename), loop.sh (the
prompts that inherit what the skills drop), tests/run.sh, and the
TICKET_FORMAT.md copies that go.

## 16. Build the independent tail in parallel

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
  leans on. #8 pushes the other way: an Abnahme that drives the application has
  less in common with a code review than trace does today, and it is critique
  that would inherit the coverage mapping. `PLAN_RATIFICATION.md` raises the
  price without settling it: it lets both file, but only trace may file against
  the spec, while critique files only what it can construct a trigger for and
  what lands in the security and data-loss properties that bind unstated.
  Merging them merges two differently-bounded mandates into one reviewer, and
  the merged skill would have to carry both bars separately anyway.
- **Should the driver notice it is being restarted onto unconverged work?**
  `MAX_PASSES=2` exists so non-convergence reaches a human, and relaxing it is
  in *Rejected* below for the right reason. On everlast the signal fired and was
  answered by re-running `loop.sh` five times, twice under a new branch name -
  which resets both the pass count and `CHECKED_AT`, so the ceiling never bit.
  `PLAN_RATIFICATION.md` shrinks what each pass can produce but does not touch
  the reset, and keeps `MAX_PASSES` as the backstop rather than replacing it -
  so the argument for leaving the driver alone is weaker than it looked.
  Against it still: the restart is silent, and a ceiling routed around without
  anyone deciding to is not a ceiling.
- **Is `/debug` worth keeping?**
- **Is `ubiquitous-language-init` still useful?**
- **Should `upgrade-dependencies` cover adding a new dependency**, not only
  upgrading existing ones?
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
  discipline is the maintenance burden the delete policy avoids on purpose.
  `PLAN_RATIFICATION.md` answers the same need from the opposite side - the
  durable functional record is executable, so it cannot go stale unnoticed -
  and #12 is the missing complement, not a replacement.

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
