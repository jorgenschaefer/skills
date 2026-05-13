# Jorgen's agent skills

Custom [agent skills](https://skills.sh) for Claude Code and other AI agents.

## Install all skills

```bash
npx skills add jorgenschaefer/skills
```

## Install a specific skill

```bash
npx skills add jorgenschaefer/skills@<skill-name>
```

## Available skills

### Project setup

- **architecture-init** — bootstrap ARCHITECTURE.md in a brownfield project by excavating cross-cutting architectural constraints from the existing codebase
- **ubiquitous-language-init** — bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project by excavating domain terminology from the existing codebase

### Workflow phases

- **discovery** — explore a feature or problem; produces a Feature Brief with a problem description and user stories
- **design** — translate a Feature Brief into a Design Doc describing the software architecture (modules, interfaces, external systems, communication patterns, data model)
- **planning** — break a Design Doc (or Feature Brief, or problem statement) into independently-deployable tickets; every ticket is a tracer bullet
- **implementation** — orchestrates the full implementation loop for a feature slug; spawns `implementation-tdd` and `implementation-tdd-review` subagents per ticket
- **implementation-tdd** — implement a single ticket using TDD (red-green-refactor); also the subagent used by the implementation orchestrator

### Reviews

- **discovery-review** — review a Feature Brief before it advances to design
- **design-review** — review a Design Doc before breaking into tickets (highest-leverage review)
- **planning-review** — review a Ticket Backlog before implementation begins
- **implementation-tdd-review** — review a code change before merging; checks ticket compliance and applies all twelve code-quality dimensions
- **refactor-design-review** — review a Refactoring Proposal before it advances to planning

### Code review

- **code-review** — review code quality for any branch, PR, staged changes, or files — standalone, no workflow context needed

### Maintenance

- **boy-scout** — triage incidental code finds: apply trivially safe fixes immediately, create tracked tickets for everything else
- **refactor-design** — comprehensive structural review of a codebase to identify architectural friction and produce a Refactoring Proposal (feeds directly into planning)
- **repo-overview** — orient a new developer to an unfamiliar codebase: tech stack, code organization, domain model, main workflows, and where to start reading
- **workflow-status** — report the current phase and artifact state of an in-progress feature

## Feature lifecycle

When a feature is fully implemented and its final review is approved, delete the feature folder:

```bash
rm -rf docs/features/<feature-slug>/
```

The durable artifacts — any updates to [`ARCHITECTURE.md`](ARCHITECTURE.md), [`UBIQUITOUS_LANGUAGE.md`](UBIQUITOUS_LANGUAGE.md), and `CLAUDE.md` — have already been written. The feature folder is working memory for the workflow; git history preserves it if you ever need to look back.

## Credits

The TDD reference files in `implementation-tdd/` (`tests.md`, `deep-modules.md`, `mocking.md`, `interface-design.md`, `refactoring.md`) are adapted from [Matt Pocock](https://mattpocock.com)'s TDD skill.

## Adding a new skill

Each skill is a subdirectory containing a `SKILL.md` file:

```
my-skill/
  SKILL.md       # Required: frontmatter + instructions
  *.md           # Optional: additional reference files
```

`SKILL.md` frontmatter:

```yaml
---
name: my-skill
description: One-line description used for discovery.
---
```
