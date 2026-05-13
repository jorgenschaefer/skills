Update `UBIQUITOUS_LANGUAGE.md` at the project root with any new terms. For each new term, add a table row to the appropriate group:

```
| **Term** | One-sentence definition in this project's context | Other words used for this concept |
```

If an existing group fits the term, add the row there. If no group fits, add a new group heading and start a new table. Don't add terms already present; don't add generic English words — only terms with project-specific or domain-specific meaning.

## When to add a new term

Add a term when all of the following hold:

1. It has a specific meaning in this project that differs from everyday usage, or it names a concept that recurs across multiple files and teams.
2. It is not already in the glossary (check before adding).
3. It is used — or will be used — in code identifiers, test descriptions, or documentation. Concepts discussed only in passing don't need entries.

**When to update instead of add:** if an existing entry is imprecise or the definition has drifted from how the term is now used, update the definition rather than adding a second entry for the same concept.

## Handling conflicting usages

If a new term is easily confused with, or conflicts with, an existing glossary entry:

- Do **not** add both; the ambiguity is the problem, not the solution.
- Append a bullet to the Flagged ambiguities section: name both usages, cite the specific files where each appears, and recommend a canonical choice with the reason.
- The recommended canonical choice should match how the term appears most consistently in code identifiers.

If a new term conflicts with an existing entry for a genuinely different concept (same word, different meanings), disambiguate both entries using a qualifying phrase (e.g., `Payment (domain)` vs. `Payment (infrastructure)`).

## Format

```
| **Term** | One-sentence definition in this project's context | Other words used for this concept |
```

If an existing group fits the term, add the row there. If no group fits, add a new group heading and start a new table.

Do NOT update the Relationships section or the Example dialogue during routine term additions — those sections require a full-file synthesis pass and should be updated manually only when structural changes to the workflow are significant enough to warrant it.

If the file doesn't exist yet, create it with this minimal structure (no Relationships section or Example dialogue — those will be added when the dedicated skill is first invoked):

```md
# Ubiquitous Language

## <Group name>

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **<Term>** | <definition> | <aliases> |
```
