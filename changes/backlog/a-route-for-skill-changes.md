---
effort: L
utility: M
---

# A change to a skill has a route that fits it

Most changes to this repository are changes to skills, and the pipeline is
built for code. Half of what `/find-criteria` does does not apply to a skill:
specimens, screen sizes, failure cases, what production must show, the
security policy, what the system keeps, and the technical decisions
(concepts, wire formats, hard to reverse) (`find-criteria/SKILL.md`, "The
loop"). It works towards criteria that tests check later, and
`/criteria-to-tickets`, `run.sh` and `/implement` are even more
code-specific: TDD, the coding standard, a check that passes or fails. For
a skill, the only way to show a change holds is a fresh agent following it
on a real case, before and after.

`/align` fits skills, but only for changes that bring the repository closer
to `MANIFESTO.md` or `PIPELINE.md`: it asks "Is it alignment?" and sends
anything else back to the backlog (`.claude/skills/align/SKILL.md`,
question 2).

Instance: the `/idea` session on `question-a-picked-item` (2026-10-25). Its
agreed problem was about to go to `/find-criteria`, which does not fit it,
and went to `/align` only because it could be read as alignment. Every skill
change since 17165a6 went through `/align`, none through the pipeline.

`/align`'s plan asks what the manifesto lists a human approving, read for
this repository, and that list applies to skills where `/find-criteria`'s
AC groups and technical decisions mostly do not.
