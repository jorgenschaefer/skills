# Filtered ideas

The decided work: every concrete change that survived a pass over the two
superseded plan files and this file's earlier numbered entries, each kept or
dropped on its own. Rationale was deliberately set aside - those plans argued
from premises that do not all survive, so every solution was judged as a change
to make rather than as a consequence of the argument that produced it.

This file records **what to build**, not why the pipeline needs it. Where an
item's evidence matters it is named in one clause. The run accounting those
clauses cite - kh-finder at 15 tickets, everlast at 29 and never converged - is
in the version of this file at commit `f85cfa4`, along with the rejected list.

Names below use the post-rename forms: `/spec-to-tickets` (was `/plan`) and
`/check-against-spec` (was `/trace`).

---

## Spec and discovery

**`## Journeys` in `SPEC_FORMAT.md`.** Per journey: the trigger, the steps in
sequence including where each terminal action puts the user down, the domain
effect (which actors act on which work objects, what events that raises), and
the screens it passes through as a walk. Written by `/discovery`.
*Touches: discovery/SPEC_FORMAT.md, discovery/SKILL.md.*

**Show the domain model as a proposal.** The domain stories the skill already
traces internally, plus per aggregate what changes together and the invariant
the root holds - in its own turn, after the journey is understood and before
criteria harden. Foreground what can be vetoed: these two are one thing, X may
lag Y, that is not what we call it, you have missed an actor. Not
entity-versus-value-object. Work objects stop being a conditional section.
*Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.*

**The mockup binds to the journey, not to one open decision.** `Show, don't
tell` fires per journey rather than per open UI decision, so it can produce
screen 1 to screen 5 rather than two layouts side by side. Same disposal policy:
kept only where the visual is the record.
*Touches: discovery/SKILL.md.*

**Three tiers, and defaults are marked.** Permanent (terms, ADRs, workflows) /
binding for this feature (stories, criteria, constraints, non-goals) / defaults.
Each permanent item gets its own explicit yes in the conversation at the moment
it is proposed. A default is *decided without the evidence the builder will
have*, is marked as such in the spec, and is overturnable on evidence found in
the code - never on taste.
*Touches: discovery/SPEC_FORMAT.md, discovery/SKILL.md, implement/SKILL.md.*

**A closing five-line receipt** naming what became permanent, at which any item
may be reopened. **The five-line cap is written into the skill**, because
without it this regrows into the closing ranked brief that `/handover` and
`/decision-brief` both died of.
*Touches: discovery/SKILL.md.*

**The design-duplication survey, authored in `/discovery`.** Before the design
is written: what already exists that resembles what this feature needs, module
by module, and for each one whether the new work reuses it, extends it, absorbs
it, replaces it, or deliberately sits beside it - with the reason. Bounded to
what *this feature* touches; an `absorb` or `replace` no criterion requires goes
to `IDEAS.md`, one that is required gets an ADR and a yes. Every verdict is
recorded in `Implementation decisions`, the reuse and sit-beside ones included,
or `/check-against-spec`'s orphan sweep files a ticket to remove what the survey
deliberately kept. Each verdict reached with the codebase surveyed rather than
open is a **default**, marked as one.
*Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.*

**ADRs get a source and a reader.** `ADR_FORMAT.md` plus a location convention.
Written in `/discovery` where the alternatives are live, never autonomously - an
ADR is a permanent-tier item and gets its own yes. Read by `/discovery` and
`/spec-to-tickets` the way discovery already reads `UBIQUITOUS_LANGUAGE.md`;
`/critique` treats contradicting a ratified ADR as a finding.
*Touches: a new ADR_FORMAT.md, discovery/SKILL.md, spec-to-tickets/SKILL.md,
critique/SKILL.md.*

**Hard-to-reverse external choices are checked against a primary source** before
they are recorded, with the citation in `Implementation decisions`. Same
argument `coding-conventions` already makes for looking up a package version.
*Touches: discovery/SKILL.md.*

**`_Verified:_` names the check that will exist, never one that already does.**
Future and passive, as `SPEC_FORMAT.md`'s own example already is.
*Touches: discovery/SPEC_FORMAT.md.*

**Separate now from later.** The spec states the smallest version worth shipping
and what deliberately comes after it. The split test catches a second feature
hiding inside the first; this catches one feature specified past its MVP.
*Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.*

**`/discovery` gains a downward exit.** It becomes the sole entry point and ends
in one of three places: a spec that `/spec-to-tickets` decomposes; a shaped
instruction `/implement` builds directly; or a reasoned no. The three tiers
apply on the shaped-instruction path too - with the user present it can ratify a
permanent-tier item itself, and marked defaults still bind the implementer.
*Touches: discovery/SKILL.md, README.md.*

---

## Decomposition (`/spec-to-tickets`)

**A constraint quantifying over a set is not claimable until the set is
enumerated against the real code.** Then either every member is assigned to a
ticket, or one ticket owns the class with the list in it. `/spec-to-tickets`
already reads the codebase for the structures the spec names.
Evidence: kh-finder C-2, claimed by four tickets and owned by none, came back as
tickets 10, 11 and 14.
*Touches: spec-to-tickets/SKILL.md.*

**A default more than one ticket touches is promoted to binding** - marked in
the spec's own defaults list before `spec_hash` is computed. Not into a
`Provides`, which would manufacture a `drift` halt out of a date-format
convention.
*Touches: spec-to-tickets/SKILL.md, discovery/SPEC_FORMAT.md.*

**Workflow-test authorisation is pre-written at planning time.**
`/spec-to-tickets` reads `tests/workflows/` and writes the authorisation into
any ticket whose work reaches one, mechanical renames included. The guard stays
strict; the expensive halts are anticipated rather than discovered.
*Touches: spec-to-tickets/SKILL.md.*

---

## Building (`/implement`)

**`/implement-ticket`, a tier-2 wrapper.** The ticket-bound lines move out of
`implement/SKILL.md` - *Say what you are doing*, *Nothing runs in the
background*, the no-questions preamble, and the halt codes and commit protocol
from *Halting*. Thirty-two rather than thirty-three, since the `REVIEWS=code`
paragraph is retired before the extraction rather than moved. The wrapper calls
`/implement` by name, the way five skills already call `coding-conventions`.

**`implement/TICKET_FORMAT.md` moves with it** rather than being copied. The
craft skill never reads a ticket, so it should not carry the format at all.
After `/propose-change`'s copy goes there are five - `critique`, `discovery`,
`implement-ticket`, `spec-to-tickets`, `check-against-spec` - still
byte-identical, with diff still the parity check. `/discovery` needs one
because the small lane emits a real ticket, which is what `/implement` reads.
*Touches: a new implement-ticket/ skill, implement/SKILL.md, loop.sh, README.md.*

**Split the rule from the resolution at `implement/SKILL.md:11`.** The craft
rule is *never build past an ambiguity*; the resolution varies with who is
present. `/implement` states the rule and asks by default; `/implement-ticket`
supplies the missing fact - nobody is watching - so the resolution is a
`## Halt` block. This is what lets the wrapper specialise rather than override,
and it closes the seam the earlier proposal called the leakiest available.
*Touches: implement/SKILL.md, implement-ticket/SKILL.md.*

**Keep the bounded attempts in `/implement`.** Three tries to get a failing test
green, two code-review rounds - those are craft and stay in the craft skill.
Only the halt codes and the commit-the-ticket-alone protocol move.
*Touches: implement/SKILL.md.*

**The completion rule is scoped to the contract, not the diff.** For each id in
`Satisfies`, name the test that pins it. Where the ticket wrote a RED run, that
run is the proof; where it did not, break the behaviour, watch the named test
fail, restore.
Evidence: kh-finder ticket 02 closed green over nineteen claimed criteria under
`REVIEWS=full` because US-1.5's abort already existed in `pdf_parse.py`.
*Touches: implement/SKILL.md, the five TICKET_FORMAT.md copies.*

**`Verification` says *how* a criterion is pinned, never that it isn't.** A
criterion nothing can pin is a discovery defect and a `blocked` halt. Name the
non-code case: criteria over a README, a glossary, a module comment or a
workflow file are pinned by asserting on the file's text.
Evidence: kh-finder ticket 04 wrote "Kein Test"; four of its five criteria came
back as tickets 06 and 07.
*Touches: implement/SKILL.md, check-against-spec/SKILL.md, the five TICKET_FORMAT.md copies.*

**A remediation ticket names the whole criterion** and every part of it left
unpinned, not only the half a mutation reached.
Evidence: everlast US-0.1 - ticket 14 pinned one half, ticket 15 the other a
pass later.
*Touches: the five TICKET_FORMAT.md copies, check-against-spec/SKILL.md.*

**`Record` gains a third subsection**, beside `Decisions` and `Unresolved`, for
a gap found and deliberately not closed here: what is wrong, where, and which
criterion or constraint the writer thinks covers it.
*Touches: the five TICKET_FORMAT.md copies.*

**Each `Decisions` and `Unresolved` entry is marked with its stakes when it is
written**, while the reasoning is live. The driver sorts on the field; nothing
is ranked at the end.
*Touches: implement/SKILL.md, the five TICKET_FORMAT.md copies.*

**The quality review checks each default overturn.** It runs first and already
reads the ticket, so hand it the ticket's marked defaults and have it ask of
each overturn whether the evidence cited is actually in the code.
*Touches: implement/SKILL.md.*

**Mutation testing as a per-ticket gate**, catching the gap on the ticket
nothing is built on yet. It **joins** the quality review rather than replacing
it - that review also holds the default-overturn evidence check above.
*Touches: implement/SKILL.md, check-against-spec/SKILL.md (the ban, below), loop.sh.*

**`/implement`'s own quality and code reviews take the review bar** below.
*Touches: implement/SKILL.md.*

---

## Reviewing (`/critique`, `/check-against-spec`)

**The review bar: three conjuncts, all of which must hold.**
- *A constructed trigger.* The concrete input or state that drives the code to a
  wrong result, a crash, or a breach. Whoever reaches it need not be the end
  user.
- *A destination.* It traces to a numbered criterion, a constraint, a workflow,
  or to one of `coding-conventions`' security and data-loss properties, which
  bind unstated. Anything else is a new requirement and goes to `IDEAS.md`.
- *No reopening.* A finding that overturns a prior ticket's `Unresolved`
  adjudication on the same code may not be filed; it makes the run **requires
  human review** instead.
Evidence: everlast 25/27/29 - one finding relitigated twice, the last three
critique passes spent on a test-only diff. The third conjunct alone stops 27
and 29.
*Touches: critique/SKILL.md, check-against-spec/SKILL.md, implement/SKILL.md.*

**A surviving mutant is a gap only on code implementing one of those.** Mutants
are not a finite set, so without this bar the per-ticket mutation gate imports
the regress the other conjuncts close.
*Touches: check-against-spec/SKILL.md, implement/SKILL.md.*

**The pre-existing-coverage carve-out.** Coverage that existed before the run
and does not exist after it **is work**, even though it traces to no criterion
in this spec - the criterion it pinned belongs to a deleted spec, which the
destination conjunct cannot see. Without this, the finding below is illegal.
*Touches: critique/SKILL.md, check-against-spec/SKILL.md.*

**Notice a test that leaves.** A test removed, renamed away or weakened over the
run's diff is a finding for `/check-against-spec`, and a ticket-scoped one for
`/implement`'s code review, which catches a consolidation at the moment it
consolidates.
Evidence: everlast ticket 26 consolidated two caller suites and removed
pre-existing coverage; ticket 28 found it a pass later.
*Touches: check-against-spec/SKILL.md, implement/SKILL.md.*

**Severity is assigned by what the defect does, not by what it could become.** A
**blocker** is a wrong result, a crash, a loss or a breach with a trigger
somebody constructed - the input or the state, named. Not what this could become
if left; not "no user is exposed", which is a claim about who is currently
looking rather than about whether the defect is there.
*Touches: critique/SKILL.md.*

**`/critique` closes with a fixed verdict line** - blockers, should-fixes, nits -
so the driver reads the count without spending a second agent on the first one's
prose.
*Touches: critique/SKILL.md.*

**`/critique` leaves the pass loop.** It runs once over the run's whole diff
after the last drain, then re-reads only what it filed, narrowed by
`CHECKED_AT`.
Evidence: `loop.sh:453` sits inside the `for pass` loop that starts at `:445`, which is how passes 2
and 3 came to read a test-only diff.
*Touches: loop.sh.*

**`/check-against-spec` becomes the Abnahme.** It drives the running feature the
way a user would, against the criteria, rather than reading code and judging.
Both modes are required and which criteria got which is the report: drive it
where a user could see it, fall back to code and test evidence where nobody can
(a retry policy, an invariant, a performance budget). The orphan sweep - a
criterion no ticket claimed, a constraint nothing verified, a non-goal built
anyway - survives here, because a per-ticket check structurally cannot find what
no ticket claimed. Sequence this **after** workflow tests, and narrow it to what
the permanent suite does not cover.
*Touches: check-against-spec/SKILL.md, critique/SKILL.md, implement/SKILL.md.*

**Lift the tooling ban** at `check-against-spec/SKILL.md:47`, at the cost of a one-time
tooling ticket per project. It is what forces most projects onto a fallback the
skill itself calls "proves less".
*Touches: check-against-spec/SKILL.md.*

**Reviews read done tickets' `Record` sections as leads, not verdicts.** An
entry in the new third subsection is a place to look; the reviewer still
verifies adversarially and decides for itself.
*Touches: check-against-spec/SKILL.md, loop.sh (`check_prompt`), tests/run.sh.*

**Fix `/critique`'s `description`** so it fires instead of losing to the
built-in code-review skill. Affects hand use only - the driver invokes it by
typed name.
*Touches: critique/SKILL.md.*

---

## Permanent records

**Ratified workflow tests under `tests/workflows/`**, named for the journey in
the user's language and **quoting** its `## Journeys` entry rather than
paraphrasing it. The test is the record; there is no companion document to go
stale. Rare by construction: a workflow test pins a journey, per-task criteria
stay ordinary tests, and most features extend an existing journey and ratify
none - the skill has to say so or every feature will invent one. The suite runs
in the project's check command, so feature 12's run keeps feature 3's journeys
green at every ticket.
*Touches: discovery/SKILL.md, spec-to-tickets/SKILL.md, loop.sh, a convention for
tests/workflows/.*

**The driver guards `tests/workflows/`.** Any ticket whose diff touches the
directory without the authorisation halts. This is the pipeline's first
driver-initiated halt and its first post-commit one: the driver sets
`status: blocked` and appends a fixed `## Halt` block naming the reason, the
commit sha and the paths touched - mechanical text, no judgement. It stops with
the commit intact; reverting is the human's call. Documented resolution is to
add the authorisation and re-run, not to re-plan.
**Never ship this without the planning-time authorisation above.**
*Touches: loop.sh, tests/run.sh.*

**`repo-overview` writes `ARCHITECTURE.md`**, marked as re-derived from code and
never hand-patched - a build artifact, not a maintained doc. It names the domain
modules and objects and the domain actions each supports.
*Touches: repo-overview/SKILL.md.*

---

## The driver (`loop.sh`)

**Pin the untested machinery first.** `tests/run.sh` covers a clean run, rate
limits, retries, unreachable queues, the ticket directory, `REVIEWS=code` and
handover's printing, and nothing else. No fixture files a ticket, so the
re-drain (`:455-460`), `CHECKED_AT` narrowing (`:414-432`) and the
non-convergence exit (`:463-466`) are untested - and every driver change on this
list rewrites them. Write the fixture and those three cases against today's
behaviour before anything else.
*Touches: tests/run.sh.*

**Three terminal states**: clean, requires human review, halted. Blockers from
`/critique` make the run *requires human review*. That state has a defined way
back: the human resolves the standing blockers and re-runs `loop.sh`, which
drains what that produced, re-checks and re-critiques over the new commits.
Nothing about acceptance is hand-made, and no hand-fix lands behind the checks.
*Touches: loop.sh, tests/run.sh.*

**A report on every terminal path**, collected mechanically: `/critique`'s
review plus every ticket's `Record` -> `Decisions` and `Unresolved` entries,
sorted on the stakes field each writer marked. The run that ends *halted* or
*requires human review* is the one whose reader most needs it.
*Touches: loop.sh, tests/run.sh.*

**`/handover` is split along the layering.** **Mechanical text is the
driver's**: the halt reason, the commit, the paths, the stakes-sorted entries,
the command that resumes. **Judgement is the skill's**: what the branch does now
that it did not before, what changed and where, what a reviewer should look at,
what is still uncertain - a PR description, which has a reader and a moment.
Every terminal path produces both. The ranked ratification brief goes; promotion
moved upstream to ratify-in-flight, and `## Accept` goes to `accept.sh` below.
*Touches: loop.sh, handover/SKILL.md, tests/run.sh.*

**Acceptance is a script, not a skill.** A new `accept.sh` deletes the spec and
the `tickets/` directory and commits that, staging only those paths. It became
mechanical when promotion moved upstream: of `## Accept`'s three steps, the
judgement was step 1, and steps 2 and 3 are `git rm` and `git commit`. The
commit message needs no skill - the report was dropped and the PR description
carries the run's prose, so the subject is the feature and the body is the
ticket ids, both derivable from filenames.

It refuses rather than trusts, and every guard already exists in `loop.sh` to
copy: in a repo and not on `main` (`:84-89`), the ticket directory present
(`:81`), every ticket `status: done` (`:340`, `why_stuck` at `:309`), and the
tree clean so the commit is deletions only. This is the pipeline's one
irreversible act and the only one that destroys the record of what was asked, so
it is bash with guards rather than an agent session or a pasted command.

The driver prints `./accept.sh <spec-dir>` on the clean path: the human types it
after reading the PR description, which is the explicit act, and it runs on the
branch before the merge, so the paper never reaches the default branch.
*Touches: a new accept.sh, loop.sh, handover/SKILL.md, tests/run.sh, README.md.*

**The driver recovers from drift.** `/spec-to-tickets --refresh` on `drift` and
`stale-spec` only, bounded to one per run. `blocked` and `mystery` still need a
human. The recovery is already documented in `spec-to-tickets/SKILL.md:92` and in all five
format copies; the driver simply never calls it.
*Touches: loop.sh, tests/run.sh.*

**The driver notices a restart onto unconverged work.** Re-running `loop.sh`
resets both the pass count and `CHECKED_AT`; everlast used that five times,
twice under a new branch name, so `MAX_PASSES=2` never bit. A ceiling routed
around without anyone deciding to is not a ceiling.
*Touches: loop.sh, tests/run.sh.*

**Keep the run's evidence.** `LOG_DIR` moves out of `$TMPDIR` and
accumulates across runs: which halt reasons recur, which convention findings
repeat, how often a second pass finds anything, cost per ticket. This is the
only empirical input `/improve-skill` can have, and the only mechanism on this
list that lets a line be *removed* because a run went right.
*Touches: loop.sh, improve-skill/SKILL.md.*

**A different model for the reviews** than wrote the code, and **reasoning
effort set per step** - decomposition and a `sha256sum` comparison should not
get the same budget.
*Touches: loop.sh (`run_step`), implement/SKILL.md (the review dispatches).*

**`REVIEWS=code` is retired.** It trades quality for time, and the paragraph it
requires inside `/implement` goes with it.
*Touches: loop.sh, implement/SKILL.md, tests/run.sh.*

---

## The skill set

**Renames, done after the deletions**, which is what makes them cheap.
- `/plan` -> `/spec-to-tickets`. Collides with harness plan mode for the human
  who types it, and the name is wrong on its face: it produces tickets.
- `/trace` -> `/check-against-spec`. Names the one check nothing else performs,
  and stays true after the Abnahme change.
*Touches: directories, loop.sh, tests/run.sh, README.md, and the skills that
name them.*

**Deleted: `/propose-change`.** Merged into `/discovery`'s shaped-instruction
terminal. Its references in `spec-to-tickets/SKILL.md`, `implement/SKILL.md`, `README.md`
and the surviving `TICKET_FORMAT.md` copies go with it.

**Deleted: `/decision-brief`.** Its job - rank the decisions worth a veto out of
a finished plan - is what ratify-in-flight replaces.

**Deleted: `/debug`.**

**Kept: `ubiquitous-language-init`.** The glossary is one of the three
permanent-tier kinds, and both `/discovery` and `/implement` read
`UBIQUITOUS_LANGUAGE.md`.

**A maintenance lane.** A third ticket kind beside the feature ticket and
`/check-against-spec`'s remediation ticket, so refactors and dependency work go
through the same TDD and review discipline instead of around it. The criterion
is that the existing suite stays green and the diff provably changes no
behaviour - which the mutation gate checks. This is what finally routes work to
`upgrade-dependencies`.
*Touches: the five TICKET_FORMAT.md copies, upgrade-dependencies/SKILL.md.*

**`upgrade-dependencies` covers adding a new dependency**, not only upgrading
existing ones - a new dependency is a hard-to-reverse external choice and takes
the primary-source check.
*Touches: upgrade-dependencies/SKILL.md.*

**`README.md`** rewritten to match: one door, three terminals, the renamed
steps, the new terminal states. "Two front doors" goes.

---

## Land these together

- **The pre-existing-coverage carve-out** and **notice a test that leaves**. The
  second is illegal under the destination conjunct without the first.
- **The `tests/workflows/` guard** and **planning-time authorisation**. The
  guard alone produces expensive halts hours into unattended runs for mechanical
  renames.
- **`## Journeys`** and **workflow tests**. A test that quotes its journey needs
  the journey in the frozen file.
- **The per-ticket mutation gate**, **lifting the tooling ban**, and **the
  surviving-mutant bar**. The gate needs the tooling and would otherwise import
  the regress the bar closes.
- **`/implement-ticket`** and **the rule/resolution split**. The wrapper
  overrides the craft skill's core contract without it.

## Sequence

Twenty steps in one branch. Each leaves the suite green and is judgeable on
its own. Three rules set the order: the driver's untested machinery is pinned
before anything rewrites it; the artifacts and the skill set settle before the
content that fills them, so nothing is edited twice against a filename that is
about to change; and spec-format changes land before driver changes, so the
window where a spec written under the old rules is built under the new ones
stays inside the branch.

**A0, A1, A3, C3 and F1 depend on nothing** and can land at any point,
including first.

Nine of the twenty steps change only prose that no test guards, so *green* means
less here than the count suggests; for those the verification is a careful read.
The eleven marked *tested* below own a case in `tests/run.sh`, written failing
first as the repo's rule requires.

The boxes are this sequence's `status` field. A session ends and another begins
with no memory of which steps landed, which is the problem the ticket format
already solves by keeping state in the file rather than in the driver. Tick the
box in the same commit as the step.

- [x] **A0** Pin the untested machinery - *tested*
- [x] **A1** Keep the run's evidence - *tested*
- [x] **A2** Review independence, `REVIEWS=code` retired - *tested*
- [x] **A3** `accept.sh` - *tested*
- [x] **B1** `SPEC_FORMAT.md` and a new `ADR_FORMAT.md`
- [x] **B2** `/discovery` gains everything it now owns
- [x] **B3** Delete `/propose-change`, `/decision-brief`, `/debug`
- [x] **B4** The renames - *tested*
- [x] **B5** `/spec-to-tickets`'s decomposition rules
- [x] **C1** `/implement-ticket`, with the rule split from the resolution - *tested*
- [x] **C2** The ticket format and what `/implement` writes into it
- [x] **C3** The maintenance lane
- [x] **D1** The review bar - *tested*
- [x] **D2** Mutation - *tested*
- [x] **D3** Workflow tests and their guard - *tested*
- [x] **E1** Terminal states, the report, and `/handover` split - *tested*
- [x] **E2** Driver resilience - *tested*
- [x] **E3** The Abnahme
- [x] **F1** `ARCHITECTURE.md`
- [ ] **F2** `README.md`

### Phase A - the mechanical work that depends on nothing

**A0. Pin the untested machinery.** The fixture that files a ticket, plus cases
for the re-drain, `CHECKED_AT` narrowing and the non-convergence exit, written
against today's behaviour. Every driver step below rewrites exactly these, and
none of them is covered now.
*tests/run.sh.*

**A1. Keep the run's evidence.** `LOG_DIR` out of `$TMPDIR`, accumulating across
runs; `/improve-skill` reads it. Early because every dogfood run from here on
either produces evidence or does not, and this is the only mechanism on the list
that lets a line be removed because a run went right. A case that a run's logs
land where the next run can read them, written failing first - a silent failure
here loses exactly the evidence the step exists to collect.
*loop.sh, improve-skill/SKILL.md, tests/run.sh.*

**A2. Review independence, and `REVIEWS=code` retired.** A different model for
the reviews, reasoning effort per step, and the quality-for-time trade deleted.
Before C1, so the wrapper never inherits a paragraph that is about to die - the
extraction is 32 lines rather than 33.
*loop.sh (`run_step`), implement/SKILL.md, tests/run.sh.*

**A3. `accept.sh`.** The script and its guards, with cases in `tests/run.sh`.
Before E1, so the mechanism exists before `/handover`'s `## Accept` is cut and
there is no window in which nothing can accept a run. It reads today's `status:`
vocabulary and today's spec layout, so nothing above it is a prerequisite.
*a new accept.sh, tests/run.sh.*

### Phase B - settle the artifacts and the skill set

**B1. `SPEC_FORMAT.md`, and a new `ADR_FORMAT.md`.** `## Journeys`; the three
tiers with defaults marked; `_Verified:_` in the future tense; now-versus-later;
where survey verdicts and affected modules are recorded; the ADR format and its
location convention. All format changes at once, because the format is the
contract every later step writes against.
*discovery/SPEC_FORMAT.md, a new ADR_FORMAT.md.*

**B2. `/discovery` gains everything it now owns.** The journeys, the domain model
shown in its own turn, the mockup bound to the journey, ratification in flight
with the capped receipt, the duplication survey, ADRs written where the
alternatives are live, the primary-source check, now-versus-later, and the three
terminals including the downward exit. One edit rather than three.
*discovery/SKILL.md.*

**B3. Delete `/propose-change`, `/decision-brief`, `/debug`.** Safe only after B2,
which is where the small lane goes. Clean every reference in `spec-to-tickets/SKILL.md`,
`implement/SKILL.md`, `handover/SKILL.md` and `README.md`. Six
`TICKET_FORMAT.md` copies become five.
*three skill directories, and the files that name them.*

**B4. The renames.** `plan/` to `spec-to-tickets/`, `trace/` to
`check-against-spec/`. Here rather than last: B3 has already cut the reference
count, and every step after this one writes the final names once.
*directories, loop.sh, tests/run.sh, README.md.*

**B5. `/spec-to-tickets`'s decomposition rules.** A constraint quantifying over
a set is not claimable until the set is enumerated against the real code and
every member is assigned; and a default more than one ticket touches is promoted
to binding in the spec's defaults list before `spec_hash` is computed. After B4
so it is written under the new name, and after B1 so the defaults list exists to
promote into.
*spec-to-tickets/SKILL.md.*

### Phase C - the building contract

**C1. `/implement-ticket`, with the rule split from the resolution.** The wrapper
and `implement/SKILL.md:11` in the same step; the wrapper overrides the craft
skill's contract without the split. `implement/TICKET_FORMAT.md` moves into the
wrapper here, leaving the same five copies in different hands.
*a new implement-ticket/, implement/SKILL.md, loop.sh, tests/run.sh.*

**C2. The ticket format and what `/implement` writes into it.** `Record`'s third
subsection, the stakes mark on every `Decisions` and `Unresolved` entry,
contract-scoped completion, `Verification` saying how rather than whether, the
whole-criterion remediation rule, the quality review checking each default
overturn, and the bounded attempts staying craft. Format and writer together: a
field with no writer is dead, and the copies are byte-identical, so every format
edit is a five-way edit worth making once.
*the TICKET_FORMAT.md copies, implement/SKILL.md.*

**C3. The maintenance lane.** A third ticket kind, and `upgrade-dependencies`
covering a new dependency under the primary-source check. Independent of
everything above except C2's copy set.
*the TICKET_FORMAT.md copies, upgrade-dependencies/SKILL.md.*

### Phase D - the reviewing contract

**D1. The review bar.** The three conjuncts, the pre-existing-coverage carve-out
and *notice a test that leaves* together, severity by what the defect does, the
fixed verdict line, reviews reading `Record` entries as leads, and `/critique`'s
description fixed. Needs C2, which is where the third subsection appears. The
driver-side reads - the verdict line's counts, and the `Record` entries the
review prompt points at - take a prompt case each, written failing first.
*critique/SKILL.md, check-against-spec/SKILL.md, implement/SKILL.md, loop.sh,
tests/run.sh.*

**D2. Mutation.** The tooling ban lifted, the per-ticket gate, and the
surviving-mutant bar - all three, or the gate imports the regress D1 closes.
After D1, because the bar is stated in terms of the destination conjunct. What
the driver passes the gate is a prompt case, written failing first.
*check-against-spec/SKILL.md, implement/SKILL.md, loop.sh, tests/run.sh.*

**D3. Workflow tests and their guard.** The `tests/workflows/` convention, the
driver guard, and the planning-time authorisation in one step - the guard alone
produces expensive halts hours into unattended runs. Needs B1 and B2 for the
journey a test quotes, and B4 for the skill that pre-writes the authorisation.
*spec-to-tickets/SKILL.md, loop.sh, tests/run.sh, tests/workflows/.*

### Phase E - the run's ending

**E1. Terminal states, the report, and `/handover` split.** Three states with a
defined way back, the mechanically collected report on every path, the driver
writing the mechanical half and the skill the PR description, and `/critique`
leaving the pass loop, plus `## Accept` cut from the skill and `./accept.sh`
printed on the clean path instead. Needs C2's stakes field to sort on, D1's
verdict line to count, and A3 to exist.
*loop.sh, handover/SKILL.md, tests/run.sh.*

**E2. Driver resilience.** Bounded `--refresh` on `drift` and `stale-spec`, and
noticing a restart onto unconverged work. After E1, because a restart is
recognised against the terminal state the previous run recorded.
*loop.sh, tests/run.sh.*

**E3. The Abnahme.** `/check-against-spec` drives the running feature rather than
reading code, keeping both modes and the orphan sweep. Last of the behavioural
work: it is narrowed to what the permanent suite does not cover, so D3 has to
exist first for that narrowing to mean anything.
*check-against-spec/SKILL.md, critique/SKILL.md, implement/SKILL.md.*

### Phase F - the durable documents

**F1. `ARCHITECTURE.md`.** `repo-overview` writes it, re-derived and never
hand-patched. Touches nothing else on this list.
*repo-overview/SKILL.md.*

**F2. `README.md`.** One door and three terminals, the renamed steps, the new
terminal states, the maintenance lane. Last, because it is the only place the
shape is explained to a reader and it should be written once against the
finished thing.
*README.md.*

## Open

Neither gates a step.

- **The `/implement-ticket` boundary is enforced by nothing.** The grep lint was
  dropped along with the three-layer taxonomy it was written to enforce, so
  ticket knowledge drifting back into `implement/SKILL.md` fails no test.
- **What the mutation gate costs at every ticket.** It is bounded in the skill -
  the ticket's own diff, one run plus one, and a stated bail-out where only a
  whole-suite run is available - but the bail-out is the builder's judgement and
  nothing measures what it actually spends.
- **What the workflow suite costs at every ticket** on a project where it is
  slow. The fallback of running it only at the final gate was dropped, so the
  at-every-ticket property is unconditional and its cost is unbudgeted.

## Dropped

The thirteen solutions that did not survive the filtering pass are recorded,
with the reason for each, in the version of this file at commit `f85cfa4`.
