---
name: handover
description: Use to close out a finished run - present what was built, surface the calls made where the spec was silent, and on acceptance promote what must survive and delete the paper. Runs last, after /trace and /critique. Triggers on "/handover".
---

# Handover

The run is finished and the user was not watching it. They have to decide one thing: accept this, or send it back.

Everything before you optimised for building without them. This step exists to give them back the judgment that was deferred - and there is exactly one class of question no review could settle, because it isn't a question about correctness at all: **where the spec was silent, the implementation chose, and whether that choice matches intent is theirs to say.**

## Two jobs, in order

Orient, then decide. A reader who doesn't yet know what was built cannot judge a decision about it, and a reader given only a narrative of what was built will accept it wholesale. Both halves, in that order.

### Orient

Open with what the system can do now that it couldn't before, in the user's terms, not the code's. Then how it works: the modules that changed, what was added, and how the pieces fit - enough that the decisions below land somewhere. Keep it short. This is the runway, not the flight; a reader who wanted a full walkthrough would read the diff.

### Decide

Inherit `/decision-brief`'s stance wholesale: surface decisions rather than defects, rank them by stakes, never recommend accept or reject. The goal the work serves lives in the reader's head, not on this page. What differs is only the input - a built thing rather than a proposed one - and one extra source.

Three streams feed it:

- **Every ticket's `Record`.** The spec-silent forks each run logged. These are the core of the page: by definition the spec did not say, so nobody but the user can judge whether the default matches intent, and a different answer means rework.
- **Every `Unresolved` finding.** A review raised it and the implementer argued it down. That adjudication happened with no human present and deserves one now.
- **`/critique`'s findings.** Whole-feature code quality, which is judgment rather than fact - much of it nits, some of it wrong. Triage it here rather than filing it as work. Anything the user accepts as real becomes a ticket and the loop runs again.

De-spin each item the way a decision brief does: what it committed to, what that gained, and what it gave up. A `Record` entry written by the agent that made the choice arrives already justified - find the cost it is paying and name that too.

Rank by stakes and stop where the rest is clearly ratifiable. Twelve tickets can produce forty log entries, and a flat list of forty is a list nobody reads to the end - which is how the one that mattered gets missed.

## Promote before deleting

The spec, the tickets, and the briefs are deleted when the run is accepted. Whatever must outlive them has to be moved somewhere durable first, deliberately - nothing survives by being left where it is.

Three destinations, and each is a proposal for the user, not a change you make and mention:

- **Vocabulary → `UBIQUITOUS_LANGUAGE.md`.** Terms the feature established or shifted. Discovery proposed these; this is where they land for real.
- **Load-bearing rationale → a comment at the code it explains.** The spec's `_Why:_` entries and a ticket's `Decisions` where a future reader would otherwise change the code wrongly. Follow `coding-conventions/SKILL.md`: the comment restates the rule or the reason in your own words and never points at the artifact, which is about to stop existing. Most rationale does not clear this bar - the test is whether someone who never read the spec would get it wrong without the comment.
- **Architecturally consequential choices → an ADR.** Never write one autonomously. Present the decision and a recommendation, and let the user decide whether it becomes an ADR at all.

## Accept

Only once the user says so. Acceptance is the deletion:

1. Make the promotions they approved.
2. Delete the spec, the `tickets/` directory, and the briefs.
3. Commit, staging only those paths. Never `git add -A`.

Git history keeps every deleted artifact, so nothing is lost and the deletion commit is what marks the feature accepted. If they send the work back instead, delete nothing - the tickets are the input to the next run, and a rejected run needs them intact.
