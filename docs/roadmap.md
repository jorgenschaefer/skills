# Roadmap

What we change in the skills next, and why. It follows from three test runs,
from reading the skills against `docs/manifesto.md`, and from the summaries
in `docs/reference/`. Delete this file when everything below is done.

Four kinds of numbers appear below. "Step 1" is a step of this roadmap.
"Finding 1" is a finding in this file. "Workflow step 5" is a step in
`docs/workflow.md`. "Logbook observation 8", "kh-finder observation 8" and
"tracker observation 3" are observations in the evidence files
`docs/evidence/2026-11-05-workout-logbook.md`,
`docs/evidence/2026-11-07-kh-finder.md` and
`docs/evidence/2026-11-08-workout-tracker.md`. A fixed finding is cut, and its
number is not used again.

## Where we are

Steps 1 to 7 are done, except step 5, which is now finding 2. Git history
has what each step changed. Two of them come up below:

- Step 1 split the work between `discover-change` and `design-change`.
  They were called `explore` and `decide`, and the logbook uses those names.
  Later `discover-change` was called `understand-change`, and the evidence
  uses that name.
- Step 2: a test holds a promise about behaviour, and structure holds a rule
  every piece of code would have to remember.

## How to work on this

- **A change that answers a test run names the observation it answers.**
  The findings without evidence below are things to watch.
- **A skill has a core and a list to look out for.** What a typical run
  needs is the core. The rest of what test runs taught goes under
  `## Look out for`, as general categories. `CLAUDE.md` says how.
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
- **Likelihood**: how likely a model is to do what a finding says, when it
  follows the skill.
- **Impact**: how much harm that does, measured as the manifesto measures
  it: by how hard it is to undo.

## Next: a fourth test run

Workout-tracker was the third run, on a new project. It showed that the
builder still decides things alone (finding 2). Its evidence file says
little about the other questions below, so they are still open. Watch especially:

- **What the kh-finder and workout-tracker runs did not answer:**
  - what `review-change` and `try-change` miss that the developer then finds.
    Workout-tracker has one case: both reviews missed a decision nobody
    agreed to (finding 2).
    A reviewer on the same model as the builder is not fully independent
    (arXiv paper). A fresh context and an adversarial prompt help, but don't
    remove this;
  - whether `design-change` brings up interaction, the life of the data and
    patterns without being pushed. kh-finder shows nothing about these;
  - whether the three fixes made after kh-finder hold: `design-change` asks
    where keys live and how often a paid call fires; `backlog` asks for
    sizes when another skill hands over an item; `learn-from-sessions`
    writes its report before it asks;
  - whether the two fixes for a redesign hold: `accept-change` sends a
    different behaviour back to `build-change`, and `build-change` runs the
    review and the stand-in once more after its fixes;
  - whether `try-change` now checks phone width, in a frame if the window
    does not resize, and whether the build's report now leaves out fixes;
  - whether `design-change` now ends with every decision in the chat,
    whether `discover-change` now starts on an open request, and whether
    the definition of simple stops a server written by hand from counting
    as simpler than a package;
  - whether the three fixes for finding 2 hold: `design-change` asks when
    each thing starts and ends, the review flags decisions about how the
    user moves through the task, and the build's report names what the
    builder decided alone;
  - whether, on a new project, the change's branch now starts from a first
    commit, so the review and `accept-change` compare against `main`
    without a workaround;
  - whether the developer now tries the change on their own data, with
    nothing left over from the stand-in;
  - whether `design-change` now names the stack before the decisions that
    rest on it;
  - what `learn-from-sessions` misses that the developer finds in the logs;
  - what the fixes cost, not only whether they hold. Each run so far added
    a clause to the skills and none removed one. Watch whether
    `design-change` now asks or tells more than before, and whether the
    developer waves its tells through without reading them;
  - whether a slimmer core makes a skill miss something it caught before.
    The pipeline skills now keep what earlier runs taught under
    `## Look out for`, after the core. Watch whether the model still reads
    and uses that list.
- **Did a wide decision slip through because it was easy to revert?** Some
  decisions reach a lot: a shared login check, a global limit, a migration
  over every record. Reverting the code is easy. But what the software did
  before the revert may not be: data that leaked, users locked out. The
  skills already count that as hard to undo (`design-change/SKILL.md:14`),
  but a model may read "easy to revert" and stop there. If it happens,
  sharpen the existing question rather than add a rule: "If this is wrong,
  what happens before anyone reverts it, and to how many people or how much
  data?" Don't send every wide change to the developer: the manifesto ranks a
  harm that is fully undone, such as an outage that is over, lower on
  purpose. No evidence yet.
- **The findings without evidence**, below.

## Tuning `learn-from-sessions`

The hard part is the prompt: what counts as a finding, and how to avoid false
ones. It needs a few rounds of tuning, so the skill is run by hand first. Its
list of places to look grows only when the developer finds something in the
logs that it missed. Once its list can be trusted, a local cron job running
`claude -p "/learn-from-sessions"` every night automates it. A cloud routine
cannot read the local session logs.

The false findings to prevent look like kh-finder observation 1. It put two
kinds of cases into one pattern, and a later correction blamed the wrong
cause. Checking each case against its quote would have caught both.

## Findings with evidence

What the evidence confirms, ordered worst first. Fix these first.

### 2. The builder decides hard-to-undo things alone

`build-change/SKILL.md:19` says only "Build the smallest thing that does the
job". Nothing tells the builder to stop and run `/design-change` when a
decision is hard to undo. `review-change` and the build's report name such
decisions, but only after they are built.

Likelihood: high. Impact: high.

Evidence: logbook observation 5 and tracker observation 1. kh-finder had no
case of it, and we guessed that steps 1 and 2 fix most of it: with the stack,
the data shape and the tells in the change file, the builder has fewer
decisions left to make alone. Workout-tracker shows that this does not cover
a gap `design-change` left open. The builder decided alone how a training
starts and ends, and its report did not say so. Both reviews read that code
and did not list the decision: their list of what is hard to undo left out
how the user moves through the task. When the developer was confused, the
builder said its rule came from the change file (finding 22).

Three fixes followed. `design-change` now asks when each thing starts and
ends. `review-change` now counts
how the user moves through the task. The build's report now names each
decision the builder made alone. If the builder still decides alone, the
options, cheapest first:

1. A line in `build-change` telling the builder to stop and run
   `/design-change` when a decision is hard to undo. `design-change` then
   needs lines on starting in the middle of a build again. They were cut
   because nothing started it there (logbook observation 5).
2. A hook that reminds the builder to run `/design-change` when it changes
   the files where such decisions usually show: the database schema, the
   dependencies, the deployment setup. It would not have caught the
   workout-tracker case, which changed how the user moves through the task.

### 4. The agent recommends more than the problem needs

The manifesto says to build small (`docs/manifesto.md:58-61`): the least that
solves the problem, so you learn early. `discover-change/SKILL.md:26` says
to put the simplest approach first, but the agent still recommends a bigger
one.

Likelihood: high. Impact: medium.

Evidence: kh-finder observation 1. The agent proposed a five-phase rewrite
and a proxy with a PIN per person and rate limiting (`c7547d4c`), recommended
the bigger of three approaches (`2e97ef0c`), and a rule on distance and time
when time alone was enough (`6878405c`, `dc1e029c`). The developer cut each
back. Why "simplest first" did not hold is not clear yet.

In the same observation, `723ff5f4` showed a second kind of case: "simplest"
read as "fewest dependencies", so a server written by hand counted as
simpler than a dev-only package. `discover-change` and `design-change` now
say what simple means: the least we write, understand and keep. They no
longer add that a dependency is often simpler. The project's `CLAUDE.md`
banned dependencies at the time, and the session cannot show whether that
or the skill pushed the agent. The cases of too much scope stay open.

### 22. The builder defends its own decisions

`build-change/SKILL.md:38` asks for "what you recommend" on decisions the
builder made alone. It will defend what it already built.

Likelihood: high. Impact: medium.

Evidence: only a related case, tracker observation 1. The decision was not
in the report at all. When the developer asked, the builder called its own
rule "how it's meant to work (from the change file …)", and said that an
explicit "done" would "change a decision in the change file". The developer
had never agreed to that decision.

## Findings without evidence yet

These come only from reading the skills. No test run has shown them. Watch
for them in the next run, and don't change a skill for them until one does.
Ordered worst first.

### 14. Small changes skip the check

When `design-change` finds nothing that matters, it says "say so in one line
and carry on. There is nothing to record: no branch, no change file, no
commit" (`design-change/SKILL.md:35`). But `build-change` needs a change
file, and the model cannot start it on its own (`disable-model-invocation`).
So "carry on" means a plain build in the same session: no fresh review, no
`try-change`, and the commits go to `main`. Workflow step 1 sends every clear,
small change this way. It also conflicts with "Then stop" (`:89-91`).

Likelihood: high. Impact: medium to high.

Evidence: none yet. In kh-finder, stopping before the build held, but only on
the path with a change file.

### 15. `upgrade-dependencies` ignores known vulnerabilities

There is no `npm audit`, and nothing puts security fixes first. If the fix
for a known vulnerability is a major version that turns the checks red, the
skill reverts it and hands it to the backlog like any other upgrade
(`upgrade-dependencies/SKILL.md:56-66`). Finding 16 then buries it.

Likelihood: high. Impact: high.

Evidence: none yet.

### 16. The backlog ranks security fixes low

The backlog ranks items by utility minus effort, and utility is "what it
gives the user" (`backlog/SKILL.md:23,40`). A security fix that
`review-change` or `upgrade-dependencies` hands over gives the user nothing
they can see, so it gets a low utility and sinks. The manifesto puts security
second, above usability.

Likelihood: high. Impact: high.

Evidence: none yet on the ranking. In kh-finder, `backlog` chose the sizes
itself when another skill handed over an item, so nobody checked them. That
is fixed now.

### 17. Tests may reach real services

`review-change/SKILL.md:38` runs throwaway tests, and does not say against
what. `try-change/SKILL.md:22` forbids production and gives the stand-in
data of its own, but a local instance still reads `.env`, which may hold
live payment or email keys. To make "the network goes away" or "the server fails" happen
(`try-change:29-34`), the model may stop shared Docker services or change the
network on the developer's machine.

Likelihood: medium. Impact: high.

Evidence: none yet. In kh-finder the checks used a throwaway container and a
faked API answer, which is the safe way.

### 18. Nobody checks the build against the existing ADRs

`build-change/SKILL.md:13` reads only the ADRs the change file links to.
`review-change/SKILL.md:27` compares the code only with the change file. A
build that breaks an older recorded decision passes both. Only
`design-change:31` reads `docs/adr/`, and that is before there is code.

Likelihood: medium. Impact: high.

Evidence: none yet.

### 19. "In a small change the list is often empty"

`design-change/SKILL.md:33` tells the model to expect nothing. Add "If you
cannot name a cost, it is not on the list", and a small change slips through
even when it adds an endpoint, an export or a personal-data field. Those are
exactly the decisions about who can see what.

Likelihood: medium. Impact: high.

Evidence: none yet.

### 35. Findings still open after the build are lost

`review-change` sends findings that are not fixed to the backlog. When
`build-change` runs it, what is still open after the second round only goes
into the build's report (`build-change/SKILL.md:32,40`). `accept-change`
sends only `## Could wait` to the backlog (`accept-change/SKILL.md:16`). Once
the developer accepts the change, nothing holds those findings.

Likelihood: medium. Impact: high.

Evidence: none yet on this path. The logbook lost two save bugs the same way,
before `review-change` sent its findings to the backlog.

### 20. Upgrades install brand-new releases at once

`upgrade-dependencies` installs the newest versions right away, and their
install scripts run (`upgrade-dependencies/SKILL.md:35,54`). There is no
minimum age for a release, and no look at new transitive dependencies or
install scripts. A compromised release that came out yesterday runs on the
developer's machine.

Likelihood: low. Impact: high.

Evidence: none yet.

### 31. The review looks for the risks of one app

The list of risks in `review-change/SKILL.md:29-34` comes from one offline
app. It does not name reading other users' records by changing an ID,
injection, cross-site scripting, secrets that end up in the client bundle, or
a new route that skips the login check. "A start, not the limit" helps, but
the list steers where the model looks.

Likelihood: low. Impact: high.

Evidence: none yet. In kh-finder the review did catch the leaked key.

### 21. A confirmed bug leaves no test behind

The reviewer deletes its throwaway test (`review-change/SKILL.md:38`), and
`build-change:30` does not ask for a lasting test with the fix. The same bug
can come back with the next change.

Likelihood: high. Impact: medium.

Evidence: none yet. In kh-finder the builder showed that its new tests fail
on the old code, which is the opposite habit.

### 23. A decision settled along the way is never written down

"If the developer's answer settles another decision on the list too, don't
ask about that one" (`design-change/SKILL.md:50`). That decision is then
neither told nor asked, so "List every decision you told or asked" (`:74`)
leaves it out. Nothing holds it once the change file is deleted.

Likelihood: medium. Impact: medium.

Evidence: none yet.

### 24. Approaches don't show what they expose

`discover-change/SKILL.md:26` asks what each approach "is good for, and what
it costs", in the terms of the domain. The developer picks a direction, such
as sharing the logbook with a coach, without seeing what it exposes.
`design-change` only ever sees the approach that was picked.

Likelihood: medium. Impact: medium.

Evidence: none yet.

### 32. `accept-change` adds tests, structure or ADRs nobody checks

"Add what is missing" (`accept-change/SKILL.md:13`) writes them after the
developer tried the change, with no review and no try. It can also produce
an ADR saying "Decided: by the developer" for something the developer never
decided.

Likelihood: medium. Impact: medium.

Evidence: none yet. In kh-finder (`68ef4750`) the step worked well: it found
a test that did not pin its decision, added one, and asked about three
findings the developer had never answered.

### 25. `learn-from-sessions` writes project details into a public repository

The evidence files hold project names, paths, session IDs and descriptions of
what happened (`learn-from-sessions/SKILL.md:65`). This repository is public
(`npx skills add jorgenschaefer/skills`). "Don't copy the project's code or
data" does not cover a client's name or confidential details of its domain.
What leaked cannot be unleaked.

Likelihood: medium. Impact: medium.

Evidence: none yet. The kh-finder evidence file names the project and its
domain; for this project that is fine.

### 33. The change file never says who uses the software

The change file has no place for who uses the software, on which device, and
where. `try-change` has to find the screen size elsewhere.

Likelihood: medium. Impact: medium.

Evidence: none yet. In kh-finder the stand-in knew the app is used on phones.

### 34. A real choice becomes a one-line tell

Asking takes three options that differ in substance, and mock-ups
(`design-change/SKILL.md:41-48`). Telling takes one line. So the model may
lean toward "only one sensible option", and "sensible" means its own
default.

Likelihood: medium. Impact: medium to high.

Evidence: none yet. kh-finder showed only that a decision can go missing
from the chat summary, and that is fixed.

### 26. Nobody checks accessibility

`try-change` never uses the software with a keyboard alone, checks contrast,
or uses a screen reader.

Likelihood: high. Impact: low to medium.

Evidence: none yet.

### 36. `learn-from-sessions` never reads a session again

The list of read sessions holds only their IDs
(`learn-from-sessions/sessions.py:60-75`). A session still running in another
terminal is marked as read, and so is one the developer later resumes. Its
later turns are skipped on every run, and nobody notices.

Likelihood: medium. Impact: low to medium.

Evidence: none yet.

### 27. A new project means a long row of questions

One decision at a time, with mock-ups (`design-change/SKILL.md:41`), means
many rounds in a new project: stack, design system, data, hosting, login. A
tired developer starts accepting whatever is recommended.

Likelihood: medium. Impact: low to medium.

Evidence: none yet. kh-finder was an existing project.

### 28. Three approaches even for a sharp request

"Offer at least three approaches" (`discover-change/SKILL.md:26`) works
against "Match the depth to the request" (`:12`). The model pads with weak
options.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 29. Every failed try goes back to `discover-change`

`build-change/SKILL.md:46` sends every failure back to `/discover-change`,
even a plain bug. There, `discover-change/SKILL.md:34` writes a new change
file and does not look for the one already on the branch. With two change
files, `build-change` cannot pick "the only one there", and `accept-change`
may delete one and leave the other to be merged into `main`.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 30. The setup skill installs every preferred library

The model may add TanStack Query and Mantine before anything needs them
(`nextjs-project-setup/SKILL.md:18-25`). The manifesto says every feature has
to earn its place.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 38. The skills hold several copies of the change file's format

The format, and which skill writes which section, are in
`discover-change/CHANGE_FORMAT.md` and `design-change/SKILL.md:63-74`,
and partly in `review-change` and `accept-change`. The copies are needed,
because each skill only sees its own directory. But they already disagree:
the format says an empty section says "None.", and
`design-change/SKILL.md:35` writes no change file at all (finding 14).

Likelihood: medium. Impact: low.

Evidence: none yet from a test run.

### 37. `learn-from-sessions` needs the `sync.sh` install

It finds the skills repository by following the link to its own directory
(`learn-from-sessions/SKILL.md:13`). The `npx skills add` install, which
`README.md` gives first, makes no link. Then there is no
`docs/manifesto.md` and no `docs/evidence/`, and the skill does not say
what to do.

Likelihood: low. Impact: low.

Evidence: none yet.

## Contradicted by the evidence

Expected from reading the skills, but the run showed otherwise.

- **"Smallest thing" read as "least code", leading to shortcuts.** No sign of
  it. The agent built more, not less (finding 4).

## Not on the roadmap

- **Advice on how to build.** Plain Claude Code built a good structure
  (logbook observation 9), and in kh-finder it wrote tests first and asked
  before a decision that was hard to undo. The build gets its tests through
  step 2, and the list of tests by kind of risk lives only in
  `review-change`. `build-change` gets advice like any skill: when a run
  shows it missed something, such as `review-change` catching the same kind
  of bug too late again and again.
- **Spec tools and staged ceremony** in the style of AWS AI-DLC. Thoughtworks
  found that spec tools give "a false sense of control". The old pipeline
  skills were deleted for this reason.
- **Rules about test coverage** (logbook observation 10).
