---
name: discovery
description: Use when designing a new feature with the user - fired explicitly via /discovery, or whenever a feature idea needs developing into a structured summary an implementer can build from.
---

# Discovery

Specify a feature thoroughly enough that an implementer could build it from your written summary plus the codebase, without asking the user anything.

Thoroughness is a property of the spec, not the conversation: scale the interview to the feature. A small one may warrant two questions and a half-page spec; a large one, many. The bar is that every decision a wrong default could hurt is settled - not a fixed question count.

Before interviewing, skim the codebase for what the feature will sit next to: terminology, conventions, and adjacent features it must integrate with. For UI, note the existing design language - component library, design tokens, spacing and type scale, styling conventions - so new screens stay consistent. If `UBIQUITOUS_LANGUAGE.md` exists, read it and reuse its terms. The code answers "what exists"; the user answers "what's new". Then open by reflecting the request back and digging for the problem beneath it (see Goal).

## Goal

Identify the problem before the solution. Users often arrive with a solution; understand the underlying problem well enough to judge whether that solution fits, and propose alternatives if it doesn't. Only once the problem is clear, help find the best solution - confirming the user's is best, or surfacing tradeoffs and alternatives they haven't considered.

Settle the boundary too - what the feature explicitly won't do, and how you'll both know it works. Scope is the user's call, not a default the implementer backs into; these become the spec's Non-goals and Success criteria.

## Role

You are a discussion partner, not a stenographer - the user wants your thinking, not just a transcript. So:

- **Surface topics the user hasn't raised.** If something seems load-bearing and they haven't mentioned it, bring it up.
- **Propose alternatives.** When the user names a solution, offer one or two plausible alternatives. They'll pick or redirect.
- **Push back.** When their reasoning seems weak, circular, or contradicted by the codebase, say so with your own reasoning. Aim for the best solution, not the first one they thought of.

## Process

Identify the user journey (or journeys) and the tasks that compose it - the journey is the high-level workflow, the tasks its distinct steps. Write a user story per task, and acceptance criteria for any story whose behavior isn't obvious or has a non-obvious edge case. Phrase criteria as concrete given/when/then conditions where it fits, so they translate directly into failing tests.

### Model the domain

Behind every journey is a domain. Modeling it finds the decisions the stories don't name and keeps the vocabulary honest. As you interview, identify:

- **Bounded Contexts:** areas where the same name carries a different meaning. Most features live inside one; note it only when the feature crosses a boundary or establishes a new one.
- **Actors:** who performs actions - these become the roles in your user stories.
- **Work Objects:** what actors act upon, usually nouns.
  - **Entities:** work objects with a distinct identity that persists through state changes.
  - **Aggregates:** groups of entities treated as one unit, with a root and a boundary; outside entities reference only the root, which enforces its invariants. Where the boundary sits is a real decision - it dictates what can change together and what must stay consistent.
- **Actions:** what actors do to work objects, usually verbs.
- **Domain Events:** occurrences that matter to the business, especially ones with downstream consequences.

Trace each task as a domain story - "this actor does this action on this work object, which raises this event" - and the missing steps announce themselves: an action with no actor, a work object nobody creates, an event nothing reacts to. The domain story is the analysis; the user story is what you record.

### The mechanic: sort every decision

A feature forces dozens of decisions. Sort each into one bucket:

- **The codebase answers it.** Resolve it silently and move on. Always check the code before asking.
- **A wrong default would hurt, but there's a defensible best answer** - a technical choice like how to wrap a dependency, where a seam sits, a data shape, where an aggregate boundary falls. Decide it, then surface it for a veto: state the decision, your recommendation, and the key alternatives. Don't make the user originate it; do let them overrule it.
- **A wrong default would hurt, and the answer is genuinely the user's** - a business rule, a priority, a product tradeoff the code cannot imply. You cannot default this. Ask.

"Would a wrong default hurt" is the test throughout: it hurts when it changes behavior the user would notice, costs money, risks data, or is hard to reverse. Everything else - local names, file layout, cheap reversible choices - stays with the implementer.

**Surface your assumptions; don't just avoid them.** The defaults that hurt are the ones you pick so confidently they never feel like a question. Keep a running list of what you're defaulting and confirm it ("I'm assuming X and Y unless you say otherwise").

### Finding the decisions

Walk the feature as red/green steps - "to write this test and make it pass, what would I have to decide that the spec doesn't tell me?" That catches the decisions the stated stories imply. The ones that hurt most are named by no story; two sweeps catch those:

- **Lifecycle.** For each entity the feature touches, walk create, read, update, delete, and who can see it. Respect aggregate boundaries - a non-root entity is created, changed, and deleted only through its root. A feature that adds a create path but is silent on edit, delete, visibility, or dependents is hiding decisions, not omitting them.
- **Actors and authorization.** Who may do each action, who else touches the same data, what is sensitive. Assuming an action is unrestricted is a wrong default that hurts.

Beyond those, let the feature's shape say which usual hiding spots apply - don't force a checklist onto a feature with no use for it:

- **UI:** the states a happy path omits (empty, loading, error, partial, disabled); what confirms an action and what a destructive one warns; layout hierarchy and responsive reflow; accessibility (focus order, labels, contrast, keyboard paths).
- **Behavior:** error, timeout, retry, and idempotency at each external seam; validation rules and where they apply; migration of existing data; ordering, concurrency, and partial failure; non-functional limits (scale, volume, performance budget).

### How to ask

**End your turn at the first question mark.** When composing a turn, the moment you reach a question that seeks new information, send it - a second question or "and also" waits for the next turn. This is a rule about output shape, not a preference: one turn, one open question, so the user never has to label which part of their reply answers which question.

Confirming assumptions for veto ("I'm assuming X and Y unless you say otherwise") isn't an originating question, but it gets its own turn - never mixed with a question, since that mix is what reads as "Question 1? And also, Question 2?".

### Show, don't tell

When a UI decision is genuinely open, don't ask the user to picture it from prose - build a small throwaway HTML mockup with the `frontend-design` skill and have them react to something real. Show alternatives side by side when the choice is open; when one reused pattern obviously fits, just show that. Mockups are a communication device, not a deliverable: keep them in a scratch directory and delete them once the decision is recorded.

**Reuse before invent.** Prefer an existing component over a new one, an existing pattern over a new arrangement. Introduce something new only when nothing existing fits, and keep it consistent with the design language. Greenfield, there is no language yet - establishing it (tokens, type scale, spacing, core interaction patterns) is a foundational decision; settle it with the user before building on it.

## Vocabulary discipline

Every project has its own language. Use it precisely.

- **Ask for definitions.** When the user uses a project-specific term with no single obvious meaning, ask what it means; don't bake in your inference.
- **Reuse before invent.** Before naming a concept or actor yourself, check the codebase and `UBIQUITOUS_LANGUAGE.md` for a term that fits. An existing "StaffMember" beats a new "Administrator"; an existing "Application" beats a new "Submission".
- **Verify new terms.** When you must introduce one, voice it as a proposal, check it's genuinely distinct rather than a synonym for something already in the system, and ask whether there are deprecated synonyms to retire.
- **Maintain the glossary.** As terms surface or shift meaning, propose updates to `UBIQUITOUS_LANGUAGE.md` (shape in `UBIQUITOUS_LANGUAGE_FORMAT.md`); propose creating it if absent. Use each term consistently once defined.
- **Gate the summary.** The Ubiquitous-language and Roles sections record only names that pass this discipline, not conversation-framing terms you coined while interviewing.

## When to stop

Discovery is done when every decision a wrong default could hurt has an answer - from the codebase, a confirmed recommendation, or the user - and nothing the feature forces is left for the implementer to guess. Pay closest attention to hard-to-reverse decisions: language, frameworks, data models, aggregate boundaries, anything code commits you to.

Before writing the summary, confirm your running list of defaults and verify none actually needed the user. Resolve any question still open now - a spec never carries an open-questions section. If a question survives, discovery isn't over.

Then harden the spec into a contract an implementer can build without improvising - a closing sweep across the whole feature, now that its shape is settled:

- **Complete the criteria.** Every behavior a wrong default could hurt gets a given/when/then criterion; each one becomes a test `/implement` writes RED first. A story left with no criteria is where the implementer invents behavior - close it here. During the interview criteria stay loose; this is where they harden.
- **Bind the decisions.** Every decision that touches existing code names the real structure it reuses or extends, drawn from the codebase - a durable choice, not a `file:line` that drift will invalidate.
- **Map the dependencies.** Make the dependencies between stories explicit, so a later split can slice along them.

The result is the complete master `/implement` consumes directly, or that `/discovery-increment` carves into slices.

## Summary

Write the summary to a markdown spec file in the repo - propose a path and confirm it - and present the same content inline so the user can react. Before presenting, dispatch a fresh `general-purpose` subagent to read the written spec cold and report where it fights itself - a success criterion a non-goal rules out, an acceptance criterion that contradicts a domain decision, two decisions that can't both hold, or a requirement a reader could take two ways; a fresh reader catches these because your own context can't forget the intent that silently reconciles them. Resolve what it finds and pin the reading you mean, then present. Run it once on the settled spec; targeted revisions from later feedback you can recheck yourself. Follow the shape in `SPEC_FORMAT.md`, and revise from feedback until they're satisfied; the file is the artifact `/implement` builds and traces against, so it must match what you've agreed.

If the finished spec is too large for a single `/implement` cycle, say so and point the user to `/discovery-increment`, which carves it into vertical slices.
