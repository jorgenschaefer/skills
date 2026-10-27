---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7
advances:
after:
status:    ready
attempts:  0
---

## Build
Delete `untangle` and everything that points at it, and stop `restructure` from putting decisions about the shape of the code to the developer.

## Done when
> **AC-1** After `./sync.sh`, typing `/untangle` in a new session finds no skill.

> **AC-2** Outside git history and `changes/`, nothing in the repository describes `untangle` as a skill, a step or a way into the criteria.

> **AC-3** Once the developer says they understand an explanation, `explain-code` ends without pointing them at another skill.

> **AC-4** When `restructure` finds a rule the code follows only by habit - a layout, a boundary nobody wrote down - it decides itself whether to make it a check, and asks the developer nothing about it. Each check it adds is named in its report in one line.

> **AC-5** When `restructure` finds a restructuring it cannot prove preserves behaviour, it leaves the code as it is and names it in its report in one line, in the user's words, with what would get easier. It asks the developer nothing about it.

> **AC-6** `restructure` still proposes feature cuts, merged concepts and renaming a name in stored data or on the wire to the developer. Each proposal says, in the user's words, what the user loses and which future changes get easier, and names no part of the code.

> **AC-7** `./test.sh` passes.

## Technical decisions
> **Concepts** No new concept. The second way into the criteria, from an explanation, goes away.

> **Wire formats** none

> **Hard to reverse** none. The skill stays in git history, and `sync.sh` removes the link that no longer resolves.

## Context
Agreed design: `untangle` is deleted, and so is everything that points at it, including the count of `CRITERIA_FORMAT.md`'s copies in `test.sh`. The README describes `restructure` as it now behaves. `restructure` stops putting decisions about the shape of the code to the developer: it decides layout rules itself, and reports a restructuring it cannot prove in one line instead of proposing it.

`sync.sh` takes a target directory as its argument, so AC-1 can be shown against a scratch target rather than `~/.claude/skills`.

What production must show, Security policy and Information model all say "None.".

## Not here
- What `explain-code` is for, and how to ask "how or why does this happen" in the user's concepts. A new backlog item at acceptance.
- Where a restructuring `restructure` finds and cannot prove should go beyond the line in its report. That is the backlog item `refactor-phase`.
- The refactorings a build suggests for what was hard to change (`implement/SKILL.md:70`), which `/accept-criteria` puts to the developer as follow-ups. Where they should go is also `refactor-phase`.
- Keeping the code cut along the user's concepts: `cut-files-by-concept` and `find-code-before-understanding-is-lost`.
- Builds asking the developer to confirm a concept's name not taken from the glossary (`implement/SKILL.md:65`). That is a decision about concepts, and stays the developer's.
- Backlog items under `changes/backlog/` that mention `untangle`: acceptance updates them.

## Left standing
