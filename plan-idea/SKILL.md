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

**Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one. Once the approach is chosen, put its scope as the next choice: the smallest version that solves the problem, a staged one, the full one.

**Name what the choice rests on.** Each assumption in one line, marked checked, with its evidence, or assumed.

**Build a specimen where the difference is visual.** Publish it as a Claude Artifact, and keep a copy in `specimens/` in the change's directory - `changes/YYYY-MM-DD-<slug>/specimens/`, made now if it is not there. Once the choice is made, `specimens/` holds the agreed specimen and nothing else.

**Work out the tasks.** A task says what to do and where, not the exact diff.

**Settle every open question.** Each one ends as a task or is ruled out. One with more than one sound answer is put to the user as alternatives.

**Go back to `/idea`** where what you find shows the problem stated wrongly, already solved, or not worth the effort the alternatives turn out to need. Say which, with the evidence, and stop.

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

   <N>. Spawn a subagent with a fresh context and give it only the problem statement above and the changes these tasks made, with this prompt: "Do these changes solve this problem? Report first what concerns the changes as a whole, then each finding with the change it concerns." Work in what it finds.
   ```

3. **Check it.** Spawn a subagent with a fresh context and give it the problem statement and the path to `CHANGE.md`, with this prompt: "Does doing these tasks solve this problem? Which task could not be done without asking something? Is there a simpler way to solve it? Which task is not needed? Report first what concerns the plan as a whole, then each finding with the task it concerns." Nothing else - an adversary holding the conversation will read your intentions into the words.
4. **Work its findings into the file, then show only what changed and ask again.** Judge its findings first; reject what is not sound. Where it found nothing, say so and ask for the final yes.
5. **Delete the backlog item** the problem came from, and commit its deletion with `CHANGE.md`.

## Throughout

**Every time you put alternatives for what the change does or how it is built to the user, give each its effort, the complexity it adds, what it gives, what is still wrong after it and what might stop it working, then recommend one and say why.** Effort is a size from XS to XL. Complexity is a few words naming what it adds - "a migration for entries and versions" - not a size. What is still wrong is held against what the problem statement says would be true instead; "nothing" is an answer. A yes/no question is not such a choice.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the user says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** The tasks are executed by an agent told "execute the tasks in CHANGE.md" - name it, and leave going on to the user to ask for.
