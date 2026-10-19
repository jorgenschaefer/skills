---
effort: M
utility: L
---

# criteria-to-tickets should write only tickets a session can do alone

`/criteria-to-tickets` has been writing tickets that need the user - "create
a client id on Google Cloud Platform" and the like. A run drives tickets with
nobody watching, so such a ticket halts or gets faked. Instead, every ticket
should be doable non-interactively: the skill asks those questions, or has
the steps run, before it writes the ticket.

Work the deployment needs after the tickets - "before you deploy this
branch, do X" - should not be bundled into the tickets as one of them.
`/criteria-to-tickets` should write a deployment checklist as part of the
tickets instead.

Nothing in the pipeline deals with either today: `criteria-to-tickets/SKILL.md`,
`TICKET_FORMAT.md` and `VERIFY.md` never mention steps only a person can do or
deployment, and the only mention of deployment is `accept-criteria/SKILL.md:53`,
which flags "what the deployment provides" as an assumption.
