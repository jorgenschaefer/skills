# Ticket format

The shape of the work order `/spec-to-tickets` and `/discovery` emit and `/implement` consumes. One ticket is one build: one agent, one context window - and in an unattended run, nobody to ask, so everything that run needs to decide must already be decided here.

A ticket carries what to build, what it may rely on, and what it must not touch. It does not carry the requirements themselves. Those stay in the spec and are cited by id, so there is one place to change them when they change.

## Where tickets live

`tickets/NN-slug.md`, beside the spec they derive from, committed with the code. The build writes its outcome back into the ticket as it finishes or halts.

Tickets are scaffolding, not documentation - they are deleted along with the spec when the run is accepted. The code and its tests are the source of truth; a finished ticket describing intent the code has since moved past is worse than no ticket. Committing them first is what makes deleting them safe: git history keeps every ticket and its `Record`, so nothing is lost, and the deletion commit marks the feature as accepted. Anything that must outlive the run is promoted somewhere durable before deletion, never left in the paper to age.

Deletion belongs to accepting the work, not to finishing it. A run that completes but is rejected still needs its tickets to re-run, and a `blocked` ticket survives until whatever blocked it is resolved.

`NN` is a zero-padded sequence in dependency order. `/discovery`'s small lane emits a single ticket in the same shape - the lanes differ in how much interviewing precedes the ticket, not in what a ticket is.

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

`spec_hash` is the first 12 characters of `sha256sum` over the spec file. `/spec-to-tickets` stamps it; `/implement` recomputes it on arrival and halts if it differs. This freezes the spec for the duration of a run: tickets cite requirements rather than copying them, so an edit to the spec mid-run would silently change what the remaining tickets mean. The hash turns that from a convention nobody remembers into a detected condition. Recovery is `/spec-to-tickets --refresh`, which re-derives the remaining tickets and re-stamps them.

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

Most tickets add behavior and the rule above governs them. A **remediation ticket** comes from a review instead - a `/check-against-spec` gap where the behavior works but no test pins it, a `/critique` blocker like three tickets each inventing their own validator - and its job is to repair something already built.

It names the defect, because there is no new behavior to name. Its `Satisfies` is the finding it resolves, quoted, with where the finding came from. Its contract is fixed and identical every time: **the finding is resolved and every existing test still passes.** That is checkable, which is what the naming rule was protecting in the first place - so the exception costs nothing.

Where the finding is a criterion nothing pins, the ticket names the **whole** criterion and every part of it left unpinned - not only the part whatever found the gap happened to reach. A criterion pinned in halves by two tickets a pass apart is one gap found twice, at twice the cost.

Everything else holds. `Out of scope` still bounds it, since a consolidation ticket that drifts into redesign is the same failure as a feature ticket that scope-creeps, and the `Record` still carries what it decided, what it left `Unresolved`, and what it left open.

### Satisfies cites, it does not copy

Every ticket traces to numbered criteria in the spec (`US-3.1`). The text beside each id is a locator so the ticket reads on its own - enough to know which criterion is meant, not enough to be a second copy of it that can disagree with the first. `/implement` reads the spec alongside the ticket; one extra file costs an agent nothing, and one source of truth costs a refresh a great deal less.

A ticket may take a whole story or part of one, but never a criterion split across two tickets: the criterion is the smallest unit a test pins, so splitting it leaves both tickets unable to prove they are done.

### Touches and Provides are separate because drift is

`Touches` is what this ticket changes. `Provides` is what *later* tickets are allowed to depend on - and it is the only part a later ticket can be wrong about, so it is the part drift-checking reads.

Describe both by durable intent, never by signature: "the `Reservation` aggregate gains a confirmation path that rejects double-booking", not `confirm(id: string): Promise<Result>`. Tickets are written before the code exists, so a signature written here is a guess that will be wrong in detail and right in substance. Pinning the substance lets an implementer choose the shape; pinning the shape manufactures drift out of decisions that were never load-bearing.

`/implement` reconciles `Preconditions` and `Touches` against the real codebase before building. When what it finds contradicts what the ticket assumed, that is a `drift` halt - not something to work around.

### Out of scope is a guardrail, not a courtesy

No human sees the diff between one ticket and the next, so "while I'm here" goes unchecked. Name what an implementer would plausibly reach for and must not: the adjacent case a later ticket owns, the abstraction that would be premature until the third caller exists, the deferred story from the spec's non-goals that this ticket sits next to.

### Verification says how, never whether

A given/when/then criterion already implies its test, and `/implement` writes it RED first. This section is for the ones that don't: an EARS constraint with no natural unit test, a behavior that must be pinned at the integration level rather than in isolation, or a criterion two tickets could each plausibly test - where saying which one owns it prevents both from testing it, or neither.

What it never says is that a criterion cannot be checked. "No test" is not a verification plan. A criterion nobody can pin is a defect in the spec: found while decomposing, it goes back to `/discovery`; found while building, it stops that build as `blocked`. Either way it never becomes a line in this section. The cases that look uncheckable usually are not - a criterion over a README, a glossary, a module comment or a workflow file is pinned by asserting on that file's text.

## Tickets without a spec

`/discovery` emits a single ticket with nothing beside it when the change is small enough that a spec would be ceremony. The ticket *is* the requirements, so three things change:

- **`spec` and `spec_hash` are omitted.** Nothing to cite, nothing to freeze.
- **`Satisfies` carries the criteria in full**, given/when/then, rather than pointing at them. The rule against copying exists because copies drift from a shared source; a lone ticket has no source to drift from.
- **A `## Why` section leads the body** - one to three sentences on the problem beneath the change. In the spec lane the spec carries intent, and an implementer who knows why is the one who notices when the literal instruction would miss the point.

`Provides` is usually empty, since no later ticket is coming to consume it. Everything else means what it means in the spec lane.

## What the build appends

A ticket is intent before the run and a record after it. Exactly one of these is appended, then `status` is set. `/implement` writes the `## Record`; the `## Halt` block and `status` belong to whoever called it, which for an unattended run is `/implement-ticket`.

```markdown
## Halt
**Reason:** blocked | drift | mystery | stale-spec
<What happened, and what the human needs to decide.>
```

- **blocked** - the spec contradicts itself, or a criterion cannot be met as written. Back to `/discovery`.
- **drift** - `Preconditions` or `Touches` no longer match the code. Back to `/spec-to-tickets --refresh`.
- **mystery** - a test will not go green and the cause is unknown after the bounded attempts. Back to a human to diagnose.
- **stale-spec** - `spec_hash` does not match. Back to `/spec-to-tickets --refresh`.

```markdown
## Record
**Commit:** <sha>
**Pinned by:**
- **US-3.1** - <the test that fails without this criterion, named so anyone can run it> (RED run in this ticket)
**Decisions:**
- **[high]** <a fork the spec left silent, the choice made, why, and where - file:line>
**Unresolved:**
- **[low]** <a review finding left standing, and why it was judged acceptable>
**Left open:**
- <a gap found here and deliberately not closed: what is wrong, where, and which criterion or constraint you believe covers it - or that none does>
```

`Pinned by` answers, for every id in `Satisfies`, which test would fail if that criterion's behaviour were removed - and says whether the proof is the RED run this ticket wrote, or a restore-and-break check against a test it did not write. A whole suite passing says nothing about the one criterion nobody wrote a test for, so the claim is made per id or not at all.

`Decisions` is what the handover brief aggregates at the end of a run: where the spec was silent, whether the default matches intent is the user's call, and this is the only place that question gets asked. `Unresolved` is for findings deliberately not fixed - a nit judged not worth it, a should-fix the implementer argued against. A section stays absent when empty rather than carrying a "none".

**Every `Decisions` and `Unresolved` entry opens with its stakes**, in exactly the form `**[high]**`, `**[medium]**` or `**[low]**`, marked as the entry is written and while the reasoning is still live. The mark is what it costs to have been wrong:

- **[high]** - it reaches past this ticket. Another ticket's `Preconditions` or `Provides` names what it decided, or the difference is visible outside the code. Being wrong means rework, not an edit.
- **[medium]** - it is contained in what this ticket built. Being wrong means changing this ticket's code and nothing else.
- **[low]** - local, reversible, or cosmetic.

For an `Unresolved` entry the question is the same one asked of the finding: if the reviewer was right, what does leaving it cost?

The driver sorts the run's report on that mark, so nothing is ranked at the end by an agent re-reading twelve tickets cold and guessing which fork mattered. Stakes are the cost of being wrong, never how hard the decision felt.

**A ticket that overturns one of the spec's defaults records it in `Decisions`** with the evidence that overturned it - the file, and what it showed. A default marked `(binding)` is not one ticket's to overturn: other tickets are already built on it, so evidence against one is a `blocked` halt rather than a decision.

**`Left open` is a lead, not a verdict.** A gap this ticket found and deliberately did not close - because another ticket owns it, or because nothing in the spec covers it - belongs there rather than nowhere. What separates it from `Unresolved` is provenance: a review raised an `Unresolved` finding and the implementer argued it down, while nobody has ruled on this one at all. What separates it from `Out of scope` is time: `Out of scope` is what the ticket was told not to build, written before the run, and this is what the run found on its way past. It is written for the end-of-run reviews to look at and judge for themselves.

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
**Pinned by:**
- **US-3.1** - `application.test.ts` "rejects without a reason" (RED run in this ticket)
- **US-3.2** - `status-page.test.tsx` "shows the rejection reason" (RED run in this ticket)
- **US-3.4** - `application.test.ts` "refuses a second rejection" (pre-existing; removed the guard, watched it fail, restored)
**Decisions:**
- **[high]** Reason has no length ceiling; the spec set none and the column is `text`. Rejected a 500-char cap as invented policy - `application.ts:142`. Ticket 07's email templating consumes the same string.
**Unresolved:**
- **[low]** Review flagged the status page's two near-identical branches; left as-is, since the third case (withdrawn, US-6) will decide whether they generalise or diverge.
**Left open:**
- The reviewer queue counts pending applications with its own query rather than the aggregate's - `queue.ts:31`. Nothing in this spec covers it; it is not wrong today, and it will disagree the first time a status is added.
```
