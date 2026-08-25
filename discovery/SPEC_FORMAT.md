# Feature spec format

The shape of the feature specification `discovery` writes, `/spec-to-tickets` decomposes into tickets, and `/implement` builds against. It is a complete contract: every unit of work maps back to a story or decision, and nothing in it is left unbuilt. Omit sections that don't apply; add subsections where the domain warrants.

Number user stories `US-1`, `US-2`… and their acceptance criteria `US-1.1`, `US-1.2`… always, without exception. Tickets cite criteria rather than copying them, so each one needs a stable anchor to be pointed at - and a criterion with no id is a criterion no ticket can claim and no review can check off.

The spec is frozen once `/spec-to-tickets` has hashed it: each ticket carries that hash, and editing the file afterwards halts the loop. `/spec-to-tickets` marks it first - `(binding)` on every default more than one ticket has to hold to - and hashes what it leaves. Settle everything else before decomposition rather than during.

Three tiers of commitment live in this file and a reader has to be able to tell them apart:

- **Permanent** - the terms under `### Ubiquitous language`, the ADRs under `## ADRs`, and any journey ratified into a workflow test. These outlive the feature and the spec that carried them, so each gets its own explicit yes in the conversation at the moment it is proposed. Ratifying a journey is a separate yes from agreeing to it: the journey binds this feature either way, and pinning it in `tests/workflows/` binds every feature after it.
- **Defaults** - every entry marked **D-n**, wherever it stands. Most are collected under `## Defaults`; a survey verdict is marked and numbered where it is, beside the decision it qualifies. A default was decided without the evidence the builder will have, so it may be overturned on evidence found in the code. Never on taste, and never silently: the ticket that overturns one records what in the code said otherwise.
- **Binding for this feature** - everything else in the file. The build satisfies it or halts.

```markdown
# Feature: <name>

## Why
<1-3 sentences: the problem and the desired outcome.>

## Success criteria
- <How we know the feature as a whole works - reserve per-story behavior for the acceptance criteria under User Stories>

## Non-goals
- <Explicitly out of scope - not now and not later.>

## Now and later
- **Now** - <the one slice that ships: what a user can do once this is built, in a sentence.>
- **Later** - <what this feature wants next, deliberately deferred, and what would have to be true to start it. Distinct from a non-goal: a non-goal is out of scope for good, this is scope held back.>

## Constraints
- **C-1** <A non-functional limit the build must hold that no single story's acceptance criteria capture: a performance budget, a scale or volume ceiling, a security property, behavior at an external seam (timeout, retry, idempotency). Write these in EARS rather than given/when/then - `WHILE <state> the system shall <response>`, `IF <condition> THEN the system shall <response>` - which states a standing constraint in one line where Gherkin needs a scenario per case. Say how each is verified, in the future tense - `_Verified by a load test that will …_`. Many have no natural unit test, and a constraint nobody can check is a wish. The check does not exist yet, and naming one that does is how a constraint comes to be ticked off against coverage that predates the feature and was never about it. Omit the section when the feature imposes none.>

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
- **<Entity>** - <its identity and what persists through state changes. Per aggregate: what changes together, and the invariant the root holds. Always present - this is the model the feature is built on, and leaving it out does not make it absent, only unstated.>

### Domain events
- **<Event>** - <when it fires and what reacts to it - include only when an occurrence has downstream consequences an implementer must wire up.>

## Journeys
- **J-1 <the journey in the user's own words>**
  - _Trigger:_ <what starts it - the actor and the occasion.>
  - _Steps:_ <in sequence: what the actor does and what the system answers back. The last step says where its terminal action puts the user down - the screen or state they are left on - never that it is simply done.>
  - _Domain effect:_ <which actors act on which work objects, and what domain events that raises.>
  - _Screens:_ <the screens it walks through, in order, as a walk rather than a list. Where the feature has no interface, name the commands or calls it is driven through instead.>

<A journey is the whole path through the feature; the user stories below are its steps, and a story belonging to no journey is a story nobody asked for. Number them `J-1`, `J-2`… so a workflow test can quote one and a story can name it.>

## User Stories
- **US-1 · As a** <role>, **I want to** <action>, **so that** <outcome>. _(J-1)_
  - _Depends on: US-2 — <what this story needs in place first>. Omit when the story stands alone; record only real build-order dependencies, so `/spec-to-tickets` can decompose along them._
  - **US-1.1** <acceptance criterion as given/when/then - required for every behavior a wrong default could hurt; each one becomes a test written RED first. Use EARS instead (`WHILE <state> the system shall …`, `IF <condition> THEN the system shall …`) where the behavior is a standing invariant rather than an event, and given/when/then would need a scenario per case to say it.>
  - _Why: <rationale - include only when omitting it would let an implementer take a wrong turn>_

## Design
- <For each screen: layout and components (reused vs new), states, and an inline _Why: ..._ when a wrong turn was the risk. Greenfield, record the established design language here. When a mockup was load-bearing to the decision and prose can't carry the layout, keep that mockup in the repo and link it here instead of describing it.>

## Implementation decisions
- <Each decision and its resolution where a wrong default would hurt, with an inline _Why: ..._ when the rationale was load-bearing. A decision that touches existing code names the real structure it reuses or extends as a durable choice - "extend the existing `ApplicationForm`, following the profile form's validation" - not a `file:line` reference that drift will invalidate. When a decision was the user's to make - a business rule, not a reversible default - say so in its _Why:_ so a later reader or reviewer knows it's settled, not open to challenge.>
- **D-n <module>** - <every verdict of the duplication survey, module by module, the reuse and sit-beside ones included: reuse, extend, absorb, replace, or sit beside, and why. Together these are the modules this feature affects. A verdict reached with the codebase surveyed is a default and is numbered as one here; a verdict recorded nowhere reads later as a module nobody looked at, and the orphan sweep files a ticket to remove what the survey deliberately kept.> _Overturnable on: <what in the code would say otherwise.>_

## ADRs
- <Each ADR this feature is built under or establishes, by number and path: **[0004](../adr/0004-integer-minor-units.md)** - <what it decided, in a clause>. An ADR is permanent-tier: written where the alternatives are still live, and never without its own yes. `ADR_FORMAT.md` says what one contains and where it lives. Omit the section when the feature neither establishes nor leans on one.>

## Defaults
- **D-1** <what the builder should do absent evidence, stated as an instruction rather than a preference.> _Overturnable on: <what in the code would say otherwise.>_
- **D-2 (binding)** <`(binding)` is added by `/spec-to-tickets`, before the spec is hashed, to every default more than one ticket has to hold to - here or wherever else it stands. It means no ticket may overturn that default alone: the evidence one ticket finds does not settle a choice the others are already built on.>

<`D-n` is one sequence across the whole file, so a default marked in place beside a decision and one collected here never share a number.>
```

## Worked example

A fragment showing the intended granularity - terse entries, `_Why:_` only where a wrong turn was the risk:

```markdown
## Journeys
- **J-2 A reviewer turns an application down**
  - _Trigger:_ a reviewer opens an application sitting in Pending.
  - _Steps:_ 1. opens the application from the queue; 2. chooses Reject and writes a reason; 3. confirms - and lands back on the queue, one shorter, with the rejection shown at the top of it.
  - _Domain effect:_ the reviewer rejects an Application; `ApplicationRejected` fires and the applicant's notification is queued off it.
  - _Screens:_ review queue → application detail → reject dialog → review queue.

## User Stories
- **US-3 · As a** reviewer, **I want to** reject an application with a reason, **so that** the applicant learns what to fix. _(J-2)_
  - **US-3.1** given a pending application, when I reject it with a non-empty reason, then its status becomes Rejected and the reason is recorded.
  - **US-3.2** given a reason left blank, when I submit, then rejection is blocked with a validation error.
  - **US-3.3** WHILE an application is already Rejected, the system shall refuse a further rejection.
  - _Why: a silent rejection generates support tickets - the reason is not optional._

## Constraints
- **C-1** IF the notification service is unreachable THEN the system shall record the rejection and retry delivery, never losing the decision. _Verified by an integration test that will stub the service to fail and assert the rejection survives it._

## Implementation decisions
- Rejection reasons are free text, not a fixed enum. _Why: the categories aren't stable yet; an enum would force a migration on every change._
- **D-2 `notifications/`** - extend. It already queues and retries; rejection adds a template, not a delivery path. _Overturnable on: a template registry that rejects runtime additions._
- **D-3 `review/queue.py`** - sit beside. Its filtering looks close but answers a different question, and folding them would couple the queue to the decision. _Overturnable on: the two filters turning out to share a predicate already._

## Defaults
- **D-1** Show the rejection reason to the applicant verbatim rather than summarising it. _Overturnable on: an existing sanitiser every outbound message already passes through._
```

User stories should be exhaustive - one per distinct workflow, including edge variations.
