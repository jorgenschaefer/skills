---
name: planning-review
description: Use this skill to review a Ticket Backlog produced by the Planning phase before implementation begins. Trigger this whenever the user says things like "review these tickets", "is this backlog ready", "critique the ticket breakdown", or hands you a directory under docs/features/ and asks for feedback. The output is a structured review file with findings categorized by severity. Always use a clean context, separate from the conversation that produced the tickets, so dependencies and independence properties get checked with fresh eyes.
---

# Planning Review

This skill reviews a **Ticket Backlog** — the artifact produced by the Planning phase. It builds on the shared review base; read [review-base.md](review-base.md) first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to verify that the work has been sliced well: each ticket stands alone, the ordering makes sense, and nothing from the design has been forgotten or smuggled out of scope.

## Setup

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding. Read the ticket backlog from `docs/features/<slug>/tickets/`.

Before reviewing, confirm:

1. The artifact is a Ticket Backlog (a directory of ticket files plus a README.md overview, following the `planning` skill structure).
2. You have access to the Design Doc the tickets are based on. You cannot review tickets meaningfully without the design — many findings come from cross-checking design content against ticket coverage.
3. You're in a clean context — you did not participate in creating this artifact. If you're unsure, treat your judgment as potentially contaminated: note it in "What was NOT checked" and flag any area where prior context might be biasing you.

## What to check

Read [tracer-bullets.md](tracer-bullets.md) for the definition of tracer-bullet slicing and the layer-by-layer antipattern. Check each ticket individually, then check the backlog as a whole.

### Per-ticket checks

For each ticket, verify:

- **Independent deployability.** Could you ship this ticket alone and have a working system? If no, the slice is wrong (or the dependency on a prior ticket is not made explicit).
- **Independent testability.** Are there observable, automatable tests that prove this ticket works? If the only "test" is "the next ticket calls this code," that's a layer-by-layer slice.
- **Acceptance criteria are observable.** Each acceptance criterion should be checkable by reading code, running a test, or observing system behavior. Vague criteria ("works correctly," "performs well") are findings.
- **Scope is clear.** "In scope" and "Out of scope" are both populated. Out-of-scope items reference where the deferred work is handled (another ticket, a future iteration, an explicit non-goal).
- **Size is plausible.** Roughly fits in a focused work session. Tickets that look like multi-week projects need splitting.
- **Ubiquitous language.** The ticket title, goal, and acceptance criteria use the canonical terms from `UBIQUITOUS_LANGUAGE.md`.
- **Traceability.** The ticket references the Design Doc section it implements.
- **Dependencies are explicit.** If the ticket depends on another ticket, it says so.
- **Definition of done is concrete.** Includes tests, documentation if applicable, deployment if applicable, telemetry if applicable.

### Backlog-level checks

- **Is every ticket a tracer bullet?** For each ticket: "if we shipped only this ticket and stopped, would a user have something observable and useful?" If no, and there's no `Depends on` explaining why, the slice is wrong.
- **Is there a tracer bullet in the first position?** The first ticket delivering user-visible behavior (spike tickets don't count) should be a thin end-to-end slice touching every layer. If the first several tickets are infrastructure with no user-visible output, the slicing is layer-by-layer.
- **Does the design get fully covered?** For every major component, contract, behavior, and cross-cutting concern in the Design Doc, find the ticket that implements it. Anything without a ticket is a coverage gap. Build a coverage table (Design Doc section → ticket numbers) as you go — include it in the output.
- **Anything in the tickets that's NOT in the design?** Such tickets are scope creep — either the design needs updating, or the ticket is unjustified.
- **Is the order sensible?** Dependencies should come before dependents. High-risk pieces should come early. Tickets that block many others should come early. Tracer bullets should come first.
- **Are cross-cutting concerns ticketed?** For each concern, check whether the design doc addressed it architecturally, then verify a ticket exists in the backlog covering it. Concerns most commonly left unticketed: observability setup, migration scripts, runbook updates, monitoring/alerting configuration.
- **Is the dependency graph reasonable?** A fully flat list is suspicious for a non-trivial feature; a long sequential chain is suspicious too — work likely could have been parallelized or sliced differently.
- **Is the total ticket count plausible?** A 40-ticket backlog for a moderate feature suggests over-slicing; a 2-ticket backlog for a major feature suggests under-slicing. Use judgment.

### Spike and unglamorous-work checks

- **Are spikes called out where appropriate?** If the design had open questions, the backlog should usually have spike tickets to resolve them, not feature tickets that depend on the answer.
- **Is unglamorous work ticketed?** Documentation updates, runbook entries, monitoring config, deprecation cleanup, feature flag setup and removal. These are real work, not afterthoughts. If they're missing, they'll either be forgotten or scope-creep into other tickets.
- **Are feature flags handled?** If the rollout plan involves flags, there should be tickets for adding the flag and (eventually) removing it.
- **Do all tickets have Status: Backlog?** A freshly-produced backlog should have every ticket at Backlog status. Any other status is a nit (likely a copy-paste artifact), but worth flagging so it gets corrected before implementation begins.
- **Does the README contain a design coverage table?** A coverage table mapping Design Doc sections to ticket numbers should be present. If it's missing, note it as a should-fix — it makes the coverage check in this review harder and leaves a gap for future readers.

### Smell tests

- **The layer-by-layer test.** Are the first 2-3 tickets all infrastructure (DB schema, plumbing, scaffolding) before any user-visible behavior? Run this first — it's the most common failure mode.
- **The "only ticket" test.** Pick any ticket at random: "if this were the only ticket that shipped, would a user notice something useful?" If no, and it has no explicit dependency supplying the missing piece, it's a finding.
- **The "ship after ticket N" test.** For each ticket: "if we shipped here and stopped, would users have something useful?" Should usually be yes, especially early.
- **The "two implementers" test.** If two implementers picked up adjacent tickets in parallel, would they collide? If yes, the dependency graph or slicing is wrong.
- **The "rename test."** Does each ticket title accurately describe the work in isolation? Generic titles like "Backend changes" or "Update API" are findings.
- **The "design smuggling" test.** Do any tickets authorize implementation choices the Design Doc didn't make (caching strategy, library picks, structural decisions)? Those belong in the design.
- **The screaming architecture test.** Read [architecture-principles.md](architecture-principles.md) §Screaming Architecture. Do implementation notes reference technical-layer paths (`services/FooService.ts`) rather than domain-first paths (`orders/FooService.ts`)? Flag as a nit with the domain-first alternative; if the codebase is already layered, acknowledge the tension.

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

- **Block** if: any ticket is not independently deployable (and not explained by an explicit dependency), there's a coverage gap on a critical part of the design, or the slicing is fundamentally layer-by-layer rather than tracer-bullet throughout.
- **Request changes** if: several should-fix items (vague acceptance criteria, hidden dependencies, missing cross-cutting tickets, ordering problems).
- **Approve with comments** if: the backlog is solid with only nit-level issues.
- **Approve** if: rare. The bar is high here too.

## Output

Save the review at `docs/features/<slug>/tickets-review-<NN>.md` using the format from [review-base.md](review-base.md). When citing findings, refer to specific ticket numbers. Include the coverage table you built during the design coverage check. If the verdict is Approve or Approve with comments, suggest the next step is the implementation skill.
