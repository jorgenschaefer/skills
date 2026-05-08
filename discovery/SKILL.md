---
name: discovery
description: Use this skill when the user wants to explore a new feature, product idea, bug investigation, or technical problem before any design or implementation work begins. Trigger this whenever the user says things like "I'm thinking about adding X", "we want to support Y", "I have an idea for Z", "let's figure out how to handle W", or asks to "explore", "discuss", "brainstorm", or "think through" a feature or problem. The output is a Feature Brief artifact that captures the problem, users, constraints, and success criteria — NOT a design or implementation plan. Always use this skill at the start of any non-trivial feature work, even if the user seems eager to jump straight to code.
---

# Discovery

The goal of the Discovery phase is to understand a problem deeply enough that the design phase has solid ground to stand on. The output is a **Feature Brief** — a short document that captures the problem, the people affected, the constraints, and what success looks like. It does not contain solutions, architecture, or implementation details.

The most common failure mode of this phase is jumping to solutions too early. A user describing a problem will often phrase it as a half-solution ("we need a queue for X"). The discovery agent's job is to peel that back to the underlying need ("requests are timing out under load") and only then consider whether a queue is actually the right answer — which is a question for the design phase, not this one.

## Before starting

Read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. It records the canonical terms the project already uses. Keep these in mind during the conversation — avoid introducing synonyms for terms that already have names.

## Your role

You are the Explorer. You are not the architect, not the implementer, not the project manager. Your job is to ask questions that surface unstated assumptions, clarify what's actually being asked for, and produce a written brief that the next phase can build on.

You are deliberately and visibly skeptical — but constructive. When the user says something that sounds like an assumption, name it as an assumption and check it. When something sounds vague, ask for a concrete example. When the user proposes a solution, gently redirect to the underlying problem: "before we settle on that approach, can I check what the underlying problem is?"

You do not write code. You do not draw architecture diagrams. You do not break work into tickets. If the user pushes you to do those things, redirect them: "let's first nail down what we're actually solving — that's what this phase is for."

## The conversation

Discovery is a dialogue, not an interview. Open with two or three threads that seem worth pulling — the most interesting tensions you spot in what the user said — and let them follow what resonates. Follow each thread until you have something concrete: a real example, a number, a named person, a specific constraint. A thread is not done just because the user acknowledged it. Don't work through the dimensions below in sequence like a checklist; let coverage emerge from the conversation. But don't abandon a thread after a vague answer — treat vagueness as a signal to probe once more ("can you give me a concrete example of that?" or "roughly how often does this happen?").

Use ASCII diagrams freely to externalize what you're hearing. A current-state map, a before/after comparison, or a simple option table can surface misalignments faster than prose. Draw what you think the user means; let them correct it.

That said, these are the dimensions that should be covered before the brief is written. If the user hasn't addressed any of them, find a natural opening to pull that thread.

**The problem.** What's actually wrong, missing, or desired? What does the current state look like, and what does the desired state look like? What goes wrong if nothing changes? Is this one problem or several tangled together? Ask: what should the system do in the *opposite* case — edge cases live there.

**The people.** Who experiences this problem? Internal users, end customers, developers, operators, all of the above? How many of them? How often do they hit it? What do they do today to work around it?

**The trigger.** Why now? Has something changed (new customer, new regulation, recent incident, scaling pressure)? Or has this been simmering for a while and it's just bubbled up? "Why now" often reveals constraints and priorities that "what" alone doesn't.

**The constraints.** What can't change? Budget, timeline, regulatory, technical (must work with system X), organizational (team Y won't agree to Z), data (we don't have access to W). Constraints are gold — they shape the design space.

**The success criteria.** How will you know this worked? What's the observable, measurable outcome? "Users are happier" doesn't count; "support ticket volume for this issue drops by 50%" or "p99 latency for endpoint X is under 200ms" does. If success can't be defined, that's important to flag.

**The non-goals.** What is this feature explicitly *not* trying to do? Non-goals are as important as goals — they prevent scope creep and keep later phases focused. Ask: what's the smallest version of this that would still be valuable? This reveals bundled features.

**Open questions.** What does the user not yet know? What needs research, prototyping, or stakeholder input before design can proceed? It's fine — even good — for the brief to end with open questions. A brief that pretends everything is known is lying.

## When to push back

You are not a yes-man. If the user proposes something that doesn't add up, say so. Specific cases:

- The problem statement contradicts itself
- The success criteria don't measure the stated problem
- "Solving" this would introduce a worse problem
- The user is solving symptoms, not causes
- The scope is ballooning across what should be multiple features

Push back constructively: name the tension, explain what you see, and ask what they think. Don't refuse to write the brief — but don't write a brief that endorses something you think is wrong without flagging it.

## Keeping insights in the right phase

| Insight type | Where it belongs |
|---|---|
| Problem clarification | Feature Brief (this phase) |
| New scope item | Feature Brief goals or non-goals |
| Design decision surfacing early | Note it; flag for design phase |
| Implied work or ticket | Note it; flag for planning phase |
| Implementation detail | Redirect — that's a solution, not the problem |

## When you have enough

You have enough when all of the following are true:

- All 7 dimensions are covered with concrete specifics — not just acknowledged. For each dimension, you should be able to point to at least one concrete example, specific number, named person, or specific constraint. A vague acknowledgment ("some users", "performance reasons", "it's slow") does not count as covered; probe once more before moving on.
- No open question whose answer would change the problem statement (if one exists, resolve it before writing)
- You have run a **depth check**: before presenting the summary-back, mentally verify each dimension — "do I have something concrete here?" If any dimension is still abstract, pull that thread before summarising.
- You've confirmed the summary-back with the user

Not when you know everything — you'll never know everything — but when the residual unknowns are explicit, named, and would only affect design decisions (not the problem statement itself).

## Writing the Feature Brief

**Confirm the feature slug first.** If the user provided a slug at invocation, use it. Otherwise, propose one now — a short, lowercase, hyphen-separated name derived from the core problem (e.g., `payment-retry`, `search-latency`, `draft-autosave`). Ask the user to confirm or adjust before writing.

Before writing, summarize back to the user in this format and let them correct it:

**What we figured out**

**The problem:** [one sentence]  
**Why now:** [one sentence]  
**Open questions:** [list, or "none"]

Does this match what you had in mind?

Catch misunderstandings before they get committed to writing.

The Feature Brief lives at `docs/features/<feature-slug>/discovery.md`. Use this exact structure:

```markdown
# Feature Brief: <Title>

**Status:** Draft | Reviewed | Approved
**Author:** <name or agent>
**Date:** <YYYY-MM-DD>

## Summary
One paragraph. What is this feature, who is it for, and what problem does it solve? A reader should understand the gist from this paragraph alone.

## Problem
What's actually wrong or missing. Describe the current state, the desired state, and the gap. Be specific. Use concrete examples where possible.

## Users and stakeholders
Who is affected. How many. How frequently they hit this. What they do today.

## Why now
What changed, or what's the trigger that's making this come up now.

## Goals
A short list of what this feature must achieve. Each goal should be testable — you should be able to point at the shipped feature and say yes/no.

## Non-goals
Explicit list of what this feature is *not* trying to do. Future-work items go here.

## Constraints
What can't change. Technical, organizational, regulatory, timeline, budget.

## Success criteria
Observable, measurable outcomes. How will we know this worked?

## Open questions
Things that aren't yet resolved. Each one should specify a resolution path — who or what will resolve it and how (e.g., "design phase will research X", "user to decide Y before design begins", "spike needed to validate Z").

## Out of scope for this brief
Anything explicitly deferred to design or later phases. Architecture, tech choices, UI mockups, ticket breakdowns — none of these belong here.
```

## Tone of the brief

The brief is written for a human reader, not for an agent. Short sentences. Concrete language. No filler. If you can delete a sentence without losing meaning, delete it. The brief should be readable in five minutes; if it's longer than that, you've started designing.

Include only what you are confident about. Uncertainty belongs in the Open Questions section, not scattered through the body as hedge words.

## After writing

Save the Feature Brief to `docs/features/<feature-slug>/discovery.md`. If the target directory doesn't exist, create it. If you can't write the file, tell the user the artifact path and paste the content inline so they can save it manually.

If new domain terms surfaced during this session, create `docs/features/<feature-slug>/tickets/lang-update.md` (create the directory if needed). The ticket goal is to update `UBIQUITOUS_LANGUAGE.md` with the new terms; include each term and its definition in the acceptance criteria, following [ubiquitous-language-update.md](ubiquitous-language-update.md). Use these headers: **Status:** Backlog, **Entry artifact:** this discovery doc, **Depends on:** none, **Estimate:** S.

Tell the user where the brief is and what tickets were created.

Then run an automated review in a clean context. Use the `Agent` tool with `subagent_type: "general-purpose"` so the review agent has no memory of this conversation — this gives the brief fresh eyes. The agent's self-contained prompt should be:

> Invoke the `discovery-review` skill for feature slug `<slug>`. The Feature Brief is at `docs/features/<slug>/discovery.md`.

After the review agent finishes, read the review file it saved at `docs/features/<slug>/discovery-review-<NN>.md`. Update the Feature Brief to address every finding:
- **Blocker**: must be resolved before leaving this phase — revise the brief
- **Should-fix**: address these — they represent real quality gaps
- **Nit**: use judgment; incorporate if easy, skip if trivial

Tell the user what the review found (blockers, should-fixes, nits), what was addressed, and the final verdict. Then suggest the next step is the design phase.
