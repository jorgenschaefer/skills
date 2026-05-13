---
name: planning
description: Use this skill when the user has a Design Doc, Refactoring Proposal, or a small feature that doesn't need a full design, and wants to break it into independently-deployable tickets ready for implementation. Trigger this whenever the user says things like "break this into tickets", "create the backlog for X", "what's the implementation plan for Y", "split this design into tasks", or hands you a Design Doc or Refactoring Proposal and asks what's next. The output is a Ticket Backlog where every ticket is independently testable and deployable — each one a tracer bullet that delivers value on its own. Always use this skill before implementation starts — implementing directly from the entry artifact skips the discipline of making work shippable in small increments.
---

# Planning

Translate the entry artifact (a Design Doc or Refactoring Proposal) into a **Ticket Backlog**: a sequence of small, self-contained units of work, each independently implementable, testable, and deployable. The discipline of slicing work into independently-deployable increments is what makes agentic implementation tractable, review human-scaled, and course-correction cheap.

## Before starting

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

## Your role

You are the Planner. You take the entry artifact and produce a list of tickets that, taken together, implement it, thinking hard about ordering, dependencies, and independence.

You do not write code or change the design — though you may flag "this design implies a ticket I can't make independent; should we revisit?"

## The principle: every ticket is a tracer bullet

Read [tracer-bullets.md](tracer-bullets.md) for the full explanation and examples.

The tracer-bullet principle applies to **every** ticket, not just the first one. Each ticket must be independently shippable and deliver observable value on its own — not just "this is useful once ticket 5 also ships."

**Anti-pattern to avoid:** "the first tracer bullet is ticket 4 + 5." Either ticket 4 delivers something on its own, or it is a task inside ticket 5, not a separate ticket. Similarly, "set up the project" scaffolding tickets should be folded into the first feature ticket.

## Properties of a good ticket

Every ticket should be:

- **Independently deployable.** Could you ship just this ticket and have a working system afterward? If no, the slice is wrong.
- **Independently testable.** Are there observable, automated tests that demonstrate the ticket works? If the ticket is "refactor module X" and there's no observable behavior change, that's a smell — either it's tied to a feature ticket, or it's a tech-debt cleanup that should be its own type.
- **Small enough to fit in a single focused work session.** If you can't imagine an implementer finishing this in a day or so, it's too big and needs splitting.
- **Large enough to deliver value.** "Add a comment to function foo" is too small. Tickets are user-visible (or at least operator-visible) increments, not arbitrary chunks.
- **Clear in scope.** The ticket says what's in and what's out. Ambiguity at the ticket boundary becomes scope creep at implementation.
- **Traceable.** The ticket references the entry artifact section it implements. Future readers should be able to ask "why this ticket?" and find the answer.

## When tickets must depend on other tickets

In practice, some dependencies are unavoidable. A ticket that displays data needs the data to exist. The discipline isn't "no dependencies" — it's "make dependencies explicit and minimal."

- State dependencies explicitly: "Depends on #123."
- Order tickets so dependencies come first.
- Prefer feature flags over hard ordering when possible: ticket A merges behind a flag, ticket B turns the flag on. Both can ship; only the flag flip is user-visible.
- If a chain of tickets is purely sequential and each one is useless without the next, reconsider — maybe there's a tracer-bullet slice you missed.

## How to approach the work

**Read `UBIQUITOUS_LANGUAGE.md`** at the project root before naming anything. Use canonical terms exactly in ticket titles, goal statements, and acceptance criteria — don't paraphrase.

**Check that suggested file paths respect [architecture-principles.md](architecture-principles.md).** When writing "Implementation notes," avoid top-level `services/`, `controllers/`, or `models/` directories. Prefer domain-first paths (`orders/OrderService.ts` over `services/OrderService.ts`). If tickets are being written for an already-layered codebase, flag the structural tension in a ticket note rather than silently perpetuating a structure the design may intend to move away from.

**Read the entry artifact.** Try `docs/features/<slug>/design.md` first; if not found, try `docs/features/<slug>/refactoring.md`; if not found, try `docs/features/<slug>/discovery.md`. If none of these exist, the user may be starting planning directly for a small feature — ask for a brief problem statement and the list of user stories or interactions to cover, and proceed from that. Note the major components, the proposed changes, the module interactions, the cross-cutting concerns. Anything explicitly out-of-scope in the entry artifact is also out-of-scope here.

After reading the entry artifact, find the most recent review for it — `docs/features/<slug>/design-review-*.md` for a Design Doc, `docs/features/<slug>/refactor-design-review-*.md` for a Refactoring Proposal. If the most recent verdict is Block or Request changes, tell the user and suggest addressing those findings before planning. Proceed if the user explicitly confirms.

**Slice by user story, not by layer.** For each user story or meaningful user interaction in the entry artifact, ask: what is the thinnest end-to-end implementation that makes this story demonstrably work? That's a ticket. It must touch every architectural layer it needs — it is not a database-layer ticket or a UI-layer ticket; it is a story-complete ticket that happens to need both.

Order tickets by value and risk — high-risk and high-value pieces first. Tickets that depend on others come after their dependencies; everything else can parallelize.

**Pull cross-cutting concerns into their own tickets when they don't fit cleanly into a feature slice.** Observability, security hardening, performance work, migration tooling — sometimes these are best as standalone tickets, sometimes they're best as part of a feature ticket. Use judgment. A rule of thumb: if a cross-cutting concern is a feature requirement, bake it into the relevant ticket; if it's general infrastructure, give it its own ticket.

**Look for spikes.** If a ticket would require an implementer to research a question first ("does library X support Y?"), pull the research out into a spike ticket. Spike outputs are decisions and notes, not production code. They have a tight time-box. Use a spike when the answer affects the design of multiple tickets; flag uncertainty inline in implementation notes when it's isolated to one ticket's approach.

**Don't forget the unglamorous work.** Migration scripts, runbook entries, monitoring config, feature flag setup, feature flag removal (if the flag has a planned sunset), deprecation of old code paths, documentation updates. These are real tickets, not afterthoughts.

## The ticket format

Each ticket lives at `docs/features/<feature-slug>/tickets/<NNN>-<slug>.md` with this structure:

```markdown
# <NNN>: <Short title>

**Status:** Backlog | In Progress | In Review | Done
**Entry artifact:** <link>
**Depends on:** <ticket numbers, or "none">
**Estimate:** <S | M | L> (rough size)

## Goal
One or two sentences. What does this ticket accomplish from a user's or operator's perspective?

## Context
Brief reminder of what's relevant from the entry artifact. Don't restate the whole document — link to it. Just the slice this ticket implements.

## Scope
### In scope
- Bullet list of what this ticket includes.
### Out of scope
- Bullet list of related-but-deferred work, with pointers to the tickets that handle it.

## Acceptance criteria
A checklist of observable, testable conditions. The ticket is done when all of these are true.

- [ ] <Specific, observable condition>
- [ ] <Another one>
- [ ] Tests cover the new behavior at the appropriate level (unit / integration / e2e — be specific)
- [ ] Documentation updated (if applicable)
- [ ] Feature flag added / changed (if applicable)
- [ ] Migration script written and tested (if applicable)

## Implementation notes
Optional. Pointers to specific files, modules, or patterns the implementer should know about. Not a full implementation plan — that's the implementer's job. Just the things the planner knows that the implementer might miss.

## Definition of done
- All acceptance criteria met
- Code reviewed
- Tests passing in CI
- Deployed to <environment> (if applicable)
- Telemetry / logging verified working in <environment> (if applicable)
```

## Spike tickets

Spikes are time-boxed investigations. Use the format defined in [spike-format.md](spike-format.md).

## The backlog overview

In addition to individual ticket files, produce a backlog overview at `docs/features/<feature-slug>/tickets/README.md`:

```markdown
# Backlog: <Feature title>

**Entry artifact:** <link>
**Created:** <date>

## Tickets in suggested order

1. [#001 - <title>](001-slug.md) — <one-line summary>
2. [#002 - <title>](002-slug.md) — <one-line summary>
...

## Dependency graph

    001 ──> 002 ──> 003
             └────> 004
    005 (independent)

## Notes on ordering
Why this order. What's the tracer bullet. What can parallelize.

## Coverage
| Entry artifact section | Ticket(s) |
|---|---|
| <section name> | #NNN |

## Out of scope
Anything from the entry artifact not covered by these tickets, with reasoning.
```

## What you do not produce

- Implementation code (that's the implementer's job)
- Architectural changes (that's the architect's job — flag it back)
- Estimates in hours or story points (rough S/M/L is enough; precise estimates are usually wrong and waste effort)

## After writing

Before finalizing, apply the tracer-bullet test to every ticket: "if we shipped only this ticket and stopped, would a user have something observable and useful?" If no and there's no depends-on explaining why, the slice is wrong — merge or reslice. Also confirm: the backlog README has a completed coverage table; feature flag setup and removal are both ticketed if flags are used.

Save tickets to `docs/features/<feature-slug>/tickets/` and the README. If the target directory doesn't exist, create it. If you can't write the files, tell the user the artifact paths and paste the content inline so they can save it manually. Tell the user how many tickets you produced, the suggested order, and what the tracer bullet is.

Then run an automated review in a clean context. Use the `Agent` tool with `subagent_type: "general-purpose"`. The agent's self-contained prompt:

> Invoke the `planning-review` skill for feature slug `<slug>`. The backlog is at `docs/features/<slug>/tickets/`.

After the review agent finishes, list `docs/features/<slug>/` and open the newest `tickets-review-*.md` file (the one just created). Update the tickets and backlog README to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the tickets
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment

If any findings were at Blocker severity, run the automated review once more after addressing them (same subagent prompt above) — a self-corrected blocker should be verified by a fresh review pass.

Tell the user what the review found, what was addressed, and the final verdict. If the final verdict is Approve or Approve with comments, suggest the `implementation` skill as the next step. If the final verdict is Block or Request changes, surface the remaining findings and ask the user how to proceed — do not suggest advancing to implementation.
