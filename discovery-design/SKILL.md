---
name: discovery-design
description: Use after /discovery (and optional /discovery-increment) when a spec is ready to implement but still leaves implementation-level decisions an implementer would otherwise pick arbitrarily. Optional depth pass. Triggers on "/discovery-design", "nail down the design", "what would an implementer have to guess", or before /implement on a non-trivial spec.
---

# Discovery Design

Given a path to a `/discovery`-shaped spec (the whole discovery doc or a single `INCREMENT-NN.md` - any filename is fine), walk it as if implementing it TDD, top to bottom, and surface every point where an implementer would otherwise just pick something. Resolve those decisions and enrich the spec in place, so `/implement` builds the intended design instead of inventing one.

This is an optional depth pass and a backstop, not a gate. `/discovery` already asks whatever surfaces while it's in focus; this skill catches the implementation-level decisions that fell outside that focus. Run it just-in-time on whatever is about to be implemented - if a large spec was split, run it per `INCREMENT`, not on the whole epic.

## Before starting

- The input is a path to the spec. If the user didn't supply one, ask before doing anything else.
- Confirm the file is recognizably `/discovery`-shaped (at minimum: Why and User Stories). If not, stop and tell the user.
- Skim the codebase for current shape - existing patterns, conventions, and structures the feature will sit in. Many decisions are already answered there; read before asking.
- Note the decisions the spec already settles. Do not re-litigate them.

## The mechanic

Walk the spec as a sequence of red/green steps. At each step ask: "to write this test and make it pass, what would I have to decide that the spec doesn't tell me - and would a plausible-but-wrong choice cause harm?"

A decision is worth surfacing only when a wrong default would hurt: it changes behavior the user would notice, costs money, risks data, or is hard to reverse once code exists. These are implementation-internal choices that no user story names - distinct from discovery's behavioral acceptance criteria, which are user-observable.

Decide and record the rest. The goal is that no decision is left for the implementer to make blind - not that every decision becomes a question.

## What to look for

A floor, not a ceiling. Follow the spec's actual shape:

- **Boundaries with the outside.** How each external dependency (SDK, network, IO) is wrapped and where the seam sits. Error, timeout, and retry behavior. Idempotency.
- **Data.** Validation rules and where they apply. Persistence shape and migration of existing rows. Defaults for sort, filter, and pagination.
- **State and flow.** State transitions and which are illegal. Ordering and concurrency. What happens on partial failure.
- **Contracts.** Request/response shapes, error formats, and the edge cases of each.

## How to ask

Ask one question per turn, and only one - same discipline as `/discovery`. Resolve what the codebase or a sensible default answers; only ask the user about decisions with a real stake (a tradeoff, a cost, a business rule).

For any decision that is significant or hard to reverse, present the decision, your recommendation, and the key alternatives, and wait for confirmation - never settle one of these silently.

Nail down concrete decisions; do not impose structure. No style mandates (function-vs-method placement, dependency direction) - just the choices this feature forces.

## When to stop

Done when every decision a wrong pick could hurt has an answer - from the codebase, a recorded default, or the user. Cheap, reversible, obvious choices (local names, file layout) stay with the implementer.

## Output

Enrich the spec in place. Present the additions and confirm with the user before writing the file back:

- Add a **Design decisions** section: each decision, its resolution, and an inline `_Why: ..._` when a wrong turn was the risk.
- Tighten existing **acceptance criteria** where a decision sharpened them.

Leave the rest of the spec untouched. The result is the same `/discovery`-shaped doc, now exhaustive enough that `/implement` picks nothing material on its own.
