---
effort: S
utility: M
---

# untangle goes away

The user, at the acceptance of `approval-follows-the-manifesto` on
2026-10-27: "Untangle in my mind needs to go away completely." This is the
one backlog item about `untangle`; what other items said about it is
collected here.

## What it does today

`untangle` is the second way into `CRITERIA.md`, entered after
`explain-code`: it turns an explanation the developer understands into a
module shape whose parts are the explanation's concepts, and writes the
`CRITERIA.md` that reworks the code into it (`untangle/SKILL.md`).

## Where it departs from the rest of the pipeline

- **Its ACs are details of the code.** The template's ACs read
  "<Concept> is the module `<path>`" (`untangle/SKILL.md:52`), with more on
  `test-map.md`, imports and diff stats. `untangle/CRITERIA_FORMAT.md:27`,
  beside it, says a module is never an AC, and `find-criteria`'s verifier
  reports such an AC. Left out of scope by the 2026-10-27 change.
- **It asks the developer to name directories.** "A new directory for a
  concept the glossary has no term for is named by the developer"
  (`untangle/SKILL.md:23`). `find-criteria` and `criteria-to-tickets` no
  longer ask this.
- **It shows the developer code.** Each module comes with "its functions or
  types and their parameters", plus "one call from an existing test,
  rewritten against the new modules" (`untangle/SKILL.md:23-24`). The
  concept-to-module mapping and the sample change in the explanation's
  terms are what the developer can judge.
- **Its `CRITERIA.md` is not checked** by a fresh adversary, unlike
  `find-criteria`'s; it is handed straight on.
- **Its proofs do not stay.** `checks.md` and `test-map.md` are deleted with
  the change's directory; the manifesto wants a check that "executes and
  stays".
- **Its ACs test the decision** ("<Concept> is the module `<path>`") rather
  than the constraint - a change in the explanation's terms lands in one
  place.
- **It costs upkeep.** Its `CRITERIA_FORMAT.md` is a copy `test.sh` keeps
  identical to `find-criteria`'s, so every change to the format changes its
  template too: the 2026-10-27 change spent an AC (AC-12) on it.

## What other items said about it

- `refactor-phase`: the user once wanted to combine `explain-code`,
  `restructure` and `untangle` into a refactor phase.
- `cut-files-by-concept`: "The untangle criteria of 2026-10-19 ask for this
  item", and its wording was to wait "once `untangle` has produced a
  result". Its rule 2 names a check from `untangle`, `deciding-code.sh`,
  which is no longer in the repository.
- `find-code-before-understanding-is-lost`: the behaviour the developer
  picks was to go to `/explain-code` and `/untangle`.
- `repo-setup-and-orientation`: `untangle` reads `UBIQUITOUS_LANGUAGE.md`.

## What points at it

`README.md:33`, `:84` and `:202`; `explain-code/SKILL.md:47`, which hands
the developer on to `/untangle`; and `test.sh`, which keeps the two
`CRITERIA_FORMAT.md` copies identical.
