---
effort: XL
utility: XL
---

# Plan the build, and put to the developer only what is hard to change

The user, on 2026-11-02, after reading Anthropic's AI-native SDLC playbook
(`anthropic-sdlc.md`): split the implementation pipeline off from the design
pipeline. Discovery makes the change; a plan pipeline builds it. In the same
conversation they agreed how the plan, its reviews and the tests should work,
and that the developer should be asked only about what is hard to change.
This item holds all of it. It took in the item "The developer decides what is
hard to change", whose evidence is under "Where it showed up" below.

## The pipeline

`design-user-journeys` → `create-plan` → `run.sh` (`split-plan`, then
`implement-plan` on each part) → `accept-change`.

- **`create-plan`** takes a specification of any kind - a `CHANGE.md`, but
  also a refactoring plan or an upgrade - and writes `plan.md`: what to do,
  step by step, like the playbook's plan.md. The plan names the files, the
  order of the work and the tests. It holds no code. Each step names the
  journey steps it makes testable. An agent with a fresh context reviews the
  plan adversarially, until "an engineer who has never seen the conversation
  could implement the change from the plan alone" (the playbook's bar).
- **`create-plan` runs in the interactive session**, not in `run.sh`.
  Questions only the developer can answer come up here, while they are still
  there. The developer can approve `plan.md`, but does not have to.
- **Once `run.sh` runs, it is fully autonomous.** It calls `split-plan`,
  which can split `plan.md` into `plan-01.md`, `plan-02.md`, …, each small
  enough to build within one context of 250k-350k tokens. The parts run one
  after the other: no parallel builds, no `after:` dependencies. Where the
  plan fits, or the developer wants it so, `run.sh` builds `plan.md` as it is.
  `split-plan` has no `undecided` halt: an open question found there is a
  defect the plan review missed. `implement-plan` can still halt as
  `blocked` or `departure`, where the code turns out different from what the
  plan assumed.
- **`implement-plan`** builds one part, and where the build departs from the
  plan, updates the plan in the same commit, including the parts still to
  come.

### This reverses a decision, on purpose

`split-change-into-chunks/SKILL.md:9`: "A chunk says what to build and what
it shares with other chunks, never how: the builder plans in the code." The
user: "it reverses it deliberately. We follow Anthropic's approach then."

### Reviews, one per level

Each level reviews against its own document:

| Level | Runs in | Reviewed against |
|---|---|---|
| `create-plan` | the interactive session | `CHANGE.md` and the journeys |
| each `implement-plan` | `run.sh` | its `plan-XX.md` |
| end of `run.sh` | `run.sh` | `plan.md`: what lies between the parts |
| `accept-change` | the interactive session | `CHANGE.md`, the journeys, the four goals, and the walk |

So the whole-change review moves from `run.sh`'s `final_review`
(`run/report.sh:99`, called at `run.sh:136`) into `accept-change`, which then
spawns `review-change` and `walk-user-journeys` on the whole change. A part
like "add the schema" has no journey to walk, so the per-part reviews are code
reviews, and the walk happens once, at acceptance. That replaces the chunk
rule "Provable on its own" (`split-change-into-chunks/SKILL.md`, "What a
chunk is").

### Sizing a part

An agent cannot measure how many tokens a later session will use, so
`split-plan` still needs a stand-in measure, like today's lines and files.
`run/session.sh:34` already writes each session's context size to the
`.tokens` log, so the stand-in limits can be set from real runs.

## Hard and soft decisions

There are two kinds of decision:

- **Hard to change later.** The user named the database schema, wire formats
  and domain object names. The test: something outside the code depends on
  it, and a revert removes the code but not what the code wrote, sent or
  promised. That covers stored data (schema, migrations that drop or
  transform data, file formats on disk, IDs and keys); wire formats (public
  APIs, event and message schemas, webhooks, CLI output that scripts read,
  URLs people link to); names that leave the code (in the UI, the API, the
  schema, the journeys, environment variables); the access model (roles,
  permissions, how login works); what the code is built around (a framework,
  a database engine, a third-party service, a UI library); and effects in the
  world (emails sent, payments made, data deleted, data collected).
- **Easy to change later**: file names, module boundaries, internal names,
  helper structure. These are the agent's, and it says nothing about them.

What the user asked for: "I'd like the agent to help me focus on the hard to
change ones, and leave me alone with the rest."

- **`create-plan` writes the full `plan.md`, then pulls out the hard
  decisions for the developer**: each with the options, a recommendation,
  why it is hard to change, and the line of the design it comes from. The
  last part matters because some hard decisions are made in design already:
  `CHANGE.md`'s `### Data` is in the user's words, and the plan turns it into
  a schema. Where there are none, it says so in one line.
- **`implement-plan` may change any soft decision.** It halts as a departure
  where it would have to change a hard decision the developer approved.
- **When in doubt, a decision counts as hard.** An agent that calls a hard
  decision soft takes it past the developer without a word.

## Review shows what is hard to undo

The same for code review: identify where the blast radius is large, or where
a revert after deployment is hard - migrations, changed API shapes, new calls
to other services, deletions. Put that in front of the developer, and skip
most of the rest. Parts of this already exist, at the end of a report:
`implement-change/SKILL.md`'s "Finish" lists "a format other programs read"
and "blast radius and revert". And `accept-change/SKILL.md:78` says such
things are "shown, not settled".

A script can flag diffs that touch known places - migration folders, schema
files, OpenAPI or proto files, exported types - so the list does not rest on
the agent noticing alone.

## Hard and soft tests

Today there are two kinds of test. A journey's test stays
(`implement-change/SKILL.md:28`, "The test stays"), and "Every other test is
yours. Write what helps you build; delete it later if it gets in the way"
(`implement-change/SKILL.md:32`). So a rule that must last needs a journey
step to get a test that lasts. `CHANGE_FORMAT.md:56`, in all four copies: "A
design detail that must last, such as "overdue invoices are shown in red",
becomes something the user sees in a journey step, so it gets a test." The
user: "we already put a lot more detail into the user journeys than I
intended to be there, because we have no other place for that to be."

What was agreed:

- **A hard test needs the developer's yes to change. A soft test is the
  agent's.** A hard test pins a hard decision, or something a user relies
  on: journey tests, rules a user relies on (such as "an invoice is overdue
  30 days after it was sent"), access tests for who may *not* see or do
  something, contract tests for wire formats and stored data, and the
  regression tests `debug` writes. Soft tests: unit tests, tests of internal
  structure, scaffolding for the build.
- **The test for hard is what breaks outside the code if it changes, not
  that the developer said it.** The user: "Just because I say the delete
  confirmation dialog goes right under the "delete" button does not mean
  it's fixed forever." The dialog's place is soft: nothing is lost, no
  program fails. That deleting asks for confirmation is hard: without it a
  user loses data in one click. "Overdue invoices are red" is soft too; the
  rule under it is hard. In general, the *what* of a journey can be hard -
  what happens, who may do it, what is kept - and the *how* is soft: layout,
  wording, place, style.
- **Each proposed hard test names what breaks if it changes.** "It was in
  the design" is no reason. Where the agent cannot name a break, the test is
  soft. The developer sees every proposed hard test in the plan, so the list
  has to be short, each line with its reason.
- **A mistake can be undone either way.** With the developer's yes, a hard
  test can become soft and a soft one hard.
- **A hard test tests from the outside**: UI, API, stored data. A hard test
  of internals freezes the code, and then every refactor needs a yes.
- **A script can tell hard from soft**, by a path or a mark in the test, so
  a diff that touches a hard test is found without an agent noticing.
- **In the inner pipeline**: `create-plan` lists the hard tests it adds or
  changes among the hard decisions. `implement-plan` writes soft tests freely
  and the hard tests the plan says, and halts as a departure where an
  existing hard test would have to change. A refactor's rule "the tests for
  the user journeys pass without being changed" (`SDLC.md`, Refactor) becomes
  "the hard tests pass without being changed". A diff that touches a hard
  test goes on the list the developer reads at acceptance.

## Light journeys

The user: "User journeys should still exist, but be very light - they need
to be kept around for the agent to orient itself in the software, to find out
what the intended use is, but not to know every single step and special case.
That's what the code is for."

So a journey keeps who uses the software and for what. During the change, the
details of each step and the special cases live in the prototype and in
`CHANGE.md`'s design - both temporary, both agreed with the developer. After
acceptance they live in the code and the hard tests; a hard test's name says
its rule in the user's words. This changes `design-user-journeys` and the
journey and change formats. It also touches `SDLC.md`'s Future Changes, "The
domain model is a good idea, but has no place yet": a list of rules is part
of a domain model. `designs-declare-what-must-be-true.md` asks for a
permanent place for what must last; hard tests are one answer to it.

## UI design stays in discovery

How the UI looks and feels is not part of `create-plan`. The plan holds what
is invisible to the user - infrastructure, dependencies, tools - and the
technical side of the frontend: components, state, the UI library, how the
screens get their data.

Why: the developer's attention has two jobs. One is hard decisions. The other
is judgement only a person can make: does this screen make sense, does this
step feel right. UI is mostly soft to change, but no test or reviewer can
judge it for the developer. In the plan, screens would fill the approval with
the details the developer wants to be left alone with. Walking the prototype
is where the developer finds out whether a step works, which belongs before
the change is final. `create-plan` stays general: a refactor or an upgrade
has no UI. And the playbook makes mockups in its Design stage, with spec.md,
before plan.md. A screen discovery made no prototype for
(`design-user-journeys/SKILL.md:37`: "where seeing a step says more than
describing it") is the plan's to decide.

## Where it showed up

From the item this one took in. The user, on 2026-11-02: in one change, a
migration was built that they did not see, and two environment variables got
names nobody discussed with them. Stored data is a question of the domain
model and should be agreed at least in the abstract. Environment variables
are an outside interface and should at least be put to them for a veto.

Later the same day, after a design in `workout-tracker`: "Mir fehlt
tatsächlich die klare Darstellung, wie das in der DB gespeichert wird. Ohne
das fühle ich mich unsicher."

And then: the `workout-tracker` design said not a word about the tech stack
or the like. The idea that technical details are not put to the developer is
wrong. Serious decisions that are not easy to change must lie with the
developer: tech stack, deployment, databases. Which module goes where,
perhaps not, at least for small tools.

The rule behind it, `design-user-journeys/SKILL.md:51`: "Do not put details
of the code to the user - files, modules, ideas for how to build it. They
are the builder's."

### haushaltsbuch

`haushaltsbuch`, change `changes/2026-11-01-ausgaben-import`, designed and
built on 2026-11-01.

**In the design** (session `3977e5e9`, 15:40 to 16:03), both came up only in
other words:

- The developer said yes to "Jede Buchung aus Ausgaben merkt sich die
  Kennung ihres Eintrags, ohne sie anzuzeigen". `CHANGE.md` adds "Wo sie
  liegt, entscheidet der Build". "Merkt sich" reads as behaviour. That it
  means a new column and a migration did not show.
- The chat said only "Adresse und Schlüssel stehen in Umgebungsvariablen".
  The agent then wrote the names `AUSGABEN_URL` and `AUSGABEN_SCHLUESSEL`
  into `CHANGE.md` without showing them. Before the final yes the skill shows
  only what changed since the last yes, so they were never shown. The
  backlog item it wrote in `../ausgaben` names `HAUSHALTSBUCH_SCHLUESSEL` the
  same way.

`design-user-journeys/SKILL.md` asks "what it keeps, and what happens to what
it already holds", and "A new thing gets its name from the user". The second
only covers what the user sees in the software, not names the outside sees.

**In the build**, chunk `04-kennung-des-eintrags` added the column
`transactions.ausgaben_eintrag_id` with migration `0033`, and reported it
under `## Left standing` as built beyond the design.

**At acceptance** (session `9c5e1ef7`, 23:41), both were in the report, but
not as decisions:

- Migration 0033 stood only under "What a revert would not undo" and in the
  steps for deployment. `accept-change/SKILL.md:78`: what stays within what
  was agreed "is shown, not settled".
- The environment variables were item 2, "Deploying needs ... and nothing in
  the repo says so": a missing documentation, not names to approve.
  `accept-change/SKILL.md:52` lists "a format other programs read" and "a
  name for something the user sees"; a name the operator sets is neither.

`SDLC.md`, Future Changes: "Stored data (database schemas) and wire formats
are relevant but are not mentioned yet."

### workout-tracker

`workout-tracker`, change `changes/2026-11-02-workouts-tracken`, design
committed as `0fced9e` on 2026-11-02, not built yet (session `707c3e2c`).

- **The data came only as a list in words.** At 14:22: "Die App speichert:
  Übungen: Name, und ob Kraft oder Cardio. Pläne: … Trainings: …", followed
  straight away by the question whether to import old records. How the
  things hang together did not come up: whether a training points to its
  plan or only keeps its name, whether an exercise in a training points to
  the exercise that "Letztes Mal" is found through. The build will make the
  tables from this, and the developer will first see them as a migration.
- **Two stores, and no picture of them.** "Alle Trainings liegen auf dem
  Handy" came in only with the verifier's findings. A queue of waiting
  changes is added. What lies on the device, what on the server, and which
  one wins is spread over "Interactions" in `CHANGE.md`, lines 63 to 66.
- **The password is again a name nobody gave.** `CHANGE.md:72`: "ein
  Passwort, das beim Einrichten des Servers festgelegt wird". What it is
  called and how it is kept is left to the build.
- **No word on the stack, the database or deployment.** At 13:36 the
  developer brought up TanStack Query for retries. The answer: "Wie man das
  baut, entscheidet der Builder." `CHANGE.md` names no stack, no database
  and no way to deploy. The repository holds no code yet, so the first
  build decides all of it alone.

## What it touches

`SDLC.md` ("Add a feature", "Refactor", Future Changes); new skills
`create-plan`, `split-plan` and `implement-plan`, in place of
`split-change-into-chunks` and `implement-change`; `run.sh` and `run/`
(chunks, `after:`, `final_review`); `accept-change`, `review-change`,
`design-user-journeys`, `debug`, `refactor-codebase`; the four copies of
`CHANGE_FORMAT.md` and the copies of `JOURNEY_FORMAT.md`.
