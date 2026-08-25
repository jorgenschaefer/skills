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

## The feature pipeline

Most of these skills compose into one flow: one door in, one implementer, and three ways out.

```
  /discovery ──┬──→ SPEC.md ──→ /spec-to-tickets ──→ tickets/ ──→ ./loop.sh
               ├──→ one ticket ─────────────────────────────────→ /implement
               ├──→ a maintenance ticket ───────────────────────→ /implement
               └──→ a reasoned no

  ./loop.sh ──→ /implement-ticket ×N ──→ /check-against-spec ──→ /critique ──→ /handover
                every ready ticket,      gaps → tickets,          blockers →    and, on a
                in dependency order      built, checked again      tickets      clean run,
                                                                                ./accept.sh
```

`loop.sh` and `accept.sh` are scripts in this repository rather than skills - the skills are what they call.

**One door.** Everything starts at `/discovery` - a feature, a bug, a passing idea - and it ends in one of three places. A spec, where the change is big enough that `/spec-to-tickets` decomposes it into tickets an unattended loop builds. A single ticket, where a spec would be ceremony and `/implement` builds it with you still there. Or a reasoned no. The split test tells the first from the second: *could you ship this on its own, and would that be worth shipping as an improvement in itself?* The no comes out of the interview instead - the problem is already solved, the cost is out of proportion, or what was asked for is a symptom of something else. And work nobody outside the code could observe is none of the three: it becomes a maintenance ticket, built and reviewed like everything else rather than done by hand.

**One unit.** The ticket, in one of three kinds: a feature ticket claiming criteria from a spec, a remediation ticket a review filed against work already built, and a maintenance ticket that changes no behaviour at all. All three are built by `/implement`, and everything requiring code is one of them - including what the end-of-run checks find, so a late fix is built and re-verified rather than patched in behind the checks.

**Three endings.** Every run finishes clean, halted, or standing on something a human has to rule on, and says which. Each prints the same two things: the driver's own account, collected from the tickets rather than judged - what every build decided and left standing, ordered by the stakes it marked at the time - and `/handover`'s pull request description. A clean run names the one command that accepts it. `./accept.sh` deletes the spec, the tickets and the mockups in a single commit - git history keeps them - and refuses unless every ticket is done and the tree is clean. That one is yours to run: accepting is the judgement the whole pipeline defers to a human, and deliberately not something an unattended session can reach.

### The driver

`loop.sh <tickets-dir>` runs unattended for hours, so the screen stays quiet: each step's narration, one line per phase, plus position, duration and cost. The exception is the closing handover, printed whole, because that description is what the run was for. Every step's full JSON transcript is kept under a directory it names at startup - outside the repository, accumulating across runs, and the only evidence `/improve-skill` has about how any of this behaves in practice.

It needs `claude`, `jq`, `git`, somewhere to keep those transcripts (`XDG_STATE_HOME` or `HOME`), and a feature branch - it refuses to run on `main`. Nobody is there to approve a tool call, so it also needs a `permissions.allow` in settings covering the edits, commands and commits a ticket makes, and starting the app the acceptance drives: `claude -p` cannot prompt, and what it cannot get approved, it declines.

It answers what it can and hands back what it cannot. A session that dies is not an ending: running out of usage is waited out, since the stream names the second the window reopens (`MAX_WAIT_HOURS` caps that), and any other death is retried after a pause - seven of them over about three hours (`RETRY_DELAYS`) - until either it works or nothing else will fix it, like a bad key. A halt on drift or a stale spec hash re-derives the unbuilt tickets against the code as it now is, once per run, because the code moving under a ticket is a re-derivation rather than a decision.

What reaches a human: a halt that needed a judgement, a queue with no path through it, a workflow test changed without authorisation, a spec check still filing work after two passes, or blockers and disagreements the review left standing.

Inside a run, the spec check gets two passes to converge (`MAX_PASSES`). Between runs there is a second ceiling, because re-running is how a human resolves a halt and each re-run starts that budget over: runs that end without finishing are counted against the paper rather than the branch, and once two have, the next asks for `ANOTHER_RUN=1` - so that passing a limit is something somebody decided rather than something that happened.

The reviews run on a different model from the one that built the code (`BUILD_MODEL` and `REVIEW_MODEL`, which it refuses to start with set to the same thing), since two sessions of one model share its blind spots. Nobody is there to approve a tool call either, so it needs standing permission for the edits, commands and commits a ticket makes, and for starting the app the acceptance drives. `claude -p` cannot prompt: what it cannot get approved, it declines.

Both scripts have tests in `tests/run.sh` - plain bash, each case building a throwaway repository with a stub standing in for `claude`. The rate-limit fixtures are real records from runs that hit the real limit.

### What holds it together

**Nothing guesses.** A run has nobody to ask, which is the one fact `/implement-ticket` supplies to a craft skill that would otherwise ask: so it halts, records why in the ticket, and stops. An ambiguity guessed past is invisible - it arrives as working code with a passing test, and every ticket after it is built on top.

**Three tiers.** What a spec says is permanent (a term, an ADR, a ratified journey), binding for this feature (journeys, criteria, constraints, non-goals), or a default - decided without the evidence the builder will have, and overturnable on evidence found in the code, never on taste. Permanent items are ratified one at a time as they are proposed, not in a brief at the end that nobody reads to the bottom of.

**Checks that execute rather than judge.** Every ticket runs a mutation gate over its own diff where the project has the tooling - and where it does not, says so and files a ticket to add it, because deciding by eye whether a test would notice a deletion is prediction. `/check-against-spec` drives the finished feature the way its user would rather than reading the code and concluding, and sweeps for what no ticket could see: a criterion nobody claimed, a constraint nothing verified, a non-goal built anyway. Ratified journeys live as tests under `tests/workflows/` that run in the project's own check command, so feature twelve's run keeps feature three's journeys green - and a build that changes one without written authorisation stops the run.

**Findings have a bar.** A constructed trigger, a destination it traces to, and no reopening of an argument a ticket already recorded and answered. Anything else is a new requirement rather than a defect, and goes to `IDEAS.md` - the parking lot beside the specs, which `/discovery` reads at the start of the next feature.

**The paper is temporary.** Spec, tickets, and the mockups the journeys were walked as are deleted when the work is accepted; git history keeps them. A mockup that outlives the run is a second source of truth nobody updates. Anything that must outlive the run is promoted first - into the glossary, a comment at the code it explains, or an ADR. What a step hands to a human is presented inline and never written down: it is read once, at the moment somebody decides, and a copy on disk only outlives the decision.

## Available skills

The pipeline is most of them. `cleanup-repo`, `repo-overview` and `upgrade-dependencies` stand outside it - they are things you run on a codebase rather than steps in building a feature.

- **check-against-spec** - the acceptance: drive the finished feature against the spec it was built from, sweep for what no ticket could have seen, file a ticket for each gap, and close with a verdict line a caller can count
- **cleanup-repo** - clean up the current project in two passes: find code to delete (dead code, code unrequired by tests/spec, absence-asserting tests) and code to refactor (YAGNI and KISS violations), then produce a reviewable plan and stop for approval before changing anything
- **coding-conventions** - the single source of truth for this project's code-quality standards (simple design, structure and locality, domain layering, clarity and least astonishment, concurrency and shared state, cost at scale, accessibility, changing what already runs, test coverage, security, dependencies); read by `/implement` when writing code and `/critique` when reviewing it, so the rules live in one place instead of drifting across skills
- **critique** - review code for quality against the shared `coding-conventions` standard, over a branch diff or a whole project; runs the project's checks, traces the change's callers, verifies every finding before reporting it, and closes with a verdict line a caller can count
- **discovery** - interview the user about a feature, a bug or an idea and end at a spec, a single ticket, or a reasoned no; four phases, each one's exit condition the next one's ground - the problem agreed in the user's words before a solution is discussed, candidates weighed against the project as it already is, the experience picked from options and then walked as a mockup, and the record hardened into something buildable without the conversation
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **handover** - close out a run by writing the pull request description for it: what the branch does now, how it works, what a reviewer should look at first, and what is still uncertain; proposes what to promote into a comment, the glossary or an ADR before `./accept.sh` deletes the paper
- **implement** - build exactly one ticket: reconcile it against the real codebase, TDD red/green/refactor, the project's own check command (a combined one where it exists, otherwise typecheck and lint), then a quality review and a code review before committing. Never builds past an ambiguity - with a human present it asks, and `/implement-ticket` supplies the answer for a run with nobody to ask
- **implement-ticket** - build one ticket from a run's `tickets/` directory with nobody watching: wraps `/implement` with the rules that hold when there is no one to ask - halt rather than guess, narrate each phase, run nothing in the background - and owns the ticket format
- **improve-skill** - improve an existing agent skill (more effective, more concise, clearer for an LLM to follow) without changing what it does: reads what real runs of it actually did, applies safe wording edits directly, micro-tests any edit meant to change behaviour against a no-guidance control, and surfaces the rest as decisions for the author
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
- **spec-to-tickets** - decompose a settled `/discovery` spec into the tickets an unattended loop can build: audit the scope cold, split into tickets named for observable behavior, declare what each may rely on from the ones before it, settle only what splitting forces, then review the set for anything a builder would have to guess
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
