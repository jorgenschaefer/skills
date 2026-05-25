# UBIQUITOUS_LANGUAGE.md format

The project-wide canonical vocabulary lives in `UBIQUITOUS_LANGUAGE.md` at the project root. It captures the domain language - the shared terms that mean the same thing to developers, users, and stakeholders.

The discovery skill writes to it as new terms surface in interviews. Other agents and humans read it to use consistent vocabulary across code, tests, and documentation.

Only terms with a clear, project-specific meaning that would not be immediately obvious without the entry go in here. Terms that could be misunderstood definitely belong here.

If the domain language is not English, use the domain language thorough the file.

## Sections

Within each section, entries are bullets, sorted alphabetically. Each entry starts with the **canonical term in bold**. Inside any entry, references to other glossary terms are also bolded so the cross-references jump out.

### Terminology

> - **Contract** - the legal document that outlines the terms of service for our API.

If the domain language is not English, the code should use English terms. Add the canonical translation in parentheses

> - **Vertrag** (`Contract`) - spezifisch das Dokument, das die Nutzungsbedingungen für unsere API festhält.

One sentence. Define the term and its meaning in the project. If the term is ambiguous, add a note about how to disambiguate it.

### Aliases to avoid

> - "Account" - use **Customer** for the order-placing entity. "Account" is reserved for authentication identity.
> - "Item" - use **Line Item** instead. "Item" was used for both products and order lines.

The rejected term in quotes, the canonical one in bold, then a short reason. This section is the project's record of disambiguation decisions.

## Updating rules

- **Add, don't rewrite.** Never modify an existing definition without explicit user confirmation. New terms are appended to the right section.
- **Sort alphabetically within each section.** Insert in place.
- **Cross-reference, don't redefine.** If a definition names another domain term, that term must have its own entry in **Terminology**. If you find an unresolved reference, add a stub entry and flag it as needing user input.
- **Flag conflicts, don't overwrite.** If a new term contradicts an existing one, append a `## Flagged ambiguities` section at the bottom of the file describing the conflict, and ask the user to resolve before merging.
- **No silent deletions.** If a term seems obsolete, move it to a `## Retired` section at the bottom rather than removing it; the history matters.

## Minimal example

```markdown
# Ubiquitous Language

The domain language is English.

## Terminology

- **Cart** - A holding area where a Customer assembles Line Items before placing an Order.
- **Customer** - A person or organization that places Orders.
- **Line Item** - A single product entry within a Cart or Order, with quantity and price.
- **Order** - A Customer's submitted request for goods, with Line Items, totals, and a status.

## Aliases to avoid

- "Item" - use **Line Item** instead.
```
