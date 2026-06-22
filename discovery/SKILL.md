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

Identify the user journey (or journeys) and the user tasks that compose it. The user journey is the high-level workflow the user wants to enable; user tasks are the distinct steps within that workflow. Write a user story for each user task, and acceptance criteria for any story whose behavior isn't obvious or has a non-obvious edge case.

### The mechanic: sort every decision

A feature forces dozens of decisions. Your whole job is to sort each one into a bucket:

- **The codebase answers it.** Resolve it silently and move on. Always check the code before asking.
- **A wrong default would hurt, but there's a defensible best answer** - a technical choice like how to wrap a dependency, where a seam sits, a data shape. Decide it yourself, then surface the choice for a veto: state the decision, your recommendation, and the key alternatives. Don't make the user originate it; do let them overrule it.
- **A wrong default would hurt, and the answer is genuinely the user's** - a business rule, a priority, a product tradeoff the code cannot imply. You cannot default this. Ask.

"Would a wrong default hurt" is the test throughout: a default hurts when it changes behavior the user would notice, costs money, risks data, or is hard to reverse. Everything else - local names, file layout, cheap reversible choices - stays with the implementer. The goal is that no decision a wrong default could hurt is left for the implementer to guess, not that every detail becomes a question.

**Surface your assumptions; don't just avoid them.** The defaults that hurt are the ones you pick confidently, so they never feel like a question. Keep a running list of what you're defaulting and confirm it ("I'm assuming X and Y unless you say otherwise") rather than trusting that nothing slipped in unexamined.

### Finding the decisions

Walk the feature as a sequence of red/green steps - "to write this test and make it pass, what would I have to decide that the spec doesn't tell me?" That catches the decisions the stated stories imply. The ones that hurt most are the ones no story names; two sweeps catch those:

- **Lifecycle.** For each entity the feature touches, walk create, read, update, delete, and who can see it. A feature that adds a create path and is silent on edit, delete, visibility, or what happens to dependents is hiding decisions, not omitting them.
- **Actors and authorization.** Who is allowed to do each action, who else touches the same data, what is sensitive. Assuming an action is unrestricted is a wrong default that hurts.

Beyond those, let the feature's actual shape say which of the usual hiding spots apply - don't force a checklist onto a feature that has no use for it:

- **UI:** the states a happy path omits (empty, loading, error, partial, disabled); what confirms an action and what a destructive one warns; layout hierarchy and responsive reflow; accessibility (focus order, labels, contrast, keyboard paths).
- **Behavior:** error, timeout, and retry at each external seam, and idempotency; validation rules and where they apply; migration of existing data; ordering, concurrency, and partial failure; non-functional limits (scale, volume, performance budget).

### How to ask

Ask one question per turn, and only one. The user should be able to reply on a single topic without labeling which part of their answer addresses which question. If you catch yourself drafting a second question in the same turn, hold it back for the next turn.

### Show, don't tell

When a UI decision is genuinely open, don't ask the user to picture it from prose - build a small throwaway HTML mockup with the `frontend-design` skill and have them react to something real. Show alternatives side by side when the choice is open; when one reused pattern obviously fits, just show that. These mockups are a communication device, not a deliverable: keep them in a scratch directory and delete them once the decision is recorded in the spec.

**Reuse before invent.** Prefer an existing component over a new one; an existing pattern over a new arrangement. Introduce something new only when nothing existing fits, and when you do, keep it consistent with the design language. Greenfield, there is no language yet - establishing it (tokens, type scale, spacing, the core interaction patterns) is a foundational decision; settle it with the user before building on it.

## Vocabulary discipline

Any project has its own language. Use it precisely.

- **Ask for definitions.** When the user uses a project-specific term with no single obvious meaning, ask what it means. Don't bake in your inference.
- **Reuse before invent.** Before naming a concept or actor in your own words, check the codebase and `UBIQUITOUS_LANGUAGE.md` for an existing term that fits. An existing "StaffMember" beats a new "Administrator"; an existing "Application" beats a new "Submission".
- **Verify new terms.** When you do need to introduce one, voice it as a proposal and check with the user that it's genuinely distinct, not just a synonym for something already in the system. Ask whether there are deprecated synonyms or words the user wants to retire.
- **Maintain the glossary.** As terms surface or shift meaning, propose updates to `UBIQUITOUS_LANGUAGE.md` (see `UBIQUITOUS_LANGUAGE_FORMAT.md` for the shape). If the file doesn't exist yet, propose creating it. Use the same term consistently once defined.
- **Gate the summary.** The Ubiquitous-language and Roles sections of the summary record only names that pass this discipline, not conversation-framing terms you coined while interviewing.

## When to stop

Discovery is done when every decision a wrong default could hurt has an answer - from the codebase, a confirmed recommendation, or the user - and nothing the feature forces is left for the implementer to guess. Pay closest attention to the decisions that are hard to reverse: language, frameworks, data models, anything code commits you to.

Before you write the summary, confirm the running list of defaults from the mechanic above and verify none of it actually needed the user. Any question still genuinely open is not finished work - resolve it now. A spec never carries an open-questions section: if a question survives, discovery isn't over.

## Summary

Write the summary to a markdown spec file in the repo - propose a path and confirm it with the user - and present the same content inline so they can react. Revise from their feedback until they're satisfied; the file is the artifact `/implement` builds and traces against, so it must match what you've agreed. Use this shape:

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

Omit sections that don't apply; add subsections where the domain warrants. User stories should be exhaustive - one for each distinct workflow, including edge variations - while the nested bullets stay optional, as the inline template notes mark.

If the finished spec is too large for a single `/implement` cycle, say so and point the user to `/discovery-increment`, which carves it into vertical slices. Either way, the goal is that a fresh implementing agent can build from the spec plus the codebase without coming back to the user.
