---
name: ubiquitous-language-init
description: Use this skill to bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project that has no existing domain language documentation, or to audit and refresh an existing glossary for drift. Trigger when the user wants to capture the domain vocabulary baked into an existing codebase, says "document domain terms", "create a glossary", "check if our glossary is still accurate", or is starting to use agent workflows in a project without a shared language baseline. Output is UBIQUITOUS_LANGUAGE.md in the project root, plus a drift report if the file already exists.
---

# Ubiquitous Language Init

The goal of this skill is to excavate and document the domain vocabulary already embedded in a brownfield codebase — the shared language between developers and domain experts that was never written down but lives in class names, method names, test descriptions, and documentation.

The output is `UBIQUITOUS_LANGUAGE.md` in the project root. This file becomes a stable vocabulary reference for the whole team and for agents working in the project: it prevents term drift, clarifies ambiguities, and gives agents a controlled vocabulary to use when generating code, tests, and documentation.

This skill produces a **single glossary** for the whole project. If the codebase spans multiple bounded contexts, group terms by context within the single file rather than creating per-context files. A unified document is easier to reason over, easier to update, and prevents agents from working with conflicting local vocabularies.

## Your role

You are the Language Archaeologist. You read existing code to surface domain terms that are already in use — not to invent a language, but to make the implicit language explicit. You identify the terms people are already using, flag where those uses are inconsistent or ambiguous, and propose a canonical vocabulary grounded in what you actually found.

You do not invent definitions. You infer them from usage in code, tests, and documentation, then ask the user to confirm or correct.

## Inputs you need

This skill operates on the **current working directory** — the brownfield project to document. No feature slug is required.

Before exploring, check:

1. **`UBIQUITOUS_LANGUAGE.md`** — if it already exists, read it. You are updating rather than replacing. Preserve all existing terms unless the codebase directly contradicts them.
2. **`docs/adr/`** — if ADRs exist, skim them. They often name key decisions using domain terms you should capture.
3. **`CLAUDE.md` / `AGENTS.md`** — if present at the root, read them. They may already name terms or constraints you won't need to document separately.

## Check for drift in existing terms

If `UBIQUITOUS_LANGUAGE.md` already exists, do a drift check as part of your codebase exploration.

For each term in the existing glossary, search the codebase for that term and classify it as:

- **Active** — term appears in code identifiers, test descriptions, or documentation, and usage matches the documented definition
- **Drifted** — term appears but usage conflicts with the documented definition (e.g., the term is now used for a different concept, or a documented alias-to-avoid has become the dominant usage)
- **Absent** — term does not appear anywhere in the codebase as a code identifier, test description, or comment

For **absent** terms: do not delete them. A term may be part of the domain language but expressed only in prose documentation or in conversations with domain experts — absence from code identifiers doesn't make it wrong. Flag it for user confirmation.

For **drifted** terms: record the conflicting evidence (specific file and usage) and include it in your presentation. Do not rewrite drifted definitions without user confirmation.

Include drift findings alongside new term findings before writing anything.

## How to explore the codebase

Read the following in order, stopping when you have enough to characterize each category. Your goal is to find terms in actual use, not to read every file.

1. **Domain model files** — classes, types, structs, interfaces that represent business entities. Look for: entity names, value object names, event names, aggregate roots. The names of these things are your primary vocabulary source.
2. **Service and use-case layers** — files that implement business operations. Look for: method/function names that describe what the system *does* (verbs), parameter names that clarify roles, return types that reveal lifecycles.
3. **Test descriptions** — test files often use natural language: `describe`, `it`, `test`, docstrings. These are the closest thing to domain-expert speech in the codebase. Look for: how the tests name the subject under test, what verbs they use, what outcomes they describe.
4. **Database schema / migrations** — table names, column names, and foreign key names reveal how the domain is stored. Look for: nouns that correspond to entities, status columns that reveal state machines, junction tables that reveal relationships.
5. **API layer** — route names, endpoint paths, request/response type names. These reveal the boundary language — how the system presents itself to the outside world.
6. **Comments and documentation** — `README.md`, inline comments, docstrings. These often contain informal definitions and sometimes the original intent behind a term.

You do not need to read everything. Aim for breadth: enough files to see the full vocabulary, not depth into every implementation.

## What to identify

For each term you find, determine:

- **What it means** in this codebase (infer from usage context)
- **What it is called** (the canonical name as used in code vs. variations)
- **Where synonyms appear** — different words used for the same concept
- **Where ambiguities appear** — the same word used for different concepts in different places
- **What relationships exist** — ownership, lifecycle dependencies, cardinality

Cluster terms into natural groupings as you find them (by subdomain, by lifecycle, by actor type). Do not force groupings — if everything belongs together, one group is fine.

## Present findings to the user

Before writing `UBIQUITOUS_LANGUAGE.md`, present your findings in two parts.

**Part 1 — Drift findings** (only if the file already exists): For each term, report its classification. List drifted terms with the specific conflicting evidence (file and usage). List absent terms as a group for the user to confirm or remove. Skip active terms from the report — a single summary line is enough ("23 existing terms confirmed active").

**Part 2 — New terms found**: Grouped by cluster, with a one-sentence definition for each. Also list any synonyms or ambiguities found among new terms.

Then ask:

> [If drift found:] I found [D] drifted terms and [A] absent terms — listed above. Let me know how to handle each before I write. [Always:] I also found [N] new domain terms across [M] clusters. Before I write the glossary, I have [K] questions about ambiguous terms. I'll go through them one at a time — you can answer, or say "skip it" to have me document the ambiguity as-is, or "write it all" to proceed immediately with my best guesses.

Then ask your questions **one at a time**, waiting for a response between each. Each question should be:
- Grounded in a specific code location (file and approximate line or method name)
- Concrete about the two interpretations you observed
- Short — one sentence of context, one question

If the user says "skip" or "write it all", proceed immediately without further questions.

In non-interactive or sub-agent contexts, proceed with best-guess definitions and flag every inferred definition in the Flagged ambiguities section.

## Verify with scenarios

For each major cluster of terms, construct one short scenario that exercises the key boundaries: a user action, the system's response, and which terms are in play. Use the scenario to test whether your proposed definitions actually hold. If a scenario exposes a contradiction, resolve it before writing.

These scenarios become the "Example dialogue" section in the output — a short conversation between a developer and a domain expert that demonstrates how the terms interact. Ground them in actual code flows you observed, not invented examples.

## Write UBIQUITOUS_LANGUAGE.md

Use this format:

```markdown
# Ubiquitous Language

## <Cluster name>

| Term | Definition | Aliases to avoid |
|------|------------|-----------------|
| **TermName** | One-sentence definition of what it IS. | OtherWord, SynonymToAvoid |

## Relationships

- A **TermA** belongs to exactly one **TermB**
- A **TermC** produces one or more **TermDs** when [condition]

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — canonical choice: **Customer** for order-placing entities, **User** for authentication identities.
```

Rules for writing:
- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **One sentence per definition.** Define what it IS, not what it does.
- **Only domain terms.** Skip generic programming concepts (array, endpoint, middleware) unless they carry domain-specific meaning in this codebase.
- **Show relationships with cardinality.** Express ownership and lifecycle dependencies explicitly.
- **Ground the example dialogue in real flows.** Use the scenarios you constructed; do not invent examples that don't correspond to actual code paths.
- **Flag unresolved ambiguities.** Any term you weren't certain about goes in the Flagged ambiguities section, with both interpretations and your best-guess recommendation.

If `UBIQUITOUS_LANGUAGE.md` already exists, update it:
- Add new terms in the appropriate cluster (create a new cluster heading if needed)
- Revise drifted definitions only after the user confirms the change is intentional
- Mark absent terms with a trailing note "(not found in current codebase — confirm this term is still in use)" rather than deleting them
- Mark newly discovered ambiguities in the Flagged ambiguities section
- Do not delete any term without explicit user instruction

## Report to the user

After writing, report in two sections:

**Glossary changes:**
```
Written: UBIQUITOUS_LANGUAGE.md
New terms: 12 across 3 clusters (Order lifecycle, People, Fulfillment)
Updated: 2 existing definitions revised based on code evidence
Flagged: 1 ambiguity left unresolved (see "account" in Flagged ambiguities)
```

**Drift findings** (only if the file already existed):
```
Active: 23 terms confirmed in codebase
Drifted: 1 — "Invoice" (definition says "sent after delivery"; code now generates invoices at order placement — see src/billing/invoice.ts:42)
Absent: 2 — "Fulfillment", "Shipment" (not found as code identifiers; marked for user confirmation)
```
Drifted definitions are only updated in the file if the user confirmed the change. Absent terms are marked in the file but not deleted.

Suggest running `adr-init` next if `docs/adr/` is empty — the two tools complement each other, and ADRs can reference the canonical terms now established.

Note: once `UBIQUITOUS_LANGUAGE.md` exists, other workflow skills (discovery, design, planning, etc.) add to it incrementally as they encounter new domain terms. The init skill does the full-synthesis pass; subsequent per-skill additions are intentionally lightweight.
