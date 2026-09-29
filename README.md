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
/idea ──(context)──→ /find-criteria ──→ CRITERIA.md ──→ /criteria-to-tickets ─┬─ 1 ticket  → /implement <ticket>
  ↑                        │                                                    └─ n tickets → ./run.sh changes/<slug>/tickets
  └── no problem visible ──┘                                                              then: /accept-criteria
```

Everything one change produces lives in `changes/YYYY-MM-DD-<slug>/`: `CRITERIA.md`, the
agreed specimen in `specimens/`, the tickets in `tickets/`, and `REVIEW.md` where the runner's
final review ran. The directory is scaffolding for one change, and `/accept-criteria` deletes it
once the change is accepted - what it was for survives in git history and in the commits that
built it. ADRs outlive the change, so they always go to `docs/adr/`.

`idea` fires by description; `find-criteria`, `criteria-to-tickets` and `accept-criteria` are
typed. A trivial change still goes through `find-criteria`, which states the problem in a
sentence, gets a yes and moves on, and a single ticket is built by `/implement` directly - the
light path is the same pipeline with less in it, not a way around it.

`run.sh` is a script rather than a skill, and that is the whole distinction:
everything that has to hold when a session is dead or lying is a script, and
everything that is judgement is a skill. A session cannot enforce a budget it is
spending, reset a claim it is holding when it dies, or wait out a limit that has
already stopped it.

**Every stage is checked by something that did not produce it.** The first three carry
their adversary as a `VERIFY.md` beside their `SKILL.md` and hand it to a subagent with
a fresh context: the problem statement's, which re-derives the problem cold from the instance
and the solution the user arrived with; the criteria's, which checks they serve the problem,
can be tested, make sense for the person who will use the thing, and can be sliced without
asking; the tickets', which checks the quotes, the coverage, the slices and the code the plans
rest on. Then `critique`, which each build spawns against its own diff, and which drives the
running product where a user sees the change. Only the last stage judges against the problem:
every check before it compares an artifact to the one before it, and a chain of sound links
still proves nothing about what started it.

**What is approved, and what is only seen.** Product behaviour - the acceptance criteria - is
approved by the user. Implementation choices are nudges: shown, so the user can object, and
carried to the builder, but checked by nothing; a build that departs from one records why.

**Stops for a person.** Agree the problem, pick an approach and approve the criteria, approve the
tickets, walk the finished change. Everything else is conditional and named - a halt, a ceiling
raised, a problem declared already solved, a re-slice approved.

**Stopping anywhere is an ending.** A problem agreed and not designed against, criteria
agreed and not built, are whole uses of the thing. Going on is always something you ask for.

### The standard

`CODING_STANDARDS.md` is what good software looks like, and it is written to hold of any
project rather than only this one.

`implement`, `critique`, `find-criteria`, `criteria-to-tickets` and `restructure` each hold an
identical copy, because a skill installs alone and cannot reach a sibling's directory. **An edit
to one is an edit to all five, in the same commit.** `ADR_FORMAT.md` is held the same way by
`find-criteria` and `criteria-to-tickets`. `./test.sh` is what enforces it, over whatever turns
out to be shared rather than over any file by name.

### The runner

`./run.sh changes/<slug>/tickets` drives a ticket directory with nobody watching: it
claims each ticket, builds it, and either finishes it or sends it back. It refuses to
start on the main branch or on a dirty tree - the ticket files aside, which are its own
bookkeeping - and before the first build it has a session name the project's checks and
runs them itself - a run that starts red does not start, and every build is told the
checks were green. It checks before every pass that the tickets still quote `CRITERIA.md`'s
acceptance criteria and nudges word for word and that every criterion is quoted by some
ticket, enforces the attempt budget from a counter in the ticket file, and waits out a
usage limit rather than spending the budget on it. A session that ends its turn with its
work uncommitted is resumed once rather than started over, and what an abandoned attempt
leaves behind goes to the stash, so the next one starts on the tree the checks were
green on. Killed in the middle, it can simply be started again: the ticket it left
claimed is carried on in the same session, on the same attempt, with its uncommitted
work taken as that session's, and the checks wait until it is finished. It refuses to
start beside a live run, or beside a session a killed run left running. Each build is
pointed at the Records of the tickets already done, since those are where one build
leaves something for the next.

There is one session per ticket, and the build spawns its own reviewer in a subagent that
did not write the code. That session commits the ticket with its build at `status: done`, and
the runner checks the commit is there - sending the ticket back if it is not, and amending the
ticket into it if the session left it out - so no ticket's status is left uncommitted for the
next session to trip on. Its own halts it commits on the spot.

When more than one ticket was built and none halted, **one final session reviews the whole
change** - the diff from before its tickets were added - for what no single ticket's review
can see: the same thing built twice, one concept under two names, seams that do not line up.
It runs `critique`, fixes what is worth fixing and commits, two rounds at most, and writes what
it left standing to `REVIEW.md`. It goes through the same usage-limit handling as the builds,
and a review that ends without committing `REVIEW.md` fails the run. A re-slice deletes
`REVIEW.md`, so the rebuilt change is reviewed again.

**It records what each ticket cost**, in context tokens read - main session and subagents
apart - since a long session re-reads its growing context on every turn. The counts are kept
per change in `.git/run-logs` and survive a run started again.

However it ends, it prints what needs a person: the halts, each ticket's
`### Left standing`, `REVIEW.md`, and the token summary. It points on to `/accept-criteria`
only when everything is built and reviewed. It walks nothing itself: acceptance needs the
user in it.

Every unattended stop is a named halt written into the ticket: `blocked`, `undecided`
and `mystery` from a session; `exhausted`, `drift` and `unbuilt` from the runner,
because in each of those three the party that would report it is in no position to.

### The sync

`./sync.sh` links every directory here that holds a `SKILL.md` into
`~/.claude/skills`, so editing a skill in this repository is editing the one a session
reads. Then it removes the links that no longer resolve, because a skill that gets
renamed leaves one behind and a dangling link fails silently - the agent reads nothing
and carries on. It only ever removes symlinks: the real directories in there are skills
synced from elsewhere or written in place, and this is not their owner.

### The tests

`./test.sh`. Everything the runner does is something that has to be true when a session
is dead or lying, so every case builds a throwaway repository - a change's `CRITERIA.md`
with a ticket directory under it - puts a stub where `claude` goes, and runs the real
script against it: the refusals, the drift pre-flight in both directions, the claim a
crashed session leaves behind, both budgets, the halt each one writes, the final review,
the token log and the report a run ends with. Alongside them, the two checks the documents
need: that the copies of a shared file are identical, and that no live instruction points at
something that is not there.

### What holds it together

**Ids, end to end.** Acceptance criteria are numbered in `CRITERIA.md`, tickets quote the ones
they cover verbatim, tests name the ones they pin, and acceptance walks them back by id.
Absences become mechanical: a criterion no ticket quotes, a ticket claiming what it does not
quote, a quote that no longer matches.

**Nothing approves its own work.** The reviewer gets the diff and not the reasoning that
produced it, because a reviewer that has already accepted every step is not a reviewer;
the runner writes the statuses a session must not; and acceptance judges against a problem
statement written before the approach was chosen.

**Checks that execute rather than judge.** A criterion is pinned by breaking the
behaviour and watching its named test fail - deleted, and its edges moved - because
deciding by eye whether a test would notice a change is prediction. `critique` and
`/accept-criteria` drive the running product rather than reading the diff and concluding,
and a build's own visual checks run in a subagent that reports back in text, so no screenshot
is carried through every later turn.

## Available skills

The pipeline is most of them. `repo-overview`, `improve-skill`, `restructure` and
`upgrade-dependencies` stand outside it - they are things you run on a codebase, or on a
skill, rather than steps in building a change.

- **idea** - the one door in, fired without being typed: the problem underneath the idea the user arrived with, dug at around one real instance until a reader who was not there could restate it, stated back and agreed - or a reasoned no. Proposes nothing and writes no file: the statement stays in the conversation for `find-criteria`
- **find-criteria** - work out with the user what the change has to do, one question at a time: at least three genuinely different approaches with their effort and code complexity for the user to pick from, a specimen where the difference is visual, the acceptance criteria, the implementation nudges, and every open question settled. Approved, checked by an adversary, approved again, and written to `CRITERIA.md`. Runs `idea` first where no problem is visible. Typed
- **criteria-to-tickets** - cut `CRITERIA.md` into vertical slices, each small enough for one session, and write a planned ticket for each - one slice included - quoting its criteria and nudges verbatim so no builder has to open `CRITERIA.md`. Checked by an adversary before it is shown for approval, with the product questions planning turned up going to the user and back into `CRITERIA.md`. Typed
- **implement** - build software to the standard: a failing test first for every piece of behaviour, the project's checks green, visual checks in a subagent that reports in text, then a `critique` subagent with a fresh context reading the diff and not the reasoning behind it. It fixes what comes back, twice at most, and says what it left standing. Fires on any request to write or change code
- **critique** - the project's code review, against `CODING_STANDARDS.md`: a diff, a branch, a PR, or the whole codebase - and the running product, wherever a user sees the change. It constructs the trigger behind every finding and tries to refute it before reporting, and writes each one as the change rather than the symptom so the list can go straight to planning
- **accept-criteria** - walk the finished change with the user: drive the running product through `CRITERIA.md`'s criteria by id, compare it with the agreed design, hold it against the problem, follow the user wherever they try it, and read what the builds and the final review left standing. Reports each criterion as met, not met, or could not be checked. Once the user accepts, it deletes the change's directory and commits that. Typed
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **improve-skill** - the review for agent skills, and it edits rather than reports: it cuts the skill to what changes what the agent does. Every edit is a deletion or a shorter replacement, clauses out of the middle of sentences included, so the file comes out shorter every time and an improvement that would *add* - a missing trigger, a completion criterion, a form that does not fit its failure - is written into the report as wording to paste rather than into the file. It names the one sentence the skill is for, deriving and writing it where the author never did, and deletes what that sentence already covers, then what the model would do anyway, the duplication and the prose around the instructions. A cut it cannot settle by reading is settled by running the skill three ways against a control. Then a subagent that did not write the rewrite reads it against the original for what went missing, which is the step that makes the cutting safe: measured over four skills, the first draft over-cuts every time and the review is what puts the guards back
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
- **restructure** - make a whole codebase easier to change: it judges what changes together from the code, with the git history's co-changing files as a second view. It looks for proposals first - near-duplicate concepts to merge in the UI and the code, and features that cost more than they give - and leaves that code alone. Then it deletes dead or inert code, colocates, splits grab-bag modules, makes coupling that nothing links explicit, unifies, collapses empty layers, generalizes and simplifies, each only for a future change it can name. It applies only what it can prove preserves behavior and proposes the rest. Typed, so it does not compete with `critique` for "clean up the code"
- **ubiquitous-language-init** - bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project by excavating domain terminology from the existing codebase
- **upgrade-dependencies** - upgrade npm dependencies safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running tests/tsc/lint at every step; reconciles the Node version across `.nvmrc`, Dockerfile and `@types/node`; taking a new dependency on is a decision rather than maintenance, and is not this skill's to make

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
