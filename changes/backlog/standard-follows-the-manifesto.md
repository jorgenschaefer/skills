---
effort: L
utility: L
---

# CODING_STANDARDS.md follows the manifesto

Every build and every review is held to `CODING_STANDARDS.md`, and in
several places it says something `MANIFESTO.md` contradicts or lacks.
Since 2026-10-24 it names its laws as the manifesto does - Utility first -
but the sections under those names were written before the manifesto.

Evidence, from `implement/CODING_STANDARDS.md` (five identical copies):

- **Utility works out what to build.** "You may have to work that out
  first, from the ticket, the callers, the domain" (`:23`). The manifesto:
  "The consultation happens before implementation; what it settles is what
  gets built", and "Something found during implementation that may change
  what the user wants is a decision the plan didn't cover". The section is
  about correctness; it says nothing of what the user wants, of failure
  cases being part of it, or of each criterion "shown by a check that
  executes and stays".
- **Usability is screens.** "Can every button be used on every supported
  screen size?" (`:89`). The manifesto: easy to use "for the people and
  programs it is meant for"; data that fits the way the user thinks of it,
  or an interface that shows how it really fits; an agent checking it by
  completing the tasks without reading the code. An API or a CLI gets
  nothing.
- **A constraint becomes a comment first.** A comment is required where
  "its correctness depends on something elsewhere - a deploy order, a lock,
  an invariant upheld by another module" (`:234`). The manifesto: "A
  constraint that matters is a check that fails and says why. ... Only what
  remains is written down."
- **A report nothing has room for.** "Follow the existing way, even if you
  would have chosen another, and report it" (`:144`). `implement/SKILL.md`'s
  Finish lists what a build leaves standing and ends "Nothing else", with no
  slot for it.
- **Rare failures may be generic.** "A rare, unusual error may make do with
  an 'an error occurred, try again' popup" (`:113`). The manifesto's
  Utility "includes the failure cases", and what the user is consulted on is
  what gets built - which failures may be generic is theirs to settle.
- **Dependencies are only checked.** _Dependencies_ asks for a registry
  check. The manifesto approves "a dependency the codebase gets built
  around" before implementation, as a hard-to-reverse decision.

Separate items cover other parts of the standard:
`security-in-the-standard` (Security), `cut-files-by-concept` (what
changes together, file shape), `approved-criteria-outlive-the-change`
(tests for approved behaviour that stay and are checked on every change),
`reviewer-shares-the-authors-lens` (the standard as the only lens of
builder and reviewer), and `approval-follows-the-manifesto` (approving a
dependency).

Depends on `layered-manifesto`, whose method layer the standard becomes half
of, and on `approval-follows-the-manifesto`, which settles approving a
dependency.
