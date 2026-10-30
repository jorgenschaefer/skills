# Change format

`changes/YYYY-MM-DD-<slug>/CHANGE.md`. Where the change is split, each chunk is a file in the same shape: `changes/YYYY-MM-DD-<slug>/chunks/NN-<slug>.md`. `run.sh` reads the frontmatter, so its shape below is not decoration.

```markdown
---
journeys:  journeys/pay-an-invoice.md, journeys/send-a-reminder.md
after:                     # chunks only: the chunks to build first, comma-separated
status:    ready           # ready | doing | done | halted
attempts:  0               # the runner's
---

# <The change, in a few words>

## Problem
<The problem agreed with the developer: what is wrong and what would be true instead, with no mechanism in it. Then the one real instance it came from, and the backlog item's path where it came from one. Acceptance holds the finished change against this.>

## Design
<What to build. Where a prototype was agreed, link it - `prototype/` beside this file - with:

**Agreed: build to this, do not redesign.**

Then whichever of these the change has, each pointing at the journey steps it serves, such as "pay-an-invoice 1-2, dispute-an-invoice 1":>

### Screens
<Each screen once, however many journeys use it: what it shows and what the user can do on it.>

### Interactions
<What happens between the steps: what the software does when the user acts, and what they see while it does.>

### Data
<What the software keeps or changes, in the user's words.>

## Not in this change
<What a builder might wander into, and should not. Omit the section when there is nothing.>

## Left standing
<Written by the build: what it left unfinished or decided on its own, for the next build and for acceptance. Empty when it left nothing.>

## Halt
<Written by whoever stopped, the session or the runner: the kind of halt and what it was blocked on. Absent unless something stopped.>
```

## What the frontmatter is for

**`journeys` names the journeys this file builds.** `CHANGE.md` names every journey the change affects. Together, the chunks name every one of them. The runner checks this.

**The journeys were approved before the build.** They are changed and committed with `CHANGE.md`, and no build commit touches `journeys/`. A build that would need to is a departure, and it halts.

**`after` gives the order of the chunks.** `CHANGE.md` leaves it empty.

**`status` and `attempts` are the runner's bookkeeping.** The runner sets `doing`. A session writes `done` when it has committed its build, or `halted` when it has stopped. `attempts` lives in the file so the count survives a runner that dies and starts again.

**Without chunks, the runner builds `CHANGE.md` itself.** With chunks, `CHANGE.md` stays the whole change, for the final review and for acceptance, and its `status` is not used.

**The design holds for this change only.** A design detail that must last, such as "overdue invoices are shown in red", becomes something the user sees in a journey step, so it gets a test.

**It is not permanent.** The change's directory, prototype included, is deleted once the change is accepted. What outlives it is in the journeys, their tests and the software itself.
