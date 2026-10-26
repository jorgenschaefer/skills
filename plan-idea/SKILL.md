---
name: plan-idea
description: Turn a problem agreed with /idea into a task list in CHANGE.md that an agent can execute without asking anything. Typed.
disable-model-invocation: true
---

Work out with the user what needs to happen to solve the problem `/idea` agreed, until whoever executes the tasks does not need to ask anything.

## Start from the problem

**Take the problem statement `/idea` agreed** from the conversation, or from the backlog item where it was recorded. Where there is none, run `/idea` first.

## The loop

**Read the repository first**: what is already there, what the project calls things, what it decided before.

**Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one.

**Build a specimen where the difference is visual.** Publish it as a Claude Artifact, and keep a copy in `specimens/` in the change's directory - `changes/YYYY-MM-DD-<slug>/specimens/`, made now if it is not there. Once the choice is made, `specimens/` holds the agreed specimen and nothing else.

**Work out the tasks.** A task says what to do and where, not the exact diff.

**Settle every open question.** Each one ends as a task or is ruled out.

**The loop is done when every task can be done without asking anything.**

## Approval, then the adversary, then approval

1. **Show the task list and ask whether this is right.** A no sends you back into the loop.
2. **Write `CHANGE.md`** in the change's directory:

   ```markdown
   # <title>

   <the problem statement /idea agreed>

   ## Tasks

   Do each task in order. After each, a subagent with a fresh context reviews it against the task; work in what it finds.

   1. <what to do, and where>
   ```

3. **Check it.** Spawn a subagent with a fresh context and give it the problem statement and the path to `CHANGE.md`, with this prompt: "Does doing these tasks solve this problem? Which task could not be done without asking something? Report each finding with the task it concerns." Nothing else - an adversary holding the conversation will read your intentions into the words.
4. **Work its findings into the file, then show only what changed and ask again.** Judge its findings first; reject what is not sound. Where it found nothing, say so and ask for the final yes.
5. **Delete the backlog item** the problem came from, and commit its deletion with `CHANGE.md`.

## Throughout

**Every time you put alternatives for what the change does or how it is built to the user, give each its effort and the complexity it adds, next to what it gives.** Effort is a size from XS to XL. Complexity is a few words naming what it adds - "a migration for entries and versions" - not a size. A yes/no question is not such a choice.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the user says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** The tasks are executed by an agent told "execute the tasks in CHANGE.md" - name it, and leave going on to the user to ask for.
