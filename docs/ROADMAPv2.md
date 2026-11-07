# Roadmap v2

Where the skills, as written today, lead a model to work against
`docs/manifesto.md`. Each finding names what the model will do, where in a
skill that comes from, two ratings, and what the evidence says.

- **Likelihood**: how likely a model is to do this when it follows the skill.
- **Impact**: how much harm it does, measured as the manifesto measures it:
  by how hard it is to undo.
- **Evidence**: what the test runs showed. "Logbook" is
  `docs/evidence/2026-11-05-workout-logbook.md`, "kh-finder" is
  `docs/evidence/2026-11-07-kh-finder.md`. A finding is confirmed,
  contradicted, or has no evidence yet.

The findings first came from reading the skills. The kh-finder run then
confirmed some, contradicted others, and added three. The numbers stay as
first written. Ratings changed where evidence came in, so the order is no
longer strictly worst first.

`docs/roadmap.md` says every change to a skill needs evidence. Findings with
no evidence yet are things to watch in the next run, not changes to make now.

## What to fix first

The findings with evidence behind them:

- **11**, secrets and paid outside calls. Seen in both runs.
- **15 and 17**, a redesign inside `accept-change` that nobody reviews or
  tries again.
- **21**, the agent recommending more than the problem needs. The developer
  cut it back several times.
- **22**, `backlog` choosing sizes on its own. This also makes 3 worse.
- **1**, the builder deciding alone. Seen in the logbook. kh-finder adds no
  new data.

Of those with no evidence yet, 2 and 3 matter most: small changes never
checked, and security fixes sinking in the backlog.

## Questions for the next run

### Did a wide decision slip through because it was easy to revert?

Some decisions reach a lot: a shared login check, a global limit, a migration
over every record. Reverting the code is easy. But what the software did
before the revert may not be: data that leaked, users locked out. The skills
already count that as hard to undo (`design-change/SKILL.md:14`), but a model
may read "easy to revert" and stop there.

Watch whether that happens. If it does, sharpen the existing question rather
than add a new rule: "If this is wrong, what happens before anyone reverts
it, and to how many people or how much data?" Don't send every wide change
to the developer: the manifesto ranks a harm that is fully undone, such as an
outage that is over, lower on purpose.

No evidence yet.

## High likelihood, high impact

### 1. The builder decides hard-to-undo things alone

`build-change/SKILL.md:19` says only "Build the smallest thing that does the
job". Nothing tells the builder to stop and run `/design-change` when a
decision is hard to undo. Roadmap step 5 is still open. `review-change`
reports such decisions, but only after they are built.

Likelihood: high. Impact: high.

Evidence: confirmed in the logbook, observation 5. kh-finder adds no new
data.

### 2. Small changes skip the check

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

### 3. The backlog ranks security fixes low

The backlog ranks items by utility minus effort, and utility is "what it
gives the user" (`backlog/SKILL.md:23,40`). A security fix that
`review-change` or `upgrade-dependencies` hands over gives the user nothing
they can see, so it gets a low utility and sinks. The manifesto puts security
second, above usability.

Likelihood: high. Impact: high.

Evidence: none yet on the ranking. kh-finder observation 3 makes it worse:
called from another skill, `backlog` chose the sizes itself, so nobody checks
them (finding 22).

### 4. `upgrade-dependencies` ignores known vulnerabilities

There is no `npm audit`, and nothing puts security fixes first. If the fix
for a known vulnerability is a major version that turns the checks red, the
skill reverts it and hands it to the backlog like any other upgrade
(`upgrade-dependencies/SKILL.md:56-66`). Finding 3 then buries it.

Likelihood: high. Impact: high.

Evidence: none yet.

### 11. Secrets and paid outside calls are nobody's design

The list of risks in `review-change/SKILL.md:29-34` comes from one offline
app. It does not name reading other users' records by changing an ID,
injection, cross-site scripting, secrets that end up in the client bundle, or
a new route that skips the login check. `design-change`'s list of what is
hard to undo (`design-change/SKILL.md:16-22`) does not name where secrets
live, or how often a paid call fires. No skill does.

Likelihood: high. Impact: high.

Evidence: confirmed in kh-finder, observations 4 and 5. `design-change` never
asked where the API key lives during development, so the agent asked for it
in the chat, and it ended up in the transcript. Nobody asked how often the
paid call fires: 28 requests on a 3 km drive. Under the dev server, any page
on another localhost port could read the key; the review caught it. The
logbook's observations 11 and 13 point the same way. First rated low
likelihood; the evidence says high.

## Medium likelihood, high impact

### 5. The builder can drop review findings without a trace

`build-change/SKILL.md:30` says "Fix what they found". The report shows only
what is "for the developer" and what could not be fixed, "Not what you fixed"
(`:41`). If the builder decides a finding is wrong, nobody sees it.
`review-change:53` says that findings not fixed go to the backlog, but
`build-change` never says so.

Likelihood: low. Impact: high.

Evidence: contradicted in kh-finder, observation 2. All five reports showed
more than asked, fixes and successes included, not less. First rated medium
likelihood.

### 6. Tests may reach real services

`review-change/SKILL.md:38` runs throwaway tests, and does not say against
what. `try-change/SKILL.md:22` forbids production, but a local instance still
reads `.env`, which may hold live payment or email keys, or point at a shared
database. To make "the network goes away" or "the server fails" happen
(`try-change:29-34`), the model may stop shared Docker services or change the
network on the developer's machine.

Likelihood: medium. Impact: high.

Evidence: none yet. In kh-finder the checks used a throwaway container and a
faked API answer, which is the safe way.

### 7. Nobody checks the build against the existing ADRs

`build-change/SKILL.md:13` reads only the ADRs the change file links to.
`review-change/SKILL.md:27` compares the code only with the change file. A
build that breaks an older recorded decision passes both. Only
`design-change:31` reads `docs/adr/`, and that is before there is code.

Likelihood: medium. Impact: high.

Evidence: none yet.

### 8. "In a small change the list is often empty"

`design-change/SKILL.md:33` tells the model to expect nothing. Add "If you
cannot name a cost, it is not on the list", and a small change slips through
even when it adds an endpoint, an export or a personal-data field. Those are
exactly the decisions about who can see what.

Likelihood: medium. Impact: high.

Evidence: none yet.

### 9. A real choice becomes a one-line tell

Asking takes three options that differ in substance, and mock-ups
(`design-change/SKILL.md:41-48`). Telling takes one line. So the model leans
toward "only one sensible option", and "sensible" means its own default.
Tells come as a list of one-liners (`:52-55`), so the developer skims past a
security-relevant one such as "sessions never expire".

Likelihood: medium. Impact: medium to high.

Evidence: partly confirmed in kh-finder, observation 10. The developer reads
the chat summary, not the change file, and one summary left out "the app asks
the API by itself".

## Low likelihood, high impact

### 10. Upgrades install brand-new releases at once

`upgrade-dependencies` installs the newest versions right away, and their
install scripts run (`upgrade-dependencies/SKILL.md:35,54`). There is no
minimum age for a release, and no look at new transitive dependencies or
install scripts. A compromised release that came out yesterday runs on the
developer's machine.

Likelihood: low. Impact: high.

Evidence: none yet.

## Medium impact

### 12. `try-change` cannot check phone width

The change file has no place for who uses the software, on which device, and
where. `try-change/SKILL.md:22` asks for "the screen size they use it on".

Likelihood: high. Impact: medium.

Evidence: partly confirmed in kh-finder, observation 8, with a different
cause. The stand-in knew the app is used on phones, but could not resize the
browser. Once it checked in a 360 px frame instead; once it reported "Nobody
tried the change at phone width."

### 13. A confirmed bug leaves no test behind

The reviewer deletes its throwaway test (`review-change/SKILL.md:38`), and
`build-change:30` does not ask for a lasting test with the fix. The same bug
can come back with the next change.

Likelihood: high. Impact: medium.

Evidence: none yet. In kh-finder the builder showed that its new tests fail
on the old code, which is the opposite habit.

### 14. The builder recommends on its own decisions

`build-change/SKILL.md:38` asks for "what you recommend" on decisions the
builder made alone. It will defend what it already built.

Likelihood: high. Impact: medium.

Evidence: none yet.

### 15. Fixes are not tried again

`/review-change` runs again only "if a fix changed the code a lot"
(`build-change/SKILL.md:32`), and the builder decides what "a lot" is.
`try-change` never runs again, so a fix for a usability problem is never
used by a user stand-in.

Likelihood: high. Impact: medium.

Evidence: confirmed in kh-finder, observation 6. After the second rebuild
inside `accept-change`, no review ran, and the stand-in never tried the new
button. The developer had to start both again by hand. First rated medium
likelihood.

### 16. A decision settled along the way is never written down

"If the developer's answer settles another decision on the list too, don't
ask about that one" (`design-change/SKILL.md:50`). That decision is then
neither told nor asked, so "List every decision you told or asked" (`:74`)
leaves it out. Nothing holds it once the change file is deleted.

Likelihood: medium. Impact: medium.

Evidence: none yet.

### 17. `accept-change` changes code after acceptance

"Add what is missing" (`accept-change/SKILL.md:13`) can mean new tests,
structure or ADRs, written after the developer tried the change, with no
review and no try. It can also produce an ADR saying "Decided: by the
developer" for something the developer never decided. And nothing says what
to do when the developer asks for a redesign inside the accept session.

Likelihood: medium. Impact: medium.

Evidence: mixed. Confirmed in kh-finder, observation 6: the feature was
rebuilt twice inside `accept-change`, and nothing sent it back to the
review and the stand-in. But in `68ef4750`, "add what is missing" worked
well: it found a test that did not pin its decision, added one, and asked
about three findings the developer had never answered.

### 18. Approaches don't show what they expose

`understand-change/SKILL.md:26` asks what each approach "is good for, and what
it costs", in the terms of the domain. The developer picks a direction, such
as sharing the logbook with a coach, without seeing what it exposes.
`design-change` only ever sees the approach that was picked.

Likelihood: medium. Impact: medium.

Evidence: none yet.

### 19. `nextjs-project-setup` and `design-change` both decide the stack

`design-change/SKILL.md:33,48` asks about the stack and the design system,
with three options each. `nextjs-project-setup/SKILL.md:8,18-25` says both are
already decided: Next.js and Mantine. Either the developer is asked what they
already answered, or the setup skill runs first and the stack is chosen
without a word, including hosting, database and login, which the setup skill
does not cover.

Likelihood: medium. Impact: medium.

Evidence: a related case in kh-finder, observation 7. Without
`understand-change`, the agent used `nextjs-project-setup` as a guide to the
developer's stack for an existing project.

### 20. `learn-from-sessions` writes project details into a public repository

The evidence files hold project names, paths, session IDs and descriptions of
what happened (`learn-from-sessions/SKILL.md:65`). This repository is public
(`npx skills add jorgenschaefer/skills`). "Don't copy the project's code or
data" does not cover a client's name or confidential details of its domain.
What leaked cannot be unleaked.

Likelihood: medium. Impact: medium.

Evidence: none yet. The kh-finder evidence file names the project and its
domain; for this project that is fine.

### 21. The agent recommends more than the problem needs

The manifesto says to build small (`docs/manifesto.md:58-61`): the least that
solves the problem, so you learn early. `understand-change/SKILL.md:26` says
to put the simplest approach first, but the agent still recommends a bigger
one. `build-change/SKILL.md:19` says "the smallest thing", which could also
be read as "the least code" and lead to shortcuts; there is no evidence of
that.

Likelihood: high. Impact: medium.

Evidence: confirmed in kh-finder, observation 1. The agent proposed a
five-phase rewrite and a proxy with a PIN per person and rate limiting
(`c7547d4c`), recommended the bigger of three approaches (`2e97ef0c`), and a
rule on distance and time when time alone was enough (`6878405c`,
`dc1e029c`). The developer cut each back. Why the skill's "simplest first"
did not hold is not clear yet. First rated low likelihood.

The cases about dependencies in `723ff5f4`, a server written by hand and a
global install, do not belong here. kh-finder's `CLAUDE.md` still said
"nothing it ships has a dependency", and the agent followed it. They show
something narrower: a project rule the developer drops in the session should
give way to what they said, and `CLAUDE.md` should change with it.
Observation 1 in the evidence file counts them with the rest and concludes
that "simplest" was read as "fewest dependencies"; that conclusion does not
hold.

### 22. `backlog` chooses sizes on its own when another skill calls it

`backlog/SKILL.md:35` says to propose effort and utility and write the file
once the user confirms. When another skill hands over an item in the middle
of its work, the model skips the confirmation.

Likelihood: high. Impact: medium, because unchecked sizes decide the ranking
(finding 3).

Evidence: confirmed in kh-finder, observation 3. Twice in `68ef4750` it wrote
and committed items with sizes it chose, then said the developer had not
confirmed them. Started directly, it asked first. This replaces the first
version of this finding, which feared the opposite: too many confirmations.

## Low impact, mostly the developer's attention

### 23. Nobody checks accessibility

`try-change` never uses the software with a keyboard alone, checks contrast,
or uses a screen reader.

Likelihood: high. Impact: low to medium.

Evidence: none yet.

### 24. A new project means a long row of questions

One decision at a time, with mock-ups (`design-change/SKILL.md:41`), means
many rounds in a new project: stack, design system, data, hosting, login. A
tired developer starts accepting whatever is recommended.

Likelihood: medium. Impact: low to medium.

Evidence: none yet. kh-finder was an existing project.

### 25. Three approaches even for a sharp request

"Offer at least three approaches" (`understand-change/SKILL.md:26`) works
against "Match the depth to the request" (`:12`). The model pads with weak
options.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 26. Every failed try goes back to `understand-change`

`build-change/SKILL.md:45` sends every failure back to `/understand-change`,
even a plain bug.

Likelihood: medium. Impact: low.

Evidence: none yet.

### 27. The setup skill installs every preferred library

The model may add TanStack Query and Mantine before anything needs them
(`nextjs-project-setup/SKILL.md:18-25`). The manifesto says every feature has
to earn its place.

Likelihood: medium. Impact: low.

Evidence: none yet.

## Found in the kh-finder run

### 28. `understand-change` does not start on an open request

Its description (`understand-change/SKILL.md:3`) names ideas, wishes and
problems, and phrases such as "let's think this through". A request like
"question every assumption and write a roadmap" matches none of them.

Likelihood: medium. Impact: medium, because the change starts from a premise
nobody questioned.

Evidence: kh-finder, observation 7. The agent agreed with the premise and put
a feeling, a migration and a feature into one change file. Once the skill
ran, asking what prompted the request found the real problem.

### 29. `learn-from-sessions` loses its work when a run ends early

It shows the findings and asks the developer what to apply
(`learn-from-sessions/SKILL.md:62`). Only after the answer does it write
anything down or mark sessions as read.

Likelihood: medium. Impact: low, but a whole run's reading is lost.

Evidence: kh-finder, observation 9. A run read 11 sessions, asked, got no
answer, and the next run had to read them all again.
