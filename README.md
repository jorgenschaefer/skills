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

- **cleanup-repo** - clean up the current project in two passes: find code to delete (dead code, code unrequired by tests/spec, absence-asserting tests) and code to refactor (YAGNI and KISS violations), then produce a reviewable plan and stop for approval before changing anything
- **critique** - review code against a focused set of quality standards (correctness, maintainability, security), over either a branch diff or a whole project; supplements rather than replaces Claude's own judgment
- **discovery** - interview the user about a feature idea, reacting to throwaway HTML mockups for UI decisions; produces an inline summary covering why, success criteria, non-goals, domain, user stories, design, and implementation decisions
- **discovery-increment** - carve the next vertical-slice `INCREMENT-NN.md` from a large `/discovery`-shaped source spec, ready for /implement to consume
- **implement** - implement a feature end-to-end from a description: planned task list, TDD red/green/refactor, then code review and a traceability check against intent
- **repo-overview** - orient a new developer to an unfamiliar codebase: tech stack, code organization, domain model, main workflows, and where to start reading
- **ubiquitous-language-init** - bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project by excavating domain terminology from the existing codebase
- **upgrade-dependencies** - upgrade npm dependencies safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running tests/tsc/lint at every step; also reconciles the Node version across `.nvmrc`, Dockerfile, and `@types/node`
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
