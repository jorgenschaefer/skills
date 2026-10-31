---
effort: S
utility: M
---

# The builds keep the maintainability findings they leave

A review finding about maintainability that a build leaves unfixed ends up
in its `## Left standing` and nowhere else. `accept-change` settles each such
item and then deletes the change's directory, so the refactor never sees
them. It cannot tell that the same kind of finding keeps coming back from
one change to the next.

In the workout-tracker run of 2026-10-31, the chunks left 138 items standing.
Among them, all rated as nits:

- "`isUniqueViolation` is now in both `exercise-repository.ts` and
  `workout-repository.ts`"
- "The conversion of Nächste Ziele to JSON is in both `plan-repository.ts`
  and `workout-repository.ts`"
- "`workoutName` (`planName ?? "Freies Training"`) exists twice"

`run/prompts.sh` (`review_brief`) tells the final review: "Leave the nits and
everything else for acceptance".

Most of what is left standing is not for the refactor: names the user sees,
blast radius and revert, checks not run, steps no test shows. Those belong
to acceptance.

What the user and Claude agreed on 2026-10-31: the builder, not
`accept-change`, puts these into the friction note, because the developer
accepts code they will not read (`accept-change/SKILL.md`), and a
duplicated helper is a detail of the code. `implement-change` already writes
friction notes ("Write down what was hard"); it would add the
maintainability findings it leaves unfixed, with file and line, and the
final review would do the same for its own. They then survive acceptance in
`changes/friction/`, where `refactor-codebase` reads them.

Related: `refactor-decides-from-measurable-signals`, which needs mistakes
seen more than once.
