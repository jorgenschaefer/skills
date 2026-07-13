---
name: repo-overview
description: Use when the user wants an orientation to an unfamiliar repository. Trigger on phrases like "give me an overview of this repo", "I'm new to this codebase", "what does this repo do", "onboard me to this project", or when the user has just arrived at a repo they haven't seen before.
---

# Repo Overview

You are a tour guide for a developer who is new to this codebase. Your job is to surface what matters fast and skip what they can discover themselves. Print a concise orientation report to the conversation — do not save it to a file.

**Calibration is the core challenge.** Include things that require reading the code to discover; exclude things obvious from file names or standard framework knowledge. After reading your report, a new developer should be able to find any piece of functionality in the repo.

## Before starting

No arguments are required. Explore the current working directory.

If `ARCHITECTURE.md` or `UBIQUITOUS_LANGUAGE.md` already exist, read them first — they may contain exactly what you need and save significant exploration time.

## Parallelize the reads

Spawn up to 3 `Explore` subagents in parallel for steps 1-7 below. Suggested split:

- **Agent A:** tech stack (step 1), directory tree (step 2), entry docs (step 3).
- **Agent B:** existing architecture/language docs (step 4), domain/model layer (step 5).
- **Agent C:** service/application layer (step 6), entry points (step 7).

Each agent returns a short structured summary; the main loop synthesizes them into the report. Step 8 (one representative test file) stays in the main loop - it's small and confirms the understanding the agents have already surfaced.

The numbered list below is the contract for what each agent should look for, even though steps 1-7 no longer run sequentially in the main loop.

## Exploration sequence

Work through these in order, stopping each step once you have enough for that section:

1. **Dependency manifest** — `package.json`, `go.mod`, `pyproject.toml`, `Gemfile`, `pom.xml`, `Cargo.toml`, etc. → identify tech stack
2. **Directory structure** — two levels deep → code organization
3. **Entry documentation** — `README.md`, `CLAUDE.md`, `AGENTS.md` → stated purpose and conventions
4. **Existing architecture docs** — `ARCHITECTURE.md`, `UBIQUITOUS_LANGUAGE.md` → leverage prior art
5. **Domain/model layer** — directories named `domain/`, `models/`, `entities/`, or equivalent → core domain objects
6. **Service/application layer** — directories named `services/`, `use_cases/`, `application/`, `handlers/`, or equivalent → main workflows
7. **Entry points** — router files, CLI definitions, queue consumers → confirm workflows, find precise entry points
8. **One representative test file** — to confirm your domain and workflow understanding

Do not read every file in a directory. Stop each step as soon as you have enough to fill that section.

## What to include and exclude

### Technology stack

**Include:** primary language + version; frameworks that shape code structure; infrastructure clients that are architecturally significant; non-obvious libraries whose presence would surprise a developer.

**Exclude:** dev/build tools, test libraries, utility packages, transitive dependencies.

### Code organization

**Include:** all top-level directories with a one-line annotation each; the organizing principle in one sentence (domain-first? layer-first? by feature?).

**Exclude:** generated/vendor directories and anything self-evident from the name.

### Domain model

**Include:** 5–8 entities and aggregates visible in multiple layers (API, service, persistence). One row per entity: what it represents, key relationships.

**Exclude:** value objects, enums, DTOs, request/response shapes, configuration objects, single-module internals. Do not list model fields.

### Main workflows

**Include:** 3–7 flows invoked by users or external callers (HTTP, CLI, queue); the primary stated purpose of the system; flows crossing module boundaries or involving multiple domain objects; background jobs central to the system's function.

**Exclude:** pure CRUD flows with no domain logic; admin/debug/health-check endpoints; operational background jobs (cleanup, reindex); flows internal to one module.

For each workflow: name, entry point as `path/to/file:function_or_handler`, one-sentence description.

### External integrations

**Include:** each external system, the access pattern (REST, gRPC, queue, SDK), and the adapter location.

**Exclude:** adapter internals, configuration details, retry/timeout parameters.

### Where to start

3–5 files a new developer should read first, in the order that builds understanding most efficiently. One reason per file — why this specific file, what it teaches that the others don't. If `ARCHITECTURE.md` or `UBIQUITOUS_LANGUAGE.md` exist in the repo, always include them first — they are the cross-session memory for agents and the shared domain vocabulary, and a developer (or agent) who doesn't know they exist can't benefit from them.

## Traps to avoid

- Do not list model fields
- Do not document every endpoint — only workflow entry points
- Do not explain self-evident CRUD flows
- Do not enumerate every package — only non-obvious ones
- Do not describe auth flow mechanics — a pointer to where auth lives is enough
- Do not include env vars, configuration, or deployment details
- Do not include historical rationale for decisions
- Do not include code snippets — file paths and function names are enough

## Output format

```
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
| Entity | What it represents | Key relationships |
|--------|-------------------|-------------------|
...

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

Aim for a report that takes 5 minutes to read, not 30.
