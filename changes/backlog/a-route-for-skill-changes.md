---
effort: L
utility: M
---

# A change to a skill has a route that fits it

Most changes to this repository are changes to skills, and "Add a feature"
is built for software that runs. A skill has no screens to walk and no user
to go through a journey; the only way to show a change to a skill holds is
a fresh agent following it on a real case, before and after.

`design-user-journeys`, `implement-change`, `walk-user-journeys` and
`accept-change` all assume running software: a journey's steps are what a
user does and sees, each step gets a test that uses the software from the
outside, and acceptance walks it on the running software. `/align`, the
route skill changes took before, is gone.

The rebuild on the `sdlc` branch went through none of them: it was proposed
one step at a time in a session, accepted by the developer, and committed.

Open: what stands in for journeys and their tests when the software is a
skill. One reading: the developer is the user, `SDLC.md`'s journeys are the
journeys, and the test of a step is a fresh agent following the skill on a
real case.

Instance: the `/idea` session on `question-a-picked-item` (2026-10-25),
whose agreed problem about a skill had no route that fitted it.
