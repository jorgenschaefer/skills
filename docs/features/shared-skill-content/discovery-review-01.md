# Review: docs/features/shared-skill-content/discovery.md

**Reviewer:** Claude (claude-sonnet-4-6), clean context
**Date:** 2026-04-30
**Artifact:** [docs/features/shared-skill-content/discovery.md](discovery.md)
**Verdict:** Request changes

## Summary

The brief is well-scoped and clearly written. The problem is stated as a problem (not a solution), the single-user scope is acknowledged honestly, and the success criteria are observable and connected to the stated problem. Two should-fix issues prevent advancing: a missing constraint about the repository's state on a fresh clone (which will directly shape the design), and an open question whose resolution path is unspecified. Several nits around new terms and borderline design language are also noted.

## Findings

### Blockers

None.

### Should-fix

1. **Missing constraint: fresh-clone repository state**
   - **Where:** Constraints section
   - **Issue:** The brief establishes that the build step must run "before committing" (Summary) and that the platform won't install a root-level `shared/` directory, so shared content must be propagated at build time. But it doesn't address whether the propagated (generated) files are committed to the repository or only exist after running the build step locally. This is a constraint-level decision: if generated files are not committed, any contributor (including the author on a new machine) must know to run setup before the skills are usable from a repo clone. If they are committed, the canonical source and the generated copies can diverge in the working tree between build runs.
   - **Why it matters:** The design phase will need to choose a propagation model (commit generated files vs. generate on demand), and this choice has significant consequences for the workflow. Without a constraint stating the author's requirement or preference, the design phase has to guess or will make an arbitrary decision that may not fit the actual working style.
   - **Suggested fix:** Add a constraint explicitly stating whether generated (propagated) files are expected to live in the repository alongside their source, or whether the repo contains only source files and the build step must be run before use. If undecided, add it as an open question with a resolution path.

2. **Open question Q3 lacks a resolution path**
   - **Where:** Open questions, "Build step trigger" question
   - **Issue:** The question names two options (pre-commit hook vs. standalone script) and notes their tradeoffs, but gives no resolution path — it doesn't say who decides, when, or how. The other two open questions explicitly assign resolution to the design phase. Q3 does not.
   - **Why it matters:** Open questions without resolution paths tend to stay open. The design skill needs to know whether this is a decision it should make, or whether the author has a preference that needs surfacing now.
   - **Suggested fix:** Either assign resolution to the design phase ("design phase will evaluate based on the propagation model chosen") or resolve it here if the author already has a preference. The tradeoffs are already well-stated; just add the resolution path.

### Nits

- The Summary uses solution language ("This feature introduces a canonical source for shared content and a build step…"). The Problem section correctly frames the problem, but a reader skimming only the Summary gets the solution before the problem. Consider restructuring the Summary sentence to lead with the problem ("Several skills share duplicated content that has already begun to diverge…") before naming the proposed solution.
- The brief introduces the term "build step" without a glossary entry. It appears seven times across multiple sections and is the central mechanism of the proposal. Worth adding to `UBIQUITOUS_LANGUAGE.md`.
- "Canonical source", "canonical file", and "canonical location" are used interchangeably across sections to refer to the same proposed artifact. Pick one and use it consistently.
- "Include directives" in Open Questions Q2 is a design-level term (implying a specific implementation mechanism) surfaced in what should be a problem-framing document. Framing it as "the build step either copies or templates" would stay at the right level of abstraction.
- Goal 4 ("the per-skill application framing stays lightweight") uses "lightweight" without defining what makes framing too heavy. This is unlikely to cause problems in practice, but a concrete indicator (e.g., "no more than one or two sentences of per-skill context per shared block") would make it testable.

## What was checked

- Problem framing: is the problem a problem, one problem, causes not just symptoms, and worth solving
- Users and stakeholders: specificity, scale, workarounds, non-user stakeholders
- Why now: trigger clarity, proportionality of urgency to scope
- Goals: testability, alignment with stated problem
- Non-goals: genuine vs. hidden requirements
- Constraints: concreteness, justification, likely missing constraints
- Success criteria: observability, connection to problem, baseline requirements
- Open questions: completeness, resolution paths
- Out of scope: boundary defense
- Skim test and future engineer test
- Ubiquitous language: checked `UBIQUITOUS_LANGUAGE.md`; flagged new terms and synonym usage
- Contradiction check: Goals vs. constraints, problem vs. success criteria, scope vs. non-goals
- Implicit design check: architecture decisions or tech choices in brief
- Boy-scout triage: no unrelated findings noted; triage skipped as unnecessary

## What was NOT checked

- Whether the 5–7 named skill files (`implementation`, `code-review`, `design`, `design-review`, `planning`, `planning-review`, `refactor-project`) actually contain the duplicated content described — the claim is plausible and the brief's scope is the mechanism, not the content, so verifying the extent of duplication is not necessary for this review.
- The skills.sh platform behavior (the constraint about installer behavior is taken at face value).
