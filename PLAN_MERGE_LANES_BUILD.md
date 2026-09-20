# Build plan: SOLUTION_MERGE_LANES.md

`SOLUTION_MERGE_LANES.md` is settled and nothing in it is built. This is how
its parts get built. It decides nothing the spec decided - what is new here
is sequencing, the shape of the gate run, the commit boundaries, and six
places where the spec's own prose is wrong about the repo and has to be
corrected before somebody builds against it.

`PLAN_MERGE_LANES.md` is the pre-spec design record and stays as it is.

**The work is attended.** `/spec-to-tickets` refuses work not observable
outside the code (`spec-to-tickets/SKILL.md:34`), so a spec about skills
cannot reach `loop.sh`. Every part is built by hand, one commit each.

## What the spec gets wrong

Verified against the repo. Each is cheap to fix and expensive to hit blind.

1. **`tests/run.sh:889` asserts exactly five `TICKET_FORMAT.md` copies.**
   Deleting `discovery/` leaves four and the suite goes red. `## Scope`'s
   *Never* lists `tests/run.sh` as out of scope for good. The spec
   contradicts itself; the *Never* line needs amending. **Yours to rule on -
   see B0.**
2. **The `zugang` material is not at `8e91c9d0`.** That commit holds the spec
   and *one* ticket. The whole set - spec, mockup, eleven tickets - is at
   `e89d1308^` = **`a09943de`**. Recovering from the cited commit gets you
   one ticket in eleven and you would not notice until the comparison.
3. **`/discovery` is already model-invoked** (`discovery/SKILL.md:2-3`, no
   `disable-model-invocation`), and its description ends *"The one way in."*
   - the same phrase the specimen gives `/idea`. Dropping `/idea`'s
   `disable-model-invocation` while `/discovery` is still installed measures
   a race between two near-identical descriptions, not a door. The spec's
   P6 -> P7 order is circular.
4. **`ADR_FORMAT.md:3` and `UBIQUITOUS_LANGUAGE_FORMAT.md:5` both name
   `/discovery`.** Copying them byte-identical, as the spec's P2 does,
   propagates the pointers P7 exists to clear from one copy to three - and
   the parity convention then forces a four-file and three-file edit later.
   Clear the lines *before* copying.
5. **Counts.** `TICKET_FORMAT.md` carries seven references each, not six.
   `loop.sh` carries one comment, not "one comment and one narration string".
   `handover/SKILL.md` carries three, as stated. `/spec-to-tickets` carries
   ten bare-word uses *plus* five `/discovery` routes; the ten is right only
   once the routes are gone. Find them by grep, not by these numbers.
6. **`grep -rn discovery` can never come back clean.** `README.md:114` is a
   frontmatter example - `description: One-line description used for
   discovery` - a correct use of the English word. The check is
   `grep -rn '/discovery'` plus a named exemption list.

## Where this stands

B0 through B5 are built and committed, one commit each (plus one for a
pre-existing red case the parity work uncovered). The suite is green at 240
passing.

B6a is built: the gate's reference material is recovered from `a09943de` and
the rubric's left-hand columns are written - 51 criteria with their claiming
tickets, four constraints, twenty-eight defaults with the binding ones
marked, the seams of tickets 01-08, and the four journeys the old lane
agreed. An isolated clone sits at `c8f509d1` on a `gate` branch with the
edited skills symlinked into it.

**B6b has not run.** It is three interactive sessions - `/idea` blocks on the
problem statement, `/to-solution` blocks on the decision criteria, on the
comparison and at the close - and a gate judged by whoever ran it is not a
gate. B7 and B8 wait on its verdict, which is what the spec means by calling
it the gate.

## Sequence

```
B0 → B1 → B2 → B3 → B4 → B5 → B6a → B6b (GATE) → B7a → B7b → B8
```

| Step | Spec part | What |
|---|---|---|
| B0 | - | Three rulings the parts assume and never settle |
| B1 | P2 (clerical half) | The shared format files, cleaned then copied |
| B2 | P1 | Rename the decision criteria |
| B3 | P2 (judgement half) | `/to-solution` learns the corpus can be code |
| B4 | P3 | The solution spec gains its anchors |
| B5 | P4 | `/spec-to-tickets` reads a solution spec |
| B6a | P5 (rubric) | Write the comparison tables' left-hand columns |
| B6b | P5 (run) | **The gate.** Re-run `zugang`, fill the right-hand columns |
| B7a | P7 | Delete `discovery/` and clear every pointer to it |
| B7b | P6 | `/idea` becomes the door |
| B8 | P8 | `/find-solution` retires |

Two changes to the spec's order, each with a reason:

- **The gate's rubric is written before the run.** A rubric written after
  seeing the result is the failure `/to-solution` itself names
  (`to-solution/SKILL.md:62`): criteria invented afterwards exist to justify
  a winner. B6a builds the left-hand columns from `a09943de` before the new
  lane runs.
- **`/idea` becomes the door only once `/discovery` is gone.** `/discovery`
  is already model-invoked and its description already ends *"The one way
  in."* - the same phrase the specimen gives `/idea`. Dropping `/idea`'s
  `disable-model-invocation` first would measure a race between two
  near-identical descriptions rather than a door.

An earlier draft of this plan moved the pointer sweep ahead of the gate, on
the grounds that it is prose and depends on nothing. That was wrong: the
pointers are *accurate* while `/discovery` is on disk, and rewriting them
first would make the repo describe a lane that does not exist yet. They move
with the deletion, as the spec had it.

## The steps

### B0 - Settle what the parts assume

Three rulings, then a commit that records them in
`SOLUTION_MERGE_LANES.md` itself:

- **The parity convention at four copies.** `tests/run.sh:882-891` pins the
  literal 5 and explains why. After this work the counts are: four
  `TICKET_FORMAT.md`, three `UBIQUITOUS_LANGUAGE_FORMAT.md`, two
  `ADR_FORMAT.md`. Recommended: generalise the assertion to *every group of
  same-named `*_FORMAT.md` files is md5-identical*, which stops pinning a
  number that will move again. That requires amending `## Scope`'s *Never*,
  which today forbids touching `tests/run.sh`.
- **The `grep` exemption list** for the retirement checks: `IDEAS.md`, the
  vendored `writing-great-skills/GLOSSARY.md`, this topic's own paper, and
  `README.md:114`.
- **Correct the `zugang` citation** from `8e91c9d0` to `a09943de`.

### B1 - The shared format files

- Rewrite `discovery/ADR_FORMAT.md:3` and
  `discovery/UBIQUITOUS_LANGUAGE_FORMAT.md:5` so neither names `/discovery`.
  Mirror the second into `ubiquitous-language-init/`, which holds an
  md5-identical copy today.
- Copy both, byte-identical, into `to-solution/`, which will propose both.
- Copy `ADR_FORMAT.md` into `handover/`, which names it at
  `handover/SKILL.md:34` without holding a copy - a live break under the
  shared-format convention.

  `handover/SKILL.md:33` names `UBIQUITOUS_LANGUAGE.md`, the *artifact*, not
  the format file. The spec's "all four copies" implies `handover/` gets one
  too; nothing in the survey justifies it. **Default: three copies, not
  four**, and say so.

Done when `md5sum` over each same-named group is a single hash, and no copy
names `/discovery`.

### B2 - Rename the decision criteria

`to-solution/SOLUTION_FORMAT.md:19` `## Criteria` becomes `## What decided
it`. One step downstream *criteria* means the ids tickets claim, and two
readings of one word in a file a decomposer now reads produces a wrong ticket
set exactly once.

Then disambiguate every use in `/to-solution`. The spec names three
(`:15`, `:41`, `:62`); there are seven - `:3` (the frontmatter description),
`:15`, `:41`, `:62`, `:64`, `:72`, `:76` - plus
`SOLUTION_FORMAT.md:5`, `:17`, `:19`, `:37`. The Done-when quantifies over
all of them.

### B3 - `/to-solution` learns the corpus can be code

- One paragraph into *Before you design*, from
  `SPECIMEN_MERGE_LANES.md:102-108`: where the corpus is a codebase, the
  reading is the code, plus `UBIQUITOUS_LANGUAGE.md` and the ADRs, plus
  `ARCHITECTURE.md` as a lead rather than as truth; `coding-conventions` is
  the standard. Not a mode, not a branch.
- Absorb `/find-solution`'s two unique moves: *reversibility breaks
  near-ties* (`find-solution/SKILL.md:52`) into phase 2, and *the four kinds
  are a floor, not the exercise* (`:31`) into phase 1.
- Absorb its third ending - recommend without recording (`:62`) - into phase
  3 beside the spec and the block.

Decide here, and write it down: **the spec is written in the corpus's own
language.** `zugang.md` is German because `/discovery` read a German corpus
first. Nothing in `/idea` or `/to-solution` says so today, and if B6b comes
back in English that is a finding against this step, not against the gate.

Done when `/to-solution` states three endings and a run on a code change
reads the codebase, the glossary and the ADRs.

### B4 - The solution spec gains its anchors

`to-solution/SOLUTION_FORMAT.md` gains, per `SPECIMEN_MERGE_LANES.md:25-63`:
`## Domain` as one paragraph rather than `SPEC_FORMAT.md`'s four
subsections; `## Defaults` with `D-n` and `_Overturnable on:_`;
`## Implementation decisions` carrying the duplication survey's verdicts
numbered in place; `## ADRs`. `## Non-goals` is already `## Scope`'s *Never*
- confirm, do not add.

**The preamble is a rewrite, not a port.** `SPEC_FORMAT.md:5-13` carries
three things that each change:

- the tier list, whose permanent tier drops from three members to two, a term
  and an ADR, because ratified journeys are no longer a concept;
- the numbering rule (*"Number user stories `US-1`… always, without
  exception"*), which is **false for the file `/to-solution` writes** and
  true only of the hardened state;
- the freeze rule, which belongs to the hardened state alone.

So the preamble becomes two-voiced: *as written by `/to-solution`* and *as
hardened by `/spec-to-tickets`*. That is judgement, and the Part's Done-when
does not reach it.

`to-solution/SKILL.md` gains the matching moves. **The domain model is
modelled in phase 2 and shown at stop 2**, not in a stop of its own - the
comparison is already the turn where candidates are laid out to be
corrected, and how each one carves the domain is part of what separates
them. The three stops stay three.

**Port process, not explanation.** Every line moved from `/discovery` passes
the no-op test: does this change what a model does, or does it define a term
the model already holds? *Aggregate*, *bounded context*, *entity*, *domain
event* are used and never defined. What ports from
`discovery/SKILL.md:107-125` is the judgement - the boundary is usually what
makes one candidate fit and another not (`:115`); a traced domain story
announces its own missing steps (`:119`); bounded context is noted only when
the change crosses or establishes one (`:111`); the show-back is in the
user's language (`:121`). Under 200 words, inline.

### B5 - `/spec-to-tickets` reads a solution spec

The hardening front half, from `SPECIMEN_MERGE_LANES.md:71-95`: number
`US-n.m` from each part's *Done when* with `n` the part index; number the
constraints `C-n`; derive the journeys from `## Design` and `## Parts` and
show them back before decomposing; mark the binding defaults; hash the file
it leaves.

*Before starting* (`:17-24`) loses the `tests/workflows/` read and points at
`SOLUTION_FORMAT.md` instead of `SPEC_FORMAT.md` - including `:23`, which
says where the mark goes back, and which now has a two-state file to point
at.

The five routes back to `/discovery` become questions asked of the user, who
is present.

**Known left standing, deliberately.** *Authorise the workflow tests a
ticket will reach* (`:75-86`) and its review item (`:109`) rest on a journey
being *ratified*, which no longer exists - while the skill now derives
journeys itself. The spec parks the whole apparatus in `## Scope`'s *Later*.
Say so in the commit rather than letting a reader find the seam.

Done when it turns a `SOLUTION_FORMAT.md` spec into a hardened spec and a
ticket set that passes its own falsification review, and it still accepts a
`SPEC_FORMAT.md` spec.

### B6a - Write the rubric before the run

Recover the old lane's output from **`a09943de`** into a directory the run
will never see:

```
git -C ~/Projects/drk-barmbek show a09943de:kh/docs/spec/zugang.md
git -C ~/Projects/drk-barmbek ls-tree -r --name-only a09943de -- kh/docs/spec/tickets
```

Then build the left-hand columns of three tables:

1. **Criterion coverage.** Every `US-n.m` from `zugang.md`, as an assertion
   sentence. They are quoted verbatim in each ticket's `Satisfies`.
2. **Constraint and binding-default coverage.** `C-1`..`C-4`, and the `D-n`
   set with the binding ones marked.
3. **Seams.** Tickets **01-08 only**. Tickets 09, 10 and 11 were filed during
   the run by `/check-against-spec` and `/critique`, not by
   `/spec-to-tickets`; comparing against all eleven makes the new set look
   artificially bad. Keep 09-11 as a separate probe: does the new
   decomposition pre-empt any of the three things the old one missed? That is
   the only place the gate could show the new lane is *better* rather than
   merely not-worse.

Record the old lane's four journeys (`J-1`..`J-4`) separately. Whether the
derived journeys match them is the evidence the spec's fourth open concern
asks for, and it gets its own verdict rather than being folded into
pass/fail.

### B6b - The gate

**Baseline matters more than anything else here.** Clone, do not worktree -
a worktree still writes into `drk-barmbek/.git`:

```
git clone --no-hardlinks ~/Projects/drk-barmbek <scratch>/zugang-gate
git -C <scratch>/zugang-gate checkout -b gate c8f509d1
```

`c8f509d1` ("kh: Mache die Anwendung installierbar") is the last `kh` commit
untouched by zugang. **Not** `8e91c9d0~1`: that is `5f492ae8`, which is
ticket 01's build, and a `/to-solution` run that reads a codebase already
holding `js/zugang.js` and the Caddy lock measures nothing.

Symlink `idea`, `to-solution` and `spec-to-tickets` into the clone's
`.claude/skills/` so the run exercises the edited skills.

Then run `/idea` -> `/to-solution` -> `/spec-to-tickets` in a fresh session
that has not seen the reference set, and fill the right-hand columns.

Pass is four things, each producing an artifact:

- **Coverage** - every old obligation lands somewhere, or is missing with a
  reason that survives reading. One silent *missing* is a fail.
- **Seams** - ticket count and each ticket's `Touches`. The old seams are
  `js/app.js`, `js/ansicht.js`, `js/zugang.js`, `css/kliniksuche.css`,
  `Caddyfile`, `sw.js`, `index.html`. Fail if the Caddy lock and the
  browser-side question land in one ticket, or `js/zugang.js` splits across
  two.
- **Nothing a builder would have to guess** - do not judge this by reading.
  Run `/spec-to-tickets`' own falsification reviewer
  (`spec-to-tickets/SKILL.md:96-111`) over **both** sets, blind, and compare
  the count and severity of findings.
- **The unattended build keeps its input** - hand the new set to `loop.sh`
  for at least one ticket in the clone, then `./accept.sh`. Verifying this
  by inspection is what the spec's second constraint explicitly is not.

A worse set stops the work here, with B1-B5 standing on their own.

**Then run it again on a bugfix**, in the same clone. The spec's first open
concern says the small lane getting longer is what would send the work back
to the shared-file candidate - the strongest loser. Deferring that discovery
until after `/discovery` is deleted is the expensive order.

### B7 - One door

Two commits.

**Retire `/discovery`.** `git rm -r discovery/`; remove
`.claude/skills/discovery`; re-copy `TICKET_FORMAT.md` across the four
remaining holders and re-`md5sum`; apply B0's ruling to
`tests/run.sh:882-891`. Check first that nothing outside `discovery/` still
reads `SPEC_FORMAT.md`.

#### The pointer sweep

Prose only, and it happens in the same commit as the deletion. Find them by
grep:

| Where | What |
|---|---|
| `spec-to-tickets/SKILL.md` | ten bare-word uses - `:3, :9, :11, :13, :15, :28, :61, :67, :86, :123`. The five `/discovery` *routes* (`:32, :34, :36, :65, :138`) wait for B6, which turns them into questions |
| `TICKET_FORMAT.md` x 5 | seven each - `:3, :17, :31, :112, :120, :124, :144` - then re-copied byte-identical, discovery's copy included while it exists |
| `implement/SKILL.md:3` | the description |
| `handover/SKILL.md` | `:30, :33, :34` |
| `loop.sh:604` | one comment. No behaviour, no narration string |
| `README.md` | `:19, :22, :35, :37, :73, :85, :94` - the pipeline section rewritten around one door; the split's stated reason corrected at `:37` (it is not that one session should not design against its own problem statement, it is that `/idea` is a place to stop); `:69` and `:71`, where the permanent tier drops to two members; `:73`, which names `/discovery` as the reader of `IDEAS.md`. `:114` survives |

Two edits the spec's Survey names but assigns to no part, and which land
here:

- `check-against-spec/SKILL.md:53` sweeps *every non-goal*; after B4 the
  section is `## Scope`'s *Never*.
- `:45-46` rest on ratified journeys as the pinning mechanism. Drop the
  ratification framing; keep `tests/workflows/` as a thing a project may
  have.

**Make `/idea` the door.** Drop `disable-model-invocation` from
`idea/SKILL.md:4`; write the model-facing description from
`SPECIMEN_MERGE_LANES.md:115-122`, covering a feature, a bug, a refactor and
a passing idea, disambiguated from `/to-solution`. State ending at the intent
as an ending, including the ending that writes no file.

Before measuring it: **fix `.claude/skills/`.** It links neither `idea` nor
`to-solution` nor `spec-to-tickets`, and six of its links - `debug`,
`decision-brief`, `discovery-increment`, `explain-diff`, `propose-change`,
`wdim` - are already dangling. This repo's own agent cannot fire `/idea`
today, so the Done-when cannot be evaluated until it can.

Done when a request that would have fired `/discovery` fires `/idea`, and a
session that stops at the intent ends without being routed onward.

### B8 - Retire `/find-solution`

`git rm -r find-solution/`. Its two moves and its ending were absorbed in B3;
its one outbound pointer (`:64`, "say that `/discovery` is next") goes with
it. In the README, `:86` is a list entry to delete and `:79` is a paragraph
about which skills stand outside the pipeline - it needs rewriting.

Done when `grep -rn find-solution` returns only `IDEAS.md`, this topic's
paper and history.

## Commits

One per step, B7 split in two: the deletion with its sweep, then the door. Subject in the imperative, body saying why,
`Co-Authored-By` trailer. Stage only that step's files.

## Verification

- **Per step** - the spec's own *Done when*, plus the corrections above.
- **Parity** - `md5sum` over each same-named `*_FORMAT.md` group after B1,
  B7 and B8.
- **The scripts** - `tests/run.sh` green after every step, B7 included, which
  is what B0's ruling is for.
- **The constraints**, as the spec states them: a `/to-solution` run on a
  non-code intent after B4 surveys no codebase, writes no user stories and
  produces no mockup; B6b's ticket set reaches `loop.sh` and `./accept.sh`
  unmodified; no must-happen step rests on a description matching, by
  inspection after B7; `/spec-to-tickets` still does not decide what the
  system does, by inspection after B5.
- **The whole branch** - a cold read by a fresh `general-purpose` subagent
  against `writing-great-skills`, which is the standard the spec names for
  the deliverable. Not `/critique`, which reviews code against
  `coding-conventions`, and nothing here is code. Three questions: what is
  the first thing you would have to guess; where does this fight itself; and
  does any rule about the craft now appear in more than one file.

## Carried, not resolved

The spec's four open concerns ride along. The small lane getting longer is
settled by B6b's second run; the other three - non-code work having no
unattended exit, domain modelling off a codebase being argued rather than
measured, and journeys moving from agreed-with-you to derived-by-a-skill -
are settled by use, and this plan does not pretend otherwise.
