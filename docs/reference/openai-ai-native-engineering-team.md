# Building an AI-native engineering team (OpenAI) — summary

Source: https://cdn.openai.com/business-guides-and-resources/building-an-ai-native-engineering-team.pdf (20 pages, read 2026-11-06). Undated; its newest data point is from August 2025.
Subtitle: "How coding agents accelerate the software development lifecycle".
Audience: engineering leaders who want to start building "AI-native teams and processes". The examples use Codex.

## Core idea

Coding agents can now work for hours at a time. METR measured about 2 hours 17 minutes of work at 50% success in August 2025, and the length doubles about every seven months. So the whole lifecycle is in scope: plan, design, build, test, review, document, deploy and maintain.

The agent becomes "the first-pass implementer"; the engineer becomes "the reviewer, editor, and source of direction". Engineers spend their time on design, architecture and system-level reasoning instead of rote implementation. "True ownership of code — especially for new or ambiguous problems — still rests with engineers."

What makes this possible, in the guide's words:

- **Unified context across systems**: one model reads code, configuration and telemetry.
- **Structured tool execution**: models run compilers, test runners and scanners, so results can be checked.
- **Persistent project memory**: long context and compaction let a model follow a feature from proposal to deployment.
- **Evaluation loops**: output is tested against unit tests, latency targets or style guides.

## The pattern of every phase

Each phase has the same structure: what is slow today, how agents help, what engineers do instead, a split into **Delegate / Review / Own**, a getting-started checklist, and sometimes a customer example.

- **Delegate**: the agent does the first pass.
- **Review**: engineers check what the agent produced.
- **Own**: what stays with people.

## Plan

- Slow today: only engineers can tell whether a feature is feasible, how long it takes and which systems it touches.
- Agents: connected to the issue tracker, they read a spec, cross-reference it with the code, flag ambiguities, break the work into parts, estimate difficulty, and trace which services a feature touches.
- **Delegate:** a first pass at feasibility and architecture; dependencies, ambiguities and edge cases.
- **Review:** accuracy, completeness, and whether estimates match real constraints. Effort sizing and non-obvious risks need human judgment.
- **Own:** prioritization, long-term direction, sequencing and trade-offs.
- Checklist: find processes that need features and code aligned (scoping, tickets). Start with tagging and deduplicating issues. Later, add sub-tasks to tickets, or start an agent run when a ticket reaches a given stage.

## Design

- Slow today: boilerplate, wiring up design systems, rework when mock-ups and implementation diverge, no time to explore alternatives.
- Agents: scaffold projects, apply design tokens and style guides, turn designs into code, suggest accessibility fixes, find user flows and edge cases in the code. Several high-fidelity prototypes in hours, so customer testing can start sooner.
- **Delegate:** scaffolding, boilerplate, mock-ups into components, design tokens.
- **Review:** design conventions, quality and accessibility, integration with existing systems.
- **Own:** "the overarching design system, UX patterns, architectural decisions, and the final direction of the user experience."
- Checklist: a multi-modal agent (text and images); design tools and component libraries exposed through MCP; workflows from designs to components to implementation; typed languages such as TypeScript, so the agent knows valid props.

## Build

- Slow today: translating specs into code, wiring services, copying patterns, rediscovering "the right way" in a large codebase, context switching.
- Agents: whole features end to end in one run (data models, APIs, UI, tests, docs). They fix build errors as they come up, change dozens of files consistently, write tests alongside the code, follow conventions (error handling, telemetry, security wrappers), and produce diffs with PR messages.
- Engineers instead: clarify behaviour, edge cases and specs before implementation; design "patterns, guardrails, and conventions that guide agent-generated code"; review architectural implications; refine business logic and performance-critical paths. They focus on "correctness, coherence, maintainability, and long-term quality".
- **Delegate:** the first implementation of well-specified features: scaffolding, CRUD, wiring, refactors, tests.
- **Review:** design choices, performance, security, migration risk and domain alignment.
- **Own:** new abstractions, cross-cutting architectural changes, ambiguous requirements, long-term maintainability trade-offs. (The sentence after this breaks off in the PDF.)
- Example: Cloudwalk. Engineers, PMs, designers and operators turn specs into scripts, fraud rules or microservices "in minutes".
- Checklist: start with well-specified tasks. Have the agent plan with a planning tool over MCP, or in a `PLAN.md` committed to the codebase. Check that the commands the agent runs succeed. Iterate on `AGENTS.md` so the agent can run tests and linters for feedback.

## Test

- Slow today: tests take time and are the first thing cut under deadline pressure; they go stale and brittle.
- Agents: suggest test cases from requirements and code, including edge cases and failure modes the developer overlooked, "a second opinion". They keep tests up to date as code changes.
- Engineers instead: as agents make code cheap, "tests serve a more and more important function as a source of truth". Defining good tests "is often the first step to allowing an agent to build a feature." Engineers look at patterns in coverage and challenge the model's test cases.
- **Delegate:** the first pass at test cases and tests, ideally "in a separate session from the feature implementation".
- **Review:** that the model took no shortcuts and wrote no stubbed tests; that the agent can run the tests and knows which suites exist.
- **Own:** aligning coverage with specs and user expectations. "Adversarial thinking, creativity in mapping edge cases, and focus on intent of the tests remain critical skills."
- Checklist: write tests as a separate step, and check they fail before implementing the feature. Set coverage guidelines in `AGENTS.md`. Give the agent coverage tools to call.

## Review

- Slow today: 2–5 hours a week per developer; a choice between a deep review and a quick "good enough" pass.
- Agents: every PR gets a consistent baseline of attention. Unlike static analysis, they can run code and trace logic across files and services. But the model must be "trained specifically to identify P0 and P1-level bugs" and give "concise, high-signal feedback; overly verbose responses are ignored just as easily as noisy lint warnings."
- At OpenAI, AI review does not make PRs faster when it finds real bugs, but it prevents defects and outages. Contributors often fix issues before another engineer looks.
- **Delegate:** the first review, possibly several rounds before a teammate sees the PR.
- **Review:** engineers still review, with emphasis on architecture: composable patterns, the right conventions, whether it meets the requirements.
- **Own:** the code deployed to production, and that it works and fulfils the requirements.
- Example: Sansan uses Codex review for race conditions and database relations, "issues humans often overlook", and for hard-coding and future scalability.
- Checklist: collect gold-standard PRs reviewed by engineers (changes and comments) as an evaluation set. Use a model trained for code review: "generalized models often nitpick and provide a low signal to noise ratio." Decide how to measure review quality; they suggest reactions to PR comments. Start small, then roll out quickly.

## Document

- Slow today: docs fall behind, knowledge sits in people's heads, documentation sprints decay.
- Agents: summarize code, draw diagrams in Mermaid, update docs on request. `AGENTS.md` can tell every prompt to update docs. Run through the SDK in release workflows, for example to summarize the commits in a release.
- Engineers instead: decide how docs are organized, "add the important 'why' behind decisions", set standards and templates, review the critical and customer-facing parts.
- **Delegate:** low-risk, repetitive docs: file and module summaries, inputs and outputs, dependency lists, PR summaries.
- **Review:** overviews of core services, public API and SDK docs, runbooks, architecture pages.
- **Own:** documentation strategy and structure, templates, and anything external-facing or safety-critical (legal, regulatory, brand).
- Checklist: experiment with prompting; put documentation guidelines in `AGENTS.md`; find workflows such as releases where docs can be generated; review for quality, correctness and focus.

## Deploy & maintain

- Slow today: during an incident, engineers switch between logs, deploys and infrastructure changes by hand.
- Agents: with logging tools connected over MCP, the agent looks at errors for an endpoint, traces them through the code, and checks git history for the change that caused them.
- **Delegate:** parsing logs, finding unusual metrics, identifying suspect changes, proposing hotfixes.
- **Review:** checking the diagnosis and approving the fix; reliability, security and compliance.
- **Own:** critical decisions, "especially for novel incidents, sensitive production changes, or situations where model confidence is low."
- Example: Virgin Atlantic investigates logs and traces issues inside the IDE through Azure DevOps and Databricks MCP servers.
- Checklist: connect agents to logging and deployment systems; scope access and permissions; reusable prompts ("Investigate errors for endpoint X"); simulated incidents to test the workflow; improve from real incidents.

## Conclusion

Agents take on "the mechanical, multi-step work"; engineers "stay firmly in control of architecture, product intent, and quality". No radical overhaul is needed: "small, targeted workflows compound quickly". Start with well-scoped tasks, invest in guardrails, and widen what the agent does step by step.

## Recurring principles

1. The agent does the first pass in every phase; people review it and own the decisions.
2. People own what needs judgment: direction and trade-offs, the design system and UX patterns, architecture, ambiguous requirements, production sign-off.
3. Engineers move from writing code to setting the patterns, guardrails and conventions that guide the agent.
4. Tests become the source of truth for what the software does, and are written separately from the code, ideally in another session.
5. Agents need feedback loops: tests, linters and coverage tools they can run themselves, set up through `AGENTS.md`.
6. Review is useful only when it is high-signal: serious bugs, concise, not nitpicking.
7. Connect agents to the systems around the code (issue tracker, design tools, logs) through MCP.
8. Start small and widen the agent's responsibility as confidence grows.

## Compared with the Anthropic playbook

The Anthropic playbook is summarized in `anthropic-ai-native-sdlc-playbook.md`.

- **Lighter.** No chain of versioned files (intent, spec, plan), no evals in CI, no hooks as gates, no measures per phase. Only `PLAN.md` and `AGENTS.md` appear as files.
- **Less governance.** Ownership is described as a split between delegate, review and own, not as gates and enforced controls.
- **Tests carry more weight.** Tests written first, in a separate session, are the source of truth. The Anthropic playbook puts the same weight on evals and a verifier in a fresh context.
- **Shared:** the human owns judgment, agents need a way to check their own work, review must be high-signal, and autonomy grows step by step.

## Not read

The charts are images; only their captions were read. The METR chart is named but its data was not extracted.
