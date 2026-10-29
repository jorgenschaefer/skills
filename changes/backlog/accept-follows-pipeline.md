---
effort: M
utility: M
---

# ACCEPT follows PIPELINE.md

`PIPELINE.md` now says what the pipeline is meant to be. The skills, the
runner and the formats were written before it, and in places do something
else. The user, on 2026-10-28: "The next step then is to hold the skills to
that description." Split by phase from `hold-the-skills-to-pipeline` on
2026-10-29.

The developer's account of the pipeline and every disagreement decided
while writing `PIPELINE.md` are in the change's `CRITERIA.md`, `## Left
standing`, at commit 4a70caf (`git show 4a70caf:changes/2026-10-28-pipeline/CRITERIA.md`).

Deviations in ACCEPT known when `PIPELINE.md` was accepted:

- The single-session path that skips `/accept-criteria`
  (`CRITERIA_FORMAT.md:57`). `PIPELINE.md`: every change goes through
  ACCEPT.
- A problem not solved at ACCEPT has no route back to idea
  (`accept-criteria/SKILL.md:101`).
- restructure (`:55`, `:70`), upgrade-dependencies (`:32`, `:50`) and
  init-security-policy (`:53`) commit code no fresh reviewer saw.
- The whole a change changes: `PIPELINE.md` (ACCEPT) shows it in the
  report. No skill does this.
