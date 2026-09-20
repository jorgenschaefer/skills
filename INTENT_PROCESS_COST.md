# Intent: the process costs more attention than it pays back

## Problem

The pipeline grew a stage at a time, and each stage brought paper with it. A run
produces a spec carrying a domain model, a ubiquitous language section, ADRs, a
three-tier commitment model and journeys; a ticket directory; a handover; and a
specimen. Some of that is read by something. Much of it is written every run and read
by nobody, and no one has ever established which is which.

The cost is not the writing. Attention is finite at every stage, and a section nobody
reads still has to be produced, reviewed, kept consistent with the sections around it,
and re-derived whenever anything upstream changes. Paperwork that pays nothing back
crowds out the thinking that would.

The same cost shows up at the entrance. Getting work into the pipeline means choosing
which skill to invoke, and a change too small to deserve the ceremony has nowhere to
go but outside the process entirely. So the small changes — most of them — happen with
none of the checks and leave none of the record, and the process only ever gets used
for the work that was already going to be done carefully.

And it shows up at the far end, in a different currency: an unattended run that spins,
or that stops without saying why, costs more attention than the ceremony it was
supposed to save.

## Evidence

- Fifteen skills and two driver scripts for one pipeline, with two more retired during
  its life (`/discovery`, `/find-solution`).
- One topic carried five documents — intent, solution, specimen, plan, and a second
  plan file whose job was to say the first one is not the plan — totalling 1,308 lines.
  They were deleted in `267625a`; `git show 267625a --stat` is the evidence.
- The spec format requires `## Domain`, `### Ubiquitous language`, `## ADRs` and the
  `## Defaults` tiers on every run. No consumer is named for most of them, and no
  measurement has ever been attempted.
- Asked directly, the person who built it says most of it was never shown to improve
  anything.

## Done when

- **C-1** Paper is proportional to the change. Every document a change produces is
  read by something — so a change that needs no reader produces nothing, and a change
  that produces five documents has five consumers for them. Checkable against any
  delivered change by naming the reader of each page it left behind.
- **C-2** Every section every artifact requires has a named consumer: a later stage, a
  script, or a person at a stated moment. A section with no consumer is a defect, not
  a nicety.
- **C-3** No change is too small for the process. Work of any size can be started the
  same way, and nothing about starting it requires deciding first how much ceremony it
  deserves. Checkable by finding work that was deliberately done outside the process:
  there should be none, and the reason should never be "it wasn't worth the overhead".
- **C-4** An unattended run ends in exactly one of two states: finished, or stopped
  with a named reason addressed to a person. It never spins and it never stops
  silently.
- **C-5** Budgets and limits hold when the thing spending them dies, including across
  a usage limit.
- **C-6** The number of mandatory stops in the ordinary case is fixed, stated, and does
  not grow with the size of the change. Every stop beyond those is traceable to a named
  condition rather than to "the process requires one here".

## Constraints

- **Optimize for: less produced-but-unread paper.** Where a capability's value is
  unproven, dropping it is the default, and dropping it loudly is acceptable. The
  burden of proof is on keeping a section, not on removing it.
- **Prefer fewer skills to more.** Indirection has to pay for itself.
- **Nothing may require a human to babysit an unattended run.** A design that needs
  someone watching is a design that will not be run.
- **Git history is the archive.** Nothing needs to stay in the working tree to be
  preserved, so "we would lose it" is not an argument against deleting paper.
- **Off limits: weaker checks.** Fewer checks is acceptable; keeping a check but
  letting it do less is not.

## Not this

- Whether the work solved the problem it was for. That is
  `INTENT_WRONG_PROBLEM.md`, and it is a separate problem with a separate fix: pruning
  every unread section would not answer it, and answering it would not prune anything.
- Improving the quality of the code the pipeline produces. Unmeasured, and separate.
- Making the pipeline faster. Wall-clock is not the complaint.
- Anything about more than one person or more than one repository.

## Whatever they arrived with

> What are the stages of software development? It starts with the customer arriving
> with an idea (usually framed as a solution). It ends with a merged PR. What are the
> individual steps, in a modern, agile, agentic development workflow?

Followed by a proposed five-stage shape — find the problem, find a solution, plan it,
implement it, accept it — with an adversarial agent at the end of each stage, and the
question of whether that made sense.

## Open questions

- Does `ubiquitous-language-init` survive? Domain language would move into a plan-time
  skill, which leaves the glossary bootstrapper either redundant or its necessary
  counterpart.
- ~~Is discovery-by-description reliable enough to carry C-3?~~ **Answered, for the
  uncontested case.** Thirty-one headless runs against a stub skill: a second-draft
  description separated code-change planning from research, meetings and rollouts
  cleanly, and fired without the word "plan". It is stochastic — one prompt fired 3 of
  4 times — but a miss yields an ordinary plan and leaves no ticket directory, so it is
  both graceful and visible. Still untested under competition from the other skills in
  this repo, which is the case that could still overturn it. See *What the experiment
  showed* in `NEW_PIPELINE_IDEA.md`.
- Does losing memory across topics cost anything? Unknown, and the old pipeline never
  established that having it helped.

## Ratified

Not yet. Reconstructed from the conversation that produced `NEW_PIPELINE_IDEA.md`;
these conditions are one reading of what was asked for, not a confirmed one.

## Routed back

Nothing yet.
