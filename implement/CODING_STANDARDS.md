# Coding Standards

What good software looks like. Any software project is held to this standard.

Where this conflicts with your general habits or training, this wins - many of its rules exist precisely to overrule them. A project's existing convention overrides a rule here only where the rule says so. Where nothing here speaks to a question, use your own judgement.

Two principles run through every property below:

- **YAGNI.** Only build and keep what is actually needed now, not in an imagined future.
- **KISS.** Prefer the simplest thing that works over "clever" designs or needless optimization.

They never justify less than correct or secure code.

You are looking for four properties. Check them in order; where two pull against each other, the earlier one wins.

- Correctness
- Security
- Usability
- Maintainability

## Correctness

Does the code do what it is supposed to do?

What that is may have to be derived first, from the ticket, the callers, the domain, and it is checked for the general case _and_ the edge cases.

Code should also be obvious in what it is meant to do. If you have to guess, or if the context points in another direction than the code would hint, that's a flag.

### Test Coverage

**Every piece of business logic is pinned by a test:** removing or changing it would make a test fail. For each piece, you should be able to name the test that pins it; where you cannot, that is a coverage gap.

**Coverage is never lost.** A test deleted, renamed away or weakened - an assertion loosened, a case dropped, two suites merged into one that covers less - unpins what it pinned. Merging is where this hides, because it reads as tidying.

**Every change is one of two kinds, and each has its own proof** - down to the three-line one.

- **It changes behaviour:** a failing test first, watched fail for the reason you expect.
- **It keeps behaviour** - a refactor, a split, a move, a rename, deleting dead code: the suite is green before and after, and no test changes except to follow a moved or renamed name. Where no test covers the code it touches, pin it with one first - green proves only what the suite covers.

Never mix the two in one step.

**Use TDD.** Red, green, refactor, in the smallest steps that make sense. Each phase is a separate test run. Writing the test and the code and then running once is not TDD even when the artifacts end up identical, because the RED run is the only thing that proves the test exercises the behaviour.

1. **RED.** One trivially small failing test for the next bit of behaviour. Run it, and confirm **the assertion fires and reports an expected/actual mismatch**. "Module not found", an import error or a syntax error is not RED - it only proves the test could not run. If the test passes immediately, find out why. Where the behaviour was already there before this session, the test is coverage: keep it and pick the next behaviour. Where it passes because of code you wrote earlier in this session, you wrote the code first: revert that code, get the failure, re-implement.
2. **GREEN.** The simplest change that could possibly work. Faking the answer with a constant is fine; the next test forces the general case. If you cannot see a small change that passes, the test is too big - revert and write a smaller one.
3. **REFACTOR.** Tests green, no new behaviour, remove duplication. Most cycles this is empty. Do not manufacture work to fill it.

**The test observes the behavior, not the call.** Failing when the behavior is removed is necessary, not sufficient. A test asserting that a mock was called does fail when you delete the call. Assert on what the code produces: the value returned, the state changed, the row written, the output rendered. A test that merely restates the implementation - the arguments a collaborator was handed, the order two internal steps ran in - moves with the code instead of holding it still, and does not close a coverage gap.

**The edges of the input range are pinned too.** The happy path runs on the value someone had in mind; the behavior has to be right on the boundaries around it, and those come from a list rather than from inspiration. Walk it against what this code takes in: empty and absent (not the same thing), zero, one, negative, the largest input that is realistic rather than the largest that is possible, the value on each side of every comparison, a duplicate, and - where the domain has them - non-ASCII text, a timezone or DST boundary, and money that will not survive a float. An entry that means something here and that the code has never seen is either a missing test or a defect.

**The failure paths are pinned too.** What the code does when things go wrong is business logic: the rejected input, the failed call, the missing record, the conflicting write. Where the code cleans up, retries, or rolls back on failure, a test drives it there.

**External adapters** - the thin edge that talks to a third-party SDK, the network, or IO - may be untested when they genuinely can't be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (just the calls you need, no logic), mock that adapter to test everything behind it, and accept the adapter itself going untested.

**The suite runs with one command, fast and the same every time.** Declare it in `CLAUDE.md`, on a line of its own: ``Check: `npm run check` ``. It builds, type-checks, lints, tests and runs the structural checks, exiting non-zero on any failure. It runs everything the CI workflow gates on, so green here is green there, and the pre-commit hook and CI run this same command. A flaky test teaches the agent to ignore failures: fix it or delete it, never retry it until it passes.

**The app starts the same way for every agent.** Where it has something to see or drive, how to start it is written where the next agent looks first - a `run` skill, the README or CLAUDE.md - with any script it needs beside it in the repository.

### Concurrency and Shared State

Code does not run alone. Two requests, a double-clicked button, a retried webhook - each is a second execution interleaved with the first, and the defect lives in the gap between two lines that look adjacent.

- **A decision made from a value you loaded is stale by the time you act on it.** Read a balance, check it, write it back, and two concurrent runs both decide from the same load - one write is lost. "Does this exist? No - create it" is the same bug: the row appears in the gap. Push the decision down to where the data is - a conditional update, a unique constraint, `SET n = n + 1`, a transaction at an isolation level you chose on purpose - rather than holding it in application memory across an `await`.
- **No mutable state outside a request.** A module-level cache, counter, or accumulator is shared by every request the process handles at once - and in a serverless runtime it survives between them too, so one user's data reaches the next. State belongs in the request or in the store.

### Changing What Already Runs

A new file is judged against the spec. Everything else is judged against what is already deployed and already stored, neither of which appears in the diff.

- **Deploy order is part of the design.** For the length of a rollout, old code runs against the new schema and new code against the old one. A change that is only correct once both halves have landed is two changes, and the order they land in is a decision.
- **A column is dropped only once nothing reads it**, which is a later deploy and not this one. Add a column nullable or defaulted before anything writes it, and backfill as its own step.

## Security

Assume a malicious user. Can they see what they should not see, or do things they should not be able to do?

Be especially wary when it comes to personally identifiable information.

**Authorization is checked against the object, not just the route.** Authentication establishes who is calling, and a route guard that they may call this endpoint; neither says they may touch _this record_. Every id arriving in a path, body, or query is a claim about ownership until the server checks it, and the check belongs inside the query (`where: { id, ownerId: session.userId }`) rather than after the fetch, where forgetting it returns the data anyway. The attacker here holds a valid session and is changing the number.

**Input never becomes code.** A query, shell command, file path or HTML built by gluing in a value from outside lets that value rewrite it. Pass it as a parameter, an argument list, an escaped value, or a path checked to stay inside its root.

**A check is never turned off to make something work.** Disabling TLS verification, CSRF protection or an auth guard, opening CORS to `*`, or putting a secret into code or a log makes the error go away by removing the protection it reported. Find the cause instead; secrets come from the environment or the secret store.

## Usability

The goal of any software is to be usable by the user. Does the software support the main workflows smoothly? Can all buttons be used on all supported screen sizes, are all texts large enough to be read, are texts cut off? Does longer or shorter than usual text break the display?

### Ubiquitous Language

`UBIQUITOUS_LANGUAGE.md`, where the project keeps one, is the source of truth for the domain's names. If a concept has a name in there already, use it before inventing your own. If a concept is new, confirm with the user what it is called in the domain and add it there before using it.

This is true both for the user interface as well as the code. Any given concept has a single name in the code base, at every level from UI to storage.

### Actionable Error Messages

An error message tells whoever reads it what to do next. It names what went wrong in their terms, the value that caused it, and the move that fixes it: "Invoice date 2026-13-01 is not a valid date, use YYYY-MM-DD", not "Invalid input". "Something went wrong" is acceptable only for the rare failure nobody can act on, as under _Sufficient Reliability_.

The reader decides the wording. An end user gets the domain's words and no stack trace, table name or internal id - those are for the log, and showing them is a leak. A developer calling a function or running a command gets the parameter, the constraint it broke and the value it received. An error that reliably leads its reader to the wrong move is a defect.

### Sufficient Efficiency

The software has to be fast enough to be usable. Past that point, speed does not justify code that is harder to read. An improvement that costs nothing in clarity is not an optimization, and needs no measurement.

**No optimization without measuring twice:** before, that the software is not fast enough, and after, that the change made it fast enough - code that only looks faster is not a win. Two costs are the exception, because they follow from the shape of the code plus a number you can go and look up: a query inside a loop, and a query with no bound or no index on what it filters or sorts.

### Sufficient Reliability

Outside of the happy path, software fails gracefully. But the less likely a failure path is, the less graceful it needs to be. A regular error case might need automatic retries and a well-phrased error display. A rare, unusual error might do with an "an error occurred, try again" popup.

### Fail Loudly Inside

Graceful failure is for the user, at the edge. Inside the code, a case that should not happen is not handled - it is reported.

- **No silent fallback.** `?? []`, a default for missing config, a `catch` that logs and returns `null`: each turns a crash at the cause into a wrong result far away from it.
- **Catch only what you handle.** A `catch` that cannot do anything useful lets the error through.
- **Check where data enters, trust it after.** Validation belongs at the boundary, as under _Business Logic Works with Domain Objects_, not repeated defensively in every function.
- **Report it once, where it is handled,** with the values that caused it - ids, input, the unexpected state - and no PII or secrets, so the next agent can get from the symptom to the line without guessing.

## Maintainability

Finally, software is written to be maintained and extended in the future - by a coding agent, not a human. Write for what that reader is:

- **It starts cold.** Nothing it learned last session carries over; what it needs is in the code, its names and its comments.
- **It finds by searching.** What a search does not return, it does not know exists.
- **It reads in pieces.** What it cannot hold at once, it judges from a part.
- **It copies what is near.** The pattern in the next file is the one it will repeat.
- **It trusts what it sees.** A misleading name or a stale comment is followed, not doubted.

The test: when a bug is reported, can its location be found quickly? When a change is asked for, can it be added without missing anything?

### One Way to Do Each Thing

The next agent repeats the nearest example. Two ways of doing the same thing - two error styles, two HTTP clients, two test helpers - get a random mix and then a third.

- **Search before you write.** Before writing a function, type, constant or rule, search for one that already does it - by its domain word and by its shape.
- **Follow the existing way,** even where you would have chosen another, and report it: "I wanted to do X, but the codebase does Y, so I did Y."
- **A new way replaces the old one** everywhere, in its own change that keeps behaviour, or it is not introduced. Moving code over only as it is touched does not replace the old way.
- **Where two ways already exist,** use the one most of the code uses.

A review reports each of these: a change that strays from the existing way, a new way that leaves the old one standing, and every place where two ways already exist.

### What Changes Together, Stays Together

If different pieces of code change together, they should be located together, so that when one changes the other is visible.

The more tightly they change together, the closer they should be together.

If two pieces of code are similar and always change the same, they should be unified. If two pieces of code look similar, but will change for different reasons, the duplication is useful. Prefer duplication over the wrong abstraction.

Directories and modules should therefore group code by feature. Prefer this over splitting by type, for example having all controllers in one directory and all models in another.

Features nest. A feature made of more than one source file gets its own subdirectory, so that a task naming a feature names the directory too.

- **Check** whenever a file is added to a directory: do the directory's files, the new one included, belong to features that change for different reasons?
- **Move** a feature into its own subdirectory as soon as it has two source files, together with their tests. A feature of a single file stays where it is, and so does a directory that is all one feature.
- **Name** the subdirectory after the feature, using its term from `UBIQUITOUS_LANGUAGE.md`. Where the glossary has none, ask the user for it and add it there; a missing name is never a reason to leave the split out. A grab-bag name (`utils`, `common`, `helpers`) or a type name (`models`, `controllers`) is not a split.
- **The split comes first,** only moves files, and changes no behaviour.

Put a test next to the file it tests, not in a separate `tests/` tree - unless the project's existing layout clearly says otherwise.

### Files Small Enough to Read Whole

An agent should be able to read a file whole. So **before adding code to a file of more than about 500 lines, split it.**

- **Size** counts what has to be read together: the file plus any fixture or helper file that only it uses.
- **Adding** is any change that does more than remove code.
- **No side-stepping.** Putting new code in a fresh file to keep this one under the limit still counts as adding to it, when the new code changes together with code here. Split first, then add to the part it belongs to.
- **Split** along what changes together, into files of roughly 150-300 lines that each hold one part. Splitting a source file always splits its test file the same way, and a test file is never split on its own: each part has exactly one test file.
- **When only the test file is over the limit,** shorten it first: shared setup, table-driven cases, helpers for repeated assertions. That is enough only if it gets the file to about 400 lines - one squeezed to just under 500 has to be shortened again on every change. Otherwise the source holds more than one part: split source and tests together, even though the source is under the limit.
- **The split comes first,** changes no behaviour, and is not mixed into the change.
- Generated files are exempt.

### Function and Method Names Follow Domain Actions

When users talk about "publishing a blog post" or "archiving it", the respective functions should be `publishPost` and `archivePost` - not `updatePost`, even though both end as a database `UPDATE`. When they talk about "setting an article's category", it should be `setArticleCategory`; when they talk about "saving an article", it should be `saveArticle`, with the argument a compound object of everything the users mean by "the article" in this context - which could contain the category.

A name is specific enough that searching for it finds its definition and its uses, and little else. `data`, `info`, `handle`, `process`, `Manager`, `utils.ts` match everything and so locate nothing; name what the thing is in this domain instead.

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

**Calls are named where they happen**, so a reader can find what runs by searching for it.

- **Not allowed:** dispatch through a computed name (`handlers["on_" + event]`, `getattr(self, name)`), reflection, monkey-patching, implicit registration, introspection. Where the set of cases is known, name each one in a `switch` or `match`.
- **Allowed:** callbacks and raised signals - they name what they hand over - and whatever a framework requires: its decorators, DI registration and entry points.
- **Built too early:** an event with a single listener, or a hook, decorator or wrapper of your own with a single user. Make the call - unless it keeps the emitter's module from depending on the listener's.

### The Compiler Checks First

Put every rule you can where the compiler enforces it.

- **Turn on the strictest checking** the language and project allow.
- **No escape hatches:** no `any`, unchecked cast, `# type: ignore` or `!` without a comment saying why it is safe.
- **Structural rules are checks too.** A rule about where code lives or what may use what - which directory may import which, where the clock is read, how a file is named - is a check the check command runs, added in the change that introduces the rule. A rule written into `CLAUDE.md` comes with its check in the same commit. Where code breaks the rule today, the check reads a list of those breaks, which only shrinks.
- **Make invalid states unrepresentable.** A union of the real cases, not a bag of optional fields and a status string.
- **Exhaustive matches.** A `switch` or `match` over a known set has no `default` that swallows the next case added.

### Fields Listed Once

Code that has to cover every field of a domain object - equality, a merge or sum, a copy, a column list, a mapping to storage or the wire - is a second definition of the type: the next field added has to be added there too, and nothing says so.

- Keep it beside the type, as a function the rest of the code calls, rather than repeating the list where it is needed. Derive it only where the language does so plainly (`#[derive(PartialEq)]`, a dataclass's `__eq__`).
- Where the list has to stand on its own - SQL, a wire format - make a forgotten field fail: a compiler check of completeness (in TypeScript, `satisfies Record<keyof T, …>`) or a test that goes through every field.
- Where it leaves fields out on purpose - equality that ignores `id` - name the fields it leaves out, so a new field has to go on one side or the other.
- Code that picks a few fields for its own purpose, such as a view showing three of them, is not such a list.

### Comments

Make intent obvious from the code first: a better name, a well-named helper. Comments that restate the code are noise.

A comment describes the code as it is now. It never names a ticket, slice, story or change, or what the code used to do.

A comment is required where the code alone would lead the next reader to change it wrongly:

- it looks dead but is used from outside the code - config, a string route, reflection, a caller outside this repo
- it looks wrong or roundabout on purpose - an external quirk, a rejected simpler version
- its correctness depends on something elsewhere - a deploy order, a lock, an invariant upheld by another module

A change that touches commented code keeps the comment true, in the same change.

### Language

Code is in English, whatever language the domain or `UBIQUITOUS_LANGUAGE.md` uses: identifiers, test names, comments, commit messages. Use the identifier the glossary entry gives, exactly - `Vertrag` in the user's mouth is `Contract` in the source, and an untranslatable term carries its own ASCII form there. Where an entry has no identifier, ask the user; do not invent one.

### Dependencies

When adding a dependency, check the registry rather than your training data, which is almost always stale: that the name you remember is right, the current stable release, and that the package is still maintained - an unmaintained one is not used.

### No Dead Code

Remove code that nothing but its tests uses - down to a single parameter, field or option, and any branch no input reaches.

When a change removes a use of something - a call to a function, an import of a module, a read of a field - check whether anything else still uses it, and remove it if nothing does. The code left unused is outside the changed lines, so the diff will not point to it.

Code can look dead and still be live. Keep it when it is:

- accessed dynamically or by reflection
- registered for dependency injection
- a route referenced by a string
- named in config or an environment variable
- a framework entry point
- a parameter that a signature it has to match requires
- a field in a stored or wire format
- an exhaustiveness assertion
- exported API used outside this repo, even with no caller inside it
