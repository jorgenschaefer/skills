---
name: ubiquitous-language
description: Use this skill to bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project that has no existing domain language documentation, or to audit and refresh an existing glossary for drift. Trigger when the user wants to capture the domain vocabulary baked into an existing codebase, says "document domain terms", "create a glossary", "check if our glossary is still accurate", or is starting to use agent workflows in a project without a shared language baseline.
---

# Ubiquitous Language

Surface the domain vocabulary a codebase already uses - in class and method names, tests and documentation - into `UBIQUITOUS_LANGUAGE.md` at the project root, each term defined from its usage. You document a language; you don't invent one.

One glossary for the whole project, even across bounded contexts: one flat list under `Terminology`.

## Pre-check existing files

Working in the current directory, read first:

1. **`UBIQUITOUS_LANGUAGE.md`**, if it exists. You are updating it, not replacing it.
2. **`CLAUDE.md` / `AGENTS.md`** at the root, if present. They may already name terms or constraints you won't need to document separately.
3. **`UBIQUITOUS_LANGUAGE_FORMAT.md`** in this skill directory - the format and updating rules the glossary follows.

## Explore the codebase

Spawn up to 3 `Explore` subagents in parallel over the six layers below, aiming for breadth, not depth, each returning its candidate terms with file-and-usage evidence; merge their lists before presenting. Where the glossary exists, spawn the drift subagent alongside them. Suggested split:

- **Agent A:** domain model files + database schema/migrations.
- **Agent B:** service/use-case layers + API routes/handlers.
- **Agent C:** tests + comments/documentation.

1. **Domain model files** (classes, types, structs, interfaces) - entity-like nouns.
2. **Database schema / migrations** - entities, relationships (foreign keys, junction tables), and invariants (NOT NULL, CHECK, UNIQUE).
3. **Service / use-case layers** (business operation handlers) - workflow verbs and the roles that perform them.
4. **API routes / handlers** - workflow verbs in endpoint paths; route-level authorization names roles.
5. **Tests** (especially `describe`/`it`/docstrings) - test names often spell out workflows and invariants in plain language.
6. **Comments and documentation** (README, inline) - invariants, role distinctions, and intent behind names.

Detect the **domain language** too - the one stakeholders use about the business, which may differ from the code's: a German insurance platform may have classes named `Contract` while domain experts speak of `Vertrag`. The glossary is written in it.

When the same concept appears under two names in different layers (e.g. `Customer` in code, `Account` in UI strings), record the rejected one in **Aliases to avoid**.

## Check for drift in existing terms

Only if `UBIQUITOUS_LANGUAGE.md` already exists.

Give a single general-purpose subagent - not `Explore`, which locates code but does not judge it - the full existing entries, definitions and aliases included, and the classes below. It reads the uses of each term and returns a verdict per term, plus every alias still in use; for each alias and every verdict but active and absent, it returns the file, line and usage as well. That is all the later steps use, so the uses of active terms stay out of your context. The asks below are yours, in Part 1. Finding the word does not make a term active; its use has to match the definition.

- **Active** - appears in code, tests, or docs and matches the documented definition.
- **Drifted** - appears, but usage conflicts with the documented definition.
- **Identifier mismatch** - the concept is in the code and matches the definition, but under an identifier other than the one in the entry's parentheses; report the identifier used. Either the entry or the code is renamed; ask which.
- **Absent** - not found as a code identifier, test description, or comment. Search three forms, not one: the entry's English identifier, the term itself, and the term transliterated to ASCII - the code usually carries the identifier, and an untranslatable term reaches it as itself with umlauts transliterated, so any two forms report compliant entries absent. Do not delete; the term may live in prose docs or with domain experts. Flag it for user confirmation.
- **Alias in use** - an entry under **Aliases to avoid** still names the concept in code, tests or UI strings. Either the code missed the decision or the decision no longer holds; ask which.

Read the entries yourself for one more class, which needs no code:

- **Over-long** - an entry that holds more than the format's one sentence: behaviour, screens, rationale, how it is built. Propose the one sentence that keeps its meaning.

## Verify with scenarios

Walk each major workflow through the candidate terms: actor → action → entity → outcome, reading naturally. Where a walk-through exposes a contradiction (a missing entity, an unresolved synonym, an invariant you hadn't surfaced), refine the term list before presenting. The walk-throughs stay out of the glossary.

## Present findings before writing

**Part 1 - Drift findings** (only if the file already exists): drifted terms, identifier mismatches and aliases still in use, each with its file and usage; absent terms as a group for confirmation; over-long entries, each with its proposed sentence; active terms in one line (e.g. "23 existing terms confirmed active"). Then ask:

> I found [D] drifted terms, [M] identifier mismatches, [A] absent terms, [U] aliases still in use and [L] over-long entries - listed above. Let me know how to handle each before I write.

Where the existing file departs from the format - a table, other headings, no line naming the domain language, another language - name each difference and ask whether to convert the file or keep its format for the new entries. Convert only in a write of its own, separate from the content changes.

**Part 2 - New terms found:** each with a one-sentence definition, flagging the synonyms and ambiguities you want resolved. Then ask:

> I found [N] new domain terms. I have [K] questions about ambiguous terms - I'll go through them one at a time. Answer each, say "skip it" to document as-is, or "write it all" to proceed with my best guesses.

Ask them **one at a time**, waiting for each answer: one sentence of context grounded in a specific file, then one concrete question between the two interpretations you observed.

## Write UBIQUITOUS_LANGUAGE.md

Follow `UBIQUITOUS_LANGUAGE_FORMAT.md`, its updating rules included.

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
Identifier mismatch: 1 - **Vertrag** (`Contract`), code uses `Agreement` (src/contracts/agreement.ts:3)
Absent: 2 - "Fulfillment", "Shipment" (not found as code identifiers; marked for user confirmation)
Aliases in use: 1 - "Account" for **Customer** (src/orders/checkout.ts:17)
Over-long: 1 - "Abruf" (2,700 characters of screens and order of steps; proposed: "fetching the bank's new entries into the ledger")
```
