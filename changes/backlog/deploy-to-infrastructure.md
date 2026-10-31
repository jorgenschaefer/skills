---
effort: M
utility: M
---

# Deploy a new app to the shared infrastructure

The user, on 2026-10-31: the deployment parts of setting up an app might be
another skill, one that works with `../infrastructure`. They left these out
of `nextjs-project-setup`: a multi-stage Dockerfile on the latest Node LTS,
`output: "standalone"` in `next.config`, a hardened `compose.prod.yaml`, and
security headers.

What the projects in `~/Projects` do today:

- nine apps have a `bin/deploy-prod`: `ausgaben`, `dom`, `drk-barmbek`,
  `drk-meldekopf`, `einsatz`, `ekg-trainer`, `isabellkoester.com`,
  `jorgenschaefer.de`, `workout-tracker`;
- three have a `compose.prod.yaml` with `cap_drop: [ALL]`,
  `no-new-privileges`, and memory and process limits: `einsatz`,
  `weight-tracker`, `workout-tracker`;
- `../infrastructure/README.md`, "Adding an app", says the rest: the
  database with `bin/create-db <host> <dbname>`, the external
  `service_network` and `database_network`, no published host ports, a
  block in `hosts/<host>/Caddyfile` with `import security`, the site in
  `bin/check-redirects`, deploying the host, and that the DNS record has to
  point at the host before the deploy;
- the security headers are already set for every site, in Caddy
  (`caddy/snippets.caddy`), so an app does not need to set or test them in
  `next.config`, as `einsatz` does.

The instance: the workout-tracker change handed all of this to a person.
Its `CHANGE.md` (lines 93-94): "At deployment, a person creates
`secrets.prod.env` with `WORKOUT_PASSWORD_HASH` and encrypts it with sops",
and "At deployment, a person adds the Caddy block, creates the database with
`bin/create-db` and adds the DNS entry in `../infrastructure`".

To settle: which of these steps a session may do itself and which need a
person - secrets, DNS, the deploy itself. `../infrastructure`'s README stays
where the steps are written; the skill reads it rather than copying it.
