# Roadmap

What we change in the skills next, and why. It follows from two test runs,
from reading the skills against `docs/manifesto.md`, and from the summaries
in `docs/reference/`. Delete this file when everything below is done.

Four kinds of numbers appear below. "Step 1" is a step of this roadmap.
"Finding 1" is a finding in this file. "Workflow step 5" is a step in
`docs/workflow.md`. "Logbook observation 8" and "kh-finder observation 8"
are observations in the evidence files
`docs/evidence/2026-11-05-workout-logbook.md` and
`docs/evidence/2026-11-07-kh-finder.md`. A fixed finding is cut, and its
number is not used again.

## Where we are

Steps 1, 2, 3, 4, 6 and 7 are done. What they changed is in the skills, in
`docs/workflow.md`, in `docs/evidence/` and in git history.

- Step 1: `understand-change` understands the problem and picks a direction.
  `design-change` designs what is costly to change. They were called
  `explore` and `decide`, and the logbook uses those names.
- Step 2: a promise about behaviour is held by a test, and a rule every piece
  of code would have to remember by structure.
- Step 3: `build-change` builds a change and checks it with `review-change`
  and the user stand-in `try-change`, each in a fresh context.
  `accept-change` wraps it up once the developer accepts it. The developer
  starts both.
- Step 4: the second test run, on kh-finder, an existing project. It ran
  the whole workflow, and `build-change` and `accept-change` ran for the
  first time. What it showed is in the findings below.
- Step 6: each change gets its own branch. The developer merges it.
- Step 7: `learn-from-sessions` collects evidence from a project's session
  logs.

Step 5, starting `design-change` during the build, is now finding 2.

## How to work on this

- **Every change to a skill comes from evidence.** Name the observation it
  answers. A skill starts small and grows only when a test run shows that it
  missed something. Don't add rules because they feel right. The findings
  without evidence below are things to watch, not changes to make.
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

## Next: a third test run

The changes for new projects have not been tested since the logbook. A run on
a new project would test them. Watch especially:

- **What the kh-finder run did not answer:**
  - whether the builder still decides things alone that are hard to undo
    (finding 2);
  - whether the branches work: one per change, and nothing left on `main`;
  - what `review-change` and `try-change` miss that the developer then finds.
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
  - what `learn-from-sessions` misses that the developer finds in the logs.
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

Two runs so far:

- On 2026-11-06 it read the logbook's three sessions. It found three things
  about the skills and four about the project, each with a quote. One change
  came of it: `review-change` now sends findings that are not fixed to the
  backlog.
- On kh-finder it ran twice. The first run lost its work, because it wrote
  nothing down before asking; that is fixed now. The second wrote the evidence
  file. Its observation 1 counted cases with different causes as one pattern,
  and drew a conclusion that did not hold: some of the cases followed an old
  project rule. The developer caught it. That is the kind of false finding the
  tuning has to prevent.

## Findings with evidence

What the evidence confirms, ordered worst first. Fix these first.

### 2. The builder decides hard-to-undo things alone

`build-change/SKILL.md:19` says only "Build the smallest thing that does the
job". Nothing tells the builder to stop and run `/design-change` when a
decision is hard to undo. `review-change` reports such decisions, but only
after they are built.

Likelihood: high. Impact: high.

Evidence: logbook observation 5. kh-finder has no case of it, which fits the
guess that steps 1 and 2 fix most of it: with the stack, the data shape and
the tells in the change file, the builder has fewer decisions left to make
alone. If it shows up again, the options, cheapest first:

1. A line in `build-change` telling the builder to stop and run
   `/design-change` when a decision is hard to undo.
2. A hook that reminds the builder to run `/design-change` when it changes
   the files where such decisions usually show: the database schema, the
   dependencies, the deployment setup.

### 4. The agent recommends more than the problem needs

The manifesto says to build small (`docs/manifesto.md:58-61`): the least that
solves the problem, so you learn early. `understand-change/SKILL.md:26` says
to put the simplest approach first, but the agent still recommends a bigger
one.

Likelihood: high. Impact: medium.

Evidence: kh-finder observation 1. The agent proposed a five-phase rewrite
and a proxy with a PIN per person and rate limiting (`c7547d4c`), recommended
the bigger of three approaches (`2e97ef0c`), and a rule on distance and time
when time alone was enough (`6878405c`, `dc1e029c`). The developer cut each
back. Why "simplest first" did not hold is not clear yet. The cases about
dependencies in the same observation belong to finding 10, not here.

### 6. `try-change` cannot check phone width

`try-change/SKILL.md:22` asks for "the screen size they use it on", but the
stand-in cannot resize the browser. The change file also has no place for
who uses the software, on which device, and where.

Likelihood: high. Impact: medium.

Evidence: kh-finder observation 8. The stand-in knew the app is used on
phones. Once it checked in a 360 px frame instead; once it reported "Nobody
tried the change at phone width." That the change file lacks the user's
device has no evidence yet: in kh-finder the stand-in knew it.

### 7. Reports list fixes and successes, although the skills forbid it

`build-change/SKILL.md:41` says to show "Not what you fixed, and not what went
well". The reports do it anyway.

Likelihood: high. Impact: low, but it costs the developer attention.

Evidence: kh-finder observation 2, five reports. One case may be a fair
exception: a fixed bug that broke a decision that matters, such as a race
with the user's consent. Either the rule goes, or the skill says why it is
there and names the exception.

### 8. A real choice becomes a one-line tell

Asking takes three options that differ in substance, and mock-ups
(`design-change/SKILL.md:41-48`). Telling takes one line. So the model leans
toward "only one sensible option", and "sensible" means its own default.
Tells come as a list of one-liners (`:52-55`), so the developer skims past a
security-relevant one such as "sessions never expire".

Likelihood: medium. Impact: medium to high.

Evidence: partly, kh-finder observation 10. The developer reads the chat
summary, not the change file, and one summary left out "the app asks the API
by itself". That the model tells where it should ask has no evidence yet.

### 10. A project rule the developer drops still wins

When the developer says in the session that a rule in `CLAUDE.md` no longer
holds, the agent keeps following the file.

Likelihood: medium. Impact: medium.

Evidence: kh-finder observation 1, `723ff5f4`. `CLAUDE.md` still said
"nothing it ships has a dependency", although the developer had just dropped
the rule. The agent recommended a server written by hand, then a global
install. The rule should give way to what the developer said, and `CLAUDE.md`
should change with it.

### 11. `understand-change` does not start on an open request

Its description (`understand-change/SKILL.md:3`) names ideas, wishes and
problems, and phrases such as "let's think this through". A request like
"question every assumption and write a roadmap" matches none of them.

Likelihood: medium. Impact: medium, because the change starts from a premise
nobody questioned.

Evidence: kh-finder observation 7. The agent agreed with the premise and put
a feeling, a migration and a feature into one change file. Once the skill
ran, asking what prompted the request found the real problem.

### 12. `nextjs-project-setup` and `design-change` both decide the stack

`design-change/SKILL.md:33,48` asks about the stack and the design system,
with three options each. `nextjs-project-setup/SKILL.md:8,18-25` says both are
already decided: Next.js and Mantine. Either the developer is asked what they
already answered, or the setup skill runs first and the stack is chosen
without a word, including hosting, database and login, which the setup skill
does not cover.

Likelihood: medium. Impact: medium.

Evidence: only a related case, kh-finder observation 7. Without
`understand-change`, the agent used `nextjs-project-setup` as a guide to the
developer's stack for an existing project. The clash itself has no evidence
yet; it needs a new project.

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
what. `try-change/SKILL.md:22` forbids production, but a local instance still
reads `.env`, which may hold live payment or email keys, or point at a shared
database. To make "the network goes away" or "the server fails" happen
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

### 22. The builder recommends on its own decisions

`build-change/SKILL.md:38` asks for "what you recommend" on decisions the
builder made alone. It will defend what it already built.

Likelihood: high. Impact: medium.

Evidence: none yet.

### 23. A decision settled along the way is never written down

"If the developer's answer settles another decision on the list too, don't
ask about that one" (`design-change/SKILL.md:50`). That decision is then
neither told nor asked, so "List every decision you told or asked" (`:74`)
leaves it out. Nothing holds it once the change file is deleted.

Likelihood: medium. Impact: medium.

Evidence: none yet.

### 24. Approaches don't show what they expose

`understand-change/SKILL.md:26` asks what each approach "is good for, and what
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

### 26. Nobody checks accessibility

`try-change` never uses the software with a keyboard alone, checks contrast,
or uses a screen reader.

Likelihood: high. Impact: low to medium.

Evidence: none yet.

### 27. A new project means a long row of questions

One decision at a time, with mock-ups (`design-change/SKILL.md:41`), means
many rounds in a new project: stack, design system, data, hosting, login. A
tired developer starts accepting whatever is recommended.

Likelihood: medium. Impact: low to medium.

Evidence: none yet. kh-finder was an existing project.

### 28. Three approaches even for a sharp request

"Offer at least three approaches" (`understand-change/SKILL.md:26`) works
against "Match the depth to the request" (`:12`). The model pads with weak
options.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 29. Every failed try goes back to `understand-change`

`build-change/SKILL.md:45` sends every failure back to `/understand-change`,
even a plain bug.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 30. The setup skill installs every preferred library

The model may add TanStack Query and Mantine before anything needs them
(`nextjs-project-setup/SKILL.md:18-25`). The manifesto says every feature has
to earn its place.

Likelihood: medium. Impact: low.

Evidence: none yet.

## Contradicted by the evidence

Expected from reading the skills, but the run showed otherwise.

- **The builder drops review findings without a trace.**
  `build-change/SKILL.md:41` says "Not what you fixed", so a finding the
  builder thinks is wrong could vanish. kh-finder observation 2 showed the
  opposite: the reports showed more than asked (finding 7).
- **`backlog` asks for too many confirmations.** kh-finder observation 3
  showed the opposite: called from another skill, it asked for none. That
  is fixed now.
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
