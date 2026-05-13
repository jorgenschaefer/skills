---
name: refactor-design
description: Use this skill when the user wants a comprehensive structural review of a codebase — not a targeted fix for a specific bug or feature, but a survey of where the architecture is creating friction. Produces a Refactoring Proposal that feeds directly into the planning phase. Trigger when the user says things like "the codebase is getting hard to change", "clean up the architecture", "do a structural review", "improve our module boundaries", or asks to improve maintainability project-wide. Do NOT use for feature design (use the design skill) or for reviewing a specific recent change (use implementation-tdd-review).
---

# Refactor Design

## Goal

Make the codebase easy to change and easy to reason about. Read [architecture-principles.md](architecture-principles.md) for the three structural principles guiding proposals: screaming architecture (domain-first organization), deep modules (Ousterhout), and adapter boundaries (clear business logic). Use these definitions when identifying friction points and proposing refactorings.

## Before starting

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Any proposed module names, entity names, or renames in the refactoring proposal should use the canonical terms — not synonyms or paraphrases.

## Process

### 0. Read ARCHITECTURE.md

Before exploring, read [`ARCHITECTURE.md`](ARCHITECTURE.md) at the project root if it exists. Note any constraints that limit what can be refactored — a proposed refactoring that would contradict an established constraint must either be dropped or propose updating `ARCHITECTURE.md` with explicit reasoning confirmed by the user.

### 1. Explore the codebase

Explore the codebase directly using your read, search, and grep tools. Use these questions to guide your attention — they name the patterns most likely to cause long-term friction. Don't treat them as an exhaustive checklist; if you encounter friction not on this list, note it.

- Where does understanding one concept require bouncing between many small files?
- Where is business logic hidden behind framework or database adaption code?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Which parts of the codebase are untested, or hard to test?

Document each friction point as you encounter it: note the file or module, the pattern creating friction, and why it makes the code hard to change or understand. These notes become the "Friction points found" section of the proposal.

If the survey surfaced incidental findings outside the scope of this refactoring, hand them off via the `Agent` tool (`subagent_type: "general-purpose"`) with this self-contained prompt:

> Invoke the `boy-scout` skill. The following incidental findings were noticed during a `refactor-design` survey for feature slug `<slug>`:
>
> `<paste the list of findings here, one per line, each with file path and description>`
>
> Triage each finding: apply trivially safe fixes immediately; write a ticket at `docs/features/boy-scout/tickets/` for everything else. The `Noticed during` field should read: "refactor-design survey for `<slug>`".

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

If this proposal introduces renamed modules, renamed entities, or new canonical names, create `docs/features/<slug>/tickets/lang-update.md` (create the directory if needed). The ticket goal is to update `UBIQUITOUS_LANGUAGE.md` with the proposed name changes; include each name change and its definition in the acceptance criteria, following [ubiquitous-language-update.md](ubiquitous-language-update.md). Use these headers: **Status:** Backlog, **Entry artifact:** this refactoring proposal, **Depends on:** none, **Estimate:** S.

Then run an automated review via the `Agent` tool (`subagent_type: "general-purpose"`) with this self-contained prompt:

> Invoke the `refactor-design-review` skill for feature slug `<slug>`. The Refactoring Proposal is at `docs/features/<slug>/refactoring.md`.

After the review agent finishes, list `docs/features/<slug>/` and open the newest `refactor-design-review-*.md` file (the one just created). Update the Refactoring Proposal to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the proposal
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment

If any findings were at Blocker severity, run the automated review once more after addressing them (same subagent prompt above) — a self-corrected blocker should be verified by a fresh review pass.

Tell the user what the review found, what was addressed, and the final verdict. If the final verdict is Approve or Approve with comments, suggest the planning phase as the next step — run the `planning` skill with the same feature slug to break the Refactoring Proposal into tickets. If the final verdict is Block or Request changes, surface the remaining findings and ask the user how to proceed — do not suggest advancing to planning.
