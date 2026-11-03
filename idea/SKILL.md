---
name: idea
description: Use when a user presents an idea for a change to establish the problem underneath the idea.
---

# Idea

Help the user sharpen an idea by finding the problem underneath it: what is wrong, and what would be true instead. Not how.

The result is a problem statement, agreed and written into the backlog item it came from, or into a new one. This skill's `INTENT_FORMAT.md` settles its shape. It is what the design and acceptance hold the change against.

## The problem

Look at the project before you ask anything.

The solution they arrived with is evidence about the problem, not the brief. So is a backlog item, however finished it reads - what it says is wrong and how much that matters included. Where it records a problem agreed with `/idea` before, state that back and ask whether it still holds; dig only where it does not.

**Get one instance** - the last time this happened, what went wrong, what it cost.

**Dig until you can state the problem so that a reader who was not here could restate it** - as long as that takes, but only on the problem.

**Then state the problem back and get their agreement.** One paragraph: what is wrong, what would be true instead.

**The mechanism they proposed must not appear in it.** "There is no skill for this", "nothing tracks it" are the solution with a *there is no* in front of it. The domain's own nouns are fine; the thing they want built is not, in any form. When the problem cannot be stated without naming it, ask what goes wrong on the days it is absent.

**Dig under a constraint they arrive with.** "Existing login only" is evidence, like the solution they arrived with: ask why. Where the answer is part of the problem, such as "nobody new gets access to member data", it goes under "What must stay true", with no mechanism in it. Where it only limits the solutions, such as "we cannot run a second login system", it is a hard decision for later: say so, and leave it out of the statement.

**One problem at a time.** Could part of this be solved on its own, and would that part be worth the work? If yes, pick one and say what you parked.

### The no is a finding

Reached after the problem statement is agreed, and only on one of three grounds:

- **Already solved.** Name the thing that does it.
- **A symptom of something else.** Name the thing underneath. This restarts the session on that problem rather than ending it - say so.
- **Not worth the work.** The problem is real, but it costs less than solving it would take. Show both sides: the cost, from the instance, and the work - the item's effort size, or your own guess, said to be one. The user decides.

This is the one place you may look at solution space, and only far enough to dismiss.

Where the idea came from a backlog item and the user agrees with a no that is not a symptom, propose deleting the item. On a yes, delete it and commit that alone, the reason in the message.

## Check it before you hand it on

Spawn a subagent with a fresh context and give it four things, as text: `VERIFY.md` from this directory, the problem statement with what must stay true, the instance, and the solution the user arrived with, in their words. Nothing else - an adversary holding the conversation that produced the statement will read your intentions into it.

Work in what it finds, and where that changes the statement, get their agreement again.

## Write it down

Write the agreed statement in `INTENT_FORMAT.md`'s headings, on main, before any branch for the change exists:

- **Where the idea came from a backlog item**, write the headings into that item, below its notes, and keep its frontmatter. Where it already holds them, replace them with what was agreed now. Commit that file alone.
- **For a new idea**, hand the headings to `/backlog`, which looks for an item it overlaps, proposes the sizes and commits the item.

The solution they arrived with goes under "What they arrived with", as evidence, not as the brief.

## Throughout

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the user says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** Name both ways on, because neither will find its own way in, and leave going on to them to ask for:

- `/create-spec` works out the design with them and writes it into the change's `spec.md`; `/create-plan` plans the build, and `run.sh` builds it with nobody watching;
- `/solve-problem` works out a solution with them and builds it in this session.

Recommend one: the first where a user journey, what the software keeps or what a user sees changes, the second where none does. Name the item's path: it holds the problem statement. `/create-spec` moves it into the change's directory as `intent.md`, which is deleted at acceptance; `/solve-problem` deletes it with its commit.
