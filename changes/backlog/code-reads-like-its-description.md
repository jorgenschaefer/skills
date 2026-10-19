---
effort: L
utility: L
---

# Code that reads like its description

An `/idea` session on 2026-10-19 settled the problem below. It is not ready
for `/find-criteria` yet: the directions under "Discussed so far" need more
discussion first.

## The problem

Agreed with the user, after a fresh-context check. "A part of the code"
replaced "a module" later the same day, since the unit turned out to be a
behaviour rather than a module.

> In a part of the code whose logic has grown complicated, such as the
> weight tracker's rule for when a series shows as "gaining weight", the
> developer no longer knows what the rule is. Reading the code doesn't tell
> them. An agent that has read the code doesn't help either. When it
> proposed fixes for a "missed gain", its explanations made no sense to the
> developer in terms of the rule. A readable account of the rule can be
> produced, but it doesn't match how the code works, so understanding the
> account still doesn't tell the developer where or how a change would go.
> They approve product changes they can't judge, and they lose control of
> software they wrote. Instead, the developer can understand what such a
> part of the code does, and that understanding carries over to the code. A
> change they can put in terms of the rule points to a place in the code,
> and an agent's explanation of a code change makes sense in terms of the
> rule. What the code does stays the same. Whether its cases are all still
> needed is a separate problem.

## The instance

The weight tracker's "gaining weight" rule grew complicated until the user
no longer understood it and could not learn it from the code. When a
"missed gain" came up, they depended entirely on an agent's proposed fixes
and could not say what they wanted. The agent explained its fixes in the
code's own terms, which made no sense to them.

The user then tried this by hand. One agent described the code in prose.
A second agent, without code access, rewrote the prose for readability.
A third agent refactored the code to follow it. The rewritten prose gave
the user understanding and described the behaviour correctly, but before
the refactor the user's ideas for changes did not map onto the code. After
it, the result "looked really good".

The module's file and the commits of the "missed gain" fixes are not
named yet.

## Scope

The code being reworked is assumed to have good test coverage. Writing new
tests is not part of this skill. The hard part is changing the existing
tests for the new module surface without weakening them.

## A typical run

How a run would look to the developer, as far as the directions below go.

You start the skill with a behaviour you can no longer explain: "when does
a weight series show as gaining?" You don't name a file or a module. You
don't need to know where the code is, and not knowing is part of why you're
running it.

The skill first finds the code. It starts where the "gaining" badge appears
and traces back. It runs the existing tests with coverage and compares the
tests that end in "gaining" with those that don't. The lines that differ
are the code that decides, perhaps spread over seven files in three
modules, mixed in with the trend chart and the "losing" logic. It notes
which of that code neighbouring behaviours also run. You aren't involved.

Then it writes the account. One agent describes what the code does, and a
second, which never sees the code, rewrites that until it reads clearly.
Every claim is checked against the existing tests, and every branch maps to
a sentence, in the rule or in a concept's details. Where a test contradicts
a claim, the account is corrected before you see it.

Then comes the one stop where you're needed. You read an account of your
rule, rule first and details below, each claim with a case taken from the
tests. Where it's unclear you say so, it's revised, and the checks run
again. Once you say you understand it, you predict the verdicts for a few
cases you haven't seen. Anything that surprised you is noted for the cruft
backlog, not acted on. At the same stop you see the proposed interface: the
account's concepts, the module each becomes and what it offers, one call
taken from a test, and the callers elsewhere that will move. You approve or
correct it, and then you can walk away.

The skill works on without you. It builds the new interface as a thin layer
over the old code, moves the tests onto it while the code stays unchanged,
and has a fresh reviewer check that no old test lost an input, an expected
value or the strictness of an assertion. Then it replaces the code behind
the interface while the tests stay unchanged, and removes the layer. The
whole suite runs at every step, so a break in a neighbouring behaviour
shows at once. Where the run cannot go on as approved, it decides the next
step itself and records why.

At the end you get the result with evidence:

- coverage of the behaviour before and after, such as seven files becoming
  one module and two shared ones;
- the round trip: a fresh agent's description of the new code predicted
  every example's verdict;
- a sample change in the rule's terms, made on a throwaway branch, that
  touched one module;
- the reviewer's comparison of old and new tests;
- every change to the approved interface and every decision the run made
  without you, each with its reason;
- the cases that surprised you, ready for `rule-cruft.md`.

You accept the change, the account is deleted, and the code stands on its
own.

## Discussed so far

These are directions, not decisions.

### Finding the code

- **The unit is a behaviour, not a module.** In a complicated codebase the
  modules may be heavily interconnected, or cut so oddly that they can't
  simply be untangled, so a module is no reliable boundary. The developer
  names a behaviour they can no longer explain, such as "when does a series
  show as gaining?".
- **Coverage finds the deciding code.** The description starts where the
  verdict shows and traces back. Coverage of the existing tests then finds
  the code across modules, without untangling them first. Coverage alone
  also includes loading, persistence and rendering, so the deciding code is
  what differs between tests with different verdicts.
- **Top-down leads, bottom-up is evidence.** The behaviour and its account
  say what shape the code should have. Dependency graphs and co-change
  history show the tangle an extraction will meet, but clustering the
  current code tends to reproduce the current cuts.
- **Neighbouring behaviours show the real seams**, compared by coverage
  of their existing tests, not by writing accounts for them. Code only one
  behaviour runs belongs to it, and code several run is a shared mechanism
  and a candidate deep module. Only the behaviour the developer named goes
  through the readability loop with them.
- **One behaviour at a time, no untangling phase first.** Untangling a
  whole bundle before it is understood is a rewrite without a
  specification. The whole test suite runs at every step, so a neighbouring
  behaviour that breaks shows up.

### The account

- **An agent describes the behaviour**, and a second agent without code
  access rewrites the description for readability.
- **The account has layers**: the rule first, then the details of each
  concept, such as empty series or missing weigh-ins. That keeps the rule
  readable while every branch still has a sentence somewhere.
- **Its examples come from the existing tests**, put in the rule's terms.
- **Its claims are checked against the tests.** A claim is wrong where an
  existing test's verdict contradicts it. A fresh agent maps every branch
  in scope to a sentence in the rule or in a concept's details. Both checks
  run again after every revision of the account.
- **The developer judges only "do I understand this?"** They cannot judge
  whether the account is true of code they don't understand. The agent
  revises until they say it reads clearly. Then they predict the verdict
  for a few test cases they haven't been shown, and the predictions are
  checked against the code, since smooth prose can feel understood without
  being so.

### The new interface

- **The developer approves it at the same stop as the account**, once they
  understand the account and have predicted the verdicts. That is when they
  can judge it best, and a second stop would gain nothing. It is approved
  rather than only shown: a surface that doesn't match the account brings
  back the mismatch the problem describes.
- **It is shown in terms the developer can judge**: a table mapping each
  concept in the account to its module and what that module offers, plus
  one call taken from an existing test. A concept with no module, or a
  module with no concept, shows at a glance.
- **The callers that have to move are listed with it**, such as the code
  in other features that calls the old surface. That is the part that is
  harder to reverse.
- **A build that changes the interface records why**, without stopping.
  The developer sees the change at acceptance, the way the pipeline already
  handles a build that goes beyond a technical decision.
- **The run does not halt for what the developer can't help with.** An old
  test that won't translate to the new interface, or an approved interface
  the code shows cannot work, is decided by the run itself and recorded
  with its reason. The developer said they likely could not help there.

### Changing the code

Tests and code never change in the same step:

1. Build the new surface, shaped by the account, as a thin adapter over the
   old code.
2. Move the tests to the new surface while the code stays unchanged, named
   and grouped by the account's concepts.
3. A fresh reviewer compares old and new tests one by one: every old test's
   inputs and expected results appear in some new test, and no assertion
   got looser.
4. Replace the implementation behind the surface while the tests stay
   unchanged.
5. Remove the adapter.

### The result

- **Its parts are the account's parts**, as deep modules. The behaviour's
  own logic is one module or submodule, and it uses shared modules it
  imports by name. Coverage of its tests shows it: scattered across files
  before, concentrated after. The account's sections decide granularity,
  for example "gaining" as a submodule of "weight trends".
- **A round trip checks that the code stands on its own.** A fresh agent
  reads only the new code and writes down what it does. That account has to
  predict the verdicts of the examples.
- **A change in the rule's terms lands in one place.** A fresh agent makes
  a change request in the rule's terms on a throwaway branch, and the diff
  touches one module per concept changed.
- **The account is scaffolding**, deleted once the change is accepted, like
  `CRITERIA.md`. The user does not want the prose kept in the code.

### Where it lives

- **It is a separate skill, not part of `restructure`**, which sweeps the
  whole codebase and only applies changes it can prove keep behaviour
  (`restructure/SKILL.md`).
- **One rule for `CODING_STANDARDS.md`** would hold new code to the shape
  without needing an account, roughly "a module opens with its concept, and
  its parts are the concepts of its domain". The standard already asks for
  abstract-first order within a file ("Files Read Top to Bottom") but says
  nothing across files and modules.

## Dropped or changed

| Considered | Outcome | Why |
| --- | --- | --- |
| Keeping the account in the code as the module's opening | Dropped | The code should stand on its own; the round trip tests that more strictly. |
| The developer approving the account as correct | Changed to "I understand this" | Judging correctness needs the understanding the developer has lost. |
| Restructuring and removing cruft in one run | Split | One diff mixing preserved and changed behaviour is the hardest to sign off on. |
| Blaming the mismatch on the code's "order" | Removed from the problem | The user never said so; it smuggled in the proposed solution. |
| A module as the unit of work | Changed to a behaviour | Tangled or oddly cut modules make no reliable boundary. |
| Generating inputs and recording the old code's outputs | Dropped | Good test coverage is assumed; the existing tests are the pin. |
| Mutation testing to prove moved tests aren't weaker | Left out for now | A fresh reviewer compares the tests instead. |

"Code is written for an agent to read" stays. The instance shows why it
serves the developer too: an agent explains changes in the concepts the
code gives it.

A fresh-context review of this item on 2026-10-19 led to the layered
account, the claims checked against tests, the predicted verdicts, the
throwaway-branch check, the separate steps for tests and code, and
comparing neighbours by coverage instead of accounts.

## Parked

Removing cruft from a rule's cases is `rule-cruft.md`. This skill would
feed it with candidates: branches in the rule itself that no sentence
covers, and cases that surprised the developer while reading. Branches in a
concept's details are not candidates.

## Open

- **Which order an account follows.** The original idea starts from the
  screen. A rule has no screen, and its account may start from the verdict.
- **Narrative versus deep modules.** Following prose tends to produce one
  thin function per sentence.
- **Shared mechanisms.** Prose is linear and code is a graph. Where does a
  part live when two accounts use it? A mechanism every behaviour touches,
  such as a large domain object, may get copied into each extraction or
  become the new tangle.
- **Cross-cutting behaviours.** Permissions, logging or units don't become
  a module each. The current direction is to leave them out of scope.
- **Choosing the behaviour.** The developer naming one they can't explain
  is the strongest signal, but a late one. Finding candidates earlier is
  `find-code-before-understanding-is-lost.md`.
- **Coverage that isn't good after all.** What the skill does when the
  assumption fails: stop, or say what is unpinned?
- **What the run may decide alone.** A test that won't translate must not
  simply be dropped or loosened, since that loses coverage. What it does
  instead is still open.
- **Mutation testing** as a later, executable check that the moved tests
  weren't weakened.
