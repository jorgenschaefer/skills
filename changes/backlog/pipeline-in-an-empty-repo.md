---
effort: M
utility: L
---

# Adding a feature works in an empty repository

Run `/idea` and `/design-user-journeys` in a completely empty repository, and
`run.sh` should work. The first change should create the setup along the
way: `CLAUDE.md` with its `Fast check:` and `Slow check:` lines, the project's
`run` skill, and whatever other files the skills come to expect.

## The runner stops before the first build

In a repo with no code yet (`portfolio`), `run.sh` stopped before the first
build with "the session found no verification command, and CLAUDE.md names
no fast check on a Fast check: or Check: line". This happens in
`run/checks.sh`: `read_checks` finds no `Fast check:` or `Check:` line in
`HEAD:CLAUDE.md` and asks a session to name the fast check. The session finds
none, because there are none, so `find_checks` stops the run.

`implement-change` already plans for a project without one: "Where no line
names a fast check, run what exists and say so" (`implement-change/SKILL.md`,
"Before you write anything"). The runner stops before it can build anything.

The build and review briefs name the checks with `checks_named`
(`run/prompts.sh`), from `$FAST_CHECK`, so a run without checks must not tell
a build "the project's fast check is ``".

The workaround was to commit a `CLAUDE.md` with ``Check: `true` ``.

`repo-setup-and-orientation` sets up a repository that already has code.
