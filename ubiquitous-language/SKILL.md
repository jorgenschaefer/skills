---
name: ubiquitous-language
description: Use to write a UBIQUITOUS_LANGUAGE.md glossary from the domain terms in a codebase that has none - "create a glossary", "document our domain terms", "capture the vocabulary of this codebase" - or to refresh an existing one and check it against the code - "is our glossary still accurate", "check the glossary for drift".
---

# Ubiquitous Language

Write or refresh `UBIQUITOUS_LANGUAGE.md` at the project root from the domain vocabulary the codebase already uses - in class and method names, tests and documentation - each term defined from its usage, and report where an existing glossary has drifted from the code. You document a language; you don't invent one.

One glossary for the whole project, even across bounded contexts: one flat list under `Terminology`.

## Read first

In the current directory:

1. **`UBIQUITOUS_LANGUAGE.md`**, if it exists. You are updating it, not replacing it.
2. **`CLAUDE.md` / `AGENTS.md`** at the root, if present. Where they already name a term, the glossary uses the same word.
3. **`UBIQUITOUS_LANGUAGE_FORMAT.md`** in this skill's directory - what goes in the glossary, its format, and the updating rules.

## Explore the codebase

Spawn up to 3 `Explore` subagents in parallel that together cover all six layers below, aiming for breadth, not depth. Each returns its candidate terms with the file and usage for each. Merge their lists before presenting. If the glossary exists, spawn the drift subagent below alongside them. Suggested split:

- **Agent A:**
  - domain model files (classes, types, structs, interfaces) - entity-like nouns;
  - database schema and migrations - entities, relationships (foreign keys, junction tables) and invariants (NOT NULL, CHECK, UNIQUE).
- **Agent B:**
  - service and use-case layers - workflow verbs and the roles that perform them;
  - API routes and handlers - workflow verbs in endpoint paths, and roles in route-level authorization.
- **Agent C:**
  - tests, especially `describe`/`it` names and docstrings - workflows and invariants in plain language;
  - comments and documentation (README, inline) - invariants, role distinctions, and the intent behind names.

Detect the **domain language** too: the one stakeholders use about the business. It may differ from the code's - a German insurance platform may have classes named `Contract` while domain experts speak of `Vertrag`.

When the same concept appears under two names in different layers (e.g. `Customer` in code, `Account` in UI strings), the user picks the canonical name in Part 2, and the other goes into **Aliases to avoid**.

## Check for drift in existing terms

Only if `UBIQUITOUS_LANGUAGE.md` already exists.

Give a single general-purpose subagent - not `Explore`, which locates code but does not judge it - the full existing entries, definitions and aliases included, and the classes below. It reads the uses of each term and returns:

- a verdict for each term;
- every alias still in use;
- for each alias in use and each verdict other than active and absent, the file, line and usage.

It returns nothing else, so the uses of active terms stay out of your context. The subagent asks no questions; the questions below are yours, in Part 1.

- **Active** - appears in code, tests or docs, and its use matches the documented definition. Finding the word is not enough.
- **Drifted** - appears, but its use conflicts with the documented definition.
- **Identifier mismatch** - the concept is in the code and matches the definition, but under an identifier other than the one in the entry's parentheses; report the identifier used. Either the entry or the code is renamed; ask which.
- **Absent** - not found as a code identifier, test description or comment. Search all three forms: the entry's English identifier, the term itself, and the term transliterated to ASCII. The code usually carries the English identifier, and a term without an English equivalent appears as itself, transliterated; searching fewer forms reports entries absent that the code does use. Do not delete an absent term, since it may live in prose docs or with domain experts; flag it for confirmation in Part 1.
- **Alias in use** - an entry under **Aliases to avoid** still names the concept in code, tests or UI strings. Either the code missed the decision or the decision no longer holds; ask which.

Read the entries yourself for one more class, which needs no code:

- **Over-long** - an entry that holds more than the format's one sentence: behaviour, screens, rationale, how it is built. Propose the one sentence that keeps its meaning.

## Verify with scenarios

Walk each major workflow through the candidate terms: actor → action → entity → outcome, and check that it reads naturally. If a walk-through exposes a contradiction - a missing entity, an unresolved synonym, an invariant you hadn't found - fix the term list before presenting. The walk-throughs stay out of the glossary.

## Present findings before writing

**Part 1 - Drift findings**, only if the file already exists:

- drifted terms, identifier mismatches and aliases still in use, each with its file and usage;
- absent terms, as one group for confirmation;
- over-long entries, each with its proposed sentence;
- active terms in one line, e.g. "23 existing terms confirmed active".

Then ask:

> I found [D] drifted terms, [M] identifier mismatches, [A] absent terms, [U] aliases still in use and [L] over-long entries - listed above. Let me know how to handle each before I write.

If the existing file departs from the format - a table, other headings, no line naming the domain language, entries in another language - name each difference. Ask whether to convert the file or keep its format for the new entries. Convert only in a write of its own, separate from the content changes.

**Part 2 - New terms found:** each with a one-sentence definition, flagging the synonyms and ambiguities you want resolved. Present only the candidates the format admits: a term with a clear, project-specific meaning that a reader would not know without the entry. Name the candidates you left out - generic words, and parts of the UI or the implementation that are not domain concepts - in one line, so the user can claim one back. Then ask:

> I found [N] new domain terms. I have [K] questions about ambiguous terms - I'll go through them one at a time. Answer each, say "skip it" to document as-is, or "write it all" to proceed with my best guesses.

Ask them **one at a time**, waiting for each answer: one sentence of context grounded in a specific file, then one concrete question between the two interpretations you observed. The questions include a canonical name for each concept with two names, a definition for each term an entry refers to that has no entry of its own, and each new term that contradicts an existing one.

## Write UBIQUITOUS_LANGUAGE.md

Follow `UBIQUITOUS_LANGUAGE_FORMAT.md`, its updating rules included.

## Report to the user

After writing, report:

**Glossary changes:**
```
Written: UBIQUITOUS_LANGUAGE.md
New terms: 12
Left out: 9 candidates that are not domain terms or need no entry
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
