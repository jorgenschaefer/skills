# Coding Standards

What good software looks like. Any software project is held to this standard.

This extends your existing standards, it does not replace them.

**The Holy Commandments:**

- **YAGNI.** Only build and keep what is actually needed now, not in an imagined future.
- **KISS.** Prefer the simplest thing that works over "clever" designs or needless optimization.

You are looking for six properties. Check them in order. Where two of them pull against each other the earlier one wins.

- Correctness
- Security
- Usability
- Sufficient Efficiency
- Sufficient Reliability
- Maintainability

## Correctness

Does the code do what it is supposed to do?

What that is may have to be derived from the context first - the ticket, the callers, the domain - before it can be checked, and it is checked for the general case _and_ the edge cases, not the one input somebody had in mind.

Code should also be obvious in what it is meant to do. If you have to guess, or if the context points in another direction than the code would hint, that's a flag.

### Test Coverage

**Every piece of business logic is pinned by a test:** removing or changing it would make a test fail. For each piece, you should be able to name the test that pins it; where you cannot, that is a coverage gap.

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

### Concurrency and Shared State

Code that reads correctly from top to bottom can still be wrong, because it does not run alone. Two requests, a double-clicked button, a retried webhook - each is a second execution interleaved with the first, and the defect lives in the gap between two lines that look adjacent.

- **A decision made from a value you loaded is stale by the time you act on it.** Read a balance, check it, write it back, and two concurrent runs both decide from the same load - one write is lost. "Does this exist? No - create it" is the same bug: the row appears in the gap. Push the decision down to where the data is - a conditional update, a unique constraint, `SET n = n + 1`, a transaction at an isolation level you chose on purpose - rather than holding it in application memory across an `await`.
- **No mutable state outside a request.** A module-level cache, counter, or accumulator is shared by every request the process handles at once - and in a serverless runtime it survives between them too, so one user's data reaches the next. State belongs in the request or in the store.

### Changing What Already Runs

A new file is judged against the spec. Everything else is judged against what is already deployed and already stored, neither of which appears in the diff.

- **Deploy order is part of the design.** For the length of a rollout, old code runs against the new schema and new code against the old one. A change that is only correct once both halves have landed is two changes, and the order they land in is a decision.
- **A column is dropped only once nothing reads it**, which is a later deploy and not this one. Add a column nullable or defaulted before anything writes it, and backfill as its own step.

## Security

Code assumes a malicious user. Can they see what they should not see, or do things they should not be able to do?

Be especially wary when it comes to personally identifiable information.

**Authorization is checked against the object, not just the route.** Authentication establishes who is calling, and a route guard that they may call this endpoint; neither says they may touch _this record_. Every id arriving in a path, body, or query is a claim about ownership until the server checks it, and the check belongs inside the query (`where: { id, ownerId: session.userId }`) rather than after the fetch, where forgetting it returns the data anyway. The attacker here holds a valid session and is changing the number.

## Usability

The goal of any software is to be usable by the user. Does the software support the main workflows smoothly? Can all buttons be used on all supported screen sizes, are all texts large enough to be read, are texts cut off? Does longer or shorter than usual text break the display?

### Ubiquitous Language

`UBIQUITOUS_LANGUAGE.md`, where the project keeps one, is the source of truth for the domain's names. If a concept has a name in there already, use it before inventing your own. If a concept is new, confirm with the user what it is called in the domain and add it there before using it.

This is true both for the user interface as well as the code. Any given concept has a single name in the code base, at every level from UI to storage.

### Actionable Error Messages

An error message tells whoever reads it what to do next. It names what went wrong in their terms, the value that caused it, and the move that fixes it: "Invoice date 2026-13-01 is not a valid date, use YYYY-MM-DD", not "Invalid input". "Something went wrong" is acceptable only for the rare failure nobody can act on, as under _Sufficient Reliability_.

The reader decides the wording. An end user gets the domain's words and no stack trace, table name or internal id - those are for the log, and showing them is a leak. A developer calling a function or running a command gets the parameter, the constraint it broke and the value it received. An error that reliably leads its reader to the wrong move is a defect.

## Sufficient Efficiency

The software should be fast enough to be usable, but not faster. Performance is not an absolute requirement. 10 ms to 5 ms is a performance improvement but an irrelevant one; 500 ms to 250 ms is not.

**No optimization without measurement.** Never make code "more efficient" without having measured it and defined the efficiency as a problem - a win that does not cross the threshold above is not one. Two costs are the exception, because they follow from the shape of the code plus a number you can go and look up: a query inside a loop, and a query with no bound or no index on what it filters or sorts.

## Sufficient Reliability

Outside of the happy path, software fails gracefully. But the less likely a failure path is, the less graceful it needs to be. A regular error case might need automatic retries and a well-phrased error display. A rare, unusual error might do with an "an error occurred, try again" popup.

## Maintainability

Finally, software is written to be maintained and extended in the future. When a bug is reported, can its location be found quickly? When a change is asked for, is every place it touches easy to find?

### What Changes Together, Stays Together

If different pieces of code change together, they should be located together, so that when one changes the other is visible.

The more tightly they change together, the closer they should be together.

If two pieces of code are similar and always change the same, they should be unified. If two pieces of code look similar, but will change for different reasons, the duplication is useful. Prefer duplication over the wrong abstraction.

Directories and modules should therefore group code by feature. Prefer this over splitting by type, for example having all controllers in one directory and all models in another.

Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.

**Before adding code to a file of more than about 500 lines, split it.** Divide it along what changes together into files of roughly 150-300 lines, each holding one part, and split its test file the same way, so each part keeps exactly one test file. When only the test file is over the limit, first shorten it: shared setup, table-driven cases, helpers for repeated assertions. If it is still too long, the source holds more than one part - split the source and its tests together, even though the source is under the limit. The split changes no behaviour and comes before the change, not mixed into it. Generated files are exempt.

### Function and Method Names Follow Domain Actions

When users talk about "publishing a blog post" or "archiving it", the respective functions should be `publishPost` and `archivePost` - not `updatePost`, even though both end as a database `UPDATE`. When they talk about "setting an article's category", it should be `setArticleCategory`; when they talk about "saving an article", it should be `saveArticle`, with the argument a compound object of everything the users mean by "the article" in this context - which could contain the category.

### Business Logic Works with Domain Objects

Entities, value objects and aggregates the domain talks about are defined explicitly as local domain objects (for example, classes or interfaces).

External seams - database interfaces, components, etc. - validate their external data at the boundaries and translate it into those objects; the rest of the code (the business logic) works only with them, and ORM types, data transfer objects and other external representations do not leak into it.

### Layers

Prefer a small number of layers that each hide real substance over many thin layers that only relay calls.

- **Indirection pays for itself.** A layer earns its place only if a caller can use it correctly without understanding what is behind it. A wrapper that relays the same vocabulary and shape it received, a delegate-only class, a hop that adds a name but no meaning - none of them do. Thinness is not the defect; a layer that spares the caller nothing is.
- **A variation point is varied.** An interface or base class with one implementation, a factory or strategy with one variant, an option every caller sets the same way: collapse each to its one case. Two exceptions: the adapter over an external dependency under _Test Coverage_, whose mock is its second case, and a variation point exported for code outside this repo to fill.
- **Inline the trivial.** A pass-through that does nothing but forward its argument, or a 1:1 domain-to-storage mapping, can stay inline. Do not manufacture a layer for it. Pull one out when the responsibility grows past trivial - real translation, real rules, more than one caller.

### Files Read Top to Bottom

A single file and every class and function inside it should read top to bottom. They start with the abstract idea and grow concrete. Helpers sit below the callers, not above them.

Reduce nesting. Prefer early returns as guards over nested if statements.

Every function call should be fully understandable from the name and parameters alone, without reading its source. If it is not, the name needs to be improved.

No reflection, monkey-patching, implicit registration, come-from, introspection, or other magic. If some piece of code causes another piece of code to run, it should say so explicitly. This does NOT refer to callbacks or signal handlers: "Raise signal X" is explicit.

**Calls are named where they happen**, so a reader can find what runs by searching for it. Dispatch through a computed name - `handlers["on_" + event]`, `getattr(self, name)`, reflection, monkey-patching - hides the call from a search. Where the set of cases is known, name each one in a `switch` or `match`. An event with a single listener, or a hook, decorator or higher-order wrapper of your own with a single user, is an abstraction built too early: make the call - unless it keeps the emitter's module from depending on the listener's.

### Comments

Comments should be rare, as they are outdated the moment they are written. The intent of code should be obvious: make it explicit with well-named helper functions before writing one. Only if that fails, and a future reader would have trouble understanding the intent, add a comment. Reluctantly.

### Language

Code is in English. Identifiers, test names, comments and commit messages are English whatever language the domain speaks, and whatever language `UBIQUITOUS_LANGUAGE.md` is written in. The glossary is where the two meet: its entries stand in the domain language and each carries the English identifier the code uses, so `Vertrag` in the user's mouth is `Contract` in the source.

Where an entry says its term has no English equivalent - a legal or regulatory word that does not translate - the domain term is the identifier, verb or noun alike, in the glossary's canonical form rather than re-inflected for the call site, transliterated to ASCII (`ä`, `ö`, `ü` and `ß` become `ae`, `oe`, `ue` and `ss`) and cased like any other name here, with everything around it that the entry does not cover staying English.

An entry with no English identifier that does not explicitly say its term has no English equivalent is just missing its translation. Ask the user for the correct term, do not invent one.

### Dependencies

When adding a dependency, do not rely on your training data - it is almost always stale. Before adding it, check the registry for the package name, which you might misremember, and look the latest stable release up.

### No Dead Code

Code that is not used anywhere outside of its tests should not be in the repository - down to a parameter, a field, an option, or a branch no input reaches. Note what only _looks_ dead but is live: dynamic or reflective access, DI registration, string-referenced routes, config and env, framework entry points, a parameter a signature it must match requires, a field in a stored or wire format, an exhaustiveness assertion, and exported API consumed from outside this repo - an exported symbol with no internal caller is not dead.

### Architecture Decisions

A record is rare. Write one only when a later change made without it would harm the project - by undoing or re-deciding this choice without a fact or argument the code cannot carry - and no comment, test or structure in the code can guard against that. Harm means concrete damage: lost data, broken operations, a costly mistake repeated. Taste, style and tidiness are not harm.

It takes one of two shapes:

- **Looks wrong, and fixing it does damage.** A competent developer or agent reading the code would take the choice for a mistake and "fix" it, or add the obvious missing piece - a cache, an ORM, a volume - and doing so would cause harm. Uploaded files stored in Postgres rather than on a volume, because only the database is backed up, is one.
- **Contested, and will be re-proposed.** Harm, plus at least two of: the person argued it out themselves - an agent listing options and the person agreeing does not count; the losing option is likely to be proposed again; the winning reasons are specific to this project, not general best practice.

Not a record:

- What the code, schema or glossary already shows, even a domain model that took real thought.
- A surprising choice confined to one place. It gets a comment there.
- A design guideline for the change in front of you, such as "one writer per file". If it still holds later, the next design rediscovers it; if it does not, it should be free to drop it without overruling anything.
- A big, expensive choice that looks normal - Postgres, an ORM - unless it is contested as above.
- Anything a test or the structure can enforce. Enforce it instead.

When unsure, mention it in one line in the plan and write nothing unless the person says yes.

**Never write one unilaterally.** Put the decision and a recommendation to the person, and write the record only once they have said yes.
