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

Sub-skills (e.g. `review/design-doc`) use nested directories. The parent `review/SKILL.md` contains shared base content; child `SKILL.md` files extend it.

## The workflow these skills implement

The skills together define a phased agentic development workflow. Each skill requires the feature slug as a required argument at invocation time (e.g., `/discovery payment-retry`); all artifacts for a feature live under `docs/features/<feature-slug>/`.

1. **discovery** → produces a Feature Brief at `docs/features/<feature-slug>/brief.md`
2. **design** → produces a Design Doc at `docs/features/<feature-slug>/design.md` + ADRs at `docs/adr/<NNNN>-<slug>.md`; reads `brief.md` (or `proposal.md` for refactor-initiated features) as the entry artifact
3. **planning** → produces a Ticket Backlog at `docs/features/<feature-slug>/tickets/` (individual ticket files + `README.md` overview)
4. **implementation** → implements one ticket at a time using TDD; incidental cleanup finds go to `docs/features/boy-scout/tickets/`
5. **review** → four phase-specific sub-skills (`review/feature-brief`, `review/design-doc`, `review/tickets`, `review/implementation`), all using a shared base in `review/SKILL.md`; reviews are saved at `docs/features/<feature-slug>/reviews/<artifact>-<YYYY-MM-DD>.md`

`refactor-project` is an alternative entry point: it produces a Refactoring Proposal at `docs/features/<feature-slug>/proposal.md` instead of a Feature Brief. Downstream skills (design, planning) accept either entry artifact.

Each skill is intended to be invoked in a clean context, separate from the conversation that produced the artifact it consumes. The `review` sub-skills in particular depend on "fresh eyes" — they must not share context with the producing conversation.

## Adding or modifying skills

When writing or editing a `SKILL.md`:
- Keep the frontmatter `description` precise: it is used for discovery/matching, so it should describe the trigger conditions, not just the skill name.
- The instructions describe *role*, *inputs*, *process*, and *output format* — not just what the skill does, but how the agent should behave while doing it.
- Cross-references between skills (e.g., `review/SKILL.md` referenced by each sub-skill) are by relative path and prose convention, not by any automated mechanism.
- After adding a skill, list it in `README.md` under "Available skills".
