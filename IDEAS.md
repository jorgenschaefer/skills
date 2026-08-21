# Ideas

Feature ideas for this repository, ordered by what each buys against what it
costs. The measure is the pipeline's own goal: correct, usable, high-quality,
maintainable software. An idea that buys wall clock or tidiness ranks below one
that closes a hole in what the pipeline can prove.

`/discovery` reads this file as its parking lot, so every entry says what
problem it solves, what it would touch, and what it costs.

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

Four of sixteen skills have one problem: the skill does not fire, and a skill
that does not fire is worth zero however good its contents.

- `/plan` collides with the harness's plan mode.
- `/critique` competes with the built-in code-review skill and loses by default.
- `upgrade-dependencies` has `disable-model-invocation: true` and no event that
  fires it, so nothing ever calls it.
- `implement` wants a broader trigger than "a ticket from a `tickets/`
  directory".

One pass over every `description` field, not four separate edits. The rename is
the only real cost: `/plan` is named in README.md, discovery/SKILL.md,
implement/SKILL.md, propose-change/SKILL.md, decision-brief/SKILL.md,
SPEC_FORMAT.md and all four copies of TICKET_FORMAT.md.

## 4. Show the user the domain model

Discovery models the domain thoroughly - actors, work objects, entities,
aggregates, actions, events - and then says outright that "the domain story is
the analysis; the user story is what you record". The model reaches the spec's
Domain section, but it is never put in front of the user as a proposal during
the interview.

Aggregate boundaries appear in discovery's own list of the hard-to-reverse
decisions to be most careful about. They are exactly the part of the model most
worth a veto, and the user never sees them until the spec lands.

The fix: present the work objects and the actions on them as a proposal, in its
own turn, the way the running list of defaults is confirmed.

Touches: discovery/SKILL.md.

## 5. Give the small-change lane somewhere to promote

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

## 6. Review with a different model than the one that wrote the code

Every step is `claude -p` with one model in a fresh serial session. Two
deterministic checks sit under four prose reviews - quality, code, `/trace`,
`/critique` - all of them the same model marking its own homework.

A different model for the reviews is the cheapest available gain in
independence: a flag, not a redesign. The same argument applies to reasoning
effort, where `/plan` - decomposition, the costliest mistake in the pipeline -
and a sha256 comparison get the same budget today.

Touches: loop.sh (`run_step`), implement/SKILL.md (the review dispatches).

## 7. Let the driver recover from drift

`drift` and `stale-spec` have a documented mechanical recovery - `/plan
--refresh` - and the driver never calls it. It retries infrastructure failure
seven times over about three hours (`RETRY_DELAYS`) but gives up on a rename at
2am.

A refresh is not a guess; it re-derives from the code as it is. Bound it to one
per run and to those two halt reasons and the no-guessing contract holds.
`blocked` and `mystery` still need a human.

Touches: loop.sh (the halt path).

## 8. Keep the evidence a run produces

`LOG_DIR` lands under `$TMPDIR` and the transcripts are framed as debugging
aids, not artifacts. So nothing accumulates across runs: which halt reasons
recur, which convention findings repeat, how often the second review pass finds
anything, cost per ticket.

That is the only empirical input `/improve-skill` could have. Today the skills
are iterated by feel.

Touches: loop.sh (`LOG_DIR`, drain, the halt path), improve-skill/SKILL.md.

## 9. Something in the pipeline has to run the software

Verification is one check command, the test suite, and four prose reviews.
`SPEC_FORMAT.md` has a Design section with screens and states - empty, loading,
error, partial, disabled - plus accessibility criteria, and no step ever renders
one.

A feature can be green, traced, critiqued and handed over while failing to boot.
This ranks above mutation testing (#10) for that reason: a suite can be fully
mutation-killed on an app that does not start. It is also the only entry here
that touches *usable* rather than *correct*.

The tooling is already present - the harness ships a `run` skill and
claude-in-chrome. The shape is a new skill between `/trace` and `/handover`,
filing a ticket per gap the way `/trace` does, so a failure re-enters the loop
instead of being patched in behind the checks.

Touches: a new skill, loop.sh (drain). The most expensive entry above the line,
and the biggest hole.

## 10. Mutation testing per ticket, which means the tooling ban goes

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

## 11. Separate now from later in discovery

Discovery holds scope to one shippable feature and parks the rest, but nothing
makes the spec state the smallest version worth shipping and what deliberately
comes after it. The split test catches a second feature hiding inside the first;
it does not catch a single feature specified past its MVP.

Touches: discovery/SKILL.md, discovery/SPEC_FORMAT.md.

## 12. A lane for the work that keeps code maintainable

propose-change bounces it explicitly: nobody outside the code can observe a
refactor, so it is below the floor and "wants doing directly". cleanup-repo is
manual and stops for approval. upgrade-dependencies is wired into nothing.

So a suite whose goal is maintainable software routes every maintenance activity
outside its own TDD and review discipline. Features get four reviews; the work
that keeps the codebase alive gets none.

The objection is real - a refactor has no new behavior, so nothing can be
written RED. But that is the criterion, not a disqualification: the existing
suite stays green and the diff provably changes no behavior, which is checkable,
and is what #10 is for. `TICKET_FORMAT.md` already carries a second ticket kind
for `/trace`'s remediation tickets; a third kind is the natural home.

A decision, not an edit. Touches: TICKET_FORMAT.md (all four copies),
propose-change/SKILL.md.

## 13. A durable system description, regenerated rather than maintained

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

## 14. Check hard-to-reverse external choices against a primary source

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

## 15. State the iron law once, in the one place that owns shared rules

"Don't report done on something you didn't run" exists across the pipeline only
in partial, skill-local forms: implement's RED confirmation, critique's
verify-before-reporting, trace's evidence rules. cleanup-repo, handover,
repo-overview and propose-change state nothing of the kind.

coding-conventions exists precisely so rules live in one place instead of
drifting across skills, and this rule is not in it.

Touches: coding-conventions/SKILL.md, and a reference from the skills that
currently restate a fragment of it.

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
  leans on.
- **Is `/debug` worth keeping?**
- **Is `ubiquitous-language-init` still useful?**
- **Should `/decision-brief` become a summary of the discovery spec** rather
  than a separate brief?
- **Should `upgrade-dependencies` cover adding a new dependency**, not only
  upgrading existing ones?
- **Should `/critique` generalise** to fire on any code review request, instead
  of competing with the built-in skill?
- **Should `/handover` run inside the loop at all?** It cannot finish there:
  promotion and deletion wait on a user who is asleep, so the driver produces
  the brief and stops, and the human who accepts in the morning runs
  `/handover` again - which re-derives the same brief from the same tickets.
  The driver now prints the brief whole rather than losing it in a transcript,
  which is worth having either way. But the alternative is that the loop ends
  at `/critique` and simply says to run `/handover`, spending one session
  instead of two and delivering the brief into the conversation that can act on
  it. Against that: a run whose brief nobody reads until morning is still a run
  whose brief exists, and reading it is how you decide whether to bother
  accepting at all.
- **handover and propose-change have never been run.** Both sit in the main
  path. Whatever is wrong with them is still undiscovered.

## Rejected

Kept here so they don't get re-proposed.

- **Warming context across tickets.** The cold start is why a ticket is a closed
  unit. At most prime facts (check command, baseline sha), never judgment.
- **Relaxing `MAX_PASSES=2`.** Non-convergence is a signal, not a budget
  problem.
- **OpenSpec's living capability specs**, updated by ADDED/MODIFIED/REMOVED
  deltas and archived per change. Stale specs are worse than none; the archive
  discipline is the maintenance burden the delete policy avoids on purpose. #13
  is the missing complement, not a replacement.
- **The byte-identical TICKET_FORMAT copies.** Deliberate - diff is the parity
  check, and cross-skill relative paths break on independent install.
- **The two-door structure, the split test, and `/implement`'s no-questions
  contract.** All hold up.
- **BMAD's named persona agents.** Ceremony without gain; the rule that the
  reviewer does not know about tickets is the better instinct.
- **Spec Kit's article that every feature must begin as a standalone library.**
  Flatly contradicts YAGNI and deep-modules.
