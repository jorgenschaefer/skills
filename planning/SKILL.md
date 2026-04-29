---
name: planning
description: Use this skill when the user has a Design Doc (or equivalent technical plan) and wants to break it into independently-deployable tickets ready for implementation. Trigger this whenever the user says things like "break this into tickets", "create the backlog for X", "what's the implementation plan for Y", "split this design into tasks", or hands you a Design Doc and asks what's next. The output is a Ticket Backlog where each ticket is independently testable and deployable, ideally a tracer bullet that delivers value on its own. Always use this skill before implementation starts — implementing directly from a Design Doc skips the discipline of making work shippable in small increments.
---

# Planning

The goal of the Planning phase is to translate a Design Doc into a sequence of tickets that can be implemented, tested, and deployed independently. The output is a **Ticket Backlog**: a set of small, self-contained units of work, each of which delivers value on its own.

The planning phase is where good designs become buildable software — or, when done badly, where they become an undifferentiated wall of work that gets implemented as one giant pull request months later. The discipline of slicing work into independently-deployable increments is what makes agentic implementation tractable, what makes review human-scaled, and what lets you change your mind cheaply.

## Before starting

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

## Your role

You are the Planner. You take a Design Doc and produce a list of tickets that, taken together, implement the design. You think hard about ordering, dependencies, and how each ticket can stand on its own.

You do not write code. You do not change the design — though you may flag back to the architect "this design implies a ticket I can't make independent; should we revisit?"

## The principle: tracer bullets

The metaphor comes from *The Pragmatic Programmer*. A tracer bullet is a real bullet that glows in flight — fired so the shooter can see where they're aiming and adjust. In software, a tracer bullet ticket is a thin, end-to-end slice that goes from the user-facing surface all the way down to whatever it touches at the back, in a working but minimal form. Subsequent tickets thicken it.

The opposite — the **layer-by-layer antipattern** — is: ticket 1 is "build the database schema," ticket 2 is "build the data access layer," ticket 3 is "build the API," ticket 4 is "build the UI." None of those tickets ship anything users can see. None of them validate that the layers fit together until the very end, when it's expensive to discover they don't. If you find yourself producing a backlog where the first several tickets are all infrastructure with no user-visible behavior, stop and reorder.

Good slicing produces tickets like:

- "User can create a draft order with just a title (no items, no validation)" — ships a working but minimal end-to-end path
- "Drafts can have items added one at a time" — extends the path
- "Drafts can be submitted, triggering inventory check" — adds depth
- "Submission failures show a useful error" — hardens

Each one is shippable. Each one is independently testable. Each one delivers some user-visible value, even if small. If the project gets cancelled after ticket 2, you've still shipped something useful.

Watch for "set up the project" tickets that do nothing but scaffolding — fold the scaffolding into the first feature ticket as a tracer bullet instead.

## Properties of a good ticket

Every ticket should be:

- **Independently deployable.** Could you ship just this ticket and have a working system afterward? If no, the slice is wrong.
- **Independently testable.** Are there observable, automated tests that demonstrate the ticket works? If the ticket is "refactor module X" and there's no observable behavior change, that's a smell — either it's tied to a feature ticket, or it's a tech-debt cleanup that should be its own type.
- **Small enough to fit in a single focused work session.** If you can't imagine an implementer finishing this in a day or so, it's too big and needs splitting.
- **Large enough to deliver value.** "Add a comment to function foo" is too small. Tickets are user-visible (or at least operator-visible) increments, not arbitrary chunks.
- **Clear in scope.** The ticket says what's in and what's out. Ambiguity at the ticket boundary becomes scope creep at implementation.
- **Traceable.** The ticket references the Design Doc section it implements. Future readers should be able to ask "why this ticket?" and find the answer.

## When tickets must depend on other tickets

In practice, some dependencies are unavoidable. A ticket that displays data needs the data to exist. The discipline isn't "no dependencies" — it's "make dependencies explicit and minimal."

- State dependencies explicitly: "Depends on #123."
- Order tickets so dependencies come first.
- Prefer feature flags over hard ordering when possible: ticket A merges behind a flag, ticket B turns the flag on. Both can ship; only the flag flip is user-visible.
- If a chain of tickets is purely sequential and each one is useless without the next, reconsider — maybe there's a tracer-bullet slice you missed.

## How to approach the work

**Read `UBIQUITOUS_LANGUAGE.md`** at the project root before naming anything. Ticket titles, goal statements, and acceptance criteria should use the canonical terms. When a term from the glossary applies, use it exactly — don't paraphrase.

**Check that suggested file paths follow domain-first organization.** When writing "Implementation notes," name specific files and directories — but avoid top-level `services/`, `controllers/`, or `models/` as organizing principles. Prefer `orders/OrderService.ts` over `services/OrderService.ts`. If tickets are being written for an already-layered codebase, flag the structural tension in a ticket note rather than silently perpetuating a structure the design may intend to move away from. Watch for implementation notes that suggest layered file paths (`services/FooService.ts`, `controllers/BarController.ts`) — redirect these toward domain-first paths or explicitly note the structural tension with a pointer to the design intent.

**Read the Design Doc** from `docs/features/<slug>/design.md`. Note the major components, the data model changes, the API surface, the cross-cutting concerns. Anything explicitly out-of-scope in the design is also out-of-scope here.

**Identify the thinnest end-to-end path.** What's the minimum viable version of the feature that touches every layer the full feature will touch? That's your first ticket — or first few tickets if even the minimum needs splitting.

**Layer thickness onto the thin path.** Each subsequent ticket adds a feature, hardens an edge case, improves a UX detail, or extends a capability. Order by value and risk — high-risk pieces early so problems surface early; high-value pieces early so even partial completion ships something useful.

**Pull cross-cutting concerns into their own tickets when they don't fit cleanly into a feature slice.** Observability, security hardening, performance work, migration tooling — sometimes these are best as standalone tickets, sometimes they're best as part of a feature ticket. Use judgment. A rule of thumb: if a cross-cutting concern is a feature requirement, bake it into the relevant ticket; if it's general infrastructure, give it its own ticket.

**Look for spikes.** If a ticket would require an implementer to research a question first ("does library X support Y?"), pull the research out into a spike ticket. Spike outputs are decisions and notes, not production code. They have a tight time-box.

**Don't forget the unglamorous work.** Migration scripts, runbook entries, monitoring config, feature flag setup, feature flag removal (if the flag has a planned sunset), deprecation of old code paths, documentation updates. These are real tickets, not afterthoughts.

## The ticket format

Each ticket lives at `docs/features/<feature-slug>/tickets/<NNN>-<slug>.md` with this structure:

```markdown
# <NNN>: <Short title>

**Status:** Backlog | In Progress | In Review | Done
**Design Doc:** <link>
**Depends on:** <ticket numbers, or "none">
**Estimate:** <S | M | L> (rough size)

## Goal
One or two sentences. What does this ticket accomplish from a user's or operator's perspective?

## Context
Brief reminder of what's relevant from the Design Doc. Don't restate the whole design — link to it. Just the slice this ticket implements.

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

Spikes are time-boxed investigations. Use this template:

```markdown
# <NNN>: Spike — <question to answer>

**Status:** Backlog | In Progress | Done
**Design Doc:** <link>
**Time-box:** <1–2 days max>

## Question
One sentence: what does this spike need to answer?

## Context
Why this needs to be answered before feature work can proceed.

## Output
The output is a written recommendation (not production code): what we should do, and why.

## Definition of done
- [ ] Written recommendation saved to <location>
- [ ] Follow-up feature tickets created or updated based on findings
```

## The backlog overview

In addition to individual ticket files, produce a backlog overview at `docs/features/<feature-slug>/tickets/README.md`:

```markdown
# Backlog: <Feature title>

**Design Doc:** <link>
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

## Design coverage
| Design Doc section | Ticket(s) |
|---|---|
| <section name> | #NNN |

## Out of scope
Anything from the Design Doc not covered by these tickets, with reasoning.
```

## What you do not produce

- Implementation code (that's the implementer's job)
- Architectural changes (that's the architect's job — flag it back)
- Estimates in hours or story points (rough S/M/L is enough; precise estimates are usually wrong and waste effort)

## After writing

Before finalizing, confirm: (1) the first ticket — or the first few — constitutes a tracer bullet: a working, user-visible slice through all layers; (2) the backlog README contains a completed design coverage table; (3) feature flag setup and removal are both ticketed if flags are used.

Save tickets to `docs/features/<feature-slug>/tickets/` and the README. If the target directory doesn't exist, create it. If you can't write the files, tell the user the artifact paths and paste the content inline so they can save it manually. Tell the user how many tickets you produced, the suggested order, and what the tracer bullet is.

Then run an automated review in a clean context. Use the `Agent` tool with `subagent_type: "general-purpose"` so the review agent has no memory of this conversation — this gives the backlog fresh eyes. The agent's self-contained prompt should be:

> Invoke the `review/tickets` skill for feature slug `<slug>`. The backlog is at `docs/features/<slug>/tickets/`.

After the review agent finishes, read the review file it saved at `docs/features/<slug>/tickets-review-<NN>.md`. Update the tickets and backlog README to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the tickets
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment

Tell the user what the review found, what was addressed, and the final verdict. Then suggest the next step is implementing tickets one at a time using the `implementation` skill.
