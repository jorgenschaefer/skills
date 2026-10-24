---
effort: M
utility: L
---

# The standard's security section covers what the manifesto asks

`CODING_STANDARDS.md`'s Security section (`implement/CODING_STANDARDS.md:75`)
covers object-level authorization, input never becoming code, never turning
a check off, and secrets in the environment. Several things the manifesto's
Security law requires are not there, so no build is held to them and no
review reports their absence.

Missing, from `MANIFESTO.md`:

- "Agents enforce that policy and prove it with tests that attempt what is
  forbidden." The standard asks for no such tests. `explain-diff` asks
  "which test pins the guards" (section 3), but nothing makes a build write
  one.
- "Every way in goes through security checks an agent finds easily, and a
  test fails when a way in bypasses them." The standard puts the ownership
  check into each query (`:81`), which is sound but scattered, and has no
  check that every entry point passes through a guard.
- "Access is denied unless a security check allows it." No default deny.
- "Nobody includes a malicious user, an outside attacker, and an agent
  steered by text it read." The standard says "Assume a malicious user"
  only.
- "Security that is hard to use gets worked around, so the secure path is
  the easy one."

"Secrets stay out of code and logs" is covered (`:85`, and _Fail Loudly
Inside_).

The standard has five copies (`implement`, `critique`, `find-criteria`,
`criteria-to-tickets`, `restructure`), edited together. The security policy
the human approves is part of `approval-follows-the-manifesto`.
