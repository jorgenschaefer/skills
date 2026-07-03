# Feature spec format

The shape of the feature specification the `discovery` skill writes. `/implement` builds from it and traces against it: every unit of work maps back to a story or decision in the spec, and nothing in the spec is left unbuilt. Omit sections that don't apply; add subsections where the domain warrants.

```markdown
# Feature: <name>

## Why
<1-3 sentences: the problem and the desired outcome.>

## Success criteria
- <How we know the feature as a whole works - reserve per-story behavior for the acceptance criteria under User Stories>

## Non-goals
- <Explicitly out of scope>

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
- **As a** <role>, **I want to** <action>, **so that** <outcome>.
  - <acceptance criterion, as given/when/then where it fits - include only when behavior has a wrong default>
  - _Why: <rationale - include only when omitting it would let an implementer take a wrong turn>_

## Design
- <For each screen: layout and components (reused vs new), states, and an inline _Why: ..._ when a wrong turn was the risk. Greenfield, record the established design language here.>

## Implementation decisions
- <Each decision and its resolution if a wrong default would hurt, with an inline _Why: ..._ when the rationale was load-bearing.>
```

## Worked example

A fragment showing the intended granularity - terse entries, `_Why:_` only where a wrong turn was the risk:

```markdown
## User Stories
- **As a** reviewer, **I want to** reject an application with a reason, **so that** the applicant learns what to fix.
  - given a pending application, when I reject it with a non-empty reason, then its status becomes Rejected and the reason is recorded.
  - given a reason left blank, when I submit, then rejection is blocked with a validation error.
  - _Why: a silent rejection generates support tickets - the reason is not optional._

## Implementation decisions
- Rejection reasons are free text, not a fixed enum. _Why: the categories aren't stable yet; an enum would force a migration on every change._
```

User stories should be exhaustive - one per distinct workflow, including edge variations - while the nested bullets stay optional, as the template notes mark. A spec never carries an open-questions section.
