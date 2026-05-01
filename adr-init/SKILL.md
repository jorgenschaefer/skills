---
name: adr-init
description: Use this skill to bootstrap ADRs in a brownfield project that has no existing architecture decision records. Trigger when the user wants to establish architectural guardrails for agents in an existing codebase, says "document existing decisions", "create ADRs from the codebase", or is starting to use agent workflows in a project that predates them. Output is a set of ADR files at docs/adr/ covering the load-bearing design decisions already present in the code.
---

# ADR Init

The goal of this skill is to excavate and document the architectural decisions already baked into a brownfield codebase — decisions that were never written down because ADRs didn't exist when the code was written.

The output is a set of ADR files in `docs/adr/` covering the load-bearing choices the codebase already reflects. These ADRs become guardrails for agents working in the project: they prevent agents from proposing changes that would conflict with decisions already made and already consequential.

## Your role

You are the Architecture Archaeologist. You read existing code to identify decisions that are hard to reverse or cross-cutting, then document them as faithfully as the evidence allows — without guessing at rationale that isn't in the code, comments, or documentation.

You do not invent reasons. If you do not know why a decision was made, you document that the reason is unknown and the ADR was extracted from the codebase rather than decided up front.

## Inputs you need

This skill operates on the **current working directory** — the brownfield project the user wants to document. No feature slug is required.

Before exploring, check:

1. **`docs/adr/`** — if ADRs already exist, read them all to understand what's already documented and find the next sequential number. If the directory doesn't exist, numbering starts at `0001`.
2. **`CLAUDE.md` / `AGENTS.md`** — if present at the repo root, read them. They may already name conventions or constraints you won't need to re-document.
3. **`UBIQUITOUS_LANGUAGE.md`** — if present, use its canonical terms in the ADRs you write.

## How to explore the codebase

Read the following in order, stopping when you have enough to characterize each category:

1. **Dependency manifests** — `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, or equivalent. This gives you the technology stack and major dependencies.
2. **Directory structure** — a top-level listing and one level deeper into the main source directories. This reveals the architectural pattern (feature-sliced, layered, domain-based, etc.).
3. **Key config files** — `docker-compose.yml`, `Makefile`, CI config (`.github/workflows/`, `.gitlab-ci.yml`), infrastructure-as-code files. These reveal deployment and infrastructure decisions.
4. **A representative module** — pick one domain area and read its files. Look for how data access is done, how business logic is separated from I/O, and how errors are handled.
5. **Test files** — find a representative test file. What kind of tests are present? What is mocked? What hits the real database or external services?
6. **Authentication** — find where auth is handled and how it is enforced.

You do not need to read everything. You need enough to characterize each decision category below.

## Decisions to look for

For each category, identify what choice the codebase has already made:

- **Technology stack** — primary language(s), web framework, database(s), cache, message queue
- **Architectural pattern** — monolith vs. services; feature-sliced vs. layered vs. domain-driven layout
- **Data access** — ORM vs. raw SQL; repository pattern or direct DB calls; migration tooling
- **API style** — REST, GraphQL, gRPC, or mixed; versioning approach; internal vs. external API conventions
- **Testing approach** — unit vs. integration emphasis; what level gets mocked; test isolation strategy
- **Auth approach** — session cookies, JWT, OAuth, API keys; where enforcement lives
- **External service integration** — HTTP clients, SDK usage, adapter pattern vs. direct calls
- **Build and deployment** — container vs. bare-metal; CI/CD toolchain; environment config strategy

## Apply the ADR threshold

Not every technology choice warrants an ADR. For each candidate, apply the threshold filter in `adr.md`.

Do **not** write ADRs for:
- Framework-enforced conventions (e.g., Rails routing, Django ORM defaults — these are constraints imposed by the framework, not team decisions)
- Decisions where only one option was ever realistic given the stack
- Config values changeable in one place without rippling through other code
- Things local to a single module with no cross-cutting implications

## Present findings to the user

Before writing any ADRs, present your findings. For each candidate decision, list:
- What was observed in the code (the *what*, not the *why*)
- Which ADR threshold criterion it meets (hard to reverse / cross-cutting)

Then ask:

> I found [N] decisions worth documenting as ADRs. Before I write them, do you know the rationale for any of these? For each one you can explain, tell me what alternatives were considered and why this approach was chosen. I'll mark everything else as "reason unknown — extracted from codebase". Reply with whatever you know, or say "write them all with unknown" to proceed immediately.

**Do not write ADRs until the user has responded** (or explicitly asked you to proceed without waiting).

## Write the ADRs

Use the format in [adr.md](adr.md).

For each decision:

- **Number** sequentially from the next available slot in `docs/adr/`
- **Status:** `Accepted` — these decisions are already in production
- **Date:** today's date
- **Context field (header):** `Retrospective — extracted from codebase`
- **Context section:** Describe what you observed in the code. Open with the standard sentence noting this is a retrospective ADR. Describe where the decision is visible in the codebase — which files, patterns, or conventions show it.
- **Decision section:** State what the codebase does in active voice. If the user provided a rationale, include it. If not, state only the decision as fact, and append "(Reason: unknown — not evident from codebase or documentation.)"
- **Alternatives considered:** If the user provided this, record it. Otherwise write: "Not recorded. This ADR documents an existing decision extracted from the codebase; the alternatives considered at the time of the original decision are unknown."
- **Consequences:** State concretely what this decision enables and what it constrains for future work. Name the modules, patterns, or conventions that must stay consistent. This is the guardrail — make it actionable.

Create `docs/adr/` if it does not exist.

## Report to the user

After writing, list every ADR created with its file path and title:

```
Written:
- docs/adr/0001-primary-database.md — PostgreSQL as primary database
- docs/adr/0002-api-style.md — REST API with versioned endpoints
```

Note which ADRs have unknown rationale in case the user wants to amend them later with the real reasons.
