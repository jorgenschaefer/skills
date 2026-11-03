---
effort: M
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

## Evidence from workout-tracker, 2026-11-03

A review of `workout-tracker` found few real bugs, but much code that was
copied and changed a little. The full proposal, with each observation,
its file and line, and the assumed reason, is
`~/Projects/workout-tracker/PROPOSAL.md`.

Two causes came up again and again:

- `implement-change` builds each chunk with a fresh agent, which does not
  know what earlier chunks wrote. "Look at what is there" does not say to
  search before writing, and duplicates may be fixed only in files the
  change already touches.
- `review-change` gets the diff, and a copy outside the diff is not in it.

The rules the proposal draws from it, each with the problem behind it:

- **A.** Before writing a helper, a component, a state pattern or a
  lookup, search for one that does it; extract on the second copy, also
  outside the change's files. Logic about the data goes in the module that
  owns the data. Tests too. (The same editing pattern five times; lookups
  inline in components; layout repeated as inline styles; fixtures
  duplicated in five test files.)
- **B.** The reviewer searches outside the diff for code that does the
  same as something new; a copy is a should-fix.
- **C.** A test never sleeps for a fixed time, and imports a constant
  rather than repeating its number. (21 fixed sleeps, about 40 s per check.)
- **D.** Code whose failure loses data, or that depends on timing or
  order, gets fast tests of its own. (`Saver`, sign-out, `storage.ts` and
  the merge in `useSnapshot` had only e2e tests.)
- **E.** Use the project's wrapper for an API everywhere; never a
  library's internal data format. (`localStorage` called directly seven
  times; TanStack's cache edited by hand.)
- **F.** A value or list that must match in two places is derived from one
  source, or a test fails when they differ. (Offline pages listed in three
  places; `nameKey` rewritten without `trim()`.)
- **G.** A sibling of an existing thing, such as another API handler, gets
  the same checks, or the report says why not. (`putPlanItem` and
  `putTrainingSet` lack a check `putTrainingItem` has.)
- **H.** Before fixing a failure with a new mechanism, check whether an
  existing one should cover it, and repair that one. (Pending changes laid
  over the snapshot in four places.)
- **I.** A case no journey names is beyond the design, even where it closes
  a real gap: ask, or report it. (Signing out without a network.)
- **J.** State lives in the lowest component that has all it needs, and no
  lower; a ref or state that copies another value is a should-fix.
- **K.** A rule the code depends on, which a reader cannot see where they
  make a change, is enforced by a test or a check, not by a comment.
  (Stored changes readable by older versions; `applyWrite` matching the
  server.)

Left without a rule on purpose: file size ("agents game it"), small points
that need judgement, and cases specific to that repository.

In pipeline v4 (`changes/2026-11-03-pipeline-v4/spec.md`), the rebuilt
standards live in `implement-code`, and `review-code` reviews against them
(spec 631-632). Rule I is close to v4's rule that a failure case earns its
place and that a hard decision goes to the developer. The proposal's point
about code snippets in `ARCHITECTURE.md` going stale is moot there: a v4
plan holds no code and is deleted after the build.

Open: whether one project's review is evidence enough, or the rules wait
for a second run.
