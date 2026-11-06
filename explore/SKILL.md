---
name: explore
description: Think a change through with the developer before anything is built - the real problem behind the request, how the domain works in the real world, and several approaches to choose from - and write what was agreed into a change file. Use when the developer brings an idea, a wish or a problem that is not yet clear, or a change larger than a quick fix; and on "let's think this through", "how should we do this", "what are the options", "I have an idea".
---

# Explore

Help the developer think. This is brainstorming, not an interview and not a rush to a solution. Consider several views and approaches, and put them to the developer so they can think them through. Stop when the developer has a direction.

Explore understands: what are we solving, how does the real world work, and roughly which way do we go. It designs nothing. `/decide` designs whatever is costly to change, and the builder the rest.

Match the depth to the request. A sharp request with one obvious approach needs a few minutes, not a long talk.

## Understand before proposing

**Read the code the request touches**, and what the software already does about it. Many questions answer themselves there; don't ask the developer what the code can tell you. In a new project there is no code. Look instead at what the developer uses today, such as a spreadsheet or a paper form, if they can show it.

**Find the real problem.** A request often names a solution. If it does, ask once what it is for, and what happened the last time it was missing. If the answer points to a different problem, say so. If it confirms the request, carry on: the developer's solution may well be the right one.

**Understand the domain.** The software models something in the real world. Work out how that world works: who does what, what belongs to whom, which rules hold even without software. Where the code's model differs from the real world, point it out. Use the developer's words for things, and notice where the code uses a different word for the same thing.

**Ask instead of assuming.** Where you are unsure about something that would change what you propose, ask. Ask one or two questions at a time, each with why you need to know.

## Propose

**Offer at least three approaches** that differ in substance, not in detail. An approach is a general direction, and it comes from how the real world works, not from technology. "The gym has bad internet, and the app has to deal with that" is a direction. Which parts work offline, and how, is for `/decide`, which may find that only some parts need to. Put the simplest first and call it the simplest. For each, say in a few lines what it is, what it is good for, and what it costs. Say which you would pick and why, and then let the developer think.

**Keep it small.** The developer will learn by using the software. Prefer the approach that can be used soonest and that leaves the decisions that are hard to undo for later, when more is known. Name what could wait.

**Build on the developer's answers.** They will combine approaches, reject all of them, or come up with a fourth. Follow them. Propose again where it helps.

## Write it down

When the developer has a direction, write the change file, in the format of `CHANGE_FORMAT.md`. Write its Problem, Approach and Could wait; `/decide` adds the rest. Show it to the developer and correct what they correct. Commit it on its own.

Put what could wait on the backlog with `/backlog`, one item each, if the developer wants to keep it.

Then run `/decide` on the change.
