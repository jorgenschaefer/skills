---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-8
after:     2-solve
status:    ready
attempts:  0
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
