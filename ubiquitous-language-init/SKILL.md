---
name: ubiquitous-language-init
description: Use this skill to bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project that has no existing domain language documentation, or to audit and refresh an existing glossary for drift. Trigger when the user wants to capture the domain vocabulary baked into an existing codebase, says "document domain terms", "create a glossary", "check if our glossary is still accurate", or is starting to use agent workflows in a project without a shared language baseline. Output is UBIQUITOUS_LANGUAGE.md in the project root, plus a drift report if the file already exists.
---

# Ubiquitous Language Init

The goal is to excavate and document the domain vocabulary already embedded in a brownfield codebase - the shared language between developers and domain experts that lives in class names, method names, test descriptions, and documentation.

The output is `UBIQUITOUS_LANGUAGE.md` in the project root: a stable vocabulary reference for the team and for agents. It prevents term drift, clarifies ambiguities, and provides a controlled vocabulary for generating code, tests, and documentation.

This skill produces a **single glossary** for the whole project. Even if the codebase spans multiple bounded contexts, keep everything in one file - one flat list in the `Terminology` section.

## Your role

You are the Language Archaeologist. You surface domain terms already in use, you don't invent a language. You infer definitions from usage in code, tests, and documentation, flag inconsistencies and ambiguities, and ask the user to confirm or correct.

## Pre-check existing files

This skill operates on the **current working directory**. Before exploring, read:

1. **`UBIQUITOUS_LANGUAGE.md`** - if it already exists, read it. You are updating, not replacing. Preserve all existing terms unless the codebase directly contradicts them.
2. **`CLAUDE.md` / `AGENTS.md`** - if present at the root, read them. They may already name terms or constraints you won't need to document separately.
3. **`UBIQUITOUS_LANGUAGE_FORMAT.md`** in this skill directory - the format specification you will follow when writing the glossary.

## Parallelize the exploration

Spawn up to 3 `Explore` subagents in parallel for the six layers below. Suggested split:

- **Agent A:** domain model files + database schema/migrations.
- **Agent B:** service/use-case layers + API routes/handlers.
- **Agent C:** tests + comments/documentation.

Each agent returns the candidate terms it found, with file-and-usage evidence. Synthesize the three lists in the main loop before presenting findings.

For the drift check (only when `UBIQUITOUS_LANGUAGE.md` already exists), give a single `Explore` agent the full existing term list and ask it to classify each as active, drifted, or absent in one pass - one batched search, not one per term.

## Explore the codebase

Read the following layers, aiming for breadth, not depth. Each layer is a place to look for terms; everything you find goes into a single `Terminology` section.

1. **Domain model files** (classes, types, structs, interfaces) - entity-like nouns.
2. **Database schema / migrations** - entities, relationships (foreign keys, junction tables), and invariants (NOT NULL, CHECK, UNIQUE).
3. **Service / use-case layers** (business operation handlers) - workflow verbs and the roles that perform them.
4. **API routes / handlers** - workflow verbs in endpoint paths; route-level authorization names roles.
5. **Tests** (especially `describe`/`it`/docstrings) - test names often spell out workflows and invariants in plain language.
6. **Comments and documentation** (README, inline) - invariants, role distinctions, and intent behind names.

While exploring, also detect the **domain language** (the language stakeholders use when talking about the business). It may differ from the code language: a German insurance platform may have classes named `Contract` while domain experts speak of `Vertrag`. Write the whole glossary file in the domain language, and reference the code identifier in parentheses where the gap matters: `**Vertrag** (\`Contract\`) - Eine vertragliche Vereinbarung ...`.

When the same concept appears under two names in different layers (e.g. `Customer` in code, `Account` in UI strings), record the rejected one in **Aliases to avoid**.

## Check for drift in existing terms

Only if `UBIQUITOUS_LANGUAGE.md` already exists.

For each existing term, search the codebase and classify it:

- **Active** - appears in code, tests, or docs and matches the documented definition.
- **Drifted** - appears, but usage conflicts with the documented definition. Record the specific file and usage as evidence. Do not rewrite the definition without user confirmation.
- **Absent** - not found as a code identifier, test description, or comment. Do not delete; the term may live in prose docs or in conversations with domain experts. Flag for user confirmation.

## Verify with scenarios

For each major workflow you found, walk through it mentally using the candidate terms. The walk-through should read naturally: actor → action → entity → outcome. If a scenario exposes a contradiction (a missing entity, a synonym you hadn't resolved, an invariant you hadn't surfaced), refine the term list before presenting findings.

These scenarios are **skill-internal verification**; they don't go into the glossary file.

## Present findings before writing

Present in two parts.

**Part 1 - Drift findings** (only if the file already exists):

List drifted terms with specific file-and-usage evidence. List absent terms as a group for confirmation. Summarize active terms in one line (e.g. "23 existing terms confirmed active").

Then ask:

> I found [D] drifted and [A] absent terms - listed above. Let me know how to handle each before I write.

**Part 2 - New terms found:**

List new terms with one-sentence definitions. Flag any synonyms or ambiguities you want the user to resolve.

Then ask:

> I found [N] new domain terms. I have [K] questions about ambiguous terms - I'll go through them one at a time. Answer each, say "skip it" to document as-is, or "write it all" to proceed with my best guesses.

Ask questions **one at a time**, waiting for a response. Each question: one sentence of context grounded in a specific file, one concrete question about the two interpretations you observed.

## Write UBIQUITOUS_LANGUAGE.md

Follow the format in `UBIQUITOUS_LANGUAGE_FORMAT.md` (sibling of this file). The essentials while writing:

- Two sections: **Terminology** and **Aliases to avoid** (the second is optional).
- Bullets, sorted alphabetically within each section. Each entry starts with the **canonical term in bold**; cross-references inside definitions are also bolded.
- One sentence per definition. Say what the term **means in this project**, not how it's implemented.
- Write the whole file in the **domain language** detected during exploration.
- When updating an existing file: **add, don't rewrite**. Insert in place to keep the section alphabetical. Never change an existing definition without user confirmation.
- For conflicts a new term raises against an existing one: append a `## Flagged ambiguities` section at the bottom describing the conflict; do not overwrite.
- For obsolete terms: move to a `## Retired` section at the bottom; never delete.

See `UBIQUITOUS_LANGUAGE_FORMAT.md` for examples and the full set of writing rules.

## Report to the user

After writing, report:

**Glossary changes:**
```
Written: UBIQUITOUS_LANGUAGE.md
New terms: 12
Updated: 2 existing definitions revised after user confirmation
Flagged: 1 ambiguity left unresolved (see "account" in Flagged ambiguities)
```

**Drift findings** (only if the file already existed):
```
Active: 23 terms confirmed in codebase
Drifted: 1 - "Invoice" (definition says "sent after delivery"; code now generates invoices at order placement - see src/billing/invoice.ts:42)
Absent: 2 - "Fulfillment", "Shipment" (not found as code identifiers; marked for user confirmation)
```

## Wire it into CLAUDE.md / AGENTS.md

After writing, check whether `CLAUDE.md` or `AGENTS.md` at the project root already contains a read instruction for `UBIQUITOUS_LANGUAGE.md`.

- If a read instruction already covers `UBIQUITOUS_LANGUAGE.md`, no change needed.
- If neither file mentions it, add an instruction. A suitable one:

  ```
  At the start of every conversation, read [`UBIQUITOUS_LANGUAGE.md`](UBIQUITOUS_LANGUAGE.md) for canonical domain vocabulary.
  ```

- If neither `CLAUDE.md` nor `AGENTS.md` exists, tell the user: "No `CLAUDE.md` or `AGENTS.md` found. Create one at the project root with an instruction to read `UBIQUITOUS_LANGUAGE.md` at the start of every session, so agents always have canonical vocabulary in context."
