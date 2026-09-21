# Plan: reshape the pipeline around one standard

Six proposals, taken together, because they touch each other: the document
proposal 1 produces is what proposals 2 and 3 read, and the renames in 5 and 6
move the files proposal 4 splits `verify` into.

No tests and no test-first: `tests/` is deleted as part of this change (step 11),
so there is nothing to keep green and nothing to write first.

## Decisions taken before this was written

Answered in the session that produced this plan, recorded here because they are
the reason the steps below look the way they do rather than some other way.

| Question | Answer |
| --- | --- |
| Where the merged document lives | A reference file, `CODING_STANDARDS.md`, duplicated byte-identically into each skill that reads it. Not a skill of its own. |
| Which skills hold a copy | `implement`, `critique`, `plan-solution`. `ADR_FORMAT.md` moves to `plan-solution/`. |
| Whether `implement` keeps its ticket half | No. Generic only. The ticket protocol moves into `run.sh`'s prompt text, not into a second skill. |
| How `implement` reviews itself | It spawns `critique` as a subagent with a fresh context, fixes what comes back, re-reviews; at most two rounds. |
| Where `cleanup-repo`'s tier 3 goes | Into `CODING_STANDARDS.md` as a property of good software. Its *procedure* goes into `critique`'s whole-repo mode. |
| What `verify` becomes | Three tailored `VERIFY.md` files — `idea/`, `find-solution/`, `plan-solution/`. Deliberately different from each other, not three copies of one generic file. The `verify` skill is deleted. |
| The directory layout | `intents/YYYY-MM-DD-<slug>/01-INTENT.md`, `02-SOLUTION.md`, `tickets/NN-<slug>.md` with two-digit numbers. |
| The plan-mode prompt | Written fresh, in this repo's voice, rather than copied from Claude Code. |
| Whether `critique` keeps its ticket section and `VERDICT:` line | Neither. Both are dropped. |
| What `/plan` means in "suitable to pass to /plan" | Claude Code's plan mode. |
| What happens to `tests/` | Deleted entirely. |
| The runner's review step | Retired — `implement` now reviews itself through a subagent, so a second review session is redundant. |
| What closes an unattended run | `run.sh` runs `/accept-intent` on the intent, prints what the walk found, and exits without merging or marking anything. |

## The shape it ends in

```
idea/                      SKILL.md  INTENT_FORMAT.md  VERIFY.md
find-solution/             SKILL.md  SOLUTION_FORMAT.md  VERIFY.md
plan-solution/             SKILL.md  TICKET_FORMAT.md  PLANNING.md  VERIFY.md
                           CODING_STANDARDS.md  ADR_FORMAT.md
implement/                 SKILL.md  CODING_STANDARDS.md
critique/                  SKILL.md  CODING_STANDARDS.md
accept-intent/             SKILL.md
git-commit-message/        SKILL.md
repo-overview/             SKILL.md
skill-review/              SKILL.md
ubiquitous-language-init/  SKILL.md  UBIQUITOUS_LANGUAGE_FORMAT.md
upgrade-dependencies/      SKILL.md
run.sh
README.md
```

Gone: `coding-standard/`, `software-design/`, `cleanup-repo/`, `verify/`,
`solve/`, `slice/`, `tests/`.

The pipeline the README will draw:

```
  /idea ──→ 01-INTENT.md ──→ /find-solution ──→ 02-SOLUTION.md ──→ /plan-solution ──┐
                                                                                    │
                                              one slice: a plan in plan mode ←──────┤
                                              many slices: tickets/NN-<slug>.md ←───┘
                                                              │
                              ./run.sh intents/<slug>/tickets ──→ /implement ──→ (critique subagent)
                                                              │
                                                      /accept-intent
```

Three stages carry their own adversary as `VERIFY.md`, run in a subagent that
did not write the artifact. The fourth adversary is `critique`, which
`implement` spawns for the same reason.

---

## Step 1 — Write `CODING_STANDARDS.md`

The merged document. Written once, at `implement/CODING_STANDARDS.md`, and
copied byte-identically in step 2.

It absorbs four sources, and each contributes a different kind of sentence:

- `coding-standard/SKILL.md` — every property, essentially intact. It is already
  written as "each rule states a property the code should have", which is the
  register the whole document adopts.
- `software-design/SKILL.md` — domain layering, the seams, domain objects, the
  granularity rule, the glossary, what deserves an ADR.
- `implement/SKILL.md` — the red/green/refactor loop and "prove the contract
  before you hand it over" (break it twice: remove the behaviour, move its edge).
  These are the only parts of `implement` that describe *how good software gets
  written* rather than how a ticket is processed.
- `cleanup-repo/SKILL.md` — tier 3 only: complexity that outweighs its value.
  Tiers 1 and 2 are already in `coding-standard` as "no dead code", YAGNI and
  KISS; restating them would be the duplication the document itself forbids.

Structure, in four parts, ordered by when a reader needs them:

```
# Coding standards

<preamble: what this is, that it supplements judgment and does not bound it,
 that each rule states a property and the reader supplies the verb — writing,
 reviewing, or deleting>

## Shaping the change
   Domain layering
   Anchor names in the domain
   The seams
   Domain objects across the seams
   Conceptual granularity, not premature abstraction
   The glossary
   What deserves an ADR

## Writing the code
   Simple design
   Structure and locality
   Clarity and least astonishment
   Concurrency and shared state
   Cost at scale
   Accessibility
   Changing what already runs
   Security
   Dependencies

## How it gets written
   Test coverage            (from coding-standard's ## Test coverage)
   The loop                 (red/green/refactor, from implement)
   Prove the contract       (break it twice, from implement)

## What does not belong
   (dead code / YAGNI / KISS restated as a deletion lens — one short
    cross-reference each, not a second statement of the rules)
   Complexity that outweighs its value
```

Edits the merge forces, beyond concatenation:

1. **The two cross-references between the old halves are now internal.**
   `coding-standard`'s opening paragraph pointing at `software-design`, and
   `software-design`'s opening pointing back, both go. So does
   `software-design`'s "not for code already being typed: that is
   `coding-standard`" — the split it describes no longer exists.
2. **"Reuse the established vocabulary" and "The glossary" now sit in one
   document** and should say the glossary thing once. The write-time rule keeps
   its full text (it carries the English-identifier reasoning, which is long and
   load-bearing); `## The glossary` shrinks to the planning-time half — putting a
   term you coin into the file, and what to do when the plan contradicts an
   entry.
3. **`## What deserves an ADR` keeps "never write one unilaterally" and "write it
   at plan exit"**, and now points at `ADR_FORMAT.md` in the same directory —
   which only `plan-solution` will hold. In the `implement` and `critique` copies
   that reference is to a file that is not there. Resolve it by having the
   sentence name the moment rather than the file: "the record is written at plan
   exit, in the shape `plan-solution` keeps" — so no copy points at a missing
   path. (`ADR_FORMAT.md` itself is unchanged and simply moves.)
4. **Tier 3 keeps its strict handling.** Written as a property — "complexity that
   outweighs its value does not belong, even when the code works, is referenced,
   and is correct" — followed by the handling that makes it safe: it is always a
   tradeoff put to a person, never applied without its own explicit go-ahead, and
   never grouped with findings that are safe to apply. That handling is what
   stops it being mistaken for a blocker.
5. **The TDD loop loses its ticket framing.** "`coding-standard` requires that no
   code change arrives without a failing test first" becomes a statement in the
   document's own voice. "For every criterion the ticket claims" becomes "for
   every piece of behaviour this change is meant to have".
6. **`## Test coverage` and `## The loop` must not restate each other.** Coverage
   is the state the suite ends in; the loop is the order the work happens in. The
   existing "This is the one rule here about the order of the work" sentence is
   the hinge — keep it, and let it point down at `## The loop` instead of at
   `/implement`.

What the document must *not* pick up: `cleanup-repo`'s two-pass procedure, its
green-baseline instruction, its `Explore` subagent advice and its plan format.
Those are how a review is *run*, and they belong in `critique` (step 4).

## Step 2 — Place the copies

`CODING_STANDARDS.md` into `implement/`, `critique/` and `plan-solution/`,
byte-identical. `ADR_FORMAT.md` moves from `software-design/` to
`plan-solution/`, unchanged.

The three copies being identical used to be checked by `tests/run.sh`. That check
is going away with the suite, so the copies are held identical by discipline: any
later edit to one is applied to all three in the same commit. Worth a line in the
README's "Adding a new skill" section saying so.

## Step 3 — Rewrite `implement`

Generic. The description is the point of the proposal, so it goes first:

```yaml
name: implement
description: Write, build or change software - a feature, a fix, a refactor.
  Fires on "implement", "build", "write the code", "add", "fix", and on any
  request to change what a codebase does.
```

No `disable-model-invocation`. This is the one skill in the repo that should fire
without being typed for anything code-shaped.

Body, in order:

1. **Understand what is being asked** before writing anything — what exists
   already, what the change has to be true of when it is finished. Where the
   request does not settle something that changes what gets built, ask; where it
   settles it badly, say so once and build it.
2. **`CODING_STANDARDS.md` is what the code has to look like.** Read it. Its
   `## Shaping the change` applies when the change introduces a concept the
   codebase has no name for or moves a boundary; its `## Writing the code`
   applies always.
3. **Build it test-first**, following the document's `## How it gets written`.
   The loop itself is not restated here — that is the duplication the merge
   exists to remove. What stays here is the instruction to follow it.
4. **Run the project's checks** — the combined command where there is one
   (`npm run check`, `make check`, `just check`), otherwise the pieces. Report
   the real result.
5. **Review it in a session that did not write it.** Spawn `critique` as a
   subagent with a fresh context, handing it the diff, the checks' result, and
   what was asked — not the reasoning that produced the code. A reviewer that has
   already accepted every step is not a reviewer, and that property survives here
   only because the subagent starts cold.
6. **Fix what comes back**, blockers and should-fix, test-first like anything
   else. Then review again. **At most two rounds**: stop when a review returns
   clean or when the second round is done, and report what is left standing —
   nits, anything you disagreed with, anything you chose not to fix and why.
   Silently dropping a finding is the failure mode this budget invites.
7. **Commit**, following `git-commit-message`. Stage the files this change
   touched and nothing else; never `git add -A`.
8. **Stop rather than improvise.** A missing precondition looks like five minutes
   of work and often is — and then the change contains something nobody asked
   for. Say what is missing and stop.

What is deleted from the current file, and where it goes:

| Deleted | Where it lives now |
| --- | --- |
| The red/green/refactor loop | `CODING_STANDARDS.md` `## The loop` |
| "Prove the contract before you hand it over" | `CODING_STANDARDS.md` `## Prove the contract` |
| "The ticket's `Done when` is the definition of done" | `run.sh`'s prompt |
| "Never open the solution" | `run.sh`'s prompt |
| "Respect the ticket's `## Not here`" | `run.sh`'s prompt |
| `blocked` / `undecided` / `mystery` halt kinds | `run.sh`'s prompt |
| "Set `status: review`, or `status: halted`" | `run.sh`'s prompt |
| "Write the ticket's `## Record`" | `run.sh`'s prompt |
| "On a second pass, `## Findings` is the brief" | dropped — there is no second pass now that the review is in-session |
| "You do not review your own work" | kept, inverted: it is now the reason step 5 uses a subagent |
| "Do not reopen the solution" | dropped — a generic build has no solution to reopen |

The skill must say nothing that contradicts the ticket protocol `run.sh` will
inject. Saying nothing about tickets is how that is achieved.

## Step 4 — Rewrite `critique`

Two jobs: judge a change or a whole repository against `CODING_STANDARDS.md`
adversarially, and emit something plan mode can act on.

Frontmatter: the description broadens to a change **or a repository**, and loses
every mention of a ticket. It must still beat a generic code review, so it keeps
the explicit trigger list.

Sections:

- **`## Scope`** — two modes now, not three. A set of changes (a diff, a branch, a
  PR) or a whole project. The ticket mode is deleted outright. Ask if ambiguous.
- **`## Whole-project mode`** — this is where `cleanup-repo`'s procedure lands:
  confirm the suite runs and is green first and note pre-existing failures, spawn
  parallel `Explore` subagents across areas and synthesize, and be explicit that
  a green suite proves nothing about code it never runs — where a proposal is not
  backed by a test that would catch the regression, its confidence drops.
- **`## What to check`** — every property in `CODING_STANDARDS.md`. The three
  properties that are the reviewer's own work stay verbatim: the checks pass,
  coverage maps, callers still work. `cleanup-repo`'s "actively try to find a use
  that proves the code is still live" joins them as a fourth, because a deletion
  proposal is the one finding that is wrong in the expensive direction.
- **`## The bar a finding has to clear`** — the constructed trigger and the
  destination survive. The destination simplifies: `CODING_STANDARDS.md`, every
  section of it, since there is no ticket or solution to trace to any more. The
  "no reopening a prior ticket's `Unresolved` adjudication" rule is deleted — it
  named a mechanism that no longer exists — and the fourth verdict count goes
  with it.
- **`## Verify before reporting`** — unchanged. This is what keeps the output
  worth reading.
- **`## Output`** — rewritten, and this is proposal 2's substance.

The output is a prioritized list of **change proposals**, not observations.
Severity stays `blocker` / `should-fix` / `nit`, with the existing rule that
severity is what the defect does and never what it could become, and that between
two levels you take the lower one. What changes is that each entry is written so
a planning session can pick it up without asking a question:

```markdown
### Blockers

1. **<what to change, as an imperative>** — `path/to/file.ts:88`
   What is wrong: <the defect, in a sentence>
   Why it matters: <the cost, concretely>
   Trigger: <for correctness and security — the input or state, and the wrong
             result it produces; this is the one that survived refutation>
   The change: <what would fix it, specifically enough to act on>
```

Then `### Should-fix`, then `### Nits`, same shape.

And a fourth group, which is where tier 3 surfaces:

```markdown
### Tradeoffs for you to decide

<Code that works, is used and is correct, but costs more than it is worth.
 Each states the value, the cost, and what is lost if it goes. These are never
 applied without their own explicit go-ahead, and they are deliberately kept
 out of the three groups above so nothing applies one by accident.>
```

Closing note in the skill: the list is written to be handed to plan mode
verbatim, which is why every entry names a change rather than a symptom, and why
the tradeoffs are fenced off from the rest.

What `critique` no longer does: write into a ticket's `## Findings`, read a
`## Record`, break behaviour to check a named test, touch frontmatter, or print a
`VERDICT:` line. The breaking-and-restoring paragraph goes entirely — it was the
one thing in the file that edited code, and its purpose was checking a ticket's
Record.

## Step 5 — `solve` → `find-solution`

`git mv solve find-solution`, and `SOLVE_FORMAT.md` → `SOLUTION_FORMAT.md`
(the old name described the skill; the new one describes the artifact, which is
what the other format files do).

`SKILL.md` changes:

- `name: find-solution`. Keep `disable-model-invocation: true` — the reasoning
  that made it typed has not changed, and the measurement behind it is recorded
  in `plan-solution`.
- The record section: **write to `intents/YYYY-MM-DD-<slug>/02-SOLUTION.md`**,
  the same dated directory `/idea` created, with the intent at `01-INTENT.md`
  beside it. Where `/idea` has not run — the short path — create the directory and
  write `02-SOLUTION.md` into it anyway, with no `01-INTENT.md`; the conditions
  live in the solution's own `## Intent` section as they do today.
- Delete "and ask where it goes if the project has not settled that". The layout
  is settled now.
- **`Run `/verify`** becomes: spawn a subagent with a fresh context, hand it
  `VERIFY.md` from this skill's directory, the solution's path, and the intent's
  path.
- The handoff names `/plan-solution` instead of `/slice`.
- Remove the instruction to read `VERDICT_*.md` before writing the tradeoffs —
  those files were retired with the old pipeline and nothing writes one now.
  (Flagged: this is a live instruction pointing at nothing, which the deleted
  `no-dangling` suite would not have caught since it only checked backticked
  paths.)

`SOLUTION_FORMAT.md` changes: the `## Intent` section names `01-INTENT.md` in the
same directory rather than a filename anywhere; everything else stands.

## Step 6 — `slice` → `plan-solution`

`git mv slice plan-solution`, `SLICE_FORMAT.md` → `TICKET_FORMAT.md`.

This is the proposal with the most new behaviour, so the skill is restructured
rather than edited.

**Input.** A solution — `02-SOLUTION.md`, or a description in the conversation.
The current refusal ("where there is no solution yet, there is nothing to slice")
softens: prose describing a settled approach is acceptable input, prose
describing a problem is not, and that is `/idea`'s.

**The cut.** Unchanged, and it is the good part of the existing file: vertical,
one seam, non-goals placed into `## Not here`, edge cases placed into
`## Done when`, open concerns settled or a reason not to cut yet, ordered by need
via `after:`, a criterion split across two slices sent back to the solution.

**Then the count decides the path.**

*One slice.* Enter plan mode and plan it there. Nothing is written to
`tickets/`: a single slice has no dependency to record, no second builder to brief
and no runner to drive, and a ticket file for it is paper produced for nobody.
The session stays in plan mode and the plan is approved the ordinary way.

*More than one slice.* Plan mode cannot be entered once per slice without a human
stop per slice, so the planning happens in context, following
`plan-solution/PLANNING.md` (step 7) for each slice in turn. Each plan is written
into its ticket at `intents/<slug>/tickets/NN-<slug>.md`.

**The order still matters, and it is the existing four steps with the verify step
rewired:**

1. Work the slicing out in context.
2. Check it — subagent, fresh context, handed `VERIFY.md` and the solution path.
3. Present it and get approval. What is approved is the slicing, not the files.
4. Write the tickets, and any ADR the change earned (`ADR_FORMAT.md` is in this
   directory now, and `CODING_STANDARDS.md` `## What deserves an ADR` says which
   decisions those are). Transcribe what was approved; an idea you have while
   writing the files is an idea that skipped the approval.

**`TICKET_FORMAT.md` changes:**

- Two-digit numbering: `intents/<slug>/tickets/01-<slug>.md`. Append-only, as
  before.
- `solution: 02-SOLUTION.md` — resolved relative to the ticket directory's
  parent, not the working directory.
- A new `## Plan` section, after `## Context`, holding the per-slice plan: the
  concrete steps in order, the files each touches, and what proves each one
  worked. This is what "create one plan per slice" produces, and it is why a
  ticket is now worth more than its criteria.
- `## Findings` is deleted from the format. Nothing writes it any more — the
  review moved inside the build session, and the runner's review step is retired.
- `## Record` stays: `run.sh` asks for it and `/accept-intent` reads it.
- `status` loses nothing, but `reviews` goes (step 9).

**Re-slicing** keeps its three rules unchanged: committed tickets are immutable,
numbering is append-only, it goes back through plan mode.

**Retire the "Why this one is typed" section's forward-looking half** but keep the
measurement — it is the only record of why these skills are typed, and the
`handoffs` suite that duplicated it is being deleted.

## Step 7 — Write `plan-solution/PLANNING.md`

The instructions that produce one slice's plan, written in this repo's voice.
What it has to carry, at minimum:

- **Read before planning.** The code the slice touches, not a guess at it. Name
  the files; a plan written against an imagined codebase is the failure this step
  exists to prevent.
- **The plan is steps, in order.** Each one small enough to be wrong on its own.
  Each names the files it touches and what it changes about them.
- **Each step says what proves it.** The test that will pin it, or the command
  that will show it working.
- **What it does not do.** The boundary against the neighbouring slices, which
  becomes the ticket's `## Not here`.
- **What is still unknown**, and what would settle it. A plan that pretends to
  certainty it does not have is worse than one that flags the gap.
- **No new requirements.** The slice's criteria are quoted from the solution and
  the plan implements exactly those. A plan that adds a criterion has widened
  work nobody approved.

Explicitly *not* a copy of Claude Code's plan-mode prompt.

## Step 8 — The three `VERIFY.md` files

`verify/SKILL.md` splits three ways, and the copies are **deliberately
different** — each holds only the contract for its own stage, in that stage's
vocabulary, with the shared rules restated in terms of what this stage's reader is
actually doing. A generic file copied three times would be the thing the split
exists to avoid.

Common to all three, but worded per stage: run in a subagent with a fresh context;
check against the stage's input only, never relitigating a ratified decision; try
to refute a finding before filing it; say who each finding is for; return a
verdict rather than a mood; say plainly when the artifact is sound; do not rewrite
the artifact.

**`idea/VERIFY.md`** — the intent contract. Re-derive the problem from the user's
own words, cold, and say where the reading diverges. Complete and free of
contradictions. Every condition observable and about the problem rather than the
answer. The problem names no mechanism. The evidence is checkable and no argument
is dressed as an observation. Plus the shape checks the deleted
`intent-format.sh` used to do, now done by reading and said to be a reading:
sections present, `C-n` contiguous from 1, no gaps or reuse.

**`find-solution/VERIFY.md`** — the solution contract. Coverage both ways, by
reading: every criterion tagged, every condition of the intent carried by some
criterion. Then the part no suite could do — whether a tag is *true*, not merely
present: take each one, ask what would have to be built for the condition to
hold, and ask whether this criterion asks for that. Then hunt the unlisted
drawback, check the ruled-out reason is true, look for the candidate nobody
considered, and test severity against the intent's constraints — violates none
(a tradeoff), violates one (disqualified, say which), or the constraints are
silent (needs the person who ratified the intent).

**`plan-solution/VERIFY.md`** — the slicing contract. Arrives as text, before any
file exists. Every ticket traces to a criterion and every criterion lands in a
ticket. Each slice vertical — buildable and testable alone, not a layer. The
criteria copied, not summarised; a quotation that stops a sentence early has
dropped a requirement. And now also: each plan's steps implement the criteria the
ticket quotes and nothing beyond them.

Every reference to `tests/*-format.sh` is removed from all three — the suites are
gone, and the existing instruction "where the suites are not in this project, the
checks are yours to do by reading; say in your report that you did, because a
reading is not a run" becomes the only mode.

Then `delete verify/`.

## Step 9 — Rewrite `run.sh`

Four changes; everything else stands, including the refusals, the drift
pre-flight, the usage-limit wait, the HEAD-moved check and the stuck report.

**1. The ticket protocol moves into the build prompt.** `session()` stops sending
`"Use /$2 on $1"` and sends `/implement` followed by the protocol as text:

> Use /implement on the work described in `<ticket>`.
>
> That file is the whole brief. Its `## Done when` is the definition of done —
> not the diff, not what you would have built. Its `## Not here` names what
> another ticket owns; building it is two tickets building the same code. Its
> `## Plan` is how it was decided this gets built.
>
> Do not open the solution the frontmatter names. The ticket quotes what it
> needs, and going upstream is how a ticket quietly becomes a different one.
>
> When the criteria are green and the checks pass, write `## Record` — which
> test names which criterion, and the command you ran — commit the code and the
> ticket together, and set `status: review` in the frontmatter.
>
> If you cannot proceed, write `## Halt` naming the kind and stop: `blocked` (a
> precondition the ticket assumed is not there), `undecided` (a decision the
> ticket does not settle and that is not yours to settle), `mystery` (a failure
> you cannot explain, which is different from one you cannot fix). Then set
> `status: halted`. Never write `status: doing` or `status: done` — those are
> the runner's.

**2. The review session is retired.** The `session "$ticket" critique` call, the
`## Findings` clearing, the `reviews` counter, `MAX_REVIEWS` and the
review-exhaustion halt all go. `implement` now reviews itself through a
fresh-context subagent, so a second review session reviews a review. A ticket
that reaches `review` with a moved HEAD goes straight to `done`.

**3. Paths.** The argument is `intents/<slug>/tickets`. The `solution:` field
resolves relative to the ticket directory's parent, so the pre-flight looks for
`$(dirname "$TICKETS")/$solution`. The two-digit ticket numbers change nothing —
`after:` still names `NN-<slug>` and the lookup is still `$TICKETS/$dep.md`.

**4. The run closes with the walk.** When every ticket is done, `run.sh` launches
`/accept-intent` on `$(dirname "$TICKETS")/01-INTENT.md`, prints what it found,
and exits 0 without merging, marking or deciding anything. Where there is no
`01-INTENT.md` — the short path — it names the solution instead and says the walk
was skipped. A failed walk is printed, not an exit code: the runner does not get
to decide the change is wrong.

Also update the header comment, which currently describes the two-session loop.

## Step 10 — `idea` and `accept-intent`

`idea/SKILL.md`: `/verify` becomes the subagent-with-`VERIFY.md` instruction, and
the default path sentence loses its "by default" hedge — the layout is settled.
The handoff at the end names `/find-solution`.

`accept-intent/SKILL.md`: eleven lines, and it takes an intent path now that
`run.sh` passes one. Add that it reads each ticket's `## Record` alongside the
walk — the Record is the only evidence a criterion was covered rather than
claimed, and with `critique` no longer checking it, nothing else reads it.

## Step 11 — Delete

```
git rm -r coding-standard/ software-design/ cleanup-repo/ verify/ tests/
```

`solve/` and `slice/` are gone already via the renames in steps 5 and 6.

`tickets/new-pipeline/` is left alone: it is the record of how this pipeline was
built, it names a `SOLUTION_NEW_PIPELINE.md` that was already deleted, and
nothing live reads it. Flagged rather than decided — say the word and it goes
too.

## Step 12 — Rewrite `README.md`

- The pipeline diagram, as drawn above.
- The skill list: delete `cleanup-repo`, `coding-standard`, `software-design`,
  `solve`, `slice`, `verify`; add `find-solution`, `plan-solution`; rewrite
  `implement` and `critique` to their new jobs.
- A new paragraph on `CODING_STANDARDS.md` — what it is, that three skills hold
  identical copies, and that an edit to one is an edit to all three in the same
  commit.
- Delete `### The tests` entirely.
- `### The runner`: drop the review half and the `reviews`/`exhausted`-from-review
  halts; add the closing walk.
- `### What holds it together`: "Nothing approves its own work" needs rewording —
  it is still true, but the mechanism is now a fresh-context subagent inside the
  build rather than a separate session launched by the runner.
- `### Adding a new skill`: note the duplicated-file convention now that no test
  enforces it.

---

## Commits

One per step, except where a step is meaningless alone:

1. Write `CODING_STANDARDS.md` and place the three copies (steps 1–2).
2. Make `implement` generic and give it the review subagent (step 3).
3. Turn `critique` into the adversarial review with plan-ready output (step 4).
4. Rename `solve` to `find-solution` and move it to the intent directory (step 5).
5. Rename `slice` to `plan-solution`, add the plan per slice (steps 6–7).
6. Split `verify` into a `VERIFY.md` per stage (step 8).
7. Rewire the runner around one session per ticket (step 9).
8. Point `idea` and `accept-intent` at the new shape (step 10).
9. Delete the retired skills and the test suite (step 11).
10. Rewrite the README (step 12).

The tree is broken in the middle — step 2's `implement` names a `critique` that
does not exist in its new form until step 3, and the renames in 4 and 5 dangle
until 8 and 10. That is accepted: there is no suite to keep green, and splitting
the work further would produce commits that each half-state a skill.

## What I am flagging rather than deciding

- **`tickets/new-pipeline/`** — left in place as history. Delete it if you would
  rather the tree held only live paper.
- **Three identical copies with nothing checking them.** The byte-identical test
  goes with `tests/`. The README will say the rule; nothing will enforce it.
  This is the one place the change makes the repo weaker, and it is a direct
  consequence of deleting the suite.
- **`find-solution` reading `VERDICT_*.md`** — a live instruction pointing at
  files that no longer exist. Removed in step 5; noting it because it is a bug
  that predates this change.
- **`implement` firing broadly.** Its description is meant to catch every
  code-writing request, which means it will also fire on three-line edits where
  a critique subagent and two review rounds are more process than the change
  deserves. The skill should say that in a line — proportion is the reader's
  call — but it is worth watching in the first few real runs.
