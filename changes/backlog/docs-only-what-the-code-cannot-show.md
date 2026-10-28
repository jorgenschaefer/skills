---
effort: S
utility: S
---

# Docs say only what the code cannot show

The README restates in prose what `run.sh` and its tests do, and comments
and skills carry the history of their rules. Both go stale and both are
read by agents as true.

`MANIFESTO.md`, premise 2: an agent "takes all of it as true". "What a
fresh agent finds with one search or in one file needs no documentation" and
"Only what remains is written down" left the manifesto; they are listed for
the standard in `standard-follows-the-manifesto`.
`CODING_STANDARDS.md`, _Comments_: a comment "never names ... what the code
used to do".

Evidence:

- README "The runner" and "The tests" sections describe `run.sh`'s
  behaviour step by step - refusals, branch, checks, drift, budget, resume,
  lock, review, token log.
- History in comments: `run/checks.sh:13` "Every build used to meet the same
  failures"; `run.sh` "A second one started beside a live run took over its
  claim"; `run/prompts.sh` "one run's build left a blocker there".
- Stories in skills: `implement/SKILL.md` "in one run the build and its
  reviewer drove the app at the same time"; `criteria-to-tickets/SKILL.md`
  "in one run, an import rule written into a ticket ..." and "A check that
  saw tickets 01 to 20 ..."; `.claude/skills/retro/SKILL.md` "One analysis
  that ran the tests ...". `improve-skill` keeps such a story only as one
  clause that does a named job.

`PIPELINE.md` now holds the pipeline's intent, and the README says what
the scripts do.
