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

1. The artifact is actually a Feature Brief (it should follow the structure from the `discovery` skill: Summary, Problem, Users, Why now, Goals, Non-goals, Constraints, Success criteria, Open questions, Out of scope for this brief).
2. You're in a clean context — you did not participate in creating this artifact. If you're unsure, treat your judgment as potentially contaminated: note it in "What was NOT checked" and flag any area where prior context might be biasing you.
3. You can read the Feature Brief in full. If it references other docs (existing system documentation, prior briefs, regulatory requirements), be aware they exist but don't pretend to have read them unless you actually did.

## What to check

Walk through these questions. Each one corresponds to a common failure mode at this phase. For each, either confirm the brief handles it well, or write a finding.

### Problem framing

- **Is the problem stated, or is a solution stated as if it were a problem?** "We need a queue" describes a solution. The problem might be "requests are timing out." Look for solution language disguised as problem language.
- **Is the problem one problem or several?** Briefs that try to solve multiple problems at once usually solve none of them well. If the brief addresses several distinct issues, suggest splitting.
- **Are symptoms confused with causes?** The brief may name a visible symptom (e.g., "support tickets are up") that is downstream of a deeper cause. The deeper cause is what the design should target.
- **Is the problem actually a problem?** Sometimes briefs propose solutions to non-issues — work that no stakeholder would notice if it shipped: no user experience change, no operational improvement, no risk reduction. If no one would notice, the brief hasn't established that it's a problem.

### Users and stakeholders

- **Are the affected users named specifically?** "Users want X" is too vague. Which users? Internal staff, customers, customers of customers, operators?
- **Is the scale of impact quantified?** "Many users" hides a lot. Five users? Five million? How often does each one hit this?
- **Are workarounds described?** What do affected users do today? Their current workarounds reveal both the urgency and the shape of an acceptable solution.
- **Are stakeholders other than end users acknowledged?** Engineering, support, security, compliance, sales — features often have non-user stakeholders whose needs shape the design.

### Why now

- **Is the trigger explicit?** A brief without "why now" leaves priorities unclear and reveals little about constraints.
- **Is the urgency of the trigger proportionate to the breadth of the proposed change?** A narrow compliance deadline doesn't justify redesigning the whole auth system; a long-simmering UX complaint rarely justifies a full rewrite. Mismatch is a finding.

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
- **Does each question have a resolution path?** An open question should specify how it will be resolved (e.g., "design phase will research X", "user to decide Y before design begins", "spike needed to validate Z"). Questions with no resolution path tend to stay open forever.

### Out of scope

- **Is the boundary defended?** Things explicitly out of scope make later phases stay focused. If a brief lists no out-of-scope items, the author probably hasn't thought about boundaries enough.

### Cross-cutting smell tests

Read [ubiquitous-language-update.md](ubiquitous-language-update.md) for the glossary maintenance standard. The primary check is that this brief uses existing glossary terms consistently — synonyms and paraphrases for existing concepts are a should-fix. Only expect a new glossary entry when a genuinely new concept has been introduced.

- **Skim test.** Can someone read the Summary alone and understand what's being proposed? If not, the Summary is doing too little work.
- **The "future engineer" test.** If a new engineer joins the team in six months and reads only this brief, will they understand why this work was done? If they'd be confused, the brief lacks context.
- **The ubiquitous language check.** Does the brief use terminology consistently with `UBIQUITOUS_LANGUAGE.md`? A brief that uses different words for the same concept as the rest of the project will cause drift in every downstream artifact. Terms that already have glossary entries: using synonyms or paraphrases is a **should-fix**. New terms the brief introduces that aren't in the glossary: also a **should-fix** — the discovery skill was responsible for adding them.
- **The contradiction check.** Do any two sections contradict each other? Goals vs. constraints, problem vs. success criteria, scope vs. non-goals. Contradictions are common in early drafts.
- **The implicit-design check.** Has the brief crept into design territory? Architecture decisions, tech choices, UI layouts, ticket-level work. If yes, they should move to the design phase or be deleted.

## Common findings

Easy-to-miss issues not named explicitly in the checks above:

- Cross-cutting concerns (security, compliance, accessibility, observability needs) absent entirely
- "Why now" left unstated
- Non-user stakeholders forgotten

## Verdict guidance for this phase

- **Block** if: the problem isn't a clear problem, the success criteria don't measure the problem, or the brief is mostly disguised design.
- **Request changes** if: goals are untestable, non-goals are missing, constraints are vague, or there are multiple should-fix items.
- **Approve with comments** if: the brief is solid, with only nit-level issues remaining.
- **Approve** if: rare. Hold a high bar.

## Output

Save the review at `docs/features/<slug>/discovery-review-<NN>.md` using the format defined in [review-base.md](review-base.md). Reference specific sections of the brief. Suggest the author address findings before re-reviewing. If the verdict is Approve or Approve with comments, suggest the next step is the design skill.
