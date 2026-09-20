---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-12
after:
status:    done
attempts:  1
reviews:   1
---

## Build

Split the write-time half out of `coding-conventions`: the standard for code, fired by
the act of writing code.

## Done when

> **AC-12** The coding standard is its own skill, fires whenever code is written rather
> than only under a ticket, and contains no design guidance.

## Context

The trigger is the point. Folded into `/implement`, the standard would apply only to
ticket-driven work, which is not most of what happens in this repository. It has to
fire on an ad-hoc edit too.

What leaves with it: TDD, and everything about what good code looks like here. What
stays behind for ticket 11: domain language, module boundaries, when something
deserves an ADR.

Ticket 5 assumes this exists. If this ticket is dropped, `/implement` has no standard
to lean on and grows one, which is the failure this split exists to prevent.

## Not here

Changing what the standard says. This moves it and re-aims its trigger.

## Record

`tests/standard-split.sh`, 6 cases, invoked by `tests/run.sh` (255 + 18 + 22 + 32 + 6,
green).

**AC-12, and the case that actually guards it.** `the split loses no section` reads the
headings of `coding-conventions/SKILL.md` as it stood at `c6bfc1d` and requires each to
be in exactly one half; `the split duplicates no section` is the same walk in the other
direction. Splitting a document is safe only if nothing falls between the halves, and
that is mechanical.

**`the standard carries no design guidance`** — the five design headings by name.
Naming them rather than inferring them is deliberate: which side a section belongs on
was a decision, and a decision that quietly reverts is what the case exists to catch.

**`the standard is not scoped to tickets`** — the description may not name a ticket,
because being read only under one is the precise failure this split exists to prevent.
Thin, and it pins the one thing AC-12 says about the trigger.

**Untested.** Whether the description actually fires when code is being written. That
is discovery, it is measurable the way `/slice`'s was, and it is not measured here —
the trial belongs with ticket 9, under competition from the other skills.

**What moved.** `## Domain layering` and its four subsections — domain naming, the
seams, domain objects, conceptual granularity — are the shape of a change, decided
while planning. Everything else is what the code should look like once written.

**What `coding-conventions` is now.** The design half, kept under its own name with a
narrowed description until ticket 11 turns it into the software-design skill. It was
not left holding both halves, because a standard that still contains what it was split
out of is not split.

**References.** Every skill that named the standard now names the half it meant, and
`/critique` reads both — the design half when a change moves a seam or names a new
concept. See `## Findings` for why the first attempt left three of them alone and why
that was wrong.

## Findings

One review round, six findings. All six taken.

**The deferral was wrong, and it was a live regression.** `implement/` is the one
affected skill with no `disable-model-invocation`, so it is reachable today by an
ordinary request — and this commit pointed it at a document holding `## Domain
layering` and nothing else. Four of its references became dangling section names, not
merely narrowed ones: `## Security`, `## Changing what already runs`, the input-range
rule, the untestable-boundary exception. "Deleted in ticket 12" defends the wording and
not the breakage, and ticket 12 runs after the end-to-end run — several tickets of a
build skill building to gutted guidance. Repointed, six lines.

**The inventory was incomplete in the direction that matters.** It named the three
skills being deleted and missed three that survive: `README.md`, which described
`coding-standard`'s contents under the other name and had no entry for it at all;
`cleanup-repo`, pointing at the dead-code list; `handover`, pointing at the comments
rule. Ticket 12 keeps all three, so those would have been permanently wrong.

**The suite pinned a literal commit.** `git show c6bfc1d:…` stops resolving after a
squash or a rebase, and a shallow clone never has it — at which point the suite fails
forever, blaming the split for a missing object. The before state is a fixture now,
with an explicit failure when it is unreadable.

**The reference case checked too little**, and the review said so: it verified a named
skill existed, never that a named *section* was still in it. Sections are what moved,
so that was the one failure this split could cause. It now walks every `## Section`
attributed to either half — scoped to the fifteen headings that moved, since a line may
name a spec's sections too, and skipping lines that name both halves, because
`/critique` legitimately does. Mutation-tested: attributing `## Security` to the design
half fails it.

**Two description defects.** `coding-standard` omitted `## Changing what already runs`
from its list, one of the two sections other skills single out as always binding.
`coding-conventions` advertised "which abstractions pay for themselves", a rule that
lives in the other file; it says how few and how deep the seams should be, which is
what it holds.

**Recorded.** The ticket's `## Context` promised TDD would move with the standard, and
`NEW_PIPELINE_IDEA.md` says ticket 5 can lean on it. There is no red/green/refactor rule
in `coding-standard`, because there was none in the original and `## Not here` forbids
adding one. Ticket 5 needs to know that before it starts.
