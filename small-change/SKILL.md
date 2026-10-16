---
name: small-change
description: Settle a small fix or change with the user and build it, in one session. Typed.
disable-model-invocation: true
---

# Small change

Settle a small change with the user in one session and build it - no files, no tickets.

## The problem

**Read the code before you ask anything**, and ask only what it cannot answer. Do not guess or assume.

**Get one real instance** - the last time this happened, what went wrong, what it cost.

**Ask until you can state the problem in one paragraph** - what is wrong, what should be true instead - and the user agrees. The fix they arrived with is evidence about the problem, not part of the statement.

Where it is already solved, or a symptom of something else, name the thing that solves it or lies underneath, and stop.

## The approach

**Propose three genuinely different approaches**, or fewer with the reason. Two that differ only in how much of the same thing they do are one.

For each: what it gives, its effort as a size from XS to XL, the complexity it adds to the code in a few words, and any stored format, wire format, trust boundary or dependency it touches.

**Recommend one, and ask which they want** with AskUserQuestion, the recommended one first.

**Larger than S, now or once building: stop and recommend `/find-criteria`.**

## What done means

**Propose what "done" means and ask whether that is it** - one or two statements that can be checked true or false. Picking an approach is not agreeing on done. Edit nothing until the user agrees.

## Build it

**Build the chosen approach.**

**Show it holding** - the test that failed before and passes now, or the running app doing it - and name anything built beyond what was agreed.

## Throughout

**End your turn at the first question mark.**

**Push back once.** A decision reaffirmed after hearing the objection is theirs.
