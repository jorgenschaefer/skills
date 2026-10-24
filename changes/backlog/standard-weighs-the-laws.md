---
effort: S
utility: M
---

# The standard weighs its properties as the manifesto weighs the laws

Three places where `CODING_STANDARDS.md` and the skills around it say
something different from `MANIFESTO.md`'s laws.

## Strict order instead of weighing

`implement/CODING_STANDARDS.md:14`: "If two pull against each other, the
earlier one wins." The manifesto: "The laws are weighed against each other,
and the order says which way to lean", and the report shows "Tradeoffs:
where the agent weighed one law against another". Under a strict order a
tiny correctness concern beats any maintainability cost, and the choice is
never seen. The standard's first property is "Correctness" - what the code
"is supposed to do" from the ticket, callers and domain (`:21`); the
manifesto's is "Utility" - what the user wants after being consulted.

## Untested adapters and unkept measurements

- `:54`: an adapter that cannot be tested may go untested, "and accept that
  the adapter itself goes untested". The manifesto: "Where a test
  environment can't see a constraint, a contract test or a benchmark comes
  as close as it can."
- `:109`: an optimization is measured before and after, but no benchmark
  stays as a check, though the manifesto makes a constraint that matters "a
  check that fails and says why".

## The boy scout rule

The manifesto: "small fixes in passing leave the code better than they
found it. They change nothing the human approved and follow the idioms
already there. Anything larger is a change of its own." Nothing in the repo
invites such fixes: `critique/SKILL.md:42` puts pre-existing problems out of
scope for a change, and builds are kept inside their ticket (`## Not here`,
`run/prompts.sh`). The caution has a reason - in a multi-ticket run a fix in
passing can land in a neighbour's ticket. The review suggested limiting
small fixes to files the change already touches.

The standard has five copies, edited together.
