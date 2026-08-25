---
name: implement-ticket
description: Build one ticket from a run's `tickets/` directory with nobody watching - the driver's per-ticket step. Wraps /implement with the rules that hold when there is no one to ask.
disable-model-invocation: true
---

# Implement Ticket

Build the ticket at the path you were given, then hand back.

The craft is `/implement`'s. Read the `implement` skill - it sits beside this one, as `implement/SKILL.md` - and follow all of it: the RED-first loop, the verification command, the two reviews, the bounded attempts, the `Record` it writes at the end. This skill supplies the one fact `/implement` cannot know on its own: **nobody is watching this run.** Everything below follows from that.

`TICKET_FORMAT.md` describes the shape of the ticket you are building and of what you write back into it.

## No questions

`/implement` never builds past an ambiguity. With a human present it asks; here there is nobody to ask, and the run is `claude -p`, which cannot prompt. So the resolution is a halt: set `status`, write the `## Halt` block, and stop.

**Halting is a normal outcome, not a failure.** It is always better than a plausible invention, because nobody is watching the next ticket build on top of it. An ambiguity you guess past is one every ticket after this one inherits, and the first person to see it will be reading the finished feature.

## Halting

`/implement` says which four conditions stop a build and names each one: `stale-spec`, `drift`, `blocked`, `mystery`. Here is what stopping does with them.

To halt: set `status: blocked` in the ticket's frontmatter, append the `## Halt` section `TICKET_FORMAT.md` specifies - the reason, what happened, and what the human needs to decide - then commit **the ticket alone** and stop. Stage nothing else. Leave partial work uncommitted in the working tree so whoever picks this up can see how far you got.

The driver reads `status` from the ticket to decide whether to continue, so setting it is what makes a halt visible. A run that stops without setting it looks like a crash, and the human gets a transcript to read instead of a sentence.

## Workflow tests are not yours to change

`tests/workflows/` holds journeys the project ratified with a human. A ticket that has to touch one says so in a `## Workflow tests` section, written before the run started; the driver checks that section as it stood beforehand and stops the run over any change made without it.

So check the ticket for that section before you touch anything under there. Where the work needs it and the ticket does not carry it, halt `blocked` now rather than building the ticket and having the run stopped afterwards - the answer is the same and it costs a whole ticket less. Adding the section yourself is not an answer: it is the thing the check exists to catch.

## Say what you are doing

A ticket takes a long time to build and your narration is the only progress anyone watching can see. Silence is indistinguishable from a hang, so as you enter each phase, say so in one short plain line: reconciling the ticket, writing the RED test for a given criterion, running the verification command, dispatching each review, committing.

Put it on the **first line** of the message - that is the part that reaches the screen. And keep it to phases, not a running commentary on tool calls: roughly a dozen lines across a whole ticket is right.

## Nothing runs in the background

There is no next turn. The run is `claude -p`, so ending your turn ends the process, and whatever you detached dies unfinished with it - a Bash call with `run_in_background`, a `Monitor`, a subagent dispatched detached. Their notifications arrive after the session is gone.

Run everything in the foreground and wait for it, however long it takes. A slow suite is a reason to raise the timeout, not to detach. And never end a turn in order to wait: "I'll pick this up when it reports" is the end of the run, not a pause - if you are narrating that you are waiting, you have already detached something you shouldn't have.

Waiting costs wall clock, which the driver expects; it runs a ticker for exactly this silence. Detaching costs the ticket: the session ends without setting `status`, so the driver reports a halt nobody wrote and stops for a human who has nothing to read.
