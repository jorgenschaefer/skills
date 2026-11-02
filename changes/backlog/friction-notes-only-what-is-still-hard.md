---
effort: S
utility: M
---

# Friction notes hold only what is still hard

The user agreed on 2026-11-02, after a review of the friction notes in
five projects: a friction note should hold only what is still hard to
change. A trap that was already solved goes in a comment at the trap, or
is left out.

`implement-change/SKILL.md:69` asks for a note where "you had to change it
in more than one place, you could not find something, something surprised
you". `debug/SKILL.md:66` asks the same. The builders read "surprised" as
"cost me time", and write down what they already solved. The refactor
cannot do anything with those points.

Where it showed up, in `../workout-tracker-1/changes/friction/`:

- `2026-10-31-anmelden-laptop.md`: the relative redirect is fixed and has a
  test; the rest is library behaviour (jsdom cannot spy on
  `window.location.assign`, Biome reads a helper named `after` as a mocha
  hook, `unstable_doesProxyMatch` is missing).
- `2026-10-31-abnahme-korrekturen.md`: `setsLine` is already built, the
  fixtures already use UUIDs, the UUID check already moved to
  `workoutToStore`, `bin/migrate-lockfile.mts` already exists.
- `2026-10-31-uebungen-bearbeiten.md`: `next/link` in Vitest, the
  `document.fonts` stub, dnd-kit positions in jsdom - all worked around.
- Parts of `2026-10-31-uebungen-ansehen.md`,
  `2026-10-31-plan-uebung-hinzufuegen.md` and
  `2026-10-31-service-worker-shell.md` are the same kind.

The knowledge is worth keeping for the next person, but the refactor
deletes the notes it deals with, so `changes/friction/` is the wrong place
for it.

Related: `refactor-drops-notes-not-seen-again`, which deals with notes
piling up from the refactor's side.
