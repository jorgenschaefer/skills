---
effort: S
utility: S
---

# run.sh runs in a new repo that has no checks yet

In a repo with no code yet (`portfolio`), `run.sh` stops before the first
ticket with "the session found no verification command, and CLAUDE.md
names no fast check on a Fast check: or Check: line". This happens in
`run/checks.sh:77`: `read_checks` finds no `Fast check:` or `Check:` line in
`HEAD:CLAUDE.md` and asks a session to name the fast check. The session finds
none, because there are none, so `find_checks` stops the run.

The build and review briefs name the checks with `checks_named`
(`run/prompts.sh:76`), from `$FAST_CHECK`, so a run without checks must not
tell a build "the project's fast check is ``".

The workaround was to commit a `CLAUDE.md` with ``Check: `true` ``.
