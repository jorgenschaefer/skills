---
effort: L
utility: L
---

# Code that reads like its description

An `/idea` session on 2026-10-19 settled the problem below. It is not ready
for `/find-criteria` yet: the directions under "Discussed so far" need more
discussion first.

## The problem

Agreed with the user, after a fresh-context check:

> In a module whose logic has grown complicated, such as the weight
> tracker's rule for when a series shows as "gaining weight", the developer
> no longer knows what the rule is. Reading the code doesn't tell them. An
> agent that has read the code doesn't help either. When it proposed fixes
> for a "missed gain", its explanations made no sense to the developer in
> terms of the rule. A readable account of the rule can be produced, but it
> doesn't match how the code works, so understanding the account still
> doesn't tell the developer where or how a change would go. They approve
> product changes they can't judge, and they lose control of software they
> wrote. Instead, the developer can understand what such a module does, and
> that understanding carries over to the code. A change they can put in
> terms of the rule points to a place in the code, and an agent's
> explanation of a code change makes sense in terms of the rule. What the
> module does stays the same. Whether its cases are all still needed is a
> separate problem.

## The instance

The weight tracker's "gaining weight" rule grew complicated until the user
no longer understood it and could not learn it from the code. When a
"missed gain" came up, they depended entirely on an agent's proposed fixes
and could not say what they wanted. The agent explained its fixes in the
code's own terms, which made no sense to them.

The user then tried this by hand. One agent described the code in prose.
A second agent, without code access, rewrote the prose for readability.
A third agent refactored the module to follow it. The rewritten prose gave
the user understanding and described the behaviour correctly, but before
the refactor the user's ideas for changes did not map onto the code. After
it, the result "looked really good".

The module's file and the commits of the "missed gain" fixes are not
named yet.

## Discussed so far

These are directions, not decisions.

- **The unit is a behaviour, not a module.** In a complicated codebase the
  modules may be heavily interconnected or cut so oddly that they can't
  simply be untangled, so a module is no reliable boundary. The developer
  names a behaviour they can no longer explain, such as "when does a series
  show as gaining?". The code in scope is whatever decides it, wherever it
  sits today: running the account's examples with coverage finds it across
  modules, without untangling them first.
- **Being a module is the result, not the start.** After the work, the
  behaviour's own logic is one module or submodule, and it uses shared
  modules it imports by name. Coverage of its examples shows it: scattered
  across files before, concentrated in its module and its named shared
  modules after. The account's sections decide granularity, for example
  "gaining" as a submodule of "weight trends".
- **Top-down leads, bottom-up is evidence.** The behaviour and its account
  say what shape the code should have. Dependency graphs and co-change
  history show the tangle an extraction will meet, but clustering the
  current code tends to reproduce the current cuts.
- **Overlapping behaviours show the real seams.** Coverage compared across
  two or three behaviours in the same bundle sorts the code: code only one
  runs belongs to it, code several run is a shared mechanism and a
  candidate deep module, and code none runs is a missed case or a candidate
  for `rule-cruft.md`.
- **One behaviour at a time, no untangling phase first.** Untangling a
  whole bundle before it is understood is a rewrite without a
  specification. Each extraction is pinned by its examples and leaves the
  rest smaller.
- **An agent describes the behaviour**, and a second agent without code
  access rewrites the description for readability.
- **The developer judges only "do I understand this?"** They cannot judge
  whether the account is true of code they don't understand. The agent
  revises until they say it reads clearly.
- **Faithfulness is checked by running something.** Every claim in the
  account comes with a concrete example, such as a series and its verdict,
  and the example runs against the old code. A fresh agent maps every
  branch in the code to a sentence in the account.
- **Behaviour is pinned before the code moves.** The examples become tests,
  and the old code's outputs are recorded over many generated inputs.
- **The code is reshaped so its parts are the account's parts**, as deep
  modules.
- **A round trip checks that the code stands on its own.** A fresh agent
  reads only the new code and writes down what it does, and that has to
  match the approved account.
- **A change in the rule's terms lands in one place.** A fresh agent gets
  the account and a change request and says where the code would change.
- **The account is scaffolding**, deleted once the change is accepted, like
  `CRITERIA.md`. The user does not want the prose kept in the code.
- **It is a separate skill, not part of `restructure`**, which sweeps the
  whole codebase and only applies changes it can prove keep behaviour
  (`restructure/SKILL.md`).
- **One rule for `CODING_STANDARDS.md`** would hold new code to the shape,
  roughly "a module's parts follow the account of what it does". The
  standard already asks for abstract-first order within a file ("Files Read
  Top to Bottom") but says nothing across files and modules.

## Dropped or changed

| Considered | Outcome | Why |
| --- | --- | --- |
| Keeping the account in the code as the module's opening | Dropped | The code should stand on its own; the round trip tests that more strictly. |
| The developer approving the account as correct | Changed to "I understand this" | Judging correctness needs the understanding the developer has lost. |
| Restructuring and removing cruft in one run | Split | One diff mixing preserved and changed behaviour is the hardest to sign off on. |
| Blaming the mismatch on the code's "order" | Removed from the problem | The user never said so; it smuggled in the proposed solution. |

"Code is written for an agent to read" stays. The instance shows why it
serves the developer too: an agent explains changes in the concepts the
code gives it.

## Parked

Removing cruft from a rule's cases is `rule-cruft.md`. This skill would
feed it with two kinds of candidates: branches with no sentence in the
account, and cases that surprised the developer while reading.

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
  is the strongest signal. Should `restructure` also suggest candidates from
  churn and bug-fix history?
- **Making the account nicer instead of clearer.** Are the examples and the
  branch mapping enough of a guard?
