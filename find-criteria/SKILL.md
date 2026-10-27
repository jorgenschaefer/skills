---
name: find-criteria
description: Work out with the user what a change has to do - its acceptance criteria, the approach they pick from real alternatives, and the technical decisions - until nothing is left to ask, and write it to CRITERIA.md.
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

**Read the codebase first**: what is already there, what the project calls things, what it decided before, and who may see and do what in `SECURITY_POLICY.md`.

**Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one.

**Build a specimen where the difference is visual.** Publish it as a Claude Artifact, and keep a copy in `specimens/` in the change's directory - `changes/YYYY-MM-DD-<slug>/specimens/`, made now if it is not there. Once the choice is made, `specimens/` holds the agreed specimen and nothing else.

**Work out the criteria.** Each AC is observable and checkable true or false, in words the developer can judge without reading the code. Hold every one against a solution nobody thought of: where that solution would solve the problem and still fail the AC, the AC is a mechanism in disguise.

**For every behaviour, ask what the user experiences when it fails**, and write the answer as an AC beside it.

**Ask about the other three groups** `CRITERIA_FORMAT.md` names: what production must show and how fast, who may see and do what, and what the system keeps, for how long, and never keeps. Each ends as ACs, or as "None." where the developer decides nothing there applies.

**Before asking who may see and do what, show the rules the change touches** - those for the things it adds to or changes, and for what a new way in would expose - as they stand in `SECURITY_POLICY.md`. Each Security policy AC is then a rule worded as it will stand in the policy, or a rule as it stands today that the change removes, as this skill's `SECURITY_POLICY_FORMAT.md` says. Where the project has no `SECURITY_POLICY.md`, say in one line that it has none and that `/init-security-policy` creates one, and ask as before.

**For anything a user sees, ask about**: the feedback after every action, actions that cannot be undone, the layout at the narrowest and widest supported screen, and how prominent rarely used actions are.

**Settle the three technical decisions** `CRITERIA_FORMAT.md` names - concepts, wire formats, hard to reverse - from the approach and the code it touches. They are approved like the ACs, and so is an answer of "none". Where one is a choice between alternatives, it is put like any other.

**Agree a term for each new concept** with the developer, under Concepts, where `UBIQUITOUS_LANGUAGE.md` has none. On their answer, add it to the glossary where the project has one, in the shape its existing entries have.

**Do not put details of the code to the developer** - tables, columns, file or directory names, a repository's layout or layers, ideas for how to build it. They are the builder's, held to `CODING_STANDARDS.md`. The developer still picks the approach from the alternatives and approves the agreed design.

**Settle every open question.** Each one ends as an AC, a technical decision, a ruled-out line, or explicitly out of scope. None survives into the file, and none is settled by guessing what only the user knows - where they are, who uses the thing.

**The loop is done when every AC and technical decision can be written so that `/criteria-to-tickets` would not have to ask anything.**

## Approval, then the adversary, then approval

1. **Show every AC and technical decision and ask whether this is right.** A no sends you back into the loop.
2. **Write `CRITERIA.md`** in the change's directory, in `CRITERIA_FORMAT.md`'s shape.
3. **Check it.** Spawn a subagent with a fresh context and give it three things: `VERIFY.md` and `CRITERIA_FORMAT.md` from this directory, and the path to `CRITERIA.md`. Nothing else - an adversary holding the conversation will read your intentions into the words.
4. **Work its findings into the file, then show only what changed and ask again.** Where it found nothing, say so and ask for the final yes.

## ADRs

A decision made here that this skill's `ADR_FORMAT.md` says earns an ADR is put to the user with a recommendation. On a yes, write it to `docs/adr/` in that file's shape, now, while the argument for it is in front of you.

## Throughout

**Every time you put alternatives for what the change does or how it is built to the user, give each its effort and the complexity it adds to the code, next to what it gives** - the approach, the variants in a specimen, and any such choice that comes up later in the loop. Effort is a size from XS to XL. Complexity is a few words naming what it adds - "a migration for entries and versions" - not a size. A yes/no question is not such a choice: approving the ACs and technical decisions, or an ADR.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the user says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** Say that `/criteria-to-tickets` is what turns them into work - name it, because it will not find its own way in - and leave going on to them to ask for.
