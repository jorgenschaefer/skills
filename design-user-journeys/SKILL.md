---
name: design-user-journeys
description: Work out with the developer which user journeys a change affects - who uses the software and for what, in a few steps each - with real alternatives, the simplest first, and write the agreed journeys into journeys/. Use when a change affects who uses the software or what for, when create-spec needs the journeys of a design, and on "write the journeys", "which journeys does this change".
---

# Design the user journeys

Work out with the developer which journeys a change affects, and how each reads once the change is built: who uses the software, and for what.

This skill's `JOURNEY_FORMAT.md` settles the shape of a journey. A journey is light: a few steps, as a user would tell a colleague. The details of each step are the design's and, later, the code's.

## Start from the problem

**Take what the change is for from your caller**, or from the conversation. Where there is none, ask what the change is for before you design anything.

**Do not reopen the problem once it is agreed.** Where you become convinced it is wrong, say so plainly and stop.

## Find the journeys

**Read the codebase and `journeys/` first**: what is already there, what the project calls things, and who can do what today.

**List the journeys this change affects**, existing and new, and the ones it ends, and show them to the developer.

**Where the software already does something the change affects and no journey describes it, write that journey first**, from what the software does today: read the code, and run the software where you can. Show it and get the developer's confirmation that it is right before you change it. It describes the software as it is, so a wrong one is corrected here, not designed around.

## Work out each journey

**Offer real alternatives where there are any**, the simplest first and called the simplest. Two that differ only in how much of the same thing they do are one. Give each its effort and the complexity it adds, next to what it gives, then recommend one and say why. Effort is a size from XS to XL. Complexity is a few words naming what it adds, not a size.

**Walk each journey with the developer**: who goes through it, what they want, and the few steps they take. As many steps as a user would tell a colleague, usually three to seven: not every click, and not every special case.

**For every journey, ask who goes through it.** "Who" is what grants access: everything no journey gives someone is denied. Show each journey the change opens to someone who could not do it before, and each one it takes away, and get a yes for each.

**Use the user's words.** A new thing gets its name from the user, and the journeys use that name.

**Do not put details of the code to the developer** - files, modules, ideas for how to build it. They are the builder's.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the developer says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

## Hand them back

**Show each journey the change affects as it will read afterwards, and ask whether this is right.** A no sends you back into the walk.

**Write the agreed journeys into `journeys/`**, in `JOURNEY_FORMAT.md`'s shape, delete the files of the ones the change ends, and hand all their paths back to your caller. Do not commit them: your caller does. Where you were used on your own, the developer commits them.
