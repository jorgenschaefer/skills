---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-8
after:     2-solve
status:    done
attempts:  1
reviews:   1
---

## Build

`/verify`, the one adversary skill, carrying a contract per stage rather than four
near-identical review skills.

## Done when

> **AC-8** `/verify` performs every artifact review, as a subagent with a fresh
> context, against the stage's input only.

## Context

Contracts: at (a), every condition observable. At (b), bidirectional coverage against
the intent's `C-n`, plus the drawback hunt — unlisted tradeoffs, whether the stated
reason for ruling out an alternative is true, and alternatives nobody considered. At
(c), every ticket traces to an `AC-n` and every `AC-n` lands in a ticket, plus slice
independence.

The rule that keeps it from oscillating: no adversary reopens a decision ratified
upstream. Looking at the codebase is allowed; relitigating the approach is not.

At (c) it is the one invocation that is not file-addressed — the proposed slicing
arrives as text in the prompt, because plan mode cannot write files.

## Not here

Reviewing code. That is `/critique`, ticket 6.

## Record

`tests/run.sh` (254 + 18 + 22, green).

**AC-8, the part that is code.** `/verify` reviews one artifact, so the mechanical half
of its contract had to be askable about one artifact. Both format suites now take
paths: `a path checks that file` and `a path checks nothing else`, in each suite. Four
cases, all four red before the change — the child walked the whole tree instead.

**AC-8, the part that is a guard.** `every suite a skill tells you to run exists` in
`tests/run.sh`: the commands `/verify` names are greped out of every `SKILL.md` and
checked to be real files. Renaming a suite now fails here instead of when an agent
follows the instruction and finds nothing.

**Untested, because it is instruction to a model.** All three contracts, the
fresh-context requirement, the no-reopening rule, the severity split on a newly found
cost, and the instruction not to rewrite the artifact. This is most of the skill. The
suites can prove an intent is malformed; nothing in bash can prove a reviewer hunted
for a drawback it did not find.

**A test-design mistake worth recording.** The first version of the single-file cases
invoked the suite from inside itself with no guard, so before the feature existed each
run spawned another, forever. It took a hard kill. The cases now set
`FORMAT_SUITE_CHILD=1`, and the fixture section runs only at the top level. A test that
hangs in its red state is a test that will be deleted rather than fixed.

**Deliberate.** `/verify` delegates the mechanical checks rather than restating them.
The alternative — teaching the skill what a conforming artifact looks like — would put
the same rules in two places, and the prose copy would be the one that drifted.

## Findings

One review round, ten findings. Eight taken, two recorded.

**The two that mattered were one bug.** `a path checks that file` matched the substring
`INTENT_X.md conforms`, which `FAIL  … conforms` contains as readily as `ok    …`, and
it ignored the child's exit status — so it passed whatever the child decided. It was
green over a child that was failing: in single-file mode the reverse walk resolved a
solution's named intents against *this repo's root* rather than beside the artifact, so
`/verify` pointed at any solution written anywhere else would have reported it
malformed. Sharpening the assertion to require `ok` and rc 0 turned the case red
immediately, which is how the bug surfaced. Both fixed.

A test that cannot tell a pass from a failure is worse than no test: it reports the
capability works and stops anyone looking.

**`/verify` was reachable by nobody.** AC-8 says it performs every artifact review, and
nothing invoked it — `idea` and `solve` were both already `done` and neither mentioned
it, and `disable-model-invocation: true` means it cannot be found by description
either. Both now run it before they hand back: `/idea` before asking for the
ratification, `/solve` before returning the spec.

**The delegation claimed more than the suites deliver.** "These check shape, numbering
and coverage in both directions" was untrue for the intent suite, which has no coverage
check at all, and half-true for the solution suite, which proves a tag exists and never
that it holds. Each suite's line now says what it does, and the solution contract gains
the reading the design assigns to nobody: take each tag and ask whether the criterion
serves the condition it cites.

**The intent contract was missing what the design says it is for** — re-deriving the
problem from the person's own words and flagging divergence, and checking the document
is complete and free of contradictions. Added.

**Three hardenings.** The suite-exists case passed vacuously on zero matches, matched
only depth-1 `SKILL.md` and a narrow path pattern, and checked `-f` rather than `-x`;
it now counts, scans companion documents, and tests runnability. The child guard wrapped
seventy lines in an unindented `if`, and an inherited `FORMAT_SUITE_CHILD` would have
silently cut a top-level run to its tree cases and still exited 0 — flattened to an
early exit, and `run.sh` clears the variable. The reporting section gained a bar:
refute your own finding first, name who it is for, and return a verdict, because an
unattended caller needs a yes or a no.

**Recorded, not fixed.** The condition rules were restated from `idea/SKILL.md`; the
skill now points at them instead, which is the same argument the delegation rests on.
And the suite paths are repo-relative: `/verify` in a project without them is told to
do the checks by reading and to say in its report that it did, because a reading is not
a run.
