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

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

Before starting design, make sure you have:

1. **The Feature Brief (or Refactoring Proposal).** Read the entry artifact from `docs/features/<slug>/discovery.md`; if not found, try `docs/features/<slug>/refactoring.md`; if neither exists, tell the user and stop. If they want to skip discovery entirely, push back gently — at minimum get a few sentences of problem statement and goals before designing.
2. **Access to the codebase.** Most design decisions are constrained by what already exists. You need to read the existing code, not guess at it.
3. **Knowledge of the team's conventions.** Check `CLAUDE.md` / `AGENTS.md` at the repo root and any subdirectory equivalents. They tell you the existing patterns, the test framework, deployment model, etc.
4. **The project's ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Use the canonical terms in your design — for modules, entities, processes, and APIs. Don't introduce synonyms for concepts that already have names.

If any of these are missing, get them before producing a design. A design written without knowledge of the existing code is fiction.

## How to approach the work

**Read the brief with two lenses in sequence.** First for comprehension: what is being asked, what problem does the user actually have? Then for design constraints: what limits the solution space, what are the non-goals that protect you from over-building?

**Survey the existing code.** Find the modules likely affected. Read their interfaces. Look at how similar features were built before — there's usually a pattern to follow or deliberately deviate from. Note any code smells you'll need to work around or address.

**Before designing: clarification round.** Run a clarification round whenever either of the following is true:

1. **Product-technical boundary decisions exist** — specific values, defaults, thresholds, or behavioral preferences the user has in mind but that the Feature Brief doesn't specify (discovery reviewers deliberately strip these as out of scope for the Feature Brief). Common examples: a list truncates at N items, a timeout is X seconds, a feature defaults to on or off. Default toward asking rather than assuming: if you are about to write a specific value or default behavior into the design without a source for it, that is a signal to ask.

2. **An ADR is about to be written** — ADRs record significant, hard-to-reverse decisions. Before committing any ADR to paper, always present the decision, your recommendation, and the key alternatives to the user and ask for confirmation or redirection.

Collect all questions from both cases and ask them together in a single structured message, grouped by type (product decisions first, ADR confirmations second), before producing any design output. Wait for the user's response, then incorporate the answers.

If the user doesn't answer a specific question, pick a reasonable default, apply it, and flag it explicitly in the Design Doc so it can be corrected during implementation.

Skip this step only if you have genuinely found no product-technical gaps **and** no ADRs are planned.

**Prefer deep modules when drawing boundaries.** A deep module has a simple interface that hides significant complexity — callers get a lot of value with little they need to know. A shallow module's interface is nearly as complex as its implementation; it leaks rather than encapsulates. Common shallow-module smells: pass-through methods that add no logic, information leakage (exposing internal data structures or config), and abstractions too small to justify their existence. For each proposed module boundary, ask: is this module earning its abstraction? If it mostly delegates to another layer without hiding anything, merge the layers or rethink the boundary.

**Organize by domain, not by layer (screaming architecture).** When proposing folder structure or module layout, group code by business domain or feature (`orders/`, `users/`, `billing/`) rather than technical role (`controllers/`, `services/`, `models/`). The folder structure should reveal what the system *does*, not what framework it runs on. If the existing codebase is layered, note that in the Design Doc — either propose a migration path toward domain-first organization, or explicitly justify why new code will extend the layered structure.

**Design clear adapter boundaries.** Within each domain module, distinguish three layers: (1) the *inbound adapter* (route handler, controller) — authenticates, validates raw input into a domain object, calls business logic, maps the result to a response; (2) the *business logic* — operates on domain objects only, contains all domain rules, never touches HTTP types or DB types; (3) the *outbound adapter* (repository, data access) — translates domain objects to DB format, calls the DB, returns domain objects, contains no domain rules. Types must mirror this separation: validation schemas (Zod, etc.) belong only in the inbound adapter, domain types belong with the business logic, and database types (ORM entities, SQL row shapes) belong only in the outbound adapter. For simple CRUD all three can be in one file, but the concerns must be visibly distinct. Call this out explicitly in the Design Doc so implementers know where each kind of code belongs.

**Generate options before committing.** For each significant decision — one that affects more than one module or would be expensive to reverse — brainstorm at least two or three approaches. The first idea is rarely the best. Write down the alternatives even if you reject them quickly.

When uncertain about a technical choice: recommend a spike if the uncertainty could change the entire approach; record it as a risk if it's about tuning or edge cases within an already-chosen approach.

**Identify the cross-cutting concerns.** Walk this list explicitly — most design failures happen because one of these was forgotten:

- Authentication and authorization
- Observability (logging, metrics, tracing, alerting)
- Error handling, retries, and partial failure
- Rate limiting and abuse prevention
- Data migration (forwards and backwards)
- Backwards compatibility with existing clients
- Feature flags and rollout strategy
- Security and PII handling
- Performance under expected load
- Multi-tenancy / data isolation (if applicable)
- Internationalization / localization (if applicable)
- Accessibility (if user-facing)
- Cost of new cloud resources or external calls

**Trace through a concrete user scenario end-to-end.** Pick a typical use case from the brief and walk it through your proposed design from request to response (or trigger to outcome). Where does data come from? Where does it go? What can fail at each step? This usually surfaces gaps faster than abstract reasoning.

**Check terminology.** Does this design introduce new canonical terms — module names, entity names, process names — that aren't yet in `UBIQUITOUS_LANGUAGE.md`? Do any proposed names conflict with existing entries? Resolve conflicts before finalizing the design; inconsistent names in a design doc become inconsistent names in code. If a proposed name conflicts with a glossary entry for the same concept, defer to the glossary: rename the design element. If you believe the glossary entry is wrong, update the glossary and note the change in the Design Doc. The glossary is authoritative; the design adapts to it.

**Think about what changes outside the new code.** Database migrations, config changes, infrastructure changes, deployment order constraints, third-party integrations, monitoring/alerting updates, runbook entries. These are often where production incidents come from.

## Architecture Decision Records (ADRs)

Significant decisions get their own ADR file at `docs/adr/<NNNN>-<slug>.md`. The bar is intentionally high. An ADR exists so future engineers can understand *why* the system has the shape it has and avoid choices that would conflict with load-bearing constraints.

A decision warrants an ADR when **at least one** of the following is true:
1. **Hard to reverse** — undoing it later would require rework across multiple parts of the codebase, a data migration, or a coordinated change.
2. **Cross-cutting constraint** — the choice governs how future engineers must build adjacent things; knowing about it prevents inconsistency or conflict elsewhere.

Two tests to apply before writing:
- *"If we changed this in six months, what would break?"* — if the answer is "one component's configuration," skip it.
- *"Does a future engineer building something new need to know about this choice to avoid an incompatible decision?"* — if no, skip it.

Examples of decisions that warrant an ADR:
- Picking a database, message queue, or other major dependency
- Choosing a synchronous vs asynchronous architecture
- Adopting a new pattern that diverges from existing code
- Establishing a new module boundary or API contract style
- Choosing one library over another when both are viable

Examples of decisions that don't:
- Variable names, function signatures, file layout within a single module
- Things fully determined by existing conventions
- UI/UX behavior localized to a single component (default expand/collapse state, sort order, button placement)
- Configuration values that can be changed in one place without rippling through other code
- Decisions where only one option was ever seriously considered

When writing an ADR, use the structure and numbering conventions in [adr-format.md](adr-format.md).

## Writing the Design Doc

The Design Doc lives at `docs/features/<feature-slug>/design.md`. Use this structure:

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

Save the Design Doc to `docs/features/<feature-slug>/design.md` and any ADRs to `docs/adr/`. If the target directories don't exist, create them. If you can't write the files, tell the user the artifact paths and paste the content inline so they can save it manually.

If this design introduced new technical or domain terms (module names, entity names, process names, API concepts), follow the instructions in [ubiquitous-language-update.md](ubiquitous-language-update.md) to update the glossary.

If the codebase survey during design surfaced code smells or findings outside the scope of this feature, invoke the `boy-scout` skill to triage them: trivially safe fixes can be applied immediately; everything else becomes a ticket in `docs/features/boy-scout/tickets/`. Noting smells in the Design Doc is optional context; tracking them as tickets is required.

Tell the user what was written and where.

Then run an automated review in a clean context. Use the `Agent` tool with `subagent_type: "general-purpose"` so the review agent has no memory of this conversation — this gives the design fresh eyes. The agent's self-contained prompt should be:

> Invoke the `design-review` skill for feature slug `<slug>`. The Design Doc is at `docs/features/<slug>/design.md`.

After the review agent finishes, read the review file it saved at `docs/features/<slug>/design-review-<NN>.md`. Update the Design Doc and any relevant ADRs to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the design
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment

Tell the user what the review found, what was addressed, and the final verdict. Then suggest the next step is the planning phase.
