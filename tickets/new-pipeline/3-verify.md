---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-8
after:     2-solve
status:    review
attempts:  1
reviews:   0
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
