# Feature spec format

The shape of the feature specification `discovery` writes, `/plan` decomposes into tickets, and `/implement` builds against. It is a complete contract: every unit of work maps back to a story or decision, and nothing in it is left unbuilt. Omit sections that don't apply; add subsections where the domain warrants.

Number user stories `US-1`, `US-2`… and their acceptance criteria `US-1.1`, `US-1.2`… always, without exception. Tickets cite criteria rather than copying them, so each one needs a stable anchor to be pointed at - and a criterion with no id is a criterion no ticket can claim and no review can check off.

The spec is frozen once `/plan` runs: each ticket carries a hash of this file, and editing it mid-run halts the loop. Settle it before decomposition rather than during.

```markdown
# Feature: <name>

## Why
<1-3 sentences: the problem and the desired outcome.>

## Success criteria
- <How we know the feature as a whole works - reserve per-story behavior for the acceptance criteria under User Stories>

## Non-goals
- <Explicitly out of scope>

## Constraints
- **C-1** <A non-functional limit the build must hold that no single story's acceptance criteria capture: a performance budget, a scale or volume ceiling, a security property, behavior at an external seam (timeout, retry, idempotency). Write these in EARS rather than given/when/then - `WHILE <state> the system shall <response>`, `IF <condition> THEN the system shall <response>` - which states a standing constraint in one line where Gherkin needs a scenario per case. Say how each is verified: many have no natural unit test, and a constraint nobody can check is a wish. Omit the section when the feature imposes none.>

## Preconditions
- <What must already exist for this to build - the baseline. Omit when nothing beyond the current codebase is required.>

## Domain

### Bounded context
<One line on the context this feature lives in - include only when the feature crosses or establishes a context boundary; omit for a single-context feature.>

### Ubiquitous language
- **<Term>** - <one-line definition - include only when an implementer's default reading would be wrong, or the term belongs in the project's ubiquitous language>

### Roles
- **<Role>** - <capabilities and scope - include only roles used in the user stories, reusing existing codebase roles where they fit>

### Work objects
- **<Entity>** - <its identity and what persists through state changes; if it belongs to an aggregate, name the root and the invariant the root enforces. Include only when identity, boundary, or an invariant is non-obvious enough that a wrong default would hurt.>

### Domain events
- **<Event>** - <when it fires and what reacts to it - include only when an occurrence has downstream consequences an implementer must wire up.>

## User Stories
- **US-1 · As a** <role>, **I want to** <action>, **so that** <outcome>.
  - _Depends on: US-2 — <what this story needs in place first>. Omit when the story stands alone; record only real build-order dependencies, so `/plan` can decompose along them._
  - **US-1.1** <acceptance criterion as given/when/then - required for every behavior a wrong default could hurt; each one becomes a test written RED first. Use EARS instead (`WHILE <state> the system shall …`, `IF <condition> THEN the system shall …`) where the behavior is a standing invariant rather than an event, and given/when/then would need a scenario per case to say it.>
  - _Why: <rationale - include only when omitting it would let an implementer take a wrong turn>_

## Design
- <For each screen: layout and components (reused vs new), states, and an inline _Why: ..._ when a wrong turn was the risk. Greenfield, record the established design language here. When a mockup was load-bearing to the decision and prose can't carry the layout, keep that mockup in the repo and link it here instead of describing it.>

## Implementation decisions
- <Each decision and its resolution where a wrong default would hurt, with an inline _Why: ..._ when the rationale was load-bearing. A decision that touches existing code names the real structure it reuses or extends as a durable choice - "extend the existing `ApplicationForm`, following the profile form's validation" - not a `file:line` reference that drift will invalidate. When a decision was the user's to make - a business rule, not a reversible default - say so in its _Why:_ so a later reader or reviewer knows it's settled, not open to challenge.>
```

## Worked example

A fragment showing the intended granularity - terse entries, `_Why:_` only where a wrong turn was the risk:

```markdown
## User Stories
- **US-3 · As a** reviewer, **I want to** reject an application with a reason, **so that** the applicant learns what to fix.
  - **US-3.1** given a pending application, when I reject it with a non-empty reason, then its status becomes Rejected and the reason is recorded.
  - **US-3.2** given a reason left blank, when I submit, then rejection is blocked with a validation error.
  - **US-3.3** WHILE an application is already Rejected, the system shall refuse a further rejection.
  - _Why: a silent rejection generates support tickets - the reason is not optional._

## Constraints
- **C-1** IF the notification service is unreachable THEN the system shall record the rejection and retry delivery, never losing the decision. _Verified by an integration test with the service stubbed to fail._

## Implementation decisions
- Rejection reasons are free text, not a fixed enum. _Why: the categories aren't stable yet; an enum would force a migration on every change._
```

User stories should be exhaustive - one per distinct workflow, including edge variations.
