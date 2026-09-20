# Ticket format

One file per slice, in `tickets/<topic>/`, numbered for identity rather than for order - `after:` carries the order, and the numbers are append-only so a re-slice adds rather than renumbers.

```markdown
---
solution:  SOLUTION_<TOPIC>.md   # for the runner's drift check; sessions never open it
satisfies: AC-1, AC-4            # the criteria this slice covers
after:     2-<slug>, 5-<slug>    # dependencies, comma-separated, or empty
status:    ready                 # ready | doing | review | done | halted
attempts:  0                     # runner-owned
reviews:   0                     # runner-owned
---

## Build
<What this slice is, in a sentence or two. The change, not the method.>

## Done when
<The criteria named in `satisfies`, quoted verbatim from the solution:

> **AC-1** <exactly as the solution writes it, tag omitted>

Copied, never summarised. A paraphrase is a criterion you have quietly changed, and the builder has no way to know: it never reads the solution.>

## Context
<Enough to build this without reading the solution - what exists already, what decided the approach, where the seam is. A session gets this file and the code, nothing else.>

## Not here
<The boundary against the neighbouring tickets, and where the excluded thing lives instead. This is what stops two slices building the same thing twice.>

## Record
<Written by the build: which test names which criterion. The only evidence that a criterion was covered rather than claimed.>

## Findings
<Written by the review: what it wants changed. Absent until there are some.>

## Halt
<Written by whoever stopped - the session or the runner - naming the kind and what it was blocked on. Absent unless something stopped.>
```

## What the frontmatter is for

**`satisfies` and the quotation have to agree.** A criterion claimed and not quoted is one the builder never sees; a criterion quoted and not claimed is work no coverage check knows about.

**`status` belongs to the runner, except at its two ends.** The runner writes `doing` and `done`; a session writes `review` when it has committed, or `halted` when it has stopped. A session never claims its own work and never declares it finished.

**`attempts` and `reviews` are counters the runner owns.** They live in the file because the runner is expected to die and resume - it waits out usage limits - and a count that does not survive that is not a ceiling.
