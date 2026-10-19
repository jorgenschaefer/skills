---
effort: L
utility: M
---

# Surface the cases in a rule that are only accumulated cruft

The rule a module implements grows complicated over time as fixes pile up.
In the weight tracker, the logic for when a weight series shows as "gaining
weight" became so convoluted that the developer no longer understood it.
Some of its cases may be needed; others may be leftovers from earlier fixes
that nothing requires any more. Nothing tells the two apart.

A clear prose description of what the code does makes such cases visible,
and should prompt asking at each one whether it is really needed. Removing
one changes behaviour, so each removal is a product decision for the user.

Parked from an `/idea` session about making code follow the structure of a
readable description of what it does, which preserves behaviour. That work
could surface candidates for this one without acting on them.

`restructure/SKILL.md:34` already proposes cutting whole features that cost
more than they give, but not cases inside a rule.
