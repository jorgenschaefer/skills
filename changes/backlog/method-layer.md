---
effort: L
utility: M
---

# A method layer says how the pipeline follows the manifesto

Do skill steps need to cite the manifesto at all? Settle that first: hold
the new manifesto against a few real skill choices, such as `/find-criteria`
showing the developer how the code will be built
(`find-criteria/SKILL.md:37`). Without citations, can a reader tell whether
the manifesto speaks to the choice, and whether the choice fits?

From the discussion of `layered-manifesto` (ced93f2) on 2026-10-25:

- The second layer is a process document - stages, stops, evidence,
  reports - which applies only in the pipeline. It sits beside the code
  standard, `CODING_STANDARDS.md`, which applies wherever `implement` fires,
  pipeline or not.
- A skill sees only its own directory, so each layer is copied into the
  skills that use it. That is cheap for a small manifesto, but not for the
  standard's 262 lines.
- Skill steps cite the layer above by its wording, and `test.sh` checks that
  the cited text exists. A step that applies a principle cites it; an
  operational one (a size threshold, the form of the `Check:` line) cites
  nothing. A step that is neither is a candidate to cut.
- An alternative for the citations: the manifesto's rules get short fixed
  ids, and skill steps name those.
- The method says what must hold across stages - what each produces, who
  checks it, what reaches the developer. A skill says how its own stage does
  it.

## Process rules that left the manifesto

The manifesto's first version held these. They are rules for the process,
so they belong in the process document:

- What was hard to change. The writer reports it, with a suggestion for
  each: a refactoring for a structural problem, a check for an invisible
  reason. It is never acted on in the change that found it. It comes to the
  developer as a follow-up, with what skipping it would cost.
  `implement/SKILL.md:70` and `accept-criteria/SKILL.md:87` already do this.
- "Reviewers use different framings, which reduces the blind spots they
  share with the author but does not remove them." See
  `reviewer-shares-the-authors-lens`.
- The report shows example runs, requests and responses where the developer
  needs to see the behaviour itself, and lists tests by what they prove
  (`acceptance-evidence-from-a-script`).
- A check that only approximates a criterion says so
  (`acceptance-evidence-from-a-script`).

## Related

- `standard-follows-the-manifesto`: the code standard, the other half of the
  second layer.
