---
name: create-spec
description: Work out the design of a change with the developer, from the agreed problem in intent.md - the user journeys, and the domain and the screens where the change needs them - cut down to what the one real instance needs, and write spec.md on the change's own branch. Use after /idea, and on "design this change", "write the spec".
disable-model-invocation: true
---

# Create a spec

Work out with the developer what the software will do once the change is built, and write it into `spec.md`: the smallest design that solves the problem in `intent.md`, so that whoever plans the build would not have to ask anything.

This skill's `SPEC_FORMAT.md` settles the shape of `spec.md`, `JOURNEY_FORMAT.md` the shape of a journey, and `INTENT_FORMAT.md` the shape of `intent.md`.

## Start from the problem

**Take the backlog item that holds the agreed problem**, in `INTENT_FORMAT.md`'s headings: the one named in the argument, or the one `/idea` just wrote. Where there is none, run `/idea` first, and carry on here once it has ended.

**Do not reopen the problem.** It was agreed. Where you become convinced it is wrong, say so plainly and stop: that is a route back to `/idea`, not something to design around.

**Make the change's branch now**, from main, named after the change's directory, `YYYY-MM-DD-<slug>`, unless you are on it. Everything the design writes goes onto it.

## Decide which parts the design needs

Read the code, `journeys/`, and `UBIQUITOUS_LANGUAGE.md` where the project has one. Then propose which parts the change needs, and get the developer's yes:

- **The journeys**, with `/design-user-journeys`, where the change affects who uses the software or what for.
- **The domain**, with `/design-domain`, where the change adds or changes what the software keeps, or the rules about it.
- **The frontend**, with `/design-frontend`, where the change adds or changes what a user sees.

A change with no new screens and no new data may need the journeys only; a change to a rule may need only the domain; a new app needs all three.

**Use them in that order**, the journeys first, because the other two build on them. Give each the problem from the backlog item, the change's directory, and what the parts before it agreed. Each writes its own files onto the branch - the journeys in `journeys/`, the prototype in `prototype/`, the glossary - and hands the agreed design back to you.

**Where two parts pull against each other**, such as a screen that needs something the domain does not keep, show the conflict with both sides, and the developer decides.

## Cut it down to the instance

**Hold every part of the design against the instance in `intent.md`**: what does the one real instance need?

**Propose the design as two lists**, "needed for the instance" and "could wait", one line per item. The developer agrees or disagrees with each item, and moves items between the lists. Nothing is cut without their yes. An item that waits comes out of the journeys and the prototype too.

**A failure case goes in only if it would really happen to this user.** Each costs a test, a walk and usually a fix. For each one that earns its place, agree with the developer what the user sees and what happens to their work, in `SPEC_FORMAT.md`'s shape.

**List the constraints**: what must stay true, from `intent.md`, and the limits on the solutions the design found. Each is one statement with one condition, how the design meets it, and how that is checked.

## Throughout

**At every decision, the simplest option comes first, and is called the simplest.** Give each option its effort and the complexity it adds, next to what it gives, then recommend one and say why. Effort is a size from XS to XL. Complexity is a few words naming what it adds, not a size.

**Do not put details of the code to the developer** - tables, files, modules, libraries. Those are `create-plan`'s.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the developer says before following it.** For each answer, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

## Write it, check it, get the yes

1. **Move the backlog item into the change** with `git mv changes/backlog/<slug>.md changes/YYYY-MM-DD-<slug>/intent.md`, and drop its frontmatter. **Write `spec.md`** beside it, in `SPEC_FORMAT.md`'s shape, from the list "needed for the instance". Show it, with each journey as it will read afterwards, and ask whether this is right. A no sends you back into the design.
2. **Check it.** Spawn a subagent with a fresh context and give it `VERIFY.md`, `SPEC_FORMAT.md`, `JOURNEY_FORMAT.md` and `INTENT_FORMAT.md` from this directory, and the path of the change's directory. Nothing else - an adversary holding the conversation will read your intentions into the words.
3. **Work its findings into the files**, then show only what changed and ask for the final yes. Where it found nothing, say so and ask for the final yes. A finding in a journey, the prototype or the glossary is fixed with the skill that wrote it.
4. **Write each item that could wait to the backlog** with `/backlog`, and tell it you commit the item. Each item holds the parts of `intent.md` it rests on, usually Problem and Outcome, under the same headings, and one line naming this change. Name its path under "Not in this change" in `spec.md`.
5. **Commit it all together** on the change's branch: `intent.md` with its move, `spec.md`, the journeys, `prototype/`, the glossary and the new backlog items.

**Stopping here is an ending.** Say that `/create-plan` plans the build from `spec.md` and puts its hard decisions to the developer, and that `run.sh` then builds it with nobody watching. Leave going on to the developer to ask for.
