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

```
  /idea ──→ INTENT_<TOPIC>.md ──→ /solve ──→ SOLUTION_<TOPIC>.md ──→ /slice ──┐
                                                                              │
                                                     tickets/<topic>/ ←───────┘
                                                              │
                          ./run.sh ──→ /implement ──→ /critique ──→ … ──→ every ticket done
                                                              │
                                    /accept ──→ VERDICT_<TOPIC>.md ──→ ./accept-run.sh

  /verify checks each artifact against what its stage was given, in a context
  that did not produce it: the intent, the solution, and the slicing before it
  is written.
```

`run.sh` and `accept-run.sh` are scripts rather than skills, and that is the whole
distinction: everything that has to hold when a session is dead or lying is a script,
and everything that is judgement is a skill. A session cannot enforce a budget it is
spending, reset a claim it is holding when it dies, or wait out a limit that has
already stopped it.

**Five stages, each emitting one artifact, each checked against what the stage was
given.** `/verify` is the one adversary, with a contract per stage, run in a context
that did not produce the thing it reads. Only the last stage judges against the
problem: every check before it compares an artifact to the one before it, and a chain
of sound links still proves nothing about what started it.

**Four stops for a person, whatever the size of the change.** Recognise the problem,
choose between candidates, approve the slicing, read the verdict and merge. Everything
else is conditional and named - a halt, a ceiling raised, an intent declared
unsatisfiable, a topic abandoned, a re-slice approved.

**Stopping anywhere is an ending.** An intent written and not designed against, a
solution recorded and not built, are whole uses of the thing. Going on is always
something you ask for.

**The paper is temporary.** The intent, the solution and the tickets are deleted when a
run is accepted, in one commit, and git history keeps them. The verdict survives,
because it is the only durable answer to what the work was for - which makes it the
pull request description too.

### The runner

`./run.sh tickets/<topic>` drives a ticket directory with nobody watching: it claims
each ticket, builds it, reviews what was built in a session that did not write it, and
either finishes it or sends it back. It refuses to start on the main branch, checks
before every pass that the tickets and their solution still agree, enforces the attempt
and review budgets from counters in the ticket files, and waits out a usage limit
rather than spending the budget on it.

Every unattended stop is a named halt written into the ticket: `blocked`, `undecided`
and `mystery` from a session; `exhausted`, `drift` and `unbuilt` from the runner,
because in each of those three the party that would report it is in no position to.

### What holds it together

**Ids, end to end.** Conditions are numbered in the intent, criteria tag the conditions
they serve, tickets quote the criteria they cover verbatim, tests name the criteria they
pin, and the verdict walks the conditions back. Absences become mechanical: a criterion
no condition asked for, a condition nothing will build, a ticket claiming what it does
not quote.

**Nothing approves its own work.** The builder does not review; the reviewer does not
decide what happens next; the runner writes the statuses a session must not; and the
stage that judges the result reads a problem statement written before the solution
existed.

**Checks that execute rather than judge.** A criterion is pinned by breaking the
behaviour and watching its named test fail - deleted, and its edges moved - because
deciding by eye whether a test would notice a change is prediction. `/accept` drives the
finished feature the way its user would rather than reading the diff and concluding.

### The tests

`tests/run.sh` is the one command. It holds what is true of the repository as a whole
and then runs a suite per artifact - the intent, solution and ticket formats, the
runner, acceptance, the consumer map, the handoffs between stages, and the check that
no live instruction points at something that is not there. Plain bash: each case builds
what it needs in a throwaway directory and cleans up after itself.

## Available skills

The pipeline is most of them. `cleanup-repo`, `repo-overview` and `upgrade-dependencies` stand outside it - they are things you run on a codebase rather than steps in building a change.
- **cleanup-repo** - clean up the current project in two passes: find code to delete (dead code, code unrequired by tests/spec, absence-asserting tests) and code to refactor (YAGNI and KISS violations), then produce a reviewable plan and stop for approval before changing anything
- **coding-standard** - the single source of truth for what this project's code should look like once written (simple design, structure and locality, clarity and least astonishment, concurrency and shared state, cost at scale, accessibility, changing what already runs, test coverage, security, dependencies); read whenever code is written, under a ticket or not, and by `/critique` when reviewing it, so the rules live in one place instead of drifting across skills
- **software-design** - how a change is shaped before it is typed: the domain's names carried through every layer, where the seams are, how few and how deep they should be, which decisions earn an ADR and when it gets written
- **critique** - the project's code review, against `coding-standard`: run it by hand on a branch, a PR or the whole codebase, or hand it a ticket and it judges that commit against the ticket's criteria, checks the tests the Record names actually fail without the behaviour, and writes what it wants changed into the ticket's Findings. It verifies every finding before reporting it, and closes with a verdict line a caller can count - which is what the runner reads
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **idea** - the one door in, fired without being typed: the problem underneath the idea the user arrived with, dug at until a reader who was not there could restate it, and written down as an intent - or a reasoned no. Proposes nothing
- **implement** - build one ticket end to end: its criteria driven out test-first, every criterion pinned by a test that is made to fail before it is trusted, the project's checks green, the evidence written into the ticket, one commit. It halts rather than working around a missing precondition, never reopens the solution, never reviews its own work and never marks its own ticket done
- **improve-skill** - improve an existing agent skill (more effective, more concise, clearer for an LLM to follow) without changing what it does: reads what real runs of it actually did, applies safe wording edits directly, micro-tests any edit meant to change behaviour against a no-guidance control, and surfaces the rest as decisions for the author
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
- **solve** - turn a ratified intent into a solution spec: candidates that differ in kind, what decides between them agreed before anything is scored, one chosen, its criteria numbered and tagged with the conditions they serve, and what it costs named against what it was chosen over. Given prose rather than an intent, it derives the conditions and gets them confirmed before it designs - or hands back to `/idea` when they cannot be stated so anyone could check them
- **slice** - cut a settled solution into the tickets that build it: vertical slices worked out in plan mode, each independently buildable, each quoting the criteria it covers verbatim so no builder has to open the solution. Typed, because it was measured never firing when the other skills are present
- **verify** - the one adversary, with a contract per stage: an intent's conditions observable, a solution's coverage both ways and the cost it failed to name, a slicing that traces both directions. Runs in a context that did not produce what it reads
- **accept** - use the finished feature, walk the intent's conditions by id, and write the verdict that survives the paper; then `./accept-run.sh`, which refuses to retire a run that is not finished
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
