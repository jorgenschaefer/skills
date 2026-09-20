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

## The pipeline

Most of these skills compose into one flow: one door in, one implementer, and four ways out of it. Everything goes through that door - a feature, a bug, a refactor, a skill, a document - and what differs is how far along it goes, not which lane it started in.

```
  /idea ──┬──→ intent.md ──→ /to-solution ──┬──→ solution spec ──┬──→ built with you present
          │                                 │                    └──→ /spec-to-tickets ──→ tickets/ ──→ ./loop.sh
          │                                 ├──→ a recommendation, recorded nowhere
          │                                 └──→ a block: the one unknown, and how to get it
          └──→ a reasoned no

  ./loop.sh ──→ /implement-ticket ×N ──→ /check-against-spec ──→ /critique ──→ /handover
                every ready ticket,      gaps → tickets,          blockers →    and, on a
                in dependency order      built, checked again      tickets      clean run,
                                                                                ./accept.sh
```

`loop.sh` and `accept.sh` are scripts in this repository rather than skills - the skills are what they call.

**One door.** Everything starts at `/idea` - a feature, a bug, a refactor, a passing idea - and `/idea` fires without being typed, so no work has to be classified before it can begin. It finds the problem underneath what was asked for, proposes nothing, and ends at an intent or at a reasoned no: the problem is already solved, the cost is out of proportion, or what was asked for is a symptom of something else.

**Stopping there is an ending.** Noting an idea and being done with it is a whole use of the lane, not an abandoned run - which is why `/idea` and `/to-solution` are two skills rather than one.

**`/to-solution` designs against the intent**, reading it cold in a fresh session that did not have the conversation. It stays generic by taking its standards from the domain rather than from itself: `coding-standard` where the work is code, `writing-great-skills` where it is a skill, whatever governs where it is neither. Where the corpus is a codebase, reading it means the code, the glossary and the ADRs, with `ARCHITECTURE.md` as a lead rather than as truth.

**The ceremony arrives with the step that needs it.** The solution spec is written for a reader and carries no journeys, no numbered criteria and no hash - a spec for a document, a process or a skill stops there and is complete. `/spec-to-tickets` adds them to that same file, and it only runs when an unattended build is about to start. Everything an anchor is for is a mechanism for having nobody in the room, so nothing pays for one until it does.

**One unit.** The ticket, in one of three kinds: a feature ticket claiming criteria from a spec, a remediation ticket a review filed against work already built, and a maintenance ticket that changes no behaviour at all. All three are built by `/implement`, and everything requiring code is one of them - including what the end-of-run checks find, so a late fix is built and re-verified rather than patched in behind the checks.

**Three endings.** Every run finishes clean, halted, or standing on something a human has to rule on, and says which. One that did not finish clean also says what it stopped on, because the state names the ending and not the cause. Each prints the same two things: the driver's own account, collected from the tickets rather than judged - what every build decided and left standing, ordered by the stakes it marked at the time - and `/handover`'s pull request description. A clean run names the one command that accepts it. `./accept.sh` deletes the spec, the tickets and the mockups in a single commit - git history keeps them - and refuses unless every ticket is done and the tree is clean. That one is yours to run: accepting is the judgement the whole pipeline defers to a human, and deliberately not something an unattended session can reach.

### The driver

`loop.sh <tickets-dir>` runs unattended for hours, so the screen stays quiet: each step's narration, one line per phase, plus position, duration and cost. The exception is the closing handover, printed whole, because that description is what the run was for. Every step's full JSON transcript is kept under a directory it names at startup - outside the repository, accumulating across runs, and the only evidence `/improve-skill` has about how any of this behaves in practice.

It needs `claude`, `jq`, `git`, somewhere to keep those transcripts (`XDG_STATE_HOME` or `HOME`), and a feature branch - it refuses to run on `main`. Nobody is there to approve a tool call, so it also needs a `permissions.allow` in settings covering the edits, commands and commits a ticket makes, and starting the app the acceptance drives: `claude -p` cannot prompt, and what it cannot get approved, it declines.

It answers what it can and hands back what it cannot. A session that dies is not an ending: running out of usage is waited out, since the stream names the second the window reopens (`MAX_WAIT_HOURS` caps that), and any other death is retried after a pause - seven of them over about three hours (`RETRY_DELAYS`) - until either it works or nothing else will fix it, like a bad key. A halt on drift or a stale spec hash re-derives the unbuilt tickets against the code as it now is, once per run, because the code moving under a ticket is a re-derivation rather than a decision.

What reaches a human: a halt that needed a judgement, a queue with no path through it, a workflow test changed without authorisation, a spec check still filing work after two passes, or blockers and disagreements the review left standing.

Inside a run, the spec check gets two passes to converge (`MAX_PASSES`). Between runs there is a second ceiling, because re-running is how a human resolves a halt and each re-run starts that budget over: runs that end without finishing are counted against the paper rather than the branch, and once two have, the next asks for `ANOTHER_RUN=1` - so that passing a limit is something somebody decided rather than something that happened.

The reviews run on a different model from the one that built the code (`BUILD_MODEL` and `REVIEW_MODEL`, which it refuses to start with set to the same thing), since two sessions of one model share its blind spots. Nobody is there to approve a tool call either, so it needs standing permission for the edits, commands and commits a ticket makes, and for starting the app the acceptance drives. `claude -p` cannot prompt: what it cannot get approved, it declines.

The tests are `tests/run.sh` - plain bash, each case building a throwaway repository with a stub standing in for `claude`. It is the one command: it covers both scripts and then runs the format suites - `tests/intent-format.sh` and `tests/solution-format.sh` - which check each format document and every intent and solution in the tree against it. The rate-limit fixtures are real records from runs that hit the real limit.

### What holds it together

**Nothing guesses.** A run has nobody to ask, which is the one fact `/implement-ticket` supplies to a craft skill that would otherwise ask: so it halts, records why in the ticket, and stops. An ambiguity guessed past is invisible - it arrives as working code with a passing test, and every ticket after it is built on top.

**Three tiers.** What a spec says is permanent (a term or an ADR), binding for this feature (journeys, criteria, constraints, what scope rules out for good), or a default - decided without the evidence the builder will have, and overturnable on evidence found in the code, never on taste. Permanent items are agreed one at a time as they are proposed, not in a brief at the end that nobody reads to the bottom of.

**Checks that execute rather than judge.** Every ticket breaks each behaviour it claims - deleted, and its edges moved - and watches the test that names it fail, because deciding by eye whether a test would notice a change is prediction. `/check-against-spec` drives the finished feature the way its user would rather than reading the code and concluding, and sweeps for what no ticket could see: a criterion nobody claimed, a constraint nothing verified, a non-goal built anyway. Where a project pins a journey as a test under `tests/workflows/`, it runs in the project's own check command, so feature twelve's run keeps feature three's journeys green - and a build that changes one without written authorisation stops the run.

**Findings have a bar.** A constructed trigger, a destination it traces to, and no reopening of an argument a ticket already recorded and answered. Anything else is a new requirement rather than a defect, and goes to `IDEAS.md` - the parking lot beside the specs, which `/idea` reads at the start of the next piece of work.

**The paper is temporary.** Spec, tickets, and the mockups the journeys were walked as are deleted when the work is accepted; git history keeps them. A mockup that outlives the run is a second source of truth nobody updates. Anything that must outlive the run is promoted first - into the glossary, a comment at the code it explains, or an ADR. What a step hands to a human is presented inline and never written down: it is read once, at the moment somebody decides, and a copy on disk only outlives the decision.

## Available skills

The pipeline is most of them. `cleanup-repo`, `repo-overview` and `upgrade-dependencies` stand outside it - they are things you run on a codebase rather than steps in building a change.

- **check-against-spec** - the acceptance: drive the finished feature against the spec it was built from, sweep for what no ticket could have seen, file a ticket for each gap, and close with a verdict line a caller can count
- **cleanup-repo** - clean up the current project in two passes: find code to delete (dead code, code unrequired by tests/spec, absence-asserting tests) and code to refactor (YAGNI and KISS violations), then produce a reviewable plan and stop for approval before changing anything
- **coding-standard** - the single source of truth for what this project's code should look like once written (simple design, structure and locality, clarity and least astonishment, concurrency and shared state, cost at scale, accessibility, changing what already runs, test coverage, security, dependencies); read by `/implement` when writing code and `/critique` when reviewing it, so the rules live in one place instead of drifting across skills
- **software-design** - how a change is shaped before it is typed: the domain's names carried through every layer, where the seams are, how few and how deep they should be, which decisions earn an ADR and when it gets written
- **critique** - review code for quality against the shared `coding-standard`, over a branch diff or a whole project; runs the project's checks, traces the change's callers, verifies every finding before reporting it, and closes with a verdict line a caller can count
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **handover** - close out a run by writing the pull request description for it: what the branch does now, how it works, what a reviewer should look at first, and what is still uncertain; proposes what to promote into a comment, the glossary or an ADR before `./accept.sh` deletes the paper
- **idea** - the one door in, fired without being typed: the problem underneath the idea the user arrived with, dug at until a reader who was not there could restate it, and written down as an intent - or a reasoned no. Proposes nothing
- **implement** - build one ticket end to end: its criteria driven out test-first, every criterion pinned by a test that is made to fail before it is trusted, the project's checks green, the evidence written into the ticket, one commit. It halts rather than working around a missing precondition, never reopens the solution, never reviews its own work and never marks its own ticket done
- **implement-ticket** - build one ticket from a run's `tickets/` directory with nobody watching: wraps `/implement` with the rules that hold when there is no one to ask - halt rather than guess, narrate each phase, run nothing in the background - and owns the ticket format
- **improve-skill** - improve an existing agent skill (more effective, more concise, clearer for an LLM to follow) without changing what it does: reads what real runs of it actually did, applies safe wording edits directly, micro-tests any edit meant to change behaviour against a no-guidance control, and surfaces the rest as decisions for the author
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
- **spec-to-tickets** - harden a settled solution spec into the anchors a run with nobody in it needs, then decompose it into the tickets that loop builds: number what tickets will cite, derive the journeys the acceptance walks, audit the scope cold, split into tickets named for observable behavior, declare what each may rely on from the ones before it, settle only what splitting forces, then review the set for anything a builder would have to guess
- **solve** - turn a ratified intent into a solution spec: candidates that differ in kind, what decides between them agreed before anything is scored, one chosen, its criteria numbered and tagged with the conditions they serve, and what it costs named against what it was chosen over. Given prose rather than an intent, it derives the conditions and gets them confirmed before it designs - or hands back to `/idea` when they cannot be stated so anyone could check them. Replaces `to-solution`
- **to-solution** - superseded by `solve`; kept until the old pipeline is retired. Read an intent cold, in a session that did not have the conversation, and design against it: a field of candidates that differ in kind, shown as cheap specimens rather than described, weighed against criteria ranked and agreed before anything is scored. Three endings - a solution spec broken into parts a builder works through, a recommendation recorded nowhere, or a block naming the single unknown
- **ubiquitous-language-init** - bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project by excavating domain terminology from the existing codebase
- **upgrade-dependencies** - upgrade npm dependencies, or add one, safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running tests/tsc/lint at every step; reconciles the Node version across `.nvmrc`, Dockerfile and `@types/node`, and treats a new dependency as the hard-to-reverse choice it is

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
