---
name: review-design-doc
description: Use this skill to review a Design Doc (and any associated ADRs) produced by the Design phase before the work is broken into tickets. Trigger this whenever the user says things like "review this design doc", "critique the architecture", "is this design ready for tickets", or hands you a file from docs/design/ and asks for feedback. The output is a structured review file with findings categorized by severity. This is the highest-leverage review in the workflow — catching architectural problems here is far cheaper than catching them in code. Always use a clean context, separate from the conversation that produced the design.
---

# Design Doc Review

This skill reviews a **Design Doc** and any associated **ADRs** — the artifacts produced by the Design phase. It builds on the shared review base; read `../SKILL.md` first for the reviewer stance, output format, and severity definitions.

This is the highest-leverage review in the workflow. Architectural problems caught here cost a review's worth of effort to fix. Caught after implementation, they cost weeks. Read carefully and skeptically.

## Setup

Before reviewing, confirm:

1. The artifact is a Design Doc (it should follow the `design` skill structure: Summary, Goals/non-goals, Background, Proposed design, Alternatives considered, Risks/open questions, Rollout plan, Testing strategy, Out of scope).
2. You can read the Feature Brief the design is based on. The design must be evaluated against the brief — a good design that solves the wrong problem is a bad design.
3. You have access to the codebase. Many design issues only become visible when you check the design against existing code. If you don't have access, note it in "What was NOT checked."
4. You're in a clean context.

## What to check

Walk through these questions. Each corresponds to a common failure mode of design at this stage.

### Alignment with the Feature Brief

- **Does the design solve the problem in the brief?** Re-read the brief's problem statement, then walk through the design and ask: how does this address that problem? If you struggle to draw the connection, that's a finding.
- **Do design goals match brief goals?** Subtle scope drift between brief and design is common — the design ends up solving an adjacent problem. Cross-check each design goal against the brief.
- **Are the brief's non-goals respected?** A design that quietly addresses non-goals is doing extra work that the brief explicitly excluded.
- **Are the brief's constraints honored?** Each constraint should either be visibly addressed in the design or explicitly noted as non-applicable.

### The proposed design itself

- **Is the design specific?** "We'll add a service" is not a design. A design says what the service does, what its interface is, what data it owns, how it's deployed, how it fails. Look for hand-waving.
- **Is the data model clear?** New tables, new columns, new types — are they specified? Is the migration story addressed (forwards and backwards)? Do existing entities need new constraints or relations?
- **Are the API contracts specified?** New endpoints, changed endpoints, internal RPC contracts — are signatures, payloads, error shapes, and idempotency semantics specified?
- **Does the design trace through a real user scenario?** Walk through one yourself if the doc doesn't. Where does data come from, where does it go, what can fail at each hop?
- **Are module boundaries clear?** What's new, what changes, what's untouched. Diffuse "we'll touch a bunch of stuff" designs are hard to ticket and hard to review. Also ask whether proposed modules are *deep*: a deep module hides significant complexity behind a simple interface; a shallow module's interface is nearly as complex as its implementation. Common shallow-module smells: pass-through layers, information leakage (exposing internal data structures or config to callers), and abstractions too thin to justify their existence. A shallow module boundary is a should-fix finding — either merge the layers or explain what complexity the boundary genuinely hides.

### Cross-cutting concerns

This is where most design failures hide. Check each one explicitly. If the design doesn't mention something on this list and it's relevant, that's a finding.

- **Authentication and authorization.** Who can call this? What permissions are required? Are roles defined? Does the design respect existing auth patterns?
- **Observability.** What gets logged? What metrics emitted? What traces? What alerts will operators need? Is there enough signal to debug a production issue?
- **Error handling.** What can fail, and what happens when it does? Is retry behavior specified? Are errors surfaced to users in a useful way? Are partial failures handled?
- **Idempotency.** For anything that mutates state, can it be safely retried? If not, why is that OK?
- **Rate limiting and abuse.** Can this endpoint be misused? At what rate? Is there a backpressure or quota mechanism?
- **Data migration.** If existing data needs to change shape or backfill, is the migration described? Is it reversible? Does it have a tested dry-run path?
- **Backwards compatibility.** Does this break existing clients, internal or external? If so, how is the transition handled?
- **Security and PII.** Does the design touch sensitive data? Is encryption at rest / in transit handled? Are audit requirements addressed?
- **Performance.** Expected load, latency targets, bottlenecks, caching strategy. "It'll be fine" is not a performance design.
- **Multi-tenancy / data isolation** if applicable. Cross-tenant leaks are a classic design oversight.
- **Internationalization / localization** if applicable.
- **Accessibility** if there's any user-facing surface.
- **Cost.** New cloud resources? Storage growth? External service calls that meter?

### Alternatives and reasoning

- **Are alternatives considered?** A design that presents one option as inevitable is hiding its reasoning. Push for at least one alternative with explicit comparison.
- **Are the right alternatives considered?** Sometimes the doc lists alternatives but skips the obvious one. If you can think of an obvious option the doc didn't address, ask.
- **Is the chosen option's tradeoff named?** Every choice trades something for something. If the design only lists upsides of the chosen option, it hasn't been honestly evaluated.

### Architecture Decision Records

- **Are significant decisions captured in ADRs?** Each major decision in the design (database choice, sync vs async, new dependency, new pattern) should have an ADR. Designs that bury major decisions in prose are hard to revisit.
- **Are existing ADRs respected?** The design may contradict a prior ADR without realizing it. Spot-check.
- **Do ADRs follow the format?** Status, Context, Decision, Alternatives, Consequences. Check the consequences section in particular — many ADRs hand-wave it.

### Existing-code awareness

- **Does the design fit existing patterns?** If the codebase has an established way to add a new service, endpoint, background job, etc., the design should follow it — or explicitly say why it deviates.
- **Does the design account for code that needs to change?** A design that proposes new modules without acknowledging the existing modules that need to be modified to integrate is incomplete.
- **Does the design use canonical names?** Check `UBIQUITOUS_LANGUAGE.md`. If the design names a module, entity, or process differently from the glossary entry for the same concept, that's a should-fix — the design will seed inconsistency in code and tickets.
- **Does the design propose to do something the codebase already does?** Reinventing existing infrastructure is a classic failure of a designer working without enough codebase context.

### Risks and uncertainty

- **Are real risks named?** A design with no risks listed is overconfident. Production code will surface risks; better to surface them now.
- **Are uncertainties marked?** Things the designer doesn't know — should they be resolved by spike, by stakeholder input, by research? If the design needs information it doesn't have, that should be explicit.
- **Is the rollback story credible?** "We'll revert if it breaks" is not a rollback plan when there are migrations or stateful changes involved.

### Rollout and operations

- **Is there a rollout plan?** Cut-over? Feature flag? Gradual percent rollout? Shadow mode?
- **Are flags and config changes specified?** "We'll add a feature flag" is incomplete — what's its name, default, who controls it, how is it removed?
- **Are operational concerns addressed?** Runbook entries, on-call implications, alerting changes.

### Testing strategy

- **Is test coverage planned at the right levels?** Unit, integration, end-to-end, load. A design that doesn't mention testing has often forgotten some level.
- **Are the hard-to-test parts called out?** Things involving real network, real concurrency, real third-party services often need explicit thought.

### Cross-cutting smell tests

- **The "implementer test."** Could a competent engineer pick up this doc and start work? If they'd need to ask 10 questions before starting, it's underspecified. If they could start without reading the doc at all, it's a no-op.
- **The "six months later" test.** When someone debugs a production issue in this code six months from now, will the design doc help them understand why things were built this way?
- **The "lipstick test."** Strip away the formatting and section headers. Does the prose describe a real plan, or does it gesture at one? Some designs look thorough but are mostly heading scaffolding around vague paragraphs.

## Common findings

To calibrate, here are the failure modes most often surfaced at this phase:

- Cross-cutting concerns missing entirely (especially observability, error handling, migration)
- The "happy path" is designed but failure modes aren't
- API contracts hand-waved ("we'll define the schema during implementation")
- Alternatives section listing only weak alternatives, making the chosen option look obvious by contrast
- Design diverges from existing codebase patterns without explanation
- ADRs missing for genuinely significant decisions
- Rollback story incomplete or unrealistic
- Performance assumptions stated as facts without measurement
- Auth and authorization treated as someone else's problem
- Testing strategy listed only at the unit level when the design clearly needs integration coverage

## Verdict guidance for this phase

- **Block** if: a critical cross-cutting concern is unaddressed (auth, security, data migration, observability for a production-critical path), the design doesn't actually solve the brief's problem, or major decisions are made without ADRs.
- **Request changes** if: there are several should-fix gaps (under-specified contracts, missing alternatives, weak rollback plan, incomplete cross-cutting coverage).
- **Approve with comments** if: the design is sound, with only nit-level issues.
- **Approve** if: rare; the bar is high here.

## Output

Save the review at `docs/reviews/design-doc-<feature-slug>-<YYYY-MM-DD>.md` using the format from the shared review base. Reference specific sections of the design. If you reviewed ADRs, list them and review each one's consequences section in particular. Suggest next steps based on verdict.
