---
name: ubiquitous-language-init
description: Use this skill to bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project that has no existing domain language documentation, or to audit and refresh an existing glossary for drift. Trigger when the user wants to capture the domain vocabulary baked into an existing codebase, says "document domain terms", "create a glossary", "check if our glossary is still accurate", or is starting to use agent workflows in a project without a shared language baseline. Output is UBIQUITOUS_LANGUAGE.md in the project root, plus a drift report if the file already exists.
---

# Ubiquitous Language Init

The goal is to excavate and document the domain vocabulary already embedded in a brownfield codebase — the shared language between developers and domain experts that lives in class names, method names, test descriptions, and documentation.

The output is `UBIQUITOUS_LANGUAGE.md` in the project root: a stable vocabulary reference for the team and for agents that prevents term drift, clarifies ambiguities, and provides a controlled vocabulary for generating code, tests, and documentation.

This skill produces a **single glossary** for the whole project. If the codebase spans multiple bounded contexts, group terms by context within the single file rather than creating per-context files.

## Your role

You are the Language Archaeologist. You surface domain terms already in use — not to invent a language, but to make the implicit explicit. You infer definitions from usage in code, tests, and documentation, flag inconsistencies and ambiguities, and ask the user to confirm or correct.

## Inputs you need

This skill operates on the **current working directory**. No feature slug is required.

Before exploring, check:

1. **`UBIQUITOUS_LANGUAGE.md`** — if it already exists, read it. You are updating rather than replacing. Preserve all existing terms unless the codebase directly contradicts them.
2. **`ARCHITECTURE.md`** — if it exists, skim it. It often names key concepts using domain terms you should capture.
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

## Detect the domain language

Before exploring the codebase, determine the domain language — the language domain experts and stakeholders use when talking about the business. Look for it in: test descriptions, README files, inline comments, UI strings, and any existing documentation.

The domain language is often different from the code language. Most codebases use English identifiers even when the domain is in another language (e.g., a German insurance platform where `Vertrag` is the domain term but `Contract` is the class name). When this is the case, the glossary must map domain terms to code terms explicitly — this is its primary value.

Record the domain language once identified. All definitions and example dialogues in `UBIQUITOUS_LANGUAGE.md` must be written in the domain language, not in the code language.

## How to explore the codebase

Read the following in order, stopping when you have enough to characterize each category. Aim for breadth, not depth.

1. **Domain model files** — classes, types, structs, interfaces representing business entities. Look for: entity names, value object names, event names, aggregate roots.
2. **Service and use-case layers** — files implementing business operations. Look for: method/function names (verbs), parameter names that clarify roles, return types that reveal lifecycles.
3. **Test descriptions** — test files using natural language (`describe`, `it`, `test`, docstrings). Look for: how tests name the subject, what verbs they use, what outcomes they describe.
4. **Database schema / migrations** — table names, column names, foreign key names. Look for: entity-mapped nouns, status columns revealing state machines, junction tables revealing relationships.
5. **API layer** — route names, endpoint paths, request/response type names. Look for: boundary language showing how the system presents itself externally.
6. **Comments and documentation** — `README.md`, inline comments, docstrings. Look for: informal definitions and original intent behind terms.

## What to identify

For each term: infer its meaning, its canonical name and variations, any synonyms (same concept, different words), any ambiguities (same word, different concepts), and key relationships (ownership, lifecycle, cardinality).

Cluster terms into natural groupings (by subdomain, lifecycle, actor type). Do not force groupings — one group is fine if that's what fits.

## Present findings to the user

Before writing `UBIQUITOUS_LANGUAGE.md`, present findings in two parts.

**Part 1 — Drift findings** (only if the file already exists): List drifted terms with specific conflicting evidence (file and usage). List absent terms as a group for confirmation. Summarize active terms in one line ("23 existing terms confirmed active").

**Part 2 — New terms found**: Grouped by cluster, one-sentence definition each. List any synonyms or ambiguities.

Then ask:

> [If drift found:] I found [D] drifted and [A] absent terms — listed above. Let me know how to handle each before I write. [Always:] I found [N] new domain terms across [M] clusters. I have [K] questions about ambiguous terms — I'll go through them one at a time. Answer each, say "skip it" to document as-is, or "write it all" to proceed with my best guesses.

Ask questions **one at a time**, waiting for a response. Each question: one sentence of context grounded in a specific file and location, one concrete question about the two interpretations observed.

In non-interactive or sub-agent contexts, proceed with best-guess definitions and flag every inferred definition in the Flagged ambiguities section.

## Verify with scenarios

For each major cluster, construct one short scenario: a user action, the system's response, and the terms in play. If a scenario exposes a contradiction, resolve it before writing. These scenarios become the "Example dialogue" section — grounded in actual code flows, not invented examples.

## Write UBIQUITOUS_LANGUAGE.md

Use this format. The table structure depends on the domain language:

**When domain language ≠ English** (e.g., German, French, Dutch), use four columns. The domain term and description are in the domain language; the code term is the English identifier used in code:

```markdown
# Ubiquitous Language

## <Clustername>

| Domänenbegriff | Code-Begriff | Beschreibung | Zu vermeiden |
|----------------|--------------|--------------|--------------|
| **Domänenterm** | `CodeTerm` | Ein-Satz-Definition was es IST. | AndererBegriff, SynonymVermeiden |

## Beziehungen

- Ein **TermA** gehört zu genau einem **TermB**
- Ein **TermC** erzeugt einen oder mehrere **TermDs** wenn [Bedingung]

## Beispieldialog

> **Entwickler:** „Wenn ein **Kunde** eine **Bestellung** aufgibt, erstellen wir sofort die **Rechnung**?"
> **Fachexperte:** „Nein — eine **Rechnung** wird erst erstellt, wenn eine **Lieferung** bestätigt wurde."

## Offene Unklarheiten

- „Konto" wurde sowohl für **Kunde** als auch für **Benutzer** verwendet — kanonische Wahl: **Kunde** für bestellende Einheiten, **Benutzer** für Authentifizierungsidentitäten.
```

**When domain language = English**, the Code-Begriff column is omitted (domain term and code term are identical):

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
- **Write in the domain language.** Definitions, descriptions, example dialogues, and section headings must be in the domain language — not the code language.
- **Domain term first, code term second.** The canonical domain term is the primary key; the English code identifier is metadata.
- **Be opinionated.** Pick the best word for each concept; list the others as aliases to avoid.
- **One sentence per definition.** Define what it IS, not what it does.
- **Only domain terms.** Skip generic programming concepts unless they carry domain-specific meaning here.
- **Show relationships with cardinality.** Express ownership and lifecycle dependencies explicitly.
- **Ground the example dialogue in real flows.** Use the scenarios you constructed.
- **Flag unresolved ambiguities.** Any uncertain term goes in the Flagged ambiguities section with both interpretations and your best-guess recommendation.

If `UBIQUITOUS_LANGUAGE.md` already exists, update it:
- Add new terms in the appropriate cluster (create a new heading if needed)
- Revise drifted definitions only after user confirmation
- Mark absent terms with "(not found in current codebase — confirm this term is still in use)" rather than deleting them
- Record newly discovered ambiguities in the Flagged ambiguities section
- Do not delete any term without explicit user instruction

## Report to the user

After writing, report:

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

## Check CLAUDE.md / AGENTS.md

After writing `UBIQUITOUS_LANGUAGE.md`, check whether `CLAUDE.md` or `AGENTS.md` at the project root already contains a read instruction for `UBIQUITOUS_LANGUAGE.md`.

- If a read instruction already exists and covers `UBIQUITOUS_LANGUAGE.md`, no change needed.
- If a read instruction exists for `ARCHITECTURE.md` but not `UBIQUITOUS_LANGUAGE.md`, add [`UBIQUITOUS_LANGUAGE.md`](UBIQUITOUS_LANGUAGE.md) alongside it.
- If no read instruction exists for either file, add one. A suitable instruction:

  ```
  At the start of every conversation, read [`ARCHITECTURE.md`](ARCHITECTURE.md) for cross-cutting architectural constraints and [`UBIQUITOUS_LANGUAGE.md`](UBIQUITOUS_LANGUAGE.md) for canonical domain vocabulary.
  ```

- If neither `CLAUDE.md` nor `AGENTS.md` exists, tell the user: "No `CLAUDE.md` or `AGENTS.md` found. Create one at the project root with an instruction to read `UBIQUITOUS_LANGUAGE.md` at the start of every session, so agents always have canonical vocabulary in context."

Suggest running `architecture-init` next if `ARCHITECTURE.md` is absent — architectural constraints written without a shared vocabulary produce inconsistent terminology.

Note: once `UBIQUITOUS_LANGUAGE.md` exists, other workflow skills (discovery, design, planning, etc.) add to it incrementally. The init skill does the full-synthesis pass; subsequent additions are intentionally lightweight.
