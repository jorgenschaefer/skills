---
effort: M
utility: L
---

# explain-diff explains a branch the way the manifesto's report does

The user wants to work out what `explain-diff` is for. It should probably
explain a branch to them the way `MANIFESTO.md` asks agents to report a
change - the decisions and the rest of "After implementation, the report
shows" - and perhaps also the acceptance criteria the branch implements,
even where they do not show up in the diff.

## What is there today

`explain-diff` writes a local HTML page in seven sections: intent and
workflow, structure, security and access, stored and wire formats with
revert, what the tests pin, precedents, surprises
(`explain-diff/SKILL.md`). It stands outside the pipeline. It overlaps
the manifesto's report in revert, security and tests, and lacks tradeoffs,
decisions the plan didn't cover, new dependencies' cost and checks, and what
was hard to change.

Where it departs from the manifesto:

- **Evidence is code lines.** Every claim carries a code line reference
  (`:28`), which a developer who does not read code cannot use; the line
  references are still worth having for a second agent to check the page.
  The tests section says "whether you ran the project's check or are citing
  someone who did" (`:44`). The manifesto: evidence is "the checks that
  prove it, rerun by a script rather than reported by the agent".
- **Section 2 is a graph of the changed modules** (`:38`): code structure
  put in front of the human.
- **It checks its own page.** `check-refs.sh` proves a referenced line
  exists, then: "check that yourself for each reference in sections 1, 3
  and 7" (`:52`). The manifesto: "Nothing judges its own work."
- **Criteria outside the diff.** `facts.sh` finds the criteria of a pipeline
  change from its `CRITERIA.md`, even after acceptance deleted it, but the
  page explains only what the diff changed.

Related: the report `/accept-criteria` writes, in the manifesto's sections
(`accept-criteria/SKILL.md`, "Report"), and `acceptance-evidence-from-a-script`.

Depends on `acceptance-evidence-from-a-script`, which settles the evidence the
report shows.
