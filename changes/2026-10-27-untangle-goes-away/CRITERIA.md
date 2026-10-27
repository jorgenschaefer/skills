# Criteria: untangle goes away

## Problem
To make the code follow the user's concepts, as the developer relays them, the pipeline asks the developer to approve how the code is laid out: which module each concept becomes, with its path, functions and parameters, the names of new directories, and a test rewritten against the new modules. The developer does not read the code, so they cannot judge these and don't care to; the manifesto leaves them to the agents. What should be true instead: nothing in the pipeline asks the developer to decide the shape of the code, and what they approve is only what the manifesto marks as theirs. Agents being able to explain how and why things happen in the user's concepts is still wanted. How to get there is not settled here.

The instance: while bringing what the developer approves in line with the manifesto (commit 8559948, 2026-10-27), the user noticed that `untangle/SKILL.md` asks the developer for each module's path and "its functions or types and their parameters", has "A new directory for a concept the glossary has no term for ... named by the developer", and shows "one call from an existing test, rewritten against the new modules". Its acceptance-criteria template reads "<Concept> is the module `<path>`". The same change spent a criterion, AC-12, on keeping `untangle`'s copy of the criteria format in step with `find-criteria`'s.

## Acceptance criteria
### Behaviour
- **AC-1** After `./sync.sh`, typing `/untangle` in a new session finds no skill.
- **AC-2** Outside git history and `changes/`, nothing in the repository describes `untangle` as a skill, a step or a way into the criteria.
- **AC-3** Once the developer says they understand an explanation, `explain-code` ends without pointing them at another skill.
- **AC-4** When `restructure` finds a rule the code follows only by habit - a layout, a boundary nobody wrote down - it decides itself whether to make it a check, and asks the developer nothing about it. Each check it adds is named in its report in one line.
- **AC-5** When `restructure` finds a restructuring it cannot prove preserves behaviour, it leaves the code as it is and names it in its report in one line, in the user's words, with what would get easier. It asks the developer nothing about it.
- **AC-6** `restructure` still proposes feature cuts, merged concepts and renaming a name in stored data or on the wire to the developer. Each proposal says, in the user's words, what the user loses and which future changes get easier, and names no part of the code.
- **AC-7** `./test.sh` passes.

### What production must show
None.

### Security policy
None.

### Information model
None.

## Agreed design
`untangle` is deleted, and so is everything that points at it, including the count of `CRITERIA_FORMAT.md`'s copies in `test.sh`. The README describes `restructure` as it now behaves. `restructure` stops putting decisions about the shape of the code to the developer: it decides layout rules itself, and reports a restructuring it cannot prove in one line instead of proposing it.

## Technical decisions
- **Concepts** No new concept. The second way into the criteria, from an explanation, goes away.
- **Wire formats** none
- **Hard to reverse** none. The skill stays in git history, and `sync.sh` removes the link that no longer resolves.

## Out of scope
- What `explain-code` is for, and how to ask "how or why does this happen" in the user's concepts. A new backlog item at acceptance.
- Where a restructuring `restructure` finds and cannot prove should go beyond the line in its report. That is the backlog item `refactor-phase`.
- The refactorings a build suggests for what was hard to change (`implement/SKILL.md:70`), which `/accept-criteria` puts to the developer as follow-ups. Where they should go is also `refactor-phase`.
- Keeping the code cut along the user's concepts: `cut-files-by-concept` and `find-code-before-understanding-is-lost`.
- Builds asking the developer to confirm a concept's name not taken from the glossary (`implement/SKILL.md:65`). That is a decision about concepts, and stays the developer's.

## Ruled out
- **Keeping `untangle`, recast so the developer approves only concepts and a sample change** - the user wants the whole idea gone, and it keeps a second route to keep in step with the criteria format.
- **Deleting only `untangle`** - `restructure` would still put layouts to the developer.
