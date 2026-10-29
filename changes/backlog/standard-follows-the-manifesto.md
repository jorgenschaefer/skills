---
effort: XL
utility: L
---

# CODING_STANDARDS.md follows the manifesto

Every build and every review is held to `CODING_STANDARDS.md`, and in
several places it says something `MANIFESTO.md` contradicts or lacks.
Since 2026-10-24 it names its laws as the manifesto names its goals -
Utility first - but the sections under those names were written before the
manifesto. It still calls them laws (`:7`, `:14`), where the manifesto now
says goals. Two skills use the word too: a build reports "where you weighed
one law of the standard against another" (`implement/SKILL.md:69`), and
`/accept-criteria` reports it under Tradeoffs (`accept-criteria/SKILL.md:73`).
The manifesto adds what those lines lack: "An agent weighs only within what
the developer approved; a tradeoff that would change it is a decision the
plan didn't cover."

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
  already there. Anything larger is a change of its own. `implement` states
  it already, in its own words (`implement/SKILL.md:32`, from cc778c3 on
  2026-10-24). Once the standard has it, that paragraph says it twice.
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

The Security section (`:77`) is checked against the manifesto by no other
item. `security-in-the-standard` was meant to, but became the security
policy (e9e746b) and left the section as it was.

Separate items cover other parts of the standard:
`approved-criteria-outlive-the-change` (tests for approved behaviour that
stay and are checked on every change), and `reviewer-shares-the-authors-lens`
(the standard as the only lens of builder and reviewer).

The process document beside the standard is `PIPELINE.md`, written on
2026-10-29. Approving a dependency is settled since
2026-10-27: "Hard to reverse" names one the codebase will be built around.

## Docs say only what the code cannot show

Merged from `docs-only-what-the-code-cannot-show` on 2026-10-29. Once the
standard has the rules above, this repository's own docs are held to them.

The README restates in prose what `run.sh` and its tests do, and comments
and skills carry the history of their rules. Both go stale and both are
read by agents as true.

`MANIFESTO.md`, premise 2: an agent "takes all of it as true". "What a
fresh agent finds with one search or in one file needs no documentation" and
"Only what remains is written down" left the manifesto; they are listed
above, under "Code rules that left the manifesto".
`CODING_STANDARDS.md`, _Comments_: a comment "never names ... what the code
used to do".

Evidence:

- README "The runner" and "The tests" sections describe `run.sh`'s
  behaviour step by step - refusals, branch, checks, drift, budget, resume,
  lock, review, token log.
- History in comments: `run/checks.sh:13` "Every build used to meet the same
  failures"; `run.sh` "A second one started beside a live run took over its
  claim"; `run/prompts.sh` "one run's build left a blocker there".
- Stories in skills: `implement/SKILL.md` "in one run the build and its
  reviewer drove the app at the same time"; `criteria-to-tickets/SKILL.md`
  "in one run, an import rule written into a ticket ..." and "A check that
  saw tickets 01 to 20 ..."; `.claude/skills/retro/SKILL.md` "One analysis
  that ran the tests ...". `improve-skill` keeps such a story only as one
  clause that does a named job.

`PIPELINE.md` now holds the pipeline's intent, and the README says what
the scripts do.

## Cut files by concept, not by line count

Merged from `cut-files-by-concept` on 2026-10-29: a possible answer to the
Maintainability goal, so it goes into the standard with the rest.

`CODING_STANDARDS.md` has no rule that holds new code to a shape cut by
concept. Its rule splitting files at about 500 lines was removed
on 2026-10-19, since the reason it gave does not hold (below). "What Changes
Together, Stays Together" (`implement/CODING_STANDARDS.md:148`) is too vague
to cause a split at all.

### The 500-line limit does not buy a whole read

The limit's reason is "an agent should be able to read a file whole". An
analysis on 2026-10-19 of 583 `run.sh` sessions across seven projects (late
September to then, about 9,900 reads of code files sized from git at
session start) shows that it does not:

| lines | ≤100 | 101–200 | 201–300 | 301–400 | 401–500 | 501–750 | >1000 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| reads that took the whole file | 85% | 49% | 32% | 20% | 23% | 13% | 7% |
| sessions that saw the whole file | 91% | 62% | 47% | 38% | 44% | 27% | 8% |

- 81% of the 2,665 `sed -n` range reads on files of 500 lines or fewer
  covered less than half the file. 2,110 of 2,896 range reads followed a
  `grep`: the agent searches, then prints a window, whatever the size.
- The drop is at 100–200 lines, and nothing changes at 500. The auto-mode
  system prompt also tells the agent to read with `sed -n`.
- The limit costs work: commits matching split/combine are about 7–15% of
  the commits in drk-barmbek, einsatz and haushaltsbuch since 2026-09-20 (a
  rough keyword count). `retro/SKILL.md:31` records the limit turning into a
  target, with files kept at 495–499 lines.

Not measured: whether partial reads cause mistakes.

### Rules discussed

These are directions, not decisions. Each one names what to look at, when
to cut, and a check, preferably one that runs.

1. **A file holds one domain concept and is named after it.** The cuts
   follow where an account of the behaviour has sections, not sentences: a
   concept is a term for `UBIQUITOUS_LANGUAGE.md`. The file opens with the
   concept, and its exports are what the concept offers. Cut when
   describing the file takes two concepts joined by "and", or its exports
   belong to different glossary terms. Code that is not a concept gets no
   file of its own, and "Layers" already rejects pass-through modules,
   which keeps away a shape of one thin function per sentence. For UI code the concept is
   what the user names: a screen, a panel, a step in a workflow, so a
   usability report leads to one directory. Check: a fresh agent reading
   only the file describes it in one sentence of glossary terms.
   `CODING_STANDARDS.md` now covers part of this: a file's exports are in
   its first 60 lines, and exports that don't fit there even with the
   helpers moved down mean the file holds more than one concept.
2. **A rule is decided in one place.** The code that decides something the
   user sees (a verdict, a badge, whether a validation passes, a price) is
   one module of pure functions over domain objects. Loading, saving and
   rendering call it and hold no branches of the rule. Cut when such
   branches turn up in a component, route handler or query. Check, which
   runs: coverage compared between tests that expect different verdicts
   lands in one module, and a change put
   in the rule's terms touches one module per concept it changes.
   `find-criteria` had a rule for this until 2026-10-27: "Give every new
   domain rule one home. Where the criteria introduce a rule - a sign, a
   status, a classification - a nudge names the one place it lives, named
   after the rule" (`find-criteria/SKILL.md:39` at cff52cc). It went with
   nudges, and nothing now gives a new rule one named place.
3. **A trust boundary is a file boundary.** Structure does not make code
   secure, but it decides whether a reviewer can check that it is. Access
   (one place per entity whose queries all carry the owner filter) and
   untrusted input (one place parsing it into domain objects) live in files
   of their own. Domain modules never import the request, the session or
   the raw database client. Cut when a file both touches those and makes
   domain decisions. Check, which runs: an import restriction in the linter
   (`no-restricted-imports`, dependency-cruiser), so a security review reads
   the boundary files and can skip the rest.
4. **What changes together is measured from history.** Files in different
   directories that change in the same commit most of the time (say more
   than half of the commits touching either) move together. A file whose
   commits fall into separate groups, each changing with different
   neighbours, splits along those groups. Code only one feature uses stays
   with it. Code several use becomes its own module only where it is a
   concept in the sense of rule 1, and otherwise stays with the feature that
   uses it most, so no `utils` appear. Check, which runs: a script over
   `git log --name-only` printing pairs and files above the thresholds,
   which `restructure` could run on its regular sweep.

The line count stays at most as a smell critique reports, at about 1000
lines, to be looked at against rules 1 and 2. It is no reason to split.

### Open

- **Coverage per verdict for new code.** Rule 2's check needs it, and
  `implement` does not produce it today.
- **Thresholds** for rule 4, and whether its script lives in `restructure`,
  `critique` or both.
- **Five copies.** The standard is copied into `implement`, `critique`,
  `restructure`, `find-criteria` and `criteria-to-tickets`. The ticket-size
  thresholds in `criteria-to-tickets/SKILL.md:27` and
  `criteria-to-tickets/VERIFY.md:27` are a separate rule and need looking
  at on their own.
