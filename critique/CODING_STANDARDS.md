# Coding Standards

What good software looks like. Every software project is held to this standard.

If this conflicts with your general habits or training, this wins; many of its rules exist to overrule them. A project's existing convention overrides a rule here only if the rule says so. If nothing here covers a question, use your own judgement.

Two principles apply to every property below:

- **YAGNI.** Only build and keep what is actually needed now, not in an imagined future.
- **KISS.** Prefer the simplest thing that works over "clever" designs or needless optimization.

They never justify code that is less than correct or secure.

Code is held to four properties. Check them in this order. If two pull against each other, the earlier one wins.

- Correctness
- Security
- Usability
- Maintainability

## Correctness

Does the code do what it is supposed to do? You may have to work that out first, from the ticket, the callers, the domain. Check it for the general case _and_ the edge cases.

It is obvious from the code what it is meant to do. If you have to guess, or the context points somewhere other than the code does, that is a defect.

**A fix goes where the cause is.** A defect shows in one place and is caused in another: duplicate rows in a list come from the query that joins them, not from the list. Find the cause before changing anything - for a regression, run `git bisect run` with the failing test - and fix it there. A fix where the symptom shows needs a comment naming the cause and why it cannot be fixed there.

### Test Coverage

**Every piece of business logic is pinned by a test:** removing or changing it makes a test fail. For each piece, you can name the test that pins it. If you cannot, that is a coverage gap.

**Coverage is never lost.** Deleting, renaming away or weakening a test - loosening an assertion, dropping a case, merging two suites into one that covers less - unpins what it pinned. Merging is where this hides, because it reads as tidying.

**Every change is one of two kinds, and each has its own proof**, down to a three-line change.

- **It changes behaviour:** first a failing test, watched fail for the reason you expect.
- **It keeps behaviour** - a refactor, a split, a move, a rename, deleting dead code: the suite is green before and after, and no test changes except to follow a moved or renamed name. If no test covers the code it touches, first pin that code with a test; green proves only what the suite covers.

Never mix the two in one step.

**Use TDD.** Red, green, refactor, in the smallest steps that make sense. Each phase is a separate test run. Writing the test and the code and then running once is not TDD, even if the files end up identical: only the RED run proves that the test exercises the behaviour.

1. **RED.** Write one trivially small failing test for the next bit of behaviour. Run it, and confirm that **the assertion fires and reports an expected/actual mismatch**. "Module not found", an import error or a syntax error is not RED; it only proves the test could not run. If the test passes immediately, find out why. If the behaviour existed before this session, the test is coverage: keep it and pick the next behaviour. If it passes because of code you wrote earlier in this session, you wrote the code first: revert that code, get the failure, and implement it again.
2. **GREEN.** Make the simplest change that could possibly work. Faking the answer with a constant is fine; the next test forces the general case. If you cannot see a small change that passes, the test is too big: revert and write a smaller one.
3. **REFACTOR.** With the tests green, remove duplication without adding behaviour. Usually there is nothing to do. Do not invent work to fill this step.

**The test observes the behaviour, not the call.** Failing when the behaviour is removed is necessary, not sufficient: a test asserting that a mock was called does fail when the call is deleted. Assert on what the code produces: the value returned, the state changed, the row written, the output rendered. A test that restates the implementation - the arguments a collaborator was handed, the order of two internal steps - does not close a coverage gap.

**The edges of the input range are pinned too.** The happy path runs on the value someone had in mind; the behaviour has to be right on the boundaries around it. Take them from this list, not from inspiration, and walk it against what this code takes in: empty and absent (not the same thing), zero, one, negative, the largest input that is realistic rather than the largest that is possible, the value on each side of every comparison, a duplicate, and - if the domain has them - non-ASCII text, a timezone or DST boundary, and money that will not survive a float. An entry that means something here and that the code has never seen is either a missing test or a defect.

**The failure paths are pinned too.** What the code does when things go wrong is business logic: the rejected input, the failed call, the missing record, the conflicting write. If the code cleans up, retries or rolls back on failure, a test drives it there.

**External adapters** - the thin edge that talks to a third-party SDK, the network or IO - may go untested if they genuinely cannot be tested at all. The business logic behind them must be fully tested. Wrap the dependency in the thinnest possible adapter (only the calls you need, no logic), mock that adapter to test everything behind it, and accept that the adapter itself goes untested.

**The suite runs with one command, fast and the same every time.** Declare it in `CLAUDE.md`, on a line of its own, in exactly this form: ``Check: `npm run check` `` - the English word `Check:` at the start of the line, even if the rest of the file is in another language, then the command in backticks and nothing after it. The command builds, type-checks, lints, tests and runs the structural checks, and exits non-zero on any failure. It runs everything the CI workflow gates on, so green here is green there, and the pre-commit hook and CI run this same command. Fix or delete a flaky test; never retry it until it passes, because it teaches the agent to ignore failures.

**The app starts the same way for every agent.** If it has something to see or drive, write how to start it where the next agent looks first - a `run` skill, the README or `CLAUDE.md` - with any script it needs beside it in the repository.

### Concurrency and Shared State

Code does not run alone. Two requests, a double-clicked button and a retried webhook are each a second run interleaved with the first, and the defect sits between two lines that look adjacent.

- **A decision made from a value you loaded is stale by the time you act on it.** Read a balance, check it and write it back, and two concurrent runs both decide from the same read - one write is lost. "Does this exist? No - create it" is the same bug: the row appears in between. Push the decision down to where the data is - a conditional update, a unique constraint, `SET n = n + 1`, a transaction at an isolation level you chose on purpose - rather than holding it in application memory across an `await`.
- **No mutable state outside a request.** A module-level cache, counter or accumulator is shared by every request the process handles at once - and in a serverless runtime it survives between requests too, so one user's data reaches the next. State belongs in the request or in the store.

### Changing What Already Runs

Judge a new file against the spec. Judge everything else against what is already deployed and already stored; neither appears in the diff.

- **Deploy order is part of the design.** During a rollout, old code runs against the new schema and new code against the old one. A change that is only correct once both halves have landed is two changes, and the order they land in is a decision.
- **Drop a column only once nothing reads it**, which is a later deploy, not this one. Add a column nullable or with a default before anything writes it, and backfill as its own step, in batches that never lock the whole table.
- **A stored or wire format changes by addition.** Anything a reader outside this deploy can observe - a field, a column, an error code, an ordering - is depended on. Renaming or reshaping one takes steps, each its own deploy: add the new form, write both, backfill, move the reads, stop writing the old, then remove it.

## Security

Assume a malicious user. Can they see what they should not see, or do what they should not be able to do?

Take particular care with personally identifiable information.

**Authorization is checked against the object, not just the route.** Authentication says who is calling, and a route guard says they may call this endpoint; neither says they may touch _this record_. Every id in a path, body or query is a claim of ownership until the server checks it. Put the check inside the query (`where: { id, ownerId: session.userId }`), not after the fetch, where forgetting it returns the data anyway. The attacker here holds a valid session and is changing the number.

**Input never becomes code.** A query, shell command, file path or HTML built by inserting a value from outside lets that value rewrite it. Pass the value as a parameter, an argument list, an escaped value, or a path checked to stay inside its root.

**Never turn a check off to make something work.** Disabling TLS verification, CSRF protection or an auth guard, opening CORS to `*`, or putting a secret into code or a log makes the error go away by removing the protection that reported it. Find the cause instead. Secrets come from the environment or the secret store.

## Usability

Does the software support the main workflows smoothly? Can every button be used on every supported screen size? Is all text large enough to read, and is any of it cut off? Does text longer or shorter than usual break the display?

### Ubiquitous Language

If the project keeps a `UBIQUITOUS_LANGUAGE.md`, it is the source of truth for the domain's names. If a concept already has a name there, use it before inventing your own.

**Finding a name.** Use the glossary's term; otherwise a word the user already uses for it, in UI text, test names, criteria or commit messages; otherwise a plain description of what it does or holds, in existing words, never a coined term. A name not taken from the glossary is listed in the change's report for the developer to confirm, add to the glossary or replace. It is not asked mid-run, and a missing name is never a reason to leave a split out.

This holds for the user interface and the code alike. Each concept has a single name in the codebase, at every level from UI to storage.

### Actionable Error Messages

An error message tells whoever reads it what to do next. It names what went wrong in their terms, the value that caused it, and the step that fixes it: "Invoice date 2026-13-01 is not a valid date, use YYYY-MM-DD", not "Invalid input". "Something went wrong" is acceptable only for the rare failure nobody can act on, as under _Sufficient Reliability_.

The reader decides the wording. An end user gets the domain's words and no stack trace, table name or internal id - those belong in the log, and showing them is a leak. A developer calling a function or running a command gets the parameter, the constraint it broke and the value it received. An error that reliably leads its reader to the wrong step is a defect.

### Sufficient Efficiency

The software has to be fast enough to be usable. Beyond that, speed does not justify code that is harder to read. An improvement that costs nothing in clarity is not an optimization and needs no measurement.

**No optimization without measuring twice:** before, to show the software is not fast enough, and after, to show the change made it fast enough. Two costs are exceptions, because the shape of the code plus a number you can look up shows them: a query inside a loop, and a query with no bound or no index on what it filters or sorts.

### Sufficient Reliability

Off the happy path, software fails gracefully. The less likely a failure, the less graceful it needs to be. A regular error case may need automatic retries and a well-worded error display. A rare, unusual error may make do with an "an error occurred, try again" popup.

### Fail Loudly Inside

Graceful failure is for the user, at the edge. Inside the code, a case that should not happen is reported, not handled.

- **No silent fallback.** `?? []`, a default for missing config, a `catch` that logs and returns `null`: each turns a crash at the cause into a wrong result far away from it.
- **Catch only what you handle.** If a `catch` cannot do anything useful, let the error through.
- **Check data where it enters, and trust it after.** Validation belongs at the boundary, as under _Business Logic Works with Domain Objects_, not repeated defensively in every function.
- **Report such a case once, where it is handled,** with the values that caused it - ids, input, the unexpected state - and no PII or secrets, so the next agent can get from the symptom to the line without guessing.
- **A log line is an event, not a sentence:** a fixed event name a search finds (`payment_failed`), with the values as fields rather than spliced into text. Every line carries the id of the request or run it belongs to. Set that id where the request or run starts, and pass it across every queue and call. If more than one entry point starts the same work, the line also says which one did.

## Maintainability

Software is written to be maintained and extended in the future, by a coding agent, not a human. Write for that reader:

- **It starts cold.** Nothing it learned last session carries over; what it needs is in the code, its names and its comments.
- **It finds by searching.** What a search does not return, it does not know exists.
- **It reads in pieces.** What it cannot hold at once, it judges from a part.
- **It copies what is near.** The pattern in the next file is the one it will repeat.
- **It trusts what it sees.** It follows a misleading name or a stale comment without doubting it.

The test: when a bug is reported, can its location be found quickly? When a change is asked for, can it be added without missing anything?

**Judge a change by how the code reads afterwards, not by the size of its diff.** Re-indented and moved lines cost nothing; a worse shape chosen to keep the diff small costs every later reader.

### One Way to Do Each Thing

Each thing - an error style, an HTTP client, a test helper - is done one way in the codebase. Two ways get mixed at random, and then a third appears.

- **Search before you write.** Before writing a function, type, constant or rule, search for one that already does it - by its domain word and by its shape.
- **Follow the existing way,** even if you would have chosen another, and report it: "I wanted to do X, but the codebase does Y, so I did Y."
- **A new way replaces the old one** everywhere, in its own change that keeps behaviour, or it is not introduced. Moving code over only as it is touched does not replace the old way.
- **If two ways already exist,** use the one most of the code uses.

A review reports each of these: a change that strays from the existing way, a new way that leaves the old one standing, and every place where two ways already exist.

### What Changes Together, Stays Together

Code that changes together is located together, so that when one piece changes the other is visible. The more tightly pieces change together, the closer together they are.

If two pieces of code are similar and always change the same way, unify them. If they look similar but will change for different reasons, the duplication is useful. Prefer duplication over the wrong abstraction.

So directories and modules group code by feature. Prefer this over splitting by type, such as all controllers in one directory and all models in another.

Features nest. A feature made of more than one source file gets its own subdirectory, so that a task naming a feature names the directory too.

- **Check** whenever a file is added to a directory: do the directory's files, the new one included, belong to features that change for different reasons?
- **Move** a feature into its own subdirectory as soon as it has two source files, together with their tests. A feature of a single file stays where it is, and so does a directory that is all one feature.
- **Name** the subdirectory after the feature, found as _Ubiquitous Language_ says. A part of one feature that is not a domain concept - its form, its import - takes the plain word for that part. A grab-bag name (`utils`, `common`, `helpers`) or a type name (`models`, `controllers`) is not a split.
- **The split comes first,** only moves files, and changes no behaviour.

Put a test next to the file it tests, not in a separate `tests/` tree, unless the project's existing layout clearly says otherwise.

### Function and Method Names Follow Domain Actions

If users talk about "publishing a blog post" or "archiving it", the functions are `publishPost` and `archivePost` - not `updatePost`, even though both end as a database `UPDATE`. If they talk about "setting an article's category", it is `setArticleCategory`; if they talk about "saving an article", it is `saveArticle`, taking a compound object of everything users mean by "the article" in this context - which could include the category.

A name is specific enough that searching for it finds its definition and its uses, and little else. `data`, `info`, `handle`, `process`, `Manager` and `utils.ts` match everything and so locate nothing; name what the thing is in this domain instead.

### Business Logic Works with Domain Objects

The entities, value objects and aggregates the domain talks about are defined explicitly as local domain objects, such as classes or interfaces.

External seams - database interfaces, components and the like - validate external data at the boundary and translate it into those objects. The rest of the code, the business logic, works only with them: ORM types, data transfer objects and other external representations do not leak into it.

### Layers

Prefer a few layers that each hide real substance over many thin layers that only relay calls.

- **A layer must spare its caller something.** It earns its place only if a caller can use it correctly without understanding what is behind it. A wrapper that passes on the same vocabulary and shape it received, a class that only delegates, a hop that adds a name but no meaning - none of them do. Thinness is not the defect; a layer that spares the caller nothing is.
- **A variation point needs a second variant.** An interface or base class with one implementation, a factory or strategy with one variant, an option every caller sets the same way: collapse each to its one case. Two exceptions: the adapter over an external dependency under _Test Coverage_, whose mock is its second case, and a variation point exported for code outside this repo to fill.
- **Inline the trivial.** A pass-through that only forwards its argument, or a 1:1 mapping between domain and storage, can stay inline. Do not create a layer for it. Pull one out when the responsibility grows past trivial - real translation, real rules, more than one caller.

### Files Read Top to Bottom

A file, and every class and function in it, reads top to bottom: it starts with the abstract idea and grows concrete. Helpers sit below their callers, not above them.

**A file's exports are in its first 60 lines.** An agent getting its bearings reads a file's opening, so every export, or at least its signature, sits there, imports included; helpers go below. Where they don't fit, move the helpers down first. If the exports still don't fit, the file holds more than one concept: split it before adding to it. Fixture and test-helper files are exempt.

Reduce nesting. Prefer early returns as guards over nested if statements.

Every function call is fully understandable from its name and parameters, without reading its source. If it is not, improve the name.

**A function over 30 lines is a smell**, not counting JSX markup. A `describe` block is a scope, like a file, not a function; test bodies and hooks count like any other function. Split off a part when a name can say what it achieves, so the call reads without its body; a part that takes few inputs and returns one result usually can. Inline a helper when its name says no more than its body.

**Calls are named where they happen**, so a reader can find what runs by searching for it.

- **Not allowed:** dispatch through a computed name (`handlers["on_" + event]`, `getattr(self, name)`), reflection, monkey-patching, implicit registration, introspection. If the set of cases is known, name each one in a `switch` or `match`.
- **Allowed:** callbacks and raised signals, because they name what they hand over, and whatever a framework requires: its decorators, DI registration and entry points.
- **Built too early:** an event with a single listener, or a hook, decorator or wrapper of your own with a single user. Make the call directly, unless the indirection keeps the emitter's module from depending on the listener's.

### The Compiler Checks First

Put every rule you can where the compiler enforces it.

- **Turn on the strictest checking** the language and project allow.
- **No escape hatches:** no `any`, unchecked cast, `# type: ignore` or `!` without a comment saying why it is safe.
- **Structural rules are checks too.** A rule about where code lives or what may use what - which directory may import which, where the clock is read, how a file is named - is a check that the check command runs, added in the change that introduces the rule. A rule written into `CLAUDE.md` comes with its check in the same commit. If code breaks the rule today, the check reads a list of those breaks, and the list only shrinks.
- **Make invalid states unrepresentable.** Use a union of the real cases, not a bag of optional fields and a status string.
- **Exhaustive matches.** A `switch` or `match` over a known set has no `default` that swallows the next case added.

### Fields Listed Once

Code that has to cover every field of a domain object - equality, a merge or sum, a copy, a column list, a mapping to storage or the wire - is a second definition of the type: the next field added has to be added there too, and nothing says so.

- Keep it beside the type, as a function the rest of the code calls, rather than repeating the list where it is needed. Derive it only if the language does so plainly (`#[derive(PartialEq)]`, a dataclass's `__eq__`).
- If the list has to stand on its own - SQL, a wire format - make a forgotten field fail: a compiler check of completeness (in TypeScript, `satisfies Record<keyof T, …>`) or a test that goes through every field.
- If it leaves fields out on purpose - equality that ignores `id` - name the fields it leaves out, so a new field has to go on one side or the other.
- Code that picks a few fields for its own purpose, such as a view showing three of them, is not such a list.

### Comments

Make intent obvious from the code first: a better name, a well-named helper. Comments that restate the code are noise.

A comment describes the code as it is now. It never names a ticket, slice, story or change, or what the code used to do.

A comment is required if the code alone would lead the next reader to change it wrongly:

- it looks dead but is used from outside the code - config, a string route, reflection, a caller outside this repo
- it looks wrong or roundabout on purpose - an external quirk, a rejected simpler version
- its correctness depends on something elsewhere - a deploy order, a lock, an invariant upheld by another module

A change that touches commented code keeps the comment true, in the same change.

### Language

Code is in English, whatever language the domain or `UBIQUITOUS_LANGUAGE.md` uses: identifiers, test names, comments, commit messages. Use the identifier the glossary entry gives, exactly - `Vertrag` in the user's mouth is `Contract` in the source, and an untranslatable term carries its own ASCII form there. If an entry has no identifier, use a plain English translation of the term and list it in the change's report, as _Ubiquitous Language_ says for names not taken from the glossary.

### Dependencies

When adding a dependency, check the registry rather than your training data, which is almost always out of date: that the name you remember is right, what the current stable release is, and that the package is still maintained. Do not use an unmaintained one.

### No Dead Code

Remove code that nothing but its tests uses - down to a single parameter, field or option, and any branch no input reaches.

When a change removes a use of something - a call to a function, an import of a module, a read of a field - check whether anything else still uses it, and remove it if nothing does. The diff will not point to it, because the code left unused is outside the changed lines.

Code can look dead and still be live. Keep it if it is:

- accessed dynamically or by reflection
- registered for dependency injection
- a route referenced by a string
- named in config or an environment variable
- a framework entry point
- a parameter that a signature it has to match requires
- a field in a stored or wire format
- an exhaustiveness assertion
- exported API used outside this repo, even with no caller inside it
