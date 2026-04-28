---
name: review-feature-brief
description: Use this skill to review a Feature Brief produced by the Discovery phase before it advances to Design. Trigger this whenever the user says things like "review this Feature Brief", "critique this brief", "is this brief ready for design", or hands you a file from docs/discovery/ and asks for feedback. The output is a structured review file with findings categorized by severity. Always use a clean context for this review — do not chain it after the discussion that produced the brief, since the value of the review depends on fresh eyes.
---

# Feature Brief Review

This skill reviews a **Feature Brief** — the artifact produced by the Discovery phase. It builds on the shared review base; read `../SKILL.md` first for the reviewer stance, output format, and severity definitions.

The unique job of this review is to catch the failure modes specific to early-stage problem framing — things that, if not caught now, will quietly distort the design and implementation that follow.

## Setup

Before reviewing, confirm:

1. The artifact is actually a Feature Brief (it should follow the structure from the `discovery` skill: Summary, Problem, Users, Why now, Goals, Non-goals, Constraints, Success criteria, Open questions, Out of scope).
2. You're in a clean context — not a continuation of the discovery conversation.
3. You can read the brief in full. If it references other docs (existing system documentation, prior briefs, regulatory requirements), be aware they exist but don't pretend to have read them unless you actually did.

## What to check

Walk through these questions. Each one corresponds to a common failure mode at this phase. For each, either confirm the brief handles it well, or write a finding.

### Problem framing

- **Is the problem stated, or is a solution stated as if it were a problem?** "We need a queue" describes a solution. The problem might be "requests are timing out." Look for solution language disguised as problem language.
- **Is the problem one problem or several?** Briefs that try to solve multiple problems at once usually solve none of them well. If the brief addresses several distinct issues, suggest splitting.
- **Are symptoms confused with causes?** The brief may name a visible symptom (e.g., "support tickets are up") that is downstream of a deeper cause. The deeper cause is what the design should target.
- **Is the problem actually a problem?** Sometimes briefs propose solutions to non-issues — work that wouldn't change anything users observe. Ask: if this shipped and nothing else changed, would anyone notice?

### Users and stakeholders

- **Are the affected users named specifically?** "Users want X" is too vague. Which users? Internal staff, customers, customers of customers, operators?
- **Is the scale of impact quantified?** "Many users" hides a lot. Five users? Five million? How often does each one hit this?
- **Are workarounds described?** What do affected users do today? Their current workarounds reveal both the urgency and the shape of an acceptable solution.
- **Are stakeholders other than end users acknowledged?** Engineering, support, security, compliance, sales — features often have non-user stakeholders whose needs shape the design.

### Why now

- **Is the trigger explicit?** A brief without "why now" leaves priorities unclear and reveals little about constraints.
- **Does the trigger justify the scope?** A small, recent regulatory deadline implies a different design space than a long-simmering UX complaint. Make sure the brief's scope matches what the trigger justifies.

### Goals and non-goals

- **Are goals testable?** "Improve user experience" is not testable. "Reduce time-to-first-result on the search page from 4 seconds to under 1 second" is.
- **Do goals match the problem?** A common drift: the problem is X, but the goals quietly slide to solving Y. Cross-check each goal against the stated problem.
- **Are non-goals listed?** A brief without explicit non-goals leaves the door open to unbounded scope creep in design. Push for them.
- **Are the non-goals actually non-goals, or are they hidden requirements?** Sometimes things listed as non-goals are quietly assumed to work — flag those for explicit discussion.

### Constraints

- **Are constraints concrete?** "Must be performant" is vague. "Must respond in under 200ms p99 under 1000 RPS" is concrete.
- **Are constraints justified?** A constraint without reasoning ("must use Postgres") is a red flag — either it's a real constraint with a real reason that should be stated, or it's a premature design decision sneaking into the brief.
- **Are missing constraints likely to surface later?** Compliance, accessibility, internationalization, data residency, audit logging, multi-tenancy. Briefs that don't mention these may have forgotten them; flag for explicit consideration.

### Success criteria

- **Can success be observed?** Vague success criteria become design failures. Push for measurable, observable criteria.
- **Do success criteria connect to the problem?** A brief whose success criteria measure something other than what the problem describes is solving the wrong thing. This is one of the most common and most damaging failure modes.
- **Are baselines mentioned?** "Reduce X by 50%" requires knowing the current value of X. If the baseline isn't established, the brief is open-ended.

### Open questions

- **Are the right questions surfaced?** Briefs that pretend everything is known are usually wrong. Look for areas the brief glosses over — those probably contain unsurfaced open questions.
- **Are owners assigned?** Open questions without owners tend to stay open forever.

### Out of scope

- **Is the boundary defended?** Things explicitly out of scope make later phases stay focused. If a brief lists no out-of-scope items, the author probably hasn't thought about boundaries enough.

### Cross-cutting smell tests

- **Skim test.** Can someone read the Summary alone and understand what's being proposed? If not, the Summary is doing too little work.
- **The "future engineer" test.** If a new engineer joins the team in six months and reads only this brief, will they understand why this work was done? If they'd be confused, the brief lacks context.
- **The ubiquitous language check.** Does the brief use terminology consistently with `UBIQUITOUS_LANGUAGE.md`? A brief that uses different words for the same concept as the rest of the project will cause drift in every downstream artifact.
- **The contradiction check.** Do any two sections contradict each other? Goals vs. constraints, problem vs. success criteria, scope vs. non-goals. Contradictions are common in early drafts.
- **The implicit-design check.** Has the brief crept into design territory? Architecture decisions, tech choices, UI layouts, ticket-level work. If yes, they should move to the design phase or be deleted.

## Common findings

To calibrate, here are the failure modes most often surfaced at this phase:

- Solution language disguised as problem language
- Vague success criteria that can't be tested
- Missing non-goals → invites scope creep in design
- Multiple problems bundled into one brief
- "Why now" left unstated → priorities unclear
- Affected users named only generically ("users")
- Non-user stakeholders forgotten
- Constraints stated without justification, hiding premature design choices
- Cross-cutting concerns (security, compliance, accessibility, observability needs) not mentioned at all
- Architecture / tech choices smuggled into the brief

## Verdict guidance for this phase

- **Block** if: the problem isn't a clear problem, the success criteria don't measure the problem, or the brief is mostly disguised design.
- **Request changes** if: goals are untestable, non-goals are missing, constraints are vague, or there are multiple should-fix items.
- **Approve with comments** if: the brief is solid, with only nit-level issues remaining.
- **Approve** if: rare. Hold a high bar.

## Output

Save the review at `docs/reviews/feature-brief-<feature-slug>-<YYYY-MM-DD>.md` using the format defined in the shared review base. Reference specific sections of the brief. Suggest the author address findings, then re-review or proceed to design depending on the verdict.
