---
name: discover-change
description: Discover what a change should do and why, before anything is designed or built - the real problem behind the request, how the domain works in the real world, and several approaches to choose from - and write what was agreed into a change file. Use when the developer brings an idea, a wish or a problem that is not yet clear, or a change larger than a quick fix; when they want to question assumptions or rethink where the project is going; and on "let's think this through", "how should we do this", "what are the options", "I have an idea", "question every assumption".
---

# Discover a change

Help the developer think. This is brainstorming, not an interview and not a rush to a solution. Consider several views and approaches, and put them to the developer so they can think them through. Stop when the developer has a direction.

This skill finds out: what are we solving, how does the real world work, and roughly which way do we go. It designs nothing. `/design-change` designs whatever is costly to change, and the builder the rest.

Match the depth to the request. A sharp request with one obvious approach needs a few minutes, not a long talk.

## Understand before proposing

**Read the code the request touches**, and what the software already does about it. Many questions answer themselves there; don't ask the developer what the code can tell you.

**Find the real problem.** A request often names a solution. If it does, ask once what it is for, and what happened the last time it was missing. If the answer points to a different problem, say so. If it confirms the request, carry on: the developer's solution may well be the right one.

**Understand the domain.** The software models something in the real world. Work out how that world works: who does what, what belongs to whom, which rules hold even without software. Ask about the unusual cases in that world that the developer may not have thought of, where they would change the approach. Where the code's model differs from the real world, point it out. Use the developer's words for things, and notice where the code uses a different word for the same thing.

**Ask instead of assuming.** Where you are unsure about something that would change what you propose, ask. Ask one or two questions at a time, each with why you need to know.

## Propose

**Offer at least three approaches** that differ in substance, not in detail. An approach is a general direction. It comes from how the real world works, not from technology. "The gym has bad internet" is an insight; "the app has to work offline" is the direction that follows from it. Which parts work offline, and how, is for `/design-change`, which may find that only some parts need to. Put the simplest first and call it the simplest. Simple means the least we write, understand and keep. For each, say in a few lines what it is, what it is good for, and what it costs. Say which you would pick and why, and then let the developer think.

**Keep it small.** The developer will learn by using the software. Prefer the approach that can be used soonest and that leaves the decisions that are hard to undo for later, when more is known. Name what could wait.

**Weigh the developer's answers before you follow them.** When they choose differently from your recommendation, put their reasons next to yours. Say what their choice gives up, answer the concerns they raised, and look for an approach that keeps the best of both. If their reasons change your view, say so and why. Then the developer decides. They may also combine approaches, reject all of them, or come up with a fourth; propose again where it helps.

## Write it down

When the developer has a direction, find the branch for the change. If you are on the default branch, create a branch from it, named after the change file's slug. If you are on another branch, ask the developer whether this change belongs there. Then write the change file, in the format of `CHANGE_FORMAT.md`. Write its Problem, Approach and Could wait; `/design-change` adds the rest. Show it to the developer and correct what they correct. Commit it on its own, on the change's branch.

Then run `/design-change` on the change.

## Look out for

A start, not the limit.

- **A new project.** There is no code to read. Look instead at what the developer uses today, such as a spreadsheet or a paper form, if they can show it. If the repository has no commits yet, make an empty commit on the default branch before you create the change's branch, so the branch has something to be compared against.
