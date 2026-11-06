# Roadmap

What we change in the skills next, and why. It follows from the first test
run (`docs/evidence/2026-11-05-workout-logbook.md`) and the summaries in
`docs/reference/`. Delete this file when all seven steps are done.

Three kinds of numbers appear below. "Step 1" is a step of this roadmap.
"Workflow step 5" is a step in `docs/workflow.md`. "Observation 8" is an
observation in the evidence file.

## Where we are

- `explore` and `decide` exist and were used once, on a new app.
- The build is plain Claude Code. There is no build skill.
- Workflow steps 5 and 6, check and report, have no skill yet.
- The split between `explore` and `decide` is agreed and written in
  `docs/workflow.md`, but not yet in the two skills.

## How to work on this

- **Every change to a skill comes from evidence.** Name the observation it
  answers. A skill starts small and grows only when a test run shows that it
  missed something. Don't add rules because they feel right.
- **A skill only sees its own directory.** A file two skills need is copied
  into each.
- **Run `./test.sh`** after every change. It checks that references to other
  skills and files are not broken.
- **Write plain English**, in the skills too: each sentence understood on
  first reading.
- **Fix a weak passage by rewriting it simpler**, not by adding a
  qualifier.
- **Steps 1 and 2 can be done in one sitting.** Commit them as logical
  commits, not one per edit.

## Words used here

- **Tell and ask.** `decide` puts every decision that is hard to undo to the
  developer. Where there is a real choice, it asks, with options and a
  recommendation. Where there is only one sensible option, it tells: one
  line, so the developer can object. "A tell" is such a line.
- **Change file.** `changes/YYYY-MM-DD-<slug>.md`, the agreement for one
  change. It is deleted when the change is done.

## Step 1: apply the split between explore and decide

Agreed in the discussion after the first run. Mostly writing.

**`explore/SKILL.md`: `explore` designs nothing.** It understands: what are we
solving, how does the real world work, and roughly which way do we go.

- Delete the paragraph "Where it looks and behaves differently ... A rough
  sketch in text is often enough." That sentence is why nobody designed the
  interaction (observation 1).
- `explore` picks the general direction, and `decide` the details. The
  direction comes from how the real world works, not from technology. "The
  gym has bad internet, and the app has to deal with that" is an insight for
  `explore`. Which parts work offline, and how, is for `decide`, which may
  find that only some parts need to (observation 14).
- "Read the code the request touches" assumes there is code. Say what to do
  when there is none (observation 3).

**`decide/SKILL.md`: `decide` designs whatever is costly to change.** The line
runs between costly and cheap to change, not between look, interaction and
data. The table in `docs/workflow.md` shows it.

New to `decide`:

- how the user moves through the task, and what they enter when
  (observation 1);
- for a new app, the design system: components, type, colours, spacing,
  asked with alternatives as clickable mock-ups, not ASCII (observation 1);
- for a completely new page in an existing app, a mock-up shown before it is
  built, even when there is nothing to ask (observation 1). So a tell can
  be a line of text or a picture;
- how access ends, and where data stays afterwards, such as on the phone
  (observation 8);
- the life of the data: how things are deleted, which fields change over
  time and what past records mean then, how many users there will be
  (observation 13).

Already in `decide`, but missed in the run, so make it clearer instead of
adding it again:

- the stack, under "Things much else is built on" (observation 5);
- a pattern that gets copied, such as every new record type touching nine
  places (observations 12, 13);
- what happens to the user's input when saving fails, which is "Trust that
  was lost" (observations 5, 8).

Other changes to `decide`:

- Rewrite the sentence "A choice of colour, wording, layout, internal names
  or code structure is not hard to undo" without layout, which was wrong
  (observation 1). The colour of one button, wording and internal names stay
  cheap. Code structure is cheap until it becomes a pattern that gets copied.
- **Write the tells down, not only what is asked.** They go into the change
  file. Before there is code, the code cannot be their record
  (observation 2).
- **Mock-ups are saved in `changes/`**, next to the change file, not left in
  the chat or the scratchpad (observation 2).
- **New projects.** When there is no code, `decide` works from the change
  file, and the stack is one of its decisions (observations 3, 5). The
  description says "Use before building any change to an existing project";
  drop "existing".
- **Commit what was agreed before the build.** Replace "Don't commit them on
  their own": `decide` commits its ADRs, its part of the change file and the
  mock-ups in one commit, so a builder in a fresh context finds them in the
  repository (observation 4). With a branch per change (step 6), an ADR for
  a change that is never built is simply not merged.
- **Ask before the build, not after.** In the run, the developer heard about
  the builder's decisions only in the report (observation 7). `decide`
  covering more (above) is the first answer; step 5 is the second.

**`explore/CHANGE_FORMAT.md`.** Say who writes each section:

- `explore` writes Problem, Approach and Could wait.
- `decide` writes Design, which is now what is costly to change, with links
  to the mock-ups in `changes/`.
- `decide` also writes Decisions that matter: every decision it told or
  asked, each with what holds it later: the code, a test (step 2) or an
  ADR.

Keep the format short. `docs/workflow.md` repeats it, so copy any change
there.

**`docs/workflow.md`**:

- Workflow step 2 no longer agrees on the interaction.
- Workflow step 3 designs what is costly to change.
- Cover new projects, not only existing ones (observation 3), starting with
  the title "Changing an existing project".

Outside support: the arXiv paper says a chat is not a record. OpenAI, the
only source that talks about design systems, says people own the design
system and UX patterns.

## Step 2: promises become tests or structure

In the first run, "old saves keep working after a deploy" was only a comment,
and last-writer-wins was only in the change file, which gets deleted
(observation 8).

- Whatever must still hold after the change needs a record that outlives
  the change file. The code holds what it shows, such as a `due_date`
  column. A test holds a promise about behaviour. An ADR holds what the code
  cannot show, such as the hosting.
- So when `decide` settles a promise, such as old saves still parsing or
  last-writer-wins, it names the test that will hold it. The change file
  lists it under Decisions that matter, and the builder writes it
  (observations 8, 11).
- When a rule is a convention every piece of code has to remember, such as
  every route checking the login, `decide` asks for structure instead: check
  the login once for all routes (observation 12).

No general rule about TDD or coverage. TDD tests what the developer has in
mind, and the bugs that mattered were exactly what nobody had in mind
(observation 10). Google and OpenAI recommend tests first; our evidence does
not support that as a rule.

## Step 3: `review`, then `check`

The serious bugs in the first run were found only by a review the developer
ran by hand (observations 6, 8). This step has the most evidence behind it.

### The four goals, split by who can see them

| Goal | `review` reads the code | User stand-in uses the running app |
|---|---|---|
| Utility | Find bugs. | Does it solve the problem in the change file? |
| Security | Find where someone can see or do more than they should. | |
| Usability | | Use it as a real user would. |
| Maintainability | Find code that makes future changes hard or bugs more likely. | |

Utility has two sides. A bug means the code does not do what it was meant to,
and a review finds that. Whether the change solves the user's problem can
only be found by using it. A change can be free of bugs and still do the
wrong job. The stand-in checks the change against the problem and the real
example in the change file. The developer has the final word in workflow
step 6.

The security cell for the stand-in is empty on purpose. A stand-in could try
to open someone else's data, but no run has shown the need yet.

### `review` (new skill, build first)

An adversarial code review in a fresh context. Its own skill, because it is
useful outside the workflow: on any diff, or on a whole repository.

`upgrade-dependencies` already asks for a fresh-context review of each
commit. Change it to use `review`.

**The baseline** is the prompt the developer used in session `3ee51f13`. It
found the serious bugs, and it covers three of the four goals in three
points:

> Find bugs. Find issues where someone can see or do more than they should.
> Furthermore, find code that will make future changes hard or make it more
> likely to add bugs in the future.

**Expansions with evidence from the first run:**

- For bugs, look first at four kinds of risk (observation 11):
  - each outside dependency fails: what does the code answer, and does the
    client retry?
  - each contract between two parts, tested from both sides together, and
    old data still parses;
  - security code under parallel and hostile use;
  - anything that can lose data.
- Confirm a suspicion with a throwaway test instead of guessing. The reviewer
  in the run did this for its two worst suspicions (observation 8).

Each point grows only when a later run shows the review missed something.

**Adversarial** means: the reviewer's job is to find what is wrong, not to
approve. Report only findings that matter; OpenAI's experience is that
verbose reviews get ignored like lint noise. Whoever asked for the review
fixes the findings: in the workflow, that is the builder. A finding that is
hard to undo goes to the developer.

**Why not the built-in `/code-review` or `/security-review`:** each covers only
some of the three points of the baseline, and neither looks at
maintainability.

**A known limit:** a reviewer on the same model as the builder is not fully
independent (arXiv paper). A fresh context and an adversarial prompt help,
but don't remove this. That is one more reason for the user stand-in and for
the developer's own look.

### `check` (new skill, after `review`)

Workflow steps 5 and 6.

- Runs `review` and the user stand-in, each in a fresh context. They find
  different things: one reads the code, the other uses the app.
- The user stand-in uses the running app, including what happens when things
  fail, not only the happy paths. In the first run the builder tried only
  happy paths and one offline case (observation 6).
- Lists every decision the builder made alone that `decide` would have
  flagged. A safety net for step 5 of this roadmap (observation 5).
- The builder fixes what the two find.
- The report shows the developer only what is hard to undo and what is still
  open. It comes before the change is wrapped up.

Outside support: AWS says self-correction only works against checks the AI
cannot change. Thoughtworks saw agents get around their own tests. OpenAI
writes tests in a separate session from the code.

## Step 4: second test run, on an existing project

`docs/workflow.md` is written for changing an existing project, and the first
run was a new app. Use the full workflow on a real change to an existing
project. Write what happened into a new file in `docs/evidence/`, in the same
form as the first.

Watch especially:

- whether `decide` now brings up interaction, the life of the data and
  patterns without being pushed;
- whether the builder still decides things alone that are hard to undo;
- what `review` and the stand-in miss that the developer then finds.

This run does not test the changes for new projects, nor branches unless
step 6 is done first. Those need a later run.

## Step 5: make `decide` start during the build

Open question 3 in the evidence file. Wait for the second run before choosing
how. Steps 1 and 2 may fix most of it: with the stack, the data shape and the
tells in the change file, the builder has fewer decisions left to make alone.

The safety net in `check` (step 3) reports such decisions in any case, but
only after the build. If the builder still decides alone, the options to
catch it during the build, cheapest first:

1. A line in the change file telling the builder to stop and run `/decide`
   when a decision is hard to undo.
2. A hook that reminds the builder to run `/decide` when it changes the
   files where such decisions usually show: the database schema, the
   dependencies, the deployment setup.

## Step 6: branches

Open question 4. In the first run everything was committed to `main`
(observation 4). This is the developer's decision. The recommendation:
`explore` creates a branch when it writes the change file, and wrap-up merges
it. For a change that skips `explore`, `decide` creates the branch. It is
small, so it can be done before step 4 if the second run should already use a
branch.

## Step 7: learn from the sessions

So far, evidence was collected by hand from the session logs in
`~/.claude/projects/<project>/`. A skill does this, and the developer decides
what changes. Findings are only candidates until a human approves them, as in
AWS AI-DLC 2.0.

### Where it runs

**One skill, `learn-from-sessions`, run in a project repository.** It covers
all sessions of that project since its last run, not only the current one.

- The sessions belong to the project, and only with the project's
  `CLAUDE.md`, code and conventions at hand can the skill tell a finding about
  the project from one about a skill.
- It is installed globally like the other skills, but starts only when the
  developer types it: `disable-model-invocation: true` in its frontmatter.
- It notes which sessions it has read, so nothing is counted twice.

### What it looks for

The same approach as `review`: a broad baseline, and a list from the evidence
as the first expansion, not as the limit.

**The baseline:** where did the work fall short of the four goals or the
ideas in `docs/manifesto.md`? Where did the developer have to step in,
correct, repeat something, or find something too late? What took more of the
developer's attention than it should have?

**Also what worked.** Observation 9, "plain Claude Code built a good
structure", was evidence too: it kept us from adding a build skill. A skill
that only looks for faults only ever proposes adding things.

**First expansion, places to look first**, all seen in the first run:

- the developer corrected the agent, or had to push for something
  (observation 1);
- the developer asked a question that showed a gap (observation 2);
- a skill should have started and did not (observation 5);
- the agent decided something hard to undo alone (observation 5);
- a later session found bugs the build missed (observation 8).

The list grows only when the developer finds something in the logs that the
skill missed.

### What it reports

- Each finding has a session ID and a quote, so it can be checked. No quote,
  no finding.
- The same kind of finding seen again is counted, not listed twice. Seen in
  three sessions is stronger than seen once.
- Each finding gets a proposed destination:

| Destination | When |
|---|---|
| The project's `CLAUDE.md` or code | It is about this project: its domain, its conventions, a missing check. |
| This repository, as an evidence file | It is about how a skill or the workflow behaves, in any project. |
| Nowhere | A one-off, or already known. |

- The developer picks what to apply. The skill makes the project changes
  with the developer, in the project repository.
- Findings about skills go into `docs/evidence/YYYY-MM-DD-<project>.md` in
  this repository, in the form of the first evidence file. The skill finds
  this repository by following its own symlink in `~/.claude/skills/`, which
  `sync.sh` created. It writes the file but does not change any skill.
- An evidence file describes the pattern in its own words. It does not copy
  code or data from the project.

### No second skill here

Turning evidence into skill changes is ordinary work in this repository, and
`CLAUDE.md` already guides it. Add a skill for it only if that work starts to
repeat itself.

### Later

The hard part is the prompt: what counts as a finding, and how to avoid false
ones. It needs a few rounds of tuning, so the skill is run by hand first.
Once its list can be trusted, a local cron job running
`claude -p "/learn-from-sessions"` every night automates it. A cloud routine
cannot read the local session logs.

`learn-from-sessions/narrate.py`, written to read the logs of the first run,
is a starting point for reading sessions compactly. The skill's `SKILL.md`
goes next to it.

This step can come before step 4, so the second test run is the first with
collected evidence.

## Not on the roadmap

- **Guidance for the build** (open questions 1 and 2). Plain Claude Code
  built a good structure (observation 9). The build gets its tests through
  step 2, and the list of tests by kind of risk lives only in `review`. That
  answers open question 2 for now, against the evidence file's suggestion
  that "the build may need guidance". Add guidance for the build only when
  runs show `review` catching the same kind of bug too late again and again.
- **Spec tools and staged ceremony** in the style of AWS AI-DLC. Thoughtworks
  found that spec tools give "a false sense of control". The old pipeline
  skills were deleted for this reason.
- **Rules about test coverage** (observation 10).
