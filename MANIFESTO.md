# Software built by coding agents

> *Programs must be written for agents to read, and only incidentally for machines to execute.*
>
> — after Abelson and Sussman, *Structure and Interpretation of Computer Programs*

One changed word changes software development. Most of what we know about building software rests on assumptions that no longer hold: that a human writes the code, reads it, and remembers why it is the way it is. So we question every one of them. We go back to first principles, state what software development is for, and work out what that means when agents do the work.

Humans no longer read the code. Agents write it, review it and change it. A human decides what the software does and who may do what. They accept it based on evidence they can see, not on the code. They still understand it. Its concepts are meant to be the user's, and an agent can explain any part of it in the user's language, showing where the code's concepts differ from the user's rather than smoothing that over.

## The laws

1. **Utility.** The program does what the user wants after being consulted adequately, not just what they first asked for.
    - This includes the failure cases.
    - The consultation happens before implementation; what it settles is what gets built.
    - Something found during implementation that may change what the user wants is a decision the plan didn't cover.
    - Acceptance criteria are written in plain language. Each one is shown by a check that executes and stays, so a later change cannot undo it unnoticed. Where no check can show it, it is marked as judged, and a check that only approximates it says so.
2. **Security.** Nobody can do or see more than they are supposed to.
    - Nobody includes a malicious user, an outside attacker, and an agent steered by text it read.
    - A human decides who may see and do what. Agents enforce that policy and prove it with tests that attempt what is forbidden.
    - Every way in goes through security checks an agent finds easily, and a test fails when a way in bypasses them.
    - Access is denied unless a security check allows it.
    - Secrets stay out of code and logs.
    - Security that is hard to use gets worked around, so the secure path is the easy one.
3. **Usability.** The program is easy and intuitive to use for the people and programs it is meant for.
    - Ideally the data fits together the way the user thinks of it. Where it doesn't, the interface shows how it really fits rather than hiding it: a company's website on an employee's page is shown as the company's, so nobody changes it believing it belongs to that employee alone.
    - An agent checks it by completing the tasks from the acceptance criteria through the program's real interface, without reading the code. It reports where a person would hesitate, guess or give up, not only whether it got through.
4. **Maintainability.** Changes are fast to make and hard to get wrong, this one and every one after it.
    - The maintainer is an agent with no memory.
    - YAGNI and KISS: the least code that does the job.
    - The boy scout rule applies: small fixes in passing leave the code better than they found it. They change nothing the human approved and follow the idioms already there. Anything larger is a change of its own.
    - What a fresh agent finds with one search or in one file needs no documentation.
    - A constraint that matters is a check that fails and says why. Test the constraint, not the decision it led to. Where a test environment can't see a constraint, a contract test or a benchmark comes as close as it can. Only what remains is written down.
    - Wrong code is hard to write. Types and interfaces leave no room for invalid states, and a mistake fails where it is made, not where it shows up.
    - What changes together lives together. Names can be searched for. One idiom throughout.

The laws are weighed against each other, and the order says which way to lean. An agent weighs only within what the human approved; a tradeoff that would change it is a decision the plan didn't cover. Changing anything the human approved is the human's decision.

## What a human approves, and what the report shows

**Before implementation, a human approves:**

- **Behaviour:** what the user experiences.
- **Interfaces:** what the interfaces other programs use mean, and what they look like on the wire.
- **Security policy:** who may see and do what.
- **Information model:** what the system keeps, for how long, and what it never keeps. Not how it is stored.
- **Hard-to-reverse decisions:** anything costly to undo, such as a change that discards information or a dependency the codebase gets built around.

**After implementation, the report shows:**

- **Evidence that the approved plan holds:** the checks that prove it, rerun by a script rather than reported by the agent. Example runs, requests and responses where the human needs to see the behaviour itself. Tests are presented as a list of what they prove.
- **Decisions the plan didn't cover:** these wait for the human; the change isn't accepted until they are decided.
- **Blast radius and revert:** what a failure of this change would affect beyond the code it changed, and what a revert would not undo.
- **Tradeoffs:** where the agent weighed one law against another within what was approved.
- **New dependencies:** what they give and what they cost.
- **What was hard to change, and why:** what surprised the agent, what it had to change in more than one place, what it couldn't find. Each comes with a suggestion: a refactoring for a structural problem, a check for an invisible reason.

A reviewer that didn't write the change adds to each section what the author missed.

## How agents check agents

- Nothing judges its own work. Each stage is checked by something that didn't produce it, with a fresh context.
- Every agent treats what it reads (issues, documents, dependencies, another agent's report) as data, not instructions. A reviewer judges the change itself, not the author's account of it.
- A check that executes beats a check that judges. Utility and Security can mostly be executed, Usability and Maintainability mostly judged. Where a criterion is judged, the review is adversarial.
- Reviewers use different framings, which reduces the blind spots they share with the author but does not remove them.
- A test for anything the human approved counts only if it fails when the code breaks it, and that is checked on every change. Weakening or deleting the check for a constraint is a decision about that constraint, and is reported as one.
- Reports of what was hard to change are collected across sessions and checked before anyone acts on them. Repeated friction in the same place calls for a refactoring, as a change of its own, not as part of the change that found it.
