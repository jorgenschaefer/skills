# UBIQUITOUS_LANGUAGE.md format

The project-wide canonical vocabulary lives in `UBIQUITOUS_LANGUAGE.md` at the project root. It captures the domain language - the shared terms that mean the same thing to developers, users, and stakeholders.

The discovery skill writes to it as new terms surface in interviews. Other agents and humans read it to use consistent vocabulary across code, tests, and documentation.

Only terms with a clear, project-specific meaning that would not be immediately obvious without the entry go in here. Terms that could be misunderstood definitely belong here.

## Language

Start the file with a line declaring the domain language (see the minimal example). Write all entries in that language. Code identifiers stay English, so when the domain language is not English, give the English identifier in `code-font` parentheses after the bold term:

```markdown
- **Vertrag** (`Contract`) - spezifisch das Dokument, das die Nutzungsbedingungen für unsere API festhält.
```

Leave the parentheses off only where the term genuinely has no English equivalent - a legal or regulatory word that does not translate - and say so in the entry itself. Saying it is what tells a builder to use the domain term as the identifier; a missing parenthesis on its own means only that nobody has filled it in yet. An invented English word here is worse than none, because it reads as the name the code should use.

```markdown
- **Grundschuld** - das dingliche Verwertungsrecht an einem Grundstück; kein englisches Äquivalent, daher steht der Begriff auch im Code.
```

## Sections

The file has two standing sections - **Terminology** and **Aliases to avoid** - plus two appended only when the updating rules call for them: **Flagged ambiguities** and **Retired**. Use these exact headings.

Within each section, entries are bullets sorted alphabetically by the bold canonical term. Each entry starts with the **canonical term in bold**; references to other glossary terms inside an entry are also bolded so the cross-references jump out.

### Terminology

One sentence per term: define its meaning in the project, and if it's ambiguous, add a note on how to disambiguate it.

```markdown
- **Contract** - the legal document that outlines the terms of service for our API.
```

### Aliases to avoid

The rejected term in quotes, the canonical one in bold, then a short reason. This section is the project's record of disambiguation decisions.

```markdown
- "Account" - use **Customer** for the order-placing entity. "Account" is reserved for authentication identity.
- "Item" - use **Line Item** instead. "Item" was used for both products and order lines.
```

### Flagged ambiguities and Retired

Created on demand by the updating rules below - Flagged ambiguities holds unresolved conflicts awaiting user input, Retired holds obsolete terms kept for history. Both live at the bottom of the file.

## Updating rules

- **Add, don't rewrite.** Never modify an existing definition without explicit user confirmation. New terms are appended to the right section.
- **Sort alphabetically within each section.** Insert in place, keyed on the bold canonical term.
- **Cross-reference, don't redefine.** If a definition names another domain term, that term must have its own entry in **Terminology**. If you find an unresolved reference, add a stub entry and flag it as needing user input.
- **Flag conflicts, don't overwrite.** If a new term contradicts an existing one, append a `## Flagged ambiguities` section at the bottom describing the conflict, and ask the user to resolve before merging.
- **No silent deletions.** If a term seems obsolete, move it to a `## Retired` section at the bottom rather than removing it; the history matters.

## Minimal example

```markdown
# Ubiquitous Language

The domain language is English.

## Terminology

- **Cart** - A holding area where a **Customer** assembles **Line Items** before placing an **Order**.
- **Customer** - A person or organization that places **Orders**.
- **Line Item** - A single product entry within a **Cart** or **Order**, with quantity and price.
- **Order** - A **Customer**'s submitted request for goods, with **Line Items**, totals, and a status.

## Aliases to avoid

- "Item" - use **Line Item** instead.
```
