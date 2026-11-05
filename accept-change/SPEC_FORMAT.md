# Spec format

`changes/YYYY-MM-DD-<slug>/spec.md` is the design of one change: what the software will do once the change is built. `create-spec` writes it beside `intent.md`, `create-plan` plans the build from it, and acceptance holds the change against it.

```markdown
# <The change, in a few words>

Designed for the problem in `intent.md`, beside this file.

## Journeys
<Each journey the change adds, changes or ends, by its path in `journeys/`, with one line on what changes in it and the part of intent.md it serves.>

## Domain
<The things the user works with that the change adds or changes: how they hang together, their rules and their lifecycle, in the user's words. Each rule a user relies on says so, such as "a training keeps the name of its plan, so deleting a plan loses nothing". Then what happens to what the software already holds. Each item names the part of intent.md it serves.>

## Frontend
<The prototype, linked - `prototype/` beside this file - with:

**Agreed: build to this, do not redesign.**

Then what the prototype does not show: each screen once, however many journeys use it, and what happens between the steps. Each item names the journey steps it serves.>

## Failure cases
- If <what goes wrong>, the user sees <what>, and their work <is kept / is lost>.

## Constraints
- <One statement, with one condition.> Met by: <how the design meets it>. Checked by: <a test from the outside, a reviewer, or a person's judgement>.

## Not in this change
<What a builder might wander into, and should not. Then each item that could wait, with the path of its backlog item.>
```

## What the parts are for

**`intent.md` holds the problem, and this file does not restate it.** Each part of the design names the part of `intent.md` it serves - Problem, Outcome or What must stay true - so a part that serves none shows.

**One section for each part of the design the change has.** A change with no new screens and no new data may have Journeys only; a change to a rule may have Domain only. Leave out a section the change does not have.

**The journeys themselves are in `journeys/`**, where they outlive the change. This file only names them.

**The domain is in the user's words**: no tables, columns or IDs. `create-plan` turns it into a schema, and each rule a user relies on into a hard test.

**The frontend is the prototype.** The builder builds the UI to it. What it does not show is written here.

**A failure case is here only if it would really happen to this user.** Each costs a test, a walk and usually a fix. The last part, what happens to the user's work, decides whether it gets a hard test: one where the user would otherwise lose work, or see something they must not see, gets one. How the error looks and what it says is soft.

**A constraint is what must stay true**, from `intent.md`, or a limit on the solutions found in the design. One statement with one condition, so it can be checked. A constraint that must outlive the change becomes a hard test in the plan, or else one line under `## Constraints` in the project's `CLAUDE.md`.

**"Not in this change" keeps the build from wandering**, and records what could wait. Each item that could wait is a backlog item of its own. Leave out the section when there is nothing.

**A `spec.md` for other work has no fixed shape.** Where `debug`, `solve-problem` or `refactor-codebase` hand work to `create-plan`, they write their agreed spec into `spec.md` in their own words: a bug's report, intention and cause, a "Done when" list, a refactoring plan. Such a change has no `intent.md`.

**It is not permanent.** The change's whole directory - `intent.md`, `spec.md` and `prototype/` included - is deleted once the change is accepted. What outlives it is in the journeys, `UBIQUITOUS_LANGUAGE.md`, the hard tests and the code.
