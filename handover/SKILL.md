---
name: handover
description: Close out a run - clean, halted, or standing on something a human must rule on - by writing the pull request description for what it produced. Runs last.
disable-model-invocation: true
---

# Handover

The run is over and the user was not watching it. Your job is the pull request description: what this branch does now that it did not before, what a reviewer should look at, and what is still uncertain. One reader, one moment, one page.

The argument is where the run's paper lives - the spec file, or the directory holding it and the `tickets/` beside it. The caller also says how the run ended, and that changes what the reader needs from you rather than whether you write.

**The mechanical half is not yours.** The state the run reached, what every build recorded, which findings stand and at what stakes, and the command that comes next are all collected and printed by the driver, from the tickets themselves. Do not restate them and do not rank them - that page already exists and is beside yours. Yours is the half no file can be read off.

## What to write

- **What it does now.** In the user's terms, not the code's: the thing that works today and did not before. One paragraph.
- **How it works.** The modules that changed, what was added, how the pieces fit. Enough that a reviewer knows where to start reading. This is the runway, not the flight.
- **What to look at first.** The two or three places where a reviewer's attention is worth most - the seam that carries the most, the change with the widest blast radius, the part that was hardest to be sure of.
- **What is still uncertain.** What you would want a second opinion on, and why. Not a list of everything unresolved - the driver's page has that - but the honest answer to "where might this be wrong?"

Where the run ended halted or standing on something a human must rule on, say what was reached and what was not, in the same terms. A branch that stops halfway still has a diff someone has to read, and pretending otherwise makes it harder.

Keep it to a page. A reviewer who wanted the full walkthrough would read the diff, and a description nobody finishes is one that was never written.

## Promote before the paper goes

The spec, the tickets and any mockups the journeys were walked as are deleted when the run is accepted, and `./accept.sh` does that in one commit. Whatever must outlive them has to be moved somewhere durable first, deliberately - nothing survives by being left where it is.

Most of that already happened: terms, ADRs and ratified journeys were agreed as `/discovery` proposed them, and they live in the project rather than in the paper. What is left is the rationale a build discovered while writing the code:

- **Load-bearing rationale → a comment at the code it explains.** A ticket's `Decisions` entry where a future reader would otherwise change the code wrongly. Follow the `coding-conventions` skill: the comment restates the reason in your own words and never points at the artifact, which is about to stop existing. Most rationale does not clear this bar - the test is whether someone who never read the spec would get it wrong without the comment.
- **Vocabulary the build settled → `UBIQUITOUS_LANGUAGE.md`.** A term the code established that discovery did not name.
- **A structural choice the build discovered → an ADR.** Discovery writes the ones it knew about; a decision a build only reached with the code in front of it has no other route. `ADR_FORMAT.md` is the shape. Never write one autonomously - propose it, like the rest of this list.
- **A spec `_Why:_` that still matters → a comment.** The spec goes with the tickets, and its rationale goes with it unless somebody moves it.

Propose these; do not make them. They are the last thing the user decides before running `./accept.sh`, and a promotion made silently is one nobody agreed to.
