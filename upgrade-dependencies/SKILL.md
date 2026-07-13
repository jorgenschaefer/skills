---
name: upgrade-dependencies
description: Use when a project's npm dependencies need upgrading safely, without breakage slipping in unattributed. Triggers on "/upgrade-dependencies", "update the dependencies", "bump our packages".
disable-model-invocation: true
---

# Upgrade Dependencies

You are a senior developer upgrading this project's dependencies. Work in three passes – baseline,
easy updates, then remaining updates one at a time – and keep the project green after every pass so
any breakage is traceable to the single change that caused it. Commit each pass separately.

Before making any commits, create a dedicated branch (e.g. `upgrade-dependencies`) if you are on the
default branch – never commit these upgrades straight to `main`.

The three checks referenced throughout are the project's **tests**, **type check** (`tsc` /
`tsc --noEmit`), and **lint**. Find the actual commands in `package.json` scripts and use those; if
any is missing, say so and run the ones that exist.

## 1. Baseline

Make sure dependencies are installed first (`npm ci`), then run all three checks before touching
anything. Everything must be green.

If something is already red, stop and report it. A pre-existing failure is not yours to fix here,
but you must not start on top of it – otherwise you can't tell an upgrade regression from noise. Note
any failure explicitly so it isn't later mistaken for upgrade damage.

## 2. Easy updates (`npm update`)

Run `npm update` to pull in everything allowed by the existing semver ranges in `package.json`
(minor and patch bumps). Then run all three checks again.

- Still green: commit this pass on its own.
- Red: the culprit is within this batch. Read the failure, fix it if it's a small adjustment, or
  narrow down which package caused it and decide whether to hold it back. Get back to green before
  committing.

## 3. Remaining updates (majors and out-of-range bumps)

`npm update` won't cross a major version or move a pinned range. Find what's left with
`npm outdated` (note: it exits non-zero whenever anything is outdated – that's normal, not a
failure). Handle these **one package at a time** – never batch majors, since a red result must
point at exactly one upgrade.

For each package, in order (leaf/dev dependencies first, framework/core last):

1. Read its changelog or migration notes for breaking changes – a major bump usually means the API
   changed, not just the version number.
2. Bump it (`npm install pkg@latest`, or edit the range and `npm install`).
3. Apply any migration the changelog calls for.
4. Run all three checks. Green: commit this single upgrade. Red and not a quick fix: revert this one
   package and move on, noting it as needing manual follow-up. Revert cleanly so the lockfile stays
   consistent: `git checkout package.json package-lock.json && npm install`.

If the bump fails to install with a peer-dependency conflict (npm's `ERESOLVE`), read which peer is
unsatisfied and upgrade the conflicting packages together as one coherent step (still committed as a
single logical upgrade). **Do not** reach for `--force` or `--legacy-peer-deps` to push past it –
those mask the conflict instead of resolving it, and leave the tree in a state that breaks later.

If a major bump implies real code changes or a behavior shift rather than a mechanical migration,
stop and surface it rather than guessing at the intended behavior.

## Node version alignment

`@types/node` should match the Node version the project actually runs on, and every place that
declares that version should agree – on the **current active LTS** unless the project has a stated
reason to pin older.

Check and reconcile:
- `.nvmrc`
- the `engines.node` field in `package.json`
- the base image in any `Dockerfile` (and CI workflow node-version, if present)
- the `@types/node` major version

If these disagree (e.g. `.nvmrc` says 20 but the Dockerfile is on `node:18`), that's a finding –
point it out and propose aligning them all on one current LTS (verify which release that currently
is rather than assuming from memory) rather than silently picking one.

As part of pass 3, bump `@types/node` to match the Node major the project actually runs on **today**
– not a higher LTS you have only proposed moving to. Types ahead of the runtime let `tsc` pass code
that fails at runtime, which defeats the point of the checks. `@types/node` moves up only in lockstep
with an approved runtime bump.

## Output

Report what moved: packages upgraded (with from → to versions), grouped by pass; anything held back
and why; and the Node-version reconciliation. Confirm the final state of all three checks, and
report the `npm audit` status (before vs after) so any remaining known vulnerabilities are visible –
without silently running `npm audit fix`, which can itself pull in breaking changes. If you made
commits, list them. Leave anything requiring a judgment call about behavior for the user to
decide – don't merge breaking upgrades on assumption.
