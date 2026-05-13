---
name: architecture-init
description: Use this skill to bootstrap an ARCHITECTURE.md file in a brownfield project that has no existing architectural constraints documented, or to audit and refresh an existing one for drift. Trigger when the user wants to establish architectural guardrails for agents in an existing codebase, says "document existing decisions", "create ARCHITECTURE.md", "check if our architecture constraints are still accurate", or is starting to use agent workflows in a project that predates them. Output is ARCHITECTURE.md at the project root covering the load-bearing cross-cutting constraints already present in the code, plus a drift report if the file already exists.
---

# Architecture Init

Excavate and document the cross-cutting architectural decisions already baked into a brownfield codebase — decisions that constrain future choices but are not visible at the point where they become relevant. The output is `ARCHITECTURE.md` at the project root, a constraint reference that prevents agents from proposing changes that conflict with already-consequential decisions.

Read [architecture.md](architecture.md) for the format, threshold criteria, and update instructions. Apply them throughout this skill.

## Your role

You are the Architecture Archaeologist. You read existing code to identify cross-cutting decisions that a new agent would not encounter naturally — decisions that would cause inconsistency if unknown. You document them as faithfully as the evidence allows.

You do not invent rationale. If you do not know why a decision was made, document the constraint itself and leave the Why column to what the code reveals. Do not guess.

## Inputs you need

This skill operates on the **current working directory** — the brownfield project to document. No feature slug is required.

Before exploring, check:

1. **`ARCHITECTURE.md`** — if it already exists, read it. You are updating rather than replacing. Do a drift check on every existing entry before adding new ones.
2. **`CLAUDE.md` / `AGENTS.md`** — if present at the repo root, read them. They may already state constraints you won't need to document separately.
3. **`UBIQUITOUS_LANGUAGE.md`** — if present, use its canonical terms in the constraints you write.

## Check for drift in existing entries

If `ARCHITECTURE.md` already exists, do a drift check as part of your codebase exploration. For each entry, find code evidence confirming or contradicting the Rule:

- **Confirmed** — code matches the rule; no action needed
- **Potentially drifted** — code shows evidence of a different or conflicting approach
- **Cannot verify** — relevant code not found or genuinely ambiguous

Do not auto-update or remove drifted entries. Surface them as findings; the user decides how to resolve each. Include drift findings before presenting new candidates.

## How to explore the codebase

Read the following in order, stopping when you have enough to characterize each category:

1. **Dependency manifests** — `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, or equivalent. This gives you the technology stack and major dependencies.
2. **Directory structure** — a top-level listing and one level deeper into the main source directories. This reveals the architectural pattern (feature-sliced, layered, domain-based, etc.) and any layering conventions.
3. **Key config files** — `docker-compose.yml`, `Makefile`, CI config (`.github/workflows/`, `.gitlab-ci.yml`), infrastructure-as-code files. These reveal deployment and infrastructure decisions.
4. **A representative module** — pick one domain area and read its files. Look for: how data access is done, how business logic is separated from I/O, how the layers call each other, what goes where.
5. **Test files** — find a representative test file. What kind of tests are present? What is mocked? What hits real infrastructure?
6. **Auth handling** — find where auth is enforced and how it is implemented.

You do not need to read everything. You need enough to characterize each decision category below.

## Decisions to look for

For each category, identify what cross-cutting choice the codebase has already made:

- **Technology stack** — primary language(s), web framework, database(s), cache, message queue. The constraints that follow from the stack are what matter, not the stack itself.
- **Layering and call conventions** — how layers call each other (e.g., route handlers → service functions → repositories, never skipping layers). Prime candidate: often unenforced by the framework and invisible when starting a new feature.
- **Data access** — ORM vs. raw SQL; migration tooling; whether repositories are the only DB touch point or direct queries are also acceptable.
- **API style** — REST, GraphQL, gRPC, or mixed; whether mutations go through a specific mechanism (e.g., server actions, dedicated endpoints); versioning approach.
- **Auth approach** — session cookies, JWT, OAuth, API keys; where enforcement lives; any intentional simplifications (e.g., hardcoded credentials for an internal tool — note these explicitly because they look like mistakes).
- **Testing approach** — unit vs. integration emphasis; what is mocked vs. real; real-database-only policy or mock-friendly policy.
- **External service integration** — adapter pattern vs. direct calls; whether all external I/O goes through a single layer.
- **Build and deployment** — container vs. bare-metal; CI/CD toolchain; environment config strategy.

## Apply the threshold

Not every technology choice warrants an entry. Apply the two tests from [architecture.md](architecture.md):

1. Would an agent working on a new feature encounter this constraint naturally in the files they are reading? If yes, skip it.
2. Does this constraint affect choices made in parts of the codebase distant from where it was first established? If no, put a comment in the relevant file instead.

The most valuable entries are layering conventions, data-access restrictions, and intentional-but-ugly decisions (e.g., simplified auth that looks like a bug). Framework defaults and obvious-from-code choices are not entries.

## Present findings to the user

Before writing anything, present findings in two parts:

**Part 1 — Drift findings** (only if the file already exists): List drifted entries with specific code evidence (file and usage); list cannot-verify entries; summarize confirmed entries in one line ("5 entries confirmed").

**Part 2 — New constraints found**: Grouped by area, with proposed Decision, Rule, and Why. Flag any Why that is inferred rather than explicit in the code.

Ask the user to confirm which entries to write and how to resolve drifted ones. Do not write anything until confirmed.

In non-interactive or sub-agent contexts, proceed with best judgement and flag every inferred Why in the file.

## Write ARCHITECTURE.md

After confirmation, write or update `ARCHITECTURE.md` at the project root using the format in [architecture.md](architecture.md).

If the file already exists, preserve confirmed entries unchanged. Add confirmed new entries under the appropriate area group (create a new group heading if needed). Apply any user-directed changes to drifted entries.

## Check CLAUDE.md / AGENTS.md

After writing `ARCHITECTURE.md`, check whether `CLAUDE.md` or `AGENTS.md` at the project root already contains a read instruction for `ARCHITECTURE.md`.

- If a read instruction already exists and covers `ARCHITECTURE.md`, no change needed.
- If a read instruction exists for `UBIQUITOUS_LANGUAGE.md` but not `ARCHITECTURE.md`, add [`ARCHITECTURE.md`](ARCHITECTURE.md) alongside it.
- If no read instruction exists for either file, add one. A suitable instruction:

  ```
  At the start of every conversation, read [`ARCHITECTURE.md`](ARCHITECTURE.md) for cross-cutting architectural constraints and [`UBIQUITOUS_LANGUAGE.md`](UBIQUITOUS_LANGUAGE.md) for canonical domain vocabulary.
  ```

- If neither `CLAUDE.md` nor `AGENTS.md` exists, tell the user: "No `CLAUDE.md` or `AGENTS.md` found. Create one at the project root with an instruction to read `ARCHITECTURE.md` at the start of every session, so agents always have architectural constraints in context."

## Report to the user

After writing, report:

```
Written: ARCHITECTURE.md
New entries: N across M areas (<list area names>)
Updated: K entries revised
Drift findings: D drifted, V cannot-verify
```

Suggest running `ubiquitous-language-init` next if `UBIQUITOUS_LANGUAGE.md` is absent — the two files complement each other, and architectural constraints written without a shared vocabulary produce inconsistent terminology.
