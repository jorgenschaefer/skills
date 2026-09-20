---
name: to-solution
description: Turn an intent into a solution spec - a field of candidates, criteria agreed before scoring, one recommendation, written down so whoever builds it needs nothing from you. Reads what /idea produced.
disable-model-invocation: true
---

# To solution

Read an intent, design the thing that answers it, and write it down thoroughly enough that whoever builds it needs nothing from you.

The intent is at `specs/<slug>/intent.md`, or wherever the project keeps this lane's paper. Take the path if you were given one; otherwise find it, and where more than one is unstarted, ask which - that is not one of the stops below, it is the argument you should have had.

Three phases, in order, and the order is load-bearing: the standards are read before the field, because candidates you cannot hold to anything cannot be told apart - and the criteria are agreed before the scoring, because criteria invented afterwards exist to justify a winner.

## The three stops

This runs across several turns, and three things stop it. Between them you work without asking - a phase that ends in a question nobody needed is the cost this skill is trying to avoid.

1. **Criteria** - proposed ranked, before anything is scored. This one is a decision: scoring does not start until the order is agreed.
2. **The comparison** - shown before the verdict. Not a decision but a correction window, so it asks for nothing and ends the turn only if they have something to say. Where the comparison rests on a claim about their world you could not check, ask about that claim by name.
3. **What you could not settle alone** - a standards contradiction you cannot resolve, an intent question only the originator could answer, or a problem statement your cold re-derivation disagrees with. Conditional, and most runs hit none of them. Where more than one is live, they go in one turn.

**End your turn at the first question mark.** One turn, one open question, so the user never has to work out which part of their reply answers which question. That rule binds at these three stops; it is not a licence to open a fourth.

## Before you design

**Read the intent, and re-derive the problem cold.** You did not have the conversation that produced it and should not pretend to - read it against whatever it points at and form your own account of what is wrong. Where your reading disagrees with the intent's, stop and say so before designing anything, because a design answering the wrong problem is indistinguishable from a good one until it ships. Whichever reading survives that exchange is the one `## Why` records, and it says which it was.

**Take the intent's open questions as work.** The ones marked *needs the field* are yours to close, and closing them is part of phases 1 and 2 rather than a separate errand. The ones marked *needs the originator* you cannot close at all - carry them to stop 3, and where the person in the room still cannot answer, the design either does not depend on it or the run blocks.

**Read the corpus this lands in** - the terminology it already uses, the conventions it already holds, and what sits next to the thing you are about to design. Reusing a concept that already exists beats introducing one that does the same work under a new name, and you cannot reuse what you have not read.

**Find the standards this work is held to.** The intent does not name them; you work them out from what the deliverable turns out to be, and the search is the same every time. Look for a skill whose job is the standard - the `coding-conventions` skill for code, `writing-great-skills` for a skill - and look under `.agents/skills/` as well as the project's own skill directories, since not every standard is installed as an invocable skill. Look in the project for a file that reads like a rule rather than a description: a contributing guide, a style guide, a glossary, a conventions doc, an `ADR` directory. Look at the corpus itself and infer the rule the existing examples all obey. Record what you found in `## Standards`, **including when the answer is nothing** - "looked, found none" is a finding, and it tells the next person how much the design was actually constrained.

**Where two standards contradict and you cannot satisfy both, stop and say so rather than picking one quietly.** A contradiction resolved silently is a policy decision made by whoever happened to be drafting, and it is invisible afterwards. Name both, say what each would require, and hand the choice over. Where nobody present owns it, design to the one you can defend and record the other as unresolved.

## One deliverable

**A spec describes one thing** - a single change someone outside it could observe, substantial enough to be worth doing on its own.

Apply the split test continuously rather than once at the end, because scope grows a sentence at a time: **could you ship half of this, and would that half still be worth shipping?** If yes it is two, and the honest move is to pick one and park the other in the project's `IDEAS.md`, with enough context to resurrect it. Parking is not refusing, and saying so keeps it from feeling like one.

**Then say what comes after.** `## Now and later` holds the smallest slice worth doing and the part deliberately held back. Later is not a non-goal - a non-goal is out of scope for good, later is scope you are choosing not to build yet. Both sections are yours to write: the intent has neither, and what you park under either is a decision this phase makes.

**The intent's proposed outcome becomes the spec's success criteria.** It already says what is true once this is solved; your job is to make it checkable, not to invent a second account of success beside it. Where you cannot make it checkable as written, that is a problem-statement disagreement and it belongs at stop 3.

## Phase 1 - The field

**Candidates that differ in kind.** Two sharing a mechanism are one candidate with a setting changed, and a field of those is a decision already made.

Four kinds go missing unless something asks for them, so ask for them. **Where one genuinely does not apply, say which and why** - a field of three with a reason is honest; a field of three that quietly dropped *do nothing* is not.

- **Theirs**, from the intent's account of what they arrived with, adjusted where the problem statement shows it aiming off, and labelled as theirs.
- **Do nothing.** What the problem costs to keep carrying is the number every other candidate has to beat, and sometimes it wins. The intent prices it: its `## Problem` carries one instance and how often it recurs, and that, repeated for as long as nobody acts, is the cost. Where the intent says there is no instance yet, doing nothing is cheap by default and you say so - a candidate that beats an unpriced floor has beaten nothing.
- **Remove the need.** Change the process, the expectation or the surrounding thing so the problem cannot arise. Skipped because it does not feel like building; wins more often than it gets offered. Outside code this is usually deleting something rather than adding one.
- **What already exists.** Prior art, a tool, a path they already own, something in the corpus doing most of the job. Primary sources, cited. Where this turns out to be the same mechanism they arrived with, it is one candidate and not two - say so, and the field needs another kind to make up the number.

**Then go past the four.** They are a floor, not the exercise: borrow from an adjacent domain, ask who has the opposite problem, ask which constraint from the intent would open something better if it moved and what moving it would cost. A field that stops at exactly the floor stopped at the checklist instead of starting from it.

Each candidate says what it does, what it costs to get, and what it costs to carry afterwards - naming who carries it. One that breaks a constraint from the intent leaves the field, and you say which constraint killed it.

## Phase 2 - The weighing

**Criteria first, agreed before anything is scored.** Derive them from what the problem costs. The intent states the problem but rarely prices it, so say what you take the cost to be as part of proposing the criteria - a ranking whose basis is unstated is a ranking nobody can disagree with. Propose them ranked, and get agreement to the list and to the order. What matters most is the user's to say, and this is stop 1. Once agreed, they do not move.

Criteria are not the intent's constraints. A constraint already eliminated whoever it was going to eliminate; criteria rank the survivors. A constraint that turns out to rank rather than kill is a criterion, and it belongs here instead.

**Score with claims, not adjectives.** "Simpler" can be said of anything. "One file instead of three, edited by whoever already edits that file" can be wrong, which is what makes it worth writing.

**Name every load-bearing unknown** - a claim that would flip the recommendation if it turned out false. Check it now, cheaply, from a primary source, or carry it to the close as a block. An unknown that would change something *below* the recommendation is not this: it is checked if cheap and recorded under `## Open concerns` if not.

**Show the comparison before the verdict** - stop 2.

## Phase 3 - The choice

**One recommendation, and a reason each loser lost** - traceable to a criterion or a constraint rather than to taste. The loser that most needs its reason said out loud is theirs.

**Or block.** The decision is not ready: here is the one load-bearing unknown, and the cheapest way to get it. A recommendation resting on a guess is worse than none. A block is an ending, stated as one rather than smuggled in as a caveat, and it produces no spec.

## The record

Write the spec as `spec.md` in the intent's own directory, in the shape `SOLUTION_FORMAT.md` specifies. Present the same content inline; that is not a question and does not end your turn.

**The bar: buildable from the spec plus the corpus, without asking you anything.** Check it rather than assume it - hand the finished file to a fresh `general-purpose` subagent that has not seen this conversation, and ask it two questions: *what is the first thing you would have to guess*, and *where does this fight itself*. Most of what comes back you answer by editing the spec. A finding you cannot close that way is one of two things: a decision you can still make, which you make; or a load-bearing unknown that surfaced late, which turns the ending into a block after all. Then the spec does not ship: leave the file uncommitted, say what blocked it and what would unblock it, and do not commit a spec you have just said is not ready.

**Then commit.** Where the work lives in version control, commit `spec.md` and `intent.md` together so the chain stays legible - and where the intent was already committed by `/idea`, commit the spec alone and say which commit carries the intent.

**Close by saying who builds it.** Where the work turned out to be an observable change to a codebase running this pipeline, `/discovery` is the door that reaches `/spec-to-tickets` and the unattended loop - say so, and say that going that way means having the interview again, since this spec carries none of the anchors that loop needs. Otherwise the spec is the handoff and there is nothing after it.

## Throughout

**Push back once, on a decision that is theirs.** Say what you see and why, and then it is theirs: a choice reaffirmed after hearing the objection is recorded in the spec as theirs. The three stops are not pushback and do not spend it - they are handshakes the run is built on.

**Every decision has an answer before you write anything down, and `## Open concerns` records the ones you had to guess at.** The test is whether the guess is defensible and written down as a guess: one that is goes in Open concerns with what would settle it, and one that is not - where you would be picking at random, or where being wrong costs more than the run - is a block. A spec never carries an open-questions section, because everything in it has been decided.
