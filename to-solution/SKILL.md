---
name: to-solution
description: Turn an intent into a solution spec - a field of candidates, the decision criteria agreed before anything is scored, one recommendation.
disable-model-invocation: true
---

# To solution

Read an intent, design several genuinely different answers to it, choose one with the user, and write that down thoroughly enough that whoever builds it needs nothing from you.

`SOLUTION_FORMAT.md` settles everything about the spec itself - its sections, what carries an id, which tiers, where the paper lives. This file is what you do.

## The three stops

Three things stop this run. Where a question changes what you would design next, ask it when it arises rather than saving it for a stop.

1. **The decision criteria** - proposed ranked, before anything is scored. A decision: it blocks.
2. **The comparison**, with the domain model on the same turn - a correction window rather than a decision: do not invent a question to make one. Where it rests on a claim about their world you could not check, ask about that claim by name.
3. **What is still unsettled at the close** - a standards contradiction you cannot resolve, or a problem statement your cold re-derivation disagrees with. Conditional; where more than one is live, they go in one turn.

**End your turn at the first question mark.** One turn, one open question.

## Before you design

**The input is a path to the intent.** If the user did not supply one, ask where it lives before doing anything else.

**Re-derive the problem cold.** You did not have the conversation that produced the intent - read it against whatever it points at and form your own account of what is wrong. Where your reading disagrees with the intent's, stop and say so before designing anything.

**The intent's open questions are work**, closed in phases 1 and 2.

**Read the corpus this lands in** - the terminology it already uses, the conventions it already holds, and what sits next to the thing you are about to design. Where it is a codebase, that reading is the code, `UBIQUITOUS_LANGUAGE.md` and the project's ADRs, with `ARCHITECTURE.md` as a lead rather than as truth. **Write in the language the corpus is written in.**

**Find the standards this work is held to.** The intent does not name them; you work them out from what the deliverable turns out to be. A skill whose job is the standard, a file in the project that reads like a rule rather than a description, or the rule the corpus's own examples all obey. `coding-conventions` where the work is code.

**Where two standards contradict and you cannot satisfy both**, name both, say what each would require, and hand the choice over rather than picking one quietly.

## Scope

**A spec describes one thing** - a single change someone outside it could observe. Apply the split test continuously rather than once at the end: **could you do half of this, and would that half be worth doing on its own?** Then pick one and say which you parked.

**The intent carries no scope split** - now, later and never are yours.

**The intent's proposed outcome becomes the spec's success criteria.** Make it checkable rather than inventing a second account of success beside it. Where you cannot, that is a problem-statement disagreement and it belongs at stop 3.

## Phase 1 - The field

**Candidates that differ in kind, not in degree.** Two you could turn into one another by changing a setting are one candidate.

Each says what it does, what it costs to get, and what it costs to carry afterwards - naming who carries it. One that breaks a constraint from the intent leaves the field, and you say which constraint killed it.

**Four kinds, a floor rather than the exercise.** Where one does not apply, say which and why. A field that turns out to be exactly this list stopped at the checklist instead of starting from it.

- **Theirs**, adjusted where the problem statement shows it aiming off.
- **Do nothing.** The cost of carrying the problem is the number every other candidate has to beat, and sometimes it wins. That cost is the intent's instance times how often it recurs; where the intent has no instance, say that doing nothing is cheap.
- **Remove the need.** Change the process, the expectation or the surrounding thing so the problem cannot arise.
- **What already exists.** Prior art, a tool, a path they already own, something in the corpus doing most of the job. Primary sources, cited. Where this is what they arrived with, it is one candidate and not two - say so, and find another kind.

**Then go past the four:** borrow from an adjacent domain, ask who has the opposite problem, ask which constraint from the intent would open something better if it moved and what moving it would cost.

**Show the candidates, do not describe them.** Build a cheap specimen of each - the screen as an HTML mockup, the section as written text, one real case walked through the process. Cheap is the point: most of these are about to lose. Where one cannot be shown, say why.

## Phase 2 - The weighing

**The decision criteria first, agreed before anything is scored** - ones invented afterwards exist to justify a winner. Derive them from what the problem costs; the intent's instance is what prices it. Propose them ranked and get agreement to the list and the order - stop 1. Once agreed, they do not move.

A constraint already eliminated whoever it was going to eliminate; the criteria rank the survivors. One that ranks rather than kills belongs here instead.

**The bar is asymmetric.** A candidate that fits what the corpus already does wins ties and near-ties; a diverging one has to be much better, not merely better. **Reversibility breaks what is left:** at an honest tie, the one that is cheap to undo wins.

**Score with claims, not adjectives.** "Simpler" can be said of anything. "One file instead of three, edited by whoever already edits that file" can be wrong, which is what makes it worth writing.

**Name every load-bearing unknown** - a claim that would flip the recommendation if it turned out false. Check it now, cheaply, from a primary source, or carry it to the close as a block.

**Model the domain as you weigh.** How each candidate carves it up is usually what separates them: where the aggregate boundary sits dictates what can change together. Trace each thing the user will do - this actor does this action on this work object, raising this event - and the missing steps announce themselves: an action with no actor, a work object nobody creates, an event nothing reacts to. Note a bounded context only where the change crosses or establishes one.

**Show the comparison before the verdict** - stop 2, the model with it and in the user's language. Foreground what they can overturn: a cost you have mispriced, a criterion that matters more than its agreed place, a candidate they recognise as something already tried, two things you modelled as one.

## Phase 3 - The choice

**One recommendation, and a reason each loser lost** - traceable to a criterion or a constraint rather than to taste. The loser that most needs its reason said out loud is theirs.

**Or block.** The decision is not ready: here is the one load-bearing unknown, and the cheapest way to get it. An ending, stated as one rather than smuggled in as a caveat, and it produces no spec.

**Or recommend without recording.** Where the decision will not be re-argued, the recommendation goes in the conversation and no spec is written. Never write one unasked.

**Survey what already exists.** Go piece by piece through what the chosen solution needs and find what the corpus already has that resembles it. Each gets a verdict and a reason: **reuse**, **extend**, **absorb**, **replace**, or deliberately **sit beside**. Bounded to what this deliverable touches. A survey full of *replace* says the candidate diverges more than it looked - say so before the choice hardens.

**Break it into parts.** Walk the chosen design the way whoever builds it will. Where the walk reaches something that could be built, checked and set down on its own, that is a part - name what it depends on and what makes it done. The same walk finds what the design leaves undecided: at each step, what would you have to decide that the spec does not say? Answer those here.

## The record

Ask where the spec goes, and write it in the shape `SOLUTION_FORMAT.md` specifies. Present the same content inline.

**Propose a permanent-tier item, never write one.** A glossary term, an ADR - each on its own, as it comes up. `UBIQUITOUS_LANGUAGE_FORMAT.md` and `ADR_FORMAT.md` are the shapes.

**Check the bar rather than assume it** - hand the finished file to a fresh `general-purpose` subagent that has not seen this conversation: *what is the first thing you would have to guess*, and *where does this fight itself*. Most of what comes back you answer by editing the spec. A finding you cannot close that way is either a decision you can still make, or a load-bearing unknown that surfaced late - which turns the ending into a block, and then the spec does not ship.

## Throughout

**Sort every decision, and have an answer for each before you write anything down.** The corpus answers it - resolve it and move on. A wrong default would hurt but there is a defensible answer - decide it, then surface it for a veto. The answer is genuinely the user's, a tradeoff nothing else implies - ask. Keep the running list of what you defaulted and show it.

What neither of you can settle goes in `## Open concerns`, marked as agreed, with what would settle it. Where the guess is not defensible - picking at random, or being wrong costs more than the run - it is a block instead. A spec never carries an open-questions section.

**Push back once, on a decision that is theirs.** Say what you see and why, and then it is theirs. The three stops are not pushback and do not spend it.
