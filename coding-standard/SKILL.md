---
name: coding-standard
description: The code-quality standard this project holds code to - simplicity, structure, clarity, concurrency, cost, accessibility, tests, security, dependencies. Read it before writing or changing any code, and before reviewing any; it is the standard itself, not the act of building or reviewing.
---

# Coding Standard

These are the standards this project holds code to. They apply whenever code is written - under a ticket or not - and whenever code is reviewed, and every skill that touches code reads this file rather than restating the rules.

How a change should be *shaped* - what the domain calls things, where the seams are, what deserves an architectural decision - is `coding-conventions`, read while the change is being planned rather than while it is being typed.

**They supplement your own judgment; they do not bound it.** Apply everything you already know about good code. The rules below sharpen focus on things that are easy to miss or where this project has a specific preference. Never excuse a problem you would otherwise catch just because no rule here names it.

Each rule states a property the code should have. Whoever reads it supplies the verb: when writing, build to the property; when reviewing, treat code that lacks it as a problem to raise.

## Simple design

Apply Kent Beck's four rules of simple design, in priority order:

1. **Correct behavior comes first** (Beck's "passes the tests"). The code must actually do what it is meant to - that is paramount. Tests are how you verify it and must exist, but a green suite is evidence, not the goal: a test can pass while it, or the code, pins the wrong behavior.
2. **Reveals intention.** Names and structure make the purpose obvious to the next reader.
3. **No duplication.** Each piece of knowledge has one representation.
4. **Fewest elements.** No classes, methods, or abstractions beyond what the first three rules require.

- **YAGNI.** Minimum code that solves the problem, nothing speculative, in the simplest and most boring version that works - prefer the conventional solution over the clever one. Speculative generality - code added for an imagined future need - does not belong in the codebase. (Tests of spec-mandated behavior are not YAGNI candidates - write them even when the production logic looks trivial.)
- **KISS.** Prefer the simplest thing that works. Needless complexity does not belong even when nothing is speculative - an abstraction where a function would do, convoluted control flow, a clever construct where plain code reads better.
- **Duplication is justified or removed.** Two copies that will change for the same reason belong in one place. Duplication is acceptable only when the copies will change for *different* reasons - then prefer it over the wrong abstraction.
- **No dead code.** Unreachable or unreferenced code should not exist. Note what only *looks* dead but is live: dynamic/reflective access, DI registration, string-referenced routes/config/env, framework entry points, and exported API consumed from outside this repo (an exported symbol with no internal caller is not dead).

## Structure and locality

Code that changes together should live close together - same file, then same module, then same directory. Having to jump between distant locations to follow one piece of logic is a smell; the further the jump, the worse it is.

- **Feature-based modules.** Combine a feature's code into the same module, each feature in its own directory or file, rather than splitting by type (all controllers in one directory, all models in another).
- **Co-locate tests.** Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.
- **Reads top to bottom** (the stepdown rule / newspaper metaphor). Files open with the abstract idea and grow concrete; a helper sits below its caller, so a reader meets a function before its details.
- **Indirection pays for itself** (deep modules, not shallow ones). A boundary earns its place only if a caller can use it correctly without understanding what's behind it. A boundary you have to see through anyway does not - a wrapper that relays the same vocabulary and shape it received, a delegate-only class, a hop that adds a name but no meaning. Thinness isn't the defect; a boundary that spares the caller nothing is.

## Clarity and least astonishment

- **Intent is obvious.** No gap between what the code says and what it does. Names are descriptive, and the wider a name's scope the more descriptive it should be (`i` is fine for a loop index, not for a function). A name should also be distinct enough to search on - avoid generic identifiers (`data`, `info`, `handle`, `process`, `manager`, `util`) for anything with wider scope, so grepping the name finds the concept and little else.
- **Comments stand on their own.** A comment explains the code to someone who has only the code, so it carries no pointer into a process artifact - `SPEC.md`, a ticket, "see US-4". Such a pointer costs a jump and outlives what it points at: specs and tickets are deleted once the work is accepted, so a comment leaning on one is a comment that will stop making sense. Test what the comment actually carries: *would a reader who doesn't know that story change this code wrongly without it?* If yes, the knowledge belongs here - as a name, a type, or a test case where code can hold it, otherwise as a comment restating the rule or the reason in your own words. If no, the comment records how the code came to be; delete it and leave that to git history.
- **Least astonishment.** Behavior matches the contract a caller infers from the name, signature, and type *before* reading the body. Hidden surprises break this: a query that mutates (a `get`/`is`/pure-looking call with side effects), error handling that diverges from its siblings (one throws where the next returns null for the same condition), a parameter or default whose effect contradicts its name. The test is a wrong assumption a caller would make and how it breaks, not a matter of taste.
- **Reuse the established vocabulary.** Use the term already in use for a concept rather than coining a synonym. If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, names in code, tests, and comments should match the identifiers it documents; coining a synonym for a concept the glossary already defines violates this.
- **Code is English.** Identifiers, test names, comments and commit messages are English whatever language the domain speaks, and whatever language `UBIQUITOUS_LANGUAGE.md` is written in. The glossary is where the two meet: its entries stand in the domain language and each carries the English identifier the code uses, so `Vertrag` in the user's mouth is `Contract` in the source. Where an entry says its term has no English equivalent - a legal or regulatory word that does not translate - the domain term is the identifier, verb or noun alike, in the glossary's canonical form rather than re-inflected for the call site, transliterated to ASCII (`ä`, `ö`, `ü` and `ß` become `ae`, `oe`, `ue` and `ss`) and cased like any other name here, with everything around it that the entry does not cover staying English. An entry that is merely missing its identifier says nothing of the kind - it is unfilled, and unfilled is not a claim in either direction. Repair it rather than read it: the entry gains the English identifier, or the statement that there is none. Which of those it wants is a question about the domain and not a judgement to make in passing, so where you cannot tell, ask rather than coin one - an invented English identifier is worse than none, because it reads ever after as the name the code should use. A concept the glossary does not carry at all is the same - a gap in the glossary, not a licence to name it in the domain language. The rule binds the names a change writes or changes - renaming is writing a name, moving code without touching its name is not - so a name, comment or message already in the tree is not made wrong by this rule - nor, where its only defect is standing in the domain language, by the one above it, which otherwise keeps its full force over code that already exists. Where the two disagree about something a change is writing, this one wins: a new English name beside domain-language siblings is not the coined synonym that rule forbids, it is the gap between them, and the glossary is where that gets recorded.
- **Fail loud, not silent.** When a broken invariant is first detectable, prefer an explicit error or assertion over a silent fallback that masks it. A wrong result that looks fine is worse than a loud failure.
- **A failure someone must act on is visible from outside the process.** Failing loud only counts as loud if it reaches someone. When code catches an error, takes a fallback, or drops work, that fact is recorded with enough context to identify the request or the record - and without the credentials or personal data that caused it. Silence should mean nothing went wrong, not that nothing was written down.

## Concurrency and shared state

Code that reads correctly from top to bottom can still be wrong, because it does not run alone. Two requests, two tabs, a double-clicked button, a retried webhook, two branches of a `Promise.all` - each is a second execution interleaved with the first, and the defect lives in the gap between two lines that look adjacent.

- **A decision made from a value you loaded is stale by the time you act on it.** Read a balance, check it, write it back, and two concurrent runs both decide from the same load - one write is lost. "Does this exist? No - create it" is the same bug: the row appears in the gap. Push the decision down to where the data is - a conditional update, a unique constraint, `SET n = n + 1`, a transaction at an isolation level you chose on purpose - rather than holding it in application memory across an `await`.
- **Anything the network can retry will arrive twice.** A webhook, a queue message, a resubmitted form, a client that timed out and tried again. Give the effect a key the second arrival collides with, so it becomes a no-op instead of a second charge.
- **No mutable state outside a request.** A module-level cache, counter, or accumulator is shared by every request the process handles at once - and in a serverless runtime it survives between them too, so one user's data reaches the next. State belongs in the request or in the store.
- **Every wait has a timeout, and whatever started an effect cancels it.** A call with no timeout is a hang with extra steps. An interval, subscription, or in-flight request still running after its component unmounted or its request ended is writing into something that is gone.

## Cost at scale

The diff shows one pass over one row. What it costs depends on how many rows there are, and that number is not in the diff.

This is not licence to optimise ahead of a measurement - KISS and YAGNI still hold, and a clever fast version of something nobody has measured is its own defect. These are the two cases where the cost follows from the shape of the code plus a number you can go and look up.

- **A query inside a loop is one query.** Fetch a list, then fetch each item's related row, and you have the N+1 that the data-access seam actively invites - a domain-named query per entity is exactly what it asks you to write. Fetch the set in one query and join or group in memory.
- **Every query has a bound and an index.** A list endpoint with no limit is fine on the developer's fifty rows and an outage at a hundred thousand; a filter or sort over an unindexed column is the same surprise in a different shape. Check both against what the table will hold, not what it holds today.

## Accessibility

A visual check never fails on any of this - it has to be driven. And what judgment catches unprompted, a missing `alt` or a `div` wired up as a button, is not what actually locks someone out.

- **Everything reachable by mouse is reachable by keyboard, and you can see where you are.** Tab through the change: focus order follows the visual order, focus is visible at every stop, a dialog holds focus while it is open and hands it back to the trigger on close, and nothing behind an overlay is still tabbable.
- **Content that arrives without a page load announces itself.** A validation error, a toast, a result that finished loading - anything a sighted user notices because it appeared - needs a live region or focus moved into it, or for a screen reader it did not happen.
- **Colour is not the only signal, and contrast is a number.** An error shown only in red, a required field marked only by colour, or body text sitting at 3:1 fails a reader who cannot separate the two. Check the pair of values, in each theme the project ships, rather than the impression.

## Changing what already runs

A new file is judged against the spec. Everything else is judged against what is already deployed, already stored, and already calling it - none of which appears in the diff.

- **A migration runs against data that exists, while the old code is still serving.** Add a column nullable or defaulted before anything writes it; backfill as its own step; drop a column only once nothing reads it, which is a later deploy and not this one. Adding a constraint or rewriting a large table takes a lock - know for how long before it meets production rows.
- **Deploy order is part of the design.** For the length of a rollout, old code runs against the new schema and new code against the old one. A change that is only correct once both halves have landed is two changes, and the order they land in is a decision worth recording.
- **A change is reversible, or its irreversibility is a decision.** Reverting code is cheap; reverting a dropped column is not. Say which one this is before it ships, rather than discovering it during the incident.
- **The stored and published shape is a contract.** A serialised payload, a JSON column, a cache key, a queue message, a URL, an exported type - anything one version writes and another reads cannot change shape until the reader tolerates both.
- **New configuration has a safe default, or fails at startup.** An environment variable the code needs and the deployment doesn't set should stop the process with its own name in the message, not surface as `undefined` three layers in. A flag gating new behavior is off until someone turns it on.

## Test coverage

- **Every piece of business logic is pinned by a test:** removing or changing it would make a test fail. For each piece, you should be able to name the test that pins it; if you can't, that's a coverage gap.
- **The test observes the behavior, not the call.** Failing when the behavior is removed is necessary, not sufficient. A test asserting that a mock was called does fail when you delete the call - and still says nothing about what the code computes, so it pins the wiring and leaves the logic free. Assert on what the code produces: the value returned, the state changed, the row written, the output rendered. A test that merely restates the implementation - the arguments a collaborator was handed, the order two internal steps ran in - moves with the code instead of holding it still, and does not close a coverage gap.
- **The edges of the input range are pinned too.** The happy path runs on the value someone had in mind; the behavior has to be right on the boundaries around it, and those come from a list rather than from inspiration. Walk it against what this code takes in: empty and absent (not the same thing), zero, one, negative, the largest input that is realistic rather than the largest that is possible, the value on each side of every comparison, a duplicate, and - where the domain has them - non-ASCII text, a timezone or DST boundary, and money that will not survive a float. An entry that means something here and that the code has never seen is either a missing test or a defect.
- **The failure paths are pinned too.** What the code does when things go wrong is business logic: the rejected input, the failed call, the missing record, the conflicting write. A suite that only walks the happy path leaves the branches that run on the worst day as the only ones nobody has executed. Where the code cleans up, retries, or rolls back on failure, a test drives it there.
- **External adapters** - the thin edge that talks to a third-party SDK, the network, or IO - may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested.

## Security

These hold even when the spec doesn't name them.

- **Every internet-reachable endpoint enforces authentication and authorization.**
- **Authorization is checked against the object, not just the route.** Authentication establishes who is calling, and a route guard that they may call this endpoint; neither says they may touch *this record*. Every id arriving in a path, body, or query is a claim about ownership until the server checks it, and the check belongs inside the query (`where: { id, ownerId: session.userId }`) rather than after the fetch, where forgetting it returns the data anyway. The attacker here holds a valid session and is changing the number.
- User input is validated at each trust boundary **and escaped where it is used** - HTML-escaped when rendered, parameterised when it reaches SQL, quoted when it reaches a shell, a path, or a URL. Validation constrains shape; it is the escaping at the point of use that prevents injection, and a value that passed a schema is not thereby safe to interpolate. Sanitising on the way in - stripping or rewriting the value to look harmless - is the weaker habit: it corrupts legitimate input and still misses the context it wasn't written for.

## Dependencies

- **The dependency is warranted.** A direct dependency is a standing cost - its updates, its advisories, its transitive tree, its eventual abandonment. Prefer the standard library, or twenty lines of your own, over a package that saves five.
- **The package is real, and you looked.** Check the registry before adding it. A plausible name with exactly the API you wanted and no registry entry is a hallucination; one that does exist under a name you half-remembered is worse, because that is where typosquats live. This holds for a package you were told to use as much as for one you thought of.
- **It is at its current latest stable release** (or latest LTS line, where the ecosystem distinguishes one). Look the version up rather than relying on memory - memory is almost always stale.
- **It carries no known advisory, under a licence this project can use.** Run the ecosystem's audit (`npm audit`, `pip-audit`, `cargo audit`) after adding it, and read the licence rather than assuming MIT. Neither is knowable from memory; both are one command away.
