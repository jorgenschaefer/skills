---
name: find-criteria
description: Work out with the user what a change has to do - its acceptance criteria, the approach they pick from real alternatives, the technical decisions and the implementation nudges - until nothing is left to ask, and write it to CRITERIA.md.
disable-model-invocation: true
---

# Find the criteria

Work out with the user what the change has to do, until every question is settled and whoever slices it into work would not have to ask anything.

This skill's `CRITERIA_FORMAT.md` settles the shape of the file.

## Start from the problem

**Take the problem statement from the conversation** or the argument of the skill.

**Where there is none, and none is visible behind the request, run `/idea` first** - the rules for the problem live there - and carry on here once it has ended.

**Where the change is trivial and the problem plain from the request**, state the problem in a sentence and get a yes - "unless you object" is not one.

**Do not reopen the problem once it is agreed.** Where you become convinced it is wrong, say so plainly and stop - that is a route back to `/idea`, not something to design around.

## The loop

**Read the codebase first**: what is already there, what the project calls things, what it decided before.

**Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one.

**Build a specimen where the difference is visual.** Publish it as a Claude Artifact, and keep a copy in `specimens/` in the change's directory - `changes/YYYY-MM-DD-<slug>/specimens/`, made now if it is not there. Once the choice is made, `specimens/` holds the agreed specimen and nothing else.

**Work out the criteria.** Each AC is observable and checkable true or false. Hold every one against a solution nobody thought of: where that solution would solve the problem and still fail the AC, the AC is a mechanism in disguise.

**For anything a user sees, ask about**: the feedback after every action, actions that cannot be undone, the layout at the narrowest and widest supported screen, and how prominent rarely used actions are.

**Settle the four technical decisions** `CRITERIA_FORMAT.md` names - stored formats, wire formats, trust boundaries, dependencies - from the approach and the code it touches. They are approved like the ACs, and so is an answer of "none". Where one is a choice between alternatives, it is put like any other.

**Raise the implementation decisions the approach makes visible as nudges** - "reuse the phone components", "do not touch DeviceView". What the product does is for the user to approve; how it is built is for them to see, with the chance to object. A nudge never restates `CODING_STANDARDS.md`; `/criteria-to-tickets` plans against the standard directly.

**Give every new domain rule one home.** Where the criteria introduce a rule - a sign, a status, a classification - a nudge names the one place it lives, named after the rule.

**Ask the user to name each new feature directory that is a domain concept**, where `UBIQUITOUS_LANGUAGE.md` has no term for it. On their answer, add it to the glossary where the project has one, in the shape its existing entries have.

**In a repository with no code yet, settle the conventions as nudges**: the directory layout, the layers, how errors reach the caller, where data is loaded, where the clock is read.

**Settle every open question.** Each one ends as an AC, a technical decision, a nudge, a ruled-out line, or explicitly out of scope. None survives into the file, and none is settled by guessing what only the user knows - where they are, who uses the thing.

**The loop is done when every AC, technical decision and nudge can be written so that `/criteria-to-tickets` would not have to ask anything.**

## Approval, then the adversary, then approval

1. **Show every AC, technical decision and nudge and ask whether this is right.** A no sends you back into the loop.
2. **Write `CRITERIA.md`** in the change's directory, in `CRITERIA_FORMAT.md`'s shape.
3. **Check it.** Spawn a subagent with a fresh context and give it three things: `VERIFY.md` and `CRITERIA_FORMAT.md` from this directory, and the path to `CRITERIA.md`. Nothing else - an adversary holding the conversation will read your intentions into the words.
4. **Work its findings into the file, then show only what changed and ask again.** Where it found nothing, say so and ask for the final yes.

## ADRs

A decision made here that this skill's `ADR_FORMAT.md` says earns an ADR is put to the user with a recommendation. On a yes, write it to `docs/adr/` in that file's shape, now, while the argument for it is in front of you.

## Throughout

**Every time you put alternatives for what the change does or how it is built to the user, give each its effort and the complexity it adds to the code, next to what it gives** - the approach, the variants in a specimen, and any such choice that comes up later in the loop. Effort is a size from XS to XL. Complexity is a few words naming what it adds - "a migration for entries and versions" - not a size. A yes/no question is not such a choice: approving the ACs, technical decisions and nudges, an ADR, an objection to a nudge.

**End your turn at the first question mark.** One turn, one open question.

**Push back once.** A decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** Say that `/criteria-to-tickets` is what turns them into work - name it, because it will not find its own way in - and leave going on to them to ask for.
