---
effort: M
utility: L
---

# The pipeline works in an empty repository

Run `/idea`, `/find-criteria` and `/criteria-to-tickets` in a completely
empty repository, and `run.sh` should work. The first change should create
the whole setup along the way: `CLAUDE.md` with its `Fast check:` and
`Slow check:` lines, `UBIQUITOUS_LANGUAGE.md`, `SECURITY_POLICY.md`, and
whatever other files the pipeline comes to expect.

## The runner stops before the first ticket

In a repo with no code yet (`portfolio`), `run.sh` stops before the first
ticket with "the session found no verification command, and CLAUDE.md
names no fast check on a Fast check: or Check: line". This happens in
`run/checks.sh:77`: `read_checks` finds no `Fast check:` or `Check:` line in
`HEAD:CLAUDE.md` and asks a session to name the fast check. The session finds
none, because there are none, so `find_checks` stops the run.

`criteria-to-tickets` already plans for this: where `CLAUDE.md` names no
fast check, "the first ticket writes the fast check ... and declares it on
a `Fast check:` line" (`criteria-to-tickets/SKILL.md:43`). The runner stops
before it can build that ticket.

The build and review briefs name the checks with `checks_named`
(`run/prompts.sh:76`), from `$FAST_CHECK`, so a run without checks must not
tell a build "the project's fast check is ``".

The workaround was to commit a `CLAUDE.md` with ``Check: `true` ``.

## The glossary

`find-criteria` agrees a term for each new concept and adds it "to the
glossary where the project has one" (`find-criteria/SKILL.md:43`). Where
there is none, the agreed terms stay in `CRITERIA.md`, which acceptance
deletes.

## The security policy

Nothing creates the security policy in a repo with no code yet.
`/init-security-policy` needs a `Check:` line and a system it can run, so
it only fits once code exists, and then the rules say what the code does
rather than what the developer decided. Until then, `find-criteria` says
there is no policy and asks as before (`find-criteria/SKILL.md:37`), and
`implement` touches the policy only where `SECURITY_POLICY.md` exists
(`implement/SKILL.md:20`). So the first change's Security policy ACs are
approved, but nothing writes them into a policy or checks them. One way:
the first change with Security policy ACs creates `SECURITY_POLICY.md`
from them, with the policy check and the rules' tests, and the
preparatory ticket that writes the `Check:` line adds the policy check.
The developer already approves the rules with the criteria, so this needs
no new stop.

`repo-setup-and-orientation` sets up a repository that already has code.
