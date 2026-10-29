---
effort: S
utility: M
---

# The deployment steps are handed over after acceptance

Some steps can only happen at deployment, after acceptance: a DNS entry, a
related service deployed, data created in production. The user wants these
in a deployment checklist rather than in a ticket. Split out of
`approved-criteria-outlive-the-change` on 2026-10-29: it needs nothing from
that item, since the list is handed over once, not kept as an approval.

`PIPELINE.md` ("Deployment steps") wants a list of those steps, handed to
the developer after acceptance and checked by the walk's fresh agent
against the change; "Passes on" in ACCEPT says the same. No skill does it:

- `/criteria-to-tickets` puts each step in a ticket's `## Not here` as a
  line beginning "At deployment, a person" (`criteria-to-tickets/SKILL.md`,
  "What slicing turns up"), though `TICKET_FORMAT.md` defines `## Not here`
  as the boundary against neighbouring tickets.
- `/accept-criteria` lists those lines under "Blast radius and revert", in
  the report before acceptance (`accept-criteria/SKILL.md`, "Report"), then
  deletes the change's directory. The steps survive only in git history and
  in the report on screen. Its fresh agent is not given them.
- PLAN has no place for them: `CRITERIA_FORMAT.md` has no section for a
  step only a person can do, and `PIPELINE.md` has find-criteria settle only
  the steps before the build. So they turn up wherever they fit.

Instances:

- `drk-barmbek` b8ca07a7: "Before this deploy, `F128222P0504` is created by
  hand in the BGM-Verwaltung", and removing the pre-check "is done by hand
  once production runs this change", both in a ticket's Context.
- `weight-tracker`, the weight trend change: a DNS entry for
  `gewicht.jorgenschaefer.de` "vor dem Deployment", inside the Wire formats
  decision.
- `dom` 2446618: the passwords in `secrets.prod.env`, which only
  `bin/deploy-prod` decrypts.

Related: `accept-follows-pipeline`.
