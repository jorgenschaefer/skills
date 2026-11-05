---
name: decide
description: Find the decisions in a change that would be hard to undo, put each to the developer, and record the settled ones in docs/adr/. Make every other decision without mentioning it. Use before building any change to an existing project, once what to build is clear; when such a decision comes up in the middle of a build; and on "what needs deciding here", "is this a big decision".
---

# Decide

The developer's attention is the scarce resource. Spend it only on decisions that would be hard to undo. Make every other decision yourself, and don't mention it.

## What is hard to undo

Reverting a commit removes the code. It does not take back what the software did while it ran. A decision is hard to undo when, after the software has been in use for a while, undoing it takes more than a revert. Ask what would be left behind:

- **Data that was stored**: where it lives and what shape it has. Once real data is there, changing either takes a migration that has to decide what the old data means, such as which user gets the web address that was stored on the company.
- **Things that were sent or published**: an API, a wire format, emails, webhooks, URLs people saved. Others now rely on them.
- **Information that leaked**: who can see or do what. Leaked information cannot be unleaked.
- **Trust that was lost**: the user relied on something, and it broke or changed under them.
- **Money or contracts**: a paid service, a licence, a vendor that is hard to leave.
- **Things much else is built on**: the tech stack, the deployment infrastructure, a pattern that gets copied across the code. Undoing one means changing everything built on it.

A choice of colour, wording, layout, internal names or code structure is not hard to undo, even if someone chose it carefully. Changing it later needs nobody's permission. A decision does not become important just because it was made.

**Changing something hard to undo that already exists is itself a decision that matters.** An existing schema or public API is a decision someone made, even with no ADR for it.

## Before you ask

1. **Read what was agreed**: the change file in `changes/`, if there is one, or else what the developer said.
2. **Read `docs/adr/`.** If the change would break a recorded decision, that is a decision that matters.
3. **Read the code the change touches**, to see what it already stores, sends and allows.
4. **List the decisions that matter.** For each, name what it would cost to undo. If you cannot name a cost, it is not on the list. Usually the list is short, and it is often empty.

If the list is empty, say so in one line and carry on.

## Telling and asking

The developer hears about every decision on the list. They are asked only where there is a real choice.

**Where there is a real choice, ask.** One decision at a time. For each:

- the decision, in one sentence;
- what it would cost to undo;
- the options, simplest first: three where there are three real ones;
- which you recommend, and why.

If the developer's answer settles another decision on the list too, don't ask about that one.

**Where there is only one sensible option, tell.** Before you build, list them, one line each, so the developer can object:

> Hard to undo, but only one sensible option:
> - `invoices.due_date`, a date column on the invoice

## Recording them

Write an ADR only for a decision the code does not show: a hosting provider, a vendor contract, a promise made to a partner, a rule such as "this email never goes to third parties". A schema, a public API or a dependency is in the code, and the code is its record.

Write each ADR as `docs/adr/NNNN-<slug>.md`, in the format of `ADR_FORMAT.md`. If it replaces a recorded decision, delete that file in the same change. If there is a change file, list the ADRs under its `## Decisions that matter`.

Don't commit them on their own. They are committed with the change they belong to.
