# Pipeline v4

This document describes the next version of the "Add a feature" pipeline as
one change. It brings together three groups of backlog items that depend on
each other:

- **The build** - `plan-the-build-and-decide-only-what-is-hard-to-change.md`
- **The design** - `several-skills-contribute-to-the-design.md` and
  `designs-declare-what-must-be-true.md`
- **Simplicity** - `simplicity-as-a-goal.md` and
  `build-the-smallest-useful-change-first.md`

The backlog items hold the evidence and the user's own words. This document
only describes the whole approach. Each part is marked:

- **Agreed** - the user agreed to it in a conversation.
- **Proposed** - it was suggested, and nobody has decided yet.
- **Open** - a question that still needs an answer.

## Why

The runs in `haushaltsbuch`, `ausgaben` and `workout-tracker` showed four
problems.

1. **Complexity comes in before the build.** Each verifier and reviewer looks
   for what is missing, and none looks for what could go. Options come as a
   menu, and the simplest one is often not on it. The code was reasonable for
   what it was asked to do. What it was asked to do was too much.
2. **The developer is not asked about the things that are hard to change.**
   A migration and two environment variable names went past the developer
   without a word. The design for `workout-tracker` said nothing about the
   stack, the database or deployment. The developer wrote a technical
   document by hand, outside any skill, and nothing checked it. The simplest
   storage was never offered, and offline sync became the largest part of
   the run.
3. **The journeys carry too much.** Only a journey's test lasts, so every
   rule that must last becomes a journey step. The journeys grew far beyond
   "who uses the software, and for what".
4. **Everything is specified up front, then built in one go.** Cutting the
   change from 11 journeys to 4 hardly made the run shorter. Each chunk has
   a fixed cost, and the hard technical part was still there.

## Principles

### 1. The smallest software that solves the problem (proposed)

A new goal in `SDLC.md`: every feature, failure case and moving part has to
earn its place. Less software is less that can break the user's trust, so
this serves Utility and Maintainability.

The goal on its own changes nothing. The rules that already exist say the
same ("Write the least code that does the job", "Nothing unasked for"), and
they did not hold. What does the work:

- **Every adversary looks for excess as hard as for gaps.** Verifiers and
  reviewers report "what could go" as findings of the same weight. Each such
  finding names the part of the problem that the thing does not serve.
- **A failure case has to earn its place.** A failure case goes into the
  design only if it would really happen to this user. Each one costs a test,
  a walk and usually a fix.
- **The simplest option comes first, and is called the simplest**, at every
  decision. This holds for design choices and technical choices alike.

### 2. Hard and soft (agreed)

A decision or a test is **hard** if something outside the code depends on
it. The test for this: a revert removes the code, but not what the code
wrote, sent or promised. Everything else is **soft**.

- The developer decides the hard things. The agent decides the soft things
  and does not mention them.
- When in doubt, a thing counts as hard.
- Whether something is hard depends on what breaks if it changes, not on
  whether the developer said it. "Deleting asks for confirmation" is hard:
  without it, a user loses data in one click. "The confirmation dialog sits
  under the button" is soft. In general, the *what* of a journey can be hard,
  and the *how* is soft.
- A mistake can be undone either way. With the developer's yes, a hard thing
  can become soft, and a soft thing hard.

The lists of what counts as hard are below, under "Hard decisions" and
"Hard tests".

### 3. The developer's attention has two jobs (agreed)

1. Hard decisions.
2. Judgements only a person can make: does this screen make sense, does this
   step feel right.

Everything else is left to the agents. This is why UI design stays in the
design stage and does not go into the plan: the plan would fill up with
details the developer wants to be left alone with.

### 4. Each level is reviewed against its own document (agreed)

Every document is checked by an agent with a fresh context, against the
document one level above it. See the table under "Reviews".

## The pipeline

```
/idea                      intent.md: the problem underneath the idea
  │
create-spec                spec.md, sized to intent.md; uses
  │                          design-user-journeys   light journeys
  │                          design-domain          domain, rules, data
  │                          design-frontend        look, feel, prototype
  │
create-plan                plan.md, hard decisions and hard tests
  │                        put to the developer       (interactive)
  ▼
run.sh                                                (autonomous)
  split-plan               plan-01.md, plan-02.md, …
  implement-plan × n       one part per session, code review per part
  review of the whole      against plan.md
  │
accept-change              review and walk of the whole change,
                           then the developer walks it
```

**Other ways in (agreed in outline).** `create-plan` takes any
specification, not only a `spec.md`:

- `debug`, when the fix is larger than one session. The spec is the bug
  report, the agreed intention and the cause. The plan's first step is the
  test that reproduces the bug.
- `solve-problem`, with its "Done when" list.
- Perhaps `refactor-codebase`, with its refactoring plan.
- `upgrade-dependencies`: **open**. It has to try the upgrade first to see
  what is needed.

Small work is still built in the session, with `implement-code` (see
below). A plan, a plan review and a run cost more than they give for a
three-line fix. The rule: work that fits in one session, and has no hard
decision the developer has not seen, goes to `implement-code`. Everything
else goes through `create-plan`.

## implement-code and review-code (agreed)

Two skills that know nothing about the pipeline: no plans, no journeys, no
`run.sh`. The pipeline's skills build on them.

- **`implement-code`** builds a small change to code that was agreed
  beforehand. Its input is any agreed spec, such as `debug`'s cause,
  intention and reproducing test, or `solve-problem`'s "Done when" list. It
  holds everything about writing code: the coding standards, the least code
  that does the job, soft tests written freely, hard tests changed only with
  a yes. Before a hard decision, it asks the developer. When it is done, it
  spawns `review-code`.
- **`review-code`** reviews a diff in a fresh context, against the spec it
  is given: does the code do what the spec says, is it correct and secure,
  and what could go. It walks nothing.

The pipeline adds only what it needs on top:

- **`implement-plan`** uses `implement-code` to build one part, and adds the
  plan rules: update the plan where the build departs from it, and halt
  instead of asking. Nobody is there to ask inside `run.sh`, so a hard
  decision the developer has not approved becomes a `departure` halt. That
  one rule is most of what separates the two skills.
- **The reviews inside `run.sh`** are `review-code`, given `plan-XX.md` for
  a part and `plan.md` at the end of the run.
- **`review-change`**, at acceptance, adds what only the pipeline has: the
  journeys, the four goals and the hard tests.

`debug` and `solve-problem` call `implement-code` directly for small work.

## Stage by stage

### /idea

`/idea` stays what it is: it finds the problem underneath the idea the
developer arrives with (the XY problem). It names no mechanism and does not
look for solutions. It needs no more brainstorming: the playbook's
"brainstorm until the problem is concrete" is what `/idea`'s digging already
does. New:

- **`/idea` writes `intent.md` (agreed).** Today almost nothing of the
  conversation survives `/idea`. In v4 the backlog item and `intent.md` are
  one file at two stages:
  1. **A backlog item** is a note, as far as the developer got, with its
     evidence. It may hold no agreed problem yet.
  2. **After `/idea`**, the same file holds the agreed problem statement,
     what must stay true, the instance, the solution the developer arrived
     with (marked as evidence, not as the brief), and what was parked.
     `/idea` updates an existing item, or writes a new one, so every idea
     takes this path.
  3. **When the design is committed**, the file moves (`git mv`, not a copy)
     to `changes/<slug>/intent.md`, without its frontmatter. If the change
     is abandoned, it moves back. For `/solve-problem`, it is deleted with
     the commit, as the backlog item is today.

  `intent.md` is what `spec.md` and acceptance are held against. `spec.md`
  points to it and does not restate the problem.
- **What must stay true (agreed).** A constraint the developer arrives with
  is evidence, like the solution they arrive with. "Existing login only"
  limits the solutions, and `/idea` digs under it: why? Where the answer is
  part of the problem, such as "nobody new gets access to member data", it
  goes into `intent.md` as what must stay true. The verifier checks it with
  the same no-mechanism rule. Where the answer only limits the solutions,
  such as "we cannot run a second login system", it is a hard decision for
  the design or `create-plan`.
- **The smallest useful change.** `/idea` already settles "the one real
  instance" of the problem. Cutting the change down to what this instance
  needs is `create-spec`'s job, not `/idea`'s. See "The size of a change"
  below.

### create-spec (agreed)

`create-spec` owns `spec.md`, as `create-plan` owns `plan.md`. It is the one
entry point to the design, and the result is always one `spec.md`.

- **It sizes the spec to the problem in `intent.md`.** It proposes the
  smallest spec that solves the intent, and the developer can widen it. A
  change with no new screens and no new data may need journeys only; a new
  app needs all three parts; a change to a rule may need only the domain.
  This is where the smallest useful change can be decided (see "The size of
  a change").
- **It uses the `design-*` skills for the parts.** `design-user-journeys`
  comes first, because the other two build on it.
- **The `design-*` skills do not write `spec.md`.** They hand back what they
  worked out with the developer, and `create-spec` writes it into
  `spec.md`. So they know nothing about the pipeline, and each can be used
  on its own: `design-frontend` for a redesign, or `design-domain` to sort
  out a domain that has grown messy. This is the same pattern as
  `implement-code`.
- **One verifier for the whole spec.** `create-spec/VERIFY.md` checks
  `spec.md` against `intent.md`, for gaps and for excess.
- **Where two parts pull against each other**, for example the frontend
  against the domain, `create-spec` shows the conflict and the developer
  decides it. Anthropic's playbook does the same.
- **The names** follow the documents: `create-spec` and `create-plan` do
  work of the same shape. The parts stay `design-*`, because they are
  design work with the developer: alternatives, prototypes, walks. `/idea`
  keeps its name for now, because it says what matters most about it:
  finding the problem underneath the idea.

**`design-user-journeys` - light journeys (agreed).** A journey says who
uses the software and for what. Agents read the journeys to find their way
around the software and to learn what it is for. They do not need every step
and special case: that is what the code is for. During the change, the
details of each step live in the prototype and in `spec.md`. After
acceptance, they live in the code and in the hard tests.

**Journeys have no "When it goes wrong" section (agreed).** A journey says
what the software is for. What happens when something fails is the *how*,
and the code shows it. The failure cases still have to be designed: which
ones earn their place, how the error is shown, and what happens to the
user's work. That goes into `spec.md`'s design and the prototype, where
the developer agrees to it, and is deleted with the change. How the code
handles the failure underneath, such as retries or a queue of waiting
changes, belongs in `plan.md`. A failure case
where the user would lose work or see something they must not see gets a
hard test (see "Hard tests"). How the error looks and what it says is soft.

Each failure case in `spec.md` has one shape: "If <what goes wrong>, the
user sees <what>, and their work <is kept / is lost>" (agreed). This is the
"unwanted behaviour" pattern of EARS, and close to the old "When it goes
wrong" line. The last part makes it hard to leave out what happens to the
user's work, and that part decides whether the case gets a hard test.

**`design-domain` (proposed).** It covers the things the user works with,
how they hang together, their rules and their lifecycle, in the user's
words. For example: "a training keeps the name of its plan, so deleting a
plan loses nothing". It settles what the hard decisions about data mean,
and `create-plan` later turns them into a schema. This gives a place to
several things that have none today:

- the domain model and stored data (`SDLC.md`, Future Changes);
- the glossary, `UBIQUITOUS_LANGUAGE.md`;
- the rules that should become hard tests, such as "an invoice is overdue
  30 days after it was sent";
- a permanent home for constraints that must last.

**`design-frontend` (proposed).** It covers the look and feel, and builds
the prototype that `design-user-journeys` builds today. The plugin skill
`frontend-design:frontend-design` could be a starting point. A design system
of colours, type and components would outlive the change.

**Constraints (proposed).** `spec.md` lists each constraint - what must stay
true from `intent.md`, and the limits on solutions found in the design -
with how it is met and how that is checked. The check is a test from the
outside, a reviewer, or a person's judgement. Each constraint is one
statement with a single condition. There is no fixed notation such as EARS
(agreed): most constraints are things that must always hold, so the pattern
would add only "shall", and "how it is checked" already makes each one
testable.

### create-plan (agreed)

`create-plan` runs in the interactive session, while the developer is still
there. Questions only the developer can answer come up here.

- **It writes the full `plan.md`.** The plan says what to do, step by step:
  the files, the order of the work and the tests. It holds no code. Each
  step names the journey steps it makes testable.
- **This deliberately reverses a current rule.** Today a chunk says "what to
  build ... never how: the builder plans in the code"
  (`split-change-into-chunks/SKILL.md`). In v4 the plan says how.
- **The plan covers what the user does not see**: infrastructure,
  dependencies, tools, and the technical side of the frontend (components,
  state, the UI library, how screens get their data). It does not cover
  how the UI looks and feels. That was settled in the design. A screen the
  design made no prototype for is the plan's to decide.
- **It then pulls out the hard decisions** and puts them to the developer.
  Each comes with the options, the simplest option first, a recommendation,
  why it is hard to change, and the line of the design it comes from. Where
  there are none, the plan says so in one line.
- **It lists the hard tests it adds or changes**, each with what breaks if
  the tested thing changes.
- **A fresh agent reviews the plan adversarially**, with
  `create-plan/VERIFY.md`. It looks for gaps and for excess, until "an
  engineer who has never seen the conversation could implement the change
  from the plan alone" (the playbook's bar).
- **It also takes an existing `plan.md`**, such as one the developer wrote by
  hand, and checks it the same way. In `workout-tracker`, nothing checked
  the technical document the developer wrote.
- The developer has to decide the hard decisions. Approving the rest of
  `plan.md` is optional.

For a new repository, this is where the stack, the database and deployment
are decided. In `workout-tracker`, the developer wrote that document by
hand.

### run.sh (agreed)

Once `run.sh` starts, it runs on its own until it finishes or halts.

- **`split-plan`** splits `plan.md` into `plan-01.md`, `plan-02.md` and so on,
  each small enough to build in one context of 250k-350k tokens. The parts
  run one after the other: no parallel builds, no `after:` dependencies.
  Where the plan fits, or the developer wants it that way, `run.sh` builds
  `plan.md` as one part. An agent cannot measure tokens in advance, so the
  split still needs a measure that stands in for them, like today's lines
  and files. The `.tokens` logs of real runs can set its limits.
- **`split-plan` cannot halt as `undecided`.** An open question at that point
  is a defect that the plan review missed.
- **`implement-plan`** builds one part, using `implement-code`. It may
  change any soft decision.
  Where the build has to depart from the plan, it updates the plan in the
  same commit, including the parts still to come. It halts as a `departure`
  where it would have to change a hard decision the developer approved, or
  an existing hard test. It halts as `blocked` where it cannot go on.
- **The reviews inside `run.sh` are `review-code`**, against the part's plan
  and, at the end, against `plan.md`. A part such as "add the schema" has no
  journey to walk, so nothing is walked inside `run.sh`.

### accept-change (agreed)

The review and the walk of the whole change move here, out of `run.sh`'s
final review. `accept-change` spawns `review-change` and
`walk-user-journeys` on the whole change, then the developer walks it.

`accept-change` holds the build against whatever specification it came
from: for a change, `intent.md`, `spec.md` and the journeys; for a bug, that the
bug no longer happens; for `solve-problem`, each item on its "Done when"
list. So every run of `run.sh` ends the same way.

The developer sees every diff that touches a hard test, and everything that
is hard to undo (see below).

**`accept-change` is the only `accept-*` skill (agreed).** The developer
accepts a document with a yes inside the session that made it: `intent.md`
at the end of `/idea`, the hard decisions at the end of `create-plan`.
`accept-change` is a different kind of thing: it happens later, in another
session, on the running software, and the developer walks it.

## Reviews

**A review is its own skill only if more than one skill uses it, or a
person calls it directly (agreed).** Otherwise it is a `VERIFY.md` in the
skill that creates the document, and that skill spawns a fresh agent with
it, as `idea` and `design-user-journeys` do today. That gives two review
skills: `review-code` (used by `implement-code`, `implement-plan` and
`run.sh`) and `review-change` (used by `accept-change`, and called directly
before a merge).

| Level | Runs in | Reviewer | Checked against |
|---|---|---|---|
| `/idea` | interactive session | `idea/VERIFY.md` | the instance and the solution the developer arrived with |
| `create-spec` | interactive session | `create-spec/VERIFY.md` | `intent.md` |
| `create-plan` | interactive session | `create-plan/VERIFY.md` | `spec.md` and the journeys, or whatever spec the plan came from |
| each `implement-plan` | `run.sh` | `review-code` | its `plan-XX.md` |
| end of `run.sh` | `run.sh` | `review-code` | `plan.md`: what lies between the parts |
| `accept-change` | interactive session | `review-change`, `walk-user-journeys` | `intent.md`, `spec.md`, the journeys, the four goals |
| `implement-code` outside the pipeline | interactive session | `review-code` | the agreed spec it was given |

Every reviewer reports what could go, as well as what is missing (proposed,
from principle 1).

**Reviews show what is hard to undo (agreed).** They point out where the
blast radius is large, or where a revert after deployment is hard:
migrations, changed API shapes, new calls to other services, deletions. They
put that in front of the developer and leave out most of the rest. A script
can flag diffs that touch known places - migration folders, schema files,
OpenAPI or proto files, exported types - so the list does not depend on the
agent noticing.

## Hard decisions (agreed)

Main's four technical decisions are the starting list: stored formats, wire
formats, trust boundaries and dependencies. Each was always answered, and
"none" counted as an answer. In full:

- **Stored data**: schema, migrations that drop or transform data, files on
  disk, IDs and keys.
- **Wire formats**: public APIs, event and message schemas, webhooks, CLI
  output that scripts read, URLs people link to.
- **Names that leave the code**: in the UI, the API, the schema, the
  journeys, environment variables.
- **The access model**: roles, permissions, how login works.
- **What the code is built around**: a framework, a database engine, a
  third-party service, a UI library.
- **Effects in the world**: emails sent, payments made, data deleted, data
  collected.

Soft: file names, module boundaries, internal names, the structure of
helpers.

Some hard decisions are made in the design already. `design-domain` settles
their substance in the user's words. `create-plan` turns them into a schema
or an API, and points back to the line of the design each one comes from.
So the developer decides the substance in the design, and in the plan only
checks the translation.

## Hard tests (agreed)

Today a journey's test stays, and "every other test is yours". In v4:

- **A hard test needs the developer's yes to change. A soft test is the
  agent's.**
- **Hard tests** pin a hard decision or something a user relies on: journey
  tests, rules a user relies on, access tests for who may *not* see or do
  something, contract tests for wire formats and stored data, tests that a
  failure does not lose the user's work, and the regression tests `debug`
  writes.
- **Soft tests**: unit tests, tests of internal structure, scaffolding for
  the build.
- **Each proposed hard test names what breaks if the tested thing changes.**
  "It was in the design" is no reason. If the agent cannot name a break, the
  test is soft. The developer sees every proposed hard test, so the list has
  to be short.
- **A hard test tests from the outside**: the UI, the API or the stored
  data. A hard test of internals would freeze the code, and then every
  refactor would need a yes.
- **A hard test's name says its rule in the user's words.**
- **A script can tell hard tests from soft ones**, by a path or a mark in
  the test. Which one is **open**.
- The refactor rule changes from "the tests for the user journeys pass
  without being changed" to "the hard tests pass without being changed".

## What lasts, and what is deleted

A change's files sit in `changes/YYYY-MM-DD-<slug>/`, all in lowercase:
`intent.md`, `spec.md`, `prototype/`, `plan.md` and `plan-01.md`,
`plan-02.md` and so on. The names follow Anthropic's playbook: `intent.md`
is the problem, `spec.md` the design, `plan.md` the build.

| Document | During the change | After acceptance |
|---|---|---|
| `journeys/*.md` (light) | changed by the design | stays |
| domain document (proposed) | changed by `design-domain` | stays |
| frontend design system (proposed) | changed by `design-frontend` | stays |
| hard tests | listed in the plan, written by the build | stay |
| `intent.md` | a backlog item, then the problem the change is held against | deleted |
| `spec.md`, including the failure cases | the design | deleted |
| prototype | what the build builds the UI to | deleted |
| `plan.md`, `plan-XX.md` | what the build follows | **open**, probably deleted with the change |

`SDLC.md` says that whatever the next agent needs is "in the journeys, the
tests and the code". In v4 that becomes: the light journeys, the domain
document, the hard tests and the code.

## The size of a change (open)

The user asked whether a change should be cut down to the smallest useful
version first, now that code is cheap. What is known:

- The size of a change is counted in parts, not journeys. Each part has a
  fixed cost of about 20 to 35 minutes, however little it builds.
- Technical choices count as much as features. In `workout-tracker`, the
  storage choice made offline sync the largest part. v4 puts that choice in
  front of the developer in `create-plan`, with the simplest option first.
- Some things cannot be cheap later: stored formats and wire formats are
  expensive to change once data exists. These are exactly the hard
  decisions.
- Each change also has fixed costs: a design session, the plan, the run, the
  acceptance.

The cut is made in `create-spec`, which sizes `spec.md` to `intent.md`.
Not decided: how it finds the smallest useful spec, and whether one change
may be built and accepted in several smaller steps.

## Skills

| Skill | In v4 |
|---|---|
| `SDLC.md` | new goal for simplicity; "Add a feature", "Debug" and "Refactor" rewritten; Future Changes partly resolved |
| `idea` | still the XY problem; writes `intent.md` into the backlog item; digs under constraints for what must stay true |
| `backlog` | an item becomes `intent.md` once `/idea` has run; moved to the change directory when taken up |
| `create-spec` | new; the entry point to the design; sizes `spec.md` to `intent.md`, uses the `design-*` skills, writes `spec.md`; `VERIFY.md` checks it against `intent.md` for gaps and excess |
| `design-user-journeys` | light journeys only; hands its result to `create-spec`; usable on its own |
| `design-domain` | new (proposed); hands its result to `create-spec`; usable on its own |
| `design-frontend` | new (proposed); takes over the prototype; hands its result to `create-spec`; usable on its own |
| `create-plan` | new; `VERIFY.md` checks the plan; also checks a `plan.md` written by hand |
| `split-plan` | new, replaces `split-change-into-chunks` |
| `implement-plan` | new, replaces `implement-change`; uses `implement-code` |
| `implement-code` | new; builds small agreed changes, outside the pipeline too; holds the coding standards |
| `review-code` | new; reviews a diff against a given spec; used by `implement-code` and inside `run.sh` |
| `review-change` | runs at acceptance on the whole change; adds the journeys, the four goals and the hard tests; reports excess; flags what is hard to undo |
| `walk-user-journeys` | walks once, at acceptance |
| `accept-change` | runs the whole-change review and walk; takes any specification |
| `debug`, `solve-problem` | build small work with `implement-code`; hand larger builds to `create-plan` |
| `refactor-codebase` | hard tests pass unchanged; perhaps ends in `create-plan` |
| `run.sh`, `run/` | parts in order instead of chunks; no `after:`; no final review |
| `CHANGE_FORMAT.md` (4 copies), `JOURNEY_FORMAT.md` (copies) | `CHANGE.md` becomes `spec.md`, without `## Problem`; sections per design skill; constraints; light journeys without "When it goes wrong"; failure cases move to `spec.md` and earn their place |
| `init-ubiquitous-language` | perhaps folded into `design-domain` |

## Open questions

1. Where does the domain document live, and in what format? How does it
   relate to `UBIQUITOUS_LANGUAGE.md`?
2. How is a hard test marked: by path or by a mark in the test?
3. Is `plan.md` deleted at acceptance, or kept?
4. How does `create-spec` find the smallest useful spec, and can one change
   be accepted in steps?
5. What does `upgrade-dependencies` do in v4?

## Backlog items this affects

These items stand on their own, but v4 changes them:

- `walk-less-during-a-run.md`: v4 walks only at acceptance. The item is
  worth doing first only if v4 is far off.
- `split-checks-its-chunks-at-most-twice.md`: the split is replaced by
  `split-plan`. The limit of two rounds should carry over.
- `continue-after-an-undecided-halt.md`: `split-plan` has no `undecided`
  halt. The question moves to `departure` and `blocked` halts in
  `implement-plan`.
- `claude-starts-run-sh.md`: its exit codes per outcome should use v4's
  halt kinds.
- `try-code-review.md`: its results show what `review-code` should take
  over from `/code-review`, or leave to it.
- `rebuild-coding-standards-from-evidence.md`: the rebuilt standards live in
  `implement-code`, and `review-code` reviews against them.
- `security-beyond-access.md`: injection and the outside attacker are
  natural constraints and hard decisions in v4.
