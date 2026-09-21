# Coding standards

What good software looks like. Any software project is held to this standard.

This extends your existing standards, it does not replace them.

## Ubiquitous language

`UBIQUITOUS_LANGUAGE.md`, where the project keeps one, is the source of truth for the domain's names. If a concept has a name in there already, use it before inventing your own. If a concept is new, confirm with the user what it is called in the domain and add it there before using it.


## Function and method names follow domain actions

When users talk about "publishing a blog post" or "archiving it", the respective functions should be `publishPost` and `archivePost` - not `updatePost`, even though both end as a database `UPDATE`.

When users talk about "setting an article's category", the respective function should be `setArticleCategory`. When users talk about "saving an article" on the other hand, the function should be `saveArticle` with the argument being a compound object of everything the users mean with "the article" in this context - that could contain the category.

## Business logic works with domain objects

Entities, value objects and aggregates the domain talks about are defined explicitly as local domain objects (for example, classes or interfaces).

External seams - database interfaces, components, etc. - translate their respective external data into a local domain objects. The rest of the code (the business logic) works with those local domain objects.

External representations, ORM types, data transfer objects etc. do not leak into the business logic. They are validated at the boundaries and translated to domain objects.

## General rules

- **YAGNI.** Production code should contain only code and abstractions that are needed now, not in an imagined future.
- **KISS.** Prefer the simplest thing that works over "clever" designs or needless optimization.
- **No optimization without measurement.** Never make code "more efficient" without having measured it and defined the efficiency as a problem.
- **No dead code.** Code that is not used anywhere outside of its tests should not be in the repository.

## File and directory layout

Code that changes together should live close together - same file, same directory, same module. Having to jump between distant locations to follow one piece of logic is a smell; the further the jump, the worse it is.

- **Feature-based modules.** Combine a feature's code into the same module, each feature in its own directory or file. Prefer this over splitting by type, for example having all controllers in one directory and all models in another.
- **Co-locate tests.** Put a test next to the file it tests, not in a separate `tests/` tree.
- **Reads top to bottom** (the stepdown rule / newspaper metaphor). Files open with the abstract idea and grow concrete; a helper sits below its caller, so a reader meets a function before its details.

## Comments

Comments should be rare, as they are outdated the moment they are written.

The intent of code should be obvious. Before adding a comment, try to make the code more explicit and the intent more obvious by adding well-named helper functions. Only if that fails, and a future reader would have trouble understanding the intent of a piece of code, add a comment. Reluctantly.

## Language

Code is in English. Identifiers, test names, comments and commit messages are English whatever language the domain speaks, and whatever language `UBIQUITOUS_LANGUAGE.md` is written in. The glossary is where the two meet: its entries stand in the domain language and each carries the English identifier the code uses, so `Vertrag` in the user's mouth is `Contract` in the source.

Where an entry says its term has no English equivalent - a legal or regulatory word that does not translate - the domain term is the identifier, verb or noun alike, in the glossary's canonical form rather than re-inflected for the call site, transliterated to ASCII (`ä`, `ö`, `ü` and `ß` become `ae`, `oe`, `ue` and `ss`) and cased like any other name here, with everything around it that the entry does not cover staying English.

If an entry does not have an English identifier and does not explicitly say that there is no English equivalent is just missing a translation. Ask the user for the correct term, do not invent one.

## Dependencies

When adding a dependency, do not rely on your training data. Check:

- **Package name.** Check the registry before adding it, you might misremember the name.
- **Latest stable release.** Look the version up rather than relying on memory - memory is almost always stale.

## Test coverage

Use TDD when writing code.

**No code change without a failing test first.** Write the test, watch it fail for the reason you expect, then write the code that makes it pass.

Deleting code can happen without a failing test first.

**The test observes the behavior, not the call.** Failing when the behavior is removed is necessary, not sufficient. A test asserting that a mock was called does fail when you delete the call. Assert on what the code produces: the value returned, the state changed, the row written, the output rendered. A test that merely restates the implementation - the arguments a collaborator was handed, the order two internal steps ran in - moves with the code instead of holding it still, and does not close a coverage gap.

**External adapters** - the thin edge that talks to a third-party SDK, the network, or IO - may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested.
