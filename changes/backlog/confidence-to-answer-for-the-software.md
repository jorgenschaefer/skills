---
effort: M
utility: L
---

# The developer ends up confident enough to answer for the software

Agreed with `/idea` on 2026-10-28, restated the same day after a review
found the first statement joined two problems:

> A developer who knew the code could stand behind the software they
> shipped. They were confident it worked, and they answered for it to
> users, customers and their employer. A developer who does not read the
> code still answers for it, but they see the software only through the
> evidence each change shows them. Change after change on good evidence
> does not add up to knowing what the software as a whole does. They also
> cannot tell where their confidence in it is thin.
>
> In the weight tracker, each fix added another special case to the
> "gaining weight" rule, and nobody approved any of them as behaviour. In
> the end the developer could no longer say what the rule was meant to do.
> So they could not answer for it.
>
> Instead, the developer is confident enough in the software as a whole to
> answer for it to others, and where that confidence is thin, they can see
> it.

Outside the statement:

- Access is one part of this, agreed on its own as the security policy's
  problem: "the developer vouching for who may see and do what" (e9e746b).
- Losing steps during the rework to the manifesto is one way the
  confidence could become thin. Under the planned rule that a step citing
  nothing is a candidate to cut (`method-layer`), `/accept-criteria`'s
  "Show them what the change decided that they answer for"
  (`accept-criteria/SKILL.md:39`) could go. That step is about one change,
  so it may not serve only this confidence.
- Left out on purpose: a record of who decided what and why. The user:
  that is about blaming, "the wrong part of accountability". What the
  developer needs is confidence that the software works, more than
  understanding how.

`method-layer` and `critical-user-journeys`, the two roots of the port to
the manifesto, depend on this. A journey's end-to-end check is the most
direct evidence that the software as a whole works.
