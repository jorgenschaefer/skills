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
  permanent, because each yes was given without the others in view.
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
is the living capability spec `IDEAS.md` rejects, on the grounds that stale
specs are worse than none.

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
green at every ticket. The green suite already guards a shipped feature's
tests - `/implement` runs the check command before its reviews - but nothing
holds a *ratified, journey-level* record that a later feature may not quietly
redefine: `/trace` checks the current spec and `/critique` is spec-blind, so a
journey nobody wrote a test for in feature 3 is nobody's business in feature 12.
Where a project's workflow suite is too slow to run at every ticket, the
fallback is the run's final gate - regressions still caught, just at the end of
the run rather than at the ticket that caused them - and that is a per-project
call worth stating rather than leaving implied.

Consent to change one is granted before the loop starts. `/discovery` reads the
existing workflow tests, and a feature that alters a journey ratifies **that
alteration** as a permanent-tier item; `/plan` writes the authorisation into
exactly one ticket. `loop.sh` halts any ticket whose diff touches the directory
without it - strict, so an unattended agent can never quietly edit the
definition of correct. The cost is a halt when a workflow test was written close
enough to the implementation that a rename reaches it, which is the signal that
it was written at the wrong seam. The discipline that keeps it rare is to assert
where nothing moves: the public API, or the text a user reads.

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
`ADR_FORMAT.md`. Never written autonomously: an ADR is a permanent-tier item and
gets its own yes.

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
what the skill already says it does. That also bounds the passes by
construction, so `MAX_PASSES=2` stops being the thing holding the loop shut.

Three bars follow, and each has to bind or the engine simply moves.

- **A finding is work only if it names a wrong behaviour reachable today with
  concrete inputs, and traces to a numbered criterion, a constraint, or a
  workflow.** A finding that traces to nothing in the spec is a new requirement,
  and new requirements go to `IDEAS.md`, never to a ticket. The line that
  matters is pinning a stated requirement versus hardening a guard - "no
  test-only ticket" would forbid trace's whole job, which is finding a criterion
  no test pins.
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

The price, which is real and worth naming: a `/critique` blocker that meets the
bar exactly is now handled by a human rather than re-entering the loop, which
reverses "a late fix is built and re-verified rather than patched in behind the
checks". The trade is a bounded loop for a hand-finished tail, and it is taken
knowingly.

`/critique` also leaves the pass loop. It read the whole diff on pass 1 and a
test-only diff on passes 2 and 3; with nothing to file, it belongs once, over
the run's whole diff, at the end.

### The run reports, and the report is the deletion commit

`/handover` goes. Its promotion job moved upstream, and what is left is the
spec-silent calls the implementers made - which cannot move upstream, because
they do not exist until the run happens. Under the tiers those are all
overturned defaults, so they want reporting, not ranking.

The driver's last act on a clean run is one commit that **deletes the spec and
the `tickets/` directory and carries the report as its commit message**:
`/critique`'s review, plus every ticket's `Record` -> `Decisions` and
`Unresolved` entries, collected mechanically. That answers three things at once.
The paper never reaches the default branch, which merging alone would not
achieve - a merge brings added files with it, squash or not, so "acceptance is
the merge" only works if something deleted them first. The report is durable
without being a file to clean up later, and `loop.sh`'s "leave no paper behind
in the working tree" holds. And a grep cannot disagree with the review it
summarises, which a second derivation at 7am could and would.

Acceptance is then the merge, with nothing to run first. A rejected run is the
same commit not made: the tickets stay, and they are the input to the next run.

`/critique` closes with a fixed verdict line - blockers, should-fixes, nits - so
the driver reads the count without spending a second agent on the first one's
prose. Blockers make the run **requires human review**, which gives it three
terminal states rather than two: **clean**, **requires human review**,
**halted**. "Finished" today means only that nothing stopped it. Under the
reachable-today bar, blocker means a user-visible wrong behaviour reachable
today - not "what happens if nobody fixes this", which is what priced
hypotheticals as defects.

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
Implementation decisions, and the seam: everything through `## User Stories`
belongs to `/discovery`, `## Design` and `## Implementation decisions` to
`/solution`.

**2. `ADR_FORMAT.md` and the location convention**, plus the reader line in
discovery, solution, plan and critique.

**3. `discovery/SKILL.md`** - cut to the what; ratification in flight and the
closing receipt; reads the existing workflow tests and the ADRs; the
`/decision-brief` close goes.

**4. `solution/SKILL.md`** - new; the how; reads `coding-conventions` and the
ADRs; may send requirements back.

**5. `plan/SKILL.md`** - the workflow-test ticket ordered last, the multi-ticket
default promoted to a `Provides`, the workflow authorisation written into the
one ticket that carries it, and the `## Hand off` close on `/decision-brief`
goes. Ordering the workflow test last cuts against plan's own uncertainty-first
rule and has to say why it is not an exception to it: the ticket carries no
uncertainty - its content was ratified before the run - only a dependency on
every ticket before it, since a journey test cannot pass until the journey
exists.

**6. The bars.** `critique/SKILL.md` - the reachable-today severity rule, the
verdict line, and the paragraph that hands a caller `TICKET_FORMAT.md` for
findings written up as work orders. `trace/SKILL.md` - the mutant bar and the
pre-existing-coverage carve-out. `implement/SKILL.md` - the same bar inside the
ticket, and the marked default it may overturn.

**7. The ticket format and the skills that name the deleted steps.** All five
`TICKET_FORMAT.md` copies say `Decisions` "is what the handover brief aggregates
at the end of a run"; it now feeds the deletion commit's message. Delete
`critique/TICKET_FORMAT.md` outright - critique no longer files - leaving four.
Also `plan/SKILL.md` ("their `Record` sections feed the handover"),
`trace/SKILL.md` ("for the human to ratify at handover", "goes to handover as a
finding") and `propose-change/SKILL.md` ("No decision brief here.").

**8. `loop.sh`** - the workflow-test guard on every ticket's diff, critique
moved out of the pass loop and filing nothing, the deletion commit carrying the
report, the three terminal states, the handover step and `BRIEF_FILTER` gone.
`tests/run.sh` extended, written failing first as in step 0.

**9. Delete `handover/` and `decision-brief/`**; `propose-change/SKILL.md` gets
the tiers; `README.md` gets the new shape.

## Open at the time of writing

- Whether `tests/workflows/` and the ADR directory are `loop.sh` config or fixed
  conventions. The driver needs the workflow path to enforce the guard; the ADR
  path is only ever read by skills, which can look.
- What `/solution` does to `IDEAS.md`'s craft-versus-loop split. It is a new
  tier-1 skill and that entry's naming principle - tier 1 named for the
  activity, tier 2 for the artifact - would have an opinion about the name.
