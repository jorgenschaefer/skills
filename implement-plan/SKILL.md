---
name: implement-plan
description: Build one part of a change's plan - plan.md itself, or one of its parts in plan/ - with implement-code, inside run.sh with nobody to ask - updating the plan where the build departs from it, and halting instead of asking where a hard decision or a hard test would have to change. Run by run.sh for each part.
---

# Implement a plan

Build one part of a plan, so that its steps are true, and leave the plan describing what was built and what is still to come.

This skill's `PLAN_FORMAT.md` settles the shape of the plan and its parts.

## What you are given

**One part**: a file in the change's `plan/`, or `plan.md` itself where the plan was not split. It is your spec. Read it whole. Read `plan.md` and the later parts only where you have to update them, as below.

**Nobody is there to ask.** Where a skill says to ask the developer, halt instead, as below.

## Build it

**Use `/implement-code`** with the part as its agreed spec, and tell it that you commit its work yourself and that nobody is there to ask. It writes the code and has it reviewed by `review-code`.

**Every soft decision is yours**, including one the plan made. Change it where the code shows a better way.

**Write the hard tests the part lists**, as it names them, each a file with `.hard.` before its test suffix.

**Where the build departs from the plan**, update the part, `plan.md` and the later parts that rest on what changed, in the same commit as the code. A later part that reads the plan must find what was really built.

## Halt instead of asking

Append a `## Halt` section to the part naming the kind and what you were stopped by, set its `status: halted`, commit the part, and stop.

- **`departure`**: the build would have to make a hard decision the plan does not settle, or change one the developer approved, or change, rename or delete an existing `.hard.` file the part does not list as changed.
- **`blocked`**: a precondition the plan assumed is not there.
- **`mystery`**: a failure you cannot explain, which is different from one you cannot fix.

## Finish

**Write what `implement-code` leaves standing into the part's `## Left standing`.** Nobody reads your closing message in an unattended run. Set the part's `status: done`, and commit the code, the part and any plan updates together, in one commit, with `git-commit-message`. Stage only the files you touched; never `git add -A`.

**Never write `status: doing`.** It belongs to the runner.
