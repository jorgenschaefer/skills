# New pipeline idea

A five-stage pipeline from a customer arriving with an idea to a verdict on whether
their problem was solved. Every stage emits one artifact. Every stage ends with an
adversarial agent that checks that artifact against what it was given. Stage (e) has
no adversary because it *is* one.

The pipeline is not a track you enter. Stages (c) and (d) happen inside the harness
modes you would already be using — plan mode and auto mode — with their skills
discovered by description rather than invoked by name. The mode is a *correlation*,
not a scoping mechanism: nothing lets a skill fire on "the user is in plan mode", only
on what the request looks like. What the arrangement buys is the design's most
important property: **every stage degrades to the unaided harness.** Load no skills at
all and plan mode plus auto mode still produce a sane result on a quick bug fix; the
skills only add. A pipeline you can forget to invoke is a pipeline that gets
forgotten.

This **replaces** the current pipeline rather than adapting it. `/to-solution`,
`/spec-to-tickets`, `/check-against-spec`, `/implement`, `/implement-ticket`,
`/handover`, `loop.sh` and `accept.sh` all go. What they solved does not go with them,
so this document has to say how each of those problems is answered here — see *What is
deliberately dropped* and *Unattended execution*.

`/idea` and `/critique` survive, both reshaped rather than rewritten: `/idea` against a
new intent format, `/critique` as (d)'s reviewer as well as the review anyone can run
by hand on any branch. `coding-conventions` splits into the plan-time software-design
skill and the write-time coding standard.

## The shape

| | Stage | Skill | Input | Artifact | Adversary checks |
|---|---|---|---|---|---|
| a | Find the actual problem | `/idea` | The customer's request, usually framed as a solution | `INTENT_<TOPIC>.md`: what must be true for the problem to be solved, plus the constraints the solution is judged against | Complete, contradiction-free, every condition observable |
| b | Find a solution | `/solve` | Intent | `SOLUTION_<TOPIC>.md`: behaviour, acceptance criteria, edge cases, accepted tradeoffs, ruled-out alternatives | Complete, contradiction-free, solves the intent, no unlisted drawbacks |
| c | Slice the work | plan mode, then `/slice` | Solution | `tickets/<topic>/`: one self-contained ticket file per vertical slice | Every ticket traces to the solution, every solution element lands in a ticket, every ticket is one slice |
| d | Implement | the runner + `/implement` | One ticket | **A commit** | The code matches the ticket; every criterion the ticket claims is named by a test |
| e | Acceptance | `/accept` | Intent + the finished feature | `VERDICT_<TOPIC>.md`, with routing | — it is the adversary |

**Three mandatory human touchpoints in the happy path:** the customer says "yes, THAT
is my problem" at the close of (a), a person approves the slicing at the end of (c),
and a person reads the verdict and merges at (e).

A second class is conditional: the `undecided` interrupt, every halt, raising a
ceiling, declaring an intent unsatisfiable, abandoning a topic, and the approval on a
re-slice. Most of these only happen on a path that has already left the happy one.

The ratification stop inside `/solve` is the exception and is not really a fourth
touchpoint: on the prose path it *is* (a)'s touchpoint, moved. Three per run either
way — what changes is where the first one lands. These are not extra ceremony;
each one exists because the alternative is a machine deciding something it has no
standing to decide.

The middle runs unattended *after plan approval*, as long as nothing halts. That is
the honest version of the claim. The plan gate is worth its cost: it is cheap, it
lands exactly where bad slicing is still catchable, and it is where an ADR gets
ratified.

## a — Find the actual problem · `/idea`

The customer arrives with a solution. The job is to find the problem underneath it:
who is hurting, what are they trying to do, what it costs them today, what evidence
there is. The artifact contains no solution.

Its outcome is **what needs to be true for the problem to be solved** — conditions
`C-1 … C-n`, each stated so that someone could later check it true or false without
asking the author what they meant. That observability requirement is what makes
stage (e) possible at all.

The artifact also carries the **constraints**: what we are optimizing and what we
will not accept. Reversibility over correctness, or the reverse. A budget. Zones of
the system not to touch. A deadline. These are not implementation detail — they are
the standard (b) gets judged against, and the customer ratifies them in the same
breath as the problem statement.

(a) is the weakest stage in the chain: its adversary has no prior artifact to compare
against, only the customer's raw words, so it can do no more than re-derive the
problem independently and flag divergence. This is why (a) ends with the customer
confirming the summary. An error here propagates through everything downstream and
is caught only at (e), after the full cost has been spent.

**Exit:** the customer recognizes their own problem in the artifact, and it names no
implementation.

**Revision:** `C-n` ids are append-only — never reused, never renumbered, because
tickets and the verdict refer to them by number. An intent edited after (c) has run
means re-slicing the unbuilt tickets; see *Unattended execution*.

## b — Find a solution · `/solve`

The chosen approach, expanded to the point of precision: observable behaviour,
acceptance criteria, edge cases, explicit non-goals. Choosing the approach and
specifying it are one act — the precision is how you find out the choice was wrong,
so splitting them into two stages only creates a handoff.

The solution must also carry:

- **Accepted tradeoffs** — the costs of this approach, named and owned.
- **At least one ruled-out alternative**, with the reason it lost.

The ruled-out alternative is what makes the tradeoffs falsifiable. Without something
to be worse than, a tradeoff list degenerates into hedges ("adds some complexity")
that cost a reviewer nothing to approve.

### What this adversary can and cannot do

It is a **validator, not a selector**. Many solutions satisfy the intent; the review
confirms that this one does, is internally consistent, and covers the intent
completely. It cannot tell you that a better solution existed, because "best" has no
ground truth in the artifact.

What it *can* do is search for drawbacks that are not on the accepted list. An
omitted drawback is a defect in the same way a contradiction is. It can also check
that the stated reason for ruling out the alternative is actually true, and look for
an alternative nobody considered. That does not make the choice right, but it catches
a choice that was *uninformed* — which is where most bad solutions come from.

These three clauses reach outside the artifact, into the codebase and the domain.
That is sanctioned; see rule 1.

### Handling a newly found tradeoff

The adversary finds costs; it does not get to decide a cost is unacceptable. That is
taste, and taste-based reviewers oscillate. Severity is tested against the intent's
constraints:

- **Violates no constraint** → append it to the accepted tradeoffs and proceed. The
  solution got more honest; nothing else changes.
- **Violates a constraint** → back to (b) for a different solution, with the violated
  constraint named.
- **Significant, but the constraints are silent on it** → the one legitimate
  interrupt. The intent did not anticipate this axis, so the person who ratified (a)
  decides, and their answer is appended to the intent as a new constraint.

Found at (b) — the normal case — the interrupt costs nothing in flight, because no
ticket exists yet. It can also surface later: a build discovers an axis the
constraints never addressed. Then the ticket takes the `undecided` halt and the run
stops. The interrupt is cheap early and expensive late, which is an argument for
spending effort on the constraints at (a), not a guarantee that it cannot happen
late.

## c — Slice the work · plan mode + `/slice`

**This stage happens in plan mode**, where `/slice` is discovered rather than typed.
With no skill loaded you get an ordinary plan, which is the correct behaviour for a
change too small to be worth more.

Two skills surface here:

- **`/slice`** — works out the slicing, and writes it once it is approved.
- **a software-design skill** — domain language, module boundaries, what deserves an
  ADR. It fires when the plan introduces a concept or crosses a boundary, not when it
  edits three lines. Plan approval is then also the moment an ADR gets ratified, which
  is where that decision belongs: in front of a person, with the reasoning visible,
  never written unilaterally. The ADR is **written at plan exit, alongside the
  tickets**, while the reasoning that produced it is still in context — (e) can only
  promote what was never written, and by then the argument is gone.

### What is approved, and when the files appear

Plan mode cannot write files, so the sequence matters and the document should not
blur it:

1. `/slice` works out the slicing **in context** — the tickets, their order, what each
   covers.
2. `/verify` runs its coverage check on that proposed slicing, before anything is
   shown. A person skimming a plan will not notice that `AC-4` landed in no ticket;
   that is exactly what a mechanical check is for, and it must run before anyone is
   asked to approve. **This is the one invocation that is not file-addressed:** the
   proposed slicing goes into the subagent's prompt as text, with the solution's path
   alongside it. Everywhere else `/verify` is handed a path, because everywhere else
   the artifact exists on disk.
3. The person approves **the slicing**, not the files.
4. Plan mode exits and `/slice` writes `tickets/<topic>/` to match.

The written files are a transcription of what was approved and are **not re-verified**.
That is a deliberate thinness: it assumes a skill can copy its own approved output to
disk faithfully. If that assumption ever fails it will fail silently, and the cheapest
fix is re-running the coverage check over the written directory as a runner
pre-flight.

The solution cut into work: `tickets/<topic>/`, one file per vertical slice, in
dependency order, each independently buildable and testable. A simple change is one
ticket in that directory; nothing about the format changes with size.

**Tickets are self-contained.** Each copies the acceptance criteria it covers
verbatim rather than citing them by id alone. The `AC-n` tags stay, for coverage —
but they are no longer the only copy of the text. This is what replaces the spec hash
the old pipeline used: a ticket cannot be silently redefined by an edit upstream,
because the words it was built against are inside it.

The cost is that an edit to the solution does not propagate, and **the runner owns
detecting that**, not the sessions. Before each pass it compares the solution against
every ticket's `Done when` block, **in both directions**, and stops the run with
`drift` on any mismatch. It has to sit there, because a session is forbidden to read
the solution at all and a committed ticket is revisited by nobody.

Being bidirectional makes it two checks in one, and the report must say which fired:

- **a ticket's criterion is not in the solution** — the solution was edited under it,
  or the slicing transcribed something that was never there;
- **a solution criterion is in no ticket** — the slicing lost it.

The second is also the coverage check over the *written* directory, which is the hole
the plan-approval sequence leaves open. So it is not merely a staleness guard: it is
the only mechanical check that the files on disk match what was approved.

Recovery is re-slicing the unbuilt tickets. A *committed* ticket that has drifted is a
decision for a person, not a re-run.

### Re-slicing

Two paths come back to (c) against a directory that already has committed tickets:
drift recovery, and the verdict routing a lost criterion back. The rules are the same
either way:

- **Committed tickets are immutable.** Their text is what the code was built against,
  and rewriting it makes the `Record` a lie.
- **Numbering is append-only**, like `C-n`. A re-slice adds tickets; it does not
  renumber the directory.
- **Re-slicing goes back through plan mode and its approval.** Writing tickets is what
  plan approval authorises, so a second write needs a second approval. `after:`
  dependencies against committed tickets are repaired as part of that plan.

## d — Implement · `/implement`, then `/critique`

**`/implement` is one ticket**: test first, implement, project checks, commit. It is
discovered from auto mode. Iterating over the directory is not its job, and **neither
is reviewing its own work** — see *Unattended execution*.

### Who reviews, and when

The review is `/critique`, run **after the commit, in its own session, against the
ticket**. It is not called from inside `/implement`, because a reviewer in the session
that wrote the code has already accepted every step of it — the fresh context is the
whole value, and a skill cannot give itself one.

That makes the ticket one unit of work rather than one commit:

1. The runner claims the ticket (`ready → doing`) and runs `/implement`.
2. `/implement` builds, writes the `Record`, commits, and sets `review`.
3. The runner runs `/critique` in a fresh session against the ticket.
4. Clean → the runner sets `done`. Findings → they are written into the ticket's
   `## Findings`, the runner counts a review round and sets `doing` again, and the
   rework is another commit.
5. Review rounds run out → the runner writes the `exhausted` halt.

`/critique` is not a pipeline-only skill and should not be written as one: it is the
project's code review, usable by hand on any branch or diff. Inside the pipeline it is
simply given a ticket to judge against.

### What `/implement` contains, given the other skills exist

The plan came from plan mode; TDD and the conventions live in the coding-standard
skill, which fires whenever code is written, ticket or not. Fold that standard into
`/implement` and it would apply only to ticket-driven work, which is not most of what
happens in a repository.

So what is left is small, and it is all of one kind — **constraints against what a
helpful agent would otherwise do**:

- **Halt rather than improvise.** The default response to a missing precondition is to
  work around it. The skill's job is to stop and name the kind.
- **Do not reopen the solution.** The default response to noticing the approach is
  suboptimal is to improve it. The skill's job is to not.
- **Write the `Record`** in the form (e) can walk: which test names which `AC-id`. It
  is the only evidence that a criterion was covered rather than claimed.
- **Leave the ticket in `review` or `halted`, never `done`.** A session does not claim
  its own work, release it, or declare it finished: the runner owns `ready → doing` and
  the final `done`, because a session that dies cannot undo its own claim and a session
  that reviewed itself has not been reviewed.

That is the test for whether this skill earns its place: what does it contain that a
competent agent holding the ticket and the conventions would not already do? A skill
that says "write good code" is fluff. A skill that says "stop here, do not fix that,
leave this behind" is not — the two differ in kind, not only in subject.

Its adversary checks the code against **the ticket**, never against the original
problem. If that reviewer is allowed to reopen "is this the right solution," the
pipeline relitigates every prior stage and stops converging.

(d) sees one ticket, so it can only check what that ticket claims. Whether the *sum*
of the tickets is the feature is a question nothing at this stage can answer — that
is (e)'s job, and the reason (e) uses the feature rather than reading the diff.

## e — Acceptance · `/accept`

One pass over the finished feature, using it the way its user would. It answers two
questions that a per-ticket review is structurally blind to: does the feature hold
together, and does it satisfy the intent.

It compares against the intent's **written** conditions, never against its own
reconstruction of what the problem was. Otherwise it drifts and starts passing work
for reasons nobody agreed to.

"No" is not actionable on its own, so the verdict routes:

- **The problem was misframed** → back to (a).
- **The solution does not address the problem** → back to (b); the intent still holds.
- **The code does not match the ticket** → back to (d), and this is a bug in the
  pipeline as well as in the work, because (d)'s adversary should have caught it.
- **A criterion nobody claimed went unbuilt** → back to (c); the slicing lost it.
- **A condition cannot be checked at all** → back to (a). It was never observable, and
  (a)'s adversary should have caught it — the one route that indicts the front of the
  pipeline rather than the work.

On an **accepted** verdict, `/accept` deletes the paper — intent, solution, tickets —
in one commit. The paper is the record of what was asked for, and git history keeps
every deleted file, but the working tree should carry the code and not the
scaffolding. It refuses rather than trusts, and stops on the first check that does not
hold: in a repository, on a branch of its own, every ticket done, and the tree clean so
the commit is deletions and nothing else.

Before deleting, it **promotes anything durable that was not already written**: a note
that belongs in the architecture document, a domain term worth recording. ADRs are
written at (c), while the argument that produced them is still in context; what reaches
(e) is whatever the build turned up afterwards. Deletion is the moment the rest is
lost, so it is the moment to ask.

**Abandonment is the same act with one check waived.** A topic dropped without being
built has tickets that are not done; `/accept --abandon` skips that check and only that
one, writes a verdict of `abandoned` with the reason, and deletes the paper. An intent
nobody pursued is information about the intent, and the verdict is the only trace that
survives it.

`VERDICT_<TOPIC>.md` is the exception to the deletion: it is the one page that survives
and merges with the change. That makes it the pull request description as well as the
judgement — what the branch does now that it did not before, what a reviewer should
look at, what is still uncertain, alongside the conditions and what they cost. One
page, because a separate handover would duplicate three quarters of it.

**The merge is a human act**, and it is the third mandatory touchpoint: a person reads
the verdict, reviews the branch, merges. Nothing merges on a verdict alone — the
verdict says the work satisfies the intent, not that a maintainer wants it.

(e) is itself unchecked. Its adversary is the customer.

## The rules that hold it together

**1. No adversary reopens a decision ratified upstream.** A reviewer may look at the
codebase, the domain and prior art — (b)'s drawback hunt requires exactly that — but
it may not relitigate the problem, the constraints, or the chosen approach once those
are ratified. Stage (e) is the only one permitted to reach back to the problem. This
restriction, not blindness to the outside world, is what makes the middle of the
pipeline safe to run unattended.

**2. "Complete" means bidirectional coverage, at (b) and (c).** Otherwise each
reviewer invents its own bar and you get rubber-stamps or endless blocking. Forward
coverage catches scope creep; backward coverage catches gaps.

- (b): every acceptance criterion traces to a condition in the intent, and every
  condition is covered by at least one criterion.
- (c): every ticket traces to the solution, and every `AC-n` lands in some ticket.

The `AC-n` half is mechanical, because those carry ids. Edge cases and non-goals do
not, so whether the tickets respect *those* is a reading — worth saying, since the
rest of this section claims to be a check rather than a judgement.

(a) and (d) have different checks, and it is worth not pretending otherwise: (a)'s is
that every condition is *observable*, which is a judgement about wording; (d)'s is
that every criterion the ticket claims is named by a test, which is forward-only
because (d) sees one ticket.

**3. Preference lives in (a), not in review.** Any question of the form "would we
rather have X or Y" must be answered by a constraint the customer ratified, or it
does not get answered by the pipeline at all — it becomes the interrupt at (b).

## The skills

`/idea → /solve → /slice → /implement → /accept`. Five verbs, one per stage. The
names are reused where the act is the same, but every one of these is a new skill
against a new set of artifacts; nothing is a drop-in rename.

They divide by how they are reached. **`/idea`, `/solve` and `/accept` are typed** —
each opens or closes something a person is accountable for, and that should be
deliberate rather than inferred. **`/slice`, the software-design skill, the coding
standard, `/implement` and `/critique` are discovered** from the work already
happening, though `/critique` is also typed constantly, because reviewing a branch is
a thing people want on its own.

Two more skills exist that are not stages, because the knowledge they carry is
consumed at moments rather than in a sequence:

- **a software-design skill** — domain language, module separation, when something
  deserves an ADR. Consumed at plan time, by whoever is deciding the shape.
- **the coding standard** — TDD and the conventions, today mixed into
  `coding-conventions`. Consumed at write time, by whoever is typing.

Splitting those two apart is the point: they are read by different agents at different
moments, and today they are one file that neither reads fully.

`/solve` and `/slice` replace `/to-solution` and `/spec-to-tickets`. Those name a
*transform* and encode their own input in the name, so they read as plumbing and have
to be renamed whenever their input changes. A stage should be named for the act it
performs.

`/slice` in particular carries its own standard. The output is not merely smaller
pieces — it is *vertical slices*, each independently buildable and testable.
`/decompose` implies breaking down through the layers, which is the wrong axis;
`/split` says nothing about how; `/sequence` names the ordering, which is the
secondary job. The name that states the quality bar is the one the adversary can
check against.

`/accept` takes over the name from `accept.sh`, which is removed. The script's
refusals survive into the skill; its stance that acceptance is unreachable by an
unattended session does not, because the verdict is exactly what the pipeline is for.

### Discovery is a description-matching problem

This is the part most likely to fail quietly. A discovered skill fires when its
description matches the situation, so "`/slice` is discoverable from plan mode" really
means its description has to match *planning a code change* — which is close to all
plan-mode use, including planning research, an investigation, or a conversation that
never produces code.

Both failure directions are bad: fire on everything and every plan pays for it; fire
unreliably and the design silently stops happening, which is the original failure this
whole pipeline exists to prevent.

The trigger conditions therefore need writing as carefully as the skills themselves,
and they can only be tuned by watching them miss. The software-design skill has the
same problem one notch narrower — it should fire on a new concept or a crossed
boundary, not on a three-line edit.

#### What the experiment showed

Thirty-one headless runs against a stub `/slice` in an empty project, before any of
this was built.

A first description keyed on *"a settled solution is being turned into the work that
builds it"* scored 12 of 14, with two stable failures: "I want to refactor the payment
module. Plan it." never fired (0 of 4), and "Plan the rollout of the new pricing page
to customers" always did (3 of 3). Both have the same cause — the description was
written in the vocabulary of this pipeline rather than in the vocabulary of a request,
and its only exclusion was research.

A second description fixed both, and is the starting point for the real skill:

> Use when planning how to carry out a change to this codebase - a feature, a bug fix,
> a refactor, a migration - so that the work can be built. Cuts it into vertical
> slices, each independently buildable and testable, and writes them as tickets. Not
> for planning research, investigation, a meeting, a rollout, or any work that does not
> change code.

**The rule:** name the shapes a request actually arrives in, and enumerate the
exclusions concretely. Abstractions about your own process match nothing, because the
person asking does not know them.

It also fires without the word "plan" ("Add rate limiting to the API" in plan mode) and
stays quiet in ordinary auto mode ("Add a retry to the fetch call"), which is the
separation (c) and (d) need.

**It is stochastic.** One prompt fired three times out of four — same words, same
description. Discovery is a probability, not a switch.

That is survivable here for a reason worth stating: a miss produces an ordinary plan,
which is this design's documented floor, and it is *visible* — no ticket directory
appears, so the runner has nothing to run. The degradation property is not only a
convenience for small changes; it is what makes discovery safe to depend on.

**What this did not test:** competition. One skill in an empty project is the easy
case. In a repository where `/critique`, the software-design skill and the coding
standard all overlap this territory, matching is a different problem, and that is the
experiment that could still falsify this.

### What is deliberately dropped

The old spec format carried machinery this one does not. Dropping it loudly is the
point — most of it was never shown to improve anything, and a section nobody checks
is a section that costs attention at every stage and pays nothing back.

- **`spec_hash`** — genuinely load-bearing, and genuinely replaced: self-contained
  tickets cannot be silently redefined, which is the only thing the freeze protected.
- **`## Domain`, ubiquitous language, `## ADRs`, three-tier defaults, `## Journeys`**
  — dropped as *required spec sections*. These were produced on every run and consumed
  almost never, which is the worst shape a document section can have.

  Domain language and ADRs return in a different form: as knowledge in the
  software-design skill, surfaced at plan time when a decision is actually being made,
  and written down only when there is something to write. That is the capability
  without the paperwork — the old format produced the artifact and skipped the
  thinking; this produces the thinking and makes the artifact optional.

## The artifacts

### `INTENT_<TOPIC>.md` — from `/idea`

```
# Intent: <the problem in one line>

## Problem                      the problem underneath, no solution in it
## Evidence                     what makes this real - incidents, quotes, numbers
## Done when                    C-1 … C-n, each observable, append-only
## Constraints                  what we optimize; what is off limits; budget, deadline
## Not this                     adjacent problems deliberately excluded
## Whatever they arrived with   the original request, verbatim
## Open questions
## Ratified                     who said "yes, THAT is my problem", and when
## Routed back                  appended by /accept each time a verdict sends work back
```

`Done when` and `Constraints` are load-bearing: everything downstream is judged
against them, and `Ratified` is what gives them their authority.

### `SOLUTION_<TOPIC>.md` — from `/solve`

```
# Solution: <the approach in one line>

## Intent               link + the C-ids it answers
## Approach             the chosen solution, in prose
## Behaviour            AC-1 … AC-n, each tagged (C-2) (C-3)
## Edge cases
## Non-goals
## Accepted tradeoffs   what this costs us, owned
## Ruled out            each alternative, and why it lost
## Open concerns        including constraints appended to the intent
```

`Accepted tradeoffs` and `Ruled out` are required, not optional. They are what the
adversary at (b) has to bite on, and without a named alternative the tradeoffs
degenerate into hedges.

### `tickets/<topic>/<n>-<slug>.md` — from `/slice`

```
---
solution:  SOLUTION_<TOPIC>.md   # for the runner's drift pre-flight only; sessions never open it
satisfies: AC-1, AC-4
after:     2-<slug>, 5-<slug>     # dependencies, comma-separated, or empty
status:    ready | doing | review | done | halted
attempts:  0                     # runner-owned
reviews:   0                     # runner-owned
---

## Build            what this slice is
## Done when        the criteria, copied verbatim from the solution
## Context          enough to build without reading the solution
## Not here         the boundary against the neighbouring ticket
## Record           written by /implement: the tests that name each criterion
## Findings         written by /critique: what the review wants changed
## Halt             written by whoever stopped: kind, and what it was blocked on
```

One file per slice, so a ticket has an identity, a status the runner can read, and
somewhere to write its own outcome without contending with its neighbours.

**Who writes what.** `/implement` writes `Record`, `Halt` and `status: review`;
`/critique` writes `Findings`; the runner writes everything else — `status: doing`,
`done`, the `attempts` and `reviews` counters, and the `exhausted` halt. The counters
live in the file rather than in the runner's memory because the runner is expected to
die and resume: it waits out usage limits, and a count that does not survive that is
not a ceiling.

### `VERDICT_<TOPIC>.md` — from `/accept`

```
# Verdict: <accepted | rejected | abandoned>

## Conditions       one row per C-id: met / not met / unverifiable, and the evidence
## Tradeoffs paid   what the solution said it would cost vs. what it cost
## Routing          on rejection: back to /idea, /solve, /slice or /implement, and why
                    on abandonment: why it was dropped

## What changed     what the branch does now that it did not before
## Look here        what a reviewer should spend their attention on
## Still uncertain  what nobody has established
```

The lower three sections are the pull request description. The verdict is the only page
that survives the paper, so it carries both jobs rather than duplicating three quarters
of itself into a separate handover.

`Tradeoffs paid` is not needed for the verdict either. It earns its place because the
verdict merges with the change — so it is where a pattern of optimistic estimates
becomes visible across topics, in history, to a person reading back.

A condition marked `unverifiable` is not a pass. It routes back to (a): the condition
was never observable, which is a defect in the intent rather than in the work.

## The ID chain

`C-n` in the intent → each `AC-n` tags the C-ids it serves → each ticket tags its
AC-ids and copies their text → each test names its AC-id → the verdict walks the
C-ids.

This is what makes the coverage rule cheap: an `AC` with no `C` tag is scope creep, a
`C` that nothing references is a gap, and both are mechanical to find.

It is not, however, free of judgement. A tag proves a link was *claimed*, not that it
holds: an `AC-7 (C-2)` that restates `C-2` badly, or a ticket that tags an `AC` it
only half implements, passes every structural check and fails the intent. The ids
make the *absences* mechanical. Correctness of what is present stays a reading.

## The adversaries are one skill

`/verify <artifact>`, with a per-stage contract — not four review skills. The core
check is the same at every boundary; only the extra clauses differ (tradeoff-hunting
at b, slice independence at c). Four near-identical reviewers drift apart within a
month.

It runs as a **subagent with a fresh context**. That is the whole requirement, and it
is the requirement that matters: an agent reviewing inside the context that produced
the artifact is attached to the reasoning that produced it, has already accepted every
step, and will read its own intentions into the words. A reviewer that has seen only
the artifact and its contract reads what is actually written.

Nothing else about the reviewer is specified — not the model, not the effort. A fresh
context is cheap, is arrangeable everywhere the pipeline runs, and is checkable by
construction: a subagent has one or it does not.

## Unattended execution

After plan approval the ticket directory is handed to **the runner** — `loop.sh`'s
successor — which walks `tickets/<topic>/` in dependency order, driving one
`/implement` session per ready ticket and one `/critique` session per committed ticket,
each in its own fresh context. Everything a session needs is in the ticket and the code; it never
consults the solution, which is what lets it run without a person.

Small work does not need it: you can run the tickets yourself in auto mode, which is
the same skill doing the same thing without the loop around it. The runner is what you
reach for when nobody is watching.

**The runner is a script, not a skill, and that is not an implementation detail.** A
session cannot enforce a budget it is spending, and cannot wait out a limit that has
already stopped it. Anything that must hold when the session is dead or misbehaving has
to live outside it:

- iteration and dependency order,
- the attempt and review ceilings,
- the `drift` pre-flight, since no session may read the solution,
- **ticket claiming.** The runner writes `ready → doing` before launching a session and
  resets `doing → ready` when a session exits without reaching `done` or `halted`.
  Sessions never claim their own work, because a ticket stuck at `doing` after a crash
  is indistinguishable from one being worked on, and only the process that launched it
  knows which,
- **wait-and-restart on usage limits**, the clearest case of all: a session that hits a
  limit cannot decide to sleep and resume, because it is no longer running.

**It works on its own branch and refuses to run on the main branch.** One topic per
branch, one ticket directory per topic. Two topics never share a directory, and
nothing merges until (e) returns an accepted verdict.

### Halts

An unattended session that cannot proceed writes a halt into the ticket and stops. It
does not improvise. The kinds a session writes:

- `blocked` — a precondition the ticket assumed is not there.
- `undecided` — a decision the constraints are silent on, surfacing during a build
  rather than at (b). The session cannot ratify a new constraint, so it stops.
- `mystery` — a failure the agent cannot explain, as distinct from one it cannot fix.

Two kinds are the **runner's**, because in both cases the party that would report it
is not in a position to:

- `exhausted` — the attempt or review-round budget ran out. A session that has run out
  of attempts is, by definition, not running.
- `drift` — a ticket and the solution no longer agree. A session never reads the
  solution, and a committed ticket is revisited by nobody. It is a pre-flight refusal,
  checked before any session starts.

A halt is addressed to a person. Reading halts is not one of the three happy-path
touchpoints — it belongs to the conditional class, because a run that halts has
already stopped being unattended.

### Ceilings

Bounded attempts at every loop, because an unbounded retry is indistinguishable from a
hang: a fixed number of attempts to get a ticket green, and a fixed number of review
rounds per ticket.

The runner enforces those two, because nothing else can. A ceiling a session is asked
to respect is not a ceiling — it is a suggestion made to the thing spending the budget.
Passing a limit must be something a person decides, not something the loop grants
itself.

**The route-back cap is different and cannot live here.** How many times a verdict has
sent the work back is a count across separate runs, decided by a person at (e), outside
any runner. It is recorded in the intent — a `## Routed back` line, appended each time,
which survives because `C-n` ids are append-only and the intent is only deleted on
acceptance. When that list grows long enough to embarrass, the honest conclusion is
that the intent is unsatisfiable as written, and that too is a person's call.

### Abandonment

A topic can be dropped mid-run. It is `/accept --abandon`, described under (e): the
same deletion with the every-ticket-done check waived, and a verdict of `abandoned`
recording why. Deciding to abandon is a person's; nothing in the runner may conclude
it.

## The short path

There is less of one than there looks, because the normal path already collapses on
its own. A small change is plan mode with no intent file behind it, one ticket in the
directory, auto mode, a verdict — the same five stages, most of them costing nothing.
That is what "degrades to the unaided harness" buys: the short path is not a mode, it
is what the pipeline looks like when the work is small.

One real branch remains.

### Collapse 1: fold (a) into (b)

Triggered by input shape:

- **`/solve INTENT_<TOPIC>.md`** — conditions and constraints already exist and are
  ratified. Go straight to the approach.
- **`/solve "<prose>"`** — derive `Done when` and `Constraints` first, show them, wait
  for the "yes", then continue into the same file, which then opens with those
  sections instead of linking an intent.

Stage (a) has not been skipped: it runs as the first move inside `/solve`, on prose
instead of a file, as a section rather than a document.

**The intent is the conditions-and-constraints block, wherever it lives.** Everything
downstream is written as though it were a file, and on this path it is not — so read it
as addressing the block: `/accept` judges against those sections inside
`SOLUTION_<TOPIC>.md`, `## Routed back` is appended there, and the coverage rule runs
within the one file. The one asymmetry: a verdict that routes back to (a) **promotes
the block into a real `INTENT_<TOPIC>.md`**. Routing to (a) means the problem statement
itself is in question, and a problem statement being reworked deserves a document of
its own rather than a section of the solution it just invalidated.

**The ordering constraint that does all the work.** The conditions must be derived
*from the request, before any approach exists*. Derived after or alongside the
approach, they come out self-serving — they will be precisely what the solution
happens to satisfy. Then (b)'s adversary is checking coherence against a target the
solution wrote for itself, and `/accept` is grading the answer against the answer.
Circular, and silently so. The stop-for-ratification is what keeps the conditions
independent of the solution.

**`/solve` must be able to refuse.** Prose input means the request was short, not that
the problem is. If, on deriving the conditions, it cannot state them observably, or
the list runs long, or the request is solution-shaped with no problem visible behind
it — it stops and hands back to `/idea` rather than guessing. Without that valve,
prose becomes the default door and (a) quietly stops happening for anything.

### There is no collapse 2

Skipping (c) looked like the other half of the short path. It is not a collapse at
all: plan mode runs either way, `/slice` emits one ticket instead of several, and the
slice test — one seam touched, no criterion that cannot be built and verified
alongside the others — is `/slice`'s to answer. When the answer is "no" it simply
emits more tickets. Nothing to decide, no transition to describe.

If no skill loads at all, plan mode still produces a plan and auto mode still builds
it. That is the floor, and it is a reasonable floor.

This is why the two collapses are separate. The first is a real branch with a real
failure mode; the second is what the normal path already does when the work is small.

### When collapse 1 is appropriate

It is safe when the problem **already arrives as observable conditions**: a bug with
a reproduction, a failing check, a stated constraint violation. There the `C-n` list
is nearly free to write, because the reproduction *is* `C-1`.

It is not safe when the trigger is "I already know what to build." That feeling is
produced by the same thing stage (a) exists to catch — a solution arriving pre-framed,
with the problem never written down. The criterion has to be a property of the
*request*, not of anyone's confidence about the answer. The pipeline cannot police
why the short path was chosen; the refusal above is the honest substitute.

## Known limits

- **The pipeline produces *a* working solution, not the best one.** The quality
  ceiling is set by whatever (b) proposes first, raised only by the constraints in (a)
  and by the ruled-out-alternative requirement. A deliberate trade for
  unattendedness, and it should stay deliberate rather than becoming a surprise.
- **An error in (a) survives every downstream check** and surfaces only at (e). The
  customer's confirmation is the only defence, so it is worth spending real effort on.
- **Memory across topics depends on the design skill actually writing things down.**
  Domain language and ADRs are no longer mandatory sections, so they exist only when
  the software-design skill judges there is something worth recording and a person
  ratifies it at plan approval. That is the right trade — the old format produced the
  artifact and skipped the thinking — but it means the record is now discretionary,
  and a run of small changes leaves no trace at all. Whether that costs anything is an
  open question to answer by observation.
- **Discovery can fail silently.** (c) and (d) depend on skills firing from a mode
  rather than being typed (the runner invokes `/implement` explicitly, so only the
  attended path is exposed). A description that matches too narrowly means the design
  quietly stops happening, and nothing in the pipeline detects its own absence.
- **(e) derives its own walkthrough** from the conditions rather than following
  written journeys. Thinner, and it puts more weight on the conditions being genuinely
  observable — which is a check something already performs, unlike the journeys.
- **Nothing covers post-merge reality.** (e) judges against the intent as written;
  whether the intent described the world correctly is a question only production
  answers.
