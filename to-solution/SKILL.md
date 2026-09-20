---
name: to-solution
description: Turn an intent into a solution spec - a field of candidates, criteria agreed before scoring, one recommendation.
disable-model-invocation: true
---

# To solution

Read an intent, design several genuinely different answers to it, choose one with the user, and write that down thoroughly enough that whoever builds it needs nothing from you.

## The three stops

Three things stop this run. Between them, ask only what the corpus cannot answer and you cannot defensibly decide - and where such a question changes what you would design next, ask it when it arises rather than saving it for a stop.

1. **Criteria** - proposed ranked, before anything is scored. This one is a decision: it blocks.
2. **The comparison** - shown before the verdict. Not a decision but a correction window: do not invent a question to make one. Where it rests on a claim about their world you could not check, ask about that claim by name.
3. **What is still unsettled at the close** - a standards contradiction you cannot resolve, or a problem statement your cold re-derivation disagrees with. Conditional, and most runs hit none. Where more than one is live, they go in one turn.

**End your turn at the first question mark.** One turn, one open question.

## Before you design

**Read the intent, and re-derive the problem cold.** You did not have the conversation that produced it - read it against whatever it points at and form your own account of what is wrong. Where your reading disagrees with the intent's, stop and say so before designing anything.

**Take the intent's open questions as work** - closing them is part of phases 1 and 2, not a separate errand.

**Read the corpus this lands in** - the terminology it already uses, the conventions it already holds, and what sits next to the thing you are about to design.

**Find the standards this work is held to.** The intent does not name them; you work them out from what the deliverable turns out to be. Look for a skill whose job is the standard. Look in the project for a file that reads like a rule rather than a description: a contributing guide, a style guide, a glossary, an `ADR` directory. Look at the corpus itself and infer the rule its examples all obey.

**Where two standards contradict and you cannot satisfy both, stop and say so rather than picking one quietly.** Name both, say what each would require, and hand the choice over.

## Scope

**A spec describes one thing** - a single change someone outside it could observe, substantial enough to be worth doing on its own.

Apply the split test continuously rather than once at the end: **could you do half of this, and would that half be worth doing on its own?** Then pick one and say which you parked.

**Then say what comes after.** The intent carries no scope split - what lands under now, later and never is this phase's decision.

**The intent's proposed outcome becomes the spec's success criteria.** Make it checkable rather than inventing a second account of success beside it. Where you cannot make it checkable as written, that is a problem-statement disagreement and it belongs at stop 3.

## Phase 1 - The field

**Candidates that differ in kind, not in degree.** Two you could turn into one another by changing a setting are one candidate.

Each candidate says what it does, what it costs to get, and what it costs to carry afterwards - naming who carries it. One that breaks a constraint from the intent leaves the field, and you say which constraint killed it.

**Four kinds. Where one does not apply, say which and why.**

- **Theirs**, from the intent's account of what they arrived with, adjusted where the problem statement shows it aiming off.
- **Do nothing.** The cost of carrying the problem is the number every other candidate has to beat, and sometimes it wins. That cost is the intent's instance, times how often it recurs; where the intent has no instance, say that doing nothing is cheap.
- **Remove the need.** Change the process, the expectation or the surrounding thing so the problem cannot arise.
- **What already exists.** Prior art, a tool, a path they already own, something in the corpus doing most of the job. Primary sources, cited. Where this turns out to be what they arrived with, it is one candidate and not two - say so, and find another kind to make up the number.

**Then go past the four:** borrow from an adjacent domain, ask who has the opposite problem, ask which constraint from the intent would open something better if it moved and what moving it would cost.

**Show the candidates, do not describe them.** Build a cheap specimen of each - the screen as an HTML mockup, the section as written text, one real case walked through the process. Cheap is the point: most of these are about to lose. Where a candidate cannot be shown, say why rather than letting prose stand in unremarked.

## Phase 2 - The weighing

**Criteria first, agreed before anything is scored** - criteria invented afterwards exist to justify a winner. Derive them from what the problem costs - the intent's instance is what prices it. Propose them ranked, and get agreement to the list and to the order; this is stop 1. Once agreed, they do not move.

A constraint already eliminated whoever it was going to eliminate; criteria rank the survivors. One that turns out to rank rather than kill is a criterion, and it belongs here instead.

**The bar is asymmetric.** A candidate that fits what the corpus already does wins ties and near-ties. A diverging one has to be much better, not merely better.

**Score with claims, not adjectives.** "Simpler" can be said of anything. "One file instead of three, edited by whoever already edits that file" can be wrong, which is what makes it worth writing.

**Name every load-bearing unknown** - a claim that would flip the recommendation if it turned out false. Check it now, cheaply, from a primary source, or carry it to the close as a block. A lesser unknown goes to `## Open concerns`.

**Show the comparison before the verdict** - stop 2. Foreground what they can overturn: a cost you have mispriced, a criterion that matters more than its agreed place, a candidate they recognise as something already tried.

## Phase 3 - The choice

**One recommendation, and a reason each loser lost** - traceable to a criterion or a constraint rather than to taste. The loser that most needs its reason said out loud is theirs.

**Or block.** The decision is not ready: here is the one load-bearing unknown, and the cheapest way to get it. A block is an ending, stated as one rather than smuggled in as a caveat, and it produces no spec.

**Survey what already exists.** Go piece by piece through what the chosen solution needs and find what the corpus already has that resembles it. Each gets a verdict and a reason: **reuse** it as it stands, **extend** it, **absorb** it, **replace** it, or deliberately **sit beside** it. Bounded to what this deliverable touches. A survey full of *replace* says the candidate diverges more than it looked - say so before the choice hardens.

**Break it into parts.** Walk the chosen design the way whoever builds it will. Where the walk reaches something that could be built, checked and set down on its own, that is a part - name what it depends on. A part nobody could tell was finished is not one yet: say what makes it done.

The same walk finds what the design leaves undecided: at each step, what would you have to decide that the spec does not say? Answer those here rather than leaving them for whoever builds it to notice.

## The record

Write the spec beside the intent, in the shape `SOLUTION_FORMAT.md` specifies. Present the same content inline.

**The winning specimen goes beside the spec, and `## Design` links it.** Delete the losing ones.

**Check the bar rather than assume it** - hand the finished file to a fresh `general-purpose` subagent that has not seen this conversation, and ask it two questions: *what is the first thing you would have to guess*, and *where does this fight itself*. Most of what comes back you answer by editing the spec. A finding you cannot close that way is one of two things: a decision you can still make, which you make; or a load-bearing unknown that surfaced late, which turns the ending into a block. Then the spec does not ship: say what would unblock it.

## Throughout

**Sort every decision.** The corpus answers it - resolve it and move on. A wrong default would hurt but there is a defensible answer - decide it, then surface it for a veto. The answer is genuinely the user's, a tradeoff nothing else implies - ask. Keep the running list of what you defaulted and show it.

**Push back once, on a decision that is theirs.** Say what you see and why, and then it is theirs. The three stops are not pushback and do not spend it.

**Every decision has an answer before you write anything down.** Show the guesses among them: anything the user can simply answer stops being a guess and becomes part of the design. What neither of you can settle goes in `## Open concerns`, marked as agreed, with what would settle it. Where the guess is not defensible - you would be picking at random, or being wrong costs more than the run - it is a block instead. A spec never carries an open-questions section.
