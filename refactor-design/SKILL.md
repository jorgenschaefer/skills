---
name: refactor-design
description: Use this skill when the user wants a comprehensive structural review of a codebase — not a targeted fix for a specific bug or feature, but a survey of where the architecture is creating friction. Produces a Refactoring Proposal that feeds directly into the planning phase. Trigger when the user says things like "the codebase is getting hard to change", "clean up the architecture", "do a structural review", "improve our module boundaries", or asks to improve maintainability project-wide. Do NOT use for feature design (use the design skill) or for reviewing a specific recent change (use implementation-review).
---

# Refactor Design

## Goal

Your goal is to make the code base easy to change and easy to reason about. Read [architecture-principles.md](architecture-principles.md) for the three structural principles this skill proposes improvements toward: screaming architecture (domain-first organization), deep modules (Ousterhout), and adapter boundaries (clear business logic). Use these definitions when identifying friction points and proposing refactorings.

## Before starting

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Any proposed module names, entity names, or renames in the refactoring proposal should use the canonical terms — not synonyms or paraphrases.

## Process

### 0. Read existing ADRs

Before exploring, read all ADRs in `docs/adr/` if they exist. Note any architectural decisions that constrain what can be refactored — a proposed refactoring that would contradict an accepted ADR must either be dropped or argue explicitly for an ADR supersession.

### 1. Explore the codebase

Explore the codebase directly using your read, search, and grep tools. Use these questions to guide your attention — they name the patterns most likely to cause long-term friction. Don't treat them as an exhaustive checklist; if you encounter friction not on this list, note it.

- Where does understanding one concept require bouncing between many small files?
- Where is business logic hidden behind framework or database adaption code?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

Document each friction point as you encounter it: note the file or module, the pattern creating friction, and why it makes the code hard to change or understand. These notes become the "Friction points found" section of the proposal.

If the survey surfaced incidental code smells, bugs, or misleading names outside the scope of this refactoring, invoke the `boy-scout` skill to triage them: trivially safe fixes can be applied immediately; everything else becomes a ticket in `docs/features/boy-scout/tickets/`.

### 2. Propose a refactoring plan

Save the proposal to `docs/features/<slug>/refactoring.md`. If the target directory doesn't exist, create it. If you can't write the file, tell the user the artifact path and paste the content inline so they can save it manually.

Use this structure:

```markdown
# Refactoring Proposal: <project or area>

**Date:** <YYYY-MM-DD>

## Summary
One paragraph: the headline finding — what kind of friction dominates?

## Friction points found
A list of specific locations with notes on what makes each one hard to change or understand.

## Proposed refactorings
For each proposed refactoring:
- **What:** the specific change (rename, move, merge, split, add boundary)
- **Why:** what friction it removes
- **Impact:** how much code is affected; how risky
- **Approach:** a starting point for implementation
- **Priority:** High / Medium / Low — estimated by impact (how much friction removed) × inverse effort (lower effort = higher priority)

## Suggested order
Which refactorings to do first and why. High-impact, low-effort changes should generally come first.

## Scope decisions
Things examined during exploration that were deliberately not included in the proposal, and why. This prevents future confusion about whether issues were missed or consciously deferred.
```

Do not implement any refactoring in this skill. The output is a proposal; implementation follows the normal ticket workflow. If the user asks you to implement, redirect: create tickets for the highest-priority refactorings using the planning skill instead.

Tell the user what was found and where the proposal lives.

Then run an automated review in a clean context. Use the `Agent` tool with `subagent_type: "general-purpose"` so the review agent has no memory of this conversation — this gives the proposal fresh eyes. The agent's self-contained prompt should be:

> Invoke the `refactor-design-review` skill for feature slug `<slug>`. The Refactoring Proposal is at `docs/features/<slug>/refactoring.md`.

After the review agent finishes, read the review file it saved at `docs/features/<slug>/refactor-design-review-<NN>.md`. Update the Refactoring Proposal to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the proposal
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment

Tell the user what the review found, what was addressed, and the final verdict. Then suggest the next step is the planning phase — run the `planning` skill with the same feature slug to break the Refactoring Proposal into tickets.
