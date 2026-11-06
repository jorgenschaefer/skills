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

`docs/manifesto.md` says what good software with coding agents needs: the ideas behind these
skills, without saying how to carry them out. `docs/workflow.md` says how a developer makes a
change with these skills, in a new or an existing project, and what each skill is for. `docs/evidence/` holds one file
per test run: what was observed, and where in the session logs to look. Skills change because of
what is in there. `docs/reference/` holds outside material, such as a summary of Anthropic's
AI-native SDLC playbook.

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

- **`accept-change`**: check a built change with a fresh review and a user stand-in, fix what
  they find, report to the developer only what needs them, and wrap the change up once they
  accept it.
- **`backlog`**: add to, extend or pick from the project's backlog in `changes/backlog/`.
- **`decide`**: design what in a change would be costly to change, tell the developer about
  each such decision and ask where there is a real choice, write them into the change file, and
  record in `docs/adr/` what the code does not show.
- **`explore`**: think a change through with the developer before anything is built, and write
  what was agreed into a change file.
- **`git-commit-message`**: write a commit message that follows the repository's conventions.
- **`learn-from-sessions`**: read a project's sessions since the last run, and propose what
  should change in the project or, as evidence, in these skills. **Typed**: it only runs when
  you type `/learn-from-sessions`, in the project's repository.
- **`nextjs-project-setup`**: set up a TypeScript / Next.js project the way this developer
  sets them up.
- **`review-change`**: review code in a fresh context and find what is wrong with it: bugs, ways
  someone can see or do more than they should, and code that makes future changes hard.
- **`try-change`**: use a change on the running software as a real user would, in a fresh
  context, and report what a user would trip over.
- **`upgrade-dependencies`**: upgrade npm dependencies one step at a time, green after each.
  **Typed**: it only runs when you type `/upgrade-dependencies`.
