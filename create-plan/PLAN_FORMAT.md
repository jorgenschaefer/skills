# Plan format

`changes/YYYY-MM-DD-<slug>/plan.md` is how the change is built. Where it is split, each part is a file of its own in `changes/YYYY-MM-DD-<slug>/plan/`: `plan/NN.md`, numbered from `01`, two digits. `run.sh` reads the frontmatter, so its shape below is not decoration.

## plan.md

```markdown
---
status:    ready           # ready | doing | done | halted
attempts:  0               # the runner's
---

# <The change, in a few words>

Planned from `changes/YYYY-MM-DD-<slug>/spec.md`.

<Only where the developer asked for it: "Build this plan as one part.">

## Hard decisions

### H1. <The decision, in a few words>

From: <the line of the spec it comes from, quoted, with its path and line number>

1. **<The simplest option> (simplest).** <What it is, and what it costs.>
2. **<The next option>.** <What it is, and what it costs.>

Recommendation: <the option>, because <why>.

Why it is hard: <what outside the code depends on it: what a revert would not undo>.

Decided: <the developer's answer, and the date>.

<Or, where there are none, one line: "No hard decisions.">

## Hard tests

- **<Its rule, in the user's words>** - `<path>.hard.test.ts`. <For a journey's test: the journey and the step it walks.> Breaks if: <what breaks for the user if the tested thing changes>.
- **<An existing hard test the plan changes or deletes>** - `<path>.hard.test.ts`. Changes: <what changes, and why>. Breaks if: <...>. The developer's yes: <the date>.

<Or, where there are none, one line: "No hard tests.">

## Steps

### 1. <What this step does, in a few words>

- `<path>`: <what changes in this file>.
- Tests: <the tests this step writes or changes, hard and soft>.
- Makes testable: <the journey steps, such as "pay-an-invoice 2-3", or "none">.

## Left standing
<Written by the build: what it left for someone to act on. Empty when it left nothing.>

## Halt
<Written by whoever stopped, the session or the runner: the kind of halt and what it was blocked on. Absent unless something stopped.>
```

## A part

```markdown
---
status:    ready
attempts:  0
---

# Part NN: <what it builds, in a few words>

Part of `changes/YYYY-MM-DD-<slug>/plan.md`.

## Hard decisions
<Each hard decision this part's steps touch, copied word for word from plan.md, the answer included. Or "None.">

## Hard tests
<Each hard test this part writes or changes, copied word for word from plan.md. Or "None.">

## From the parts before
<What the parts built before this one provide that this one builds on: a file, a table, a route, a name. Or "Nothing." for the first part.>

## Steps
<A run of plan.md's steps, copied word for word, with their numbers.>

## Left standing

## Halt
```

## What it is for

**`status` and `attempts` are the runner's bookkeeping.** The runner sets `doing`. A session writes `done` when it has committed its build, or `halted` when it has stopped. `attempts` lives in the file so the count survives a runner that dies and starts again.

**The parts are built in the order of their numbers**, one after the other. A part rests on what the parts before it built, and on nothing a later one builds.

**Without parts, the runner builds `plan.md` itself.** With parts, `plan.md` stays the whole plan, for the review at the end of the run and for acceptance. Its `status` then says whether that review is done: the review sets it to `done`, and a new split sets it back to `ready`. The review writes what it left under `### End review` in `plan.md`'s `## Left standing`, and a new split removes that heading and what is under it.

**The plan says how.** The files, the order of the work and the tests, but no code. It covers what the user does not see: infrastructure, dependencies, tools, and the technical side of the frontend. How the UI looks was settled in the design.

**Hard and soft.** A decision or a test is hard if something outside the code depends on it: a revert removes the code, but not what the code wrote, sent or promised. The developer decides each hard decision before the run and approves each hard test the plan changes or deletes. Every soft decision is the build's, and the build may change it.

**A hard test is a file with `.hard.` before its test suffix.** It tests from the outside - the UI, the API or the stored data - and its name says its rule in the user's words. A journey's step marked *(judged)* gets no test.

**Where the build departs from the plan**, it updates its part, `plan.md` and the later parts in the same commit, so the plan always describes what is built and what is still to come.

**It is not permanent.** The change's directory is deleted once the change is accepted. The hard decisions live on in the schema, the API and the hard tests; git keeps the plan.
