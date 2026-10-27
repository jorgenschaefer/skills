---
effort: S
utility: S
---

# ADRs at the slicing approval

`/criteria-to-tickets` puts each decision it newly makes while reading the
code to the developer at its approval, with a recommendation, where
`ADR_FORMAT.md` says it earns an ADR (`criteria-to-tickets/SKILL.md:76`).
The user, on 2026-10-27: "ADRs feel like necessary for me, but that might be
a backlog item." Whether they belong at the slicing approval is open.

With it: since 2026-10-27 (32e8636) that approval shows only the product
questions and the steps only a person can do; slice sizes are no longer
shown. The user: the split is "mostly mechanical, if we ever change it,
it's retroactively (\"the tickets started to take up too much / too little
context\"), it's not an approval step". So it is open whether the stop
"approve the tickets" (`README.md:68`, "Stops for a person") exists when
there is nothing to ask.
