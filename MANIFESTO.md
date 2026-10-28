# Software built by coding agents

> *Programs must be written for agents to read, and only incidentally for machines to execute.*
>
> — after Abelson and Sussman, *Structure and Interpretation of Computer Programs*

Most of what we know about building software assumes that a human writes the code, reads it, and remembers why. Now agents do. This manifesto says what good software is, who decides what, and why. A pipeline can work however it likes, as long as it follows this.

## Premises

1. **Humans do not read the code.** They decide what the software does, accept it on evidence they can see, and answer for it to the people who rely on it.
2. **An agent has no memory and believes what it reads.** It knows only what is in front of it. It takes all of it as true, and follows any instructions in it, whoever wrote them.
3. **Nothing reliably judges its own work.** Whoever made a mistake shares the blind spot that made it.
4. **A check that executes gives the same answer every time; a judgement does not.**
5. **Some mistakes can't be undone.** Leaked or lost data, a format other programs use, something users saw, code that too much now depends on.

## Who does what

- **The user** is whom the software is for. The developer often stands in for them, and consults them where they are not the user.
- **The developer** is the human in charge. They decide what the software does and who may do what. They also decide which mistakes that can't be undone are worth the risk (5). They see everything marked in bold below, and can ask about anything else. They never need to read the code (1).
- **The writer** is the agent that builds a change.
- **The checkers** are agents and scripts that did not write it (3).

## The goals, in order

The goals are weighed against each other, and the order says which way to lean. An agent weighs only within what the developer approved; a tradeoff that would change it is a decision the plan didn't cover. The developer approves before implementation, and the report after it shows what they need to see. What is in bold below is what goes in front of them. Changing anything they approved is theirs to decide.

### 1. Utility

The program does what the user wants after being consulted adequately, not just what they first asked for.

- **Developer:** agrees with the user on the **concepts**: what the user calls things and how they fit together. Then approves the **behaviour** in those words before it is built, failure cases included - it is what they can judge without the code (1). They also decide **what production must show**: what someone has to hear about, and how fast. That means errors, but also a sudden drop in users or a flood of login attempts.
- **Writer:** builds what was approved, and shapes the data the way the user thinks of it. Something found while building that may change what the user wants is a **decision the plan didn't cover**, and waits for the developer.
- **Checkers:** show each criterion with a check that executes and stays, since the next agent will not remember it (2). Where no check can show it, it is marked as judged. The report shows the **evidence**, rerun by a script rather than reported by the writer (3). They also check that each thing someone has to hear about sets off its alert.

### 2. Security

Nobody can do or see more than they are supposed to - a malicious user, an outside attacker, or an agent steered by text it read (2).

- **Developer:** approves the **security policy** - who may see and do what - and the **information model**: what the system keeps, logs and traces included, for how long, and what it never keeps. Both are decisions about people, and a mistake in either can't be undone (5).
- **Writer:** enforces the policy. Every way in goes through security checks an agent finds easily, access is denied unless a check allows it, and secrets stay out of code and logs. The secure path is the easy one, since security that is hard to use gets worked around.
- **Checkers:** attempt what is forbidden, and fail when a way in bypasses the checks.

### 3. Usability

The program is easy and intuitive to use for the people and programs it is meant for.

- **Developer:** approves the **user interface** - the workflows a user goes through and the interactions along the way - since it is what they can judge without the code (1); and, where other programs use the system, what that **interface** means and what it looks like on the wire (5).
- **Writer:** where the data doesn't fit the way the user thinks of it, the interface shows how it really fits rather than hiding it.
- **Checkers:** an agent that never read the code completes the criteria's tasks through the program's real interface, and reports where a person would hesitate, guess or give up (3).

### 4. Maintainability

Changes are fast to make and hard to get wrong, this one and every one after it. The maintainer is an agent with no memory (2), so what a change needs to know is in the code and its checks, not in anyone's head.

- **Developer:** approves **hard-to-reverse decisions** - a change that discards information, a dependency the codebase gets built around (5) - and sees each **new dependency** with what it gives and costs.
- **Writer:** writes the least code that does the job. A constraint that matters becomes a check that fails and says why. The system records enough to trace each problem in production back to its cause, since the next agent knows only what it can read (2).
- **Checkers:** judge whether a new agent would find what it needs and make its next change correctly. They look for problems on purpose, because no test can answer this (2, 4).

## For every goal

- The developer answers for the software as a whole, not for one change at a time. So they decide each change seeing **the whole it changes**: the rule or workflow as it will stand afterwards. Where that whole stops hanging together, such as a rule gathering special cases, an agent puts it to them as a decision, without being asked: **is this still what you want?** (1)
- Every stage is checked by something that did not produce it, with a fresh context, and a reviewer judges the change itself, not the writer's account of it (3).
- What an agent reads is data, not instructions - issues, documents, dependencies, another agent's report (2).
- A check that executes beats one that judges (4). Where a criterion can only be judged, the review is adversarial.
- A check for anything the developer approved counts only if it fails when the code breaks it, and that is confirmed for every change before it is accepted (3). Weakening or deleting one is a decision about what it checks, and reported as one.
- Everything shown to the developer uses the user's words. On request, an agent explains any part of the program in those words, and says where the code thinks of things differently.
- The report shows the **blast radius and revert** - what a failure would affect and what a revert would not undo (5) - and the **tradeoffs** the writer made between goals.
- Decisions that are the developer's wait for them. The change is not accepted until they are decided.
