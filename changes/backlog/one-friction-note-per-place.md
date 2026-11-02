---
effort: S
utility: S
---

# One friction note per place, not per chunk

The user agreed on 2026-11-02, after a review of the friction notes in
five projects: a friction note should be about one place, not about one
chunk.

`README.md:44` already says "one note per place that was hard to change",
and `refactor-codebase/SKILL.md:17` says "A place several notes name is the
strongest signal there is". `implement-change/SKILL.md:69` names the file
after the change (`YYYY-MM-DD-<slug>.md`) and does not say one place.

Where it showed up: in `../workout-tracker-1/changes/friction/`, 11 of the
13 notes are one per chunk, each with 3 to 5 points that have nothing to do
with each other (`2026-10-31-anmelden-laptop.md`,
`2026-10-31-app-aktualisieren.md`, `2026-10-31-plan-editor.md`, ...).

The strongest signal in that project is spread over four such notes, and
none of them says so: the phone's pages and screen parameters, kept in step
by hand between `src/sw.ts`, `serwist.config.mjs`, `session-guard.ts`,
`screen-navigation.ts` and `ServiceWorkerRegistration.tsx`
(`2026-10-31-app-aktualisieren.md`, `2026-10-31-handy-uebung-hinzufuegen.md`,
`2026-10-31-training-beenden-verwerfen.md`,
`2026-10-31-training-eintragen.md`).
