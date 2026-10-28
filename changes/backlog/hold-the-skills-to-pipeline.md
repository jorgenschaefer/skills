---
effort: L
utility: L
---

# Hold the skills to PIPELINE.md

`PIPELINE.md` now says what the pipeline is meant to be. The skills, the
runner and the formats were written before it, and in places do something
else. The user, on 2026-10-28: "The next step then is to hold the skills to
that description."

The developer's account of the pipeline and every disagreement decided
while writing `PIPELINE.md` are in the change's `CRITERIA.md`, `## Left
standing`, at commit 4a70caf (`git show 4a70caf:changes/2026-10-28-pipeline/CRITERIA.md`).

Deviations known when `PIPELINE.md` was accepted:

- A question found during IMPLEMENT: `implement/SKILL.md:16` ("ask ... and
  do not build past it") and `:54`, `CODING_STANDARDS.md:97`, the runner's
  `undecided` halt (`run/prompts.sh:31`), the final review deferring rather
  than building a best guess (`run/prompts.sh:101`),
  `.claude/skills/align/SKILL.md:51`. Until this is done, sessions in this
  repository meet only implement's "ask", since `CLAUDE.md` no longer says
  to save questions for the stops.
- The ticket approval stop: `criteria-to-tickets/SKILL.md:69`, `:79` (ADRs
  at the approval). `PIPELINE.md` has no stop between the approved criteria
  and ACCEPT, and ADRs come in find-criteria or the walk.
- A departure counted only in "None." groups: `run/prompts.sh:23`,
  `TICKET_FORMAT.md:38`, `criteria-to-tickets/SKILL.md:37`,
  `CRITERIA_FORMAT.md:27`. `PIPELINE.md`: anything that changes what was
  approved.
- The single-session path that skips `/accept-criteria`
  (`CRITERIA_FORMAT.md:57`). `PIPELINE.md`: every change goes through
  ACCEPT.
- A problem not solved at ACCEPT has no route back to idea
  (`accept-criteria/SKILL.md:101`).
- `plan-idea` is a route after idea with no criteria or acceptance; it is
  not part of the pipeline.
- Manifesto checks no skill carries: the whole a change changes, alerts
  shown to fire, checks shown to fail when the code breaks, criteria marked
  executed or judged.
- The single-ticket brief (`criteria-to-tickets/SKILL.md:96`) claims to
  match the runner's (`run/prompts.sh:19-33`) and does not.
- restructure (`:55`, `:70`), upgrade-dependencies (`:32`, `:50`) and
  init-security-policy (`:53`) commit code no fresh reviewer saw.
- Re-slice after drift: `run/drift.sh:113` against
  `criteria-to-tickets/SKILL.md:85-86`; `attempts` runner-owned
  (`TICKET_FORMAT.md:12`) but reset by a re-slice.
- The check line's form: `critique/SKILL.md:28` against `run/checks.sh:67`.
- Stage outputs left uncommitted while the runner refuses a dirty tree:
  glossary entries (`find-criteria/SKILL.md:43`), the run skill
  (`accept-criteria/SKILL.md:17`), `CRITERIA.md`.
- What critique is handed in the CRITERIA path: `implement/SKILL.md:18`
  against `:36` and `run/prompts.sh:101`.
- Stops outside the developer's stops: `ubiquitous-language/SKILL.md:73-83`,
  `.claude/skills/align/SKILL.md:11`.
- `.claude/skills/align` judges a gap only against manifesto sentences (its
  question 2), not against `PIPELINE.md`.

Related: `implement-is-how-code-gets-built`, `slicing-finds-nothing-to-decide`,
`acceptance-evidence-from-a-script`, `a-route-for-skill-changes`.
