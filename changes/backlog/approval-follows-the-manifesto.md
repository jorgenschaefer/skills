---
effort: L
utility: L
---

# The human approves what the manifesto lists, and nothing else

What `/find-criteria` puts before the developer does not match what
`MANIFESTO.md` says they approve: the bold items in its developer lines.
Some of what they must judge is out of reach for someone who does not read
the code, and some of what they answer for is never asked.
`CLAUDE.md`: the developer sees "what the manifesto puts in bold".

Agreed with `/idea` on 2026-10-27:

Before a change is built, the developer approves its behaviour and its
technical decisions. But four decisions the manifesto gives them are never
put to them: what the user experiences when something fails, what
production must show and how fast, what the system keeps and for how long
and what it never keeps, and whether to make a change that discards
information. An agent settles these alone, or they come up only after the
build. Instead, each of these is put to the developer before the build, in
words they can judge without reading the code. The developer decides it,
or decides that it doesn't apply.

Instance: no failure. The manifesto rewrite (23c6504) gave the developer
these decisions, and `find-criteria` was not updated with it.
`find-criteria/CRITERIA_FORMAT.md:26-29` and `find-criteria/SKILL.md:33`
ask none of them, and retention appears nowhere in the repo.

Parked: what isn't the developer's is put to them, and the security policy
is mixed with implementation in Trust boundaries (the sections below on
the four technical decisions and on implementation). Since 62b33a0, showing
the developer more than the manifesto requires is allowed, so what is left
is asking them to decide things that are not theirs.

## The four technical decisions are the wrong four

- **Stored formats** asks for "the tables, columns, files and keys"
  (`find-criteria/CRITERIA_FORMAT.md:27`). The manifesto asks for the
  information model: "what the system keeps, logs and traces included, for
  how long, and what it never keeps." How it is stored is not the
  developer's to decide: "They decide what the software does and who may do
  what." Retention and never-keep appear nowhere in the repo.
- **Trust boundaries** (`:29`) mixes policy with implementation - new input,
  outgoing calls. The manifesto asks for the security policy: who may see
  and do what.
- **Dependencies** approves every library, "none" included. The manifesto
  approves hard-to-reverse decisions in general: "a change that discards
  information, a dependency the codebase gets built around". The developer
  only "sees each new dependency with what it gives and costs". The repo has
  no such category before implementation; "costly to reverse" shows up only
  afterwards, in Left standing.
- README.md:60 gives the reason for the four as "mistakes land outside the
  repository", which is not the manifesto's reason.

## Implementation is put in front of the human

- Nudges: "how it is built is for them to see, with the chance to object"
  (`find-criteria/SKILL.md:37`). The manifesto rules this out. Of the
  developer it says: "They decide what the software does and who may do
  what." How the code is built is neither. The conventions of a new
  repository - layout, layers, error flow - settled with the user as nudges
  (`:43`).
- Naming feature directories (`:41`). Asking the user for the term for a new
  concept fits the manifesto (the developer "agrees with the user on the
  concepts"); framing it as a directory does not.
- `/accept-criteria` takes every departure from a nudge one at a time with
  the user, and shows precedents and declared boundaries
  (`accept-criteria/SKILL.md:48-53`). A weakened structural check does belong
  in front of the human: the manifesto calls weakening a check a decision.

## Failure cases are not part of the consultation

The manifesto's Utility goal: the developer approves the behaviour
"failure cases included".
`find-criteria/SKILL.md:33` asks about feedback, undo, layout and prominence,
not about what the user experiences when something fails; neither does
`find-criteria/VERIFY.md`.

## What production must show is never asked

The manifesto's Utility goal: the developer decides "what production must
show: what someone has to hear about, and how fast. That means errors, but
also a sudden drop in users or a flood of login attempts"
(`MANIFESTO.md:32`). Neither `find-criteria` nor `CRITERIA_FORMAT.md` asks
about it.

Touches: both `CRITERIA_FORMAT.md` copies, `find-criteria` and its
`VERIFY.md`, `TICKET_FORMAT.md` and `criteria-to-tickets`, `run/drift.sh`
(it checks that nudges and technical decisions are quoted word for word),
`run/prompts.sh`, `accept-criteria` and `signals.sh`, README, and the
tests over the runner.
