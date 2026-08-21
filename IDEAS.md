# NOTES

## Findings
- I never see the proposed domain model + actions
- /plan has a bad name, it's confused with the /plan mode command
- A run can stop without halting. Ticket 14 of notebooklm-mvp ended `end_turn`/
  success with status still `todo` and no `## Halt`: the model left the baseline
  `npm run check` in a background task and ended its turn waiting on it. In
  `claude -p`, end_turn is process exit, so Monitor and background tasks never
  report back. /implement forbids this for review dispatches; nothing covered
  the verification command.

## Pipeline

Three changes, ranked by leverage. Evaluated 2026-08-21 across the whole flow
(discovery -> plan -> loop.sh -> implement/trace/critique -> handover).

### 1. Executed evidence instead of prose review

The verification stack is model-judging-model almost everywhere. Deterministic:
the check command and the test suite. On top of those sit four prose reviews
(quality, code, /trace, /critique), all the same model marking its own homework.
/trace names this itself - "the one check in the pipeline that isn't" - and then
declines to fix it: mutation testing only where a tool is already configured,
plus an explicit `Don't install tooling`. So most projects get the fallback
/trace itself calls "proves less".

- Make mutation testing over the ticket diff a per-ticket gate. It mechanically
  checks the exact property /implement claims (every behavior pinned by a test
  that would fail without it), and it catches the gap on the ticket nothing is
  built on yet instead of ten tickets later.
- Let it replace the quality review rather than join it. That review already
  runs only once, is the first thing dropped under REVIEWS=code, and a surviving
  mutant answers its core question objectively.
- Add an acceptance step that drives the running system. The spec has a Design
  section with screens and states; nothing in the pipeline ever renders one.

Touches: trace/SKILL.md (the tooling ban), implement/SKILL.md (Review it),
loop.sh (REVIEWS). Costs a one-time tooling ticket per project - which is what
the ban currently forbids, so that rule is the one that has to go.

### 2. Heterogeneous models, and parallel tickets over the DAG

Every step is `claude -p` with one model in a fresh serial session.

- A different model for the reviews than for the implementation is the cheapest
  available gain in independence: a flag, not a redesign. Same for staggering
  reasoning effort - /plan (dekomposition, costliest mistake) and a sha256
  comparison get the same budget today.
- Wall clock is the sum of all tickets although `depends_on` already declares
  the DAG. Keep the uncertainty-first prologue serial - that ordering is why a
  halt costs one ticket instead of ten - and parallelise the independent tail in
  worktrees.
- Then REVIEWS=code can die. It trades quality for time; parallelism trades
  money for time, which is the better trade.

Touches: loop.sh (run_step, drain), plan/SKILL.md (its ordering rule already
fits).

### 3. Let the driver recover mechanically, and keep evidence from a run

- `drift` and `stale-spec` have a documented mechanical recovery - /plan
  --refresh - and the driver never calls it. It retries infrastructure failure
  eight times over three hours but gives up on a rename at 2am. A refresh is not
  a guess; it re-derives from the code as it is. Bound it to one per run and to
  those two reasons and the no-guessing contract holds. `blocked` and `mystery`
  still need a human.
- Logs go to /tmp and are explicitly discarded ("debugging aids, not
  artifacts"), so nothing accumulates: which halt reasons recur, which
  convention findings repeat, how often the second review round finds anything,
  cost per ticket. That is the only empirical input /improve-skill could have,
  and the skills are currently iterated by feel.

Touches: loop.sh (drain, the halt path, LOG_DIR), improve-skill/SKILL.md.

### Considered and rejected

- Warming context across tickets. The cold start is why a ticket is a closed
  unit. At most prime facts (check command, baseline sha), never judgment.
- Relaxing MAX_PASSES=2. Non-convergence is a signal, not a budget problem.
- Touching the two-door structure or the split test. Both hold up.

## Pipeline, compared against the field

Evaluated against BMAD, GitHub Spec Kit, OpenSpec, GSD Core, Superpowers and
mattpocock/skills, asking one question: what do they have that we don't, that
serves quality surviving contact with maintenance.

Items 1 and 2 are both inside Pipeline #1 above. The new claim here is their
order: mutation testing sharpens a test suite that already exists, and nothing
at all checks that the software runs. A suite can be 100% mutation-killed on an
app that does not boot.

### 1. Nothing in the pipeline ever runs the software

The verification stack is one deterministic check and four prose reviews.
SPEC_FORMAT has a Design section with screens and states - empty, loading,
error, partial, disabled - plus accessibility criteria, and no step ever renders
one. A feature can be green, traced, critiqued and handed over while failing to
boot.

GSD keeps a UAT phase; BMAD has a QA persona whose artifact is a validation
report. The tooling is already here: the harness ships a `run` skill and
claude-in-chrome.

Touches: a new skill between /trace and /handover, filing tickets for gaps the
way /trace does; loop.sh (drain).

### 2. Mutation testing per ticket, which means the tooling ban goes

Everything the pipeline claims rests on one property - every behavior pinned by
a test that would fail without it - and today that property is asserted by the
model that wrote the test. Mutation testing is the executable form of the same
sentence.

The blocker is ours: trace/SKILL.md says "Don't install tooling to satisfy
this", so most projects get the fallback trace itself calls "proves less". That
rule is what has to go, at the cost of a one-time tooling ticket per project.

Touches: trace/SKILL.md (the ban), implement/SKILL.md (Review it), loop.sh.

### 3. ADRs are written and never read

`grep -rln ADR --include=SKILL.md` returns one file: handover. It can promote an
architecturally consequential choice into an ADR, and nothing ever reads one
again - not discovery, not plan, not implement, not critique.

So the only durable decision record the pipeline produces has no consumer.
Feature 12 can contradict a decision ratified at feature 3 and nothing notices,
which is the exact failure ADRs exist to prevent. Spec Kit re-reads its
constitution on every command; mattpocock keeps CONTEXT.md and ADRs current
inline.

Cheapest item on this list by a wide margin: three bullets in three files.

Touches: discovery/SKILL.md and plan/SKILL.md (read the ADRs the way they
already read UBIQUITOUS_LANGUAGE.md), critique/SKILL.md (contradicting a
ratified ADR is a finding).

### 4. The standard doesn't reach the skills that decide what gets built

coding-conventions is read by six of sixteen skills: cleanup-repo, handover,
critique, plan, implement, itself. Not discovery - which settles the design
language, the data shapes, the aggregate boundaries and the whole Implementation
decisions section. Not propose-change, which picks an approach and writes it
into a ticket. Not trace.

A ticket can therefore be born violating the layering doctrine, /implement
builds it faithfully, and the code review flags a structure the ticket
mandated. The rubric binds the builder and the reviewer but not the designer.

Touches: discovery/SKILL.md, propose-change/SKILL.md (one line each).

### 5. A durable system description, regenerated rather than maintained

Deleting the spec and tickets at handover is right, and worth defending against
OpenSpec's model of living capability specs updated by ADDED/MODIFIED/REMOVED
deltas and archived per change. Stale specs are worse than none, and OpenSpec's
archive discipline is the maintenance burden we avoided on purpose.

But after twenty features there is a glossary, some comments, a few ADRs, and no
document saying what the system does or how it is shaped. The repo-overview note
below already names the fix.

The move is regenerate-instead-of-maintain: repo-overview writes ARCHITECTURE.md
marked as re-derived from code and never hand-patched. That keeps the anti-stale
principle - it is a build artifact, not a maintained doc - and closes the
gap the delete policy leaves open.

Touches: repo-overview/SKILL.md.

### 6. No lane for the work that keeps code maintainable

propose-change bounces it explicitly: nobody outside the code can observe a
refactor, so it is below the floor and "wants doing directly". cleanup-repo is
manual and stops for approval. upgrade-dependencies is wired into nothing.

So a suite whose goal is maintainable software routes every maintenance activity
outside its own TDD and review discipline. Features get four reviews; the work
that keeps the codebase alive gets none.

The objection is real - a refactor has no new behavior, so nothing can be
written RED. But that is the criterion, not a disqualification: the existing
suite stays green and the diff provably changes no behavior, which is checkable
and is what #2 is for. TICKET_FORMAT already carries a second ticket kind for
/trace's remediation tickets; a third kind is the natural home.

A decision, not an edit. Touches: TICKET_FORMAT.md (x4), propose-change.

### 7. Nothing consults a primary source

No skill does external research. discovery names "hard-to-reverse decisions:
language, frameworks, data models" as the ones to be most careful about, and
settles them from weights that are months stale. GSD makes research a blocking
gate; mattpocock has a dedicated research skill.

We already accept this argument at a smaller scale - coding-conventions says to
look a dependency's version up because memory is almost always stale, and now
its registry entry too. It applies with more force to choosing the library.

Touches: discovery/SKILL.md - any hard-to-reverse external choice checked
against current docs before it is recorded, citation in Implementation
decisions.

### 8. Trigger reliability

/plan collides with plan mode. /critique competes with the harness's built-in
code-review skill and loses by default. upgrade-dependencies has no event that
fires it. implement wants a broader trigger. Four of sixteen skills, one
problem: the skill does not fire, and a skill that does not fire is worth zero
however good its contents.

One pass over every description field, not four separate edits.

### Smaller

- A different model for the reviews than for the implementation. Pipeline #2's
  first bullet; take that half and leave the parallelism half, which buys wall
  clock rather than quality.
- Superpowers' verification-before-completion iron law. We state that rule four
  times in four skills, incompletely each time, and not at all in discovery,
  propose-change or handover.

### Checked and left alone

- The delete-the-paper policy. Correct; #5 is its missing complement, not its
  replacement.
- The byte-identical TICKET_FORMAT copies. Deliberate - diff is the parity
  check, and cross-skill relative paths break on independent install.
- The two-door structure, the split test, and /implement's no-questions
  contract.
- BMAD's named persona agents. Ceremony without gain; our rule that the reviewer
  does not know about tickets is the better instinct.
- Spec Kit's article that every feature must begin as a standalone library.
  Flatly contradicts YAGNI and deep-modules.

## Skill Notes

### cleanup-repo

Works ok

## coding-conventions

Works ok

## critique

Generalize so it's called automatically for any kind of code review?

## debug

Drop?

## decision-brief

Meh. Better, have a summary of the discovery output spec.

## discovery

Does not focus enough on MVP and does not cleanly separate "now" and "later" features.

## git-commit-message

Works great

## handover

Not attempted yet?

## implement

More generic implementation, trigger for any kind of implementation work.

## improve-skill

Works ok

## plan

Needs a different name

## propose-change

Not tried yet

## repo-overview

Could get a better architecture overview?

Explain the architecture of the project in the current repository. Include domain modules / objects and the domain actions they support.

## trace

Should this be merged into critique? It is a code review, but it is not a critique of the code itself, but of the traceability of the code to the spec.

## ubiquitous-language-init

Is this still useful?

## upgrade-dependencies

Needs a better trigger so it's called automatically when dependencies need to be upgraded
Could be made more generic, also for installing new dependencies, not just upgrading existing ones?

