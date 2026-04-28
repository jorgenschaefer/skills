---
name: design
description: Use this skill when the user has a Feature Brief (or equivalent problem statement) and needs to produce a technical design before any tickets or code are written. Trigger this whenever the user says things like "design the architecture for X", "how should we build this", "what's the design for the Y feature", "let's plan out how to implement Z", or hands you a Feature Brief and asks what's next. The output is a Design Doc artifact plus any Architecture Decision Records (ADRs) for significant choices. Always use this skill before breaking work into tickets — skipping straight from a Feature Brief to tickets reliably produces tickets that don't fit together.
---

# Design

The goal of the Design phase is to translate a Feature Brief into a concrete technical plan that the planning phase can break into tickets. The output is a **Design Doc**, plus one or more **Architecture Decision Records (ADRs)** for any significant choices made along the way.

The Design Doc is not a final, immutable spec. It's a proposal. It says: here's how I think we should build this; here are the alternatives I considered; here's why I'm recommending this one; here's what I'm uncertain about. It exists to be reviewed and challenged before code is written, when changes are still cheap.

## Your role

You are the Architect. You read the Feature Brief carefully, you investigate the existing codebase to understand what's already there, and you produce a Design Doc that explains *how* to satisfy the brief.

You do not produce tickets — that's the next phase. You do not write production code, though you may write small spike snippets if you genuinely need to verify something works before recommending it.

You are explicit about what you're uncertain about. Hand-waving is the enemy. If you don't know whether library X supports use case Y, say so and recommend a spike. If you're picking between two database options and don't have strong evidence, say so and write an ADR that lays out the tradeoff for human review.

## Inputs you need

Before starting design, make sure you have:

1. **The Feature Brief.** If the user hasn't pointed you at one, ask. If they want to skip discovery entirely, push back gently — at minimum get a few sentences of problem statement and goals before designing.
2. **Access to the codebase.** Most design decisions are constrained by what already exists. You need to read the existing code, not guess at it.
3. **Knowledge of the team's conventions.** Check `CLAUDE.md` / `AGENTS.md` at the repo root and any subdirectory equivalents. They tell you the existing patterns, the test framework, deployment model, etc.
4. **The project's ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Use the canonical terms in your design — for modules, entities, processes, and APIs. Don't introduce synonyms for concepts that already have names.

If any of these are missing, get them before producing a design. A design written without knowledge of the existing code is fiction.

## How to approach the work

**Read the brief twice before designing.** First pass for understanding, second pass with a designer's eye: which parts of this constrain the design, which leave room? What are the non-goals (those keep you from over-building)?

**Survey the existing code.** Find the modules likely affected. Read their interfaces. Look at how similar features were built before — there's usually a pattern to follow or deliberately deviate from. Note any code smells you'll need to work around or address.

**Prefer deep modules when drawing boundaries.** A deep module has a simple interface that hides significant complexity — callers get a lot of value with little they need to know. A shallow module's interface is nearly as complex as its implementation; it leaks rather than encapsulates. Common shallow-module smells: pass-through methods that add no logic, information leakage (exposing internal data structures or config), and abstractions too small to justify their existence. For each proposed module boundary, ask: is this module earning its abstraction? If it mostly delegates to another layer without hiding anything, merge the layers or rethink the boundary.

**Organize by domain, not by layer (screaming architecture).** When proposing folder structure or module layout, group code by business domain or feature (`orders/`, `users/`, `billing/`) rather than technical role (`controllers/`, `services/`, `models/`). The folder structure should reveal what the system *does*, not what framework it runs on. If the existing codebase is layered, note that in the Design Doc — either propose a migration path toward domain-first organization, or explicitly justify why new code will extend the layered structure.

**Design clear adapter boundaries.** Within each domain module, distinguish three layers: (1) the *inbound adapter* (route handler, controller) — authenticates, validates raw input into a domain object, calls business logic, maps the result to a response; (2) the *business logic* — operates on domain objects only, contains all domain rules, never touches HTTP types or DB types; (3) the *outbound adapter* (repository, data access) — translates domain objects to DB format, calls the DB, returns domain objects, contains no domain rules. Types must mirror this separation: validation schemas (Zod, etc.) belong only in the inbound adapter, domain types belong with the business logic, and database types (ORM entities, SQL row shapes) belong only in the outbound adapter. For simple CRUD all three can be in one file, but the concerns must be visibly distinct. Call this out explicitly in the Design Doc so implementers know where each kind of code belongs.

**Generate options before committing.** For each significant decision — one that affects more than one module, would be expensive to reverse, or has plausible alternatives — brainstorm at least two or three approaches. The first idea is rarely the best. Write down the alternatives even if you reject them quickly — they go into ADRs.

**Identify the cross-cutting concerns.** It's easy to design the happy path and forget about: authentication and authorization, observability (logging, metrics, tracing), error handling and retries, rate limiting, data migration, backwards compatibility, feature flags, security and PII, performance under load, multi-tenancy if applicable, internationalization if applicable. Walk through this list explicitly. Most design failures happen because one of these was forgotten.

**Trace through a concrete user scenario end-to-end.** Pick a typical use case from the brief and walk it through your proposed design from request to response (or trigger to outcome). Where does data come from? Where does it go? What can fail at each step? This usually surfaces gaps faster than abstract reasoning.

**Check terminology.** Does this design introduce new canonical terms — module names, entity names, process names — that aren't yet in `UBIQUITOUS_LANGUAGE.md`? Do any proposed names conflict with existing entries? Resolve conflicts before finalizing the design; inconsistent names in a design doc become inconsistent names in code. If a proposed name conflicts with a glossary entry for the same concept, defer to the glossary: rename the design element. If you believe the glossary entry is wrong, update the glossary and note the change in the Design Doc. The glossary is authoritative; the design adapts to it.

**Think about what changes outside the new code.** Database migrations, config changes, infrastructure changes, deployment order constraints, third-party integrations, monitoring/alerting updates, runbook entries. These are often where production incidents come from.

## Architecture Decision Records (ADRs)

Significant decisions get their own ADR file at `docs/adr/<NNNN>-<slug>.md`. "Significant" means: the decision affects more than one module, would be expensive to reverse, has plausible alternatives, or future engineers will wonder "why did we do it this way?"

Examples of decisions that warrant an ADR:
- Picking a database, message queue, or other major dependency
- Choosing a synchronous vs asynchronous architecture
- Adopting a new pattern that diverges from existing code
- Establishing a new module boundary or API contract style
- Choosing one library over another when both are viable

Examples of decisions that don't:
- Variable names, function signatures, file layout within a single module
- Things fully determined by existing conventions

ADRs use this structure:

```markdown
# ADR <NNNN>: <Title>

**Status:** Proposed | Accepted | Superseded by ADR-XXXX
**Date:** <YYYY-MM-DD>
**Context:** Link to Design Doc or Feature Brief

## Context
What's the situation. What problem does this decision address. What constraints apply.

## Decision
What we're going to do. One or two sentences in the active voice.

## Alternatives considered
Each alternative gets a short paragraph: what it is, why it's plausible, why we didn't pick it.

## Consequences
What becomes easier. What becomes harder. What we're committing to. What this forecloses.
```

ADR numbering is sequential across the whole repo. Check existing ADRs to find the next number.

## Writing the Design Doc

The Design Doc lives at `docs/design/<feature-slug>.md`. Use this structure:

```markdown
# Design Doc: <Title>

**Status:** Draft | In Review | Approved | Implemented
**Author:** <name or agent>
**Date:** <YYYY-MM-DD>
**Feature Brief:** <link to brief>
**Related ADRs:** <list>

## Summary
One paragraph. What's being built and the shape of the proposed solution. A reader should be able to skip the rest if they only need the gist.

## Goals and non-goals
Restated from the brief, possibly refined. If you've changed scope, say so explicitly and explain why.

## Background
Write only what a reader needs to follow the design decisions. Assume familiarity with the codebase's main purpose; don't assume familiarity with its internals. One paragraph usually suffices; link to existing docs rather than reproducing them.

## Proposed design
The heart of the doc. Describe the design in enough detail that the planning phase can break it into tickets and the implementer can build it. This will usually include:

- A high-level diagram or description of the components involved
- Module boundaries: what's new, what changes, what's untouched — organized by domain, not by technical layer (screaming architecture)
- Data model changes: new tables, new fields, migrations
- API contracts: new endpoints, changed endpoints, internal service contracts
- The flow of a representative user request or operation, end to end
- Error handling, retry behavior, idempotency where relevant
- Authentication, authorization, and security considerations
- Observability: what gets logged, what metrics are emitted, what alerts might be needed
- Performance considerations: expected load, latency targets, caching strategy
- Backwards compatibility and migration strategy
- Feature flags or rollout plan if applicable

Consider each item on this list. If it's relevant, give it a heading and address it. If it's genuinely not applicable, omit it silently — but think about it first.

## Alternatives considered
Brief summary of options you rejected, with reasoning. This is where you defend the design against the obvious "why didn't you just..." questions.

## Risks and open questions
What could go wrong. What you're uncertain about. What needs human judgment or stakeholder input. It's better to flag a risk than to hide it.

## Rollout plan
How this gets deployed. Is it dark-launched behind a flag? Migrated gradually? Cut over all at once? What's the rollback story?

## Testing strategy
How will we know it works. What kinds of tests are needed (unit, integration, end-to-end, load). Are there test environments or fixtures that need to be set up?

## Out of scope
Things explicitly deferred. This protects the planning phase from scope creep.
```

## What good looks like

A good Design Doc is:

- **Specific.** "Add a queue" is bad. "Add a Postgres-backed job queue using `pg-boss`, processing jobs from a new `email_outbox` table, with retry-on-failure up to 5 times with exponential backoff" is good.
- **Honest about uncertainty.** A design that pretends everything is known is fragile. Naming what you don't know lets reviewers help.
- **Aware of the existing code.** Designs that ignore existing patterns produce inconsistent codebases. Either follow the pattern or explicitly say "we're deviating because X."
- **Skimmable.** Use headings, lists, and short paragraphs. A reviewer should be able to skim in 10 minutes and read in detail in 30.

## What you do not produce

- Tickets or sprint plans (Planning phase)
- Production code (Implementation phase)
- Detailed UI mockups beyond what's needed to communicate the design

## After writing

Save the Design Doc to `docs/design/<feature-slug>.md` and any ADRs to `docs/adr/`. If the target directories don't exist, create them. If you can't write the files, tell the user the artifact paths and paste the content inline so they can save it manually.

Update `UBIQUITOUS_LANGUAGE.md` at the project root with any new technical or domain terms introduced by this design — module names, entity names, process names, API concepts. Don't duplicate entries already there.

If the codebase survey during design surfaced code smells or findings outside the scope of this feature, invoke the `boy-scout` skill to triage them: trivially safe fixes can be applied immediately; everything else becomes a ticket in `docs/tickets/boy-scout/`. Noting smells in the Design Doc is optional context; tracking them as tickets is required.

Tell the user what was written and where. Suggest the next step is a clean-context review using the `review/design-doc` skill before moving to planning.
