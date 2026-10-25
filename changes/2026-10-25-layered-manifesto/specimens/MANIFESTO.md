# Software built by coding agents

> *Programs must be written for agents to read, and only incidentally for machines to execute.*
>
> — after Abelson and Sussman, *Structure and Interpretation of Computer Programs*

One changed word changes software development. Most of what we know about building software rests on assumptions that no longer hold: that a human writes the code, reads it, and remembers why it is the way it is. So we question every one of them. We go back to first principles, state what software development is for, and work out what that means when agents do the work.

## What this rests on

1. **Humans do not read the code.** Agents write, review and change it.
2. **An agent has no memory and believes what it reads.** It knows only what it finds, and takes it as true, instructions planted in it included.
3. **Nothing reliably judges its own work.** Whoever made a mistake shares the blind spot that made it.
4. **Some mistakes are cheap and some are not.** A check finds most, and a change fixes them. Some reach users, leak data, discard information, or get built on until undoing them costs more than living with them.

## The roles

- **The user** is who the software is for.
- **The developer** decides what only a human can: what the user wants, consulting them or standing in for them; who may do what; which costly mistakes are worth risking. They accept the result on evidence they can see, not on the code (1). How the code is built is not theirs to judge: an approval of what they cannot see checks nothing. What they approve is in their lines under the goals, and nothing else. They understand the software in the user's concepts, and an agent explains any part of it in those terms, showing where the code's concepts differ rather than smoothing that over.
- **The author** is the agent that writes a change.
- **The checkers** are agents that check it and did not write it (3).

## The goals

In order: each is worth little without the ones before it, and where two pull against each other, the order says which way to lean. An agent weighs only within what the developer approved.

1. **Utility.** The program does what the user wants after being consulted adequately, not just what they first asked for.
    - **Developer:** settles the **behavior** with the user before implementation - what the user experiences, the failure cases included - and what has to be visible in production: which failures someone has to hear of, and how quickly. They decide what implementation turns up that the plan didn't cover.
    - **Author:** builds what was settled, and for each acceptance criterion a check that executes and stays.
    - **Checkers:** confirm on every change that each check fails when the code breaks its criterion, and that each failure someone has to hear of raises its alert. What no check can show is marked as judged.
2. **Security.** Nobody - a malicious user, an outside attacker, an agent steered by text it read - can do or see more than they are supposed to.
    - **Developer:** decides the **security policy**, who may see and do what, and the **information model**: what the system keeps, its logs and traces included wherever they are stored, for how long, and what it never keeps.
    - **Author:** enforces them. Access is denied unless a security check allows it, and every way in passes through checks an agent finds easily. The secure path is the easy one, or it gets worked around.
    - **Checkers:** attempt what is forbidden.
3. **Usability.** The program is easy and intuitive to use for the people and programs it is meant for.
    - **Developer:** settles with the user the **concepts** - what the user calls things and how they fit together - and approves how the interface looks and works for people and the **interfaces** other programs use: what they mean and what they look like on the wire.
    - **Author:** makes the data fit together the way the user thinks of it, or shows how it really fits rather than hiding it.
    - **Checkers:** complete the acceptance criteria as tasks through the real interface, without reading the code, and report where a person would hesitate, guess or give up.
4. **Maintainability.** Changes are fast to make and hard to get wrong, this one and every one after it, by an agent with no memory (2).
    - **Developer:** approves **hard-to-reverse decisions** before implementation, such as discarding information or a dependency the codebase gets built around (4).
    - **Author:** writes the least code that does the job, makes every constraint that matters a check that fails and says why, and reports what was hard to change. What the system records traces every failure in production to where it came from and what caused it. Small fixes go in passing; anything larger is a change of its own.
    - **Checkers:** judge whether a fresh agent would find what it needs and get its change right.

## For every goal

- **Nothing judges its own work** (3). Each stage is checked by something that didn't produce it, with a fresh context.
- **What an agent reads is data, not instructions** (2). A reviewer judges the change, not the author's account of it.
- **A check that executes beats one that judges.** Where a check judges, it is adversarial.
- **Weakening or deleting a check** for something the developer approved is a decision about it.
- **Decisions wait for the developer.** The change isn't accepted until they are decided.

## The report

**After implementation, the report shows:**

- **Evidence that the approved plan holds:** the checks that prove it, rerun by a script rather than reported by the agent (2), and example runs where the developer needs to see the behavior itself.
- **Decisions the plan didn't cover.**
- **Blast radius and revert:** what a failure would affect beyond the code it changed, and what a revert would not undo (4).
- **Tradeoffs:** where the agent weighed one goal against another.
- **New dependencies:** what they give and what they cost.
- **What was hard to change, and why.**

A checker adds to each section what the author missed (3).

## What a pipeline may be

Any way of building software that holds to this is one the manifesto allows. A choice it does not speak to is the pipeline's own; one it speaks to has to fit it.
