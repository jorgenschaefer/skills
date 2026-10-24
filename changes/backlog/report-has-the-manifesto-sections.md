---
effort: M
utility: L
---

# The report after a build shows what the manifesto lists

After a change is built, the developer does not learn where the agent
traded one law against another, what a failure of the change would affect,
what a revert would leave behind, what a new dependency costs, or what was
hard to change.

`MANIFESTO.md`, "After implementation, the report shows": evidence,
decisions the plan didn't cover, "Blast radius and revert: what a failure
of this change would affect, and what a revert would not undo",
"Tradeoffs: where the agent weighed one law against another", "New
dependencies: what they give, what they cost and the results of the checks
on them", "What was hard to change, and why ... Each comes with a
suggestion: a refactoring for a structural problem, a check for an
invisible reason."

Evidence:

- Left standing lists its contents and ends "Nothing else"
  (`criteria-to-tickets/TICKET_FORMAT.md:52`, both `CRITERIA_FORMAT.md:46`,
  `implement/SKILL.md:56`, and the brief in `run/prompts.sh`). None of the
  four is on the list, so a build is told not to report them.
- `REVIEW.md`'s `## For you` (`run/prompts.sh`, `review_brief`) and the
  report of `/accept-criteria` (`accept-criteria/SKILL.md:63`) have none of
  them either. `accept-criteria:51` asks what the change does "when a new
  external thing is down", which is part of a blast radius.
- Only `explain-diff` says what a revert would not undo (section 4), and it
  is not part of the pipeline.

"What was hard to change" is also the input that
`find-code-before-understanding-is-lost` collects across sessions.

## Nothing gets weighed

Tradeoffs would stay empty while the standard decides by strict order: "If
two pull against each other, the earlier one wins"
(`implement/CODING_STANDARDS.md:14`, in all five copies). The manifesto:
"The laws are weighed against each other, and the order says which way to
lean." And `implement/SKILL.md:50` says "a tradeoff nobody accepted is not a
detail", though under a strict order there is no tradeoff.
