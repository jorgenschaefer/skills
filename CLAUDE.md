# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of [agent skills](https://skills.sh) for Claude Code. Each skill is a subdirectory containing a `SKILL.md` file with YAML frontmatter (`name`, `description`) followed by the skill's instructions in Markdown.

Published as `jorgenschaefer/skills`. Install all skills: `npx skills add jorgenschaefer/skills`. Install one: `npx skills add jorgenschaefer/skills@<skill-name>`.

## Skill structure

```
<skill-name>/
  SKILL.md       # Required: frontmatter + instructions
  *.md           # Optional: reference files the skill can read
```

The `review/SKILL.md` file contains shared base content read by each phase-specific review skill (`discovery-review`, `design-review`, `planning-review`, `implementation-review`). These are top-level skill directories, not nested sub-skills.

## The workflow these skills implement

The skills together define a phased agentic development workflow. Each skill requires the feature slug as a required argument at invocation time (e.g., `/discovery payment-retry`); all artifacts for a feature live under `docs/features/<feature-slug>/`.

1. **discovery** → produces a Feature Brief at `docs/features/<feature-slug>/discovery.md`
2. **design** → produces a Design Doc at `docs/features/<feature-slug>/design.md` + ADRs at `docs/adr/<NNNN>-<slug>.md`; reads `discovery.md` (or `refactoring.md` for refactor-initiated features) as the entry artifact
3. **planning** → produces a Ticket Backlog at `docs/features/<feature-slug>/tickets/` (individual ticket files + `README.md` overview)
4. **implementation** → implements one ticket at a time using TDD; incidental cleanup finds go to `docs/features/boy-scout/tickets/`
5. **review** → four phase-specific skills (`discovery-review`, `design-review`, `planning-review`, `implementation-review`), all reading the shared base in `review/SKILL.md`; reviews are saved at `docs/features/<feature-slug>/<artifact>-review-<NN>.md`

`refactor-project` is an alternative entry point: it produces a Refactoring Proposal at `docs/features/<feature-slug>/refactoring.md` instead of a Feature Brief. Downstream skills (design, planning) accept either entry artifact.

`workflow-status` is a utility skill: given a feature slug, it reads the feature folder and reports what phase the work is in, what artifacts exist, and what the next step is.

Each skill is intended to be invoked in a clean context, separate from the conversation that produced the artifact it consumes. The review skills in particular depend on "fresh eyes" — they must not share context with the producing conversation.


## Adding or modifying skills

When writing or editing a `SKILL.md`:
- Keep the frontmatter `description` precise: it is used for discovery/matching, so it should describe the trigger conditions, not just the skill name.
- The instructions describe *role*, *inputs*, *process*, and *output format* — not just what the skill does, but how the agent should behave while doing it.
- Cross-references between skills (e.g., `review/SKILL.md` referenced by each phase-specific review skill) are by relative path and prose convention, not by any automated mechanism.
- After adding a skill, list it in `README.md` under "Available skills".
