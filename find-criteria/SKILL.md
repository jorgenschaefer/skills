---
name: find-criteria
description: Work out with the user what a change has to do - its acceptance criteria, the approach they pick from real alternatives, and the implementation nudges - until nothing is left to ask, and write it to CRITERIA.md. Typed, not inferred.
disable-model-invocation: true
---

# Find the criteria

Work out with the user what the change has to do, until every question is settled and whoever slices it into work would not have to ask anything.

This skill's `CRITERIA_FORMAT.md` settles the shape of the file.

## Start from the problem

**Take the problem statement from the conversation** or the argument of the skill.

**Where there is none, and none is visible behind the request, run `/idea` first** and carry on here once it has ended. The problem comes first, and its rules live in that one skill.

**Where the change is trivial and the problem plain from the request**, state the problem in a sentence and get a yes.

**Do not reopen the problem once it is agreed.** Where you become convinced it is wrong, say so plainly and stop - that is a route back to `/idea`, not something to design around.

## The loop

**Read the codebase first**: what is already there, what the project calls things, what it decided before. The alternatives and what they cost rest on it.

**Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one.

**Build a specimen where the difference is visual.** Publish it as a Claude Artifact, and keep a copy in `specimens/` in the change's directory - `changes/YYYY-MM-DD-<slug>/specimens/`, made now if it is not there. Once the choice is made, `specimens/` holds the agreed specimen and nothing else.

**Work out the criteria.** Each AC is observable and checkable true or false. Hold every one against a solution nobody thought of: where that solution would solve the problem and still fail the AC, the AC is a mechanism in disguise.

**For anything a user sees, ask about**: the feedback after every action, actions that cannot be undone, the layout at the narrowest and widest supported screen, and how prominent rarely used actions are. These are what slipped through when nobody asked.

**Raise the implementation decisions the approach makes visible as nudges** - "reuse the phone components", "do not touch DeviceView". What the product does is for the user to approve; how it is built is for them to see, with the chance to object.

**Settle every open question.** Each one ends as an AC, a nudge, a ruled-out line, or explicitly out of scope. None survives into the file.

**The loop is done when every AC and nudge can be written so that `/criteria-to-tickets` would not have to ask anything.**

## Approval, then the adversary, then approval

1. **Show every AC and nudge and ask whether this is right.** A no sends you back into the loop.
2. **Write `CRITERIA.md`** in the change's directory, in `CRITERIA_FORMAT.md`'s shape.
3. **Check it.** Spawn a subagent with a fresh context and give it three things: `VERIFY.md` and `CRITERIA_FORMAT.md` from this directory, and the path to `CRITERIA.md`. Nothing else - an adversary holding the conversation will read your intentions into the words.
4. **Work its findings into the file, then show only what changed and ask again.** Where it found nothing, say so and ask for the final yes.

## ADRs

A decision made here that this skill's `ADR_FORMAT.md` says earns an ADR is put to the user with a recommendation. On a yes, write it to `docs/adr/` in that file's shape, now, while the argument for it is in front of you.

## Throughout

**Every time you put alternatives for what the change does or how it is built to the user, give each its effort and the complexity it adds to the code, next to what it gives** - the approach, the variants in a specimen, and any such choice that comes up later in the loop. Effort is a size from XS to XL. Complexity is a few words naming what it adds - "a migration for entries and versions" - not a size. A yes/no question is not such a choice: approving the ACs and nudges, an ADR, an objection to a nudge.

**End your turn at the first question mark.** One turn, one open question.

**Push back once.** A decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** Criteria agreed and not built are a whole use of this skill. Say that `/criteria-to-tickets` is what turns them into work - name it, because it will not find its own way in - and leave going on to them to ask for.
