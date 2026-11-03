# Plan: pipeline v4

This plan builds what `spec.md` in this directory describes. It names the
files, the order of the work and the checks. It holds no skill text and no
code.

Line numbers such as "spec 516" point at `spec.md`.

## How to use this plan

There is no `create-plan`, `split-plan` or `implement-plan` yet, so a person
builds this plan by hand, one session at a time, each in a fresh context.
The sessions are `plan/01.md` to `plan/10.md`. Each holds one part, or two
small parts that read the same files, copied word for word from below.
Give the session this file, `spec.md` and its `plan/NN.md`.

| Session | Parts |
|---|---|
| `plan/01.md` | 1, 2 |
| `plan/02.md` | 3, 4 |
| `plan/03.md` | 5a |
| `plan/04.md` | 5b |
| `plan/05.md` | 6 |
| `plan/06.md` | 7 |
| `plan/07.md` | 8 |
| `plan/08.md` | 9, 10 |
| `plan/09.md` | 11 |
| `plan/10.md` | 12 |

Where a session changes what its part says, it changes the part here and
in its `plan/NN.md` in the same commit.

Nothing else uses this repository while the plan is built. Between two
parts, the skills may not work together, and no project has to keep
working. Only one thing holds at the end of every part: `./test.sh` is
green. That is how a session knows its part is done.

At the end of each part:

- Where the part adds or removes a skill directory, run `./sync.sh`.
- `README.md` describes each skill the part changed as it now is.
- Stage only the files the part names.

Three rules from the repository hold in every part:

- A file two skills need is copied into each, byte for byte. Edit every
  copy in the same commit. `test.sh` finds the copies by file name.
  `VERIFY.md` is exempt by name: each skill's verifier is its own document.
- `tests/no-dangling.sh` fails when a `SKILL.md`, a `*_FORMAT.md` or
  `README.md` names `` `/skill` `` or `` `skill/FILE.md` `` and that is not
  there. So a part may only point at a skill that already exists. It does
  not see bare names, prose or `.sh` files, so a part that deletes a skill
  also greps for its name.
- A skill with `disable-model-invocation: true` ("typed") cannot be loaded
  by another skill's Skill call (`run/prompts.sh`, above `split_brief`). A
  skill that another skill loads must not be typed (H4).

## Hard decisions

These are the things that something outside this repository depends on:
projects that use the skills, the files they hold, the names people type,
and what `run.sh` reads. Each needs the developer's answer before the part
that builds it.

Three of them (H1, H5, H6) are settled by spec.md already. They are listed
so the developer sees them once, and need only a yes.

### H1. The file names in a change's directory

`changes/YYYY-MM-DD-<slug>/` holds `intent.md`, `spec.md`, `prototype/`,
`plan.md` and, where the plan was split, its parts in `plan/01.md`,
`plan/02.md`, …, all in lowercase. No `chunks/`, no `CHANGE.md`, no
`REVIEW.md`.

Decided by the developer, 2026-11-03. This departs from spec 531-534, which
puts `plan-01.md`, `plan-02.md` beside `plan.md`: a plan can have ten parts
or more, and a directory of their own keeps the change's directory short.
It also keeps the runner's test for "split or not" as it is today: whether
the directory holds parts. A part's run log is named after its file, such as
`01-<time>.jsonl`.

Why it is hard: `run.sh` finds a change by these names, and `retro` and
`explain-diff` read them back from a project's history after the directory
is deleted.

### H2. What `run.sh` reads in `plan.md` and in each part

spec 398-404: "The parts run one after the other: no parallel builds, no
`after:` dependencies."

Options:

1. **`status` and `attempts` only (simplest).** The frontmatter is the
   runner's bookkeeping, as today, and nothing else. The parts are built in
   the order of their numbers. `## Left standing` and `## Halt` stay as
   today. `plan.md` is the one part where `plan/` holds none.
2. As 1, plus `journeys:` as today, so `run.sh` can check that the named
   journeys exist.
3. As 1, plus a field such as `split: no`, so the developer can ask for the
   plan to be built as one part without a split session.

Decided by the developer, 2026-11-03: option 1.

Recommendation: 1. Nothing in v4's runner needs the journeys: nothing is
walked inside `run.sh`, and `create-plan/VERIFY.md` checks the plan against
the journeys before the run. spec 401 lets the developer ask for one part,
but does not say how. Under option 1, `create-plan` writes that wish into
`plan.md` in a sentence, and `split-plan` follows it.

In a split plan, `plan.md`'s `status` also marks the end-of-run review:
the review sets it to `done`, and a new split sets it back to `ready`. Today the final review's `REVIEW.md` being committed is
how the runner knows the review finished. See Q2.

Why it is hard: `run.sh` reads these fields.

### H3. Halt kinds, and the runner's exit codes

spec 405-412: `split-plan` "cannot halt as `undecided`"; `implement-plan`
"halts as a `departure`" or "as `blocked`". spec 620-628 on
`continue-after-an-undecided-halt.md` and `claude-starts-run-sh.md`.

Today: `blocked`, `undecided` and `mystery` from a session; `exhausted`,
`drift`, `unbuilt` and `departure` from the runner.

Options:

1. **Only what spec.md names (simplest).** From a session: `blocked` and
   `departure`. From the runner: `exhausted`, `unbuilt` and `departure`.
   `undecided`, `mystery` and `drift` go.
2. As 1, and keep `mystery` ("a failure you cannot explain, which is
   different from one you cannot fix").
3. Keep every kind of today, and add `departure` as a session's kind.

Decided by the developer, 2026-11-03: option 2.

Recommendation: 2.

- `undecided` goes because v4 leaves no question for the build: a hard
  decision the developer has not approved is a `departure`, and every soft
  one is the agent's.
- `drift` goes because nothing is left for it to check: no `after:`, no
  Problem copied into each part, no `journeys:` field (H2).
- `mystery` stays because spec.md does not remove it, and it tells the
  developer something `blocked` does not.
- spec.md does not say what `split-plan` does with an open question, since
  it cannot halt on one. This plan's reading: it writes the question under
  `plan.md`'s `## Left standing` and takes the smallest reading.

The exit codes stay as they are: 0 finished, 1 halted or stopped, 2
refused. With the drift pre-flight gone, nothing halts with 2 any more. `claude-starts-run-sh.md` wants
one code per outcome. That is a backlog item of its own (spec 627).

Why it is hard: a halted part names its kind on disk, the developer reads
it, and the backlog item above will build exit codes on these kinds.

### H4. Skill names, and which ones a person types

spec 590-614, the Skills table.

New: `create-spec`, `design-domain`, `design-frontend`, `create-plan`,
`split-plan`, `implement-plan`, `implement-code`, `review-code`. Deleted:
`split-change-into-chunks`, `implement-change`. Kept: `idea`,
`design-user-journeys`, `review-change`, `walk-user-journeys`,
`accept-change`.

Which skills are typed (`disable-model-invocation: true`):

- **Typed** - only a person starts them: `create-spec`, `accept-change`,
  `refactor-codebase`, `upgrade-dependencies`, and `split-plan`, which
  `run.sh` loads by starting its prompt with the command, as it loads
  `split-change-into-chunks` today.
- **Not typed** - another skill or `run.sh` loads them:
  `design-user-journeys`, `design-domain` and `design-frontend`
  (`create-spec` uses them); `create-plan` (`debug`, `solve-problem` and
  `upgrade-dependencies` hand larger work to it); `implement-code` and
  `review-code`; `implement-plan` (`run.sh` names it in the middle of its
  prompt, as it names `implement-change` today).

`design-user-journeys` is typed today, so this changes it.

Decided by the developer, 2026-11-03: these names, and this split between
typed and not typed.

Why it is hard: people type these names, and installed projects hold them.

### H5. How a hard test is marked

spec 516-525 settles it, "to be tried out": `.hard.` before the test
suffix, such as `invoice-overdue.hard.test.ts`. A script finds every diff
that touches one with `grep '\.hard\.'`. spec.md already rejected a fixed
directory and a tag inside the test. See Q11 for languages where this name
does not work.

Why it is hard: every project names its hard test files this way, and
`accept-change/signals.sh` finds them by it.

Decided by the developer, 2026-11-03: `.hard.` in the file name, for
JavaScript and TypeScript for now.

### H6. `## Constraints` in a project's `CLAUDE.md`

spec 349-354 settles it: one line per constraint in the project's
`CLAUDE.md`, under a `## Constraints` heading. Nothing reads them by
script; `review-change` reads them as text. See Q4 for who writes a line
there.

Why it is hard: projects' `CLAUDE.md` files will hold the list, and every
agent in those projects reads it.

Decided by the developer, 2026-11-03: a `## Constraints` heading with one
bullet per constraint, written by the build as a step `create-plan` plans
(this also settles Q4).

### H7. The shape of `intent.md`

spec 199-214: after `/idea` the file holds "the agreed problem statement,
what must stay true, the instance, the solution the developer arrived with
(marked as evidence, not as the brief), and what was parked".

Decided by the developer, 2026-11-03: one heading per part, in this order:

1. `## Problem`: what is wrong.
2. `## Outcome`: what would be true instead, with no mechanism in it.
   `create-spec` and acceptance hold the work against this.
3. `## Instance`: the one real instance.
4. `## What must stay true`: only what is part of the problem. Limits on
   the solution are hard decisions for later (spec 216-223).
5. `## What they arrived with`: the solution the developer arrived with,
   as evidence.
6. `## Parked`.

Splitting Problem from Outcome comes from the playbook's example intent.md
(claude.com/blog/the-ai-native-sdlc-playbook, Stage 1). Its other sections
are left out: "Affected users and systems" leads towards a solution,
"Constraints" would mix what is part of the problem with limits on the
solution, "Open questions" has no place once `/idea` ends in an agreed
statement, and the author and the status are in git.

While the file is a backlog item, the backlog's frontmatter (`effort`,
`utility`) and the item's own notes stay above the headings. `create-spec`
drops the frontmatter when it moves the file (spec 209).

Why it is hard: backlog items in projects keep this shape for months, and
`/idea` reads it back when an item is picked (spec 579).

## The parts, in order

The order follows one rule, so that no-dangling stays green: build a skill
before any skill points at it.

| Part | What |
|---|---|
| 1 | `SDLC.md` |
| 2 | `implement-code`, `review-code` |
| 3 | `create-plan` |
| 4 | `split-plan`, `implement-plan` |
| 5a | the drift pre-flight goes |
| 5b | `run.sh` builds `plan.md` and its parts (the largest part) |
| 6 | the end-of-run review writes into `plan.md` |
| 7 | acceptance reviews and walks the whole change; the old build skills go |
| 8 | small work uses `implement-code`; larger work goes to `create-plan` |
| 9 | `/idea` writes `intent.md` |
| 10 | `design-domain`, `design-frontend` |
| 11 | `create-spec`, and light journeys |
| 12 | the rest of the docs, and the backlog |

### Part 1. `SDLC.md` says what v4 is for

**Achieves:** the goal and the journeys every later part serves.
`CLAUDE.md` tells every session here to read `SDLC.md` before changing what
a skill is for, so it goes first.

**Files:**

- `SDLC.md`:
  - Simplicity, as a paragraph under "Goals" before the four ranked goals,
    not as a fifth (Q12): "the smallest software that solves the problem";
    every feature, failure case and moving part earns its place; less
    software is less that can break the user's trust. Say that it serves
    Utility and Maintainability.
  - Maintainability: "in the journeys, the tests and the code" becomes "in
    the light journeys, `UBIQUITOUS_LANGUAGE.md`, the hard tests and the
    code" (spec 547-549).
  - "Add a feature", rewritten to the v4 stages: `/idea` and `intent.md`;
    the design with `create-spec` and its parts; the hard decisions put to
    the developer in `create-plan`; `run.sh` building part after part with
    a code review of each; the review and the walk of the whole change at
    acceptance; then the developer walks it. Hard and soft decisions and
    tests in a sentence each. Small work built in the session with
    `implement-code`.
  - "Debug": a fix is reviewed by `review-code`; the reproducing test is a
    hard test; a fix larger than one session goes to `create-plan`.
  - "Refactor": "The tests for the user journeys pass without being
    changed" becomes "The hard tests pass without being changed"
    (spec 526-527).
  - "Backlog": the last paragraph says the item moves into the change's
    directory as `intent.md` and is deleted with it. See Q11.
  - Future Changes: remove the three lines v4 settles (ubiquitous language,
    domain model, stored data and wire formats). Keep the line about
    production problems.

**Carries out:** Principle 1 (the goal), the Skills table row for
`SDLC.md`, What lasts (the last paragraph), Hard tests (the refactor rule).

**Checked by:** a person reads the new `SDLC.md` against spec.md's
Principles and Pipeline. `./test.sh` does not read `SDLC.md`.

### Part 2. `implement-code` and `review-code`

**Achieves:** the two skills that know nothing about the pipeline (spec
159-187).

**Files:**

- `implement-code/SKILL.md`, new, not typed. Builds a small agreed change
  from any agreed spec. Takes over from `implement-change/SKILL.md` what is
  about writing code: read what is there and use the user's words; find
  the checks (`Fast check:`, `Slow check:`, `Check:`); write the least code
  that does the job; leave touched files better in a commit of its own;
  keep its own context with subagents; run the checks; stop rather than
  improvise; the friction note in `changes/friction/`. New:
  - What it leaves standing is only what someone has to act on: review
    findings not fixed, fixes made after the last review, checks not run,
    and every hard decision it made or met. Soft decisions it does not
    mention (spec 67-68). Today's list loses tradeoffs, a better approach
    and blast radius beyond the hard decisions.
  - Hard and soft tests (spec 497-527): soft tests are written freely; a
    hard test is a file with `.hard.` in its name (H5); a hard test is
    changed or deleted only with the developer's yes; a new hard test tests
    from the outside, is named in the user's words, and names what breaks
    if the tested thing changes, or it is soft.
  - Hard decisions (spec 468-493): the list of what counts as hard; when in
    doubt, hard; before a hard decision, ask the developer, with the
    options, simplest first and called the simplest, and a recommendation.
  - A failure case the user sees is built only where the spec asks for it
    (spec 55-57). How the code handles failures underneath is its own.
  - When done, spawn `review-code` with a fresh context, with the diff, the
    checks' result and the spec it was given. Not the reasoning. Fix the
    blockers and the should-fix; two rounds at most.
  - **Who commits:** where the caller says it commits, `implement-code`
    leaves the change reviewed, green and uncommitted, with what it left
    standing. Otherwise it commits with `git-commit-message`, staging only
    what it touched. Each caller says which.
  - Leaves out what is the pipeline's: journeys, `run.sh`, statuses, halts,
    walking.
- `review-code/SKILL.md`, new, not typed. Reviews a diff in a fresh context
  against the spec it is given. Takes over from `review-change/SKILL.md`
  the parts about code: what it is given; parallel `Explore` subagents for
  large diffs; correctness and security (every way in denies unless
  allowed; secrets; outside text is data); the five things it establishes
  itself (checks pass, tests that would catch a break, tests that left,
  callers still work, code it wants deleted is dead); refute each finding
  by its trigger; severity; the output format. New:
  - "What could go" as findings of the same weight as gaps, each naming the
    part of the spec the thing does not serve (spec 52-54).
  - A changed or deleted `.hard.` file is a blocker unless the spec says
    the developer approved it.
  - A section "Hard to undo": migrations, changed API shapes, new calls to
    other services, deletions (spec 460-466).
  - It walks nothing and changes nothing.
- `README.md`: an entry for each.

**Carries out:** implement-code and review-code; Principles 1 (the first
and third bullets) and 4 (all code is reviewed); Hard decisions; Hard
tests; Reviews (hard to undo, as far as `review-code` goes).

**Checked by:** `./test.sh`. A person walks it once: in a scratch
repository with one source file and one test, run `/implement-code` on a
two-line agreed change. See that it spawns `review-code`, that the review
has a "what could go" part and a "hard to undo" part, that it commits, and
that a `.hard.` test it would have to change makes it ask.

### Part 3. `create-plan`

**Achieves:** the skill that writes `plan.md` and puts the hard decisions
to the developer (spec 358-392).

**Files:**

- `create-plan/PLAN_FORMAT.md`, new. The shape of `plan.md` and of a part:
  - frontmatter `status` and `attempts`, the runner's (H2);
  - a title;
  - which specification it was planned from, by path;
  - `## Hard decisions`: each with the options, simplest first, the
    recommendation, why it is hard, the line of the spec it comes from, and
    the developer's answer; or one line saying there are none;
  - `## Hard tests`: each with its name in the user's words and what breaks
    if the tested thing changes. A journey's test walks it from the outside
    and names its journey and step; a *(judged)* step gets none. A hard test
    the plan changes is listed too, with the developer's yes;
  - `## Steps`, numbered: the files, what changes in each, the tests, and
    the journey steps it makes testable; no code;
  - `## Left standing` and `## Halt`, as today;
  - for a part: the hard decisions and hard tests it touches, copied word
    for word from `plan.md`, and what the parts before it provide;
  - what the frontmatter is for, as `CHANGE_FORMAT.md` says it today, with
    `after:` and `journeys:` gone.
- `create-plan/SKILL.md`, new, not typed. In the interactive session:
  - takes any specification: `spec.md` and its journeys; a bug's cause and
    intention; a "Done when" list; a refactoring plan; an existing
    `plan.md` written by hand, which it checks the same way
    (spec 124-133, 384-386);
  - reads the code, and plans what is not built yet;
  - writes the full `plan.md` in `PLAN_FORMAT.md`'s shape: what the user
    does not see (infrastructure, dependencies, tools, the technical side
    of the frontend); not how the UI looks; a screen with no prototype is
    the plan's to decide (spec 369-373);
  - for a new repository, the stack, the database and deployment
    (spec 390-392);
  - turns the domain design into a schema and points each hard decision
    back to its line (spec 300-301, 489-493);
  - for each constraint in the spec: a hard test where it can be one,
    otherwise a step that adds its line under `## Constraints` in the
    project's `CLAUDE.md` (spec 341-354; Q4);
  - where the developer wants it built as one part, says so in `plan.md`
    (H2);
  - spawns a fresh agent with `VERIFY.md`, `PLAN_FORMAT.md` and the paths
    of the spec and the plan, nothing else; works in what it finds; two
    rounds at most;
  - then puts the hard decisions to the developer one at a time, simplest
    option first, and writes each answer into the plan. Approving the rest
    is optional (spec 387-388);
  - commits `plan.md` on the change's branch, and says that `./run.sh
    changes/<dir>` builds it.
- `create-plan/VERIFY.md`, new: checks the plan against the spec and the
  journeys, for gaps and for excess, against the bar "an engineer who has
  never seen the conversation could implement the change from the plan
  alone"; every hard decision has its options, its line and an answer;
  every hard test names a break; nothing in the plan says how the UI
  looks; nothing is left for the build to ask.
- `README.md`: an entry for `create-plan`.

**Carries out:** create-plan; Hard decisions (the putting to the
developer); Hard tests (the list in the plan); Constraints (how they
outlive `spec.md`); Reviews (the `create-plan` row); Size of a change (the
storage choice, spec 558-560).

**Checked by:** `./test.sh`. A person walks `/create-plan` once in a
scratch repository on a short written spec with one journey: `plan.md`
comes out in the format, the verifier runs, and the hard decisions come
one at a time.

### Part 4. `split-plan` and `implement-plan`

**Achieves:** the two skills `run.sh` calls from part 5b on.

**Files:**

- `split-plan/PLAN_FORMAT.md` and `implement-plan/PLAN_FORMAT.md`: copies
  of `create-plan/PLAN_FORMAT.md`.
- `split-plan/SKILL.md`, new, typed. Takes over from
  `split-change-into-chunks/SKILL.md`: what it takes; asks nothing; the
  estimate by lines and files, with today's limits, as the stand-in for
  250k-350k tokens (spec 398-404); split where the context divides;
  everything placed; preparatory parts first (no fast check, a slow fast
  check, code a search would miss); a step only a person can do halts as
  `blocked`; a step only for deployment goes to `## Left standing`;
  splitting again. Changed:
  - writes `plan/01.md`, `plan/02.md`, …, in order, built
    one after the other; no `after:`;
  - a part is a run of the plan's steps, copied word for word, with the
    hard decisions and hard tests it touches;
  - "Provable on its own" goes: a part such as "add the schema" has no
    journey to walk (spec 413-415);
  - an open question is not a halt (H3);
  - a `plan.md` that says "one part", or that fits, is built as it is;
  - the check of the parts with a fresh agent stays, two rounds at most
    (spec 622-623);
  - splitting again sets `plan.md` back to `status: ready` and removes what
    the end review left in its `## Left standing`, so the rebuilt parts are
    reviewed again (today it deletes `REVIEW.md`).
- `split-plan/VERIFY.md`, new, from `split-change-into-chunks/VERIFY.md`:
  everything placed once, word for word; nothing in a part asks for more
  than `plan.md` does; what passes between parts; each part one context
  long; the parts rest on code that is there. Gone: the journey-based
  checks, `after:`, the developer's questions.
- `implement-plan/SKILL.md`, new, not typed. Builds one part with
  `/implement-code`, says it commits itself, and adds only the plan's rules
  (spec 175-181, 407-412):
  - reads its part; may read `plan.md` and the later parts to update them;
  - may change any soft decision;
  - where the build departs from the plan, updates the part, `plan.md` and
    the later parts in the same commit;
  - where it would change a hard decision the developer approved, or an
    existing `.hard.` file its part does not list as changed, halts as
    `departure` (Q8); where it cannot go on,
    `blocked`; a failure it cannot explain, `mystery` (H3);
  - never asks: nobody is there;
  - writes the tests the part lists as hard, named `.hard.`;
  - writes what `implement-code` leaves standing into the part's
    `## Left standing`, sets `status: done`, and commits code, part and any
    plan updates together.
- `README.md`: entries for both.

**Carries out:** run.sh (the split-plan and implement-plan bullets);
implement-code and review-code (what `implement-plan` adds); Backlog items
this affects (`split-checks-its-chunks-at-most-twice.md`).

**Checked by:** `./test.sh`. Walked by a person with the run in part 6.

### Part 5a. The drift pre-flight goes

**Achieves:** a small first step of the runner's switch, under today's
names, so part 5b fits one session. Nothing is left for drift to check in
v4 (H3).

**Files:**

- `run/drift.sh`: deleted. `journeys_touched` moves to `run/chunks.sh`. The
  departure halt on a build that changes `journeys/` stays.
- `run.sh`, `run/loop.sh`: the two `preflight` calls go. `after:` stays for
  now: `ready_chunk` still reads it.
- `run/chunks.sh`: `halt_kind` no longer knows `drift`.
- `tests/run/drift.sh`: delete the cases for the Problem, the journeys and
  `after:` naming a chunk; move the two departure cases (a build and the
  review change a journey) to `tests/run/loop-sessions.sh` and
  `tests/run/report.sh`. Delete the file.
- `tests/run/report.sh`, `tests/run/chunks.sh`: the cases that halt on
  drift go: a run stopped by drift, and drift halted once on a restart.
- `README.md`: the drift paragraph of "The runner" goes, and exit code 2
  means only "refused".

**Carries out:** H3 (no `drift`).

**Checked by:** `./test.sh`.

### Part 5b. `run.sh` builds `plan.md` and its parts

**Achieves:** the runner of v4 (spec 394-415, 612). The end review still
ends in `REVIEW.md`; part 6 changes that.

Do the test harness and the stub first, then the runner, then the suites
one at a time.

**Files:**

- `run.sh`: requires `plan.md` in the directory (today `CHANGE.md`);
  `CHANGE` and `CHUNKS` become the plan and its parts; the refusal on main
  or master says "a change is built on its own branch" and names no skill.
- `run/chunks.sh`: the parts are `plan/[0-9][0-9].md`, else `plan.md`
  itself; a file is a part when its frontmatter has
  `status:` (today: `journeys:`); `split_change` runs `/split-plan`;
  `halt_kind` knows `blocked`, `mystery`, `departure`, `exhausted` and
  `unbuilt` (H3).
- `run/loop.sh`: `ready_chunk` takes the first ready part in number order,
  with no `after:`.
- `run/prompts.sh`:
  - `brief` says "Use /implement-plan on …", names the halt kinds of H3,
    and no longer says `undecided`;
  - `brief` drops "Do not open" the whole change: `implement-plan` may read
    `plan.md` and update the later parts;
  - `split_brief` starts with `/split-plan`;
  - `review_brief`: the session runs `review-code` on the whole diff, with
    `plan.md` as the spec, looking for what lies between the parts; no
    `walk-user-journeys`; it names `/implement-code`, not
    `/implement-change`, for what is left standing (Q1).
- `run/report.sh`: `review_base` starts where `plan/` was first added, as it starts at
  `chunks/` today.
- `run/session.sh`, `run/run-skill.sh`: comments that name chunks or
  `implement-change`.
- `tests/run/harness.sh`: `workspace` builds `plan.md` and `plan/01.md`,
  `plan/02.md` with no `after:`; `unsplit`, `chunk` and `chunk_path`
  follow.
- `tests/stub-session`: it tells sessions apart by how the prompt opens
  (`Use /implement-change on …`, `/split-change-into-chunks on …`); those
  become `Use /implement-plan on …` and `/split-plan on …`. `split-two` and
  `split-dirty` write the two parts. The header says so.
- `tests/run.sh`, `tests/run/chunks.sh`, `tests/run/loop.sh`,
  `tests/run/loop-checks.sh`, `tests/run/loop-sessions.sh`,
  `tests/run/prompts.sh`, `tests/run/report.sh`, `tests/run/run-skill.sh`,
  `tests/run/session.sh`: the file names, and the cases listed under
  Tests below.
- `.claude/skills/run/SKILL.md`, `.claude/skills/run/demo-repo.sh`: the
  demo change has `plan.md` and two parts.
- `README.md`: "The runner" and "The tests" rewritten for `plan.md` and its
  parts, the halt kinds and no walk. The run skill (`run_skill`) stays: the
  walker at acceptance uses it.

**Carries out:** run.sh; the Skills table rows for `run.sh` and `run/`;
Reviews (the "end of run.sh" row); H1-H3; Backlog items this affects
(`continue-after-an-undecided-halt.md`, `walk-less-during-a-run.md`).

**Checked by:** `./test.sh`. A stub run with the `run` skill, twice:
`plan build build review` on the split demo change ends in "next:
/accept-change"; the same after `git rm` of the parts, with `plan split-two
build build review`.

### Part 6. The end-of-run review writes into `plan.md`

**Achieves:** no `REVIEW.md` (spec 531-545). The review's leftovers go
where acceptance reads every other build's.

**Files:**

- `run/prompts.sh`, `review_brief`: the session fixes blockers and
  should-fix, two rounds at most; what it left goes into `plan.md`'s
  `## Left standing`; it sets `plan.md`'s `status: done` and commits (H2,
  Q2). `REVIEW_STOPPED_EARLY` and `red_review_checks` say `plan.md`.
- `run/report.sh`: `final_review` knows the review finished by `plan.md`'s
  `status: done` in HEAD, not by `REVIEW.md`; `review_checks` follows;
  `end_run` says "parts" where it prints to the developer.
- `run.sh`: `REVIEW` goes.
- `run/chunks.sh`, `run/loop.sh`, `run/report.sh`: the identifiers `chunk`,
  `CHUNK_FILES`, `load_chunks`, `ready_chunk` and the like become `part`.
  Soft, but the next reader of the runner should find v4's words.
- `tests/stub-session`: `review` and its variants set `plan.md` done
  instead of writing `REVIEW.md`; the header says so.
- `tests/run/report.sh`, `tests/run/prompts.sh`: the cases listed under
  Tests.
- `README.md`: "The final review" paragraph.

**Carries out:** run.sh (the end review); What lasts (no `REVIEW.md`).

**Checked by:** `./test.sh`. A stub run with the `run` skill: `plan build
build review` ends in "next: /accept-change", and `plan.md` in HEAD is
`status: done`; `R` again does not start a second review. Then a person
runs `./run.sh` once on the real `claude` in a scratch project with a
`plan.md` of two clear halves: `split-plan` writes two parts, each is built
through `implement-plan` and `implement-code` and reviewed by
`review-code`, and the end review sets `plan.md` done.

### Part 7. Acceptance reviews and walks the whole change; the old build skills go

**Achieves:** the review and the walk of the whole change happen once, at
acceptance, against whatever spec the build came from (spec 417-435, 454).
`split-change-into-chunks` and `implement-change` are deleted.

**Files:**

- `accept-change/SKILL.md`:
  - takes the change's directory, and holds the build against its spec:
    for a change, `intent.md`, `spec.md` and the journeys; for a bug, that
    the bug no longer happens; for `solve-problem`, each item on its "Done
    when" list. All three are in `spec.md` (Q3);
  - spawns `review-change` and `walk-user-journeys` on the whole change,
    side by side, in fresh contexts. `review-change` gets the diff from
    the base `signals.sh` prints. Then it shows the developer the journeys
    step by step, and the developer walks it (spec 420-421);
  - reads every `## Left standing` in the directory: `plan.md` and its
    parts;
  - shows every diff that touches a `.hard.` file, and everything hard to
    undo (spec 428-429);
  - "Fix now" uses `/implement-code`; "Back to design" goes to
    `/design-user-journeys` until part 11;
  - what goes, because the two subagents now do it: its own walk of every
    journey, its own reading of the diff for what goes beyond what was
    agreed, and the subagent that looks for what it missed. It keeps
    `signals.sh`, holding the change against its spec, and settling what
    was left open. The report loses the Tradeoffs heading, which are soft
    (spec 67-68);
  - on acceptance deletes the whole directory: `intent.md`, `spec.md`,
    `prototype/`, `plan.md`, `plan/` (spec 536-545).
- `accept-change/signals.sh`: a new kind, `hard tests`, for any path with
  `.hard.` in its file name. The base stays "the commit before the first
  that added anything under the directory"; the header comment, which says
  "the commit before CHANGE.md", says that.
- `accept-change/CHANGE_FORMAT.md`: deleted.
- `review-change/SKILL.md` (spec 184-185, 606): runs at acceptance on the
  whole change, and is still called directly before a merge. It uses
  `/review-code` for the code, then adds what only the pipeline has: the
  journeys; the four goals; the hard tests (each journey's *what* has a
  hard test from the outside; a changed `.hard.` file is shown); the
  constraints under `## Constraints` in `CLAUDE.md`; what could go; what is
  hard to undo. "A diff that touches `journeys/` is a blocker" goes: at
  acceptance the diff holds the design's journey edits, and `run.sh`
  already stops a build that touches them. The description no longer names
  `implement-change` or the final review.
- `walk-user-journeys/SKILL.md`: walks once, at acceptance; the
  description says `accept-change` spawns it.
- `split-change-into-chunks/`, `implement-change/`: deleted, with their
  copies of `CHANGE_FORMAT.md` and `JOURNEY_FORMAT.md`.
- `tests/signals.sh`: the case under Tests below.
- `README.md`: the entries; the two deleted skills gone; the `VERIFY.md`
  paragraph names the skills that hold one now. Run `./sync.sh`.

"When it goes wrong" goes from these skills in part 11, with the journey
format.

**Carries out:** accept-change; Reviews (the `accept-change` row, hard to
undo); Hard tests (the developer sees every diff touching one); the Skills
table rows for `review-change`, `walk-user-journeys`, `accept-change`,
`split-plan` and `implement-plan` ("replaces").

**Checked by:** `./test.sh`, and `grep -rn
'implement-change\|split-change-into-chunks'` outside `changes/` finds
nothing. A person runs `/accept-change` on the scratch project part 6 left:
both subagents run, a `.hard.` diff is shown, the design's journey edit is
not a blocker, and on yes the directory is deleted.

### Part 8. Small work uses `implement-code`; larger work goes to `create-plan`

**Achieves:** every path outside the pipeline that writes code gets the
same review (spec 96-100, 187), and the other ways into the pipeline (spec
124-133, 153-157).

**Files:**

- `debug/SKILL.md`:
  - outcome 3 builds the fix with `/implement-code`, given the report, the
    agreed intention, the cause and the reproducing test as its spec, and
    says it commits itself: the fix with the friction note. No more
    `review-change`;
  - the reproducing test is a hard test: named `.hard.` and in the user's
    words. Where a journey's hard test missed the bug, it strengthens that
    test, which needs the developer's yes;
  - a fix larger than one session goes to `/create-plan`: `debug` makes the
    branch `YYYY-MM-DD-fix-<slug>`, writes
    `changes/YYYY-MM-DD-fix-<slug>/spec.md` with the report, the agreed
    intention and the cause, and commits it (Q3). The plan's first step is
    the reproducing test.
- `solve-problem/SKILL.md`: "Build it" uses `/implement-code`, with the
  agreed result and the "Done when" list as its spec, in place of its own
  build steps and fresh reviewer. It says it commits itself: after the
  user's yes, with the backlog item's deletion. Work that does not fit one
  session, or has a hard decision the developer has not seen, goes to
  `/create-plan` the same way as `debug`'s. Alternatives come simplest
  first, and the simplest is called that (spec 58-60).
- `refactor-codebase/SKILL.md`: "The journeys' tests pass without being
  changed" becomes "the hard tests pass without being changed", in the
  rule at the top and in "Build it". "Review it" spawns `review-code` with
  the plan items as the spec, and says that a changed `.hard.` file is a
  blocker. Items too large for this session go to `/create-plan` the same
  way (spec 131: "perhaps"; see Could wait).
- `upgrade-dependencies/SKILL.md` (spec 135-151):
  - mechanical upgrades as today;
  - the "manual follow-up" list goes to `/backlog`, one item per upgrade
    that needs real code changes, holding the changelog's migration notes
    and what failed; such an item is built with `/implement-code` where it
    fits one session and has no hard decision, and through `/create-plan`
    otherwise;
  - hard tests pass unchanged; an upgrade that would need a hard test
    changed goes to the developer;
  - replacing a library is a hard decision: propose it, do not do it;
  - each commit of the upgrade is reviewed by `review-code`, against the
    changelogs.
- `README.md`: the four entries.

**Carries out:** Principle 4; Pipeline (other ways in, `upgrade-dependencies`,
the small-work rule); implement-code and review-code (the last line); Hard
tests (the refactor rule, `debug`'s regression tests); the Skills table
rows for `debug`, `solve-problem`, `refactor-codebase` and
`upgrade-dependencies`.

**Checked by:** `./test.sh`. A person runs `/debug` once in a scratch
repository with a planted bug: the fix comes through `implement-code`, the
test is named `.hard.`, `review-code` reviews it, and one commit holds the
fix.

### Part 9. `/idea` writes `intent.md`

**Achieves:** what `/idea` agreed survives the conversation (spec 191-227).

**Files:**

- `idea/INTENT_FORMAT.md`, new: the shape of H7, and the file's first two
  stages (a backlog note, and after `/idea`). Part 11 adds the third. Copies in
  `backlog/INTENT_FORMAT.md` and `accept-change/INTENT_FORMAT.md`.
- `idea/SKILL.md`:
  - writes the agreed statement, in `INTENT_FORMAT.md`'s headings, into the
    backlog item it came from and commits that file alone; for a new idea
    it hands the same to `/backlog`, which writes, sizes and commits the
    item (Q7). Either way the commit lands on main, before any change
    branch exists (Q6). The solution the developer arrived with is marked
    as evidence;
  - digs under a constraint the developer arrives with: where the answer is
    part of the problem, it goes under "What must stay true"; where it only
    limits the solutions, it is named as a hard decision for later;
  - no longer says "There is no file";
  - a picked item that already holds an agreed problem: state it back and
    ask whether it still holds, as today.
- `idea/VERIFY.md`: checks "What must stay true" with the same
  no-mechanism rule, and reports what could go: a part of the statement
  the instance does not need.
- `backlog/SKILL.md`: an item can hold what `/idea` agreed, in
  `INTENT_FORMAT.md`'s headings; keep them when extending the item. When
  `/idea` hands it a new idea, it writes the parts as given, and adds
  sizes and commits as for any new item.
- `accept-change/SKILL.md`: holds the change against `intent.md`'s parts,
  as `INTENT_FORMAT.md` names them.
- `README.md`: the entries.

**Carries out:** /idea (all bullets but the move); Skills table rows for
`idea` and `backlog`; H7.

**Checked by:** `./test.sh` (the three copies are identical). A person
runs `/idea` once on a backlog item in a scratch repository: the item gains
the six headings, and the commit holds only that file.

### Part 10. `design-domain` and `design-frontend`

**Achieves:** the two new design parts, usable on their own (spec 240-247,
283-331).

**Files:**

- `design-domain/UBIQUITOUS_LANGUAGE_FORMAT.md`: a copy of
  `init-ubiquitous-language/UBIQUITOUS_LANGUAGE_FORMAT.md`.
- `design-domain/SKILL.md`, new, not typed:
  - draws the current domain model from the schema and
    `UBIQUITOUS_LANGUAGE.md`, in the glossary's words, without IDs, join
    tables or sync columns;
  - works out with the developer the things, how they hang together, their
    rules and lifecycle, in the user's words; alternatives simplest first;
  - says why the model is shaped as it is, as a rule a user relies on, so
    `create-plan` can make it a hard test;
  - updates `UBIQUITOUS_LANGUAGE.md` when the change brings new words;
    where there is none, says `/init-ubiquitous-language` writes one;
  - hands the agreed model back to its caller; writes no file but the
    glossary; keeps no domain document.
- `design-frontend/SKILL.md`, new, not typed:
  - takes over from `design-user-journeys/SKILL.md` the prototype (publish
    as an Artifact, keep a copy in `prototype/`, which holds only the
    agreed one) and the questions for anything a user sees (feedback,
    actions that cannot be undone, narrowest and widest screen, rare
    actions);
  - in an app that exists, reads the theme, the shared components and the
    screens, and designs to match; writes no design-system document;
  - for a new app, proposes several design systems with a recommendation,
    simplest first, and the developer picks one; the first change builds it
    as code;
  - may start from the plugin skill `frontend-design:frontend-design`;
  - hands the agreed design and prototype back to its caller; used on its
    own, the developer commits them.
- `README.md`: entries for both.

**Carries out:** create-spec (design-domain, no lasting domain document,
`UBIQUITOUS_LANGUAGE.md`, design-frontend, design system in the code, a
new app's design system); Skills table rows for `design-domain`,
`design-frontend` and `init-ubiquitous-language`.

**Checked by:** `./test.sh` (the glossary format's copies are identical).
A person runs `/design-domain` once in a project with a schema and a
glossary: the drawn model uses the glossary's words and leaves out IDs.

### Part 11. `create-spec`, and light journeys

**Achieves:** the one entry point to the design, which writes `spec.md`
(spec 229-356, 551-588). After this part the whole v4 pipeline runs.

**Files:**

- `create-spec/SPEC_FORMAT.md`, new, and copies in
  `create-plan/SPEC_FORMAT.md` and `accept-change/SPEC_FORMAT.md`. The
  shape of `spec.md`: a pointer to `intent.md`, no Problem; one section per
  design part it has (journeys, domain, frontend with the prototype link
  and "Agreed: build to this"); `## Failure cases`, each "If <what goes
  wrong>, the user sees <what>, and their work <is kept / is lost>";
  `## Constraints`, each one statement with one condition, how it is met
  and how it is checked; `## Not in this change`. What the parts are for,
  and that it is deleted at acceptance.
- `INTENT_FORMAT.md`, all four copies (`idea`, `backlog`, `accept-change`
  and the new `create-spec/INTENT_FORMAT.md`): the third stage, the move
  into the change's directory, and that it is deleted at acceptance.
- `create-spec/JOURNEY_FORMAT.md`: a copy of the new journey format.
- `create-spec/SKILL.md`, new, typed:
  - starts from `intent.md` (runs `/idea` first where there is none);
  - decides which parts the change needs, and uses
    `/design-user-journeys` first, then `/design-domain` and
    `/design-frontend` where needed;
  - holds every part against the instance in `intent.md`, and proposes the
    spec as "needed for the instance" and "could wait"; the developer
    decides each item;
  - a failure case goes in only if it would really happen to this user;
  - shows a conflict between two parts, and the developer decides;
  - lists the constraints: what must stay true from `intent.md`, and the
    limits found in the design;
  - makes the change's branch first, so the `design-*` skills write onto
    it; writes `spec.md`; the journeys, `prototype/` and the glossary are
    written by the `design-*` skill that owns each;
  - spawns a fresh agent with `VERIFY.md`, the formats and the change's
    directory; works in what it finds; asks for the final yes;
  - moves the backlog item to `changes/<dir>/intent.md` with `git mv`,
    without its frontmatter; writes each "could wait" item to the backlog,
    with the Problem and Outcome it rests on copied in, and a line naming
    the change (Q5); commits all of it together;
  - ends by naming `/create-plan`.
- `create-spec/VERIFY.md`, new: `spec.md` against `intent.md`: nothing
  missing; nothing that serves no part of the problem, each part naming
  what it serves; each failure case earns its place and has its three
  parts; each constraint has one condition, how it is met and how it is
  checked; nothing is a detail of the code; it can be planned without
  asking. Takes the user-facing probes and the "can be tested" rule from
  `design-user-journeys/VERIFY.md`.
- `JOURNEY_FORMAT.md`, every copy (`design-user-journeys`, `review-change`,
  `walk-user-journeys`, `accept-change`, `debug`, `refactor-codebase`,
  `create-spec`): light journeys (spec 259-265); no "When it goes wrong";
  "Who" still grants access; which steps stay and how they are numbered
  per Q14.
- `design-user-journeys/SKILL.md`: light journeys only; no prototype (now
  `design-frontend`'s); no "what can go wrong at every step"; no
  `CHANGE.md`, no branch, no verifier, no commit; writes the agreed
  journeys into `journeys/` and hands them back to its caller; used on its
  own, the developer commits them; alternatives simplest first;
  `disable-model-invocation` removed (H4).
- `design-user-journeys/VERIFY.md`, `design-user-journeys/CHANGE_FORMAT.md`:
  deleted (spec 248-249: one verifier for the whole spec; Q10).
- `walk-user-journeys/SKILL.md`, `review-change/SKILL.md`,
  `accept-change/SKILL.md`: "When it goes wrong" goes from the walk, the
  test check and the report. At acceptance, the failure cases in `spec.md`
  are walked and checked in its place.
- `idea/SKILL.md`: the way on is `/create-spec` or `/solve-problem`.
- `debug/SKILL.md`: outcome 2 says what the software should do instead is
  settled through `/idea` and `/create-spec`.
- `accept-change/SKILL.md`: "Back to design" goes to `/create-spec`.
- `backlog/SKILL.md`: `create-spec` moves a picked item into the change.
- `README.md`: "How it works", "What lives where", the entries; run
  `./sync.sh`.

**Carries out:** create-spec, all of it; The size of a change; What lasts
(the table); /idea (the move); the Skills table rows for `create-spec`,
`design-user-journeys`, `CHANGE_FORMAT.md` and `JOURNEY_FORMAT.md`.

**Checked by:** `./test.sh` (every copy identical; no pointer to the
deleted files). A person walks the whole pipeline once in a scratch
project with a tiny app: `/idea` on a backlog item, `/create-spec`,
`/create-plan`, `./run.sh` on the real `claude`, `/accept-change`. Note the
time each stage took and where the developer was asked something soft.

### Part 12. The rest of the docs, and the backlog

**Achieves:** nothing in the repository still describes v3.

**Files:**

- `README.md`: read whole against v4.
- `retro/SKILL.md`: the run's files are `plan.md` and its parts, their
  `## Halt` and `## Left standing`.
- `explain-diff/SKILL.md`: the claim files are `intent.md`, `spec.md`,
  `plan.md` and its parts. `facts.sh` needs no change: it reads any file
  under `changes/<slug>/`.
- `changes/backlog/`:
  - delete the five items v4 is made of (spec 7-11), and
    `walk-less-during-a-run.md` and
    `split-checks-its-chunks-at-most-twice.md`, which v4 settles;
  - in `continue-after-an-undecided-halt.md` and `claude-starts-run-sh.md`,
    replace the halt kinds with H3's;
  - in `try-code-review.md`, `rebuild-coding-standards-from-evidence.md`
    and `security-beyond-access.md`, replace `implement-change` and
    `review-change` with the v4 skills spec 629-635 names.
- `changes/2026-11-03-pipeline-v4/`: deleted, as acceptance would.

**Carries out:** Backlog items this affects; What lasts (this change's own
directory).

**Checked by:** `./test.sh`; `grep -rn 'CHANGE\.md\|chunk\|REVIEW\.md\|When
it goes wrong' --include='*.md'` outside `changes/` finds nothing.

## Tests

Tests this plan adds or changes, in `./test.sh`. None is a `.hard.` test:
that rule is for projects that use the skills.

| Test | Part | What breaks if it is wrong |
|---|---|---|
| `tests/run/harness.sh` and `tests/stub-session` build `plan.md` and `plan/NN.md` | 5b | every runner suite tests a layout no project has |
| `tests/run.sh`: a directory without `plan.md` is refused | 5b | the runner starts on a change nobody planned |
| `tests/run/chunks.sh`: the split runs `/split-plan` on a first start, writes parts that are loaded, and a `plan.md` that fits is built as it is | 5b | the runner builds the wrong files, or splits again on a restart |
| `tests/run/loop.sh`: parts are built in number order, with no `after:` | 5b | parts build out of order, and a later part finds nothing of what an earlier one makes |
| `tests/run/loop-sessions.sh`: a part halted as `departure` by its session stops the run, and the kind is read back | 5b | a session's new halt kind reads as "kind not named" |
| `tests/run/prompts.sh`: the build brief names `/implement-plan` and no `undecided`; the split brief starts with `/split-plan`; the end review's brief names `review-code` and no walker | 5b | sessions load skills that are gone, or the run walks again at its end |
| the cases moved from `tests/run/drift.sh`: a build or the end review that changes `journeys/` halts as `departure` | 5a | builds change approved journeys without a word |
| `tests/run/drift.sh`: deleted with `run/drift.sh` | 5a | — |
| `tests/run/report.sh`: the end review counts as finished when `plan.md` is `status: done` in HEAD; a run started again does not review again; after a new split sets it back to `ready`, the review runs again | 6 | a run reviews twice, or points on to acceptance with no review |
| `tests/signals.sh`: a diff that touches `invoice.hard.test.ts` prints it under `hard tests` | 7 | a changed hard test reaches acceptance without the developer seeing it |
| `test.sh`'s shared-file check now also covers `PLAN_FORMAT.md`, `SPEC_FORMAT.md`, `INTENT_FORMAT.md` and `UBIQUITOUS_LANGUAGE_FORMAT.md` | 3, 4, 9-11 | a skill reads a stale copy of a format. No change to `test.sh`: it finds copies by name |
| `tests/no-dangling.sh` over the new skills | every part | a skill points at one that does not exist. No change: it scans every `SKILL.md` |

## Coverage

Each section of `spec.md`, and the parts that carry it out.

| spec.md section | Parts |
|---|---|
| Why | none: it is the reason, not a task |
| Principle 1, the smallest software | 1 (goal), 2 (`review-code`), 3, 4, 7, 8, 9, 10, 11 (every adversary reports excess; simplest first) |
| Principle 2, hard and soft | 2, 3, 4 |
| Principle 3, the developer's attention | 3 (UI stays out of the plan) |
| Principle 4, each level reviewed; all code reviewed | 2, 3, 4, 5b, 7, 8, 11 |
| The pipeline | 1, 5b, 11 |
| Other ways in | 3, 8 |
| `upgrade-dependencies` stays outside | 8 |
| Small work in the session | 8 |
| implement-code and review-code | 2, 4, 7, 8 |
| /idea | 9, 11 (the move) |
| create-spec, and its parts | 10, 11 |
| Light journeys; no "When it goes wrong"; failure-case shape | 11 |
| design-domain; no lasting domain document; `UBIQUITOUS_LANGUAGE.md` | 10 |
| design-frontend; design system in the code; a new app's | 10 |
| Constraints, and how they outlive `spec.md` | 3, 7 (`review-change`), 11 |
| create-plan | 3 |
| run.sh | 4, 5a, 5b, 6 |
| accept-change | 7, 9, 11 |
| Reviews, and what is hard to undo | 2, 3, 4, 5b, 7, 11 |
| Hard decisions | 2, 3, 4 |
| Hard tests | 1, 2, 4, 7, 8 |
| What lasts, and what is deleted | 1, 6, 7, 11, 12 |
| The size of a change | 3 (storage choice), 11 |
| Skills | every row in the part named above |
| Backlog items this affects | 4, 5b, 12 |

Things this plan does that `spec.md` does not ask for, each because
something spec.md asks for needs it:

- Updating `retro`, `explain-diff`, `README.md`, the `run` demo skill, the
  three other backlog items and the tests: they describe or test what v4
  changes.
- Deleting `run/drift.sh` (H3, part 5a): nothing is left for it to check.
- Renaming the runner's identifiers to "part" (part 6): soft, so the next
  reader finds v4's words.
- The format files `PLAN_FORMAT.md`, `SPEC_FORMAT.md`, `INTENT_FORMAT.md`:
  several skills need each shape, and a skill sees only its own directory.

## Could wait

The developer decides what moves. Nothing here is cut from the plan.

- **The refactor's hand-over to `create-plan`** (part 8): spec 131 says
  "perhaps". A refactor that does not fit one session is rare.
- **`upgrade-dependencies`** (part 8): it stays outside the pipeline, and
  nothing else depends on it.
- **The new-app design system in `design-frontend`** (part 10): needed only
  when a new app is designed.
- **The identifier rename in part 6**: nothing outside the runner sees it.
- **The backlog clean-up** (part 12): harmless to leave for a while.

## Questions

Gaps and contradictions found in `spec.md`, and how the developer settled
each, with the part that depends on it. All are settled.

- **Q1. Is there a review at the end of `run.sh`?** The pipeline (spec 118)
  and the Reviews table (spec 453) say "review of the whole against
  `plan.md`". The Skills table (spec 612) says "no final review". Reading:
  a `review-code` session at the end, no walk. (Part 5b.) Settled by the
  developer, 2026-11-03: as read.
- **Q2. Who fixes what the end review finds, and where does the rest go?**
  `review-code` changes nothing (spec 171-173), and `REVIEW.md` is not among
  a change's files (spec 531-545). Reading: the end-review session fixes
  blockers and should-fix, two rounds at most, writes the rest into
  `plan.md`'s `## Left standing`, and sets `plan.md`'s `status: done`.
  (Part 6.) Settled by the developer, 2026-11-03: as read.
- **Q3. Where does a specification that is not a `spec.md` live?** `debug`,
  `solve-problem` and `refactor-codebase` hand larger work to
  `create-plan`, and `accept-change` holds the build against it. spec.md
  does not say in which file the bug's cause or the "Done when" list is
  kept, or who makes the branch. Reading: the caller makes the branch and
  writes `changes/<dir>/spec.md` in its own words, and `create-plan`
  writes `plan.md` beside it. (Parts 7, 8.) Settled by the developer,
  2026-11-03: as read. The caller writes `spec.md` in free text and does
  not go through `create-spec`: the work is already agreed, it has no
  `intent.md`, and `create-plan`'s verifier checks the plan against it.
- **Q4. Who writes a constraint's line into `CLAUDE.md`, and when?**
  spec 349-354 says where it goes, not who writes it. Reading:
  `create-plan` makes it a step of the plan, and the build writes it.
  (Part 3.) Settled by H6.
- **Q5. What does a "could wait" backlog item point to?** spec 576-577 says
  it points to the `intent.md` it came from. That file is deleted at
  acceptance (spec 542). Settled by the developer, 2026-11-03: the item
  copies the parts of `intent.md` it rests on, usually Problem and Outcome,
  under the same headings, and names the change it was cut from in one
  line. (Part 11.)
- **Q6. Who moves `intent.md` back when a change is abandoned, and what
  counts as abandoned?** spec 210-211 says it moves back, but no skill
  abandons a change. Settled by the developer, 2026-11-03: nobody moves it.
  `/idea` commits the backlog item on main; `create-spec` makes the
  change's branch first and does the `git mv` on it. Abandoning a change
  means dropping its branch, and the backlog item on main is untouched.
  The README's "What lives where" says so. (Parts 9, 11.)
- **Q7. Does `/idea` propose effort and utility for a new backlog item?**
  spec 207-208 has `/idea` write a new item when there is none, and
  backlog items need both sizes. Settled by the developer, 2026-11-03:
  `/idea` hands a new idea to `/backlog`, which checks for an overlapping
  item, proposes the sizes and commits the file alone. An idea that came
  from an item is still updated by `/idea` itself. (Part 9.)
- **Q8. May the build change a hard test the developer approved changing
  in the plan?** spec 410-412 says `implement-plan` halts where it would
  change "an existing hard test". But a change that edits a journey changes
  that journey's test, and `create-plan` lists that change for the
  developer's yes (spec 378-379, 499). Halting on it would stop every such
  run on its first part. Reading: it halts only on a `.hard.` change its
  part does not list. The runner does not check this itself, as it checks
  `journeys/`. (Part 4.) Settled by the developer, 2026-11-03: as read.
- **Q9. How does a script flag "exported types"?** spec 463-466 names
  them among the places a script flags. They cannot be found by file name,
  as `signals.sh` finds the rest. Settled by the developer, 2026-11-03:
  left to the reviewers; `review-code` checks the callers of every exported
  name it touches.
- **Q10. Do the `design-*` skills, used on their own, have a verifier?**
  spec 248-249 has one verifier for the whole spec, so
  `design-user-journeys/VERIFY.md` goes. Then `design-frontend` used for a
  redesign on its own is checked by nobody. Settled by the developer,
  2026-11-03: no verifier in the `design-*` skills. Used alone, the
  developer judges the result; a build of it goes through `create-plan`,
  whose verifier checks the plan. (Part 11.)
- **Q11. Does the "Backlog" journey in `SDLC.md` change?** The Skills
  table names only "Add a feature", "Debug" and "Refactor". The Backlog
  journey says the item "is deleted" once the change is accepted, but in v4
  it moves into the change as `intent.md` first. Settled by the
  developer, 2026-11-03: part 1 rewrites that one paragraph: the item
  becomes `intent.md` once `/idea` has run, moves into the change's
  directory when the design is committed, and is deleted with it at
  acceptance. (Part 1.)
- **Q12. Where does simplicity go among the goals?** spec 44-46 calls it a
  new goal that serves Utility and Maintainability. The goals are ranked.
  Settled by the developer, 2026-11-03: not a ranked goal. A paragraph
  under "Goals", before the four, says the smallest software that solves
  the problem, and why; the four stay as they are. (Part 1.)
- **Q13. Does `.hard.` work in every language?** spec 518-519 says "the
  same rule holds in any language". It does not:
  - Go's test files must end in `_test.go`, so a hard Go test would be
    `invoice.hard_test.go`, which `grep '\.hard\.'` misses.
  - In Python, a file `test_invoice.hard.py` likely breaks the import, since
    the dot reads as a package.

  Reading: `.hard.` as spec.md says, which works for JavaScript and
  TypeScript. (Parts 2, 7.) Settled by H5.
- **Q14. What does a light journey still hold?** spec 259-265 says it says
  "who uses the software and for what", and that agents "do not need every
  step and special case". But each plan step "names the journey steps it
  makes testable" (spec 364-365), journey tests are hard tests, and a test
  today names its journey and step. Does a light journey keep numbered
  steps, and `*(judged)*`? Settled by the developer, 2026-11-03: Who,
  Wants, and a few numbered steps: as many as a user would tell a
  colleague, usually three to seven, not every click or special case.
  `*(judged)*` stays. Tests and plan steps name journey and step as
  today. (Part 11.)
