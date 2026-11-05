---
name: nextjs-project-setup
description: Set up a new TypeScript / Next.js project the way this developer sets them up - Node, Biome, Vitest, the check command and the preferred libraries - or bring an existing one in line. Use when creating a Next.js app, starting a TypeScript web project in an empty repository, or when a change or a part of one sets up a project that has no code yet.
---

# Set up a Next.js project

These are the developer's choices for every TypeScript / Next.js project. Where a project already decides something differently, its own decision wins: change it only where you were asked to.

Install the current versions. Pin nothing here that the package manager pins for you.

## Node

The latest LTS release of Node. Write its major version to `.nvmrc`.

## Libraries

Prefer these over alternatives that do the same job:

- **Next.js**, with the App Router;
- **Zod** for every input from outside;
- **TanStack Query** (`@tanstack/react-query`) for data the client fetches;
- **Mantine** for the UI.

Where the project uses Mantine, set up PostCSS the way Mantine's Next.js guide does, with `postcss-preset-mantine` and `postcss-simple-vars`, and take icons from `@tabler/icons-react`.

## Biome

Biome lints and formats everything; there is no ESLint and no Prettier. Where `create-next-app` sets up ESLint, say no or remove it.

Run `npx @biomejs/biome init`, so the `$schema` matches the installed version, then set `biome.json` to the recommended presets with these changes:

```json
{
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "files": { "includes": ["**", "!changes", "!public", "!**/*.svg"] },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2 },
  "linter": {
    "enabled": true,
    "rules": {
      "preset": "recommended",
      "style": { "noNonNullAssertion": "error" }
    }
  },
  "assist": {
    "enabled": true,
    "actions": { "source": { "organizeImports": "on" } }
  }
}
```

## Tests

Vitest runs the tests.

## Scripts

`package.json` has at least these:

```json
{
  "check": "tsc --noEmit && biome check && vitest run",
  "test": "vitest run",
  "lint": "biome check",
  "format": "biome check --write"
}
```

`npm run check` runs every test, the type check and Biome, and exits non-zero on any failure. `npm run format` also organizes the imports.

Declare it in `CLAUDE.md`, so agents find it:

```markdown
Fast check: `npm run check`
```

Run `npm run check` once the setup is done. It passes on the empty app.
