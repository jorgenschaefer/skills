# Ticket format

One file per slice, in the change's own `tickets/` directory - `changes/YYYY-MM-DD-<slug>/tickets/NN-<slug>.md` - numbered for identity rather than for order. `after:` carries the order. A number is never reused: commits and `after:` lines name tickets by it. A ticket with nothing left to build is deleted, and its number goes with it. Two digits, because a long slicing that starts at `1-` sorts `10-` before `2-`.

```markdown
---
criteria:  CRITERIA.md           # resolved next to the tickets/ directory, not from the cwd
closes:    AC-1                  # the ACs true once this slice is built
advances:  AC-4                  # the ACs this slice builds part of, closed by a later one
after:     02-<slug>, 05-<slug>  # dependencies, comma-separated, or empty
status:    ready                 # ready | doing | done | halted
attempts:  0                     # runner-owned
---

## Build
<What this slice is, in a sentence or two. The change, not the method.>

## Done when
<The ACs named in `closes`, quoted verbatim from `CRITERIA.md`:

> **AC-1** <exactly as `CRITERIA.md` writes it>

Copied, never summarised. A ticket carrying its own words cannot be redefined by an edit upstream, and the builder never opens `CRITERIA.md` to find out what was meant. A paraphrase is a criterion quietly changed, in a file that claims to be quoting one.

Then, for each AC under `## Toward`, the part of it this slice makes true, in plain words and not quoted: "CSV export works, without filters". Observable like an AC, and narrower than the one it serves - never beside it or beyond it.>

## Toward
<The ACs named in `advances`, quoted verbatim the same way, so the builder sees the whole of what its part is for. Omit the section when `advances` is empty.>

## Nudges
<The nudges this slice bears on, quoted verbatim from `CRITERIA.md`, one quote each with a blank line between:

> <exactly as `CRITERIA.md` writes it>

Soft: nothing checks the build against them, but a departure from one is recorded under `## Left standing`, with the reason. Empty when none bears on this slice.>

## Context
<Enough to build this without reading `CRITERIA.md` - what exists already, the agreed design and its specimen where it bears on this slice, where the seam is. A session gets this file and the code, nothing else.>

## Plan
<How this gets built: the steps in order, the files each one touches, and what proves each one worked. `PLANNING.md` is the shape.

Written before the build, by whoever cut the slice, against the code as it actually is. It is not binding the way `Done when` is - a builder who finds the plan wrong says so - but it is the difference between a ticket that has been thought about and one that has been described.>

## Not here
<The boundary against the neighbouring tickets, and where the excluded thing lives instead, and the lines of `CRITERIA.md`'s `Out of scope` a builder here would otherwise wander into.>

## Left standing
<Written by the build: review findings not fixed and why, checks not run, each AC this slice closes or advances that no automated test proves and how it was checked instead, departures from the plan, and departures from a nudge with the reason. Nothing else - a fixed finding or an AC a test proves is what `status: done` already says, and listing them buries the lines worth reading. Printed at the end of the run, read by the later builds and at acceptance. Empty when the build left nothing.>

## Halt
<Written by whoever stopped - the session or the runner - naming the kind and what it was blocked on. Absent unless something stopped.>
```

## What the frontmatter is for

**A ticket that only splits a large file closes and advances nothing.** Both fields are empty, it quotes no AC, and its `Done when` names the files it splits into - source and test, one test file per source file - with the behaviour unchanged and the checks green. The tickets that add to the file come `after:` it.

**`closes` and `advances` have to agree with the quotation.** An AC claimed and not quoted is one the builder never sees; an AC quoted and not claimed is work no coverage check knows about. The runner checks both.

**Every AC is closed by exactly one ticket, and that ticket comes after every one that advances it**, directly or by way of others. The closing ticket writes the AC's test, and one built before the parts it rests on writes a test nothing can pass yet. The runner checks this too.

**`doing` belongs to the runner; a session ends it.** A session writes `done` when it has committed its build, or `halted` when it has stopped. The runner sends back a `done` with no commit behind it.

**`attempts` is a counter the runner owns.** It lives in the file because the runner is expected to die and resume - it waits out usage limits - and a count that does not survive that is not a ceiling.
