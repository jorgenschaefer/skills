---
name: design
description: Use this skill when the user has a Feature Brief (or equivalent problem statement) and needs to produce a technical design before any tickets or code are written. Trigger this whenever the user says things like "design the architecture for X", "how should we build this", "what's the design for the Y feature", "let's plan out how to implement Z", or hands you a Feature Brief and asks what's next. The output is a Design Doc artifact. Always use this skill before breaking work into tickets — skipping straight from a Feature Brief to tickets reliably produces tickets that don't fit together.
---

# Design

The goal of the Design phase is to describe the software architecture of the solution. The output is a **Design Doc** that names the domain entities the feature operates on and the workflows that affect them; specifies which modules are created, modified, or removed; defines their interfaces; identifies which external systems are involved; and describes how components communicate and what the data model looks like. It does not describe how to implement anything — that is the planning and implementation phases' job.

The Design Doc is a proposal - not an immutable spec. It says: here's how I think we should build this, here are the alternatives I considered, here's why I'm recommending this one, here's what I'm uncertain about. It exists to be reviewed and challenged before code is written, when changes are still cheap.

## Your role

You are the Architect. You investigate the existing codebase and produce a Design Doc describing *the architecture* needed to satisfy the brief - not how to implement it.

You do not produce tickets or production code, though you may write small spike snippets to verify something works before recommending it. Be explicit about uncertainty: if you don't know whether library X supports use case Y, say so and recommend a spike; if you're choosing between options without strong evidence, lay out the tradeoff explicitly.

## Inputs you need

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding.

Before starting design, work through these inputs in order:

**Group A — Problem understanding**

1. **The Feature Brief.** Read `docs/features/<slug>/discovery.md`.
   - If not found but `refactoring.md` exists: tell the user this feature uses the refactoring path and the next step is `planning`, not `design`. Stop.
   - If neither exists: tell the user and stop.
   - If the user wants to skip discovery entirely: push back gently — at minimum get a few sentences of problem statement and goals before designing.
   - If `docs/features/<slug>/discovery-review-*.md` exists and the most recent verdict is Block or Request changes: tell the user the discovery phase has unresolved review findings and suggest addressing them before designing. Proceed only if the user explicitly confirms.

**Group B — Codebase knowledge**

2. **Access to the codebase.** Most design decisions are constrained by what already exists. Read the existing code; do not guess at it.
3. **Team conventions.** Check `CLAUDE.md` / `AGENTS.md` at the repo root and any subdirectory equivalents. They tell you the existing patterns, the test framework, deployment model, etc.

**Group C — Shared constraints**

4. **Ubiquitous language.** Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Use the canonical terms in your design — for modules, entities, processes, and APIs. Don't introduce synonyms for concepts that already have names.
5. **Architectural constraints.** Read `ARCHITECTURE.md` at the project root if it exists. Read [architecture.md](architecture.md) for the threshold and entry format. Verify each relevant constraint against the current codebase before applying it — rationale drifts.
6. **Architecture principles.** Read [architecture-principles.md](architecture-principles.md) in full. All five principles apply to this design.

If any of these are missing, get them before producing a design. A design written without knowledge of the existing code is fiction.

## How to approach the work

**Read the brief for design constraints** — what limits the solution space, what are the non-goals that protect you from over-building?

**Survey the existing code.** Find the modules likely affected, read their interfaces, and look at how similar features were built before — there's usually a pattern to follow or deliberately deviate from. During this survey, also run the terminology check: do any proposed module names, entity names, or process names conflict with entries in `UBIQUITOUS_LANGUAGE.md`? Note conflicts now — they need to be resolved before the Design Doc is written, and may surface questions for the clarification round.

**Model the domain before designing the architecture.** The module structure should emerge from the domain model, not the other way around. Specifically: (1) identify the key domain objects — what they know, what they do, what rules constrain them; (2) trace each user story as a domain-level narration — which objects are created or modified, which rules are checked, what state transitions occur. Only then decide how to structure the modules.

**Before designing: clarification round.** Run a clarification round whenever either of the following is true:

1. **Product-technical boundary decisions exist** — specific values, defaults, thresholds, or behavioral preferences the user has in mind but that the Feature Brief doesn't specify (discovery reviewers deliberately strip these as out of scope for the Feature Brief). Common examples: a list truncates at N items, a timeout is X seconds, a feature defaults to on or off. Default toward asking rather than assuming: if you are about to write a specific value or default behavior into the design without a source for it, that is a signal to ask.

2. **A new architectural constraint is about to be added to `ARCHITECTURE.md`** — before committing any entry, always present the proposed constraint, its rule, and the rationale to the user and ask for confirmation or redirection. Adding to `ARCHITECTURE.md` without user confirmation is never acceptable.

Collect all questions from both cases and ask them together in a single structured message, grouped by type (product decisions first, architectural constraint confirmations second), before producing any design output. Wait for the user's response, then incorporate the answers. In subagent contexts or when no response arrives within one conversational turn: pick reasonable defaults (industry-standard first; failing that, consistent with similar features in the codebase; failing that, the most conservative option), apply them, and flag them in a single consolidated block at the top of the Design Doc: *"Clarification round: no response received. The following values were assumed — correct during implementation if needed: [list each assumption]."*

Skip this step only if you have genuinely found no product-technical gaps **and** no new architectural constraints are planned.

**Apply architecture principles to module design.** For each module proposed:
- **Screaming Architecture**: use domain-first naming. If the existing codebase is layered, note it explicitly in the Design Doc — propose a migration path or justify extending the layered structure.
- **SRP**: ask "whose requirements drive this module?" If two different actors, split it.
- **Common Closure**: ask "when this needs to change, what else changes?" Place code there, even if it looks like a shared utility.
- **Adapter Boundaries**: state placement explicitly — inbound adapter, domain layer, outbound adapter — so implementers know where each kind of code belongs.
- **Deep Modules**: ask "is this module earning its abstraction?" If it mostly delegates without hiding complexity, merge the layers.

**Generate options before committing.** For each significant decision — one that affects more than one module or would be expensive to reverse — brainstorm at least two or three approaches and write down the alternatives even if you reject them quickly. When uncertain: recommend a spike if the uncertainty could change the entire approach; record it as a risk if it's about tuning or edge cases within an already-chosen approach.

**Identify the cross-cutting concerns.** Walk them explicitly — most design failures happen because one of these was forgotten.

**Trace through a concrete user scenario end-to-end.** Pick a typical use case from the brief and walk it through your proposed design from request to response (or trigger to outcome). Where does data come from? Where does it go? What can fail at each step? This usually surfaces gaps faster than abstract reasoning.

**Surface NFR-driven decisions explicitly.** When a non-functional requirement from the Feature Brief (latency target, throughput, reliability) directly drives a structural decision — e.g., "we add a cache layer because the latency target rules out a database query on every request" — state that connection explicitly inline in the Proposed design, next to the decision it drives. NFRs that don't change the structure don't belong in the design doc at all.

**Finalize terminology.** After the clarification round, confirm that all module names, entity names, and process names in the design are consistent with `UBIQUITOUS_LANGUAGE.md`. If a proposed name conflicts with a glossary entry for the same concept, defer to the glossary: rename the design element. If you believe the glossary entry is wrong, note the discrepancy in the Design Doc and include the correction in the lang-update ticket (see below). The glossary is authoritative; the design adapts to it. Check also for new terms introduced by the design that should be added to the glossary (they will go in the lang-update ticket).

**Think about what changes outside the new code.** Database migrations, config changes, infrastructure changes, deployment order constraints, third-party integrations, monitoring/alerting updates, runbook entries. These are often where production incidents come from.

## Updating ARCHITECTURE.md

When the design surfaces a cross-cutting constraint that is not already in `ARCHITECTURE.md`, add it after user confirmation in the clarification round.

Read [architecture.md](architecture.md) for the threshold criteria and format. The entry belongs in `ARCHITECTURE.md` only when both conditions hold: (1) an agent working on a new feature would not naturally encounter this constraint in the files they are reading; (2) it governs choices in parts of the codebase distant from where it was first established. If it is local to one file, put a comment in that file instead.

## Writing the Design Doc

The Design Doc lives at `docs/features/<feature-slug>/design.md`. Use this structure:

```markdown
# Design Doc: <Title>

**Status:** Draft | In Review | Approved | Implemented
**Author:** <name or agent>
**Date:** <YYYY-MM-DD>
**Feature Brief:** <link to brief>

## Summary
One paragraph. What's being built and the shape of the proposed solution. A reader should be able to skip the rest if they only need the gist.

## Goals and non-goals
Restated from the brief, possibly refined. If you've changed scope, say so explicitly and explain why.

## Background
Write only what a reader needs to follow the design decisions. Assume familiarity with the codebase's main purpose; don't assume familiarity with its internals. One paragraph usually suffices; link to existing docs rather than reproducing them.

## Domain model
The business concepts this feature operates on. For each domain object — whether introduced by this feature or an existing object being extended — state explicitly which it is.

Each entry should cover:

- **New / Existing (extended)**: Is this object introduced by this feature, or does it already exist and is being modified?
- **Identity**: Is it an entity (has a unique identifier that persists over time) or a value object (defined entirely by its attributes, no independent identity)?
- **Attributes**: What does it know? Name and type each attribute.
- **Relationships**: How does it relate to other domain objects?
- **Lifecycle / state**: If it goes through distinct states, describe the state machine — states and the transitions between them.
- **Behaviors**: What can happen to it or be done with it?
- **Invariants**: What rules must always hold? List both per-object rules ("an Order must have at least one line item") and cross-object rules relevant to this object ("an Order cannot be cancelled after it has shipped").
- **Code location**: Which module in the codebase implements this object (new or existing)?
- **Persistence**: Which table or collection persists this object (new or existing)?

## Workflows
For each user story from the Feature Brief, or for a group of closely related stories, narrate what happens in the business domain when a user executes that story. This is a domain-level narration, not a module call graph — describe what happens to domain objects, not which code files are invoked. The module-level trace belongs in Proposed design.

Each workflow entry should cover:
- Which user story or stories it implements (by reference)
- Which domain objects are created, modified, or read
- Which invariants or rules are checked, and what happens on success or failure
- Which state transitions occur, and what the final state is
- The observable outcome from the user's perspective

## Proposed design
The heart of the doc. A diagram is strongly encouraged — an ASCII or structured diagram showing the components, their boundaries, and the connections between them. Prose may supplement or replace it.

The design must address these architectural concerns:

- **Modules**: which modules (files, packages, services) are created, modified, or removed. Name them. State what each one is responsible for.
- **Module interfaces**: what are the public interfaces of new or changed modules? What do callers see? What does the module hide? Signatures are formalized in the Contracts section.
- **External systems**: which databases, queues, email services, caches, third-party APIs, or other external systems are involved? Which module owns the boundary to each one?
- **Communication patterns**: how do components talk to each other? Direct calls? Async events? Message bus? Queue? Be explicit about which interactions are synchronous and which are asynchronous.
- **Data model**: what tables, collections, or schemas are created, modified, or removed? What are the fields and their types? What relations exist?
- **A representative scenario**: trace one user story from the brief end-to-end through the proposed architecture. Where does the request enter? Which modules handle it? What external systems are touched? What does the response look like?
- **Error propagation**: how do errors cross module boundaries? Is failure synchronous or asynchronous? Are there circuit breakers, dead-letter queues, or retry patterns between components? This is an architectural decision — it affects module structure. Specific retry counts and timeout values go in tickets.
- **Runtime topology**: how many distinct runtime components exist and where do they run? (e.g. "web server + separate background worker process", "single monolith", "three microservices"). This is distinct from a rollout plan — it is the architectural shape of what gets deployed.
- **New technology introductions**: if the design introduces a technology not already present in the codebase (a new database, a message queue, a caching layer, a third-party API), name it, justify the choice, and note what alternatives were considered. Existing stack choices need no justification.

Does NOT belong here: rollout plans and feature flags, test strategy, observability configuration, runbook entries, backwards-compatibility migration scripts, error handling implementation details (retry counts, timeout values, backoff). The error *propagation pattern* between modules belongs here; implementation details belong in tickets.

Security and authentication: these are architectural concerns when they affect module boundaries or the choice of external systems. Note them here at the architecture level ("the inbound adapter validates the JWT; the domain layer receives only the authenticated user identity"). Implementation details go in tickets.

## Contracts

The explicit interfaces that bound the domain from the rest of the system. Write these in the project's implementation language, or in typed pseudocode if the language is not yet fixed.

**Domain service interfaces** — the public API of each domain service or use case handler introduced or modified by this feature. For each, include: method names, parameter names and types, return type, and any raised errors or result variants.

**Adapter ports** — the interfaces the domain requires its infrastructure to satisfy. For each adapter (Repository, External Service client, event publisher, message consumer, etc.):
- Port interface name and which module declares it
- Method signatures
- Direction: inbound (adapter drives the domain) or outbound (domain drives the adapter)

These contracts are the primary artifact for verifying domain purity: if a port interface references an infrastructure type (ORM entity, HTTP response object, raw DB row), the domain boundary is leaking.

## Alternatives considered
Brief summary of architectural options you rejected, with reasoning. This is where you defend the design against the obvious "why didn't you just..." questions. Focus on structural choices (different module boundaries, different communication patterns, different external systems), not on implementation alternatives.

## Risks and open questions
What could go wrong at the architectural level. What you're uncertain about. What needs human judgment or stakeholder input before the planning phase can begin. It's better to flag a risk than to hide it.

## Out of scope
Things explicitly deferred. This protects the planning phase from scope creep.
```

## What good looks like

A good Design Doc is architectural (not implementational), specific at boundary level ("add an async task queue between `OrderService` and `NotificationAdapter`" not "add a queue"), honest about uncertainty, aware of existing patterns (follow or explicitly deviate), and skimmable in under 10 minutes from diagram plus headings.

## When the design is complete

Proceed to writing the Design Doc when all of the following are true:

- Every domain object the feature operates on is named in the Domain model section, with new vs. existing stated explicitly
- Every user story has a corresponding workflow narration in the Workflows section
- Every open question from the brief is either resolved in the design or explicitly deferred with a reason
- All modules, their interfaces, and their connections to external systems are named
- Every domain service and adapter port introduced by the feature has an entry in the Contracts section with typed signatures
- The domain model's code location and persistence entries are consistent with the module architecture
- Any new architectural constraints have been confirmed with the user

If you find yourself writing "TBD" or "to be determined in implementation" for module boundaries or interfaces, that's a signal the design isn't done yet. "TBD in implementation" for implementation details inside a module is fine.

## After writing

Save the Design Doc to `docs/features/<feature-slug>/design.md`. If the target directory doesn't exist, create it. If you can't write the file, tell the user the artifact path and paste the content inline so they can save it manually.

If the design surfaced new cross-cutting constraints confirmed in the clarification round, create `docs/features/<feature-slug>/tickets/arch-update.md` (create the directory if needed). The ticket goal is to add the constraints to `ARCHITECTURE.md`; copy the exact constraint text into the acceptance criteria, following [architecture.md](architecture.md) for the entry format. Use these headers: **Status:** Backlog, **Entry artifact:** this design doc, **Depends on:** none, **Estimate:** S.

If this design introduced new technical or domain terms (module names, entity names, process names, API concepts) — or if any glossary corrections were identified during the terminology check — create `docs/features/<feature-slug>/tickets/lang-update.md` (create the directory if needed). The ticket goal is to update `UBIQUITOUS_LANGUAGE.md`; include each term, its definition, and any corrections in the acceptance criteria, following [ubiquitous-language-update.md](ubiquitous-language-update.md). Use the same ticket headers.

If the codebase survey surfaced code smells or findings outside this feature's scope, collect them and use the `Agent` tool with `subagent_type: "general-purpose"` to hand them off. The agent's self-contained prompt should be:

> Invoke the `boy-scout` skill. The following incidental findings were noticed during the design survey for feature slug `<slug>`:
>
> `<paste the list of findings here, one per line, each with file path and description>`
>
> Triage each finding: apply trivially safe fixes immediately; write a ticket at `docs/features/boy-scout/tickets/` for everything else. The `Noticed during` field should read: "design survey for `<slug>`".

Tracking findings as tickets is required; noting them in the Design Doc is optional.

Tell the user what was written and where.

Then run an automated review in a clean context. Use the `Agent` tool with `subagent_type: "general-purpose"`. The agent's self-contained prompt should be:

> Invoke the `design-review` skill for feature slug `<slug>`. The Design Doc is at `docs/features/<slug>/design.md`. The Feature Brief is at `docs/features/<slug>/discovery.md`.

After the review agent finishes, list `docs/features/<slug>/` and open the newest `design-review-*.md` file (the one just created). Update the Design Doc to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the design
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment

If any findings were at Blocker severity, run the automated review once more after addressing them (same subagent prompt above) — a self-corrected blocker should be verified by a fresh review pass.

Tell the user what the review found, what was addressed, and the final verdict. If the final verdict is Approve or Approve with comments, suggest the planning phase as the next step. If the final verdict is Block or Request changes, surface the remaining findings and ask the user how to proceed — do not suggest advancing to planning.
