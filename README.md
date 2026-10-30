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

What developing with these skills is meant to be - its goals and its user journeys - is in
`SDLC.md`. This README says how to install the skills and what the scripts do.

What outlives a change is in `journeys/`, one file per thing a user does. Everything else one
change produces lives in `changes/YYYY-MM-DD-<slug>/`, on the change's branch, and is deleted
once the change is accepted: `CHANGE.md`, the agreed prototype in `prototype/`, the chunks in
`chunks/` where the change was split, and `REVIEW.md` where the runner's final review ran.

`idea` fires by description; `design-user-journeys` and `split-change-into-chunks` are typed,
and the runner types the second itself.

`run.sh` is a script rather than a skill. Its library is under `run/` - a directory with no
`SKILL.md`, so not a skill, and `sync.sh` leaves it out.

### Shared files

A skill installs alone and cannot reach a sibling's directory, so a file two skills need is
copied into each - `JOURNEY_FORMAT.md` and `CHANGE_FORMAT.md` among them. **An edit to one
copy is an edit to all of them, in the same commit.** `./test.sh` is what enforces it, over
whatever turns out to be shared rather than over any file by name.

### The runner

`./run.sh changes/<slug>` builds a change with nobody watching. It runs on the change's own
branch, which `design-user-journeys` made, and refuses to start on main. On a first start a
session runs `split-change-into-chunks`: where one agent cannot build the change within one
context, it splits `CHANGE.md` into chunks in `chunks/`; where it can, the runner builds
`CHANGE.md` as the one chunk. A split that halts - a question only the developer can answer, a
step only a person can do - ends the run before anything is built. Then the runner claims each
chunk, builds it, and either finishes it or sends it back. It refuses to start on a dirty tree -
the chunk files aside, which are its own bookkeeping - and before the first build it runs
the project's fast check and slow check itself - a run that starts red does not start,
says which check is red, and every build is told the checks were green. The commands are
the `Fast check:` and `Slow check:` lines in the project's `CLAUDE.md` - a `Check:` line
with no `Fast check:` line is the fast check - read again before every run of the checks,
so a chunk that declares one is held to it from its own commit on; only where no line
names a fast check does a session name it, once per run. A `CLAUDE.md` with both `Check:`
and `Fast check:` is refused, and on a build's commit it counts as a red check. It runs
both checks again on every build's commit, rather than believing the session's account of
them, so a session runs only the fast check: a red one goes back to the session that made
it, told which check failed and where its output is, the first time without spending an
attempt. It checks before every pass that every journey `CHANGE.md` names is there, that
`after:` names chunks that exist, and, where the change was split, that every chunk carries
`CHANGE.md`'s Problem word for word, names only journeys `CHANGE.md` names, and that together
the chunks name all of them. The journeys were approved before the build, so a build or a final
review whose commits change one stops the run, as a `departure` halt in the chunk or in the
run's last lines, with its commits left for the developer to keep or revert. It enforces the attempt
budget from a counter in the chunk file, and waits out a usage limit rather than
spending the budget on it. A session that ends its turn with its work uncommitted is
resumed once rather than started over, and what an abandoned attempt leaves behind goes
to the stash, so the next one starts on the tree the checks were green on. Killed in the
middle, it can simply be started again: the chunk it left claimed is carried on in the
same session, on the same attempt, with its uncommitted work taken as that session's, and
the checks wait until it is finished. It refuses to start beside a live run, or beside a
session a killed run left running. Each build is pointed at what the chunks already done
left standing, since that is where one build leaves something for the next.

There is one session per chunk, and the build spawns its own reviewer in a subagent that
did not write the code. That session commits the chunk with its build at `status: done`, and
the runner checks the commit is there - sending the chunk back if it is not, and amending the
chunk into it if the session left it out - so no chunk's status is left uncommitted for the
next session to trip on. Its own halts it commits on the spot.

When more than one chunk was built and none halted, **one final session reviews the whole
change** - the diff from before its chunks were added - for what no single chunk's review
can see: the same thing built twice, one concept under two names, seams that do not line up.
It runs `review-change`, fixes what is worth fixing and commits, two rounds at most, and writes what
it left standing to `REVIEW.md`. It is handed what the builds left standing, though the reviewer is
not, and settles the blockers and should-fix a build left unfixed: fixed, or left for the
person. `REVIEW.md` opens with `## For you`: what is still open once the review is done, what
needs a decision first, then most important first. It goes through the same usage-limit handling as the builds,
and a review that ends without committing `REVIEW.md` fails the run. Once it is committed,
the runner runs both checks once more, and a red one goes back to the review session on a
chunk's attempt budget. Still red, the run halts and names the red check and its output, for
the developer to settle; a run started again over a committed review runs both checks and halts
again while either is red, so a run never points on to acceptance with a red check. A new split
deletes `REVIEW.md`, so the rebuilt change is reviewed again.

**It records what each chunk cost**, in context tokens read - main session and subagents
apart - since a long session re-reads its growing context on every turn. The counts are kept
per change in `.git/run-logs` and survive a run started again. They are kept, not printed.
Beside them it keeps every call a session's permissions refused, one line each with the
session it came from and the reason the CLI gave - sessions run in auto mode, and a refused
call does not stop one.

However it ends, it ends with what needs a person, and only that, last on the screen. A halt
stops the run, which ends saying which chunk halted and printing its whole `## Halt`. A
finished run points on to `/accept-change`.

Every unattended stop is a named halt written into the chunk: `blocked`, `undecided`
and `mystery` from a session; `exhausted`, `drift`, `unbuilt` and `departure` from the
runner, because in each of those four the party that would report it is in no position to.

### The sync

`./sync.sh` links every directory here that holds a `SKILL.md` into
`~/.claude/skills`, so editing a skill in this repository is editing the one a session
reads. Then it removes the links that no longer resolve, because a skill that gets
renamed leaves one behind and a dangling link fails silently - the agent reads nothing
and carries on. It only ever removes symlinks: the real directories in there are skills
synced from elsewhere or written in place, and this is not their owner. A skill linked from this
repository's own `.claude/skills` - `retro` - is for working on the skills here, so
it is left out, and a session in this repository finds it there.

### The tests

`./test.sh`. Every case of the runner's suites builds a throwaway repository - a change's `CHANGE.md`
with its journeys and chunks - puts a stub where `claude` goes, and runs the real
script against it: the refusals, the split, the drift pre-flight, the departure halt, the claim a
crashed session leaves behind, both budgets, the halt each one writes, the final review,
the token log and the report a run ends with. `accept-criteria/signals.sh` gets a suite of
its own, over the same kind of throwaway repository. Alongside them, the two checks the documents
need: that the copies of a shared file are identical, and that no live instruction points at
something that is not there.

## Available skills

What each skill does today. What it is meant to be is in `SDLC.md`.

- **backlog** - the ideas not started yet, one file per item in `changes/backlog/` with its effort and utility from XS to XL, proposed from the code and confirmed by the user. Adding reads the code for evidence and extends an item that overlaps rather than writing a second; picking ranks by utility against effort, checks the top three against the current code, proposes deleting what is already solved, recommends one and hands it to `idea`. `accept-criteria` hands it each follow-up and deletes the items a change finished. Converts an older backlog's items to its shape on first use
- **idea** - the door in for an idea, fired without being typed: the problem underneath the idea the user arrived with, dug at around one real instance until a reader who was not there could restate it, stated back and agreed - or a reasoned no. Proposes nothing but deleting a backlog item it said no to, and writes no file: the statement stays in the conversation for `find-criteria`
- **design-user-journeys** - work out with the user how the software should change to solve an agreed problem: the journeys it affects - written down first from what the software does today where none describes it - walked step by step with at least three genuinely different alternatives, a prototype where seeing helps, what goes wrong at each step, and who goes through each journey, since that is what grants access. A fresh subagent checks the journeys and `CHANGE.md` before the final yes, and they are committed on the change's own branch. Typed
- **split-change-into-chunks** - judge whether one agent can build a change within one context, and where it cannot, split `CHANGE.md` into chunks of the same shape, each provable on its own, ordered by need, with the design copied word for word. It asks nothing: a question only the developer can answer, or a step only a person can do, halts the run. Run by `run.sh` on a first start
- **implement-change** - build a change from its `CHANGE.md` or a chunk, to its design and prototype, with a test for each journey that uses the software from the outside and stays. Access is denied unless a journey gives it, and the journeys themselves are never changed. Every change is reviewed by `review-change` and walked by `walk-user-journeys`, two rounds at most; what was hard goes to `changes/friction/`. Run by `run.sh` for each chunk
- **critique** - the code review, against `CODING_STANDARDS.md`: a diff, a branch, a PR, or the whole codebase - and the running product, where an agent that never saw the code completes the criteria as its user's tasks and says where a person would hesitate, guess or give up. It constructs the trigger behind every finding and tries to refute it before reporting, and writes each one as the change rather than the symptom so the list can go straight to planning
- **accept-criteria** - walk the finished change with the user: drive the running product through `CRITERIA.md`'s criteria by id, compare it with the agreed design, hold it against the problem, follow the user wherever they try it, and read what the builds and the final review left standing. It shows what the code changed from what was agreed - the AC groups, the technical decisions, the ADRs and `CLAUDE.md`'s rules - and each check weakened, by what it no longer protects, plus what a failure would affect, what a revert would not undo and the dependencies taken on, each pointing at its evidence in the diff: a script names the files a decision usually lives in, and a fresh subagent looks for what the walk missed. Reports the items the manifesto puts in the report - each criterion as met, not met, or could not be checked, the decisions the plan didn't cover, blast radius and revert with the steps left for deployment, tradeoffs, new dependencies - plus what was hard to change, then gives everything left open an outcome - keep, fix now, re-slice, skip with a reason, or follow-up, which is what it proposes for what was hard to change, with what skipping it would cost - agreed as a list and discussed one at a time where the user wants to. Once the user accepts, it deletes the change's directory and commits that. Typed
- **explain-code** - explain what a part of the code decides, once the developer can no longer follow it: traced back from where the answer shows and widened to everything shown there from the same code, written by an agent that reads the code, rewritten by one that never sees it and may cut freely, and checked against the code for false statements only. In chat, top-down: a short summary in terms that titled sections below explain, revised until the developer understands it; it writes no file. Typed
- **explain-diff** - explain the change between two git refs, so the developer can sign off on it without reading the diff. It writes a local HTML page that takes about five minutes to read. The page says what the change is for and how a user works with it, and where the code differs from what the change claimed to do. It shows a graph of the changed modules with what each one does, and who may reach each new entry point. It lists what a revert would not undo, which behaviours the tests cover, what the next change will copy, and what would surprise a reader. Every statement links to its line in the code. A script collects the facts the page must not miss: the criteria of a pipeline change, even after acceptance deleted them, changed dependencies and formats, deleted files, and removed or skipped tests. A second script fails the page if a link points at a line that does not exist. It explains the change and does not review it
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **improve-skill** - make a skill do its job in as few words as the job allows, in language a developer new to the project understands on first reading. It edits the skill rather than reporting on it. It starts from the one sentence that says what the skill is for, and writes that sentence if the skill has none. First it fixes what would make a run miss that purpose, such as contradictions, unclear lines, steps with no clear end, hard language and a weak description, and lists each fix as the change in behaviour it makes. Then it cuts what does nothing: what the agent would do anyway, repetition, history, and the reasons and stories model-written skills explain themselves with. A cut must never drop an instruction. Where reading cannot settle that, it tests the cut against a control, or marks it as a guess the author can revert. Last, a subagent that did not write the rewrite compares it with the original, and every instruction it finds missing goes back in. It leaves the change uncommitted
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
- **restructure** - make a whole codebase easier to change, run every one to two weeks over all of it, since every other check judges one change and drift is the sum of them. It first makes the structure something the checks hold: a fast check declared on `CLAUDE.md`'s `Fast check:` line - an older `Check:` line rewritten to it - run by the pre-commit hook, with CI running it and the slow check, and every structural rule `CLAUDE.md` states turned into a check with today's breaks in a list that only shrinks. It judges what changes together from the code, with the git history's co-changing files as a second view. It looks for proposals first - near-duplicate concepts to merge in the UI and the code, and features that cost more than they give - and leaves that code alone. Then it deletes dead or inert code, colocates, splits grab-bag modules, makes coupling that nothing links explicit, unifies, collapses empty layers, generalizes, simplifies, renames what a search would miss and corrects false or historical comments, each only for a future change it can name. It decides itself which habits of the code become checks. It applies only what it can prove preserves behavior; of the rest, it proposes only feature cuts, merged concepts and renames in stored data or on the wire, in the user's words, and names every other restructuring it could not prove in one line of its report. Last, it holds `CLAUDE.md` against the moved code and has `repo-overview` and `ubiquitous-language` refresh theirs, and it counts what it found and fixed against the previous run. Typed, so it does not compete with `critique` for "clean up the code"
- **retro** - look back over a session or a `run.sh` run, from its logs, and change what let it go worse than it should have: the pipeline where the failure would recur in any project, the project where it comes from that project. It checks first whether the fixes since the last run held, since a recurrence means the mechanism was wrong; every finding points at a log line, commit or ticket and survives an attempt to refute it, and one that could happen but was not observed ranks below all that were; and each fix takes the strongest mechanism that fits - something that executes, then a check by something without a stake, then an instruction - never `CLAUDE.md`. It reports most costly first and makes only the fixes the user picks, one commit each, carrying the numbers the next retro compares against. Typed, and only in this repository: it is linked from `.claude/skills` and not synced
- **ubiquitous-language** - write or refresh UBIQUITOUS_LANGUAGE.md from the domain terms in the codebase, and report where an existing one has drifted from the code, or where an entry has grown past its one sentence into a specification
- **upgrade-dependencies** - upgrade npm dependencies safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running the fast and the slow check at every step; reconciles the Node version across `.nvmrc`, Dockerfile and `@types/node`; taking a new dependency on is a decision rather than maintenance, and is not this skill's to make

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

A skill installs on its own and cannot read a sibling's directory. So a reference file
two skills both need is **copied into each of them**, byte for byte, rather than shared -
`CODING_STANDARDS.md` lives in five places for exactly this reason. The copies have to
be edited together, in one commit, and `./test.sh` fails when they are not.

`VERIFY.md` is the deliberate exception: three skills hold one, and the three are
different documents on purpose. An adversary written generically enough to serve all
three stages says less at each of them. `test.sh` exempts it by name, and a new
exception has to be added there as well as here.
