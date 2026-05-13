---
name: discovery-review
description: Use this skill to review a Feature Brief produced by the Discovery phase before it advances to Design. Trigger this whenever the user says things like "review this Feature Brief", "critique this brief", "is this brief ready for design", or hands you a file from docs/features/ and asks for feedback. The output is a structured review file with findings categorized by severity. Always use a clean context for this review — do not chain it after the discussion that produced the brief, since the value of the review depends on fresh eyes.
---

# Discovery Review

This skill reviews a **Feature Brief** — the artifact produced by the Discovery phase. It builds on the shared review base; read [review-base.md](review-base.md) first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to catch the failure modes specific to early-stage problem framing — things that, if not caught now, will quietly distort the design and implementation that follow.

## Setup

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding. Read the Feature Brief from `docs/features/<slug>/discovery.md`.

Before reviewing, confirm:

1. The artifact is actually a Feature Brief (it should follow the structure from the `discovery` skill: Problem, User Stories, Non-goals, Constraints, Open questions).
2. You're in a clean context — you did not participate in creating this artifact. If you're unsure, treat your judgment as potentially contaminated: note it in "What was NOT checked" and flag any area where prior context might be biasing you.
3. You can read the Feature Brief in full. If it references other docs (existing system documentation, prior briefs, regulatory requirements), be aware they exist but don't pretend to have read them unless you actually did.

## What to check

Walk through these questions. Each one corresponds to a common failure mode at this phase. For each, either confirm the brief handles it well, or write a finding.

### Problem section

- **Is the problem stated, or is a solution stated as if it were a problem?** "We need a queue" describes a solution. The problem might be "requests are timing out." Look for solution language disguised as problem language.
- **Is the problem one problem or several?** Briefs that try to solve multiple problems at once usually solve none of them well. If the brief addresses several distinct issues, suggest splitting.
- **Are symptoms confused with causes?** The brief may name a visible symptom (e.g., "support tickets are up") that is downstream of a deeper cause. The deeper cause is what the design should target.
- **Is the problem actually a problem?** Sometimes briefs propose solutions to non-issues — work that no stakeholder would notice if it shipped: no user experience change, no operational improvement, no risk reduction.
- **Are the affected users named specifically?** "Users want X" is too vague. The Problem section should name who is affected and how often they hit it.
- **Is the trigger explicit?** A brief without "why now" leaves priorities unclear. The Problem section should say what changed or what prompted this now.
- **Are workarounds described?** What do affected users do today? Their current workarounds reveal both the urgency and the shape of an acceptable solution.

### User stories

- **Are stories in the correct format?** Each story should be: "As a [role], I want to [action] in order to [goal]." Missing components are a should-fix.
- **Do stories describe user interactions, not system behavior?** "The system should batch requests" is not a user story. "I want to submit a batch of items at once" is. System-centric stories are a should-fix.
- **Does each story trace back to the problem?** Stories that don't connect to the stated problem are scope creep in disguise.
- **Are stories specific enough to implement?** A story so vague it could mean anything ("I want a better experience") is not actionable. Flag it.
- **Is any meaningful user interaction missing?** Consider who uses the feature and what they'd need to do. A brief with two stories for a complex feature probably missed some.
- **Do stories smuggle in solutions?** The "I want to" clause should describe the desired behavior, not the implementation. "I want the API to return a 202" is a design decision, not a story.

### Non-goals

- **Are non-goals listed?** A brief without explicit non-goals leaves the door open to scope creep in design.
- **Are the non-goals actually non-goals, or are they hidden requirements?** Sometimes things listed as non-goals are quietly assumed to work — flag those for explicit discussion.

### Constraints

- **Are constraints concrete?** "Must be performant" is vague. "Must respond in under 200ms p99 under 1000 RPS" is concrete.
- **Are constraints justified?** A constraint without reasoning ("must use Postgres") is a red flag — either it's a real constraint with a real reason that should be stated, or it's a premature design decision sneaking into the brief.
- **Are missing constraints likely to surface later?** Compliance, accessibility, internationalization, data residency, audit logging, multi-tenancy. Briefs that don't mention these may have forgotten them; flag for explicit consideration.

### Open questions

- **Are the right questions surfaced?** Briefs that pretend everything is known are usually wrong. Look for areas the brief glosses over — those probably contain unsurfaced open questions.
- **Does each question have a resolution path?** An open question should specify how it will be resolved (e.g., "design phase will research X", "user to decide Y before design begins", "spike needed to validate Z"). Questions with no resolution path tend to stay open forever.

### Cross-cutting smell tests

Read [ubiquitous-language-update.md](ubiquitous-language-update.md) for the glossary maintenance standard. The primary check is that this brief uses existing glossary terms consistently — synonyms and paraphrases for existing concepts are a should-fix. Only expect a new glossary entry when a genuinely new concept has been introduced.

- **The "future engineer" test.** If a new engineer joins the team in six months and reads only this brief, will they understand why this work was done? If they'd be confused, the brief lacks context.
- **The ubiquitous language check.** Does the brief use terminology consistently with `UBIQUITOUS_LANGUAGE.md`? Terms that already have glossary entries: using synonyms or paraphrases is a **should-fix**. New terms the brief introduces that aren't in the glossary and have no update ticket: also a **should-fix** — the discovery skill was responsible for creating a ticket to add them.
- **The contradiction check.** Do any two sections contradict each other? Stories vs. non-goals, problem vs. constraints. Contradictions are common in early drafts.
- **The implicit-design check.** Has the brief crept into design territory? Architecture decisions, tech choices, UI layouts, ticket-level work. If yes, they should move to the design phase or be deleted.

## Common findings

Easy-to-miss issues not named explicitly in the checks above:

- **Brief reads like a design doc.** Architecture choices, tech stack, UI layouts, or ticket-level tasks are stated as if decided — these belong in later phases, not in a brief.
- **"Why now" left unstated.** A brief without a trigger hides priority context and misses constraints that will surface later.
- **Non-user stakeholders forgotten.** Engineering (on-call burden), support (new ticket types), legal, compliance, sales — features often have non-user stakeholders whose needs silently constrain the design. These should appear somewhere in the Problem section even if they don't generate user stories of their own.
- **Open questions with no resolution path.** A list of open questions is good; a list where none of them specifies who resolves it, how, or by when is just a list of things the author is hoping will sort themselves out.
- **Problem statement solves a symptom.** "Support tickets are up" is a symptom; "users can't recover from payment failures without contacting support" is the cause. The design should target the cause.
- **Stories bundle multiple independent goals.** A story that says "I want to do X and Y and Z" usually needs splitting. Each story should describe one interaction.

## Verdict guidance for this phase

- **Block** if: the problem isn't a clear problem, there are no user stories, or the brief is mostly disguised design.
- **Request changes** if: stories are missing, malformed, or don't trace to the problem; non-goals are missing; constraints are vague; or there are multiple should-fix items.
- **Approve with comments** if: the brief is solid, with only nit-level issues remaining.
- **Approve** if: rare. Hold a high bar.

## Output

Save the review at `docs/features/<slug>/discovery-review-<NN>.md` using the format defined in [review-base.md](review-base.md). Reference specific sections of the brief. Suggest the author address findings before re-reviewing. If the verdict is Approve or Approve with comments, suggest the next step is the design skill.
