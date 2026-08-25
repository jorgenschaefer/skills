# Plan: restructure `/discovery` around its four phases

## Why

`/discovery` is meant to do four things: find the real problem beneath what was
asked for; find the solution that best fits the existing concepts and
architecture; propose the experience with options the user picks from; and leave
a document an implementer can build from without the conversation.

Today the fourth is finished and the first three are not, in proportion to how
much of the file each gets:

- **The problem** is one paragraph (`## Goal`). No excavation technique, no
  evidence check, and no gate that stops the conversation moving to solutions
  before the problem is agreed. The problem statement is written down only at
  the end, as the spec's `## Why`.
- **The solution** has no step at all. "Propose alternatives" is one bullet
  under `## Role`. The module survey - the only place the codebase is consulted
  about shape - runs *after* journeys, stories and the domain model have already
  fixed the solution, and is explicitly scoped to module-level reuse verdicts.
  So the judgement "does this fit what the project already is, and if it
  diverges, is it enough better to justify the divergence" happens nowhere, and
  the asymmetry in that sentence is not stated anywhere in the skill.
- **The experience** points the other way from what is wanted: *"Two options
  side by side are for a decision still genuinely open after it."* The walk is
  the default and options are the exception.

The file is also organised topically while the work is sequential, so the arc
above is invisible to a reader following it.

## Decisions taken

| | |
|---|---|
| Structure | Full restructure into four phases; every existing section moves under the phase it belongs to. |
| Solution step | Its own phase, with the fit bar stated as a rule. |
| Domain model | Phase 2, part of choosing - aggregate boundaries are solution shape. |
| UX | Approach options first, user picks, then the walk of the chosen one. |
| Mockup | Kept in the repo through the run, deleted by `accept.sh` with the rest of the paper. |
| Small lane | Same four phases, scaled down - not a separate structure. |

## The new shape

```
1  Problem      both lanes - ends by naming the lane
2  Solution     both lanes, scaled
3  Experience   spec lane only
4  Record       spec file, or ticket
                                     + Throughout
```

### Phase 1 - The problem

Absorbs today's opening paragraphs and `## Goal`. Gains:

- **Excavation.** What happens today, what the user does instead, how often it
  bites, what it costs when it does, and one concrete recent instance. A problem
  with no instance behind it is a preference, and the difference decides whether
  this is worth building.
- **The gate.** State the problem back in one paragraph and get agreement to it
  *before* any solution is discussed. This is the phase's exit condition, and
  the one place the skill currently has nothing where it most needs something.
- **The reasoned no lives here.** Its three grounds - already solved, cost out
  of proportion, symptom of something else - are all claims about the problem,
  and none of them is reachable without having gone looking. Say what evidence
  makes each one, so a no is a finding rather than a mood.
- **The lane.** Phase 1 ends by naming the exit: spec, one ticket, maintenance
  ticket, or no. It cannot be known before the problem is understood and it must
  not be asked as an opening question.
- **Reads.** Today's codebase skim, `UBIQUITOUS_LANGUAGE.md`, `IDEAS.md`, plus
  `ARCHITECTURE.md` where one exists - see *Absorbed from `IDEAS.md`* below.

### Phase 2 - The solution

New. Two to three candidates, one of them whatever the user arrived with. Per
candidate: what it does, what it costs to build and to carry, and - the part
that matters - which existing concept it extends or what new one it introduces.

**The fit bar, stated as a rule:** a solution that fits the project's existing
concepts and architecture wins ties and near-ties. A diverging one has to be
*much* better, not merely better, because divergence is paid for twice - once
building it and again by everyone who reads the codebase afterwards.

Then, in order:

- **Pushback and the choice.** Recommend one, with the reasoning. Where the
  user's candidate is not it, say so and why - once. If they reaffirm, that is
  their call: build it and record it as theirs.
- **A diverging winner is an ADR proposal.** It is exactly the structural choice
  a later reader would otherwise undo without learning what it cost. Proposed,
  never written autonomously, as the ADR rule already requires.
- **The domain model** of the chosen candidate, shown back for veto in a turn of
  its own - moved here from Process, unchanged. Aggregate boundaries are part of
  what makes a candidate fit or not, so this is where they get decided.
- **The module survey**, moved up from below the criteria. Same verdicts, same
  recording, now the evidence for a choice rather than a note taken after it.
- **Why not X**, recorded. Rejected candidates and the reason go in the spec so
  nothing downstream drifts back toward them helpfully.

**Small lane:** the same phase compressed - root cause, blast radius, the
mechanism that already exists, four honest verdicts. Those bullets already are
the fit judgement at one ticket's scale, and they move here unchanged.

### Phase 3 - The experience

Journeys, then the UX, then the criteria. Changes:

- **Options before the walk.** Two or three genuinely different shapes for how
  the feature is met - inline against modal against its own screen; wizard
  against single form - sketched cheaply, and the user picks. Then the full
  journey walk of the one they picked, as the skill already describes it.
  Today's demotion of options is dropped; today's argument for the walk is kept
  whole, because it is still right about what a walk finds that a screen cannot.
- **The chosen walk is kept.** It goes to `mockups/` beside the spec and
  `## Design` links it, so the implementer builds against the thing that was
  agreed rather than a paragraph about it. The option sketches stay in scratch
  and die immediately.
- Reuse-before-invent, the red/green walk, the lifecycle and authorization
  sweeps, and the hiding-spots list all move here unchanged.

### Phase 4 - The record

Today's `## When to stop`, the hardening sweep, `## Records that outlive the
feature`, `## Summary` and the receipt, in that order and largely unchanged.
One addition: the cold-read subagent gets the small lane's second question -
**"what is the first thing you would have to guess?"** - which the spec lane
currently does not ask despite the higher stakes.

### Throughout

Role and pushback, the mechanic that sorts every decision into three buckets,
one open question per turn, and vocabulary discipline. Each applies in every
phase, which is why none of them is a phase. `## One feature` and its split test
apply everywhere too but stay at top level - see the risks below.

## Files

| File | Change |
|---|---|
| `discovery/SKILL.md` | The restructure above. |
| `discovery/SPEC_FORMAT.md` | New `## Solution` after `## Why`: the chosen approach in a sentence, what it extends, and the candidates rejected with reasons. `## Design` updated to link `mockups/` and to say it dies with the spec. |
| `accept.sh` | Delete `$SPEC_DIR/mockups` with the spec and the tickets. Absent is fine; git history keeps it. |
| `tests/run.sh` | A case: accept deletes a mockups directory; a run without one still accepts. |
| `README.md` | The `discovery` bullet and the pipeline paragraph. |
| `IDEAS.md` | Resolve the absorbed half of the `ARCHITECTURE.md` item. |

## Absorbed from `IDEAS.md`

**`ARCHITECTURE.md` needs a reader** names `/discovery` as one of two obvious
readers, treated as a lead rather than truth since it is only as current as the
last `/repo-overview` run. Phase 2 is the reader it was waiting for - judging
architectural fit is the one job that wants it. Taking the `/discovery` half
now; the `/spec-to-tickets` half stays parked. Flagging rather than absorbing
silently, as the parking lot's own rule requires.

## Risks, and how they were settled

Three lines were load-bearing where they stood, and the restructure moved all
three. Each was resolved deliberately rather than by where the text landed:

- **`## One feature` and the split test stayed at top level**, before the
  phases, rather than being demoted into `## Throughout`. It is the skill's only
  defence against an oversized spec and carries *"Nothing downstream will save
  you from getting this wrong"* - too load-bearing to sit two thirds of the way
  down a longer file. Phase 1 points at it for the lane decision instead.
- **The lanes stayed blunt.** *"Most of this skill is written for the spec lane
  and does not apply here"* became, in `## The shape`: *"Phase 3 belongs to the
  spec lane alone, and phase 2 on the small lane is four questions rather than a
  survey - a bugfix that acquires a domain-model turn and a mockup walk has cost
  more to specify than it would have cost to fix."* Same force, and now it says
  which phases rather than gesturing at the rest of the file.
- **"End your turn at the first question mark" kept its own heading**, under
  `## Throughout` rather than inside a paragraph about talking to the user.

One thing the unification bought that was not planned for: *ratify in flight*
was a small-lane bullet duplicating what `Records that outlive the feature`
already said for the spec lane. On one spine it is a single rule with a clause
for each lane.

## Not doing

- Splitting `SKILL.md` into per-phase files. One file, four sections; the phases
  are a reading order, not modules.
- Touching `/spec-to-tickets` or `/check-against-spec`. The new `## Solution`
  section is additive and neither reads it.
