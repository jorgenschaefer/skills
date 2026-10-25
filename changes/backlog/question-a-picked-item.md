---
effort: S
utility: M
---

# A picked item is questioned before it is built on

Agreed with `/idea` on 2026-10-25:

A backlog item is written quickly, as a note on an improvement, and often
starts as an itch the developer cannot yet put into words. What it is meant
to improve, and how much that matters, are set at that moment. When the item
is picked, the pipeline treats both as settled. Often what the improvement is
trying to solve has not been worked out yet, and working it out turns the
item into a different or sharper topic. Sometimes the problem is clear but
does not hurt enough to be worth solving. Today the developer has to notice
this each time and steer the discussion themselves. What should be true
instead: before work on a picked item starts, what it is meant to improve and
whether that is worth the work have been worked out with the developer, and
"not worth doing" is one possible outcome.

Instances, all from 2026-10-24, each after the user stepped in to discuss
the item:

- cf82597: "reviewers use different framings" became
  `reviewer-shares-the-authors-lens`; the item had misread the manifesto line.
- aef325c: "implement consults before building" became
  `implement-is-how-code-gets-built`, a different problem.
- 1468d99: `standard-weighs-the-laws` was split, and contract tests and kept
  benchmarks were dropped as "a problem the pipeline rarely has".

Evidence:

- `backlog/SKILL.md:43`: an item that "states a problem a reader who was not
  here could restate" goes straight to `/find-criteria`, which takes it as
  the agreed problem - "Do not reopen the problem once it is agreed"
  (`find-criteria/SKILL.md`, "Start from the problem"). Items written with
  evidence from the code read like that however little thought went into
  them.
- `/idea` tests whether the problem is real, through one instance, but its
  no has two grounds only, already solved and a symptom of something else
  (`idea/SKILL.md`, "The no is a finding"). Not worth doing exists only for
  a part of a problem (`idea/SKILL.md:26`).

`MANIFESTO.md`, Utility: "The program does what the user wants after being
consulted adequately", and "The consultation happens before implementation;
what it settles is what gets built."
