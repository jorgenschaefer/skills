---
name: review-tickets
description: Use this skill to review a Ticket Backlog produced by the Planning phase before implementation begins. Trigger this whenever the user says things like "review these tickets", "is this backlog ready", "critique the ticket breakdown", or hands you a directory under docs/tickets/ and asks for feedback. The output is a structured review file with findings categorized by severity. Always use a clean context, separate from the conversation that produced the tickets, so dependencies and independence properties get checked with fresh eyes.
---

# Tickets Review

This skill reviews a **Ticket Backlog** — the artifact produced by the Planning phase. It builds on the shared review base; read `../SKILL.md` first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to verify that the work has been sliced well: each ticket can stand on its own, the ordering makes sense, and nothing from the design has been forgotten or smuggled out of scope.

## Setup

Before reviewing, confirm:

1. The artifact is a Ticket Backlog (a directory of ticket files plus a README.md overview, following the `planning` skill structure).
2. You have access to the Design Doc the tickets are based on. You cannot review tickets meaningfully without the design — many findings come from cross-checking design content against ticket coverage.
3. You're in a clean context.

## What to check

Walk through these questions. Check each ticket individually, then check the backlog as a whole.

### Per-ticket checks

For each ticket, verify:

- **Independent deployability.** Could you ship this ticket alone, with no other ticket from the backlog, and have a working system? If no, the slice is wrong (or the dependency on a prior ticket is not made explicit).
- **Independent testability.** Are there observable, automatable tests that would prove this ticket works? If the ticket's only "test" is "the next ticket calls this code," that's a layer-by-layer slice, not a tracer-bullet slice.
- **Acceptance criteria are observable.** Each acceptance criterion should be checkable by reading code, running a test, or observing system behavior. Vague criteria ("works correctly," "performs well") are findings.
- **Scope is clear.** "In scope" and "Out of scope" are both populated. Out-of-scope items reference where the deferred work is handled (another ticket, a future iteration, an explicit non-goal).
- **Size is plausible.** Roughly fits in a focused work session. Tickets that look like multi-week projects need splitting.
- **Ubiquitous language.** The ticket title, goal, and acceptance criteria use the canonical terms from `UBIQUITOUS_LANGUAGE.md`. A ticket whose title paraphrases a glossary term creates ambiguity for the implementer.
- **Traceability.** The ticket references the Design Doc section it implements. Tickets without traceability often turn out to implement something not in the design.
- **Dependencies are explicit.** If the ticket depends on another ticket, it says so. Hidden dependencies surface as merge conflicts and "wait, you didn't tell me X needed to ship first" moments.
- **Definition of done is concrete.** Includes tests, documentation if applicable, deployment if applicable, telemetry if applicable.

### Backlog-level checks

- **Is there a tracer bullet?** Look for the first ticket. Does it deliver a thin end-to-end slice that touches every layer the full feature will touch? If the first several tickets are all "set up infrastructure" or "build the database schema" with no user-visible output, the slicing is layer-by-layer rather than tracer-bullet.
- **Does the design get fully covered?** Walk through the Design Doc. For every major component, contract, behavior, and cross-cutting concern, find the ticket that implements it. Anything in the design without a ticket is a coverage gap. Things the design explicitly puts out-of-scope are fine.
- **Anything in the tickets that's NOT in the design?** Tickets that introduce work not described in the design are scope creep — either the design needs updating, or the ticket is unjustified.
- **Is the order sensible?** Dependencies should come before dependents. High-risk pieces should come early. Tickets that block many others should come early. Tracer bullets should come first.
- **Are cross-cutting concerns ticketed?** Observability, security review, performance testing, migration scripts, runbook updates, monitoring/alerting setup — these are commonly forgotten. Check the design for what should be there, then check the backlog for whether it is.
- **Is the dependency graph reasonable?** A flat list of independent tickets is suspicious for a non-trivial feature — they probably depend on each other in ways the planner didn't acknowledge. A long sequential chain of dependencies is also suspicious — work likely could have been parallelized or sliced differently.
- **Is the total ticket count plausible?** A 40-ticket backlog for a moderate feature suggests over-slicing; a 2-ticket backlog for a major feature suggests under-slicing. Use judgment.

### Spike and unglamorous-work checks

- **Are spikes called out where appropriate?** If the design had open questions, the backlog should usually have spike tickets to resolve them, not feature tickets that depend on the answer.
- **Is unglamorous work ticketed?** Documentation updates, runbook entries, monitoring config, deprecation cleanup, feature flag setup and removal. These are real work, not afterthoughts. If they're missing, they'll either be forgotten or scope-creep into other tickets.
- **Are feature flags handled?** If the rollout plan involves flags, there should be tickets for adding the flag and (eventually) removing it.

### Smell tests

- **The "ship after ticket N" test.** For each ticket, ask: "if we shipped after this ticket and stopped, would users have something useful?" The answer should usually be yes, especially for the early tickets.
- **The "two implementers" test.** If two implementers picked up adjacent tickets in parallel, would they collide? If yes, the dependency graph is wrong, or the slicing is wrong.
- **The "rename test."** Read each ticket title in isolation. Does the title accurately describe the work? Generic titles like "Backend changes" or "Update API" are findings.
- **The "design smuggling" test.** Are tickets quietly making design decisions the Design Doc didn't make? "Implement caching" buried in a ticket is a design decision, not just an implementation detail.
- **The layer-by-layer test.** Are the first 2-3 tickets all infrastructure (DB schema, plumbing, scaffolding) before any user-visible behavior? That's the layer-by-layer antipattern. Tracer bullets thread through all layers in the first ticket.

## Common findings

- Layer-by-layer slicing instead of tracer-bullet slicing
- Acceptance criteria that aren't observable
- Hidden dependencies between tickets
- Cross-cutting concerns from the design not represented in any ticket (commonly: observability, migrations, runbook updates)
- Tickets too large to fit in a focused session — should be split
- Tickets too small to be meaningful units of work — should be merged
- Scope creep: tickets implementing work the design doesn't authorize
- Coverage gaps: design content with no corresponding ticket
- Sequential dependency chains where independent slices were possible
- Missing tickets for feature flag setup and removal
- No spike for an open question that should have been resolved before feature work

## Verdict guidance for this phase

- **Block** if: tickets are not independently deployable, there's a coverage gap on a critical part of the design, or the slicing is fundamentally layer-by-layer rather than tracer-bullet.
- **Request changes** if: several should-fix items (vague acceptance criteria, hidden dependencies, missing cross-cutting tickets, ordering problems).
- **Approve with comments** if: the backlog is solid with only nit-level issues.
- **Approve** if: rare. The bar is high here too.

## Output

Save the review at `docs/reviews/tickets-<feature-slug>-<YYYY-MM-DD>.md` using the format from the shared review base. When citing findings, refer to specific ticket numbers. Include a coverage table or list mapping Design Doc sections to ticket numbers — this makes coverage gaps visible at a glance. Suggest next steps based on verdict.
