---
name: nextjs-project-setup
description: Set up a new TypeScript / Next.js project the way this developer sets them up - Node, Biome, Vitest, the check command, the preferred libraries and the login - or bring an existing one in line. Use when creating a Next.js app, starting a TypeScript web project in an empty repository, or when a change or a part of one sets up a project that has no code yet.
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

## Login

Write the login yourself, without an auth library. The parts are small, and
the libraries bring their own user table, or sessions the server cannot end.
The templates are in `login/` next to this file. Copy them into `src/auth/`,
and the hash scripts into `bin/`.

Who logs in decides the rest, and it is hard to change later. So it belongs
to `/design-change`. This section says how to build each case once it is
decided.

### The same in every case

- **Sessions.** A random token of 32 bytes goes into the cookie. The
  database stores only its SHA-256, so whoever reads the table has no
  session. Logging out deletes the row. Logging in deletes the browser's old
  session first. Writing a new session also deletes the expired ones. Write
  this as `src/auth/session.ts` for the app's database, with
  `validateSessionToken(token, now)`, which `guard.ts` calls.
- **The cookie.** `session-cookie.ts`: httpOnly, SameSite=Lax, and in
  production Secure with the `__Host-` prefix. The proxy renews it with
  `renewSessionCookie`.
- **One place checks the login.** Wrap every page, Server Action and route
  handler in `guardedPage`, `guardedAction` or `guardedRoute` from
  `guard.ts`. `guard.test.ts` walks `src/app/` and fails for any that answers
  without a session. The way to log in is the only entry it leaves open.
- **CSRF.** Server Actions and SameSite=Lax cover it. No token.
- **The password hash.** Ask the developer which of the two:
  - `password-scrypt.ts`: Node's own scrypt, no dependency, no limit on the
    length. Each check takes about 128 MB of memory, so the throttle below
    matters.
  - `password-bcrypt.ts`: bcryptjs, one dependency, lighter on memory. bcrypt
    ignores everything past 72 bytes, so the policy refuses longer passwords.
    Its hash holds `$`, which Docker Compose reads as a variable, so each `$`
    is written `$$` in `secrets.prod.env`.

  Both export the same names. For a user who does not exist, compare against
  `DUMMY_PASSWORD_HASH`, so the time does not tell which names exist. Call
  `assertPasswordPolicy` wherever a password is set.

### One person

- **The account.** No users table. One hash in `PASSWORD_HASH`, in
  `secrets.prod.env`. The developer makes it with the hash script that
  matches the password file, copied into `bin/`, and puts it there.
- **Guessing.** `one-at-a-time.ts` runs the checks one after the other, and
  the login action pauses for one second after a wrong password. So guessing gets no faster
  than one try a second, and no IP address is needed.
- **The session.** It lasts long and is renewed when used, so the person
  rarely logs in. workout-tracker uses a year.

### A few shared accounts, one per role

- **The accounts.** Fixed in the code, one hash per role in
  `secrets.prod.env`. Never the password itself.
- **Guessing.** As for one person.
- **The session.** One row per device, so a single device can be logged
  out. Where the accounts serve a shift, `session-cutoff.ts` ends every
  session at the shift change, as dom does at 06:00. Its shortcut is only
  checked for Berlin, at hours 0 and 3 to 23.

### Named users

- **The accounts.** A users table with the hash, and pages where an admin
  creates users and resets passwords. The first admin comes from two
  variables in the secrets when the app starts.
- **Guessing.** `rate-limit.ts` counts failed tries per IP address and per
  IP address and user name. It reads the address with `client-ip.ts`, which
  is only correct behind the host's Caddy.
- **The session.** 30 days at most, and it ends after 24 hours unused, as in
  einsatz. A new password ends all sessions of that user. Users can log out
  their other devices.

