---
name: handover
description: Close out a finished run: present what was built, surface the calls made where the spec was silent, and on acceptance promote what must survive and delete the paper. Runs last.
disable-model-invocation: true
---

# Handover

The run is finished and the user was not watching it. They have to decide one thing: accept this, or send it back.

The argument is where the run's paper lives - the spec file, or the directory holding it and the `tickets/` beside it.

Everything before you optimised for building without them. This step exists to give them back the judgment that was deferred - and there is exactly one class of question no review could settle, because it isn't a question about correctness at all: **where the spec was silent, the implementation chose, and whether that choice matches intent is theirs to say.**

## Two jobs, in order

Orient, then decide. A reader who doesn't yet know what was built cannot judge a decision about it, and a reader given only a narrative of what was built will accept it wholesale. Both halves, in that order.

### Orient

Open with what the system can do now that it couldn't before, in the user's terms, not the code's. Then how it works: the modules that changed, what was added, and how the pieces fit - enough that the decisions below land somewhere. Keep it short. This is the runway, not the flight; a reader who wanted a full walkthrough would read the diff.

### Decide

Surface decisions rather than defects, rank them by stakes, and never recommend accept or reject: the goal the work serves lives in the reader's head, not on this page. State each as the tradeoff it was - what it committed to, what that bought, what it gave up - so the reader can judge it rather than agree with it.

Two streams feed the ranked list:

- **Every ticket's `Record`.** The spec-silent forks each run logged. These are the core of the page: by definition the spec did not say, so nobody but the user can judge whether the default matches intent, and a different answer means rework.
- **Every `Unresolved` finding.** A review raised it and the implementer argued it down. That adjudication happened with no human present and deserves one now.

Review findings that mattered are not a third stream - `/trace` and `/critique` filed their gaps and blockers as tickets, and those were built and reviewed like everything else before the run reached you. What survives is `/critique`'s nits, which nobody acted on. Put them in a short appendix below the ranked list, not in it. They are not decisions, and mixing forty nits into the list is how the one item that needed a veto gets skimmed past.

A `Record` entry written by the agent that made the choice arrives already justified - the cost it is paying is the half you have to supply.

Rank by stakes and stop where the rest is clearly ratifiable. Twelve tickets can produce forty log entries, and a flat list of forty is a list nobody reads to the end - which is how the one that mattered gets missed.

## Promote before deleting

The spec and the tickets are deleted when the run is accepted. Whatever must outlive them has to be moved somewhere durable first, deliberately - nothing survives by being left where it is. The brief needs no deleting; it is presented inline and never written down, since a brief is spent the moment its reader decides.

Three destinations, and each is a proposal for the user, not a change you make and mention:

- **Vocabulary → `UBIQUITOUS_LANGUAGE.md`.** Terms the feature established or shifted. Discovery proposed these; this is where they land for real.
- **Load-bearing rationale → a comment at the code it explains.** The spec's `_Why:_` entries and a ticket's `Decisions` where a future reader would otherwise change the code wrongly. Follow the `coding-conventions` skill: the comment restates the rule or the reason in your own words and never points at the artifact, which is about to stop existing. Most rationale does not clear this bar - the test is whether someone who never read the spec would get it wrong without the comment.
- **Architecturally consequential choices → an ADR.** Never write one autonomously. Present the decision and a recommendation, and let the user decide whether it becomes an ADR at all.

## Accept

Only once the user says so - which means you may not get there. The driver runs this step at the end of an unattended run, where there is nobody to answer: present the brief, name the promotions you would propose, and stop. Acceptance then happens when a human runs `/handover` again with you present, and nothing is deleted until they do.

Acceptance is the deletion:

1. Make the promotions they approved.
2. Delete the spec and the `tickets/` directory.
3. Commit, staging only those paths. Never `git add -A`.

Git history keeps every deleted artifact, so nothing is lost and the deletion commit is what marks the feature accepted. If they send the work back instead, delete nothing - the tickets are the input to the next run, and a rejected run needs them intact.
