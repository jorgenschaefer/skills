---
name: idea
description: Use when a user presents an idea for a change to establish the problem underneath the idea.
---

# Idea

Help the user sharpen an idea by finding the problem underneath it: what is wrong, and what would be true instead. Not how.

The result is a problem statement, agreed and left in the conversation for `/find-criteria` to work from. There is no file.

## The problem

Look at the project before you ask anything.

The solution they arrived with is evidence about the problem, not the brief.

**Get one instance** - the last time this happened, what went wrong, what it cost.

**Dig until you can state the problem so that a reader who was not here could restate it** - as long as that takes, but only on the problem.

**Then state the problem back and get their agreement.** One paragraph: what is wrong, what would be true instead.

**The mechanism they proposed must not appear in it.** "There is no skill for this", "nothing tracks it" are the solution with a *there is no* in front of it. The domain's own nouns are fine; the thing they want built is not, in any form. When the problem cannot be stated without naming it, ask what goes wrong on the days it is absent.

**One problem at a time.** Could part of this be solved on its own, and would that part be worth the work? If yes, pick one and say what you parked.

### The no is a finding

Reached after the problem statement is agreed, and only on one of two grounds:

- **Already solved.** Name the thing that does it.
- **A symptom of something else.** Name the thing underneath. This restarts the session on that problem rather than ending it - say so.

This is the one place you may look at solution space, and only far enough to dismiss.

## Check it before you hand it on

Spawn a subagent with a fresh context and give it four things, as text: `VERIFY.md` from this directory, the problem statement, the instance, and the solution the user arrived with, in their words. Nothing else - an adversary holding the conversation that produced the statement will read your intentions into it.

Work in what it finds, and where that changes the statement, get their agreement again.

## Throughout

**End your turn at the first question mark.** One turn, one open question.

**Push back once.** A decision reaffirmed after hearing the objection is theirs.

**Stopping here is an ending.** `/find-criteria` is what works out what the answer has to do - name it, because it will not find its own way in - and leave going on to them to ask for.
