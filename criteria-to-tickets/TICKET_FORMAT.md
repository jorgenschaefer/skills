# Ticket format

One file per slice, in the change's own `tickets/` directory - `changes/YYYY-MM-DD-<slug>/tickets/NN-<slug>.md` - numbered for identity rather than for order. `after:` carries the order. A number is never reused: commits and `after:` lines name tickets by it. A ticket with nothing left to build is deleted, and its number goes with it. Two digits, because a long slicing that starts at `1-` sorts `10-` before `2-`.

```markdown
---
criteria:  CRITERIA.md           # resolved next to the tickets/ directory, not from the cwd
satisfies: AC-1, AC-4            # the ACs this slice covers
after:     02-<slug>, 05-<slug>  # dependencies, comma-separated, or empty
status:    ready                 # ready | doing | done | halted
attempts:  0                     # runner-owned
---

## Build
<What this slice is, in a sentence or two. The change, not the method.>

## Done when
<The ACs named in `satisfies`, quoted verbatim from `CRITERIA.md`:

> **AC-1** <exactly as `CRITERIA.md` writes it>

Copied, never summarised. A ticket carrying its own words cannot be redefined by an edit upstream, and the builder never opens `CRITERIA.md` to find out what was meant. A paraphrase is a criterion quietly changed, in a file that claims to be quoting one.>

## Nudges
<The nudges this slice bears on, quoted verbatim from `CRITERIA.md`, one quote each with a blank line between:

> <exactly as `CRITERIA.md` writes it>

Soft: nothing checks the build against them, but a departure from one is recorded under `### Left standing`, with the reason. Empty when none bears on this slice.>

## Context
<Enough to build this without reading `CRITERIA.md` - what exists already, the agreed design and its specimen where it bears on this slice, where the seam is. A session gets this file and the code, nothing else.>

## Plan
<How this gets built: the steps in order, the files each one touches, and what proves each one worked. `PLANNING.md` is the shape.

Written before the build, by whoever cut the slice, against the code as it actually is. It is not binding the way `Done when` is - a builder who finds the plan wrong says so - but it is the difference between a ticket that has been thought about and one that has been described.>

## Not here
<The boundary against the neighbouring tickets, and where the excluded thing lives instead, and the lines of `CRITERIA.md`'s `Out of scope` a builder here would otherwise wander into.>

## Record
<Written by the build: which test names which AC, and the command that ran the checks. The only evidence that an AC was covered rather than claimed.

### Left standing
Review findings not fixed and why, checks not run, departures from the plan, and departures from a nudge with the reason. Printed at the end of the run and read at acceptance.>

## Halt
<Written by whoever stopped - the session or the runner - naming the kind and what it was blocked on. Absent unless something stopped.>
```

## What the frontmatter is for

**`satisfies` and the quotation have to agree.** An AC claimed and not quoted is one the builder never sees; an AC quoted and not claimed is work no coverage check knows about.

**`doing` belongs to the runner; a session ends it.** A session writes `done` when it has committed its build, or `halted` when it has stopped. The runner sends back a `done` with no commit behind it.

**`attempts` is a counter the runner owns.** It lives in the file because the runner is expected to die and resume - it waits out usage limits - and a count that does not survive that is not a ceiling.
