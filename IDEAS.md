# NOTES

## Findings
- I never see the proposed domain model + actions
- /plan has a bad name, it's confused with the /plan mode command
- A run can stop without halting. Ticket 14 of notebooklm-mvp ended `end_turn`/
  success with status still `todo` and no `## Halt`: the model left the baseline
  `npm run check` in a background task and ended its turn waiting on it. In
  `claude -p`, end_turn is process exit, so Monitor and background tasks never
  report back. /implement forbids this for review dispatches; nothing covered
  the verification command.

## Pipeline

Three changes, ranked by leverage. Evaluated 2026-08-21 across the whole flow
(discovery -> plan -> loop.sh -> implement/trace/critique -> handover).

### 1. Executed evidence instead of prose review

The verification stack is model-judging-model almost everywhere. Deterministic:
the check command and the test suite. On top of those sit four prose reviews
(quality, code, /trace, /critique), all the same model marking its own homework.
/trace names this itself - "the one check in the pipeline that isn't" - and then
declines to fix it: mutation testing only where a tool is already configured,
plus an explicit `Don't install tooling`. So most projects get the fallback
/trace itself calls "proves less".

- Make mutation testing over the ticket diff a per-ticket gate. It mechanically
  checks the exact property /implement claims (every behavior pinned by a test
  that would fail without it), and it catches the gap on the ticket nothing is
  built on yet instead of ten tickets later.
- Let it replace the quality review rather than join it. That review already
  runs only once, is the first thing dropped under REVIEWS=code, and a surviving
  mutant answers its core question objectively.
- Add an acceptance step that drives the running system. The spec has a Design
  section with screens and states; nothing in the pipeline ever renders one.

Touches: trace/SKILL.md (the tooling ban), implement/SKILL.md (Review it),
loop.sh (REVIEWS). Costs a one-time tooling ticket per project - which is what
the ban currently forbids, so that rule is the one that has to go.

### 2. Heterogeneous models, and parallel tickets over the DAG

Every step is `claude -p` with one model in a fresh serial session.

- A different model for the reviews than for the implementation is the cheapest
  available gain in independence: a flag, not a redesign. Same for staggering
  reasoning effort - /plan (dekomposition, costliest mistake) and a sha256
  comparison get the same budget today.
- Wall clock is the sum of all tickets although `depends_on` already declares
  the DAG. Keep the uncertainty-first prologue serial - that ordering is why a
  halt costs one ticket instead of ten - and parallelise the independent tail in
  worktrees.
- Then REVIEWS=code can die. It trades quality for time; parallelism trades
  money for time, which is the better trade.

Touches: loop.sh (run_step, drain), plan/SKILL.md (its ordering rule already
fits).

### 3. Let the driver recover mechanically, and keep evidence from a run

- `drift` and `stale-spec` have a documented mechanical recovery - /plan
  --refresh - and the driver never calls it. It retries infrastructure failure
  eight times over three hours but gives up on a rename at 2am. A refresh is not
  a guess; it re-derives from the code as it is. Bound it to one per run and to
  those two reasons and the no-guessing contract holds. `blocked` and `mystery`
  still need a human.
- Logs go to /tmp and are explicitly discarded ("debugging aids, not
  artifacts"), so nothing accumulates: which halt reasons recur, which
  convention findings repeat, how often the second review round finds anything,
  cost per ticket. That is the only empirical input /improve-skill could have,
  and the skills are currently iterated by feel.

Touches: loop.sh (drain, the halt path, LOG_DIR), improve-skill/SKILL.md.

### Considered and rejected

- Warming context across tickets. The cold start is why a ticket is a closed
  unit. At most prime facts (check command, baseline sha), never judgment.
- Relaxing MAX_PASSES=2. Non-convergence is a signal, not a budget problem.
- Touching the two-door structure or the split test. Both hold up.

## Skill Notes

### cleanup-repo

Works ok

## coding-conventions

Works ok

## critique

Generalize so it's called automatically for any kind of code review?

## debug

Drop?

## decision-brief

Meh. Better, have a summary of the discovery output spec.

## discovery

Does not focus enough on MVP and does not cleanly separate "now" and "later" features.

## git-commit-message

Works great

## handover

Not attempted yet?

## implement

More generic implementation, trigger for any kind of implementation work.

## improve-skill

Works ok

## plan

Needs a different name

## propose-change

Not tried yet

## repo-overview

Could get a better architecture overview?

Explain the architecture of the project in the current repository. Include domain modules / objects and the domain actions they support.

## trace

Should this be merged into critique? It is a code review, but it is not a critique of the code itself, but of the traceability of the code to the spec.

## ubiquitous-language-init

Is this still useful?

## upgrade-dependencies

Needs a better trigger so it's called automatically when dependencies need to be upgraded
Could be made more generic, also for installing new dependencies, not just upgrading existing ones?

