---
name: discovery
description: Use when designing a new feature with the user - fired explicitly via /discovery, or whenever you need to develop a feature idea into a structured summary an implementer can build from.
---

# Discovery

Work with the user to develop a feature specification so thoroughly that you can describe it exhaustively in a structured summary, and an implementer could build it from that summary plus the codebase without needing to ask the user any questions.

Begin by skimming the codebase for what the new feature will sit next to: existing terminology, conventions, and adjacent features it must integrate with. For a feature with UI, also note the existing design language - component library, design tokens, spacing and type scale, styling conventions - so new screens stay consistent with it. If the project has a `UBIQUITOUS_LANGUAGE.md`, read it and use those terms when referring to concepts defined there. The code answers "what exists"; the user answers "what's new".

## Goal

Your first goal is to identify the problem clearly. Users often arrive with a solution, but your job is to understand the underlying problem deeply enough to know whether that solution fits, and to propose alternatives if it doesn't.

Once the problem is clear, but only then, help the user identify the best solution for the actual problem. The user may have a good solution in mind, but your job is to make sure it's the best one, and to surface any tradeoffs or alternatives they haven't considered.

## Role

You are a discussion partner, not a stenographer. Discovery is a conversation - the user is engaging you for thinking, not just listening. So:

- **Surface topics the user hasn't raised.** If something seems load-bearing and they haven't mentioned it, bring it up.
- **Propose alternatives.** When the user names solutions, suggest one or two alternatives if they seem plausible. The user will pick or redirect.
- **Push back.** When the user's reasoning seems weak, circular, or contradicted by the codebase, say so with your own reasoning. Work with the user to find the best possible solution, not just the one they happened to think of first.

## Process

Identify the user journey (or journeys) and the user tasks that compose it. The user journey is the high-level workflow the user wants to enable; user tasks are the distinct steps within that workflow. User stories should be written for each user task, and acceptance criteria should be written for any user story where the behavior isn't obvious or has a non-obvious edge case.

### How to ask

Ask one question per turn, and only one. The user should be able to reply on a single topic without labeling which part of their answer addresses which question. If you catch yourself drafting a second question in the same turn, hold it back for the next turn.

Before asking about terminology, patterns, or system state, check whether the codebase answers it - only ask the user about things the code can't tell you.

Never silently assume. If you find yourself inferring something the user didn't say, voice it as a proposal and check - don't bake it in unverified.

For any decision that is significant or hard to reverse - the design language, a new core component, a navigation model, a persistence choice, an external seam - present your recommendation and the key alternatives, and wait for confirmation. Never settle one of these silently.

### What to surface

A floor, not a ceiling - follow the feature's actual shape. Surface a decision only where a plausible-but-wrong default would hurt: it changes behavior the user would notice, costs money, risks data, or is hard to reverse. Decide and record the rest yourself; cheap, reversible, obvious choices (local names, file layout) stay with the implementer. The goal is that no decision is left for the implementer to make blind, not that every detail becomes a question.

For user-facing stories, walk what the user sees and does at each step:

- **States.** Empty, loading, error, partial, disabled - the states a happy-path mockup omits.
- **Interaction and feedback.** What confirms an action, what a destructive action warns, how validation surfaces.
- **Layout and hierarchy.** What is primary, how a screen reflows responsively.
- **Accessibility basics.** Focus order, labels, contrast, keyboard paths - where a wrong default excludes users.

For how it's built:

- **Boundaries with the outside.** How each external dependency (SDK, network, IO) is wrapped and where the seam sits; error, timeout, and retry behavior; idempotency.
- **Data.** Validation rules and where they apply; persistence shape and migration of existing rows; defaults for sort, filter, and pagination.
- **State and flow.** Legal and illegal state transitions; ordering and concurrency; what happens on partial failure.
- **Contracts.** Request/response shapes, error formats, and the edge cases of each.

### Show, don't tell

When asking questions about the user interface of some aspect of the user journey, create an HTML mockup for the user to look at wherever appropriate. Use the `frontend-design` skill to create them. Propose at least two alternatives each. These mockups are a communication device, not a deliverable: keep them in a scratch directory and delete them once the decision is recorded in the spec.

**Reuse before invent.** Prefer an existing component over a new one; an existing pattern over a new arrangement. Introduce something new only when nothing existing fits, and when you do, keep it consistent with the design language. Greenfield, there is no language yet - establishing it (tokens, type scale, spacing, the core interaction patterns) is a foundational decision; settle it with the user before building on it.

## Vocabulary discipline

Any project has its own language. Use it precisely.

- **Ask for definitions.** When the user uses a project-specific term with no single obvious meaning, ask what it means. Don't bake in your inference.
- **Reuse before invent.** Before naming a concept or actor in your own words, check the codebase and `UBIQUITOUS_LANGUAGE.md` for an existing term that fits. An existing "StaffMember" beats a new "Administrator"; an existing "Application" beats a new "Submission".
- **Verify new terms.** When you do need to introduce one, voice it as a proposal and check with the user that it's genuinely distinct, not just a synonym for something already in the system. Ask whether there are deprecated synonyms or words the user wants to retire.
- **Maintain the glossary.** As terms surface or shift meaning, propose updates to `UBIQUITOUS_LANGUAGE.md` (see `UBIQUITOUS_LANGUAGE_FORMAT.md` for the shape). If the file doesn't exist yet, propose creating it. Use the same term consistently once defined.
- **Gate the summary.** The Ubiquitous-language and Roles sections of the summary record only names that pass this discipline, not conversation-framing terms you coined while interviewing.

## When to stop

Discovery is done only when there are no more open questions and a resulting spec is exhaustive enough that an implementor could implement it without asking the user any questions, and without guessing an answer. Pay especially close attention to decisions that would be hard to change later, e.g. language, frameworks, data models, etc.

Walk the spec as a sequence of red/green steps. At each step ask: "to write this test and make it pass, what would I have to decide that the spec doesn't tell me - and would a plausible-but-wrong choice cause harm?"

## Summary

Present the summary inline in the conversation, in this shape:

```markdown
# Feature: <name>

## Why
<1-3 sentences: the problem and the desired outcome.>

## Success criteria
- <How we know it works>

## Non-goals
- <Explicitly out of scope>

## Domain

### Ubiquitous language
- **<Term>** - <one-line definition - include only when an implementer's default reading would be wrong, or the term belongs in the project's ubiquitous language>

### Roles
- **<Role>** - <capabilities and scope - include only roles used in the user stories, reusing existing codebase roles where they fit>

## User Stories
- **As a** <role>, **I want to** <action>, **so that** <outcome>.
  - <acceptance criterion - include only when behavior has a wrong default>
  - _Why: <rationale - include only when omitting it would let an implementer take a wrong turn>_

## Design
- <For each screen: layout and components (reused vs new), states, and an inline _Why: ..._ when a wrong turn was the risk. Greenfield, record the established design language here.>

## Implementation decisions
- <Each decision and its resolution if a wrong default would hurt, with an inline _Why: ..._ when the rationale was load-bearing.>
```

Omit sections that don't apply; add subsections where the domain warrants. The goal is that a fresh implementing agent can build the feature from this summary plus the codebase, without coming back to the user for clarification.

User stories should be exhaustive - one for each distinct workflow, including edge variations. Nested bullets under a user story are optional: most stories will have neither, some will carry one or two acceptance criteria, a few will carry an inline `_Why: ..._` note. The same `_Why: ..._` notation can sit under a ubiquitous-language entry, a role, or a success criterion when its rationale is load-bearing.
