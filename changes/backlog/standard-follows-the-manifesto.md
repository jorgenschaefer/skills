---
effort: L
utility: L
---

# CODING_STANDARDS.md follows the manifesto

Every build and every review is held to `CODING_STANDARDS.md`, and in
several places it says something `MANIFESTO.md` contradicts or lacks.
Since 2026-10-24 it names its laws as the manifesto names its goals -
Utility first - but the sections under those names were written before the
manifesto. It still calls them laws (`:7`, `:14`), where the manifesto now
says goals.

Evidence, from `implement/CODING_STANDARDS.md` (five identical copies):

- **Utility works out what to build.** "You may have to work that out
  first, from the ticket, the callers, the domain" (`:23`). The manifesto:
  the developer approves the behaviour "before it is built", the writer
  "builds what was approved", and "Something found while building that may
  change what the user wants is a decision the plan didn't cover". The
  section is about correctness; it says nothing of what the user wants, of
  failure cases being part of it, or of showing each criterion "with a check
  that executes and stays".
- **Usability is screens.** "Can every button be used on every supported
  screen size?" (`:89`). The manifesto: easy to use "for the people and
  programs it is meant for"; data that fits the way the user thinks of it,
  or an interface that shows how it really fits; an agent checking it by
  completing the tasks without reading the code. An API or a CLI gets
  nothing.
- **A constraint becomes a comment first.** A comment is required where
  "its correctness depends on something elsewhere - a deploy order, a lock,
  an invariant upheld by another module" (`:234`). The manifesto: "A
  constraint that matters becomes a check that fails and says why." "Only
  what remains is written down" left the manifesto and is listed below.
- **A report nothing has room for.** "Follow the existing way, even if you
  would have chosen another, and report it" (`:144`). `implement/SKILL.md`'s
  Finish lists what a build leaves standing and ends "Nothing else", with no
  slot for it.
- **Rare failures may be generic.** "A rare, unusual error may make do with
  an 'an error occurred, try again' popup" (`:113`). The manifesto has the
  developer approve the behaviour "failure cases included", and the writer
  "builds what was approved" - which failures may be generic is theirs to
  settle.
- **Dependencies are only checked.** _Dependencies_ asks for a registry
  check. The manifesto approves "a dependency the codebase gets built
  around" before implementation, as a hard-to-reverse decision.

## Code rules that left the manifesto

The manifesto's first version held these. They are rules for code, so they
belong in the standard, which does not state them yet:

- The boy scout rule: small fixes in passing leave the code better than they
  found it. They change nothing the developer approved and follow the idioms
  already there. Anything larger is a change of its own.
- "What a fresh agent finds with one search or in one file needs no
  documentation."
- Test the constraint, not the decision it led to.
- Where a test environment can't see a constraint, a contract test or a
  benchmark comes as close as it can.
- "Only what remains is written down": what no check can hold.
- A mistake fails where it is made, not where it shows up. The standard says
  this only for silent fallbacks (_Fail Loudly Inside_, `:119`) and for
  field lists (_Fields Listed Once_, `:215`).

YAGNI, KISS, colocation, searchable names, invalid states and one way to do
each thing left the manifesto too, but the standard already has them.

Separate items cover other parts of the standard:
`security-in-the-standard` (Security), `cut-files-by-concept` (what
changes together, file shape), `approved-criteria-outlive-the-change`
(tests for approved behaviour that stay and are checked on every change),
and `reviewer-shares-the-authors-lens` (the standard as the only lens of
builder and reviewer).

Depends on `method-layer`, the process document that sits beside the
standard in the second layer. Approving a dependency is settled since
2026-10-27: "Hard to reverse" names one the codebase will be built around.
