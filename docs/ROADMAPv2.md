# Roadmap v2

Where the skills, as written today, lead a model to work against
`docs/manifesto.md`. Each finding names what the model will do, where in a
skill that comes from, and two ratings.

- **Likelihood**: how likely a model is to do this when it follows the skill.
- **Impact**: how much harm it does, measured as the manifesto measures it:
  by how hard it is to undo.

Only finding 1 rests on evidence so far (observation 5 in
`docs/evidence/2026-11-05-workout-logbook.md`). The others come from reading
the skills. `docs/roadmap.md` says every change to a skill needs evidence, so
treat them as things to watch in the next test run, not as changes to make
now.

## What to fix first

Findings 1, 2 and 3. Together they turn most security findings into problems
nobody acts on: the builder decides alone, small changes are never checked,
and what the check finds sinks in the backlog.

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

## High likelihood, high impact

### 1. The builder decides hard-to-undo things alone

`build-change/SKILL.md:19` says only "Build the smallest thing that does the
job". Nothing tells the builder to stop and run `/design-change` when a
decision is hard to undo. Observation 5 shows this happening. Roadmap step 5
is still open. `review-change` reports such decisions, but only after they
are built.

Likelihood: high. Impact: high.

### 2. Small changes skip the check

When `design-change` finds nothing that matters, it says "say so in one line
and carry on. There is nothing to record: no branch, no change file, no
commit" (`design-change/SKILL.md:35`). But `build-change` needs a change
file, and the model cannot start it on its own (`disable-model-invocation`).
So "carry on" means a plain build in the same session: no fresh review, no
`try-change`, and the commits go to `main`. Workflow step 1 sends every clear,
small change this way. It also conflicts with "Then stop" (`:89-91`).

Likelihood: high. Impact: medium to high.

### 3. The backlog ranks security fixes low

The backlog ranks items by utility minus effort, and utility is "what it
gives the user" (`backlog/SKILL.md:23,40`). A security fix that
`review-change` or `upgrade-dependencies` hands over gives the user nothing
they can see, so it gets a low utility and sinks. The manifesto puts security
second, above usability.

Likelihood: high. Impact: high.

### 4. `upgrade-dependencies` ignores known vulnerabilities

There is no `npm audit`, and nothing puts security fixes first. If the fix
for a known vulnerability is a major version that turns the checks red, the
skill reverts it and hands it to the backlog like any other upgrade
(`upgrade-dependencies/SKILL.md:56-66`). Finding 3 then buries it.

Likelihood: high. Impact: high.

## Medium likelihood, high impact

### 5. The builder can drop review findings without a trace

`build-change/SKILL.md:30` says "Fix what they found". The report shows only
what is "for the developer" and what could not be fixed, "Not what you fixed"
(`:41`). If the builder decides a finding is wrong, nobody sees it.
`review-change:53` says that findings not fixed go to the backlog, but
`build-change` never says so. And the builder is the author, the one most
likely to dismiss a finding.

Likelihood: medium. Impact: high.

### 6. Tests may reach real services

`review-change/SKILL.md:38` runs throwaway tests, and does not say against
what. `try-change/SKILL.md:22` forbids production, but a local instance still
reads `.env`, which may hold live payment or email keys, or point at a shared
database. To make "the network goes away" or "the server fails" happen
(`try-change:29-34`), the model may stop shared Docker services or change the
network on the developer's machine.

Likelihood: medium. Impact: high.

### 7. Nobody checks the build against the existing ADRs

`build-change/SKILL.md:13` reads only the ADRs the change file links to.
`review-change/SKILL.md:27` compares the code only with the change file. A
build that breaks an older recorded decision passes both. Only
`design-change:31` reads `docs/adr/`, and that is before there is code.

Likelihood: medium. Impact: high.

### 8. "In a small change the list is often empty"

`design-change/SKILL.md:33` tells the model to expect nothing. Add "If you
cannot name a cost, it is not on the list", and a small change slips through
even when it adds an endpoint, an export or a personal-data field. Those are
exactly the decisions about who can see what.

Likelihood: medium. Impact: high.

### 9. A real choice becomes a one-line tell

Asking takes three options that differ in substance, and mock-ups
(`design-change/SKILL.md:41-48`). Telling takes one line. So the model leans
toward "only one sensible option", and "sensible" means its own default.
Tells come as a list of one-liners (`:52-55`), so the developer skims past a
security-relevant one such as "sessions never expire".

Likelihood: medium. Impact: medium to high.

## Low likelihood, high impact

### 10. Upgrades install brand-new releases at once

`upgrade-dependencies` installs the newest versions right away, and their
install scripts run (`upgrade-dependencies/SKILL.md:35,54`). There is no
minimum age for a release, and no look at new transitive dependencies or
install scripts. A compromised release that came out yesterday runs on the
developer's machine.

Likelihood: low. Impact: high.

### 11. The security lens is narrow

The list of risks in `review-change/SKILL.md:29-34` comes from one offline
app. It does not name reading other users' records by changing an ID,
injection, cross-site scripting, secrets that end up in the client bundle, or
a new route that skips the login check. "A start, not the limit" helps, but
the list steers where the model looks. No skill says where secrets live.

Likelihood: low. Impact: high.

## Medium impact

### 12. The change file never says who the user is

The change file has no place for who uses the software, on which device, and
where. `try-change/SKILL.md:22` asks for "the screen size they use it on" but
has nowhere to learn it, so it guesses a desktop. The manifesto says the agent
"has to know what the software is really used for, and by whom".

Likelihood: high. Impact: medium.

### 13. A confirmed bug leaves no test behind

The reviewer deletes its throwaway test (`review-change/SKILL.md:38`), and
`build-change:30` does not ask for a lasting test with the fix. The same bug
can come back with the next change.

Likelihood: high. Impact: medium.

### 14. The builder recommends on its own decisions

`build-change/SKILL.md:38` asks for "what you recommend" on decisions the
builder made alone. It will defend what it already built.

Likelihood: high. Impact: medium.

### 15. Fixes are not tried again

`/review-change` runs again only "if a fix changed the code a lot"
(`build-change/SKILL.md:32`), and the builder decides what "a lot" is.
`try-change` never runs again, so a fix for a usability problem is never
used by a user stand-in.

Likelihood: medium. Impact: medium.

### 16. A decision settled along the way is never written down

"If the developer's answer settles another decision on the list too, don't
ask about that one" (`design-change/SKILL.md:50`). That decision is then
neither told nor asked, so "List every decision you told or asked" (`:74`)
leaves it out. Nothing holds it once the change file is deleted.

Likelihood: medium. Impact: medium.

### 17. `accept-change` adds code after acceptance

"Add what is missing" (`accept-change/SKILL.md:13`) can mean new tests,
structure or ADRs, written after the developer tried the change, with no
review and no try. It can also produce an ADR saying "Decided: by the
developer" for something the developer never decided.

Likelihood: medium. Impact: medium.

### 18. Approaches don't show what they expose

`understand-change/SKILL.md:26` asks what each approach "is good for, and what
it costs", in the terms of the domain. The developer picks a direction, such
as sharing the logbook with a coach, without seeing what it exposes.
`design-change` only ever sees the approach that was picked.

Likelihood: medium. Impact: medium.

### 19. `nextjs-project-setup` and `design-change` both decide the stack

`design-change/SKILL.md:33,48` asks about the stack and the design system,
with three options each. `nextjs-project-setup/SKILL.md:8,18-25` says both are
already decided: Next.js and Mantine. Either the developer is asked what they
already answered, or the setup skill runs first and the stack is chosen
without a word, including hosting, database and login, which the setup skill
does not cover.

Likelihood: medium. Impact: medium.

### 20. `learn-from-sessions` writes project details into a public repository

The evidence files hold project names, paths, session IDs and descriptions of
what happened (`learn-from-sessions/SKILL.md:65`). This repository is public
(`npx skills add jorgenschaefer/skills`). "Don't copy the project's code or
data" does not cover a client's name or confidential details of its domain.
What leaked cannot be unleaked.

Likelihood: medium. Impact: medium.

### 21. "The smallest thing" read as "the least code"

A model may read `build-change/SKILL.md:19` as leave to copy code instead of
sharing it, or to skip validation.

Likelihood: low. Impact: medium.

## Low impact, mostly the developer's attention

### 22. The backlog asks for confirmation item by item

Each item handed over needs the developer to confirm its sizes
(`backlog/SKILL.md:35`). `accept-change`, `review-change` and
`upgrade-dependencies` each hand over several items, one at a time.

Likelihood: high. Impact: low.

### 23. Nobody checks accessibility

`try-change` never uses the software with a keyboard alone, checks contrast,
or uses a screen reader.

Likelihood: high. Impact: low to medium.

### 24. A new project means a long row of questions

One decision at a time, with mock-ups (`design-change/SKILL.md:41`), means
many rounds in a new project: stack, design system, data, hosting, login. A
tired developer starts accepting whatever is recommended.

Likelihood: medium. Impact: low to medium.

### 25. Three approaches even for a sharp request

"Offer at least three approaches" (`understand-change/SKILL.md:26`) works
against "Match the depth to the request" (`:12`). The model pads with weak
options.

Likelihood: medium. Impact: low.

### 26. Every failed try goes back to `understand-change`

`build-change/SKILL.md:45` sends every failure back to `/understand-change`,
even a plain bug.

Likelihood: medium. Impact: low.

### 27. The setup skill installs every preferred library

The model may add TanStack Query and Mantine before anything needs them
(`nextjs-project-setup/SKILL.md:18-25`). The manifesto says every feature has
to earn its place.

Likelihood: medium. Impact: low.
