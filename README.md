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

- **discovery** - interview the user about a feature idea; produces an inline summary covering why, success criteria, non-goals, domain, and open questions
- **discovery-increment** - carve the next vertical-slice `INCREMENT-NN.md` from a large `/discovery`-shaped source spec, ready for /implement to consume
- **implement** - implement a feature end-to-end from a description: planned task list, TDD red/green/refactor, then code review and a traceability check against intent
- **repo-overview** - orient a new developer to an unfamiliar codebase: tech stack, code organization, domain model, main workflows, and where to start reading
- **ubiquitous-language-init** - bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project by excavating domain terminology from the existing codebase
- **wdim** - excavate a fuzzy idea, feeling, or critique into clearer phrasing of what the user actually means

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
