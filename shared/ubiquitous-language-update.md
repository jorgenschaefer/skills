Update `UBIQUITOUS_LANGUAGE.md` at the project root with any new terms. For each new term, add a table row to the appropriate group:

```
| **Term** | One-sentence definition in this project's context | Other words used for this concept |
```

If an existing group fits the term, add the row there. If no group fits, add a new group heading and start a new table. Don't add terms already present; don't add generic English words — only terms with project-specific or domain-specific meaning.

If a new term conflicts with or is easily confused with an existing glossary entry, append a bullet to the Flagged ambiguities section naming both terms and the recommended canonical choice.

Do NOT update the Relationships section or the Example dialogue — those are maintained by the dedicated `ubiquitous-language` skill, which synthesises the whole file.

If the file doesn't exist yet, create it with this minimal structure (no Relationships section or Example dialogue — those will be added when the dedicated skill is first invoked):

```md
# Ubiquitous Language

## <Group name>

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **<Term>** | <definition> | <aliases> |
```
