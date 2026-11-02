---
effort: L
utility: L
---

# Rebuild the coding standards from what matters for coding agents

The user, on 2026-11-02, after comparing this branch with `main`: main's
`CODING_STANDARDS.md` (262 lines, `implement/CODING_STANDARDS.md` on `main`,
copied into five skills) is gone from this branch. It was "a file I
personally honed and large parts reflected my personal opinions about code.
But those opinions are outdated in the age of coding." They want it rebuilt
"as per evidence of what actually matters for coding agents, relying on
their models and learned ideas more than on writing down my personal,
anecdotal opinions."

On `main`, `implement`, `critique`, `criteria-to-tickets`, `find-criteria`
and `restructure` read it. It covered correctness (fixing a bug where its
cause is, TDD with a red run, edge cases, failure paths, "coverage is never
lost"), security (authorization against the object, input never becomes
code, never turning a check off), naming, efficiency, and maintainability
(one way to do each thing, colocation, file and function size, fields
listed once).

On this branch, no skill has rules for the code itself. `review-change` has
one paragraph on maintainability. `implement-change/SKILL.md` says "Every
other test is yours. Write what helps you build; delete it later if it gets
in the way", so business logic outside a journey has no rule for its tests.
Injection, which `security-beyond-access.md` does not name, has no rule
either.

Evidence from `try-code-review.md` (ausgaben, 2026-11-01): `critique`
reviews on main, which read the file, took 2 to 7 minutes and 10 to 21 tool
calls. `review-change` reviews took about a minute and 7 tool calls, and
missed a defect that acceptance found. The changes were smaller, so this
proves little on its own.

Not wanted back: a check for each new structure (the ticket rule "A slice
that introduces a structure adds its check").

Open: what counts as evidence, and which skills read the result. The "good
coding skill" in `plan-the-build-and-decide-only-what-is-hard-to-change.md`
may be where it lives.
