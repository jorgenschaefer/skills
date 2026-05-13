---
name: design-review
description: Use this skill to review a Design Doc produced by the Design phase before the work is broken into tickets. Trigger this whenever the user says things like "review this design doc", "critique the architecture", "is this design ready for tickets", or hands you a file from docs/features/ and asks for feedback. The output is a structured review file with findings categorized by severity. This is the highest-leverage review in the workflow — catching architectural problems here is far cheaper than catching them in code. Always use a clean context, separate from the conversation that produced the design.
---

# Design Review

This skill reviews a **Design Doc** — the artifact produced by the Design phase. Read [review-base.md](review-base.md) first for the reviewer stance, output format, and severity definitions.

Architectural problems caught here cost a review's worth of effort to fix; caught after implementation, they cost weeks.

## Setup

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding. Read the design doc from `docs/features/<slug>/design.md`.

Before reviewing, confirm:

1. The artifact is a Design Doc (it should follow the `design` skill structure: Summary, Goals/non-goals, Background, Proposed design, Alternatives considered, Risks/open questions, Out of scope).
2. You can read the Feature Brief the design is based on — a good design that solves the wrong problem is a bad design.
3. You have access to the codebase. If you don't, note it in "What was NOT checked."
4. You're in a clean context. If unsure, note it in "What was NOT checked" and flag any area where prior context might bias you.
5. You have read [`ARCHITECTURE.md`](ARCHITECTURE.md) at the project root if it exists; a design contradicting an established constraint is the most important finding at this phase. If the file doesn't exist, note it in "What was checked."

## What to check

### Alignment with the Feature Brief

- **Does the design solve the problem in the brief?** Re-read the brief's problem statement, then walk through the design and ask: how does this address that problem? If you struggle to draw the connection, that's a finding.
- **Do design goals match brief goals?** Subtle scope drift between brief and design is common — the design ends up solving an adjacent problem. Cross-check each design goal against the brief.
- **Are the brief's non-goals respected?** A design that quietly addresses non-goals is doing extra work that the brief explicitly excluded.
- **Are the brief's constraints honored?** Each constraint should either be visibly addressed in the design or explicitly noted as non-applicable.
- **Are the brief's open questions resolved?** Read the brief's open questions section. For each question, verify the design either answers it or explicitly defers it with a reason. An open question that could change the design approach and is not addressed is a should-fix.

### Domain model

- **Is there a domain model section?** If missing entirely, that is a blocker — the domain model is foundational to the rest of the design.
- **Are all objects labeled new or existing (extended)?** Each domain object should explicitly state whether it is introduced by this feature or already exists and is being modified. Ambiguity here misleads implementers.
- **Are attributes named?** "The Order has some fields" is not enough. Each attribute should be named and typed.
- **Are invariants stated?** Both per-object rules ("an Order must have at least one line item") and cross-object rules ("an Order cannot be cancelled after it has shipped") should be listed. A domain model with no invariants has not been thought through.
- **Are objects with state described as state machines?** If an object can be in different states (pending, confirmed, shipped), the states and their transitions should be named. An object described as having a "status" field but no state machine description is incomplete.
- **Is each object's code location named?** Which module implements it? New objects should say where they will live; existing objects should say which file they currently live in.
- **Is each object's persistence named?** Which table or collection? New tables should be named; existing tables should be named and the new columns or changes stated.
- **Are all domain objects in the workflows present in the domain model?** Objects that appear in workflows but not in the domain model section are a should-fix — they were forgotten.

### Workflows

- **Is there a workflow for every user story?** Every story in the Feature Brief should have a corresponding workflow narration. Missing workflows are a should-fix.
- **Is the narration at the domain level?** A workflow that says "OrderService calls PaymentAdapter" is a module trace, not a domain narration. A domain narration says "the Order transitions to confirmed and a Payment is created in authorized state." Flag module-level narration as a should-fix.
- **Are the rules checked at each step made explicit?** The workflow should name which invariants are verified and what happens when they fail.
- **Is the observable outcome stated?** Each workflow should end with what the user can observe as a result.

### The proposed design itself

Read [architecture-principles.md](architecture-principles.md) for the canonical definitions of screaming architecture, deep modules, and adapter boundaries. The review-specific criteria below (what to flag and at what severity) apply those principles to design documents.

- **Is there a diagram?** A design doc without a diagram has not fully externalized its architecture. Flag as a should-fix if missing — prose alone is insufficient for communicating component topology.
- **Are modules named and bounded?** Each module should be named and its responsibility stated. "We'll touch a bunch of stuff" is a blocker. What's new, what changes, what's untouched.
- **Are module interfaces specified?** What does each new or changed module expose to callers? What does it hide? A module whose interface is as complex as its implementation is a shallow module — a should-fix.
- **Are external systems identified?** Which databases, queues, email services, caches, or third-party APIs are involved? Which module owns the boundary to each? A design that mentions "we'll need a database" without saying which module owns it is underspecified.
- **Are communication patterns explicit?** For each module-to-module or module-to-external-system interaction, is it synchronous or asynchronous? Direct call, event, queue, or message bus? Ambiguous wiring is a should-fix.
- **Is the data model specified?** New tables, collections, or schemas — are they named, with fields and types? Existing entities needing new columns or relations — are they identified?
- **Does the design trace through a real user story?** If the doc doesn't trace a scenario end-to-end through the architecture, flag that as a should-fix — a design that can't be walked hasn't been fully thought through. Do not supply the trace yourself.
- **Are adapter boundaries specified?** The design should make clear that inbound adapters (route handlers, controllers) own authentication, input validation, and request mapping; business logic operates on domain objects only; outbound adapters (repositories, external service clients) translate domain objects to and from external formats. If the design is silent on this split, that is a should-fix.
- **Are error propagation patterns specified?** For each module-to-module interaction, what happens when the downstream fails? Synchronous error surfacing, dead-letter queue, circuit breaker, async retry — the design should name the pattern. If the design is silent on failure modes between components, flag as a should-fix.
- **Is the runtime topology specified?** How many distinct runtime components are deployed and where do they run? If the design describes modules without saying how they are grouped into processes or services, flag as a should-fix — especially when background workers, queues, or separate services are introduced.
- **Are new technology introductions justified?** If the design introduces something not already in the codebase (a new database, message broker, caching layer, third-party API), is the choice named and the rationale stated? Unjustified new dependencies are a should-fix.

### Cross-cutting architectural concerns

Read [cross-cutting-concerns.md](cross-cutting-concerns.md) and walk the full list explicitly. Check whether the design addresses each concern at the architecture level (which module is responsible, which external system handles it) — not the implementation level (specific field names, retry counts, runbook entries). Key concerns to call out explicitly:

- **Authentication and authorization.** Which module validates identity? Does the domain layer receive a token or a resolved user object? Are authorization decisions at the adapter boundary or domain layer?
- **External system ownership.** For each external system, which module owns the adapter?
- **Data migration.** If the data model changes, which module runs the migration, is it safe to run alongside old code, is rollback possible?
- **Security and PII.** New trust boundaries, sensitive data, encryption or audit concerns at the module-boundary level.
- **Performance constraints.** Latency or throughput constraints that affect architectural choices — a constraint that should influence module design but isn't reflected is a finding.
- **Multi-tenancy / data isolation** if applicable — cross-tenant leaks are a classic design-level oversight.
- **Idempotency, rate limiting, backwards compatibility, feature flags, cost of new external dependencies** — these are in the full list; missing any of them for a design that introduces them is a should-fix.

### Alternatives and reasoning

- **Are alternatives considered?** A design presenting one option as inevitable is hiding its reasoning; expect at least one alternative with explicit comparison.
- **Are the right alternatives considered?** For each major choice, ask: is there a simpler approach that would satisfy the brief? If yes and the doc doesn't address it, that's a finding.
- **Is the chosen option's tradeoff named?** If the design only lists upsides, it hasn't been honestly evaluated.

### Architectural constraints

Read [architecture.md](architecture.md) for the format and threshold criteria.

- **Does the design respect all constraints in `ARCHITECTURE.md`?** A design that silently contradicts an established constraint is a blocker.
- **Does the design surface new cross-cutting constraints?** If the design introduces a constraint that is not visible at the decision point and not already in `ARCHITECTURE.md`, a ticket to update `ARCHITECTURE.md` should have been created during the design phase. A missing update ticket for a new constraint is a should-fix.

### Existing-code awareness

Read [ubiquitous-language-update.md](ubiquitous-language-update.md) for the glossary maintenance standard. The primary check is that this design uses existing glossary terms consistently — synonyms and paraphrases for existing concepts are a should-fix. Only expect a new glossary entry when a genuinely new concept has been introduced.

- **Does the design fit existing patterns?** If the codebase has an established way to add a new service, endpoint, background job, etc., the design should follow it — or explicitly say why it deviates.
- **Does the design account for code that needs to change?** A design that proposes new modules without acknowledging the existing modules that need to be modified to integrate is incomplete.
- **Does the design use canonical names?** Check `UBIQUITOUS_LANGUAGE.md`. If the design names a module, entity, or process differently from the glossary entry for the same concept, that's a should-fix — the design will seed inconsistency in code and tickets.
- **Does the design propose to do something the codebase already does?** Reinventing existing infrastructure is a classic failure of a designer working without enough codebase context.

### Risks and uncertainty

- **Are real risks named?** A design with no risks listed is overconfident. Production code will surface risks; better to surface them now.
- **Are uncertainties marked?** Things the designer doesn't know — should they be resolved by spike, by stakeholder input, by research? If the design needs information it doesn't have, that should be explicit.
- **Is the rollback story credible?** "We'll revert if it breaks" is not a rollback plan when there are migrations or stateful changes involved.

### Cross-cutting smell tests

- **The "implementer test."** Could a competent engineer pick up this doc and start work? If they'd need to ask 10 questions before starting, it's underspecified. If they could start without reading the doc at all, it's a no-op.
- **The "six months later" test.** When someone debugs a production issue in this code six months from now, will the design doc help them understand why things were built this way?

## Common findings

To calibrate, here are the failure modes most often surfaced at this phase:

- Domain model section missing entirely
- Objects not labeled new vs. existing — implementers can't tell what already exists
- Invariants absent — the domain model lists attributes but no rules
- State machine missing for an object that clearly has lifecycle states
- A domain object appears in a workflow but not in the domain model
- Workflows written as module call graphs rather than domain narrations
- No diagram — the architecture hasn't been externalized
- Module names but no interfaces — what callers see is unspecified
- External systems mentioned but not owned by any module — the adapter boundary is missing
- Communication patterns ambiguous — "the service calls the database" without saying whether it's sync, async, queue, event, etc.
- Error propagation between components not addressed — what happens when a downstream module fails is left unspecified
- Runtime topology unstated — the design adds a background worker or queue but doesn't say how many processes exist or where they run
- New technology introduced without justification — a new database, broker, or API added with no rationale or alternatives considered
- Data model not specified — tables or schema changes described in prose but not named with fields
- No scenario traced end-to-end through the architecture
- Alternatives section listing only weak alternatives, making the chosen option look obvious by contrast
- Design diverges from existing codebase patterns without explanation
- New cross-cutting constraints with no update ticket created
- Auth and authorization not addressed at the module-boundary level
- Data migration story missing when schema changes are present

Implementation-level items (observability config, test strategy, rollout plan, runbook entries) are NOT findings here — they belong in tickets.

## Verdict guidance for this phase

- **Block** if: the domain model section is missing, module boundaries are undefined, external systems are unnamed, the design doesn't trace to the Feature Brief's user stories, or the design contradicts an established constraint in `ARCHITECTURE.md`.
- **Request changes** if: interfaces are underspecified, communication patterns are ambiguous, data model is missing, no end-to-end scenario is traced, or alternatives are absent for significant decisions.
- **Approve with comments** if: the architecture is sound, with only nit-level issues.
- **Approve** if: rare; the bar is high here.

## Output

Save the review at `docs/features/<slug>/design-review-<NN>.md` using the format from [review-base.md](review-base.md). Reference specific sections of the design. If the verdict is Approve or Approve with comments, suggest the next step is the planning skill.
