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
  `CHANGE.md`. `./run.sh` builds it with nobody watching: `split-change-into-chunks` splits
  it where one agent cannot build it in one context, `implement-change` builds each part, and
  `review-change` and `walk-user-journeys` check each build. `accept-change` walks the finished
  change with the developer.
- **Debug:** `debug` finds a bug and ends one of three ways: as intended, a feature request
  for the backlog, or a fix.
- **Refactor:** `refactor-codebase` makes the code easier to change, from the friction notes
  the builds and `debug` left.
- **Backlog:** `backlog` holds the ideas not started yet, and picks the next one.

What lives where:

- `journeys/` holds one file per thing a user does. It outlives every change, and describes
  the software as it is.
- `changes/YYYY-MM-DD-<slug>/` holds what one change produces, on the change's own branch:
  `CHANGE.md`, the agreed prototype in `prototype/`, the chunks in `chunks/` where the change
  was split, and `REVIEW.md` where the runner's final review ran. It is deleted once the change
  is accepted.
- `changes/friction/` holds one note per place that was hard to change or hard to debug, until
  a refactor deals with it.
- `changes/backlog/` holds one file per idea not started yet.

A skill marked **Typed** below only runs when you type its name, such as `/accept-change`.
The others also start when the conversation matches their description.

### Shared files

A skill installs alone and cannot read a sibling's directory, so a file two skills need is
copied into each, byte for byte - `JOURNEY_FORMAT.md` and `CHANGE_FORMAT.md` among them. **An
edit to one copy is an edit to all of them, in the same commit.** `./test.sh` fails when the
copies differ. It checks whatever turns out to be shared, not a list of files.

`VERIFY.md` is the one exception: `idea`, `design-user-journeys` and `split-change-into-chunks`
each hold one, and the three are different documents on purpose. An adversary written
generally enough to serve all three stages says less at each of them. `test.sh` exempts it by
name, and a new exception has to be added there as well as here.

### The runner

`./run.sh changes/YYYY-MM-DD-<slug>` builds a change with nobody watching. It is a script
rather than a skill, because what it holds has to be true when a session is dead or lying. Its
library is under `run/`, a directory with no `SKILL.md`, so not a skill.

**Before it builds anything:**

- It runs on the change's own branch, which `design-user-journeys` made. It refuses to start
  on main or master, in a repository with no commits, on a dirty tree (its own chunk files
  aside), beside a live run, or beside a session a killed run left running.
- On a first start, a session runs `split-change-into-chunks`. Where one agent can build the
  change within one context, the runner builds `CHANGE.md` as the one chunk. Otherwise the
  session splits it into chunks in `chunks/`. A split that halts - on a question only the
  developer can answer, or a step only a person can do - ends the run before anything is built.
- It runs the project's fast check and slow check itself. A run that starts red does not
  start, and says which check is red. Every build is told the checks were green.

**The checks.** The commands are the `Fast check:` and `Slow check:` lines in the project's
`CLAUDE.md`. A `Check:` line with no `Fast check:` line is the fast check. A `CLAUDE.md` with
both `Check:` and `Fast check:` is refused, and on a build's commit it counts as a red check.
The lines are read again before every run of the checks, so a chunk that declares one is held
to it from its own commit on. Only where no line names a fast check does a session name it,
once per run. In a new project there is nothing to name yet: the run then starts with no
checks, and the build that sets them up declares them in `CLAUDE.md`.

The runner runs both checks again on every build's commit, rather than believing the
session's account of them, so a session runs only the fast check. A red check goes back to the
session that made it, told which check failed and where its output is. The first time, that
costs no attempt.

**Before every pass**, it checks that every journey `CHANGE.md` names is there and that
`after:` names chunks that exist. Where the change was split, it also checks that every chunk
carries `CHANGE.md`'s Problem word for word, names only journeys `CHANGE.md` names, and that
the chunks together name all of them. Where they disagree, the run halts as `drift`.

**The journeys were approved before the build.** A build or a final review whose commits
change one stops the run as a `departure` halt, and leaves its commits for the developer to
keep or revert.

**Each chunk** gets one session, which runs `implement-change`. That skill spawns its own
reviewer and walker in subagents that did not write the code.

- The session commits the chunk with its build at `status: done`. The runner checks the commit
  is there: it sends the chunk back if it is not, and amends the chunk file into it if the
  session left it out. A session commits its own halts on the spot.
- The attempt budget is a counter in the chunk file. A usage limit is waited out rather than
  spent from the budget.
- A session that ends its turn with its work uncommitted is resumed once rather than started
  over. What an abandoned attempt leaves behind goes to the stash, so the next one starts on the
  tree the checks were green on.
- Killed in the middle, the runner can simply be started again. The chunk it left claimed is
  carried on in the same session, on the same attempt, with its uncommitted work taken as that
  session's. The checks wait until it is finished.
- Each build is pointed at what the chunks already done left standing, since that is where one
  build leaves something for the next.

**The final review.** When more than one chunk was built and none halted, one more session
reviews the whole change, from before its chunks were added. It looks for what no single
chunk's review can see: the same thing built twice, one concept under two names, seams that do
not line up. It runs `review-change` and `walk-user-journeys`, fixes what is worth fixing, two
rounds at most, and commits. It is handed what the builds left standing, though its reviewer is
not, and settles the blockers and should-fix a build left unfixed: fixed, or left for the
person.

It writes what it left to `REVIEW.md`, which opens with `## For you`: what is still open, what
needs a decision first, then the rest, most important first. A review that ends without
committing `REVIEW.md` fails the run. Once it is committed, the runner runs both checks again.
A red one goes back to the review session, on a chunk's attempt budget. Still red, the run
halts and names the red check and its output. A run started again over a committed review
runs both checks and halts again while either is red, so a run never points on to acceptance
with a red check. A new split deletes `REVIEW.md`, so the rebuilt change is reviewed again.

**What it records.** Each chunk's cost in context tokens read, main session and subagents
apart, since a long session re-reads its growing context on every turn. And every call a
session's permissions refused, one line each with the session and the reason the CLI gave:
sessions run in auto mode, and a refused call does not stop one. Both are kept per change in
`.git/run-logs`, survive a run started again, and are not printed.

**How it ends.** With what needs a person, and only that, last on the screen. A halt stops the
run, which ends by naming the chunk that halted and printing its whole `## Halt`. A finished
run points on to `/accept-change`.

Every unattended stop is a named halt, written into the chunk: `blocked`, `undecided` and
`mystery` from a session; `exhausted`, `drift`, `unbuilt` and `departure` from the runner,
because in each of those four the party that would report it is in no position to.

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
`CHANGE.md` with its journeys and chunks - puts a stub where `claude` goes, and runs the real
script against it: the refusals, the split, the drift checks, the departure halt, the claim a
crashed session leaves behind, both budgets, the halt each one writes, the final review, the
token log and the report a run ends with. The scripts of `accept-change` and `explain-diff`
get suites of their own, over the same kind of throwaway repository. Beside them run the
checks the documents need: that the copies of a shared file are identical, that no live
instruction points at something that is not there, and that every script passes `shellcheck`.

## Available skills

What each skill does today. What it is meant to be is in `SDLC.md`.

### Add a feature

- **idea** - the door in for an idea: the problem underneath the idea the user arrived with, dug at around one real instance until a reader who was not there could restate it, stated back and agreed - or a reasoned no. Proposes nothing but deleting a backlog item it said no to, and writes no file: the statement stays in the conversation for `design-user-journeys`, with the backlog item's path where it came from one
- **design-user-journeys** - work out with the user how the software should change to solve an agreed problem: the journeys it affects - written down first from what the software does today where none describes it - walked step by step with at least three genuinely different alternatives, a prototype where seeing helps, what goes wrong at each step, and who goes through each journey, since that is what grants access. A fresh subagent checks the journeys and `CHANGE.md` before the final yes, and they are committed on the change's own branch. Typed
- **split-change-into-chunks** - judge whether one agent can build a change within one context, and where it cannot, split `CHANGE.md` into chunks of the same shape, each provable on its own, ordered by need, with the design copied word for word. It asks nothing: a question only the developer can answer, or a step only a person can do, halts the run. Run by `run.sh` on a first start. Typed
- **implement-change** - build a change from its `CHANGE.md` or a chunk, to its design and prototype, with a test for each journey that uses the software from the outside and stays. Access is denied unless a journey gives it, and the journeys themselves are never changed. Every change is reviewed by `review-change` and walked by `walk-user-journeys`, two rounds at most; what was hard goes to `changes/friction/`. Run by `run.sh` for each chunk
- **review-change** - the code review of one change, against its `CHANGE.md` or chunk, its journeys and the four goals in order: the code does what the journeys say and solves the problem; every way in denies unless a journey's "Who" gives access, and the review tries to get past it; the code uses the journeys' words, and the next agent would find what it needs. It checks for itself that the checks pass, that each journey step has a test from the outside that would catch it breaking, that no test left unreported, that callers still work and that code it wants deleted is dead. Every finding survives an attempt to construct its trigger. It changes nothing; walking the software is `walk-user-journeys`'
- **walk-user-journeys** - walk the journeys on the running software as the user in each one, without ever reading the code, the diff or the design: every step and every "When it goes wrong" case, judging the steps marked *(judged)*, then the edges no journey names and what "Who" does not allow. It follows no instruction the software shows, cleans up what it created, and reports one line per step - as written, hesitated, guessed or gave up - with screenshots
- **accept-change** - walk the finished change with the developer: each journey it names, step by step on the running software, showing for each step the test that checks it and what that test found. It holds the change against its problem, and sends it back to `idea` where the problem is not solved. It shows what the code did beyond what was agreed - access no journey gives first, then departures from the design, broken `CLAUDE.md` rules, weakened checks, blast radius and revert, new dependencies - each pointing at its evidence: a script names the files a decision usually lives in, and a fresh subagent looks for what the walk missed. Everything the builds and the final review left open gets an outcome: keep, fix now, back to design, skip with a reason, or follow-up. Once the developer accepts, it deletes the change's directory and the backlog item it came from, commits that, and hands over the steps left for deployment. Typed

### Debug, refactor and the backlog

- **debug** - find a bug from however it was reported, on the running software: reproduce it, agree with the developer what the software is meant to do there, and find the cause from evidence. It ends one of three ways: it works as intended and that is right, and it explains why; the intention is wrong, and it hands a feature request to `backlog`; or it is a bug, and it writes a test that reproduces it, fixes it on a branch and has `review-change` review the fix. What made the bug hard to find goes in a note in `changes/friction/`
- **refactor-codebase** - make the codebase easier to change, every few changes. It gathers the friction notes the builds and debug sessions left in `changes/friction/`, the git history's churn and co-change, and the coupling in the code, and agrees a ranked plan with the developer, each item naming the future change it makes easier. It builds the chosen items - deleting dead code, colocating, splitting, making hidden coupling explicit, unifying, collapsing layers, generalizing, simplifying, renaming to the journeys' words, correcting comments - one commit each, only where tests prove what the software does stays the same. The journeys' tests pass unchanged; what would change behaviour is listed apart, in the user's words. `review-change` reviews the result, and the friction notes it dealt with are deleted. Typed
- **backlog** - the ideas not started yet, one file per item in `changes/backlog/` with its effort and utility from XS to XL, proposed from the code and confirmed by the user. Adding reads the code for evidence and extends an item that overlaps rather than writing a second; picking ranks by utility against effort, checks the top three against the current code, proposes deleting what is already solved, recommends one and hands it to `idea`. `accept-change` hands it each follow-up and deletes the items a change finished, and `debug` hands it each feature request: behaviour that works as intended where the intention is wrong. Converts an older backlog's items to its shape on first use

### Understanding the code

- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading, in the user's words where `journeys/` names them - shown in the conversation and not saved
- **init-ubiquitous-language** - write or refresh `UBIQUITOUS_LANGUAGE.md` from the domain terms in the codebase, and report where an existing one has drifted from the code, or where an entry has grown past its one sentence into a specification
- **explain-code** - explain what a part of the code decides, once the developer can no longer follow it: traced back from where the answer shows and widened to everything shown there from the same code, written by an agent that reads the code, rewritten by one that never sees it and may cut freely, and checked against the code for false statements only. In chat, top-down: a short summary in terms that titled sections below explain, revised until the developer understands it; it writes no file. Typed
- **explain-diff** - explain the change between two git refs, so the developer can own it without reading the diff. It writes a local HTML page that takes about five minutes to read. The page says what the change is for and how a user works with it, and where the code differs from what the change claimed to do. It shows a graph of the changed modules with what each one does, and who may reach each new entry point. It lists what a revert would not undo, which behaviours the tests cover, what the next change will copy, and what would surprise a reader. Every statement links to its line in the code. A script collects the facts the page must not miss: a change's `CHANGE.md` and chunks, even after acceptance deleted them, changed dependencies and formats, deleted files, and removed or skipped tests. A second script fails the page if a link points at a line that does not exist. It explains the change and does not review it

### Other

- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **improve-skill** - make a skill do its job in as few words as the job allows, in language a developer new to the project understands on first reading. It edits the skill rather than reporting on it. It starts from the one sentence that says what the skill is for, and writes that sentence if the skill has none. First it fixes what would make a run miss that purpose, such as contradictions, unclear lines, steps with no clear end, hard language and a weak description, and lists each fix as the change in behaviour it makes. Then it cuts what does nothing: what the agent would do anyway, repetition, history, and the reasons and stories model-written skills explain themselves with. A cut must never drop an instruction. Where reading cannot settle that, it tests the cut against a control, or marks it as a guess the author can revert. Last, a subagent that did not write the rewrite compares it with the original, and every instruction it finds missing goes back in. It leaves the change uncommitted
- **upgrade-dependencies** - upgrade npm dependencies safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running the fast and the slow check at every step; reconciles the Node version across `.nvmrc`, Dockerfile and `@types/node`; taking a new dependency on is a decision rather than maintenance, and is not this skill's to make. Typed
- **nextjs-project-setup** - set up a new TypeScript / Next.js project the developer's way, or bring one in line: Node at the latest LTS in `.nvmrc`; Next.js, Zod, TanStack Query and Mantine as the preferred libraries, with Mantine's PostCSS presets and Tabler icons where it is used; Biome for linting and formatting with the recommended presets, 2-space indents, organized imports and non-null assertions as errors; Vitest; and an `npm run check` that runs the type check, Biome and every test, declared as the fast check in `CLAUDE.md`. No other skill names it: a build that sets up such a project finds it by its description.
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
