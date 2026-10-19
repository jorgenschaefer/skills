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
backlog ──→ /idea ──(context)──→ /find-criteria ──→ CRITERIA.md ──→ /criteria-to-tickets ─┬─ 1 ticket  → /implement <ticket>
   ↑          ↑                        │                                                    └─ n tickets → ./run.sh changes/<slug>/tickets
   │          └── no problem visible ──┘                                                              then: /accept-criteria
   └────────────────────────────────────────────────── follow-ups ──────────────────────────────────────────────────┘
```

Everything one change produces lives in `changes/YYYY-MM-DD-<slug>/`: `CRITERIA.md`, the
agreed specimen in `specimens/`, the tickets in `tickets/`, and `REVIEW.md` where the runner's
final review ran. The directory is scaffolding for one change, and `/accept-criteria` deletes it
once the change is accepted - what it was for survives in git history and in the commits that
built it. ADRs outlive the change, so they always go to `docs/adr/`.

`idea` fires by description; `find-criteria`, `criteria-to-tickets` and `accept-criteria` are
typed. A trivial change can still go through `find-criteria`, which states the problem in a
sentence, gets a yes and moves on, and a single ticket is built by `/implement` directly.
A change small enough for one session can skip the tickets too: `/implement` builds
`CRITERIA.md` itself and commits it with the change, and deleting the change's directory is
the acceptance - the user walks it, not `/accept-criteria`.

`run.sh` is a script rather than a skill, and that is the whole distinction:
everything that has to hold when a session is dead or lying is a script, and
everything that is judgement is a skill. A session cannot enforce a budget it is
spending, reset a claim it is holding when it dies, or wait out a limit that has
already stopped it. Its library is under `run/` - a directory with no `SKILL.md`,
so not a skill, and `sync.sh` leaves it out.

**Every stage is checked by something that did not produce it.** The first three carry
their adversary as a `VERIFY.md` beside their `SKILL.md` and hand it to a subagent with
a fresh context: the problem statement's, which re-derives the problem cold from the instance
and the solution the user arrived with; the criteria's, which checks they serve the problem,
can be tested, make sense for the person who will use the thing, and can be sliced without
asking; the tickets', which checks the quotes, the coverage, the slices, the code the tickets
rest on, that no two tickets build the same thing, and the ACs that pull against each other. Then `critique`, which each build spawns against its own diff, and which drives the
running product where a user sees the change. Only the last two judge against the problem - the run's final review, whose critique
drives the product through the user's situation, and acceptance: every check before them
compares an artifact to the one before it, and a chain of sound links
still proves nothing about what started it.

**What is approved, and what is only seen.** Product behaviour - the acceptance criteria - is
approved by the user, and so are the four technical decisions whose mistakes land outside the
repository: stored formats, wire formats, trust boundaries and dependencies, each settled
up front, "none" included. A build may go beyond one where the code calls for it, and records
that it did; acceptance shows it for approval. Other implementation choices are nudges: shown,
so the user can object, and carried to the builder as ideas it checks against the code, not
orders; a build that departs from one records why.

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
`find-criteria`, `criteria-to-tickets` and `accept-criteria`. `./test.sh` is what enforces it, over whatever turns
out to be shared rather than over any file by name.

### The runner

`./run.sh changes/<slug>/tickets` drives a ticket directory with nobody watching: it
claims each ticket, builds it, and either finishes it or sends it back. Started on the
main branch, it makes a branch named after the change's directory and runs there, and
refuses where that branch already exists. It refuses to start on a dirty tree - the
ticket files aside, which are its own bookkeeping - and before the first build it runs
the project's checks itself - a run that starts red does not start, and every build is told the checks were green. The
command is the `Check:` line in the project's `CLAUDE.md`, read again before every run of
the checks, so a ticket that declares one is held to it from its own commit on; only
where there is none does a session name it, once per run. It runs them again on every
build's commit, rather than believing the session's account of them: a red one goes back
to the session that made it, the first time without spending an attempt. It checks before every pass that the tickets still quote `CRITERIA.md`'s
acceptance criteria, technical decisions and nudges word for word, that every ticket quotes every technical decision, that each ticket's `closes:` and `advances:`
name exactly the criteria it quotes, and that every criterion is closed by exactly one ticket,
built after every ticket that advances it - a criterion can take several slices, but one of
them finishes it and writes its test. It enforces the attempt budget from a counter in the ticket file, and waits out a
usage limit rather than spending the budget on it. A session that ends its turn with its
work uncommitted is resumed once rather than started over, and what an abandoned attempt
leaves behind goes to the stash, so the next one starts on the tree the checks were
green on. Killed in the middle, it can simply be started again: the ticket it left
claimed is carried on in the same session, on the same attempt, with its uncommitted
work taken as that session's, and the checks wait until it is finished. It refuses to
start beside a live run, or beside a session a killed run left running. Each build is
pointed at what the tickets already done left standing, since that is where one build
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
it left standing to `REVIEW.md`. It is handed what the builds left standing, though critique is
not, and settles the blockers and should-fix a build left unfixed: fixed, or left for the
person. `REVIEW.md` opens with `## For you`: at most five things still open once the review is
done, most important first. It goes through the same usage-limit handling as the builds,
and a review that ends without committing `REVIEW.md` fails the run. A re-slice deletes
`REVIEW.md`, so the rebuilt change is reviewed again.

**It records what each ticket cost**, in context tokens read - main session and subagents
apart - since a long session re-reads its growing context on every turn. The counts are kept
per change in `.git/run-logs` and survive a run started again. They are kept, not printed.
Beside them it keeps every call a session's permissions refused, one line each with the
session it came from and the reason the CLI gave - sessions run in auto mode, and a refused
call does not stop one.

However it ends, it ends with what needs a person, and only that, last on the screen. A halt
stops the run, which ends saying which ticket halted and printing its whole `## Halt`. A
finished run prints the review's `## For you` - or, with one ticket and no review, that
ticket's `## Left standing` - and points on to `/accept-criteria`. What each build left
standing stays in its ticket, and the rest of `REVIEW.md` is read at acceptance. It walks nothing itself: acceptance needs the
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
synced from elsewhere or written in place, and this is not their owner. A skill linked from this
repository's own `.claude/skills` - `retro` - is for working on the skills here, so
it is left out, and a session in this repository finds it there.

### The tests

`./test.sh`. Everything the runner does is something that has to be true when a session
is dead or lying, so every case builds a throwaway repository - a change's `CRITERIA.md`
with a ticket directory under it - puts a stub where `claude` goes, and runs the real
script against it: the refusals, the drift pre-flight in both directions, the claim a
crashed session leaves behind, both budgets, the halt each one writes, the final review,
the token log and the report a run ends with. `accept-criteria/signals.sh` gets a suite of
its own, over the same kind of throwaway repository. Alongside them, the two checks the documents
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
`/accept-criteria` drive the running product rather than reading the diff and concluding.
A build does not check its own screens: its reviewer has them driven, by a subagent of its own
that reports back in text, so neither the driving nor its screenshots are carried through the
reviewer's every later turn.

## Available skills

The pipeline is most of them. `explain-diff`, `repo-overview`, `improve-skill`, `restructure`,
`retro` and `upgrade-dependencies` stand outside it - they are things you run on a codebase,
on a change, on a skill or on a finished run, rather than steps in building a change.

- **backlog** - the ideas not started yet, one file per item in `changes/backlog/` with its effort and utility from XS to XL, proposed from the code and confirmed by the user. Adding reads the code for evidence and extends an item that overlaps rather than writing a second; picking ranks by utility against effort, checks the top three against the current code, proposes deleting what is already solved, recommends one and hands it to `idea` or `find-criteria`. `accept-criteria` hands it each follow-up and deletes the items a change finished. Converts an older backlog's items to its shape on first use
- **idea** - the one door in, fired without being typed: the problem underneath the idea the user arrived with, dug at around one real instance until a reader who was not there could restate it, stated back and agreed - or a reasoned no. Proposes nothing and writes no file: the statement stays in the conversation for `find-criteria`
- **find-criteria** - work out with the user what the change has to do, one question at a time: at least three genuinely different approaches for the user to pick from, a specimen where the difference is visual, the acceptance criteria, the four technical decisions, the implementation nudges, and every open question settled. Every choice between alternatives, the approach and any later one such as a specimen's variants, shows each option's effort as a size from XS to XL and what it adds to the code in words, next to what it gives. Approved, checked by an adversary, approved again, and written to `CRITERIA.md`. Runs `idea` first where no problem is visible. Typed
- **criteria-to-tickets** - cut `CRITERIA.md` into slices, each provable on its own and small enough for one session, and write a ticket for each - one slice included - quoting its criteria, technical decisions and nudges verbatim so no builder has to open `CRITERIA.md`, and saying what to build and what it shares with other tickets, never how. Checked by an adversary before it is shown for approval, and again for any ticket added or changed after that check, with the product questions slicing turned up going to the user and back into `CRITERIA.md`. Typed
- **implement** - build software to the standard: a failing test first for every piece of behaviour, the project's checks green, then a `critique` subagent with a fresh context reading the diff and not the reasoning behind it, and driving the running app where a user sees the change. It fixes what comes back, twice at most, and says what it left standing. Fires on any request to write or change code
- **critique** - the code review, against `CODING_STANDARDS.md`: a diff, a branch, a PR, or the whole codebase - and the running product, wherever a user sees the change. It constructs the trigger behind every finding and tries to refute it before reporting, and writes each one as the change rather than the symptom so the list can go straight to planning
- **accept-criteria** - walk the finished change with the user: drive the running product through `CRITERIA.md`'s criteria by id, compare it with the agreed design, hold it against the problem, follow the user wherever they try it, and read what the builds and the final review left standing. It shows what the code changed from what was agreed - the technical decisions, the nudges, the ADRs, `CLAUDE.md`'s rules and the declared structure - plus the precedents it sets, each pointing at its evidence in the diff: a script names the files a decision usually lives in, and a fresh subagent looks for what the walk missed. Reports each criterion as met, not met, or could not be checked, then gives everything left open an outcome - keep, fix now, re-slice, skip with a reason, or follow-up - agreed as a list and discussed one at a time where the user wants to. Once the user accepts, it deletes the change's directory and commits that. Typed
- **explain-diff** - explain the change between two git refs, so the developer can sign off on it without reading the diff. It writes a local HTML page that takes about five minutes to read. The page says what the change is for and how a user works with it, and where the code differs from what the change claimed to do. It shows a graph of the changed modules with what each one does, and who may reach each new entry point. It lists what a revert would not undo, which behaviours the tests cover, what the next change will copy, and what would surprise a reader. Every statement links to its line in the code. A script collects the facts the page must not miss: the criteria of a pipeline change, even after acceptance deleted them, changed dependencies and formats, deleted files, and removed or skipped tests. A second script fails the page if a link points at a line that does not exist. It explains the change and does not review it
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **improve-skill** - make a skill do its job in as few words as the job allows, in language a developer new to the project understands on first reading. It edits the skill rather than reporting on it. It starts from the one sentence that says what the skill is for, and writes that sentence if the skill has none. First it fixes what would make a run miss that purpose, such as contradictions, unclear lines, steps with no clear end, hard language and a weak description, and lists each fix as the change in behaviour it makes. Then it cuts what does nothing: what the agent would do anyway, repetition, history, and the reasons and stories model-written skills explain themselves with. A cut must never drop an instruction. Where reading cannot settle that, it tests the cut against a control, or marks it as a guess the author can revert. Last, a subagent that did not write the rewrite compares it with the original, and every instruction it finds missing goes back in. It leaves the change uncommitted
- **repo-overview** - orient a new developer to an unfamiliar codebase - tech stack, code organization, work objects and the actions each part supports, main workflows, where to start reading - and leave it in `ARCHITECTURE.md`, re-derived whole every run rather than maintained by hand
- **restructure** - make a whole codebase easier to change, run every one to two weeks over all of it, since every other check judges one change and drift is the sum of them. It first makes the structure something the checks hold: a single check command declared on `CLAUDE.md`'s `Check:` line, and every structural rule `CLAUDE.md` states turned into a check with today's breaks in a list that only shrinks. It judges what changes together from the code, with the git history's co-changing files as a second view. It looks for proposals first - near-duplicate concepts to merge in the UI and the code, and features that cost more than they give - and leaves that code alone. Then it deletes dead or inert code, colocates, splits grab-bag modules, makes coupling that nothing links explicit, unifies, collapses empty layers, generalizes, simplifies, renames what a search would miss and corrects false or historical comments, each only for a future change it can name. It applies only what it can prove preserves behavior and proposes the rest. Last, it holds `CLAUDE.md` against the moved code and has `repo-overview` and `ubiquitous-language` refresh theirs, and it counts what it found and fixed against the previous run. Typed, so it does not compete with `critique` for "clean up the code"
- **retro** - look back over a session or a `run.sh` run, from its logs, and change what let it go worse than it should have: the pipeline where the failure would recur in any project, the project where it comes from that project. It checks first whether the fixes since the last run held, since a recurrence means the mechanism was wrong; every finding points at a log line, commit or ticket and survives an attempt to refute it, and one that could happen but was not observed ranks below all that were; and each fix takes the strongest mechanism that fits - something that executes, then a check by something without a stake, then an instruction - never `CLAUDE.md`. It reports most costly first and makes only the fixes the user picks, one commit each, carrying the numbers the next retro compares against. Typed, and only in this repository: it is linked from `.claude/skills` and not synced
- **ubiquitous-language** - write or refresh UBIQUITOUS_LANGUAGE.md from the domain terms in the codebase, and report where an existing one has drifted from the code, or where an entry has grown past its one sentence into a specification
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
