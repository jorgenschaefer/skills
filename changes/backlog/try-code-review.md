---
effort: M
utility: M
---

# Try /code-review against the pipeline's reviews

The user, on 2026-10-31, asked whether the pipeline's reviews do a code
review with Claude Code's general knowledge, and whether `run.sh` should run
`/code-review` at the end of a run as well. Their note: maybe some items can
be removed from `review-change` and delegated to `/code-review`.

The pipeline reviews code with `review-change`: after each build, spawned by
`implement-change`, and once over the whole change in the final review
(`review_brief` in `run/prompts.sh`). Its description says "use it in place
of a generic code review", and line 8: "A problem nothing here names is
still reported at full severity".

`/code-review` is built into Claude Code: a recipe tuned for correctness
bugs, at an effort level from `low` to `max`; higher levels run more
reviewers.

The parts of `review-change/SKILL.md` that overlap with it:

- under "Utility", that the code does what the design says "in the general
  case and the edge cases";
- "Callers still work";
- "Code you want deleted is really dead";
- most of "Verify before reporting": each finding is a hypothesis, and only
  one whose trigger can be named survives.

The parts only the pipeline has: the code against the design and the
journeys, a test for each journey step, tests that left, the checks, the
journeys staying unchanged, and the journeys' words in the code.

The evidence so far, from the workout-tracker run of 2026-10-31: the chunk
reviews found 6 blockers; the walks found what no code review could, such
as the offline navigation bug in chunk 08. Nothing yet shows a bug that
`review-change` missed and `/code-review` would have found.

The experiment: once a run's final review has committed `REVIEW.md`, run
`/code-review high` on the branch by hand, and compare its findings with
`REVIEW.md` and the chunks' `## Left standing`: what it finds that they do
not, and whether that holds up.

What it costs: in a new app the final diff is the whole app.
