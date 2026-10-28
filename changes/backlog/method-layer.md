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
  It is also the last section of `/accept-criteria`'s report
  (`accept-criteria/SKILL.md:75`), added on 2026-10-24 when the old
  manifesto still listed it (7f81793). Nothing the report follows holds the
  rule until this layer does.
- "Reviewers use different framings, which reduces the blind spots they
  share with the author but does not remove them." See
  `reviewer-shares-the-authors-lens`.
- The report shows example runs, requests and responses where the developer
  needs to see the behaviour itself, and lists tests by what they prove
  (`acceptance-evidence-from-a-script`).
- A check that only approximates a criterion says so
  (`acceptance-evidence-from-a-script`).

## Answering for the whole

The manifesto now says, in the first line under "For every goal": "The
developer answers for the software as a whole, not for one change at a
time." The method layer carries what that line asks of each change: the
developer sees **the whole it changes**, and a whole that stops hanging
together is put to them unasked.

- No skill yet shows the developer, for a change, the whole that change
  changes - the rule or workflow as it will stand afterwards - or raises a
  whole that stops hanging together, such as a rule gathering special cases.
  The weight tracker in `approved-criteria-outlive-the-change` is the
  example: the developer approved each fix to a rule, and nobody saw the
  fixes add up to a pile of special cases.
- `/accept-criteria`'s "Show them what the change decided that they answer
  for" (`accept-criteria/SKILL.md:39`) cites nothing yet, so it could be cut
  under the rule that a step citing nothing is a candidate to cut. It serves
  this goal, so it should cite that line rather than be cut.
- A record of who decided what and why was left out on purpose. The
  developer who agreed the item saw it as blame, "the wrong part of
  accountability". What the developer needs is confidence that the software
  works.

## Related

- `standard-follows-the-manifesto`: the code standard, the other half of the
  second layer.
