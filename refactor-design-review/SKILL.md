---
name: refactor-design-review
description: Use this skill to review a Refactoring Proposal produced by the refactor-design skill before it advances to the planning phase. Trigger when the user says things like "review this refactoring proposal", "is this proposal ready for planning", or hands you a refactoring.md file and asks for feedback. Always use a clean context, separate from the conversation that produced the proposal. Output is a structured review file saved at docs/features/<slug>/refactor-design-review-NN.md.
---

# Refactor Design Review

This skill reviews a **Refactoring Proposal** — the artifact produced by the `refactor-design` skill. It builds on the shared review base; read [review-base.md](review-base.md) first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to catch problems in the structural analysis and proposed changes before they cascade into the planning phase — vague friction points produce vague tickets; unacknowledged constraint conflicts produce reverting PRs.

## Setup

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding. Read the Refactoring Proposal from `docs/features/<slug>/refactoring.md`.

Before reviewing, confirm:

1. The artifact follows the `refactor-design` structure: Summary, Friction points found, Proposed refactorings, Suggested order, Scope decisions.
2. You have read [`ARCHITECTURE.md`](ARCHITECTURE.md) at the project root (if it exists; otherwise note it). Constraint compliance is one of the highest-value checks here.
3. You're in a clean context. If unsure, note it in "What was NOT checked" and flag areas where prior context might bias you.

## What to check

Walk through these questions. Each corresponds to a common failure mode of structural proposals at this stage.

### Friction points

- **Are friction points specific?** Each entry should name a concrete file or module, the pattern creating friction (e.g., "business logic lives in the route handler", "module exposes its internal DB schema to callers"), and why it makes the code hard to change or understand. An entry that names a general area ("the user module is a mess") without a specific file and pattern is not actionable — should-fix.
- **Is the consequence stated?** Each friction point should explain why it matters. If missing, the implementer can't prioritize or validate the fix — should-fix unless the consequence is obvious.
- **Are the friction points accurate?** If you have codebase access, spot-check a few: does the described pattern actually appear in the named location? A proposal built on a misidentified problem is worse than no proposal — blocker if a major proposed refactoring rests on a misread.

### Constraint compliance

- **Does any proposed refactoring contradict a constraint in `ARCHITECTURE.md`?** For each established constraint, ask: would this refactoring violate it? A change that breaks a layering convention, removes an enforced pattern, or reorganizes the project against an established architectural constraint is a blocker unless it explicitly proposes updating `ARCHITECTURE.md` with reasoning.
- **Is a contradicting proposal acknowledging the constraint?** A proposal that says "propose updating ARCHITECTURE.md because..." is acceptable if the argument is sound. A proposal that silently violates an established constraint is a blocker.

### Refactoring actionability

- **Can an engineer plan tickets from each proposal?** The `planning` skill will use this proposal as its entry artifact. Each proposed refactoring should give the planner enough to start: what specifically should change, where it lives, what the target state looks like. "Clean up the module" is not actionable; "merge the thin `UserMapper` class into `UserRepository`, which currently delegates every method unchanged" is.
- **Is the approach field meaningful?** Each proposal should include "Approach: a starting point for implementation." If it is generic ("follow best practices", "refactor incrementally") rather than specific to the codebase, it's a should-fix.
- **Is impact assessed?** The proposal should name how much code is affected and estimate risk. Missing impact means the planner can't assess feasibility — should-fix.

### Priority and ordering

- **Is priority justified by impact × inverse effort?** The skill defines High/Medium/Low in terms of friction removed relative to effort. A High priority refactoring that touches most of the codebase without explaining the payoff, or a Low priority item on a large risky change, may be miscalibrated — nit.
- **Does the suggested order follow from priority and dependencies?** If High priority items come later than Medium priority items with no stated reason, or if a proposal depends on another but is ordered before it, that's a should-fix.
- **Are dependencies between refactorings acknowledged?** Some refactorings can't proceed until others land. Unacknowledged ordering dependencies are traps for the planner — should-fix.

### Coverage completeness

- **Are obvious friction areas absent?** Based on the codebase (if accessible) or on the Summary's stated findings, are there expected friction patterns not in the Friction points section? If the Summary says "the main problem is X" and X doesn't appear in the friction list, that's a should-fix.
- **Is the Scope decisions section populated?** This section should list things examined and consciously excluded. An empty scope section means the reader can't distinguish oversight from deliberate decision — should-fix.

### Architecture principles alignment

Read [architecture-principles.md](architecture-principles.md) for the canonical definitions of screaming architecture, deep modules, and adapter boundaries.

- **Do proposed refactorings move toward these principles?** Well-aligned: moving business logic into the domain layer, merging thin pass-through abstractions, reorganizing by domain rather than technical layer.
- **Do any proposals move away from these principles?** Flag proposals to extract new thin wrappers, reorganize into a `services/` directory, or add abstractions that leak internal structure.

### Ubiquitous language

Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Then check:

- **Does the proposal use canonical terms?** Proposed module names, entity names, and process names should match glossary entries. Synonyms or paraphrases for already-named concepts are a should-fix — the downstream tickets and code will inherit the inconsistency.
- **Are new terms proposed without a glossary entry?** If the proposal introduces a name for a concept not yet in the glossary, check whether the proposal updated the glossary. If not, that's a should-fix — the `refactor-design` skill was responsible for adding them.

### The "can this be ticketed?" smell test

Read the Proposed refactorings as if you were the planner. Could you produce a ticket from each entry without reading the source code? If not, the proposal is underspecified — should-fix.

## Common findings

- Friction points named without file paths or specific patterns
- Proposed refactorings too vague to produce actionable tickets from ("clean up", "improve", "reorganize")
- Constraint contradictions unacknowledged
- Suggested order that doesn't follow from stated priorities or ignores dependencies
- Scope decisions section empty — reader can't distinguish oversight from deliberate exclusion
- Friction areas named in the Summary that don't appear in the Friction points list
- Approach fields that are generic rather than codebase-specific

## Verdict guidance for this phase

- **Block** if: a proposed refactoring contradicts an established constraint in `ARCHITECTURE.md` without acknowledgement; friction points lack specific locations; the proposal is too vague to produce actionable tickets from.
- **Request changes** if: priorities are unjustified; ordering contradicts priorities or ignores dependencies; obvious friction areas are missing; scope decisions are empty; refactorings lack actionable approach.
- **Approve with comments** if: the proposal is solid, with only nit-level concerns.
- **Approve** if: rare. Hold a high bar.

## Output

Save the review at `docs/features/<slug>/refactor-design-review-<NN>.md` using the format defined in [review-base.md](review-base.md). Reference specific sections of the proposal and, where possible, specific file paths from the Friction points list. If the verdict is Approve or Approve with comments, suggest the next step is the `planning` skill.
