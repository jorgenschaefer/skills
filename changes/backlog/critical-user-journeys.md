---
effort: L
utility: XL
---

# Critical user journeys say what the software is for

Nothing the pipeline uses or writes says what the software is for: the two or
three critical user journeys (CUJs) - the end-to-end paths that make it worth
using, such as "a customer finds a product and pays for it". They sit far above
the acceptance criteria: a handful per product against hundreds of ACs, each a
happy path at the level of the user's goal, without error cases, which are too
many and too detailed at that level. A change's ACs say how that change moves a
journey; the journey itself is never written down or approved.

Evidence:

- `CODING_STANDARDS.md:89` (five copies) asks "Does the software support the
  main workflows smoothly?" and nothing defines them.
- `CRITERIA.md` is the only approved statement of behaviour, it covers one
  change, and `/accept-criteria` deletes it once the change is accepted.
- `repo-overview` writes "Main workflows" into `ARCHITECTURE.md`
  (`repo-overview/SKILL.md:77`), derived from the code: what is, not what was
  meant, and approved by nobody.
- The usability check completes the change's ACs as tasks
  (`MANIFESTO.md`, Usability), so a change that breaks a journey it did not
  touch goes unnoticed; acceptance holds the change against its own Problem,
  never against the journey.
- `ubiquitous-language` walks "each major workflow" through its terms
  (`ubiquitous-language/SKILL.md:62`) and invents the workflows each time.

## How it was discussed to fit

- **Manifesto:** the developer owns the journeys - the top of what the
  developer decides, "what the software does", and the one approval that outlives every
  change. Changing one is a decision the plan didn't cover. The usability
  agent completes the journeys through the real interface, not only the
  change's ACs. Each journey is held by an end-to-end check; its written
  form stays short: who, what they want to get done, a few steps in their
  words.
- **A lasting file**, e.g. `JOURNEYS.md` beside `UBIQUITOUS_LANGUAGE.md`,
  with a format file copied into each skill that uses it.
- `idea` places the problem on a journey; one that fits none is either a new
  journey or not worth doing.
- `find-criteria`: `CRITERIA.md` names the journey the change serves; adding
  or changing a journey is approved explicitly. Where the project has none,
  the first change writes them.
- `implement` / `critique`: the usability driver also gets the journeys the
  change touches; a journey check weakened or deleted is reported as a
  decision.
- `accept-criteria` walks the change's journey end to end and holds the
  result against it as well as against the Problem.
- `repo-overview`'s "Main workflows" become the draft for an existing
  project's first journeys, and later show where code and journeys differ.
- `restructure`: a feature that serves no journey is a candidate among
  "features that cost more than they give"; `backlog` ranks utility by the
  journey an item serves; `ubiquitous-language` walks the approved journeys;
  `explain-diff` places a change's happy path on its journey.

## Open

- When the journey checks run: end-to-end checks are slow and flaky, but the
  manifesto: "A check for anything the developer approved counts only if it
  fails when the code breaks it, and that is confirmed on every change".
- Whether `find-criteria` writes the first journeys, or something else does.

## Related

- `approved-criteria-outlive-the-change`: journeys give accepted ACs a place
  to live on - their tests grouped under the journey they serve.
- `cut-files-by-concept`, `explain-diff-as-the-report` mention workflows.

Depends on `approval-follows-the-manifesto`, which settles what the human
approves; a journey is one more approval on top of it.
