# AI-Native SDLC Playbook (Claude Academy) — summary

Source: https://academy.claude.com/courses/ai-native-sdlc-playbook (14 lessons, ~1 hour, read 2026-11-02).
Audience: engineering, platform and security leads in organisations that already use Claude Code, especially large or regulated enterprises.
Prerequisites: comfortable with Claude Code; a Git repo and CI pipeline you are allowed to change.

## Core idea

Twelve "plays" across six stages: Plan, Design, Build, Test, Deploy, Maintain. The stages are explicitly non-linear.
Each artifact is a versioned file in Git: intent.md → spec.md → plan.md → code → evals → metrics → back to intent.md.
"Humans remain accountable for every decision that requires judgment."

Every lesson uses the same template: what changes (traditional vs AI-native), prerequisites, steps, examples, governance, measures (leading and lagging).

## Dependencies between plays

- No prerequisites: capture intent, CLAUDE.md, skills, feedback loop, hooks, plan mode.
- Subagents need CLAUDE.md (a feedback loop helps).
- Evals need CLAUDE.md and a feedback loop.
- Requirements and design need captured intent and skills.
- PR review needs evals and subagents (skills help).
- CI/CD needs PR review and hooks.
- Closing the loop on metrics needs CI/CD and captured intent.

## Stage 1 — Plan: capture intent as intent.md

- Intent comes from a person, a ticket or an incident alert.
- Brainstorm with Claude until the problem is concrete. Write it with the organisation's template (the template can be a skill). The product owner corrects it, then it is committed.
- intent.md is "human readable and machine actionable."
- Location: an `intent/` folder in the product repo. Use a separate repo only when intent spans many repos. Connectors let people who don't use Git commit from claude.ai or Cowork.
- Governance: Git history and the merge are the record of what was accepted or rejected.
- Measures: time from first conversation to committed intent.md (should fall from weeks to hours); how many intents survive; how often intent.md changes after spec.md is first committed.

## Stage 2 — Design: requirements and design in one session

- The product owner runs one session with skills for brand, security, compliance and UX, attaches intent.md, and gets spec.md.
- spec.md has numbered requirements (R1…), design, a constraints table, and flagged areas of concern, each with an owner. Example concern: two skills (UX vs brand voice) contradict each other. The agent surfaces the conflict; a human resolves it.
- Front-end: mock up in Claude Design, export to Claude Code.
- Governance: skills act as constraints. Spec, prompt and skill versions are logged in Git.
- Measures: time from intent.md to spec.md; spec.md commits after plan.md exists (requirements rework).

## Stage 3 — Build

### Plan mode as the default start
- After an engineer approves spec.md, Claude writes plan.md in plan mode (no file edits until the plan is accepted).
- The plan names files, order of work and tests. Question it and iterate until "an engineer who has never seen the conversation could implement the change from the plan alone."
- When implementation departs from the plan, update plan.md in the same commit.
- Auto mode is for routine work, once guardrails are mature.
- Legacy systems: one source of truth per artifact. Three set-ups: the repo is the truth; the legacy system is the truth and an MCP server writes back to it; or at minimum, links between the two.
- Measures: share of changes merged on the first pass; number of rework cycles.

### CLAUDE.md
- Generate with /init, then cut it down to what a new joiner needs. Check it into Git. "Keep it under a page."
- "When Claude makes a mistake twice, the correction goes into CLAUDE.md."
- Example sections: Commands, Conventions, Architecture, Things Claude gets wrong.
- Measures: repeated mistakes; time to first merged PR for a new joiner.

### Skills as institutional knowledge
- A skill is a folder with SKILL.md; the frontmatter says when it triggers. Lives in `.claude/skills/<name>/` or is shipped in a plugin.
- Use skills for institutional knowledge that must be applied consistently. Things that belong in CLAUDE.md or a prompt don't go in a skill.
- "A skill is a control, though an advisory one." Policies that must hold are backed by hooks.
- Build hooks: block edits to protected paths, run formatter or linter after edits, keep credentials out of diffs.
- Example: a PostToolUse hook (matcher `Edit|Write`) runs a policy script; exit code 2 feeds the message back to Claude. The same script also runs as a required PR check, because Edit/Write hooks miss edits made through shell commands.
- Measures: time from a policy change to the merged skill; PR findings that cite the policy (should fall toward zero).

### Parallel sessions and subagents
- Parallel session: another Claude Code instance in its own Git worktree (`claude --worktree feature-auth`).
- Subagent: a scoped helper in `.claude/agents/` with its own context window and restricted tools.
- "Two or three sessions is a sensible starting point."
- Example: a verifier subagent with only Bash and Read; it runs the app and reports, never edits.
- Measures: concurrent sessions per engineer (OpenTelemetry); changes merged per engineer per week, read together with the rework rate.

## Stage 4 — Test

### Give Claude a feedback loop
- "Always give Claude a way to verify its own work."
- Wrap all checks in one command (`make test`, `npm test`) that exits non-zero on failure. Use measurable targets.
- Bug fixes: write the failing test first and commit it, then fix without editing the test (a hook enforces this).
- UI: compare screenshots; "Two or three rounds is normal."
- CLAUDE.md lines: "Run the tests before reporting a task complete, and show the output." "If a test fails, fix the code, not the test."
- A verifier subagent does the final check in a fresh context.
- Measures: first-pass CI success; review time per PR; change failure rate.

### Continuous evals in CI
- "Evals are the AI-native equivalent of stage-gate QA."
- Collect 20–50 real tasks as evals (a prompt plus checks). Each eval pins the commit it starts from and lists the files it may change.
- Run them in CI on a schedule (daily) and whenever CLAUDE.md, skills or hooks change. Gate changes to that configuration on the pass rate.
- Every production incident becomes an eval.
- Mechanics: one git worktree per eval at its start commit, `claude -p` with `--allowedTools`, a check script grades the result. Don't use `--bare`: it skips CLAUDE.md, skills and hooks, which are what you are testing. The check fails runs that touch files outside the allowed list.
- Failure example: trimming CLAUDE.md makes Claude log full responses; the PII eval fails.
- Measures: pass rate over time; time from incident to eval; regressions caught in CI vs in production.

## Stage 5 — Deploy

### AI in the PR review loop
- Managed Code Review, or claude-code-action in your own CI (Bedrock, Vertex AI or Microsoft Foundry possible).
- REVIEW.md at the repo root defines three passes: bugs; security; compliance with spec.md, plan.md and design principles. It defines "Important" vs "Nit" and says "Report at most five nits per review."
- Findings never approve or block on their own; a code owner must still approve. Separation of duties: the agent that wrote the code cannot approve it.
- `@claude` on a review comment makes Claude fix it and push; `@claude review` asks for a new review. A slash command works through open comments and failing checks until "the PR is green and waiting only on code owner approval."
- Mistakes seen twice go into CLAUDE.md. Tune the review monthly.
- Measures: time to first review ("should fall to minutes"); defects caught before merge vs in production.

### Hooks as approval gates
- A hook can allow, ask or block. Gates: change-management sign-off, release authorisation, protected paths.
- Team hooks live in `.claude/settings.json`; non-negotiable ones in managed settings (MDM or admin console).
- Example release gate: dev is allowed; staging is allowed from main in the pipeline, otherwise ask; production needs an approved change ticket (`CHG-<n>`) for the same version, otherwise deny and point to the ticket process. Known weakness: an engineer could set `GITHUB_REF` by hand. Non-interactive runs turn "ask" into "deny".
- Managed settings lock things down: deny/allow permission rules, disable bypass mode, only managed permission rules/hooks/MCP servers, sandbox required with a network allowlist and credential paths denied, strict known marketplaces, a required minimum Claude Code version.
- Measures: wait time per gate (OpenTelemetry); gate violations that reach production.

### CI/CD integration and deployment
- Introduce in order:
  1. Read-only judgment steps with `claude -p`: triage a build, summarise a flaky test, draft a changelog.
  2. Write steps behind gates: open PRs only, never push to main.
  3. Sandboxed agent jobs with short-lived, scoped tokens and no production credentials.
  4. Deployment through MCP tools: release, status (waits five minutes after the last release, returns 5xx rate), rollback.
- Autonomy is tiered per environment. Production fails closed. "The agent may act up to the production gate and cannot pass it."
- Rollback "should be the most rehearsed path." Example rule in the prompt: "If the 5xx rate on any endpoint is over 1%, roll back."
- Measures: share of pipeline failures triaged without paging anyone; DORA metrics.

## Stage 6 — Maintain: closing the loop on metrics

- Runs headless. Between stages sits a confidence gate: either deterministic, or an adversarial reviewing agent.
- Control band = mean and standard deviation (σ) of the last 30 days of hourly readings.
  - Above 1σ: log. Above 2σ: diagnose, read-only. Above 3σ: propose a fix (a PR or a pre-approved runbook).
  - Under a normal distribution: ~1 in 6 readings above 1σ, 1 in 44 above 2σ, 1 in 740 above 3σ. With 720 readings a month that is ~4 a day, ~16 a month and ~1 a month.
  - Western Electric drift rules (1956): four of the last five above 1σ, or eight in a row above the mean, count as 2σ.
- Worked example: a release sets a cache TTL from 60 to 0; 3σ breach eight minutes later; rollback runbook; a new intent.md is written; a new eval is added so it can't recur.
- Claude Tag (Slack, public beta): Claude is a channel member with its own identity; a lessons file collects post-mortems.
- Measures: time from breach to intent.md; share of findings that become fixes; repeat incidents.

## Recurring principles

1. Every stage produces a versioned file in Git; Git is the audit trail.
2. Humans own judgment: product owner corrects intent, engineer approves spec and plan, code owner approves merge, release manager owns production.
3. Advisory controls (CLAUDE.md, skills, REVIEW.md) are backed by enforced ones (hooks, managed settings, required CI checks) wherever a rule must hold.
4. Claude must always be able to verify its own work; checking is done in a fresh context by an agent that didn't write the code.
5. Mistakes become durable: twice → CLAUDE.md; incident → eval; metric breach → intent.md.
6. Configuration of the agent (CLAUDE.md, skills, hooks) is code and is regression-tested with evals.
7. Autonomy grows step by step: read-only first, then gated writes, tiered by environment.
8. Every play has leading and lagging measures.

## Not read

The single-page version at https://claude.com/blog/the-ai-native-sdlc-playbook and other linked docs and blog posts were not fetched. The dependency graph was read from its image alt text only.
