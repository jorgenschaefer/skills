---
name: decide
description: Design what in a change would be costly to change - how the user moves through the task, the design system, the data, the stack - and put each such decision to the developer before the build. Ask where there is a real choice, tell where there is only one, and write both down. Make every other decision without mentioning it. Use before building any change, once what to build is clear; when such a decision comes up in the middle of a build; and on "what needs deciding here", "is this a big decision".
---

# Decide

The developer's attention is the scarce resource. Spend it only on decisions that would be hard to undo. Make every other decision yourself, and don't mention it.

`/explore` found the problem and a general direction. It designed nothing. Decide designs whatever in the change is costly to change, whether interaction, look or data. The builder designs the rest.

## What is hard to undo

Reverting a commit removes the code. It does not take back what the software did while it ran. A decision is hard to undo when, after the software has been in use for a while, undoing it takes more than a revert. Ask what would be left behind:

- **Data that was stored**: where it lives and what shape it has. Once real data is there, changing either takes a migration that has to decide what the old data means, such as which user gets the web address that was stored on the company. Think through the life of the data too: how things are deleted, which fields change over time and what past records mean then, and how many users there will be.
- **Things that were sent or published**: an API, a wire format, emails, webhooks, URLs people saved. Others now rely on them.
- **Information that leaked**: who can see or do what, how access ends, and where data stays afterwards, such as on a phone. Leaked information cannot be unleaked.
- **Trust that was lost**: the user relied on something, and it broke or changed under them. Above all: what happens to what the user entered when saving fails.
- **Money or contracts**: a paid service, a licence, a vendor that is hard to leave.
- **Things much else is built on**: the tech stack and its versions, the deployment infrastructure, the design system, a pattern that gets copied across the code, such as every new record type touching nine places. Undoing one means changing everything built on it.
- **How the user moves through the task**: which steps, in which order, and what they enter when. The data and much of the code take their shape from it.

The colour of one button, wording and internal names are not hard to undo, even if someone chose them carefully. Nor is code structure, until it becomes a pattern that gets copied. Changing them later needs nobody's permission. A decision does not become important just because it was made.

**Changing something hard to undo that already exists is itself a decision that matters.** An existing schema or public API is a decision someone made, even with no ADR for it.

## Before you ask

1. **Read what was agreed**: the change file in `changes/`, if there is one, or else what the developer said.
2. **Read `docs/adr/`.** If the change would break a recorded decision, that is a decision that matters.
3. **Read the code the change touches**, to see what it already stores, sends and allows. In a new project there is no code; work from the change file, and the stack is one of your decisions.
4. **List the decisions that matter.** For each, name what it would cost to undo. If you cannot name a cost, it is not on the list. In a small change to an existing project the list is often empty. A new project always has a stack to decide, and a design system if it has screens.

If the list is empty, say so in one line and carry on.

## Telling and asking

The developer hears about every decision on the list before the build. They are asked only where there is a real choice.

**Where there is a real choice, ask.** One decision at a time. For each:

- the decision, in one sentence;
- what it would cost to undo;
- the options, simplest first: three where there are three real ones;
- which you recommend, and why.

Where the options look or behave differently, show them as clickable mock-ups, not ASCII. For a new project with screens, ask about the design system this way: components, type, colours, spacing.

If the developer's answer settles another decision on the list too, don't ask about that one.

**Where there is only one sensible option, tell.** List them, one line each, so the developer can object:

> Hard to undo, but only one sensible option:
> - `invoices.due_date`, a date column on the invoice

A completely new page in an existing app is told as a mock-up, shown before it is built, even when there is nothing to ask.

## Recording them

Save every mock-up in `changes/`, next to the change file and named after it: `changes/YYYY-MM-DD-<slug>-<what>.html`. Not in the chat or a scratch directory: the builder will not see those.

In the change file, add two sections after `## Approach`:

```markdown
## Design
<What is costly to change: how the user moves through the task, the design
system, the data. Links to the mock-ups.>

## Decisions that matter
- <the decision> - held by <the code | a test of what | docs/adr/NNNN-<slug>.md>
```

List every decision you told or asked, not only the ones you asked. Before there is code, the change file is their only record. If there is no change file, tell the developer what you would have written there.

The change file is deleted when the change is done, so each decision also needs something that holds it afterwards. The code holds what it shows, such as a `due_date` column. Write an ADR only for a decision the code does not show: a hosting provider, a vendor contract, a promise made to a partner, a rule such as "this email never goes to third parties".

Write each ADR as `docs/adr/NNNN-<slug>.md`, in the format of `ADR_FORMAT.md`. If it replaces a recorded decision, delete that file in the same change.

Commit the ADRs, your part of the change file and the mock-ups in one commit, before the build. A builder in a fresh context then finds them in the repository.
