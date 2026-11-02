---
effort: S
utility: M
---

# Open bugs a user sees go to the backlog, not to friction

The user agreed on 2026-11-02, after a review of the friction notes in
five projects: an open bug that a user sees, or a gap in what the software
stores, goes to the backlog, not into `changes/friction/`.

The refactor reads the friction notes, and it must not change what the
software does (`SDLC.md`, "Refactor"). A bug in a friction note reaches
nobody who may fix it.

Where it showed up:

- `../workout-tracker-1/changes/friction/2026-10-31-plan-uebung-hinzufuegen.md`:
  Mantine dialogs stay on screen when the laptop frame hides the page.
  „Neue Übung“ is fixed; "The delete questions and „Änderungen
  verwerfen?“ still have the problem."
- `../workout-tracker-1/changes/friction/2026-10-31-training-beenden-verwerfen.md`:
  "A stale tab still drops your input without a word."
- `../haushaltsbuch/changes/friction/2026-11-01-ziel-konto-einer-buchung.md`:
  a booking does not store which of its accounts was the import's target,
  so the preset is a heuristic. Storing it is a change to the data, which
  the design explicitly left out.

Gaps in the tests are close to this: "no test can pin that order"
(`2026-10-31-abmelden-handy.md`), "only shown on a real phone"
(`2026-10-31-app-aktualisieren.md`), "checked by nothing" for what the
pages sent without a login import (`2026-10-31-service-worker-shell.md`).

Where an open bug is found today: `implement-change/SKILL.md:69` (the
friction note), `implement-change`'s `## Left standing`, which
`accept-change` deletes with the change's directory, and
`accept-change/SKILL.md:80`, which sends findings about the code alone to
`changes/friction/`.
