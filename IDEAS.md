# Ideas

The parking lot: candidates for this repository, still being weighed. Every
entry says what problem it solves, what it would touch, and what it costs.
`/discovery` reads this file the way it reads a target project's - something
parked here may belong in the feature being specified.

Work that is decided rather than weighed lives in `FILTERED_IDEAS.md`.
Everything this file used to carry as a numbered entry has been through that
filter and is either on that list or in *Rejected* below.

The two things kept here permanently are the run accounting the decided work
argues from, and the rejected list, which exists so nothing gets re-proposed.

## Two runs, cited throughout

The empirical baseline. Most of `FILTERED_IDEAS.md` cites one of these two runs,
so the accounting sits here once rather than in every item.

`kh-finder` (`spec-dokumentbestand`) finished at 15 tickets: 4 planned, 11
filed by `/trace` and `/critique` during the run. `everlast-notebooklm`
(`notebooklm-mvp`, then `finalize`) finished at 29 and **has not converged**:
13 planned, 16 filed, ticket 29 still `todo`, five restarts across two branch
names, and the last three critique passes spent on a test-only diff.

Not all 27 late tickets are defects in the pipeline. Duplication found once
three copies existed, a vocabulary split, a suite poisoning its own database,
and a defect in a late fix caught by critique after trace are the yield the
reviews exist for. The ones that should not have got that far each name their
tickets in `FILTERED_IDEAS.md`.

Transcripts were under `/tmp/loop-spec-dokumentbestand-*`,
`/tmp/loop-notebooklm-mvp-*` and `/tmp/loop-finalize-*`; the tickets themselves
under each project's `docs/tickets/`. That the evidence for every fix on the
decided list sat in `$TMPDIR` is the gap *Keep the run's evidence* closes.

## New ideas

None parked yet. Append here with the problem, the touches and the cost.

## Rejected

Kept so they don't get re-proposed. The first group predates the filtering pass;
the second came out of it.

### Standing

- **Warming context across tickets.** The cold start is why a ticket is a closed
  unit. At most prime facts (check command, baseline sha), never judgment.
- **Relaxing `MAX_PASSES=2`.** Non-convergence is a signal, not a budget
  problem. What is worth fixing is the reset that routes around it, which is on
  the decided list.
- **OpenSpec's living capability specs**, updated by ADDED/MODIFIED/REMOVED
  deltas and archived per change. Stale specs are worse than none; the archive
  discipline is the maintenance burden the delete policy avoids on purpose. The
  decided list answers the same need from the opposite side - the durable
  functional record is executable, so it cannot go stale unnoticed.
- **A closing step that ratifies decisions after the run.** Both `/handover` and
  `/decision-brief` died of it. A ranked list handed to a reader with no live
  memory of the argument behind any item gets skimmed, not decided.
  Ratification belongs at the moment the decision is live; what follows a run is
  a report. Re-proposing it as "but shorter" is the same shape - which is why
  the five-line receipt on the decided list has its cap written into the skill.
- **A shared file for the split test and the other cross-skill rules.** The
  split test, the one-question-per-turn rule and treat-the-verdict-as-a-claim
  each live at three sites. They were reconciled in place instead: a file per
  rule buys parity for three sentences and costs another artifact to keep in
  step. The copies read identically, so a grep is the check.
- **BMAD's named persona agents.** Ceremony without gain; the rule that the
  reviewer does not know about tickets is the better instinct.
- **Spec Kit's article that every feature must begin as a standalone library.**
  Flatly contradicts YAGNI and deep-modules.

### From the filtering pass

- **Three named layers (craft / contract / orchestration) and a sorting test.**
  A taxonomy over a one-file problem. `/discovery` cannot split without leaving
  a hole in its own deliverable - `SPEC_FORMAT.md` is 76 lines of which 4 touch
  the loop - and the stated payoff is either reuse outside the loop, which the
  proposal disclaimed, or deletion pressure, which persisting the run's evidence
  delivers directly. The one extraction the corpus demanded survives as
  `/implement-ticket`.
- **A grep test enforcing that layering.** Written to enforce the taxonomy
  above. Its token list also omitted `ticket` and `spec`, the exact vocabulary
  its own hits table counted.
- **`SKILLS_DIR` in `loop.sh`, and five format copies down to one.** Rests on an
  unverified claim about the install layout, creates drift between the checked-
  out driver and the installed skills it would name, and no defect has ever been
  traced to the copies. Their byte-identical parity stays deliberate: diff is
  the check, and cross-skill relative paths break on independent install.
- **Merging `/check-against-spec` into `/critique`.** Two differently-bounded
  mandates; `/critique` is deliberately spec-blind; the merged skill would carry
  both bars separately anyway. Turning the first into an Abnahme pushes them
  further apart.
- **Splitting `/discovery` into `/discovery` and a new `/solution`.** The survey
  and the ADR source, its two real payoffs, are kept inside `/discovery` on the
  decided list.
- **Parallelising the independent tail in worktrees.** The most expensive item
  proposed, and it buys wall clock. The measured failure is convergence -
  everlast finished 29 tickets without converging - not throughput.
- **A slow-suite fallback** running the workflow tests only at the final gate.
- **The report as the clean run's deletion commit message.**
- **Stating the iron law once in `coding-conventions`.** Consolidation with no
  evidence of harm behind it.
- **The two-door structure.** Superseded rather than upheld: `/propose-change`
  is deleted and `/discovery` becomes the sole entry with three terminals.
