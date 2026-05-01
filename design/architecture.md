# Architecture Guide

## About ARCHITECTURE.md

`ARCHITECTURE.md` at the project root is the single record of cross-cutting decisions that constrain future design choices — decisions that are not visible at the point where they become relevant and that affect choices made in parts of the codebase distant from where they were first established.

**Read before relying.** Rationale in this file drifts as the codebase evolves. Before applying a constraint, verify it holds against the current code. The file is a starting point for exploration, not a substitute for it.

## Format

```markdown
# Architecture

Cross-cutting decisions that constrain future design choices. Verify each against the codebase before relying on it — rationale drifts.

## <Area>

| Decision | Rule | Why |
|---|---|---|
| Short name | Prescriptive statement. Include "do not X" where the constraint forecloses something. | One sentence. |
```

Area names emerge from the project. Use whatever grouping fits: Data layer, Auth, API style, Layering, Testing, Infrastructure, etc. One flat section is fine if the project is small.

## When to add an entry

Add an entry when **both** conditions hold:

1. **Not visible at the decision point.** An agent working on a new feature would not naturally read the files where this constraint lives. If the constraint is obvious from the framework, the naming conventions, or the file they're already editing, skip it — the code is the documentation.

2. **Cross-cutting.** The constraint governs choices in parts of the codebase distant from where it was first established. If it applies only to one file or one module, put a comment in that file instead.

Do **not** add entries for:
- Decisions that follow directly from the framework or stack (e.g., "use server actions in a Next.js app" if the whole codebase already does)
- Constraints local to a single file — a comment in that file is the right location
- Things where the code, directory names, or conventions already make the choice unmistakable to a reader

## Updating ARCHITECTURE.md

When a design phase surfaces a new cross-cutting constraint:

1. **Confirm with the user before adding it.** Adding to `ARCHITECTURE.md` without user confirmation is never acceptable.
2. Find the appropriate area group. Add a new group if needed.
3. Add a row: Decision (short name) | Rule (prescriptive, include "do not X" explicitly where relevant) | Why (one sentence).
4. If an existing constraint no longer holds, remove or update the row. Do not add a supersession entry — git records history.
