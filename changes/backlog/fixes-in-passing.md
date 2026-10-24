---
effort: S
utility: M
---

# Builds make small fixes in passing

`MANIFESTO.md`: "The boy scout rule applies: small fixes in passing leave the
code better than they found it. They change nothing the human approved and
follow the idioms already there. Anything larger is a change of its own."

Nothing in the repository invites such fixes. Builds are kept inside their
ticket (`## Not here`, `run/prompts.sh:23`). `critique/SKILL.md:42` puts a
pre-existing problem out of scope for a change, which binds the reviewer,
not the builder, but nothing tells the builder otherwise.

The caution has a reason: in a run with several tickets, a fix in passing can
land in a neighbouring ticket's code. A review suggested limiting small fixes
to files the change already touches.

A fix in passing is something a build discovers, which
`implement-is-how-code-gets-built` is about - though not one the human has to
decide.
