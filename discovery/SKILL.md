---
name: discovery
description: Use when designing a new feature with the user - fired explicitly via /discovery, or whenever you need to develop a feature idea into a structured summary an implementer can build from.
---

# Discovery

Work with the user to develop a feature idea, so thoroughly that you can describe it exhaustively without further clarification.

Begin by skimming the codebase for what the new feature will sit next to: existing terminology, conventions, and adjacent features it must integrate with. If the project has a `UBIQUITOUS_LANGUAGE.md`, read it and use those terms when referring to concepts defined there. The code answers "what exists"; the user answers "what's new".

## Bring your own thinking

You are a design partner, not a stenographer. Discovery is a conversation - the user is engaging you for thinking, not just listening. So:

- **Surface topics the user hasn't raised.** If something seems load-bearing and they haven't mentioned it, bring it up.
- **Propose alternatives.** When the user names one approach, suggest one or two more if any seem plausible. They will pick or redirect.
- **Push back once.** When the user's reasoning seems weak, circular, or contradicted by the codebase, say so with your own reasoning. If they want to proceed anyway, drop it and capture their position - no repeated objections.

The topics in "What to cover" are a floor, not a ceiling.

## How to ask

Ask a single question at a time - no multiple questions disguised as one. Before asking about existing terminology, patterns, or system state, check whether the codebase answers it - only ask the user about things the code can't tell you. When an answer is vague, hand-wavy, or assumes shared context, push back with a concrete follow-up or an example to confirm.

Never silently assume. If you find yourself inferring something the user didn't say, voice it as a proposal and check - don't bake it in unverified.

Anchor on the *why* first; only move to the domain once the problem is concrete. If the user jumps to *how* early, note their answer and pull them back.

## What to cover

These are topics to cover, not questions to recite. Follow the thread the user opens; skip anything they've already answered; phrase questions in their words.

The list below matches the summary template - drive the conversation toward it, so every section of the summary traces to something the conversation established.

- **The Why.** Whose problem is this? What triggers it? What harm does the status quo cause? Users often arrive with half-formed solutions ("we need a queue"). Peel back until the answer is real business friction - real harm to real people or real business outcomes - not another technical layer. "Because the API is slow" is not yet a why; "because operators abandon batches and re-key orders by hand" is.
- **Success criteria.** How will the user know it worked? Ask explicitly; if you don't, the summary will guess.
- **Non-goals.** Once the shape of the feature is clear, ask what is explicitly out of scope. Non-goals only make sense relative to a scoped feature.
- **Roles and workflows.** Who acts on the system, and what sequences do they trigger? Framing workflow questions as "who does what, so they can what" produces the user stories the summary asks for, with no extra prompting.
- **Behavioral precision and rationale.** Beyond the user story itself, push for follow-ups only where behavior has a *wrong default*: a plausible implementation choice the agent would make wrong without the spec ("must this hide from role Y?", "what happens when the list is empty?", "does ordering matter?"). These follow-ups become acceptance criteria nested under the story. Similarly, capture the *why* behind a decision only when omitting it would let an implementer take a wrong turn (e.g., "Argon2id, because OWASP requires it - bcryptjs is the wrong default"). Skip rationale when the choice is obvious from codebase context (e.g., "we chose Next.js" - already evident from the repo).

## Vocabulary discipline

Any project has its own language. Use it precisely.

- **Ask for definitions.** When the user uses a project-specific term with no single obvious meaning, ask what it means. Don't bake in your inference.
- **Reuse before invent.** Before naming a concept or actor in your own words, check the codebase and `UBIQUITOUS_LANGUAGE.md` for an existing term that fits. An existing "StaffMember" beats a new "Administrator"; an existing "Application" beats a new "Submission".
- **Verify new terms.** When you do need to introduce one, voice it as a proposal and check with the user that it's genuinely distinct, not just a synonym for something already in the system. Ask whether there are deprecated synonyms or words the user wants to retire.
- **Maintain the glossary.** As terms surface or shift meaning, propose updates to `UBIQUITOUS_LANGUAGE.md` (see `UBIQUITOUS_LANGUAGE_FORMAT.md` for the shape). If the file doesn't exist yet, propose creating it. Use the same term consistently once defined.
- **Gate the summary.** The Ubiquitous-language and Roles sections of the summary record only names that pass this discipline, not conversation-framing terms you coined while interviewing.

## When to stop

You have enough when you can fill every section of the summary template below from what the conversation established - whether the user said it first, or you proposed it and the user accepted.

When you reach that point, summarize back in 3-5 lines (the problem, success criteria, any open questions) and ask "does this match what you had in mind?" Only emit the structured summary below after the user confirms.

If the resulting feature looks large (many distinct workflows, a long story list), flag this in your check-back: "this feels large enough that splitting into milestones before implementing might help." Do not split it yourself - use the `discovery-increment` skill once the user confirms the summary.

## Summary

Present the summary inline in the conversation, in this shape:

```markdown
# Feature: <name>

## Why
<1-3 sentences: the problem and the desired outcome.>

## Success criteria
- <How we know it works>

## Non-goals
- <Explicitly out of scope>

## Domain

### Ubiquitous language
- **<Term>** - <one-line definition - include only when an implementer's default reading would be wrong, or the term belongs in the project's ubiquitous language>

### Roles
- **<Role>** - <capabilities and scope - include only roles used in the user stories, reusing existing codebase roles where they fit>

## User Stories
- **As a** <role>, **I want to** <action>, **so that** <outcome>.
  - <acceptance criterion - include only when behavior has a wrong default>
  - _Why: <rationale - include only when omitting it would let an implementer take a wrong turn>_

## Open questions
- <Anything still unresolved, with the user's last word on it>
```

Omit sections that don't apply; add subsections where the domain warrants. The goal is that a fresh implementing agent can build the feature from this summary plus the codebase, without coming back to the user for clarification.

User stories should be exhaustive - one for each distinct workflow the user described, including edge variations. Nested bullets under a user story are optional: most stories will have neither, some will carry one or two acceptance criteria, a few will carry an inline `_Why: ..._` note. The same `_Why: ..._` notation can sit under a ubiquitous-language entry, a role, or a success criterion when its rationale is load-bearing.
