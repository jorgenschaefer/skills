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

## Layers

Prefer a small number of layers that each hide real substance over many thin layers that only relay calls.

- **Indirection pays for itself.** A layer earns its place only if a caller can use it correctly without understanding what is behind it. A wrapper that relays the same vocabulary and shape it received, a delegate-only class, a hop that adds a name but no meaning - none of them do. Thinness is not the defect; a layer that spares the caller nothing is.
- **Inline the trivial.** A pass-through that does nothing but forward its argument, or a 1:1 domain-to-storage mapping, can stay inline. Do not manufacture a layer for it. Pull one out when the responsibility grows past trivial - real translation, real rules, more than one caller.

## General rules

- **YAGNI.** Production code should contain only code and abstractions that are needed now, not in an imagined future.
- **KISS.** Prefer the simplest thing that works over "clever" designs or needless optimization.
- **Duplication is justified or removed.** Two copies that will change for the same reason belong in one place. Duplication is acceptable only when the copies will change for *different* reasons - then prefer it over the wrong abstraction. There is no count of copies that decides this.
- **No optimization without measurement.** Never make code "more efficient" without having measured it and defined the efficiency as a problem. Two costs are the exception, because they follow from the shape of the code plus a number you can go and look up: a query inside a loop, and a query with no bound or no index on what it filters or sorts.
- **No dead code.** Code that is not used anywhere outside of its tests should not be in the repository. Note what only *looks* dead but is live: dynamic or reflective access, DI registration, string-referenced routes, config and env, framework entry points, and exported API consumed from outside this repo - an exported symbol with no internal caller is not dead.

## File and directory layout

Code that changes together should live close together - same file, same directory, same module. Having to jump between distant locations to follow one piece of logic is a smell; the further the jump, the worse it is.

- **Feature-based modules.** Combine a feature's code into the same module, each feature in its own directory or file. Prefer this over splitting by type, for example having all controllers in one directory and all models in another.
- **Co-locate tests.** Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.
- **Reads top to bottom** (the stepdown rule / newspaper metaphor). Files open with the abstract idea and grow concrete; a helper sits below its caller, so a reader meets a function before its details.

## Concurrency and shared state

Code that reads correctly from top to bottom can still be wrong, because it does not run alone. Two requests, a double-clicked button, a retried webhook - each is a second execution interleaved with the first, and the defect lives in the gap between two lines that look adjacent.

- **A decision made from a value you loaded is stale by the time you act on it.** Read a balance, check it, write it back, and two concurrent runs both decide from the same load - one write is lost. "Does this exist? No - create it" is the same bug: the row appears in the gap. Push the decision down to where the data is - a conditional update, a unique constraint, `SET n = n + 1`, a transaction at an isolation level you chose on purpose - rather than holding it in application memory across an `await`.
- **No mutable state outside a request.** A module-level cache, counter, or accumulator is shared by every request the process handles at once - and in a serverless runtime it survives between them too, so one user's data reaches the next. State belongs in the request or in the store.

## Security

**Authorization is checked against the object, not just the route.** Authentication establishes who is calling, and a route guard that they may call this endpoint; neither says they may touch *this record*. Every id arriving in a path, body, or query is a claim about ownership until the server checks it, and the check belongs inside the query (`where: { id, ownerId: session.userId }`) rather than after the fetch, where forgetting it returns the data anyway. The attacker here holds a valid session and is changing the number.

## Changing what already runs

A new file is judged against the spec. Everything else is judged against what is already deployed and already stored, neither of which appears in the diff.

- **Deploy order is part of the design.** For the length of a rollout, old code runs against the new schema and new code against the old one. A change that is only correct once both halves have landed is two changes, and the order they land in is a decision.
- **A column is dropped only once nothing reads it**, which is a later deploy and not this one. Add a column nullable or defaulted before anything writes it, and backfill as its own step.

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

## Architecture decisions

A decision earns a record when it will outlive the change that produced it and someone will later wonder why - a boundary, a representation the whole codebase has to agree on, a dependency taken on or refused for a reason the code cannot show, a constraint accepted. A decision that only shapes the change in front of you is not one of these.

**Never write one unilaterally.** Put the decision and a recommendation to the person, and write the record only once they have said yes.

## Test coverage

**Every piece of business logic is pinned by a test:** removing or changing it would make a test fail. For each piece, you should be able to name the test that pins it; where you cannot, that is a coverage gap.

Use TDD when writing code.

**No code change without a failing test first.** Write the test, watch it fail for the reason you expect, then write the code that makes it pass.

Deleting code can happen without a failing test first.

**Each phase is a separate test run.** Red, green, refactor, in the smallest steps that make sense. Writing the test and the code and then running once is not TDD even when the artifacts end up identical, because the RED run is the only thing that proves the test exercises the behaviour.

1. **RED.** One trivially small failing test for the next bit of behaviour. Run it, and confirm **the assertion fires and reports an expected/actual mismatch**. "Module not found", an import error or a syntax error is not RED - it only proves the test could not run. If the test passes immediately, you wrote the code first: revert it, get the failure, re-implement.
2. **GREEN.** The simplest change that could possibly work. Faking the answer with a constant is fine; the next test forces the general case. If you cannot see a small change that passes, the test is too big - revert and write a smaller one.
3. **REFACTOR.** Tests green, no new behaviour, remove duplication. Most cycles this is empty. Do not manufacture work to fill it.

**The test observes the behavior, not the call.** Failing when the behavior is removed is necessary, not sufficient. A test asserting that a mock was called does fail when you delete the call. Assert on what the code produces: the value returned, the state changed, the row written, the output rendered. A test that merely restates the implementation - the arguments a collaborator was handed, the order two internal steps ran in - moves with the code instead of holding it still, and does not close a coverage gap.

**The edges of the input range are pinned too.** The happy path runs on the value someone had in mind; the behavior has to be right on the boundaries around it, and those come from a list rather than from inspiration. Walk it against what this code takes in: empty and absent (not the same thing), zero, one, negative, the largest input that is realistic rather than the largest that is possible, the value on each side of every comparison, a duplicate, and - where the domain has them - non-ASCII text, a timezone or DST boundary, and money that will not survive a float. An entry that means something here and that the code has never seen is either a missing test or a defect.

**The failure paths are pinned too.** What the code does when things go wrong is business logic: the rejected input, the failed call, the missing record, the conflicting write. A suite that only walks the happy path leaves the branches that run on the worst day as the only ones nobody has executed. Where the code cleans up, retries, or rolls back on failure, a test drives it there.

**External adapters** - the thin edge that talks to a third-party SDK, the network, or IO - may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested.

## What does not belong

Code that works, is referenced, and is correct can still not be worth what it costs to carry. Weigh **what it brings** - how much it matters to what the project does, and to whether the project is usable - against **what it costs** - how complex it is, how hard to understand, how hard to change. Where the cost clearly outweighs the value, it does not belong, *even though nothing above it is violated*.

This is the one property here that can take working functionality away, so it is handled differently from everything else in this document:

- It is **always a tradeoff put to a person**, never a defect to fix. State the value, the cost, and what is lost if it goes; then let them choose.
- It is **never applied without its own explicit go-ahead**, even when the rest of a cleanup has been approved.
- It is **never grouped with findings that are safe to apply.** Mixing it in is the one mistake that makes a review dangerous: a reader trusts a safe item, applies it, and has made a product decision without noticing.
