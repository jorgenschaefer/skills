# Software Development Life Cycle

## Software Development

Software development is a means to an end, not an end in itself.

The end is supporting a user in their work. The software is not the work. The software enables the work.

To achieve this, the user has to trust the software. Trust is the most important aspect. Software the user has stopped trusting is worthless, however fast, secure or easy to use it is: they work around it. But the trust has to be earned. Software that is trusted without deserving it lets the user down the moment it breaks, and then it loses more trust than it ever had.

## Goals

Software development is the art of crafting software that deserves the user's trust. It earns that trust in four ways, in this order:

### 1. Utility

The program does what the user wants - after being consulted adequately, not just what they first asked for.

This is the fundamental requirement for trust. If the program regularly does something else than what the user wants or needs, they lose trust in the program and solve their problems in other ways.

The user journeys are written in the user's words. The code uses the same words for the same things.

### 2. Security

Nobody can do or see more than they are supposed to.

What someone is supposed to do and see is what the user journeys give them. Everything else is denied by default: every way into the software denies access unless a rule allows it.

Once software has been abused by an attacker, or information leaked in an unforeseen way, it is hard to regain trust.

### 3. Usability

The program is easy and intuitive to use.

If the user does not have to think about how to do things, and just enjoys the process, they are more likely to trust the program and come back to it voluntarily.

### 4. Maintainability

New features can be added quickly, and bugs can be fixed fast.

The next change is made by an agent that remembers nothing of this one. So whatever it needs to know is in the repository: in the journeys, the tests and the code.

If a user reports a problem or a wishlist item and receives an update soon, they will trust the software more even if it breaks in the future.

## SDLC User Journeys

### Add a feature

As a developer, I open claude code and tell it about an idea I have for the software.

It interviews me and helps me identify the actual problem I am trying to solve.

Once we have that identified, it finds the user journeys this change affects, and works with me to change them or add new ones. Where the software already does something that no journey describes yet, it first writes that journey from what the software does today, and I confirm it.

It then walks the user journey and discusses with me how each step would look and feel. Where seeing a step says more than describing it, it builds a rough prototype I can click through, and we walk that. It provides alternative options all the way until we agree on a finished design. The builder builds to the prototype, and the prototype is thrown away when the change is accepted.

Once finalized, the agent creates two documents:

- A permanent `journeys/slug.md` file for each user journey, named after what the user does, such as `journeys/pay-an-invoice.md`. A change edits the journeys it affects, so each file always describes the software as it is.
- A temporary `changes/YYYY-MM-DD-slug/CHANGE.md` description of the design, interactions, screens etc. to be implemented

Based on these files, agents implement the change, with nobody watching. First the work is split into chunks, each small enough for one agent to build within one context. Then a fresh agent builds each chunk. For each user journey, it writes a test that walks the journey the way a user would: it clicks, types or calls the API, and never calls the code's internals. The test stays. When it fails, it names the step that broke. A step that no test can show, such as "it feels quick", is marked as judged. A journey that no test walks drifts away from the software, and the next agent believes it anyway.

An adversarial reviewer with a new context then checks the code and software against the user journeys, changes, and the four goals above. An agent that has not read the code walks each user journey on the running software, and reports where a person would hesitate, guess or give up.

Then I walk the user journey myself, on the running software. For each step, the agent shows me what checks it and what the check found. If the software does what we designed but does not solve my problem, we go back to the interview. The change is done when I accept it.

### Debug

As a developer, I can describe a bug in whatever way it came to me.

The agent searches for the bug, asking me questions to support it in finding the bug.

Once identified, it ends in one of three ways:

1. The software works as intended, and the intention is right. Nothing changes, and the agent explains to me why it works this way.
2. The software works as intended, but this shows the intention is wrong. This is a feature request, and goes into the backlog.
3. The software does not work as intended. The agent writes a test that reproduces the bug, and then implements a fix.

The test and fix are reviewed by an adversarial reviewer with a new context.

### Refactor

During any implementation run, agents note when they found a feature hard to implement.

During debugging, agents also note down what piece of code was brittle or what made it hard to find a bug.

At acceptance, the review findings about the code that nobody fixed are noted down too.

Each note is one file, `changes/friction/YYYY-MM-DD-slug.md`, so runs on different branches never write to the same file. A refactor deletes the notes it has dealt with.

In the refactor stage, those signals together with the git history - which files change often, which files change together, etc. - and possibly other signals are used together to come up with a refactoring plan that makes the code base more easy to change in the future.

The most important items are implemented and reviewed by an adversarial reviewer. The tests for the user journeys pass without being changed. A refactor that needs to change one changes what the software does, and goes through "Add a feature" instead.

### Backlog

As a developer, I can add an idea to the backlog whenever it comes up, and pick the next thing to work on from it.

Each item is one file, `changes/backlog/slug.md`. It holds what I had in mind, as far as I got, and the evidence from the code: where the problem showed up. It does not add a solution I did not have. The agent proposes two sizes, effort and utility, each from XS to XL, and I confirm or correct them. If the idea overlaps an existing item, the agent adds it to that item instead of writing a new one.

Items also come from the other journeys: a debug run that shows the intention is wrong, and anything an agent finds during a change that does not belong to it.

When I ask what to do next, the agent ranks the items by utility against effort. It checks the top ones against the current code, and proposes deleting an item whose problem no longer shows. It recommends one item and a runner-up, and says why.

An item is a note, not a plan. The item I pick starts "Add a feature" at the interview, however settled it reads. Once the change is accepted, the item is deleted.

## Future Changes

- The ubiquitous language is a good idea, but has no place yet
- The domain model is a good idea, but has no place yet
- Stored data (database schemas) and wire formats are relevant but are not mentioned yet
- How production problems are noticed before a user reports them (errors, alerts, logs) is not mentioned yet
