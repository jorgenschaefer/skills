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

## How it works

`IDEAS.md` says what good software with coding agents needs: the ideas behind these skills,
without saying how to carry them out. `anthropic-sdlc.md` summarizes Anthropic's AI-native
SDLC playbook, as a reference. `WORKFLOW.md` says how a developer changes an existing
project with these skills.

A skill installs alone and cannot read a sibling's directory, so a file two skills need is
copied into each.

### The sync

`./sync.sh` links every directory here that holds a `SKILL.md` into `~/.claude/skills`, so
editing a skill in this repository is editing the one a session reads. Then it removes the
links that no longer resolve, because a renamed skill leaves one behind, and a dangling link
fails silently: the agent reads nothing and carries on. It only ever removes symlinks. The real
directories in there are skills from elsewhere, and this is not their owner.

### The tests

`./test.sh` checks that every script passes `shellcheck`, that no skill points at something
that is not there, and what `sync.sh` does.

## Available skills

- **`backlog`**: add to, extend or pick from the project's backlog in `changes/backlog/`.
- **`decide`**: find the decisions in a change that would be hard to undo, tell the developer
  about each and ask where there is a real choice, and record in `docs/adr/` what the code does
  not show.
- **`git-commit-message`**: write a commit message that follows the repository's conventions.
- **`nextjs-project-setup`**: set up a TypeScript / Next.js project the way this developer
  sets them up.
- **`upgrade-dependencies`**: upgrade npm dependencies one step at a time, green after each.
  **Typed**: it only runs when you type `/upgrade-dependencies`.
