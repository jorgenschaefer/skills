---
effort: M
utility: L
---

# The walker builds its browser setup from nothing

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

Walkers also stop servers they did not start: `pkill -f next-server`. The
auto mode classifier refused this twice as "Interfere With Workloads" (see the
`.refused` log of that run).

Evidence: `.git/run-logs/*-20261031-*.jsonl` in `~/Projects/workout-tracker`.
