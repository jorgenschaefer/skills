# Ticket format

One file per slice, in the intent's own `tickets/` directory - `intents/YYYY-MM-DD-<slug>/tickets/NN-<slug>.md` - numbered for identity rather than for order. `after:` carries the order. A number is never reused: commits and `after:` lines name tickets by it. A ticket with nothing left to build is deleted, and its number goes with it. Two digits, because a long slicing that starts at `1-` sorts `10-` before `2-`.

```markdown
---
solution:  02-SOLUTION.md        # resolved next to the tickets/ directory, not from the cwd
satisfies: AC-1, AC-4            # the criteria this slice covers
after:     02-<slug>, 05-<slug>  # dependencies, comma-separated, or empty
status:    ready                 # ready | doing | review | done | halted
attempts:  0                     # runner-owned
---

## Build
<What this slice is, in a sentence or two. The change, not the method.>

## Done when
<The criteria named in `satisfies`, quoted verbatim from the solution:

> **AC-1** <exactly as the solution writes it, tag omitted>

Copied, never summarised. A ticket carrying its own words cannot be redefined by an edit upstream, and the builder never opens the solution to find out what was meant. A paraphrase is a criterion quietly changed, in a file that claims to be quoting one.>

## Context
<Enough to build this without reading the solution - what exists already, what decided the approach, where the seam is. A session gets this file and the code, nothing else.>

## Plan
<How this gets built: the steps in order, the files each one touches, and what proves each one worked. `PLANNING.md` is the shape.

Written before the build, by whoever cut the slice, against the code as it actually is. It is not binding the way `Done when` is - a builder who finds the plan wrong says so - but it is the difference between a ticket that has been thought about and one that has been described.>

## Not here
<The boundary against the neighbouring tickets, and where the excluded thing lives instead. This is what stops two slices building the same thing twice.>

## Record
<Written by the build: which test names which criterion. The only evidence that a criterion was covered rather than claimed.

And what the build left standing - review findings not fixed and why, checks not run, departures from the plan. The walk reads it; nobody reads a build's closing message.>

## Halt
<Written by whoever stopped - the session or the runner - naming the kind and what it was blocked on. Absent unless something stopped.>
```

## What the frontmatter is for

**`satisfies` and the quotation have to agree.** A criterion claimed and not quoted is one the builder never sees; a criterion quoted and not claimed is work no coverage check knows about.

**`status` belongs to the runner, except at its two ends.** The runner writes `doing` and `done`; a session writes `review` when it has committed, or `halted` when it has stopped. A session never claims its own work and never declares it finished. The runner writes `done` into the session's commit, by amending it.

**`attempts` is a counter the runner owns.** It lives in the file because the runner is expected to die and resume - it waits out usage limits - and a count that does not survive that is not a ceiling.
