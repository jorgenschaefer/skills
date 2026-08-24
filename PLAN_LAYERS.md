# Plan: three layers, and the loop knowledge in one of them

A draft, not a decided build. The shape below is settled enough to argue with;
the open decisions at the bottom are not settled at all. It is deliberately
short - a plan that needs five hundred lines of argument is evidence the change
is too big, and that is the failure this one exists to avoid.

## Why

This changes nothing about what the pipeline does. It changes only where its
knowledge lives.

The suite grows and never shrinks. Every line was added because a run went
wrong; no line has ever been removed because a run went right. One cause of
that ratchet is fixable by restructuring: craft knowledge and loop knowledge
share a file, so they share a change rule.

- **Craft** is chosen, slow, and validated by a career of writing software. It
  should almost never change, and it needs no evidence, because a standard is
  picked rather than discovered.
- **Loop knowledge** is empirical, fast, cheap to falsify, and currently
  validated by two runs. It should change often, on evidence, and be deleted
  when a run stops needing it.

One corpus means one change rule, so today every loop lesson gets written in
the permanent register of a standard, and the accretion - which is nearly all
loop lessons - lands in the craft files and inflates them. Separating them is
what makes two different change rules possible. That, and not reuse outside the
loop, is what this buys.

## The layers

- **Craft.** How to build, review, specify, debug, name. Holds no opinion about
  who is watching. Useful typed by hand with no spec, no ticket and no loop.
- **Contract.** The shapes that make an unattended handoff possible:
  `SPEC_FORMAT.md`, `TICKET_FORMAT.md`, and the vocabulary inside them -
  `spec_hash`, `status`, the four halt reasons, `Record` and its subsections.
  Should be the smallest and most stable of the three.
- **Orchestration.** What runs when, and everything that follows from nobody
  being present: halting instead of asking, the drain, the pass ceiling,
  retries, terminal states.

The sorting test, for the margin: *would this line still be true if a competent
human were doing the work by hand, with no ticket and no loop?*

- "Duplication is justified or removed" - yes - craft.
- "Assert on what the code produces, not that a mock was called" - yes - craft.
- "Halting is a normal outcome" - no, it presupposes nobody to ask -
  orchestration.
- "Run everything in the foreground" - no, it presupposes `claude -p` -
  orchestration.
- "A verdict is a claim to verify; a bare *looks good* is not a review" -
  borderline, and instructive. You would trust a human reviewer's word more.
  Its stated justification is that no human is watching, so it is an
  orchestration rule currently wearing craft clothes.

## Most of this already holds

Counting lines that name a ticket, a halt, a status, `spec_hash`, the loop or
unattendedness:

| skill | hits | reading |
|---|---|---|
| `implement` | 38 | the only real extraction |
| `plan` | 28 | orchestration by definition, nothing to extract |
| `propose-change` | 16 | almost all of it the word "ticket" |
| `handover` | 12 | craft body, kept; see *Settled* |
| `trace` | 11 | orchestration, plus a craft body worth keeping |
| `discovery` | 4 | four sentences, all removable |
| four more | 1-2 | incidental |
| the other six | 0 | already clean |

So the craft tier mostly exists already. `critique/SKILL.md` names a ticket
exactly once, in its closing paragraph; six skills name nothing at all. This is
a subtraction at four sites, not a restructuring of sixteen.

## Where each skill lands

**Craft - eleven skills, none of which knows a run is unattended.**

| skill | change |
|---|---|
| `coding-conventions` | none. The standard both tiers read. |
| `implement` | the TDD and review craft only; the ticket contract moves out |
| `critique` | drop the closing ticket paragraph (line 52) |
| `discovery` | the sole entry point; three terminals; absorbs the weighing and the investigation |
| `propose-change` | **deleted** - merged into `/discovery` (see *Settled*) |
| `handover` | kept, rescoped: a PR description, on every terminal path |
| `decision-brief` | craft, until `PLAN_RATIFICATION.md` deletes it |
| the seven others | none - already clean |

**Contract.** `SPEC_FORMAT.md`, `TICKET_FORMAT.md`, and the vocabulary they
carry. No new artifact: this layer already physically exists, it has just never
been named, which is why loop knowledge keeps being written as advice inside
craft files instead of as a field in a format.

**Orchestration.** `loop.sh`, `spec-to-tickets`, `check-against-spec`, and a new
`implement/TICKET_MODE.md` holding the 33 lines currently inside
`implement/SKILL.md` - *Say what you are doing*, *Nothing runs in the
background*, *Halting*, the no-questions preamble, the `REVIEWS=code`
paragraph. `implement` stays one installable skill and dispatches on whether
its input is a ticket path or a sentence; a wrapper skill buys a second
registry entry and hard enforcement, and indirection has to pay for itself.

## How they are tied together

```
orchestration   loop.sh · spec-to-tickets · check-against-spec
                implement/TICKET_MODE.md
       │        knows nobody is present; dispatches craft skills by name
       ▼
contract        SPEC_FORMAT.md · TICKET_FORMAT.md
       │        read by whoever writes or reads one of those artifacts
       ▼
craft           coding-conventions · implement · critique · discovery
                handover · debug · repo-overview · cleanup-repo
                upgrade-dependencies · git-commit-message · improve-skill
                ubiquitous-language-init
```

**The arrows only point down.** Orchestration may know about the contract and
about craft. Craft may know about the contract where it writes or reads one -
`discovery` writes a spec. **No craft skill
may carry orchestration knowledge**, and that is the one rule worth enforcing,
because it is the one that keeps loop lessons out of the craft files.

Runtime wiring is unchanged for a feature: `/discovery` writes a spec,
`/spec-to-tickets` decomposes it, `loop.sh` drains the tickets through
`/implement`, then `/check-against-spec` and `/critique`. What changes is that
the loop's skills *read* the craft skills
rather than restating them - which is already the pattern for
`coding-conventions` and is now the rule rather than a coincidence.

**One door, three terminals.** The routing cannot happen at the entrance,
because size is what the conversation discovers - asking someone to pick a door
is asking them to answer the question the conversation exists to answer.
`/discovery` becomes the sole entry point and ends in one of three places:

- **a spec** - `/spec-to-tickets` decomposes it, the loop builds it. A feature.
- **a shaped instruction** - `/implement` builds it. A change or a bugfix.
- **a reasoned no** - the change is not worth making. A legitimate ending.

A ticket appears in only the first. It was never the unit of judgment - it is
the unit of *unattended handoff*, and the other two terminals have a human
present. The second is also not new work: it is the floor the README already
describes ("no difference at all means it doesn't want a ticket") finally
having a named path, and the only difference is that "wants doing directly" now
goes through the same TDD and review craft as everything else.

Those are `propose-change`'s four honest verdicts (`:60`) minus "it's actually a
feature", which stops existing when there is one door. So `/propose-change` is
deleted, and `/discovery` absorbs what was genuinely its own rather than shared:
the cost/benefit weighing, the verdict, and the codebase investigation that
`/discovery` today only skims.

The apparatus objection does not survive contact with the four checks a bugfix
actually needs. *What is the real bug* is `discovery/SKILL.md:18`, verbatim.
*Is this the right solution, or an XY problem* is the same line. *A reproduction
case for the test* is a given/when/then criterion (`:47`), and
`propose-change/SKILL.md` already frames it exactly so - "for a bug, the
reproduction case is a criterion, phrased so it becomes the failing test". Only
*what else is affected* is propose-change's alone. Three of the four are
already discovery's opening moves, so the merged skill is mostly deletion.

Statedness survives as the parameter it always was, not as a door: whether the
change arrives already stated is what decides how much interviewing precedes
the investigation. That is a branch inside one skill, and it is what
"scale the interview to the feature" (`:10`) already says.

Two things the merge must carry. **The ceremony lives in the output contract,
not in the interview** - `SPEC_FORMAT.md`'s "number everything, not optional at
any spec size" is what would force a bugfix through stories, a `/plan` run and a
loop. The shaped-instruction terminal is what prevents that, and without it the
merge makes ceremony worse rather than better. And **`/debug` is the skill
`/discovery` reaches for when the input is a bug** - reproducing and root-
causing is already a skill, craft calling craft, so the merged skill does not
absorb debugging technique.

## Enforce it with a grep, not with discipline

Prose has no failure mode, which is why the suite accreted in the first place.
So the layer rule ships as a test in `tests/run.sh`: grep every craft skill for
`halt`, `status:`, `spec_hash`, `depends_on`, `unattended`, `loop.sh`, and fail
on a hit. The allowlist is the orchestration tier plus the format files.

Without this, the layering is another paragraph asking a reader to be
disciplined, and it will have leaked back within three features. With it, the
next loop lesson written into `coding-conventions` fails a test on the way in.

## Open decisions

- **How a driver-invoked skill gets the ticket contract.** This is the plan's
  load-bearing decision, and drawing the dependency edges is what exposed it.
  Dropping `critique`'s closing ticket paragraph leaves its `TICKET_FORMAT.md`
  an orphan no line references, and `critique_prompt()` already leans on that
  copy - it says "in the shape TICKET_FORMAT.md specifies" and lets the skill's
  own copy resolve the bare name. So the cheapest-looking subtraction is not
  free; it needs somewhere else for the format to come from. Options:
  (a) leave five copies, keep `critique` line 52, and accept the leak;
  (b) ship the pipeline as one installable unit, at the cost of `npx skills add
  jorgenschaefer/skills@critique` no longer standing alone;
  (c) a `ticket-format` skill the others declare, which `skills.sh` has no
  dependency mechanism for;
  (d) `loop.sh` learns where skills live - a `SKILLS_DIR` defaulting to
  `~/.claude/skills`, which is a real directory on this machine - and its
  prompts name an absolute path instead of a bare filename.
  **Recommendation: (d).** Two lines of bash, testable in `tests/run.sh`
  against a fixture, and it is what makes the whole layering more than
  bookkeeping: with it, every skill the driver invokes - `critique`, `trace`,
  `implement` - drops its copy, and five copies become two, the two that a
  human types by hand - and with `/propose-change` no longer writing one,
  that is `plan` alone, so five copies become **one** and the byte-identical
  parity `IDEAS.md` keeps deliberately has nothing left to check. The cost is
  that `loop.sh`
  now assumes an install layout, which is a claim about the world rather than
  about the code, so it gets a startup check that fails loudly rather than a
  prompt that silently names a path nothing reads.
- **Does `trace` split like `implement`?** Its body - acceptance-test a build
  against stated requirements - is craft, and becomes more so if `IDEAS.md` #8
  lands and it drives the running software. Its output is pipeline. #15 says
  subtraction rather than a twin; that answer weakens if #8 lands.
- **Order against `PLAN_RATIFICATION.md`.** Both touch `implement`, `critique`,
  `trace` and the format copies. #15 assumed the ratification plan lands first
  and the refactor goes on green. **Recommendation: reverse it.** This plan
  changes no behavior, so it is the safe one to land first, and it makes the
  other plan's diff smaller and its content sortable - much of what that plan
  adds is orchestration knowledge that would otherwise land in craft files.

## Settled while drafting

- **`/propose-change` is deleted; `/discovery` becomes the sole entry point.**
  Reached in three moves over one conversation, and worth recording because the
  first two were wrong. First: the skill is two things welded together - the
  judgment, and the write-up as a ticket - and only the second half looked like
  orchestration, existing solely because a ticket was the one input
  `/implement` accepted. Second: the doors are cut by size, which nobody can
  answer at the door, and the exits are one-sided - `propose-change` carries
  the upward one three times (`:19`, `:23`, `:60`) while `/discovery` has no
  downward one at all, so a request that turns out small is caught by `/plan`'s
  cold audit after a whole spec has been written. Third, and the resolution:
  if the routing cannot happen at the entrance, there should not be two
  entrances. One door, three terminals.

  Against the merge, and answered: the apparatus differs. It does not, or not
  in the way it looked - three of the four checks a bugfix needs are already
  `/discovery`'s opening moves. What does differ is the *output*, and that is
  what the third terminal fixes.

  Not routed to harness plan mode either. Plan mode plans how to do what was
  asked; it does not weigh whether the change is worth making, apply the split
  test, or say a reasoned no - and none of that is repo-owned if it lives in
  the harness. `IDEAS.md` #1 already had one collision with plan mode and
  resolved it by moving *away*.

- **The two orchestration skills are renamed: `/plan` becomes
  `/spec-to-tickets`, `/trace` becomes `/check-against-spec`.** `IDEAS.md` #1
  wanted the first for two reasons - `/plan` collides with harness plan mode for
  the human typing it, and #15's principle is that tier 1 is named for the
  activity and tier 2 for the artifact. `/spec-to-tickets` satisfies the
  principle better than the `/decompose` this draft first recommended, which is
  an activity name on a tier-2 skill.

  `/trace` is jargon that says nothing about what it does, and what it does is
  the one check nothing else performs: was the thing the spec describes actually
  built, and is each criterion pinned by a test that would fail without it.
  `/check-against-spec` names that and stays true if `IDEAS.md` #8 lands and the
  check starts driving the running software rather than reading code.
  `/spec-to-gaps` would parallel `/spec-to-tickets` more neatly and is wrong:
  the transformation naming fits a step that always produces tickets, and this
  one produces a verdict, with tickets only where it finds something.
  `/acceptance-check` is out because "acceptance" already means the human
  accepting a run.

  **Rename last.** `/plan` has 50 references across 14 files and `/trace` 16
  across 10, but four of the five `TICKET_FORMAT.md` copies and three whole
  skills disappear earlier in this sequence. Renaming after them costs 8 files
  and 5 files instead of 14 and 10.

- **`/handover` is kept, and it is craft.** Its content standard is a PR
  description: what the branch does now that it did not before, what changed and
  where, what a reviewer should look at, and what is still uncertain. That is
  useful typed by hand on any branch, so it is craft with an orchestration
  caller - and it is the answer to the objection this repo's own review made of
  `PLAN_RATIFICATION.md`, which routes the same content into a deletion commit's
  body, durable but write-only. A PR description has a reader and a moment.

  It keeps *orient* and loses the other two jobs. The ranked ratification brief
  goes, for the reason `PLAN_RATIFICATION.md` gives and this does not dispute -
  a list of forty decisions handed to someone with no memory of the arguments
  gets skimmed. Promotion moves upstream. What is left is orientation plus, on a
  stop, what to do next.

  **Every terminal path produces one.** The driver already does this well twice
  and badly once: a dead session prints why, whether it retried, and the exact
  re-run command (`loop.sh:270-278`); stuck tickets print which ones, why each,
  and how to reset them (`:385-394`); non-convergence prints one line -
  "reviews still filing work after 2 passes" - and exits (`:464`). So this is
  not new behaviour, it is an existing pattern made uniform and its one gap
  filled.

  The split follows the layering. **Mechanical text is the driver's**: the halt
  reason, the commit, the paths, the command that resumes. Bash writes that, and
  `PLAN_RATIFICATION.md` is right that it is all a bash driver should write.
  **Judgement is the skill's**: what was built, what to review, what is
  unresolved. A `blocked` ticket already carries `/implement`'s own `## Halt`
  reasoning; the driver surfaces it rather than re-deriving it.

  Open: the name. `/handover` describes the moment, not the artifact, and this
  draft has just renamed two skills for being no more descriptive than that.
  `/describe-branch` and `/pr-description` are the candidates. Left open because
  naming is the author's call.

  This contradicts `PLAN_RATIFICATION.md`'s step 9, which deletes the skill.
  That plan needs re-reading either way; this is one more item for the list.

## Sequence

Each step is judgeable on its own and none depends on the next being written.

1. **The layer rule and its grep test in `tests/run.sh`**, written failing
   first against today's files. Mechanism before prose, and it tells you
   immediately how big the rest of the job is.
2. **`discovery`** - drop the four sentences describing what `/plan` does next.
   The only subtraction that depends on nothing else.
3. **`SKILLS_DIR` in `loop.sh`**, with the startup check and a fixture case in
   `tests/run.sh` written failing first. Nothing in the skills changes yet;
   this only makes step 4 possible.
4. **`critique` and `trace`** - drop the ticket paragraphs and the two
   `TICKET_FORMAT.md` copies, now that the driver names the path.
5. **`implement`** - extract `TICKET_MODE.md`, dispatch on the input shape,
   drop the third copy. The one substantial edit, and the one that makes the
   generic mode real: invoked on a sentence it *should* ask when the
   requirement is ambiguous, which is the inverse of the ticket contract and
   the leakiest seam in this plan.
6. **`discovery` and `propose-change`** - `/discovery` gains the
   shaped-instruction and reasoned-no terminals and absorbs the weighing, the
   verdict and the code investigation; `/propose-change` is deleted with its
   format copy. The largest edit in the plan and the only one that changes what
   a human does. Depends on step 5 existing, since one terminal is
   `/implement` on a sentence.
7. **`loop.sh`'s terminal handler and `handover`** - one exit path instead of
   scattered `echo >&2; exit N`, every one of them printing an explanation and
   next steps; `handover/SKILL.md` cut to the PR description. `tests/run.sh`
   gets a case per terminal path, written failing first.
8. **The renames** - `plan/` becomes `spec-to-tickets/` and `trace/` becomes
   `check-against-spec/`, directories included, with `loop.sh` and
   `tests/run.sh` following. Deliberately after the deletions, which is what
   makes it cheap.
9. **`README.md`** - the pipeline section rewritten around the three layers and
   the one door, since it is the only place the shape is explained to a reader.
   "Two front doors" goes with `/propose-change`.

Steps 2, 4 and 5 are net deletions, and so is 6 on balance. Step 3 is the only
new mechanism, and step 1 is the only new prose.

## Not in this plan

- **The epistemic labels** - standard, mechanism, claim - which are the second
  axis. They belong on lines, never on file boundaries, so they are a pass over
  the corpus rather than a restructuring. Worth doing next, and worth doing
  before `PLAN_RATIFICATION.md`, because most of that plan is claims.
- **`IDEAS.md` #2, #3, #4** - the evidence-backed fixes from the two runs.
  Untouched, and still the entries with actual tickets behind them.
- **Deleting `handover` and `decision-brief`** - `PLAN_RATIFICATION.md` owns
  that. Note the collision the other way too: that plan's step 9 gives
  `/propose-change` the three tiers, and step 6 here deletes the skill.
  Whichever lands second has to be re-read, which is one more reason to land
  this one first.
