---
name: find-solution
description: Turn an intent into a solution spec - candidates weighed, one chosen, its criteria tagged to the conditions they serve and its costs named. Typed, not inferred.
disable-model-invocation: true
---

# Find a solution

Design several genuinely different answers to an intent, choose one with the user, and write it down thoroughly enough that whoever builds it needs nothing from you.

This skill's `SOLUTION_FORMAT.md` settles the shape of the spec.

## Start from the conditions

**Read the intent's `Done when` before anything else, and take its numbers with you** - they are what your criteria will tag.

**Read `Not this` as the fence it is.** It names the adjacent problems this run does not
solve, and a solution that quietly answers one has widened the work past what was ratified.

**Read `Open questions` and say what the approach does with each.**

**Read `Constraints` as disqualifiers, not preferences.** A candidate that violates one is out, whatever else it has going for it.

### Given prose instead of a file

A small change arrives as a sentence, and writing an intent document for it would cost more than the change. That path is open, in one order and no other:

1. **Derive the conditions and constraints from what they said. Before you have an approach.**
2. **Show them and wait for the yes.**
3. **Then design.**

**The order is the whole of it.** Conditions written once an approach exists describe the approach, and nobody will be able to see that from the finished file.

**Refuse the short path rather than guess.** Hand back to `/idea` when you cannot state the conditions so someone could check them later, when the list runs long, or when the request is a solution with no problem visible behind it. A short request is not a small problem.

## The field

**Design genuinely different answers, not one answer at three sizes.** Two candidates that differ only in how much of the same thing they do is one candidate. At least three, or say why the space held fewer.

**Show the candidates, do not describe them.** For each one the constraints did not kill, build a cheap specimen - the screen as an HTML mockup, the section as written text, the interface as a sketch of its signatures, one real case walked through the flow. Two approaches described in prose collapse into the thorough one and the simple one, and the user is left choosing between adjectives. Cheap is the point: most of these are about to lose. Where a candidate cannot be shown, say why rather than letting prose stand in unremarked.

**Build the specimens in `specimens/` inside the intent's directory, and nowhere else** - `intents/YYYY-MM-DD-<slug>/specimens/`. That holds for every file they touch: a staging folder for publishing them, and a file fetched back to edit. On the short path, make the intent's directory now. A specimen built anywhere else is left behind there, in the way of every build that follows.

**Agree what decides before you score anything.** Say which properties will pick the winner, and get that agreed while the candidates are still open. Criteria proposed afterwards are criteria chosen to make the answer you already like come out on top, and neither of you will be able to tell.

**Kill on constraints first.** What remains is a choice, and the choice is the user's. Give a recommendation.

**Look at what is already here before inventing.** What the project calls things, what it already does, what it decided before.

## The record

**Walk the approach the way whoever builds it will, before you write it down.** Step through the change as the builder, and at each step ask what you would have to decide that the approach does not say. Every one of those is a question you are about to make someone else guess at. Where it turns up nothing, say so.

**Write it to `02-SOLUTION.md`, in the intent's own directory** - `intents/YYYY-MM-DD-<slug>/`, beside the `01-INTENT.md` it answers.

Where there is no intent document - the short path above - that directory is the one you made for the specimens, or make it now if none were built; `02-SOLUTION.md` is the only document in it. The conditions live in the solution's own `## Intent` section.

**Once the choice is made, `specimens/` holds the chosen candidate and nothing else.** Delete the losers, the picture of today and every board that only served the comparison. Where the specimens were published, cut the published copy to the same files. `SOLUTION_FORMAT.md` says where they are linked from.

**Every open question the intent raised appears in the solution** - settled in `Approach`, deferred in `Open concerns`, or named as still open.

**Tag every criterion with the conditions it serves**, and drop the one that serves none - it is work nobody asked for. Then check the other direction: every condition in the intent is carried by at least one criterion.

**`Accepted tradeoffs` and `Ruled out` are not optional and not decoration.** A reviewer can find a cost you failed to name; no reviewer can find the better solution you never considered.

Write what this costs against what it was chosen over. "Adds some complexity" is a shrug. "Two round trips instead of one, bought for a schema that does not need migrating" is a tradeoff.

**Where a cost the intent's constraints forbid turns up, the approach is disqualified.** Not a tradeoff to accept - a candidate to replace.

**Where a cost turns up that the constraints are silent on, ask.** Their answer belongs in the intent as a new constraint, not in your tradeoff list as a fait accompli.

## Throughout

**Do not reopen the problem.** The intent is ratified. Where you are convinced the problem is wrong, say so plainly and stop - that is a route back to `/idea`, not something to design around.

**Every decision has an answer before you write anything down.** What the intent, the project or the codebase already answers, you answer. What you can defensibly decide, you decide - and where being wrong would be expensive to undo, you decide it and put it in the list for a veto, because being sure is not what makes a one-way door safe. What is genuinely theirs, a tradeoff nothing else implies, you ask. Only what neither of you can settle reaches `Open concerns`, and it says what would settle it.

**End your turn at the first question mark.** One turn, one open question - except the walk's, which go back as one list.

**Push back once.** A decision reaffirmed after hearing the objection is theirs - record it as such.

**Check the spec before you hand it back.** Spawn a subagent with a fresh context and give it three things: `VERIFY.md` from this directory, the path to the solution, and the path to the intent. Nothing else - a reviewer that has your reasoning will read your intentions into the words.

**Stopping here is an ending.** A solution recorded and not built is a whole use of this skill. Say that `/plan-solution` is what turns it into work - name it, because it will not find its own way in - and leave going on to them to ask for.
