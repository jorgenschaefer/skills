---
effort: S
utility: S
---

# run.sh runs in a new repo that has no checks yet

In a repo with no code yet (`portfolio`), `run.sh` stops before the first
ticket with "the session found no verification command, and CLAUDE.md
declares none on a Check: line". This happens in `run/checks.sh:43`:
`checks_command` finds no `Check:` line in `HEAD:CLAUDE.md` and asks a session
to name the checks. The session finds none, because there are none, so
`find_checks` stops the run.

The build prompts in `run/prompts.sh:21` and `:78` state the checks as
`$VERIFY`, so a run without checks must not tell a build "the project's checks
are ``".

The workaround was to commit a `CLAUDE.md` with ``Check: `true` ``.
