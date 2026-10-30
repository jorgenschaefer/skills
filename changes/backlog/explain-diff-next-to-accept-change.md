---
effort: M
utility: L
---

# What explain-diff is for, next to accept-change

The user wants to work out what `explain-diff` is for. It was meant to
explain a branch the way the report of a change does. That report is now
`accept-change`'s: each journey step with the test that checks it, what the
code did beyond what was agreed, blast radius and revert, and new
dependencies.

`explain-diff` writes a local HTML page in seven sections: intent and
workflow, structure, security and access, stored and wire formats with
revert, what the tests pin, precedents, surprises (`explain-diff/SKILL.md`).
It overlaps `accept-change` in revert, access and tests. Where it differs:

- **Evidence is code lines.** Every claim carries a code line reference,
  which a developer who does not read the code cannot use. The references
  are still worth having for a second agent to check the page.
- **Section 2 is a graph of the changed modules**: code structure put in
  front of the developer.
- **It checks its own page.** `check-refs.sh` proves a referenced line
  exists, and then the writer checks the claims itself.
- **It explains any range of commits**, not only a change built with these
  skills, and `facts.sh` finds a change's `CHANGE.md` and chunks even after
  acceptance deleted them.

Open: whether `explain-diff` should exist next to `accept-change` at all,
and if it should, for which ranges and which reader.
