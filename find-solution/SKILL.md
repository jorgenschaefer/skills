---
name: find-solution
description: Find the problem behind a proposed solution, build a field of candidates that differ in kind, weigh them against criteria agreed in advance, and choose.
disable-model-invocation: true
---

# Find the solution

Someone arrives with a solution. Find the problem underneath it, build a field of genuinely different candidates - the arriving solution among them - weigh them against criteria agreed before anything is scored, and recommend one.

The solution someone arrives with is evidence about the problem, not a description of it. It says where they were looking. It does not say what they were looking at.

## Where this ends

Two endings, and which one you reach is not yours to choose - it falls out of whether the decision rests on anything unknown.

- **A choice.** One recommendation, the criteria it won on, and why each other candidate lost. Doing nothing is a legitimate winner and reaching it is not a failed run.
- **A block.** The decision is not ready: a single fact would flip it, nobody knows the fact, and finding it out is cheaper than building the wrong thing. Name the fact and the cheapest way to get it. A recommendation resting on a guess is worse than no recommendation, because the guess is invisible in the result.

Anything that must be built afterwards is somebody else's job. Where the chosen solution is a change to a codebase, close by pointing at `/discovery`.

## The shape

Four phases, in order, and each one's exit condition is the next one's ground:

1. **The problem** - what is actually wrong, agreed in the user's words, with an instance behind it and the constraints named.
2. **The field** - candidates that differ in kind, built by research rather than brainstorm.
3. **The weighing** - criteria fixed first, then concrete claims, then the unknowns that would flip it.
4. **The choice** - one recommendation, why each other lost, and a record if it will be re-argued.

The order is load-bearing. Criteria invented after the scoring exist to justify a winner. A field built before the problem is agreed is a field of answers to a question nobody asked.

**Every run does all four.** There is no short lane: the command was typed deliberately, and the decisions that most deserve this are the ones that looked small at the start.

## Phase 1 - The problem

**Open by reflecting the request back.** Say what you understand them to want and what you take the underlying trouble to be, and let them correct the second half. That correction is the cheapest one available in the whole run.

**Dig until you have the instance.** A problem stated in general - it's slow, it's confusing, we need a way to do X - is not something a candidate can be weighed against. Get to:

- what happens today, step by step, in the situation that goes wrong;
- what they do instead - the workaround they have already built, which is the most honest description of the problem available;
- how often it bites, what it costs when it does, and who else it bites;
- one concrete recent time it happened.

Insist on the last. A problem with no instance behind it is a preference, and the two are worth very different amounts of work. Where there genuinely is no instance - something anticipated rather than suffered - say that is what you have, out loud, because it changes what everything after this is worth spending.

**Name what must hold.** Budget, deadline, who has to operate the thing afterwards, what may not break, what cannot be changed. Constraints eliminate candidates; criteria rank them. Mixing the two lets a candidate that was never viable dilute the field, so the eliminating ones are settled here, before the field exists.

**Then state the problem back and get agreement, before any candidate is discussed.** One paragraph in the user's own words: what is wrong, what it costs, and what would be true instead.

**Check it against the arriving solution before you send it.** No noun from that solution may appear in the problem statement. "There is no cache", "we don't have a dashboard", "the script isn't automated" are the solution with a *there is no* in front of it. If the problem cannot be stated without naming the mechanism, phase 1 is not finished - keep asking what goes wrong when the mechanism is absent.

This paragraph is the phase's exit condition and everything after it is built on it.

## Phase 2 - The field

At least three candidates that **differ in kind**, and no ceiling - a field that honestly ran to seven is a good field, not an undisciplined one. Two candidates sharing a mechanism are one candidate with a setting changed, and a field padded that way is worse than a narrow one, because it looks like a choice was made.

**Think first. The list below is a floor, not the exercise.** These four are the ones that go missing unless something asks for them - not the ones worth having. A field that turns out to be exactly these four stopped at the checklist instead of starting from it, so reach the floor and keep going: the candidate that wins is often the one nobody had a category for.

- **What they arrived with**, adjusted where phase 1 showed it aiming slightly off. Label it as theirs. Naming it keeps the rest of the run from quietly drifting back toward it out of deference, or away from it to look independent.
- **Do nothing.** Always in the field. The cost of the instance, at the frequency established in phase 1, is the number every other candidate has to beat - and where the problem is rare or cheap, it beats them.
- **Remove the need.** Change the process, the expectation, or whatever upstream produces the situation, so the problem cannot arise. This is the candidate people skip because it does not feel like building, and it is the one that most often wins outright.
- **What already exists.** Research this - it is not a brainstorm. Search for how the problem is already solved: tools, services, libraries, prior art, an established practice, a path already present in the thing they own that they did not know was there. Read primary sources rather than recollection, and cite what you read. Reinventing a solved problem is the expensive mistake this phase exists to prevent, and it is invisible from the inside.

Then go past it. Borrow from an adjacent domain - the same problem shape solved elsewhere arrives with its failure modes already documented. Invert the thing: who has the opposite problem, and what do they do. Ask what would have to be true for the problem to be worth solving properly rather than patching, and what that unlocks. Something in the field should be a candidate nobody in the conversation had thought of, and if nothing is, the research was too narrow rather than the field too small.

For each candidate, three things and no essay: what it does; what it costs to get; what it costs to **carry** - the maintenance, the operating burden, the person who has to understand it in a year. Name who that person is.

**Kill on constraints, out loud.** A candidate that breaks a phase-1 constraint leaves the field, and you say which constraint killed it. Carrying a dead candidate into the weighing to make the field look wide corrupts the comparison.

**Then let one candidate attack a constraint instead of obeying it.** The phase-1 constraints eliminate, and that is what they are for - but a constraint is a fact about the world today, not a law. Ask which one, if it moved, would open something better than anything the surviving field allows, and what moving it would cost: a budget that the output itself could pay for, a deadline nobody outside the room set, a tool nobody has actually refused to change, a standard that was assumed rather than agreed. This is the candidate the field loses by construction, because every other move in this phase is a search *within* the constraints.

Where the research honestly leaves one candidate, say so and say why. But "only one" reached without the research is not a finding, it is unfinished legwork.

## Phase 3 - The weighing

**Criteria first, and they are agreed before anything is scored.** Derive them from what the problem costs - the things that go wrong in the instance are exactly the things a solution is judged on - propose them ranked by what you believe matters most, and get agreement to both the list and the ranking. What matters most is the user's call and never yours. Once agreed, the criteria do not move: a criterion appearing after the scores exist is there to justify a winner.

**Score with claims, not adjectives.** "Simpler" and "more flexible" decide nothing and can be said of anything. "One config file instead of three services, maintained by someone who already knows bash" decides something, and can be wrong - which is the property that makes it worth writing.

**Name every load-bearing unknown.** A claim is load-bearing when the recommendation flips if it turns out false. For each one: check it, or block on it. Checking means a primary source, a five-minute experiment, a spike, a price page - cheap, and now, while the decision is still open. Guessing past one is the failure this whole phase is arranged to prevent, because the guess disappears into the result and the result looks confident either way.

**Cost to carry outweighs cost to get** where they conflict. One is paid once and the other is paid repeatedly, usually by someone who was not in this conversation.

**Reversibility breaks near-ties.** At an honest tie, the candidate that is cheap to undo wins outright. It is not a tiebreaker of last resort - it is the strongest thing you know about a decision whose criteria could not separate two options.

**Show the weighing back before concluding it.** The comparison, not the verdict: candidates against criteria, the claims that carried each, the unknowns and what checking them showed. What they can veto here is a claim you got wrong about their world, and that veto is unavailable once the recommendation is on the table and only the verdict is in view.

## Phase 4 - The choice

**One recommendation, and a reason each other lost** - each traceable to a criterion or a constraint, never to a shrug. The loser that most needs its reason stated is the solution they arrived with. If it lost, say so plainly, with the reasoning, once. If they reaffirm it after hearing that, it is theirs: take it, and record that it was theirs, so nothing later reopens a settled argument.

**Nothing is left open at the close.** Every question the choice rests on has an answer - from research, from the user, or from a recommendation they confirmed. A surviving open question means the ending is a block, and blocks are stated as blocks rather than smuggled in as caveats under a recommendation.

**Offer the record; never write it unasked.** Most decisions are made once and live in the doing. Offer `DECISION_<topic>.md` - shape in `DECISION_FORMAT.md` - when the decision will be re-argued: it cost real effort to reach, more than one person lives with it, or the reasoning will be invisible to whoever meets the result later. Present what it would say and let them decide whether it becomes a document at all.

Then say what comes next. Where the choice is a change to a codebase, that is what `/discovery` is for.

## Throughout

These hold in every phase, which is why none of them is one.

### Nothing is assumed

Sort every question the run raises into one of three, and the middle bucket is deliberately narrow:

- **Research answers it.** Go and look - the code, the docs, the primary source, the thing they already own. Never ask for what you can find out, and never recall what you can read.
- **A wrong answer would be cheap and easy to undo.** Decide it, and say out loud that you did, in the form "I'm taking X as given unless you say otherwise". Keep the running list and confirm it before the weighing closes.
- **Anything else.** Ask. Priorities, tradeoffs, what they can live with, what matters most, what a thing means to them - none of these are inferable from context, and an inferred one is wrong invisibly.

The defaults that hurt are the ones taken so confidently they never surfaced as questions. Surfacing them is the whole of the discipline.

### How to ask

**End your turn at the first question mark.** The moment a turn reaches a question that seeks new information, send it - a second question, or an "and also", waits for the next turn. One turn, one open question, so an answer never has to be labelled with which question it belongs to. Confirming something for veto is not an originating question, but it still gets its own turn.

### Role

A discussion partner, not a stenographer.

- **Surface what they have not raised.** If something looks load-bearing and nobody has mentioned it, raise it.
- **Push back once.** Where their reasoning is weak, circular, or contradicted by what you found, say so with your own reasoning. Once. A reaffirmed decision is theirs, and re-arguing it costs more than the mistake would.
- **Ask what their words mean.** When a term carries weight and could mean two things, ask which, rather than baking in the reading that happened to occur to you.
