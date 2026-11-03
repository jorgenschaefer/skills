---
effort: M
utility: L
---

# The pipeline's code reviews find too little; try /code-review against them

The user, on 2026-10-31, asked whether the pipeline's reviews do a code
review with Claude Code's general knowledge, and whether `run.sh` should run
`/code-review` at the end of a run as well. Their note: maybe some items can
be removed from `review-code` and delegated to `/code-review`.

The pipeline reviews code with `review-code`: after each build, spawned by
`implement-code`, and once over the whole change in the end review of
`run.sh` (`review_brief` in `run/prompts.sh`). At acceptance,
`review-change` runs it again on the whole change. Line 8 of
`review-code/SKILL.md`: "A problem nothing here names is still reported at
full severity".

`/code-review` is built into Claude Code: a recipe tuned for correctness
bugs, at an effort level from `low` to `max`; higher levels run more
reviewers.

The parts of `review-code/SKILL.md` that overlap with it:

- that the code does what the spec says "in the general case and the edge
  cases";
- "Callers still work";
- "Code you want deleted is really dead";
- most of "Verify before reporting": each finding is a hypothesis, and only
  one whose trigger can be named survives.

The parts only the pipeline has: the code against the spec, what could go,
what is hard to undo, tests that left, the checks and the `.hard.` tests in
`review-code`; the journeys, a hard test for each journey step, the
constraints and the journeys' words in the code in `review-change`.

The evidence so far, from the workout-tracker run of 2026-10-31: the chunk
reviews found 6 blockers; the walks found what no code review could, such
as the offline navigation bug in chunk 08. Nothing yet shows a bug that
`review-change` missed and `/code-review` would have found.

More evidence, from ausgaben on 2026-11-01 (two small changes, one chunk
each):

- The reviews got short. Each took about a minute and 7 tool calls, and
  found nothing. The `critique` reviews of the old pipeline in the same
  project took 2 to 7 minutes and 10 to 21 tool calls, usually in two
  rounds. The changes were smaller, so this alone proves little.
- The review missed a test that did not follow its journey. The test for
  monat-abschliessen 4 (`app/debt/page.test.tsx`) used a different example
  from the journey's and was written to match what the app showed. The
  reviewer wrote that it "covers step 4". The builder flagged it itself in
  its halt. `review-change` asks for exactly this check: "a test that would
  still pass with the step broken is no test".
- Acceptance found a defect the review did not: `germanOffsetMs` in
  `lib/month.ts` fell back to an offset of 0 without an error, which dates a
  close in the wrong month (fixed in `9058630`).

The experiment: once a run's end review has set `plan.md` to `status:
done`, run `/code-review high` on the branch by hand, and compare its
findings with the `## Left standing` of `plan.md` and its parts: what it
finds that they do not, and whether that holds up. The results show what
`review-code` should take over from `/code-review`, or leave to it.

What it costs: in a new app the final diff is the whole app.
