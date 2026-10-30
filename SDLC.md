# Software Development Life Cycle

## Software Development

Software development is means to an end, not an end in itself.

The end is supporting a user in their work. The software is not the work. The software enables the work.

To achieve this, the software needs the *trust* of the user. Trust is the most important aspect. A slow, insecure software with bad interface that a user trusts is more valuable than a fast, secure, easy to use software that the user has lost trust in.

## Goals

Software development is the art of crafting software that the user trusts. Trust is built in four

### 1. Utility

The program does what the user wants - after being consulted adequately, not just what they first asked for.

This is the fundamental requirement for trust. If the program regularly does something else than what the user wants or needs, they lose trust in the program and solve their problems in other ways.

### 2. Security

Nobody can do or see more than they are supposed to.

Once a software was abused by an attacker, or information leaked in an unforeseen way, it is hard to regain trust.

### 3. Usability

The program is easy and intuitive to use.

If the user does not have to think about how to do things, and just enjoys the process, they are more likely to trust the program and come back to it voluntarily.

### 4. Maintainability

New features can be added quickly, and bugs can be fixed fast.

If a user reports a problem or a wishlist item and receives an update soon, they will trust the software more even if it breaks in the future

## SDLC User Journeys

### Add a feature

As a developer, I open claude code and tell it about an idea I have for the software.

It interviews me and helps me identify the actual problem I am trying to solve.

Once we have that identified, it works with me to come up with at least one user journey for this change.

It then walks the user journey and discusses with me how each step would look and feel like. It provides alternative options all the way until we agree on a finished design.

Once finalized, the agent creats two documents:

- A permanent `changes/journeys/slug.md` file describing each user journey for the future
- A temporary `changes/YYYY-MM-DD-slug/CHANGE.md` description of the design, interactions, screens etc. to be implemented

Based on these files, an agent implements the change.

An adversarial reviewer wih a new context then checks the code and software against the user journeys, changes, and the four goals above.

### Debug

As a developer, I can describe a bug in whatever way it came to me.

The agent searches for the bug, asking me questions to support it in finding the bug.

Once identified, it writes a test that reproduces the bug, and then implements a fix.

The test and fix are reviewed by an adversarial reviewer with a new context.

### Refactor

During any implementation run, agents note when they found a feature hard to implement.

During debugging, agents also note down what piece of code was brittle or what made it hard to find a bug.

In the refactor stage, those signals together with the git backlog - which files change often, which files change together, etc. - and possibly other signals are used together to come up with a refactoring plan that makes the code base more easy to change in the future.

The most important items are implemented and reviewed by an adversarial reviewer.

### Backlog

tbd

## Future Changes

- The ubiquitous language is a good idea, but has no place yet
- The domain model is a good idea, but has no place yet
- Stored data (database schemas) and wire formats are relevant but are not mentioned yet
