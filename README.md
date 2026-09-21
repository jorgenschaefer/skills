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
  /idea ──→ 01-INTENT.md ──→ /find-solution ──→ 02-SOLUTION.md ──→ /plan-solution ──┐
                                                                                    │
                                              one slice: a plan in plan mode ←──────┤
                                              many slices: tickets/NN-<slug>.md ←───┘
                                                              │
                          ./run.sh intents/<slug>/tickets ──→ /implement ──→ (critique, cold)
                                                              │
                                                      /accept-intent
```

Everything one change produces lives in `intents/YYYY-MM-DD-<slug>/` - the intent, the
solution beside it, the tickets under it. The paper for one change stays together, and
the numbers say what order it was written in.

`run.sh` is a script rather than a skill, and that is the whole distinction:
everything that has to hold when a session is dead or lying is a script, and
everything that is judgement is a skill. A session cannot enforce a budget it is
spending, reset a claim it is holding when it dies, or wait out a limit that has
already stopped it.

**Every stage is checked by something that did not produce it.** The first three carry
their adversary as a `VERIFY.md` beside their `SKILL.md` and hand it to a subagent with
a fresh context: the intent's, which has no prior artifact and re-derives the problem
cold; the solution's, which checks coverage both ways and hunts the cost the author
could not see; the slicing's, which reads text before there are files. The fourth is
`critique`, which the build spawns against its own diff for the same reason. Only the
last stage judges against the problem: every check before it compares an artifact to
the one before it, and a chain of sound links still proves nothing about what started
it.

**Four stops for a person, whatever the size of the change.** Recognise the problem,
choose between candidates, approve the slicing, read what the walk found and merge.
Everything else is conditional and named - a halt, a ceiling raised, an intent declared
unsatisfiable, a topic abandoned, a re-slice approved.

**Stopping anywhere is an ending.** An intent written and not designed against, a
solution recorded and not built, are whole uses of the thing. Going on is always
something you ask for.

### The standard

`CODING_STANDARDS.md` is what good software looks like here and how it gets written, in
four parts ordered by when a reader needs them: shaping the change, writing the code,
how it gets written, and what does not belong. It was four skills, read at different
moments by different readers, which meant four places for a rule to drift.

`implement`, `critique` and `plan-solution` each hold an identical copy, because a skill
installs alone and cannot reach a sibling's directory. **An edit to one is an edit to
all three, in the same commit.** `./test.sh` is what enforces it, over whatever turns
out to be shared rather than over that file by name.

### The runner

`./run.sh intents/<slug>/tickets` drives a ticket directory with nobody watching: it
claims each ticket, builds it, and either finishes it or sends it back. It refuses to
start on the main branch, checks before every pass that the tickets and their solution
still agree, enforces the attempt budget from a counter in the ticket file, and waits
out a usage limit rather than spending the budget on it. When every ticket is done it
walks the intent with `/accept-intent` and prints what that found - without merging,
marking, or ruling on it.

There is one session per ticket. There used to be two, the second reviewing what the
first built; the build now spawns that reviewer itself, in a subagent that did not write
the code.

Every unattended stop is a named halt written into the ticket: `blocked`, `undecided`
and `mystery` from a session; `exhausted`, `drift` and `unbuilt` from the runner,
because in each of those three the party that would report it is in no position to.

### The tests

`./test.sh`. Everything the runner does is something that has to be true when a session
is dead or lying, so every case builds a throwaway repository - an intent, the solution
beside it, a ticket directory - puts a stub where `claude` goes, and runs the real
script against it: the refusals, the drift pre-flight in both directions, the claim a
crashed session leaves behind, both budgets, and the halt each one writes. Alongside
them, the two checks the documents need: that the copies of a shared file are identical,
and that no live instruction points at something that is not there.

### What holds it together

**Ids, end to end.** Conditions are numbered in the intent, criteria tag the conditions
they serve, tickets quote the criteria they cover verbatim, tests name the criteria they
pin, and the walk goes back through the conditions. Absences become mechanical: a
criterion no condition asked for, a condition nothing will build, a ticket claiming what
it does not quote.

**Nothing approves its own work.** The reviewer gets the diff and not the reasoning that
produced it, because a reviewer that has already accepted every step is not a reviewer;
the runner writes the statuses a session must not; and the stage that judges the result
reads a problem statement written before the solution existed.

**Checks that execute rather than judge.** A criterion is pinned by breaking the
behaviour and watching its named test fail - deleted, and its edges moved - because
deciding by eye whether a test would notice a change is prediction. `/accept-intent`
drives the finished feature the way its user would rather than reading the diff and
concluding.

## Available skills

The pipeline is most of them. `repo-overview`, `skill-review` and `upgrade-dependencies`
stand outside it - they are things you run on a codebase rather than steps in building a
change.

- **idea** - the one door in, fired without being typed: the problem underneath the idea the user arrived with, dug at until a reader who was not there could restate it, and written down as an intent - or a reasoned no. Proposes nothing
- **find-solution** - turn an intent into a solution spec: candidates that differ in kind, what decides between them agreed before anything is scored, one chosen, its criteria numbered and tagged with the conditions they serve, and what it costs named against what it was chosen over. Given prose rather than an intent, it derives the conditions and gets them confirmed before it designs - or hands back to `/idea` when they cannot be stated so anyone could check them
- **plan-solution** - cut a settled solution into vertical slices and plan each one. A single slice is planned in plan mode and written nowhere; more than one, and each gets its plan written into a ticket that quotes the criteria it covers verbatim, so no builder has to open the solution. Typed, because it was measured never firing when the other skills are present
- **implement** - build software to the standard: a failing test first for every piece of behaviour, the project's checks green, then a `critique` subagent with a fresh context reading the diff and not the reasoning behind it. It fixes what comes back, twice at most, and says what it left standing. Fires on any request to write or change code
- **critique** - the project's code review, against `CODING_STANDARDS.md`: a diff, a branch, a PR, or the whole codebase. It constructs the trigger behind every finding and tries to refute it before reporting, writes each one as the change rather than the symptom so the list can go straight to plan mode, and keeps the tradeoffs that would remove working functionality in a section of their own, where nothing applies one by accident
- **accept-intent** - use the finished feature the way its user would, walk the intent's conditions by id, read the tickets' Records alongside them, and report which conditions you could find in the product and which you could not
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **skill-review** - the review for agent skills: read one skill whole, judge it against the lenses that decide whether it fires at the right moment and binds the agent once it does - triggering, altitude, the information hierarchy, completion criteria, leading words, pruning, the form a piece of guidance takes - and report what would make it work better. It changes nothing, constructs the failing run behind every finding, and labels each one as wording or as behaviour, which is the author's call
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
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

A skill installs on its own and cannot read a sibling's directory. So a reference file
two skills both need is **copied into each of them**, byte for byte, rather than shared -
`CODING_STANDARDS.md` lives in three places for exactly this reason. The copies have to
be edited together, in one commit, and `./test.sh` fails when they are not.

`VERIFY.md` is the deliberate exception: three skills hold one, and the three are
different documents on purpose. An adversary written generically enough to serve all
three stages says less at each of them. `test.sh` exempts it by name, and a new
exception has to be added there as well as here.
