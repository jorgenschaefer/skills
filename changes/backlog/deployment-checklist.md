---
effort: M
utility: M
---

# A deployment checklist for the steps a change leaves for deployment

Some steps can only happen at deployment, after acceptance: a DNS entry, a
related service deployed, data created in production. The user wants these
in a deployment checklist rather than in a ticket.

Today `/criteria-to-tickets` keeps them out of every build and puts each in
a ticket's `## Not here` as a line beginning "At deployment, a person"
(`criteria-to-tickets/SKILL.md`, "What slicing turns up"), and
`/accept-criteria` lists those lines under "Blast radius and revert". That is
a stopgap: `## Not here` is meant for the boundary against other tickets, and
`/accept-criteria` deletes the change's directory, so the steps survive
acceptance only in git history and in the report on screen.

Instances:

- `drk-barmbek` b8ca07a7: "Before this deploy, `F128222P0504` is created by
  hand in the BGM-Verwaltung", and removing the pre-check "is done by hand
  once production runs this change", both in a ticket's Context.
- `weight-tracker`, the weight trend change: a DNS entry for
  `gewicht.jorgenschaefer.de` "vor dem Deployment", inside the Wire formats
  decision.
- `dom` 2446618: the passwords in `secrets.prod.env`, which only
  `bin/deploy-prod` decrypts.

What the report shows is now the bold items in `MANIFESTO.md`, and the
steps fall under blast radius and revert: "what a revert would not undo".

Open: where the checklist lives once acceptance deletes the change's
directory, who hands it over, and when.

Depends on `approved-criteria-outlive-the-change`, which settles what survives
once acceptance deletes the change's directory.
