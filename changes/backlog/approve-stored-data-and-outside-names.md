---
effort: M
utility: L
---

# The developer approves new stored data and names the outside sees

The user, on 2026-11-02: in one change, a migration was built that they did
not see, and two environment variables got names nobody discussed with them.
Stored data is a question of the domain model and should be agreed at least
in the abstract. Environment variables are an outside interface and should
at least be put to them for a veto.

Later the same day, after a design in `workout-tracker`: "Mir fehlt
tatsächlich die klare Darstellung, wie das in der DB gespeichert wird. Ohne
das fühle ich mich unsicher."

## Where it showed up

### haushaltsbuch

`haushaltsbuch`, change `changes/2026-11-01-ausgaben-import`, designed and
built on 2026-11-01.

**In the design** (session `3977e5e9`, 15:40 to 16:03), both came up only in
other words:

- The developer said yes to "Jede Buchung aus Ausgaben merkt sich die
  Kennung ihres Eintrags, ohne sie anzuzeigen". `CHANGE.md` adds "Wo sie
  liegt, entscheidet der Build". "Merkt sich" reads as behaviour. That it
  means a new column and a migration did not show.
- The chat said only "Adresse und Schlüssel stehen in Umgebungsvariablen".
  The agent then wrote the names `AUSGABEN_URL` and `AUSGABEN_SCHLUESSEL`
  into `CHANGE.md` without showing them. Before the final yes the skill shows
  only what changed since the last yes, so they were never shown. The
  backlog item it wrote in `../ausgaben` names `HAUSHALTSBUCH_SCHLUESSEL` the
  same way.

`design-user-journeys/SKILL.md` asks "what it keeps, and what happens to what
it already holds", and "A new thing gets its name from the user". The second
only covers what the user sees in the software, not names the outside sees.

**In the build**, chunk `04-kennung-des-eintrags` added the column
`transactions.ausgaben_eintrag_id` with migration `0033`, and reported it
under `## Left standing` as built beyond the design.

**At acceptance** (session `9c5e1ef7`, 23:41), both were in the report, but
not as decisions:

- Migration 0033 stood only under "What a revert would not undo" and in the
  steps for deployment. `accept-change/SKILL.md:78`: what stays within what
  was agreed "is shown, not settled".
- The environment variables were item 2, "Deploying needs ... and nothing in
  the repo says so": a missing documentation, not names to approve.
  `accept-change/SKILL.md:52` lists "a format other programs read" and "a
  name for something the user sees"; a name the operator sets is neither.

`SDLC.md`, Future Changes: "Stored data (database schemas) and wire formats
are relevant but are not mentioned yet."

### workout-tracker

`workout-tracker`, change `changes/2026-11-02-workouts-tracken`, design
committed as `0fced9e` on 2026-11-02, not built yet (session `707c3e2c`).

- **The data came only as a list in words.** At 14:22: "Die App speichert:
  Übungen: Name, und ob Kraft oder Cardio. Pläne: … Trainings: …", followed
  straight away by the question whether to import old records. How the
  things hang together did not come up: whether a training points to its
  plan or only keeps its name, whether an exercise in a training points to
  the exercise that "Letztes Mal" is found through. The build will make the
  tables from this, and the developer will first see them as a migration.
- **Two stores, and no picture of them.** "Alle Trainings liegen auf dem
  Handy" came in only with the verifier's findings. A queue of waiting
  changes is added. What lies on the device, what on the server, and which
  one wins is spread over "Interactions" in `CHANGE.md`, lines 63 to 66.
- **The password is again a name nobody gave.** `CHANGE.md:72`: "ein
  Passwort, das beim Einrichten des Servers festgelegt wird". What it is
  called and how it is kept is left to the build.
