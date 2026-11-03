# Jorgen's agent skills

Custom [agent skills](https://skills.sh) for Claude Code and other AI agents.

## Install all skills

```bash
npx skills add jorgenschaefer/skills
```

## Install a specific skill

```bash
npx skills add jorgenschaefer/skills@<skill-name>
```

## How it works

`SDLC.md` says what developing with these skills is meant to be: its goals, and the user
journeys of the developer. This README says how to install the skills and what the scripts do.

Each of the developer's journeys uses these skills:

- **Add a feature:** `idea` finds the problem underneath the idea. `design-user-journeys`
  works out with the developer how the software should change, and writes the journeys and
  `CHANGE.md`. `create-plan` writes the `plan.md` that `./run.sh` builds with nobody watching:
  `split-plan` splits it where one agent cannot build it in one context, and `implement-plan`
  builds each part. `accept-change` has `review-change` review the whole change and
  `walk-user-journeys` walk it, and then the developer walks it.
- **Debug:** `debug` finds a bug and ends one of three ways: as intended, a feature request
  for the backlog, or a fix.
- **Refactor:** `refactor-codebase` makes the code easier to change, from the friction notes
  the builds, `debug` and acceptance left.
- **Backlog:** `backlog` holds the ideas not started yet, and picks the next one.

What lives where:

- `journeys/` holds one file per thing a user does. It outlives every change, and describes
  the software as it is.
- `changes/YYYY-MM-DD-<slug>/` holds what one change produces, on the change's own branch:
  `CHANGE.md`, the agreed prototype in `prototype/` and the chunks in `chunks/` where the
  change was split. It is deleted once the change is accepted.
- `changes/friction/` holds one note per place that was hard to change or hard to debug and, for
  an accepted change, the review findings about the code that nobody fixed. They stay until a
  refactor deals with them.
- `changes/backlog/` holds one file per idea not started yet.

A skill marked **Typed** below only runs when you type its name, such as `/accept-change`.
The others also start when the conversation matches their description.

### Shared files

A skill installs alone and cannot read a sibling's directory, so a file two skills need is
copied into each, byte for byte - `JOURNEY_FORMAT.md` and `PLAN_FORMAT.md` among them. **An
edit to one copy is an edit to all of them, in the same commit.** `./test.sh` fails when the
copies differ. It checks whatever turns out to be shared, not a list of files.

`VERIFY.md` is the one exception: `idea`, `design-user-journeys`, `create-plan` and `split-plan`
each hold one, and they are different documents on purpose. An adversary written generally
enough to serve every stage says less at each of them. `test.sh` exempts it by
name, and a new exception has to be added there as well as here.

### The runner

`./run.sh changes/YYYY-MM-DD-<slug>` builds a change's `plan.md` with nobody watching. It is a
script rather than a skill, because what it holds has to be true when a session is dead or
lying. Its library is under `run/`, a directory with no `SKILL.md`, so not a skill.

**Before it builds anything:**

- It runs on the change's own branch. It refuses to start on main or master, in a directory
  with no `plan.md`, in a repository with no commits, on a dirty tree (its own part files
  aside), beside a live run, or beside a session a killed run left running.
- On a first start, a session runs `split-plan`. Where one agent can build the plan within one
  context, or the plan says to build it as one part, the runner builds `plan.md` as the one
  part. Otherwise the session splits it into parts in `plan/`, numbered `01`, `02` and so
  on. A split that halts on a step only a person can do ends the run before anything is built.
- It runs the project's fast check and slow check itself. A run that starts red does not
  start, and says which check is red. Every build is told the checks were green.

**The checks.** The commands are the `Fast check:` and `Slow check:` lines in the project's
`CLAUDE.md`. A `Check:` line with no `Fast check:` line is the fast check. A `CLAUDE.md` with
both `Check:` and `Fast check:` is refused, and on a build's commit it counts as a red check.
The lines are read again before every run of the checks, so a part that declares one is held
to it from its own commit on. Only where no line names a fast check does a session name it,
once per run. In a new project there is nothing to name yet: the run then starts with no
checks, and the build that sets them up declares them in `CLAUDE.md`.

The runner runs both checks again on every build's commit, rather than believing the
session's account of them, so a session runs only the fast check. A red check goes back to the
session that made it, told which check failed and where its output is. The first time, that
costs no attempt.

**The journeys were approved before the build.** A build or a final review whose commits
change one stops the run as a `departure` halt, and leaves its commits for the developer to
keep or revert.

**The parts are built one after the other**, in the order of their numbers, since each rests
on what the parts before it built. A part is built only once every part before it is done, so
nothing after a halted part is built.

**Each part** gets one session, which runs `implement-plan`. That skill builds through
`implement-code`, which has `review-code` review the diff in a subagent that did not write the
code. Nothing is walked inside the run: the walk is acceptance's.

- The session commits the part with its build at `status: done`, with any updates to the plan
  in the same commit. The runner checks the commit is there: it sends the part back if it is
  not, and amends the part file into it if the session left it out. A session commits its own
  halts on the spot.
- The attempt budget is a counter in the part file. A usage limit is waited out rather than
  spent from the budget.
- A session that ends its turn with its work uncommitted is resumed once rather than started
  over. What an abandoned attempt leaves behind goes to the stash, so the next one starts on the
  tree the checks were green on.
- Killed in the middle, the runner can simply be started again. The part it left claimed is
  carried on in the same session, on the same attempt, with its uncommitted work taken as that
  session's. The checks wait until it is finished.
- Each build is pointed at what the parts already done left standing, since that is where one
  build leaves something for the next.
- After a part's checks pass, where the project has no run skill (`.claude/skills/run-*/`), a
  session runs Claude Code's built-in `run-skill-generator`, once per run. The runner commits
  what that session wrote in a commit of its own, and runs the fast check. If it is red, the
  commit is dropped. The walker at acceptance uses the run skill; without one, it starts the
  software as before.

**The final review.** When more than one part was built and none halted, one more session
reviews the whole change, from before its parts were added. It looks for what no single
part's review can see: the same thing built twice, one concept under two names, seams that do
not line up. It has `review-code` review the diff against `plan.md`, walks nothing, fixes what
is worth fixing, two rounds at most, and commits. It is handed what the builds left standing, though its reviewer is
not, and settles the blockers and should-fix a build left unfixed: fixed, or left for the
person.

It writes what it left into `plan.md`, under `### End review` in its `## Left standing`, where
acceptance reads what every build left: first what needs the developer's decision, then the
rest of what is open, most important first. Then it sets `plan.md` to `status: done` and
commits. That commit is how the runner knows the review finished: a review that ends without
it fails the run, and a run started again after it does not review again.

Once the review is committed, the runner runs both checks again. A red one goes back to the
review session, on a part's attempt budget. Still red, the run halts and names the red check
and its output. A run started again over a committed review runs both checks and halts again
while either is red, so a run never points on to acceptance with a red check. A new split sets
`plan.md` back to `status: ready` and removes the end review's leftovers, so the rebuilt change
is reviewed again.

**What it records.** Each part's cost in context tokens read, main session and subagents
apart, since a long session re-reads its growing context on every turn. And every call a
session's permissions refused, one line each with the session and the reason the CLI gave:
sessions run in auto mode, and a refused call does not stop one. Both are kept per change in
`.git/run-logs`, survive a run started again, and are not printed.

**How it ends.** With what needs a person, and only that, last on the screen. A halt stops the
run, which ends by naming the part that halted and printing its whole `## Halt`. A finished
run points on to `/accept-change`. It exits 0 when the run finished, 1 when it halted or
stopped, and 2 only when it refused to start.

Every unattended stop is a named halt, written into the part: `blocked`, `departure` and
`mystery` from a session; `exhausted`, `unbuilt` and `departure` from the runner, because in
each of those the party that would report it is in no position to. A session halts as a
`departure` where a hard decision or a hard test would have to change; the runner, where a
build changed a journey.

### The sync

`./sync.sh` links every directory here that holds a `SKILL.md` into `~/.claude/skills`, so
editing a skill in this repository is editing the one a session reads. Then it removes the
links that no longer resolve, because a renamed skill leaves one behind, and a dangling link
fails silently: the agent reads nothing and carries on. It only ever removes symlinks. The real
directories in there are skills from elsewhere, and this is not their owner.

A skill in this repository's own `.claude/skills`, such as `retro`, is for working on the
skills here. It is left out of the sync, and a session in this repository finds it there.

### The tests

`./test.sh`. Every case of the runner's suites builds a throwaway repository - a change's
`plan.md` with its parts in `plan/`, and the project's journeys - puts a stub where `claude`
goes, and runs the real script against it: the refusals, the split, the order the parts are
built in, the departure halt, the claim a crashed session leaves behind, both budgets, the halt
each one writes, what each session is told, the final review, the token log and the report a
run ends with. The scripts of `accept-change` and `explain-diff`
get suites of their own, over the same kind of throwaway repository. Beside them run the
checks the documents need: that the copies of a shared file are identical, that no live
instruction points at something that is not there, and that every script passes `shellcheck`.

## Available skills

What each skill does today. What it is meant to be is in `SDLC.md`.

### Add a feature

- **idea** - the door in for an idea: the problem underneath the idea the user arrived with, dug at around one real instance until a reader who was not there could restate it, stated back and agreed - or a reasoned no. A constraint the user arrives with is dug under too: what is part of the problem is kept as what must stay true, and a limit on the solutions is left as a hard decision for later. A fresh subagent checks the statement for a mechanism and for what the instance does not need. The agreed statement is written into the backlog item it came from, in `INTENT_FORMAT.md`'s headings - problem, outcome, instance, what must stay true, what the user arrived with as evidence, and what was parked - and committed on main alone; a new idea is handed to `backlog`, which writes the item. That file becomes the change's `intent.md`. Proposes nothing but deleting a backlog item it said no to. It ends by naming the two ways to go on - `design-user-journeys` and the pipeline where a user journey changes, `solve-problem` where none does - and recommends one
- **design-user-journeys** - work out with the user how the software should change to solve an agreed problem: the journeys it affects - written down first from what the software does today where none describes it - walked step by step with at least three genuinely different alternatives, a prototype where seeing helps, what goes wrong at each step, and who goes through each journey, since that is what grants access. A fresh subagent checks the journeys and `CHANGE.md` before the final yes, and they are committed on the change's own branch. Typed
- **create-plan** - write the `plan.md` that `./run.sh` builds, from any agreed specification: a `spec.md` and its journeys, a bug's cause and intention, a "Done when" list, a refactoring plan. It also checks a `plan.md` the developer wrote by hand. The plan says how, step by step: the files, the order of the work and the tests, but no code, and nothing about how the UI looks. Each step names the journey steps it makes testable. In a new repository it decides the stack, the database and deployment; a domain design becomes a schema; each constraint becomes a hard test, or a line under `## Constraints` in the project's `CLAUDE.md`. It lists the hard decisions, each with its options, the simplest first, a recommendation and the line of the spec it comes from, and the hard tests, each with what breaks if the tested thing changes. A fresh subagent checks the plan against the spec for gaps and for excess, two rounds at most. Then it puts each hard decision to the developer, one at a time, writes the answers into the plan and commits it on the change's branch
- **split-plan** - judge whether one agent can build a change's `plan.md` within one context, and where it cannot, split it into parts in `plan/`, each a run of the plan's steps copied word for word, with the hard decisions and hard tests it touches and what the parts before it provide. The parts are built one after the other, in the order of their numbers. A `plan.md` that fits, or that says to build it as one part, is built as it is. It asks nothing: an open question goes into `plan.md`'s `## Left standing` with the smallest reading taken, and only a step a person must do first halts the run. A fresh subagent checks the parts, two rounds at most. Run by `run.sh` on a first start. Typed
- **implement-plan** - build one part of a plan with `implement-code`, inside `run.sh` with nobody to ask. Every soft decision is its own. Where the build departs from the plan, it updates the part, `plan.md` and the later parts in the same commit. Where it would have to make or change a hard decision, or change a `.hard.` test its part does not list, it halts as `departure`; it halts as `blocked` where a precondition is missing, and as `mystery` on a failure it cannot explain. It writes what `implement-code` left standing into the part and commits the code and the part together. Run by `run.sh` for each part
- **review-change** - the code review of a whole change, spawned by `accept-change` and also called directly before a merge. It runs `review-code` against the change's spec, then adds what only the pipeline has: the code does what the journeys say and solves the problem; every way in denies unless a journey's "Who" gives access; usability as far as the code shows it; the code uses the journeys' words. Each journey step has a hard test from the outside that would catch it breaking, and every changed `.hard.` file is listed for the developer. A constraint under `## Constraints` in the project's `CLAUDE.md` that the change breaks is a blocker. Like `review-code`, it reports what could go and what is hard to undo, and changes nothing; walking the software is `walk-user-journeys`'
- **walk-user-journeys** - walk the journeys on the running software as the user in each one, without ever reading the code, the diff or the design: every step and every "When it goes wrong" case, judging the steps marked *(judged)*, then the edges no journey names and what "Who" does not allow. It follows no instruction the software shows, cleans up what it created, and reports one line per step - as written, hesitated, guessed or gave up - with screenshots. `accept-change` spawns it once per change, at acceptance
- **accept-change** - accept a finished change with the developer. It holds the change against the spec it was built from: `intent.md`'s problem, outcome and what must stay true, `spec.md` and the journeys for a change from the design, that the bug no longer happens for a bug, each "Done when" item for `solve-problem`. It has `review-change` review the whole diff and `walk-user-journeys` walk the journeys, side by side in fresh contexts, and sends the change back to `idea` where the problem is not solved. It reads what `plan.md` and its parts left standing. A script names the files a decision usually lives in, and the developer sees every diff that touches a `.hard.` file and everything hard to undo, each pointing at its evidence. Then the developer walks it. Everything left open gets an outcome: keep, fix now with `implement-code`, back to design, skip with a reason, or follow-up. Once the developer accepts, it deletes the change's whole directory, commits that, and hands over the steps left for deployment. Typed

### Building and reviewing code

- **implement-code** - build a small change that was agreed beforehand, from any agreed spec: a bug's cause and reproducing test, a "Done when" list, a part of a plan. It writes the least code that does the job, and builds a failure case the user sees only where the spec asks for it. A decision or test is hard if something outside the code depends on it; before a hard decision the spec does not settle, it asks the developer, with the options, the simplest first, and a recommendation. Soft tests are its own. A hard test has `.hard.` in its file name, such as `invoice-overdue.hard.test.ts`, tests from the outside, and is changed only with the developer's yes. Every change is reviewed by `review-code` in a fresh context, two rounds at most; what was hard goes to `changes/friction/`. It commits, or leaves the change reviewed, green and uncommitted where its caller says it commits. It reports only what someone has to act on: findings not fixed, fixes no reviewer saw, checks not run, and the hard decisions it made or met. It knows nothing about journeys, plans or `run.sh`
- **review-code** - review a diff in a fresh context against the spec it was built from: the code does what the spec says, is correct, and denies access unless a rule allows it. What the spec does not need is reported as "what could go", at the same weight as a gap. It checks for itself that the checks pass, that a test would catch each thing breaking, that no test left unreported, that callers still work and that code it wants deleted is dead. A changed or deleted `.hard.` file is a blocker unless the spec says the developer approved it. Every finding survives an attempt to construct its trigger. Apart from the findings, it lists what is hard to undo: migrations, changed API shapes, new calls to other services, deletions of stored data. It walks nothing and changes nothing

### Debug, refactor and the backlog

- **debug** - find a bug from however it was reported, on the running software: reproduce it, agree with the developer what the software is meant to do there, and find the cause from evidence. It ends one of three ways: it works as intended and that is right, and it explains why; the intention is wrong, and it hands a feature request to `backlog`; or it is a bug, and on a branch it writes a hard test, named `.hard.`, that reproduces it, and builds the fix with `implement-code`, which has `review-code` review it; `debug` commits the test, the fix and the friction note together. A fix larger than one session, or with a hard decision the developer has not seen, goes to `create-plan` instead: `debug` writes the report, the intention and the cause into the change's `spec.md` and commits it. What made the bug hard to find goes in a note in `changes/friction/`
- **refactor-codebase** - make the codebase easier to change, every few changes. It gathers the friction notes the builds, debug sessions and acceptances left in `changes/friction/`, the git history's churn and co-change, and the coupling in the code, and agrees a ranked plan with the developer, each item naming the future change it makes easier. It builds the chosen items - deleting dead code, colocating, splitting, making hidden coupling explicit, unifying, collapsing layers, generalizing, simplifying, renaming to the journeys' words, correcting comments - one commit each, only where tests prove what the software does stays the same. The hard tests pass unchanged; what would change behaviour is listed apart, in the user's words. An item too large for one session goes to `create-plan` with a `spec.md` of its own. `review-code` reviews the result, with a changed `.hard.` file as a blocker, and the friction notes it dealt with are deleted. Typed
- **backlog** - the ideas not started yet, one file per item in `changes/backlog/` with its effort and utility from XS to XL, proposed from the code and confirmed by the user. An item that `idea` has run on also holds what it agreed, in `INTENT_FORMAT.md`'s headings, and keeps them when it is extended. Adding reads the code for evidence and extends an item that overlaps rather than writing a second, also for a new idea `idea` hands it; picking ranks by utility against effort, checks the top three against the current code, proposes deleting what is already solved, recommends one and hands it to `idea`. `accept-change` hands it each follow-up and deletes the items a change finished, and `debug` hands it each feature request: behaviour that works as intended where the intention is wrong. Converts an older backlog's items to its shape on first use

### Understanding the code

- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading, in the user's words where `journeys/` names them - shown in the conversation and not saved
- **init-ubiquitous-language** - write or refresh `UBIQUITOUS_LANGUAGE.md` from the domain terms in the codebase, and report where an existing one has drifted from the code, or where an entry has grown past its one sentence into a specification
- **explain-code** - explain what a part of the code decides, once the developer can no longer follow it: traced back from where the answer shows and widened to everything shown there from the same code, written by an agent that reads the code, rewritten by one that never sees it and may cut freely, and checked against the code for false statements only. In chat, top-down: a short summary in terms that titled sections below explain, revised until the developer understands it; it writes no file. Typed
- **explain-diff** - explain the change between two git refs, so the developer can own it without reading the diff. It writes a local HTML page that takes about five minutes to read. The page says what the change is for and how a user works with it, and where the code differs from what the change claimed to do. It shows a graph of the changed modules with what each one does, and who may reach each new entry point. It lists what a revert would not undo, which behaviours the tests cover, what the next change will copy, and what would surprise a reader. Every statement links to its line in the code. A script collects the facts the page must not miss: a change's `CHANGE.md` and chunks, even after acceptance deleted them, changed dependencies and formats, deleted files, and removed or skipped tests. A second script fails the page if a link points at a line that does not exist. It explains the change and does not review it

### Other

- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **improve-skill** - make a skill do its job in as few words as the job allows, in language a developer new to the project understands on first reading. It edits the skill rather than reporting on it. It starts from the one sentence that says what the skill is for, and writes that sentence if the skill has none. First it fixes what would make a run miss that purpose, such as contradictions, unclear lines, steps with no clear end, hard language and a weak description, and lists each fix as the change in behaviour it makes. Then it cuts what does nothing: what the agent would do anyway, repetition, history, and the reasons and stories model-written skills explain themselves with. A cut must never drop an instruction. Where reading cannot settle that, it tests the cut against a control, or marks it as a guess the author can revert. Last, a subagent that did not write the rewrite compares it with the original, and every instruction it finds missing goes back in. It leaves the change uncommitted
- **upgrade-dependencies** - upgrade npm dependencies safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running the fast and the slow check at every step; reconciles the Node version across `.nvmrc`, Dockerfile and `@types/node`. `review-code` reviews every commit against the changelogs. The hard tests pass unchanged; an upgrade that would change one goes to the developer, and replacing a library is a hard decision it proposes and does not make. Each upgrade that needs real code changes goes to `backlog` as an item of its own, with the migration notes and what failed, to be built with `implement-code` or planned with `create-plan`. Typed
- **nextjs-project-setup** - set up a new TypeScript / Next.js project the developer's way, or bring one in line: Node at the latest LTS in `.nvmrc`; Next.js, Zod, TanStack Query and Mantine as the preferred libraries, with Mantine's PostCSS presets and Tabler icons where it is used; Biome for linting and formatting with the recommended presets, 2-space indents, organized imports and non-null assertions as errors; Vitest; and an `npm run check` that runs the type check, Biome and every test, declared as the fast check in `CLAUDE.md`. No other skill names it: a build that sets up such a project finds it by its description.
- **solve-problem** - work out a solution to an agreed problem with the user and build it in the same session, without journeys, a plan or `run.sh`. It walks one decision at a time with at least three genuinely different alternatives, the simplest first and called that, each with its effort and the complexity it adds, and a recommendation; it asks instead of guessing, and edits nothing until the user says the finished result it describes is what they have in mind and agrees to its "Done when" list: each criterion says something about the result and how to check it, written before the build, able to fail, and at least one checking that the problem itself is gone. Then `implement-code` builds it and has `review-code` review it; `solve-problem` checks every criterion it can check now, reports each as met, not met or still to check, and commits on the user's yes, deleting the backlog item it came from. Work that does not fit one session, or has a hard decision the user has not seen, goes to `create-plan` with a `spec.md` holding the agreed result and the "Done when" list. `idea` recommends it where no user journey changes
- **retro** - look back over a session or a `run.sh` run, from its logs, and change what let it go worse than it should have: the skills where the failure would recur in any project, the project where it comes from that project. It checks first whether the fixes since the last run held, since a recurrence means the mechanism was wrong; every finding points at a log line, commit or chunk and survives an attempt to refute it, and one that could happen but was not observed ranks below all that were; and each fix takes the strongest mechanism that fits - something that executes, then a check by something without a stake, then an instruction - never `CLAUDE.md`. It reports most costly first and makes only the fixes the user picks, one commit each, carrying the numbers the next retro compares against. Typed, and only in this repository: it is linked from `.claude/skills` and not synced

## Adding a new skill

Each skill is a subdirectory containing a `SKILL.md` file:

```
my-skill/
  SKILL.md       # Required: frontmatter + instructions
  *.md           # Optional: additional reference files
```

`SKILL.md` frontmatter:

```yaml
---
name: my-skill
description: One-line description used for discovery.
---
```

A reference file another skill also needs is copied in, as **Shared files** above says.
