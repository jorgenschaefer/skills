---
name: find-solution
description: Find the problem behind a proposed solution, build a field of candidates that differ in kind, weigh them against criteria agreed in advance, and choose.
disable-model-invocation: true
---

# Find the solution

Someone arrives with a solution. Find the problem underneath it, build a field of genuinely different candidates - theirs among them - weigh them against criteria agreed before anything is scored, and recommend one.

The solution they arrive with is evidence about the problem, not a description of it.

Four phases, in order. Criteria invented after the scoring exist to justify a winner, and a field built before the problem is agreed answers a question nobody asked. Every run does all four.

## Phase 1 - The problem

**Reflect the request back**, and let them correct what you take the underlying trouble to be.

**Dig until you have the instance:** what happens today, step by step; what they do instead; how often it bites and what it costs; one concrete recent time it happened. Insist on the last - a problem with no instance behind it is a preference, and saying so out loud changes what everything after it is worth spending.

**Name what must hold** - budget, deadline, who operates the thing afterwards, what may not break. Constraints eliminate candidates. Criteria rank them, later.

**Then state the problem back and get agreement, before any candidate is discussed.** One paragraph in their words: what is wrong, what it costs, and what would be true instead.

**No noun from their solution may appear in it.** "There is no cache", "we don't have a dashboard" are the solution with a *there is no* in front of it. If the problem cannot be stated without naming the mechanism, keep asking what goes wrong when the mechanism is absent.

## Phase 2 - The field

Candidates that **differ in kind**. Two sharing a mechanism are one candidate with a setting changed.

**At least three, and no ceiling.** The list below is a floor, not the exercise - these are the ones that go missing unless something asks for them, not the ones worth having. A field that turns out to be exactly this list stopped at the checklist instead of starting from it.

- **Theirs**, adjusted where phase 1 showed it aiming off, and labelled as theirs.
- **Do nothing.** The cost of the instance is the number everything else has to beat, and sometimes it wins.
- **Remove the need.** Change the process or the expectation so the problem cannot arise. Skipped because it does not feel like building; wins more often than it gets offered.
- **What already exists.** Research it - tools, services, prior art, a path they already own. Primary sources, cited. Reinventing a solved problem is invisible from the inside.

**Then go past the floor.** Borrow from an adjacent domain. Ask who has the opposite problem. Ask what would have to be true for this to be worth solving properly rather than patching. Something in the field should be a candidate nobody had a category for.

**And let one candidate attack a constraint instead of obeying it.** A constraint is a fact about today, not a law: which one, if it moved, opens something better than the surviving field allows, and what would moving it cost? Every other move here searches *within* the constraints, so this is the candidate the field loses by construction.

Each candidate says what it does, what it costs to get, and what it costs to carry afterwards - naming who carries it. One that breaks a constraint leaves the field, and you say which constraint killed it.

## Phase 3 - The weighing

**Criteria first, agreed before anything is scored.** Derive them from what the problem costs, propose them ranked, and get agreement to the list and to the order. What matters most is theirs to say. Once agreed, they do not move.

**Score with claims, not adjectives.** "Simpler" can be said of anything. "One config file instead of three services, maintained by someone who already knows bash" can be wrong, which is what makes it worth writing.

**Name every load-bearing unknown** - a claim that flips the recommendation if it turns out false. Check it now, cheaply, from a primary source, or block on it. A guess here disappears into the result, and the result looks confident either way.

**Reversibility breaks near-ties.** At an honest tie, the one that is cheap to undo wins.

**Show the comparison before the verdict**, while a claim you got wrong about their world can still be corrected.

## Phase 4 - The choice

**One recommendation, and a reason each loser lost** - traceable to a criterion or a constraint. The loser that most needs its reason said out loud is theirs. If they reaffirm it after hearing why it lost, it is theirs to take, and you record that it was.

**Or block.** The decision is not ready: here is the one unknown, and the cheapest way to get it. A recommendation resting on a guess is worse than none. Nothing is left open at the close - a surviving question means the ending is a block, stated as one rather than smuggled in as a caveat.

The findings go in the conversation. Offer a written record only where the decision will be re-argued - the problem, the criteria, the choice, why each loser lost, and what would overturn it - and never write one unasked.

Where the choice is a change to a codebase, say that `/discovery` is next.

## Throughout

**Ask rather than assume.** Where research answers it, go and look - never ask for what you can find out. Where a wrong answer would be cheap to undo, decide it and say that you did: "I'm taking X as given unless you say otherwise." Everything else - priorities, tradeoffs, what they can live with, what a word means to them - ask. The defaults that hurt are the ones taken so confidently they never surfaced as questions.

**End your turn at the first question mark.** One turn, one open question, so an answer never has to be labelled with which question it belongs to.

**Push back once.** Where their reasoning is weak, circular, or contradicted by what you found, say so with your reasoning. Once - a reaffirmed decision is theirs.
