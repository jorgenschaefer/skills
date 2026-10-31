---
effort: M
utility: L
---

# Walks are slow: no run skill, no browser setup

Every `walk-user-journeys` subagent sets up a browser on its own, and this is
the slowest part of a run. In the workout-tracker run of 2026-10-31, walking
the journeys took about 250 of the 460 minutes of chunks 02-15, which is 54%
of the wall time. The code reviewer runs beside the walker and is done after
2-3 minutes, so the walker sets the pace of every review round.

What each walker does:

- It installs Playwright into `/tmp` with `npm i`, each time with a different
  version: `playwright@1.5`, `@1.56`, `@1.57`, `@1.64.1`, `@latest`,
  `playwright-core@1.58`. One install took 94 seconds (chunks 14 and 17).
- It writes its own helper (`lib.mjs`, `lib.js`, `cdp.mjs`) and then drives
  the browser with node scripts run through Bash, with fixed waits
  (`waitForTimeout`). A walk takes 20-86 Bash calls and 6-16 minutes.

`run/session.sh` allows `mcp__playwright` and its comment says "Playwright is
kept, for testing in the browser". But no MCP server is configured in the
sessions (`mcp_servers: []` in the init event), so the walkers never had it.
The project has no Playwright dependency and no `run` skill either.

The user, on 2026-10-31: for speed, the pipeline should run
`/run-skill-generator` where the project has no run skill yet - first "the
walker should create the run skill", then "maybe run.sh can run it
directly". `implement-change` may not benefit from a run skill at all.

`/run-skill-generator` is built into Claude Code (2.1.316), with
`disableModelInvocation`, so no session can call it with the `Skill` tool -
the walker cannot. A `claude -p` session whose prompt is
`/run-skill-generator` runs it (tried on 2026-10-31 in a scratch
repository). What it does, from its bundled files:

- it writes `.claude/skills/run-<unit-name>/SKILL.md`, while
  `implement-change` and the walker look for `.claude/skills/run/`;
- for a web app it drives the browser with `chromium-cli`, which is not
  installed here; without it, it writes a Playwright driver, once, into the
  committed skill;
- in a repository with several apps and no clear match, it asks the user
  which one.

Claude Code also has a built-in model-invocable skill that launches the
project's app: it uses a project skill that covers it, and otherwise
recommends `/run-skill-generator`.

Open: when in a run, since a new project has nothing to run before a build
makes it.

Today `implement-change/SKILL.md` ("Before you write anything") has the
rule: "Find the project's way of running the software - a `run` skill,
`CLAUDE.md`, the README ... Where there is none, build one, write it up as
the project's run skill". In the workout-tracker run it did not fire. The
chunk 01 builder read `../weight-tracker/.claude/skills/run/SKILL.md`, but
wrote none, probably because the project's `CLAUDE.md` says how to start
the app, which the rule counts as a way of running it. The builder itself
uses the way of running only to hand it to the reviewers, and to check the
*(judged)* steps.

Others start the software too, and would reuse the skill: `accept-change`,
`debug`, and the final review's walker.

What constrains the walker, if it writes the skill itself rather than the
generator: it never reads the code, only how to start the software
(`walk-user-journeys/SKILL.md`, "Start the software"), so it can write a run
skill only from what the docs say; where they are not enough, it says so
and stops, as today. It is a subagent and commits nothing, so the builder
or the final review commits the skill.

Walkers also stop servers they did not start: `pkill -f next-server`. The
auto mode classifier refused this twice as "Interfere With Workloads" (see the
`.refused` log of that run).

Evidence: `.git/run-logs/*-20261031-*.jsonl` in `~/Projects/workout-tracker`.
