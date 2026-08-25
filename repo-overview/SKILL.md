---
name: repo-overview
description: Use when someone needs an orientation to a repository — "give me an overview of this repo", "I'm new to this codebase", "what does this repo do", "onboard me to this project" — or asks to write or refresh `ARCHITECTURE.md` ("regenerate the architecture doc", "the architecture doc is stale").
---

# Repo Overview

You are a tour guide for a developer who is new to this codebase. Your job is to surface what matters fast and skip what they can discover themselves.

**Calibration is the core challenge.** Include things that require reading the code to discover; exclude things obvious from file names or standard framework knowledge. After reading your report, a new developer should be able to find any piece of functionality in the repo.

## Where the report goes

Present it inline, and write the same text to `ARCHITECTURE.md` at the root of the repository you explored. It is a **build artifact, not a document** — re-derived whole every time this runs — and the banner in the output format below says so, because the only reader who can act on that is the person tempted to edit it.

Say in your reply that you wrote it, and where. Three cases where you do not: the working directory is not a repository, the tree is not the user's to write into, or an existing `ARCHITECTURE.md` has uncommitted edits — overwriting a committed file is what this is for, but silently taking somebody's unsaved work with it is not. In that last case say what you found and let them decide.

If the project commits it, the next run's overwrite shows up as a diff, which is the most useful form this file takes: what changed since somebody last looked.

## Before starting

No arguments are required. Explore the current working directory.

If `UBIQUITOUS_LANGUAGE.md` exists, read it first — it is the project's agreed vocabulary, and the report uses those words rather than inventing parallel ones.

Read any existing `ARCHITECTURE.md` **yourself, and do not hand it to the agents below**. It describes the code as it was when somebody last ran this, and the reason to run again is that something has moved — an agent that reads the old claims while deriving the new ones will confirm them, which is also how a hand-edit survives the overwrite that was supposed to end it. Derive from the code, then diff what you found against what the file said. What changed is the most interesting thing you can tell the reader.

## Parallelize the reads

Spawn up to 3 `Explore` subagents in parallel for steps 1-7 below. Suggested split:

- **Agent A:** tech stack (step 1), directory tree (step 2), entry docs (step 3).
- **Agent B:** the project's vocabulary (step 4), domain/model layer (step 5).
- **Agent C:** service/application layer (step 6), entry points (step 7).

Each agent returns a short structured summary; the main loop synthesizes them into the report. Step 8 (one representative test file) stays in the main loop - it's small and confirms the understanding the agents have already surfaced.

The numbered list below is the contract for what each agent looks for.

## What to explore

Stop on each item once you have enough for its section - reading every file in a directory is never the goal.

1. **Dependency manifest** — `package.json`, `go.mod`, `pyproject.toml`, `Gemfile`, `pom.xml`, `Cargo.toml`, etc. → identify tech stack
2. **Directory structure** — two levels deep → code organization
3. **Entry documentation** — `README.md`, `CLAUDE.md`, `AGENTS.md` → stated purpose and conventions
4. **`UBIQUITOUS_LANGUAGE.md`** → the vocabulary to reuse rather than reinvent
5. **Domain/model layer** — directories named `domain/`, `models/`, `entities/`, or equivalent → core domain objects
6. **Service/application layer** — directories named `services/`, `use_cases/`, `application/`, `handlers/`, or equivalent → main workflows
7. **Entry points** — router files, CLI definitions, queue consumers → confirm workflows, find precise entry points
8. **One representative test file** — to confirm your domain and workflow understanding

## What to include and exclude

### Technology stack

**Include:** primary language + version; frameworks that shape code structure; infrastructure clients that are architecturally significant; non-obvious libraries whose presence would surprise a developer.

**Exclude:** dev/build tools, test libraries, utility packages, transitive dependencies.

### Code organization

**Include:** all top-level directories with a one-line annotation each; the organizing principle in one sentence (domain-first? layer-first? by feature?).

**Exclude:** generated/vendor directories and anything self-evident from the name.

### Domain model

Grouped the way the code is, which step 2 already established: by module where modules own behaviour, and by layer where the repo is layer-first — in which case the grouping column carries the layer and the rows are what a reader would otherwise have to reconstruct.

Per row: the work objects it holds, and the actions it supports — an action being something an actor does to a work object, named the way the domain names it. "A reviewer rejects an application", not "calls `update()`". Where the code has no domain verbs at all and CRUD really is the whole story, say that in a line instead of inventing them; it is the most useful thing an overview can tell you about a codebase.

**Include:** 5–8 work objects, the aggregates among them, and where each lives; the actor for each action; at most a handful of actions per row, the ones that carry the domain. Where an aggregate boundary is not obvious from the names, one clause on what changes together inside it.

**Exclude:** value objects, enums, DTOs, request/response shapes, configuration objects, single-module internals. Do not list model fields.

### Main workflows

**Include:** 3–7 flows invoked by users or external callers (HTTP, CLI, queue); the primary stated purpose of the system; flows crossing module boundaries or involving multiple domain objects; background jobs central to the system's function.

**Exclude:** pure CRUD flows with no domain logic; admin/debug/health-check endpoints; operational background jobs (cleanup, reindex); flows internal to one module; auth flow mechanics — a pointer to where auth lives is enough.

For each workflow: name, entry point as `path/to/file:function_or_handler`, one-sentence description.

### External integrations

**Include:** each external system, the access pattern (REST, gRPC, queue, SDK), and the adapter location.

**Exclude:** adapter internals, configuration details, retry/timeout parameters.

### Where to start

3–5 files a new developer should read first, in the order that builds understanding most efficiently. One reason per file — why this specific file, what it teaches that the others don't. Where `UBIQUITOUS_LANGUAGE.md` exists, it goes first: it is the shared domain vocabulary, and a developer who doesn't know it exists can't benefit from it. Never list `ARCHITECTURE.md` itself — the reader is holding it.

### The report as a whole

**Prose and pointers.** File paths and function names carry the detail - no code snippets, no env vars, configuration or deployment details, and no historical rationale for decisions.

## Output format

```
_Re-derived from the code by `/repo-overview` on <today's date, from `date`>. Not
hand-edited: the next run overwrites this file whole, so a correction made here is
a correction lost. Where it is wrong, the code has moved — run it again._

## What This Is
2–3 sentences: what the system does, who uses it, what problem it solves.

## Technology Stack
- **Language:** <name + version>
- **Framework(s):** <name — purpose>
- **Infrastructure:** <DB, cache, message queue, etc.>
- **Notable libraries:** <non-obvious ones only; omit section if none>

## Code Organization
<annotated directory tree, 2 levels, one line per directory>

Organizing principle: <one sentence>

## Domain Model
| Module | Work objects | Actions |
|--------|--------------|---------|
| `review/` | Application, Decision | a reviewer approves or rejects an Application |
...

<one line per aggregate whose boundary isn't obvious: what changes together inside it>

## Main Workflows
1. **<Name>** — `path/to/file:entry_point` — <one sentence>
...

## External Integrations
- **<System>** — <access pattern> — adapter at `path/to/adapter/`
...

## Where to Start
1. `path/to/file` — <why this one first>
...
```

Aim for a report that takes 5 minutes to read, not 30. One text, written once, saved and shown.
