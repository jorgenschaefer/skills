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

## Agreed while comparing tech stacks (2026-10-27)

- **Security code comes from a standard library.** The user: "use a good,
  standard library for security-related code, and write it yourself only
  with good reason approved by the developer." For authentication in Next.js
  there is no such library, and the usual advice is to write a small one.
  einsatz did: sessions, password hashing and a rate limiter in
  `einsatz/src/server/auth/`. Code written in-house gets the strongest tests
  that attempt what is forbidden: a wrong password, an expired session,
  brute force, a token for another record.
- **The access matrix is written against behaviour, not mechanism.** One
  test per who × action, in the user's words ("a Führungskraft may not
  delete an open Einsatz"), not "has role X". Then a change of access model,
  such as RBAC → ABAC, keeps the same tests. Only a change to the matrix
  itself changes how the security goal is checked, and that is the
  developer's decision.
- **The first iteration uses the simplest model.** The user: "Use the
  simplest solution for the first iteration. We expand and improve later."
  It still has the matrix and the check that every way in passes through the
  guard, since these make expanding it later safe.
- What happens without the check on ways in: einsatz has one gate for
  changes by logged-in users (`operationAction`, tested in
  `einsatz/src/app/operations/[id]/operation-action.test.ts`). Link access is
  checked separately in each route under `einsatz/src/app/view/` and
  `einsatz/src/app/device/` (`resolveViewAccess`, `resolveDeviceAccess`), and
  nothing fails when a new route leaves it out.
