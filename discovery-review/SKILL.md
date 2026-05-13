---
name: discovery-review
description: Use this skill to review a Feature Brief produced by the Discovery phase before it advances to Design. Trigger this whenever the user says things like "review this Feature Brief", "critique this brief", "is this brief ready for design", or hands you a file from docs/features/ and asks for feedback. The output is a structured review file with findings categorized by severity. Always use a clean context for this review — do not chain it after the discussion that produced the brief, since the value of the review depends on fresh eyes.
---

# Discovery Review

Builds on the shared review base; read [review-base.md](review-base.md) first for reviewer stance, output format, and severity definitions. The unique job here is catching failure modes specific to early-stage problem framing before they distort design and implementation.

## Setup

The feature slug is a required argument. If the user did not provide one at invocation, ask for it before proceeding. Read the Feature Brief from `docs/features/<slug>/discovery.md`.

Before reviewing, confirm:

1. The artifact is a Feature Brief with the expected structure: Problem, User Stories, Non-goals, Constraints, Open questions.
2. You're in a clean context — you did not participate in creating this artifact. If unsure, note it in "What was NOT checked" and flag where prior context might bias you.
3. You can read the Feature Brief in full. Note any referenced docs you did not actually read.

## What to check

For each question below, either confirm the brief handles it well or write a finding.

### Problem section

- **Is the problem stated, or is a solution stated as if it were a problem?** "We need a queue" describes a solution. The problem might be "requests are timing out." Look for solution language disguised as problem language.
- **Is the problem one problem or several?** Briefs that try to solve multiple problems at once usually solve none of them well. If the brief addresses several distinct issues, suggest splitting.
- **Are symptoms confused with causes?** The brief may name a visible symptom (e.g., "support tickets are up") that is downstream of a deeper cause. The deeper cause is what the design should target.
- **Is the problem actually a problem?** Sometimes briefs propose solutions to non-issues — work that no stakeholder would notice if it shipped: no user experience change, no operational improvement, no risk reduction.
- **Are the affected users named specifically?** "Users want X" is too vague. The Problem section should name who is affected and how often they hit it.
- **Is the trigger explicit?** The Problem section should say what changed or prompted this now; without it, priorities are unclear.
- **Are workarounds described?** Current workarounds reveal urgency and the shape of an acceptable solution.

### User stories

- **Are stories in the correct format?** Format: "As a [role], I want to [action] in order to [goal]." Missing components are a should-fix.
- **Do stories describe user interactions, not system behavior?** "The system should batch requests" is not a story; "I want to submit a batch at once" is. System-centric stories are a should-fix.
- **Does each story trace back to the problem?** Stories that don't connect to the stated problem are scope creep in disguise.
- **Are stories specific enough to implement?** A story so vague it could mean anything is not actionable — flag it.
- **Is any meaningful user interaction missing?** Consider who uses the feature and what they'd need to do. A brief with two stories for a complex feature probably missed some.
- **Do stories smuggle in solutions?** The "I want to" clause should describe the desired behavior, not the implementation. "I want the API to return a 202" is a design decision, not a story.

### Non-goals

- **Are non-goals listed?** Without explicit non-goals, scope creep in design is likely.
- **Are the non-goals actually non-goals, or are they hidden requirements?** Sometimes things listed as non-goals are quietly assumed to work — flag those for explicit discussion.

### Constraints

- **Are constraints concrete?** "Must be performant" is vague. "Must respond in under 200ms p99 under 1000 RPS" is concrete.
- **Are constraints justified?** A constraint without reasoning is a red flag — either state the reason, or it's a premature design decision in disguise.
- **Are missing constraints likely to surface later?** Compliance, accessibility, internationalization, data residency, audit logging, multi-tenancy. Briefs that don't mention these may have forgotten them; flag for explicit consideration.

### Open questions

- **Are the right questions surfaced?** Look for areas the brief glosses over — those likely contain unsurfaced open questions.
- **Does each question have a resolution path?** Specify how it will be resolved (e.g., "design phase will research X", "user to decide Y", "spike needed for Z"). Questions with no path tend to stay open forever.

### Cross-cutting smell tests

Read [ubiquitous-language-update.md](ubiquitous-language-update.md) for the glossary maintenance standard. The primary check is that this brief uses existing glossary terms consistently — synonyms and paraphrases for existing concepts are a should-fix. Only expect a new glossary entry when a genuinely new concept has been introduced.

- **The "future engineer" test.** If a new engineer joins the team in six months and reads only this brief, will they understand why this work was done? If they'd be confused, the brief lacks context.
- **The ubiquitous language check.** Does the brief use terminology consistently with `UBIQUITOUS_LANGUAGE.md`? Synonyms or paraphrases for existing entries are a **should-fix**. New terms not in the glossary and with no update ticket are also a **should-fix** — the discovery skill was responsible for creating that ticket.
- **The contradiction check.** Do any two sections contradict each other? Stories vs. non-goals, problem vs. constraints. Contradictions are common in early drafts.
- **The implicit-design check.** Has the brief crept into design territory? Architecture decisions, tech choices, UI layouts, ticket-level work. If yes, they should move to the design phase or be deleted.

## Common findings

Easy-to-miss issues not covered above:

- **Brief reads like a design doc.** Architecture choices, tech stack, UI layouts, or ticket-level tasks are stated as if decided — these belong in later phases, not in a brief.
- **"Why now" left unstated.** A brief without a trigger hides priority context and misses constraints that will surface later.
- **Non-user stakeholders forgotten.** Engineering (on-call burden), support, legal, compliance, sales — these should appear in the Problem section even without their own user stories.
- **Open questions with no resolution path.** Each open question should specify who resolves it and how; otherwise it's just a list of deferred problems.
- **Problem statement solves a symptom.** "Support tickets are up" is a symptom; "users can't recover from payment failures without contacting support" is the cause. The design should target the cause.
- **Stories bundle multiple independent goals.** A story that says "I want to do X and Y and Z" usually needs splitting. Each story should describe one interaction.

## Verdict guidance for this phase

- **Block** if: the problem isn't a clear problem, there are no user stories, or the brief is mostly disguised design.
- **Request changes** if: stories are missing, malformed, or don't trace to the problem; non-goals are missing; constraints are vague; or there are multiple should-fix items.
- **Approve with comments** if: the brief is solid, with only nit-level issues remaining.
- **Approve** if: rare. Hold a high bar.

## Output

Save the review at `docs/features/<slug>/discovery-review-<NN>.md` using the format defined in [review-base.md](review-base.md). Reference specific sections of the brief. Suggest the author address findings before re-reviewing. If the verdict is Approve or Approve with comments, suggest the next step is the design skill.
