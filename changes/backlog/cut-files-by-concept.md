---
effort: M
utility: L
---

# Cut files by concept, not by line count

`CODING_STANDARDS.md` has no rule that holds new code to the shape
`untangle` produces. Its rule splitting files at about 500 lines was removed
on 2026-10-19, since the reason it gave does not hold (below). "What Changes
Together, Stays Together" (`implement/CODING_STANDARDS.md:148`) is too vague
to cause a split at all.
The untangle criteria of 2026-10-19 ask for this item, under Nudges,
roughly "a module opens with its concept, and its parts are the
concepts of its domain".

## The 500-line limit does not buy a whole read

The limit's reason is "an agent should be able to read a file whole". An
analysis on 2026-10-19 of 583 `run.sh` sessions across seven projects (late
September to then, about 9,900 reads of code files sized from git at
session start) shows that it does not:

| lines | ≤100 | 101–200 | 201–300 | 301–400 | 401–500 | 501–750 | >1000 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| reads that took the whole file | 85% | 49% | 32% | 20% | 23% | 13% | 7% |
| sessions that saw the whole file | 91% | 62% | 47% | 38% | 44% | 27% | 8% |

- 81% of the 2,665 `sed -n` range reads on files of 500 lines or fewer
  covered less than half the file. 2,110 of 2,896 range reads followed a
  `grep`: the agent searches, then prints a window, whatever the size.
- The drop is at 100–200 lines, and nothing changes at 500. The auto-mode
  system prompt also tells the agent to read with `sed -n`.
- The limit costs work: commits matching split/combine are about 7–15% of
  the commits in drk-barmbek, einsatz and haushaltsbuch since 2026-09-20 (a
  rough keyword count). `retro/SKILL.md:31` records the limit turning into a
  target, with files kept at 495–499 lines.

Not measured: whether partial reads cause mistakes.

## Rules discussed

These are directions, not decisions. Each one names what to look at, when
to cut, and a check, preferably one that runs.

1. **A file holds one domain concept and is named after it.** The cuts
   follow where an account of the behaviour has sections, not sentences: a
   concept is a term for `UBIQUITOUS_LANGUAGE.md`. The file opens with the
   concept, and its exports are what the concept offers. Cut when
   describing the file takes two concepts joined by "and", or its exports
   belong to different glossary terms. Code that is not a concept gets no
   file of its own, and "Layers" already rejects pass-through modules,
   which keeps away the one-thin-function-per-sentence shape
   `untangle`'s backlog discussion warned about. For UI code the concept is
   what the user names: a screen, a panel, a step in a workflow, so a
   usability report leads to one directory. Check: a fresh agent reading
   only the file describes it in one sentence of glossary terms.
   `CODING_STANDARDS.md` now covers part of this: a file's exports are in
   its first 60 lines, and exports that don't fit there even with the
   helpers moved down mean the file holds more than one concept.
2. **A rule is decided in one place.** The code that decides something the
   user sees (a verdict, a badge, whether a validation passes, a price) is
   one module of pure functions over domain objects. Loading, saving and
   rendering call it and hold no branches of the rule. Cut when such
   branches turn up in a component, route handler or query. Check, which
   runs: coverage compared between tests that expect different verdicts
   lands in one module (`untangle`'s `deciding-code.sh`), and a change put
   in the rule's terms touches one module per concept it changes.
3. **A trust boundary is a file boundary.** Structure does not make code
   secure, but it decides whether a reviewer can check that it is. Access
   (one place per entity whose queries all carry the owner filter) and
   untrusted input (one place parsing it into domain objects) live in files
   of their own. Domain modules never import the request, the session or
   the raw database client. Cut when a file both touches those and makes
   domain decisions. Check, which runs: an import restriction in the linter
   (`no-restricted-imports`, dependency-cruiser), so a security review reads
   the boundary files and can skip the rest.
4. **What changes together is measured from history.** Files in different
   directories that change in the same commit most of the time (say more
   than half of the commits touching either) move together. A file whose
   commits fall into separate groups, each changing with different
   neighbours, splits along those groups. Code only one feature uses stays
   with it. Code several use becomes its own module only where it is a
   concept in the sense of rule 1, and otherwise stays with the feature that
   uses it most, so no `utils` appear. Check, which runs: a script over
   `git log --name-only` printing pairs and files above the thresholds,
   which `restructure` could run on its regular sweep.

The line count stays at most as a smell critique reports, at about 1000
lines, to be looked at against rules 1 and 2. It is no reason to split.

## Open

- **Wording waits for `untangle`.** Its criteria leave this rule out of
  scope so it can be worded once `untangle` has produced a result.
- **Coverage per verdict for new code.** Rule 2's check needs it, and
  `implement` does not produce it today.
- **Thresholds** for rule 4, and whether its script lives in `restructure`,
  `critique` or both.
- **Five copies.** The standard is copied into `implement`, `critique`,
  `restructure`, `find-criteria` and `criteria-to-tickets`. The ticket-size
  thresholds in `criteria-to-tickets/SKILL.md:27` and
  `criteria-to-tickets/VERIFY.md:27` are a separate rule and need looking
  at on their own.
