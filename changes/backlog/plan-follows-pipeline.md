---
effort: L
utility: L
---

# PLAN follows PIPELINE.md

`PIPELINE.md` now says what the pipeline is meant to be. The skills, the
runner and the formats were written before it, and in places do something
else. The user, on 2026-10-28: "The next step then is to hold the skills to
that description." Split by phase from `hold-the-skills-to-pipeline` on
2026-10-29.

The developer's account of the pipeline and every disagreement decided
while writing `PIPELINE.md` are in the change's `CRITERIA.md`, `## Left
standing`, at commit 4a70caf (`git show 4a70caf:changes/2026-10-28-pipeline/CRITERIA.md`).

Deviations in PLAN known when `PIPELINE.md` was accepted:

- The ticket approval stop: `criteria-to-tickets/SKILL.md:69`, `:79` (ADRs
  at the approval). `PIPELINE.md` has no stop between the approved criteria
  and ACCEPT, and ADRs come in find-criteria or the walk.
- `plan-idea` is a route after idea with no criteria or acceptance; it is
  not part of the pipeline.
- The whole a change changes: `PIPELINE.md` (PLAN) shows the developer the
  rule or workflow as it will stand afterwards, and asks where it stops
  hanging together. No skill does this.
- Stage outputs left uncommitted while the runner refuses a dirty tree:
  glossary entries (`find-criteria/SKILL.md:43`), the run skill
  (`accept-criteria/SKILL.md:17`), `CRITERIA.md`.
- Stops outside the developer's stops: `ubiquitous-language/SKILL.md:73-83`,
  `.claude/skills/align/SKILL.md:11`.
- `.claude/skills/align` judges a gap only against manifesto sentences (its
  question 2), not against `PIPELINE.md`.

## Slicing finds nothing left to decide

Slicing should only group the ACs into pieces that fit one context window.
In practice `/criteria-to-tickets` regularly finds questions for the
developer, so the change stops between approving the criteria and the run.
The user, on 2026-10-28: "criteria-to-tickets regularly asks questions.
find-criteria needs something so that does not happen so regularly anymore."

- `criteria-to-tickets/SKILL.md:53` reads the code each slice will touch
  and walks each slice against it "as its builder would", looking for
  behaviour the user sees that the ACs leave open, ACs that conflict, and a
  technical decision the code shows to be short. The approval list (`:69`)
  puts these to the user.
- `find-criteria/SKILL.md:9` and `:49` set the bar: the loop is done when
  "`/criteria-to-tickets` would not have to ask anything". Nothing in the
  skill gets there.
- `PIPELINE.md` ("A question found during IMPLEMENT"): IMPLEMENT runs
  without interruption and slicing decides nothing new; a question it still
  finds is decided within what was approved, recorded, and shown at
  acceptance.

Related: `a-route-for-skill-changes`.
