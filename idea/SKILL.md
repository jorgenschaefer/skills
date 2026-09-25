---
name: idea
description: Use when a user presents an idea for a change to establish the problem underneath the idea.
---

# Idea

Help the user sharpen an idea by finding the problem underneath it, and write that down as an intent: what is wrong, what it costs, what would be true instead, and what any answer has to hold to. Not how.

## The problem

Look at the project before you ask anything.

The solution they arrived with is evidence about the problem, not the brief.

**Get one instance** - the last time this happened, what went wrong, what it cost.

**Dig until you can state the problem so that a reader who was not here could restate it from the intent alone** - as long as that takes, but only on the problem.

**Then state the problem back and get their agreement.** One paragraph: what is wrong, what would be true instead.

**The mechanism they proposed must not appear in it.** "There is no skill for this", "nothing tracks it" are the solution with a *there is no* in front of it. The domain's own nouns are fine; the thing they want built is not, in any form. When the problem cannot be stated without naming it, ask what goes wrong on the days it is absent.

Draft everything else the intent holds from what they have told you, and present it for correction. Ask questions before guessing.

**One problem per intent.** Could part of this be solved on its own, and would that part be worth the work? If yes, pick one and say what you parked.

### The no is a finding

Reached after the problem statement is agreed, and only on one of two grounds:

- **Already solved.** Name the thing that does it.
- **A symptom of something else.** Name the thing underneath. This restarts the session on that problem rather than ending it - say so.

This is the one place you may look at solution space, and only far enough to dismiss.

## The conditions

`Done when` is the part everything later addresses, so it is worth more effort than the rest of the draft put together.

**Each condition is checked, not judged.** Write it so that someone months from now could hold it against the finished thing and say true or false without asking what you meant. "Fast enough" is a judgement. "A cold start answers in under a second" is a condition.

**Each condition is about the problem, not the answer.** Test it against a solution you did not think of: if that solution would solve the problem and still fail the condition, the condition is a mechanism in disguise. Rewrite it as the outcome you actually wanted.

## The record

Present the intent in the shape this skill's `INTENT_FORMAT.md` specifies, and write it to `intents/YYYY-MM-DD-<slug>/01-INTENT.md`.

### Check it before you ask

Spawn a subagent with a fresh context and give it two things: `VERIFY.md` from this directory, and the path to the intent. Nothing else - an adversary holding the conversation that produced the document will read your intentions into it.

## Throughout

**End your turn at the first question mark.** One turn, one open question.

**Push back once.** A decision reaffirmed after hearing the objection is theirs - record it as such.

**Stopping here is an ending.** `/find-solution` is what turns it into an approach - name it, because it will not find its own way in - and leave going on to them to ask for.
