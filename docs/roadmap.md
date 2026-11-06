# Roadmap

What we change in the skills next, and why. It follows from the first test
run (`docs/evidence/2026-11-05-workout-logbook.md`) and the summaries in
`docs/reference/`. Delete this file when everything below is done.

Three kinds of numbers appear below. "Step 1" is a step of this roadmap.
"Workflow step 5" is a step in `docs/workflow.md`. "Observation 8" is an
observation in the evidence file.

## Where we are

Steps 1, 2, 3, 6 and 7 are done. What they changed is in the skills, in
`docs/workflow.md` and in git history.

- Step 1: `understand-change` understands the problem and picks a direction.
  `design-change` designs what is costly to change. They were called
  `explore` and `decide`, and the evidence files use those names.
- Step 2: a promise about behaviour is held by a test, and a rule every piece
  of code would have to remember by structure.
- Step 3: `accept-change` checks a built change with `review-change` and the
  user stand-in `try-change`, each in a fresh context. The developer starts
  it in a fresh session, not the builder.
- Step 6: each change gets its own branch. The developer merges it.
- Step 7: `learn-from-sessions` collects evidence from a project's session
  logs.

`understand-change` and `design-change` ran once, under their old names, on a
new app. `try-change` and `accept-change` have never run. The build is plain
Claude Code; there is no build skill.

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

## Words used here

- **Tell and ask.** `design-change` puts every decision that is hard to undo
  to the developer. Where there is a real choice, it asks, with options and a
  recommendation. Where there is only one sensible option, it tells: one line,
  so the developer can object. "A tell" is such a line.
- **Change file.** `changes/YYYY-MM-DD-<slug>.md`, the agreement for one
  change. It is deleted when the change is done.

## Step 4: second test run, on an existing project

The first run was a new app. Use the full workflow on a real change to an
existing project. Collect the evidence with `/learn-from-sessions` in that
project, and write it into a new file in `docs/evidence/`, in the same form
as the first.

Watch especially:

- whether `design-change` now brings up interaction, the life of the data and
  patterns without being pushed;
- whether the builder still decides things alone that are hard to undo;
- whether `try-change` can start and use the software;
- what `review-change` and `try-change` miss that the developer then finds. A
  reviewer on the same model as the builder is not fully independent (arXiv
  paper). A fresh context and an adversarial prompt help, but don't remove
  this;
- whether the branches work: one per change, and nothing left on `main`;
- what `learn-from-sessions` misses that the developer finds in the logs.

This run does not test the changes for new projects. Those need a later run.

## Step 5: make `design-change` start during the build

Open question 3 in the evidence file. Wait for the second run before choosing
how. Steps 1 and 2 may fix most of it: with the stack, the data shape and the
tells in the change file, the builder has fewer decisions left to make alone.

The safety net in `accept-change` (step 3) reports such decisions in any
case, but only after the build. If the builder still decides alone, the
options to catch it during the build, cheapest first:

1. A line in the change file telling the builder to stop and run
   `/design-change` when a decision is hard to undo.
2. A hook that reminds the builder to run `/design-change` when it changes
   the files where such decisions usually show: the database schema, the
   dependencies, the deployment setup.

## Tuning `learn-from-sessions`

The hard part is the prompt: what counts as a finding, and how to avoid false
ones. It needs a few rounds of tuning, so the skill is run by hand first. Its
list of places to look grows only when the developer finds something in the
logs that it missed. Once its list can be trusted, a local cron job running
`claude -p "/learn-from-sessions"` every night automates it. A cloud routine
cannot read the local session logs.

The first run, on 2026-11-06, read the logbook's three sessions. It found
three things about the skills and four about the project, each with a quote.
It left out what the evidence file already had, so whether it would find
those on its own is still untested. One change came of it: `review-change`
now sends findings that are not fixed to the backlog.

## Not on the roadmap

- **Guidance for the build** (open questions 1 and 2). Plain Claude Code
  built a good structure (observation 9). The build gets its tests through
  step 2, and the list of tests by kind of risk lives only in
  `review-change`. That answers open question 2 for now, against the
  evidence file's suggestion that "the build may need guidance". Add
  guidance for the build only when runs show `review-change` catching the
  same kind of bug too late again and again.
- **Spec tools and staged ceremony** in the style of AWS AI-DLC. Thoughtworks
  found that spec tools give "a false sense of control". The old pipeline
  skills were deleted for this reason.
- **Rules about test coverage** (observation 10).
