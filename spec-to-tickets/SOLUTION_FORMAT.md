# Solution spec format

The shape of the spec `/to-solution` writes from an intent: the problem carried forward, the field that was weighed, the one that won, and the parts whoever builds it works through.

## Two states of one file

**As `/to-solution` writes it**, the spec is read by a person or a planning agent. No journeys, no numbered criteria, no hash. A spec for a document, a process or a skill stops here and is complete.

**As `/spec-to-tickets` hardens it**, the same file gains what a reader did not need and a run with nobody in it does: `## Journeys`, the testable `US-n.m` derived from each part's *Done when*, `C-n` on the constraints, `(binding)` on every default more than one ticket has to hold to. Then it is hashed, and every ticket carries that hash - so an edit afterwards halts the loop. That step runs only when an unattended build is about to start, which is why nothing below is numbered until it does.

Three tiers of commitment live in this file and a reader has to be able to tell them apart:

- **Permanent** - the terms under `### Ubiquitous language` and the ADRs under `## ADRs`. These outlive the deliverable and the spec that carried it, so each gets its own explicit yes in the conversation at the moment it is proposed, never a brief at the end that nobody reads to the bottom of.
- **Defaults** - every entry marked **D-n**, wherever it stands. Most are collected under `## Defaults`; a survey verdict is marked and numbered where it is, beside the decision it qualifies. A default was decided without the evidence the builder will have, so it may be overturned on evidence found in the corpus. Never on taste, and never silently: whoever overturns one records what said otherwise.
- **Binding for this deliverable** - everything else in the file. The build satisfies it or stops.

`D-n` is one sequence across the whole file, so a default marked in place beside a decision and one collected at the end never share a number.

Omit sections that do not apply.

```markdown
# Solution: <the deliverable, in a few words>

## Why
<The problem, carried from the intent. The problem, not the solution. Where your cold re-derivation disagreed with the intent, record the reading that survived and say that the two differed.>

## Solution
- **Chosen** - <the approach in a sentence or two, and what it extends or introduces.>
- **Rejected** - <each candidate that lost, one line, with the decision criterion or constraint it lost to. Include what the user arrived with wherever that is not what was chosen, and say where they overruled the recommendation.>

## What decided it
<What the candidates were ranked against, in the order agreed before anything was scored.>

## Standards
<Which standing standards the design was held to, and the shape each imposed. Write this section even when the search found nothing. Then any contradiction between two of them left unresolved, naming both.>

## Domain
<The actors, the work objects they act on, the actions and the events that matter. Per aggregate: what changes together, and the invariant its root holds. Where the corpus is a codebase that is a boundary in the code; where it is a process or a document it is which steps have to move together.>

### Bounded context
<One line - include only where the deliverable crosses or establishes a boundary.>

### Ubiquitous language
- **<Term>** - <one line - include only where a reader's default reading would be wrong, or the term belongs in the project's ubiquitous language. Permanent-tier.>

### Roles
- **<Role>** - <what it can do and where that stops - include only the roles this deliverable actually gives work to, reusing the ones the corpus already has where they fit.>

### Work objects
- **<Entity>** - <its identity and what persists through state changes. Per aggregate: what changes together, and the invariant the root holds. Always present - this is the model the deliverable is built on, and leaving it out does not make it absent, only unstated.>

### Domain events
- **<Event>** - <when it fires and what reacts to it - include only where an occurrence has downstream consequences somebody has to wire up.>

## Design
<The thing itself, in whatever form the domain uses. Where a specimen was built - a mockup, a draft, a worked example - link it rather than describing it: whoever builds this builds against what was agreed, not against a paragraph about it.>

<Then, per surface the specimen walks - a screen, a command, a section, a step: what it is made of and which parts are reused rather than new, the states it can be in, and an inline _Why: ..._ where a wrong turn was the risk. This is what the specimen shows and cannot say, and it is where the testable criteria come from - `/spec-to-tickets` reads each part's _Done when_ against this section.>

## Implementation decisions
- <Each decision whoever builds this would otherwise have to make, and its resolution, with an inline _Why: ..._ where the rationale was load-bearing. A decision that touches what already exists names the real thing it reuses or extends - "extend the existing `ApplicationForm`, following the profile form's validation" - never a `file:line` that drift will invalidate. Where the decision was the user's rather than a reversible default, say so, so a later reader knows it is settled and not open.>
- **D-n <what it is about>** - <every verdict of the survey of what already exists, piece by piece, the reuse and sit-beside ones included: reuse, extend, absorb, replace, or sit beside, and why. Together these are what the deliverable affects. A verdict reached with the corpus surveyed is a default and is numbered as one here; a verdict recorded nowhere reads later as something nobody looked at.> _Overturnable on: <what in the corpus would say otherwise.>_

## Parts
<Each piece the deliverable is made of, in an order that can be worked through:>
- **<name>** - <what it is.> Depends on: <other parts, or nothing.> Done when: <what is observably true - as many statements as the part has ends, not one sentence per part. This is what `/spec-to-tickets` derives the testable criteria from, read against `## Design`, so write each as something that could be driven.>

## Scope
- **Now** - <what this slice delivers.>
- **Later** - <deliberately deferred, and what would have to be true to start it.>
- **Never** - <out of scope for good.>

## Success criteria
- <How anyone tells this worked, once it is built. Observable from outside the thing, and written so it could be driven: given/when/then, or EARS (`WHILE <state> the system shall …`) where the behaviour is a standing invariant rather than an event. These stay feature-level and unnumbered - the numbered criteria come from the parts.>

## Constraints
- <What any answer had to hold to, carried from the intent plus whatever the design added. Each says how it will be verified, in the future tense. A constraint nobody can check is a wish.>

## Defaults
- **D-n** <what the builder should do absent evidence, stated as an instruction rather than a preference.>
  _Overturnable on: <what in the corpus would say otherwise.>_

## ADRs
- <Each ADR this design is built under or establishes, by number and path: **[0004](../adr/0004-integer-minor-units.md)** - <what it decided, in a clause>. Permanent-tier: written where the alternatives are still live, and never without its own yes. `ADR_FORMAT.md` is the shape.>

## Open concerns
<What neither you nor the user could settle, each named as a guess: what was assumed, what would settle it, and what changes if it goes the other way. Everything here has a decision attached and was agreed.>
```

## What hardening adds

`/spec-to-tickets` writes these into the same file when an unattended build is about to start, and nothing else does. They are here because three things downstream read them - `TICKET_FORMAT.md`'s `Satisfies`, `/implement`, and `/check-against-spec` - and a shape each of them parses cannot be left to whoever writes it.

```markdown
## Journeys
- **J-1 <the journey in the user's own words>**
  - _Trigger:_ <what starts it - the actor and the occasion.>
  - _Steps:_ <in sequence: what the actor does and what the system answers back. The last step says where its terminal action puts the user down - the screen or state they are left on - never that it is simply done.>
  - _Domain effect:_ <which actors act on which work objects, and what domain events that raises.>
  - _Surfaces:_ <the screens it walks through, in order, as a walk rather than a list. Where there is no interface, the commands or calls it is driven through.>

<Derived from `## Design` and `## Parts`, and shown back before decomposition. `/check-against-spec` drives them as its script.>

## Parts
- **<name>** - <unchanged.> Depends on: <unchanged.> Done when: <unchanged.>
  - **US-1.1** <one testable criterion, `n` being the part's index. Given/when/then, or EARS (`WHILE <state> the system shall …`, `IF <condition> THEN the system shall …`) where the behaviour is a standing invariant rather than an event. Each becomes a test written RED first, and exactly one ticket claims it.>

## Constraints
- **C-1** <unchanged text, now numbered.> _Verified by <the check, in the future tense>._

## Defaults
- **D-2 (binding)** <`(binding)` is added here, and wherever else a `D-n` stands, to every default more than one ticket has to hold to. It means no ticket may overturn that default alone: the evidence one ticket finds does not settle a choice the others are already built on, so a ticket that finds such evidence stops instead.>
```

Then the file is hashed, and every ticket carries the first 12 characters of that hash. Tickets cite criteria rather than copying them, so an edit afterwards would silently change what the unbuilt ones mean - which is why the marks go in before the hash and never after.
