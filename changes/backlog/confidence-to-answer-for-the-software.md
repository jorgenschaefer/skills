---
effort: M
utility: L
---

# The developer ends up confident enough to answer for the software

Agreed with `/idea` on 2026-10-28:

> A developer who knew the code could stand behind the software they
> shipped. They were confident it worked, and they answered for it to users,
> customers and their employer. A developer who does not read the code still
> answers for it, but the software is a black box to them, and the agents
> that built it cannot answer for anything. The manifesto has the developer
> "accept it on evidence they can see", but that is about one change at a
> time. It does not say that the evidence has to add up to confidence that
> the software as a whole works. It also does not say that this confidence
> is what lets the developer answer for the software to others. While the
> pipeline is reworked to follow the manifesto, a step that serves only that
> confidence has nothing to cite. One example is `/accept-criteria`'s "Show
> them what the change decided that they answer for"
> (`accept-criteria/SKILL.md:39`). Under the planned rule that a step citing
> nothing is a candidate to cut (`method-layer`), it could go. This has not
> happened yet. The cost comes when the rework applies the rule. Instead, no
> step that adds to that confidence is lost without anyone noticing, and a
> gap in that confidence is visible to the developer.

There is no past instance, since the reworked pipeline is not finished. The
security policy's agreed problem was the same idea for access: "the
developer vouching for who may see and do what" (e9e746b).

Left out on purpose: a record of who decided what and why. The user: that
is about blaming, "the wrong part of accountability". What the developer
needs is confidence that the software works, more than understanding how.

`method-layer` and `critical-user-journeys`, the two roots of the port to
the manifesto, depend on this. A journey's end-to-end check is the most
direct evidence that the software as a whole works.
