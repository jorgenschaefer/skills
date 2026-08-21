# Ticket format

The shape of the work order `/plan` and `/propose-change` emit and `/implement` consumes. One ticket is one `/implement` run: one agent, one context window, no questions asked of anyone - so everything that run needs to decide must already be decided here.

A ticket carries what to build, what it may rely on, and what it must not touch. It does not carry the requirements themselves. Those stay in the spec and are cited by id, so there is one place to change them when they change.

## Where tickets live

`tickets/NN-slug.md`, beside the spec they derive from, committed with the code. `/implement` writes its outcome back into the ticket as it finishes or halts.

Tickets are scaffolding, not documentation - they are deleted along with the spec when the run is accepted. The code and its tests are the source of truth; a finished ticket describing intent the code has since moved past is worse than no ticket. Committing them first is what makes deleting them safe: git history keeps every ticket and its `Record`, so nothing is lost, and the deletion commit marks the feature as accepted. Anything that must outlive the run is promoted somewhere durable before deletion, never left in the paper to age.

Deletion belongs to accepting the work, not to finishing it. A run that completes but is rejected still needs its tickets to re-run, and a `blocked` ticket survives until whatever blocked it is resolved.

`NN` is a zero-padded sequence in dependency order. `/propose-change` emits a single ticket in the same shape - the light lane differs in how much interviewing precedes the ticket, not in what a ticket is.

## Frontmatter

```yaml
id: 04
status: todo          # todo | done | blocked
depends_on: [02, 03]  # ticket ids that must be done first; [] when none
spec: SPEC.md         # path, relative to the ticket
spec_hash: a3f2c81d09e4
```

`status` is the loop's durable state: it picks the lowest-numbered `todo` whose `depends_on` are all `done`, and stops when none qualifies. Keeping it in the file rather than in the driver is what makes a halted run resumable.

`spec` and `spec_hash` are omitted when no spec stands behind the ticket - see *Tickets without a spec* below.

`spec_hash` is the first 12 characters of `sha256sum` over the spec file. `/plan` stamps it; `/implement` recomputes it on arrival and halts if it differs. This freezes the spec for the duration of a run: tickets cite requirements rather than copying them, so an edit to the spec mid-run would silently change what the remaining tickets mean. The hash turns that from a convention nobody remembers into a detected condition. Recovery is `/plan --refresh`, which re-derives the remaining tickets and re-stamps them.

## The body

```markdown
# <Verb phrase naming the observable change>

## Satisfies
- **US-3.1** - <a few words locating the criterion, not a copy of it>
- **US-3.2** - <...>

## Preconditions
- <What an earlier ticket built that this one stands on, named durably.>

## Touches
- <Existing structure this ticket extends or changes, named durably.>

## Provides
- <What later tickets may rely on, described by intent.>

## Out of scope
- <What not to build here.>

## Verification
- <Only where a criterion doesn't imply its own test.>
```

### Name it as a verb phrase about observable behavior

"Let a reviewer reject an application", not "add the rejection service". If you cannot name the ticket that way, the decomposition has gone horizontal - and horizontal tickets invite interfaces nothing calls, which is the failure an unattended run is least likely to catch on itself. Allow it only where a real dependency forces it, and say in `Out of scope` what must *not* be built out speculatively.

### Remediation tickets are the exception

Most tickets add behavior and the rule above governs them. A **remediation ticket** comes from a review instead - a `/trace` gap where the behavior works but no test pins it, a `/critique` blocker like three tickets each inventing their own validator - and its job is to repair something already built.

It names the defect, because there is no new behavior to name. Its `Satisfies` is the finding it resolves, quoted, with where the finding came from. Its contract is fixed and identical every time: **the finding is resolved and every existing test still passes.** That is checkable, which is what the naming rule was protecting in the first place - so the exception costs nothing.

Everything else holds. `Out of scope` still bounds it, since a consolidation ticket that drifts into redesign is the same failure as a feature ticket that scope-creeps, and the `Record` still carries what it decided and what it left `Unresolved`.

### Satisfies cites, it does not copy

Every ticket traces to numbered criteria in the spec (`US-3.1`). The text beside each id is a locator so the ticket reads on its own - enough to know which criterion is meant, not enough to be a second copy of it that can disagree with the first. `/implement` reads the spec alongside the ticket; one extra file costs an agent nothing, and one source of truth costs a refresh a great deal less.

A ticket may take a whole story or part of one, but never a criterion split across two tickets: the criterion is the smallest unit a test pins, so splitting it leaves both tickets unable to prove they are done.

### Touches and Provides are separate because drift is

`Touches` is what this ticket changes. `Provides` is what *later* tickets are allowed to depend on - and it is the only part a later ticket can be wrong about, so it is the part drift-checking reads.

Describe both by durable intent, never by signature: "the `Reservation` aggregate gains a confirmation path that rejects double-booking", not `confirm(id: string): Promise<Result>`. Tickets are written before the code exists, so a signature written here is a guess that will be wrong in detail and right in substance. Pinning the substance lets an implementer choose the shape; pinning the shape manufactures drift out of decisions that were never load-bearing.

`/implement` reconciles `Preconditions` and `Touches` against the real codebase before building. When what it finds contradicts what the ticket assumed, that is a `drift` halt - not something to work around.

### Out of scope is a guardrail, not a courtesy

No human sees the diff between one ticket and the next, so "while I'm here" goes unchecked. Name what an implementer would plausibly reach for and must not: the adjacent case a later ticket owns, the abstraction that would be premature until the third caller exists, the deferred story from the spec's non-goals that this ticket sits next to.

### Verification, only where it isn't obvious

A given/when/then criterion already implies its test, and `/implement` writes it RED first. This section is for the ones that don't: an EARS constraint with no natural unit test, a behavior that must be pinned at the integration level rather than in isolation, or a criterion two tickets could each plausibly test - where saying which one owns it prevents both from testing it, or neither.

## Tickets without a spec

`/propose-change` emits a single ticket with nothing beside it. The ticket *is* the requirements, so three things change:

- **`spec` and `spec_hash` are omitted.** Nothing to cite, nothing to freeze.
- **`Satisfies` carries the criteria in full**, given/when/then, rather than pointing at them. The rule against copying exists because copies drift from a shared source; a lone ticket has no source to drift from.
- **A `## Why` section leads the body** - one to three sentences on the problem beneath the change. In the heavy lane the spec carries intent, and an implementer who knows why is the one who notices when the literal instruction would miss the point.

`Provides` is usually empty, since no later ticket is coming to consume it. Everything else means what it means in the heavy lane.

## What `/implement` appends

A ticket is intent before the run and a record after it. `/implement` appends exactly one of these, then sets `status`.

```markdown
## Halt
**Reason:** blocked | drift | mystery | stale-spec
<What happened, and what the human needs to decide.>
```

- **blocked** - the spec contradicts itself, or a criterion cannot be met as written. Back to `/discovery`.
- **drift** - `Preconditions` or `Touches` no longer match the code. Back to `/plan --refresh`.
- **mystery** - a test will not go green and the cause is unknown after the bounded attempts. Back to `/debug`, run by a human.
- **stale-spec** - `spec_hash` does not match. Back to `/plan --refresh`.

```markdown
## Record
**Commit:** <sha>
**Decisions:**
- <a fork the spec left silent, the choice made, why, and where - file:line>
**Unresolved:**
- <a review finding left standing, and why it was judged acceptable>
```

`Decisions` is what the handover brief aggregates at the end of a run: where the spec was silent, whether the default matches intent is the user's call, and this is the only place that question gets asked. `Unresolved` is for findings deliberately not fixed - a nit judged not worth it, a should-fix the implementer argued against. Both sections stay absent when empty rather than carrying a "none".

## Worked example

```markdown
---
id: 04
status: done
depends_on: [02]
spec: SPEC.md
spec_hash: a3f2c81d09e4
---

# Let a reviewer reject an application with a reason

## Satisfies
- **US-3.1** - rejection requires a non-empty reason
- **US-3.2** - the applicant sees the reason on their status page
- **US-3.4** - a rejected application cannot be rejected again

## Preconditions
- Ticket 02 built the `Application` aggregate with its `submitted` state and the reviewer role check.

## Touches
- `Application` gains a rejection transition; the existing state guard is the place it belongs.
- The applicant status page, which already renders the approved case.

## Provides
- A rejection carries a reason string that later tickets may display; the aggregate rejects an empty one rather than defaulting it.

## Out of scope
- The rejection notification email - US-5, ticket 07 owns it.
- Bulk rejection. One application at a time; no batch path, even though the loop would be trivial.

## Verification
- US-3.4 pins at the aggregate, not the endpoint - a second rejection must fail on the invariant, not on an HTTP guard that a later caller could bypass.

## Record
**Commit:** 9f4a2c1
**Decisions:**
- Reason has no length ceiling; the spec set none and the column is `text`. Rejected a 500-char cap as invented policy - `application.ts:142`.
**Unresolved:**
- Review flagged the status page's two near-identical branches; left as-is, since the third case (withdrawn, US-6) will decide whether they generalise or diverge.
```
