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

- **adr-init** — bootstrap ADRs in a brownfield project by excavating load-bearing design decisions from the existing codebase
- **[ubiquitous-language](https://github.com/mattpocock/skills/tree/main/skills/deprecated/ubiquitous-language)** — initialize the UBIQUITOUS_LANGUAGE.md file (Matt Pocock)

### Workflow phases

- **discovery** — explore a feature or problem and produce a Feature Brief before any design or code
- **design** — translate a Feature Brief into a Design Doc and Architecture Decision Records
- **planning** — break a Design Doc into independently-deployable tickets using the tracer-bullet approach
- **implementation** — implement one ticket at a time using TDD (red-green-refactor)

### Reviews

- **discovery-review** — review a Feature Brief before it advances to design
- **design-review** — review a Design Doc and ADRs before breaking into tickets (highest-leverage review)
- **planning-review** — review a Ticket Backlog before implementation begins
- **implementation-review** — review a code change before merging; checks ticket compliance and delegates code quality to the code-review skill
- **refactoring-review** — review a Refactoring Proposal before it advances to design

### Code review

- **code-review** — review code quality for any branch, PR, staged changes, or files — standalone, no workflow context needed

### Maintenance

- **boy-scout** — triage incidental code finds: apply trivially safe fixes immediately, create tracked tickets for everything else
- **refactor-project** — comprehensive structural review of a codebase to identify architectural friction and propose a refactoring plan
- **workflow-status** — report the current phase and artifact state of an in-progress feature

## Feature lifecycle

When a feature is fully implemented and its final review is approved, delete the feature folder:

```bash
rm -rf docs/features/<feature-slug>/
```

The durable artifacts — ADRs in `docs/adr/` and any updates to `CLAUDE.md` — have already been written. The feature folder is working memory for the workflow; git history preserves it if you ever need to look back.

## Credits

The TDD reference files in `implementation/` (`tests.md`, `deep-modules.md`, `mocking.md`, `interface-design.md`, `refactoring.md`) are adapted from [Matt Pocock](https://mattpocock.com)'s TDD skill.

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
