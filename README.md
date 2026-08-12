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

- **architektur-auswirkungen** - turn a user story into a high-level analysis of its architecture impact before any code is written (German output): affected components, contract and data-flow changes, only genuinely significant tensions, and proposed ADRs; drafted in chat and written to files only after explicit approval
- **cleanup-repo** - clean up the current project in two passes: find code to delete (dead code, code unrequired by tests/spec, absence-asserting tests) and code to refactor (YAGNI and KISS violations), then produce a reviewable plan and stop for approval before changing anything
- **coding-conventions** - the single source of truth for this project's code-quality standards (simple design, structure and locality, domain layering, validation at the boundary, test coverage, security); read by `/implement` when writing code and `/critique` when reviewing it, so the rules live in one place instead of drifting across skills
- **critique** - review code for quality against the shared `coding-conventions` standard, over either a branch diff or a whole project; verifies each finding before reporting and supplements rather than replaces Claude's own judgment
- **debug** - investigate a bug, test failure, or unexpected behavior to root cause before fixing: reproduce it, instrument component boundaries to find where it breaks, test one hypothesis at a time, and question the architecture after repeated failed fixes
- **decision-brief** - turn a proposed approach (a `/discovery` spec, plan, or PRD) into a one-page decision brief so a reviewer can decide whether to build it as-is or iterate first: surfaces the consequential, contentious, load-bearing, or hard-to-reverse decisions a reviewer might veto, restates each as a neutral tradeoff, and hands the verdict to the reviewer rather than recommending one
- **discovery** - interview the user about a feature idea, reacting to throwaway HTML mockups for UI decisions; produces a feature spec file (written to the repo and presented inline) covering why, success criteria, non-goals, domain, user stories, design, and implementation decisions
- **discovery-increment** - carve the next vertical-slice `INCREMENT-NN.md` from a large `/discovery`-shaped source spec, ready for /implement to consume
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **improve-skill** - improve an existing agent skill (make it more effective, more concise, and clearer for an LLM to follow) without changing what it does: applies safe wording edits directly and surfaces behavior-changing edits as decisions for the author
- **implement** - implement a feature end-to-end from a description: planned task list, TDD red/green/refactor, then code review and a traceability check against intent
- **propose-change** - evaluate a proposed small change or bugfix to existing behavior and turn it into a plan `/implement` can follow: investigate where it lands in the code, weigh cost against benefit, push back on weak ideas, and produce a light written plan (or a reasoned no)
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
