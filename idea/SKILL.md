---
name: idea
description: Use when a change is being worked out with the user - a feature, a bug, a refactor, or a passing idea that needs developing into something buildable. Finds the problem underneath what was asked for and writes it down as an intent, with no solution in it. The one way in.
---

# Idea

Help the user sharpen an idea by finding the problem underneath it, and write that down as an intent: what is wrong, what it costs, what would be true instead, and what any answer has to hold to. Not how.

## The problem

Look at the project before you ask - what it already calls things, what it already has. `IDEAS.md`, where the project keeps one, is the parking lot the checks file into: what is already noted there is evidence about the problem, and sometimes it is the problem.

The solution they arrived with is evidence about the problem, not the brief.

**Get one instance** - the last time this happened, what went wrong, what it cost. A problem with no instance behind it is usually a preference.

Usually, not always. Some failures leave no trace by construction: nothing was watching, so the absence of an example is what you would see either way. That case is allowed, and it is the only one - say plainly in `Evidence` that there is no instance, say what makes the failure structural, and expect a weaker yes when you ask for it.

**Dig until you can state the problem so that a reader who was not here could restate it from the intent alone** - as long as that takes, but only on the problem.

**Then state the problem back and get their agreement.** One paragraph: what is wrong, what would be true instead.

**The mechanism they proposed must not appear in it.** "There is no skill for this", "nothing tracks it" are the solution with a *there is no* in front of it. The domain's own nouns are fine; the thing they want built is not, in any form. When the problem cannot be stated without naming it, ask what goes wrong on the days it is absent.

Draft everything else the intent holds from what they have told you, and present it for correction. Ask only where you would otherwise be inventing something they alone could know.

**One problem per intent.** Could half of this be solved on its own, and would that half be worth the work? If yes, pick one and say which you parked.

### The no is a finding

Reached after the problem statement is agreed, and only on one of three grounds:

- **Already solved.** Name the thing that does it.
- **Cost out of proportion.** The instance, times how often it recurs, against roughly what any answer would cost to build and then to keep. Say both sides.
- **A symptom of something else.** Name the thing underneath. This restarts the session on that problem rather than ending it - say so.

This is the one place you may look at solution space, and only far enough to dismiss.

## Constraints, not criteria

**A constraint disqualifies a candidate outright. A criterion ranks the ones that survive.** Only the first belongs in an intent.

Test each one: would it *kill* a candidate, or only score it lower? Demote the second kind and say so.

## The conditions

`Done when` is the part everything later addresses, so it is worth more effort than the rest of the draft put together.

**Each condition is checked, not judged.** Write it so that someone months from now could hold it against the finished thing and say true or false without asking what you meant. "Fast enough" is a judgement. "A cold start answers in under a second" is a condition.

**Each condition is about the problem, not the answer.** Test it against a solution you did not think of: if that solution would solve the problem and still fail the condition, the condition is a mechanism in disguise. Rewrite it as the outcome you actually wanted.

**Number them `C-1`, `C-2`.** They are append-only. Everything downstream cites them by number, so a renumbering silently repoints tags that were written against the old ones.

## The record

Present the intent in the shape `INTENT_FORMAT.md` specifies, and ask where to write it.

**Stopping here is an ending.** Noting an idea and being done with it is a whole use of this skill, not an abandoned run. Say that `/solve` is what designs against the intent, and leave it at that - going on is theirs to ask for.

Where they want no file either, that is also an ending: the problem was worth stating and it is stated. Do not write one to have something to show for the turn. There is nothing to ratify either - the section below is about a file that exists.

### Check it before you ask

Run `/verify` on the written intent, in a subagent with a fresh context, and fix what it finds. You have been in this conversation and cannot see the document the way someone arriving at it will - which is the whole reason the check exists. Then ask.

### Ask for the ratification

Once the file is written, the last act is asking the person whether they recognize their problem in it - not whether the intent reads well, and not whether your proposal sounds reasonable. Ask about the problem.

Record what the yes was worth, because the two are not the same:

- **On evidence** - they can point at the instance.
- **On the argument** - they cannot, and were persuaded the failure is real and would have left no trace. Write that down as the weaker yes it is, together with what would have to keep not happening for it to have been wrong.

**Do not ratify an intent you reconstructed after a solution already existed** without saying so in the same breath. Conditions written by someone who already knows the answer tend to describe the answer, and the person saying yes deserves to know that is the risk they are being asked about.

A no is not a failure of the session. It means the problem is somewhere else, and finding that out before anything was built is the cheapest this skill ever gets.

## Throughout

**End your turn at the first question mark.** One turn, one open question.

**Push back once.** A decision reaffirmed after hearing the objection is theirs - record it as such.
