---
effort: M
utility: L
---

# The standard's security section covers what the manifesto asks

`CODING_STANDARDS.md`'s Security section (`implement/CODING_STANDARDS.md:75`)
covers object-level authorization, input never becoming code, never turning
a check off, and secrets in the environment. Several things the manifesto's
Security goal requires are not there, so no build is held to them and no
review reports their absence.

Missing, from `MANIFESTO.md`:

- The writer "enforces the policy", and the checkers "attempt what is
  forbidden". The standard asks for no such tests. `explain-diff` asks
  "which test pins the guards" (section 3), but nothing makes a build write
  one.
- "Every way in goes through security checks an agent finds easily", and
  the checkers "fail when a way in bypasses the checks". The standard puts
  the ownership check into each query (`:81`), which is sound but
  scattered, and has no check that every entry point passes through a guard.
- "access is denied unless a check allows it". No default deny.
- "Nobody can do or see more than they are supposed to - a malicious user,
  an outside attacker, or an agent steered by text it read." The standard
  says "Assume a malicious user" only.
- "The secure path is the easy one, since security that is hard to use gets
  worked around."

Secrets that "stay out of code and logs" are covered (`:85`, and _Fail Loudly
Inside_).

The standard has five copies (`implement`, `critique`, `find-criteria`,
`criteria-to-tickets`, `restructure`), edited together. The security policy
the human approves is an AC group in every `CRITERIA.md` since 2026-10-27
(`find-criteria/CRITERIA_FORMAT.md`).
