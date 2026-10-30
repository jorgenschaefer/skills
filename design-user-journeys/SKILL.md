---
name: design-user-journeys
description: Work out with the user how the software should change to solve an agreed problem - the user journeys it affects, walked step by step with real alternatives and a prototype where seeing helps - until nothing is left to ask, and write the journeys and CHANGE.md.
disable-model-invocation: true
---

# Design the user journeys

Work out with the user how the software should change, by walking the user journeys it affects, until whoever builds it would not have to ask anything.

This skill's `JOURNEY_FORMAT.md` and `CHANGE_FORMAT.md` settle the shape of the files.

## Start from the problem

**Take the problem statement from the conversation** or the argument of the skill.

**Where there is none, and none is visible behind the request, run `/idea` first**, and carry on here once it has ended.

**Where the change is trivial and the problem plain from the request**, state the problem in a sentence and get a yes - "unless you object" is not one.

**Do not reopen the problem once it is agreed.** Where you become convinced it is wrong, say so plainly and stop - that is a route back to `/idea`, not something to design around.

## Find the journeys

**Read the codebase and `journeys/` first**: what is already there, what the project calls things, and who can do what today.

**List the journeys this change affects**, existing and new, and show them to the user.

**Where the software already does something the change affects and no journey describes it, write that journey first**, from what the software does today: read the code, and run the software where you can. Show it and get the user's confirmation that it is right before you change it. It describes the software as it is, so a wrong one is corrected here, not designed around.

## Walk the journeys

**Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one.

**Walk each journey step by step with the user**: what they do, what they see, how it feels. Offer alternatives at each step where there are real ones.

**Build a prototype where seeing a step says more than describing it.** A rough one they can click through: publish it as a Claude Artifact, and keep a copy in `prototype/` in the change's directory - `changes/YYYY-MM-DD-<slug>/prototype/`, made now if it is not there. Once the design is agreed, `prototype/` holds the agreed prototype and nothing else.

**For every step, ask what can go wrong** and what the user sees then. Each answer goes under "When it goes wrong".

**For every journey, ask who goes through it.** "Who" is what grants access: everything no journey gives someone is denied. Show each journey the change opens to someone who could not do it before, and each one it takes away, and get a yes for each.

**For anything a user sees, ask about**: the feedback after every action, actions that cannot be undone, the layout at the narrowest and widest supported screen, and how prominent rarely used actions are.

**Ask which details of the design must last.** One that must becomes something the user sees in a journey step, so it gets a test. The rest holds for this change only.

**Use the user's words.** A new thing gets its name from the user, and the journeys and the design use that name.

**Do not put details of the code to the user** - tables, columns, files, modules, ideas for how to build it. They are the builder's.

**Settle every open question.** Each one ends in a journey, in the design, or under "Not in this change". None is settled by guessing what only the user knows.

**The walk is done when the journeys and the design can be written so that a builder would not have to ask anything.**

## Approval, then the adversary, then approval

1. **Show each journey the change affects as it will read afterwards, and the design, and ask whether this is right.** A no sends you back into the walk.
2. **Make the change's branch**, named after the change's directory, `YYYY-MM-DD-<slug>`, unless you are on it. **Write the files there**: the journeys in `journeys/`, in `JOURNEY_FORMAT.md`'s shape, and `CHANGE.md` in the change's directory, in `CHANGE_FORMAT.md`'s shape. Where the change came from a backlog item, `CHANGE.md`'s Problem names its path.
3. **Check them.** Spawn a subagent with a fresh context and give it `VERIFY.md`, `JOURNEY_FORMAT.md` and `CHANGE_FORMAT.md` from this directory, and the path to the change's directory. Nothing else - an adversary holding the conversation will read your intentions into the words.
4. **Work its findings into the files, then show only what changed and ask again.** Where it found nothing, say so and ask for the final yes.
5. **Commit** the journeys, `CHANGE.md` and `prototype/` together.

## Throughout

**Every time you put alternatives to the user, give each its effort and the complexity it adds, next to what it gives, then recommend one and say why.** Effort is a size from XS to XL. Complexity is a few words naming what it adds - "a second kind of invoice" - not a size. A yes/no question is not such a choice.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the user says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** Say that `./run.sh changes/YYYY-MM-DD-<slug>` builds the change with nobody watching, and splits it first where it is too big for one agent to build within one context. Leave going on to the user to ask for.
