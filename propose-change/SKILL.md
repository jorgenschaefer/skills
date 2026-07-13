---
name: propose-change
description: Use when the user proposes a small change or bugfix to existing behavior and it needs evaluating and turning into a plan an implementer can follow. Fired explicitly via /propose-change. For a new capability, use /discovery instead.
disable-model-invocation: true
---

# Propose Change

The user has proposed a change or reported a bug. Your job is to turn it into a plan `/implement` can follow - guarding against bad ideas while letting good ones through. The goal is a change that addresses the real need while keeping the project usable and its code clean, not a rubber stamp.

Unlike `/discovery`, the change is already stated. The uncertainty is not "what does the user want" but "where does this thread through the code" and "is it worth doing, and done this way". So the weight is on investigation and judgment, not on interviewing. Keep the ceremony light - a small change should not feel like a feature.

## Scope: this skill vs `/discovery`

This skill is for **modifying or fixing behavior that already exists** - a tweak, an adjustment, a bugfix. If the request adds a **new user-facing capability or journey**, it's a feature: stop and point the user to `/discovery`, which is built to develop it.

The boundary is easy to miss because a request can arrive dressed as a small change and unfold into a feature once you investigate. When that happens - the change needs its own domain modeling, spawns several user stories, or opens a workflow the app doesn't have yet - say so and hand off. Redirecting is a good outcome, not a failure.

## Process

Scale it to the change. A one-line fix may need one investigative pass and three sentences of plan; a cross-cutting tweak, more. Run the steps in order, but let a trivial change collapse the small ones.

**End your turn at the first question mark.** When a turn reaches a question that seeks new information, send it - a second question waits for the next turn, so the user never has to untangle which reply answers which question. Confirming assumptions for veto ("I'm assuming X unless you say otherwise") gets its own turn, never mixed with a question. This holds across every step below, not just the last.

### 1. Understand the real problem

Reflect the request back and find the problem beneath it. Users often arrive with a solution already chosen; the stated change may not be the best way to get what they actually need (the XY problem - they ask for X because they think it solves Y; address Y). Investigate first (step 2 often answers the question); ask only what the codebase can't answer and a wrong guess would get wrong - the motivation, the expected behavior where it's genuinely ambiguous. For an obvious change with an obvious motive, don't manufacture questions.

For a **bug**, the "why" is usually settled - a bug is self-justifying. Spend the effort on the "what" instead: pin down the actual vs. expected behavior and a concrete case that reproduces it.

### 2. Investigate the codebase

This is the center of the skill. Before evaluating or planning, find how the change actually lands in the code:

- **Locate the code** the change touches - the real functions, modules, and data it modifies or extends.
- **Trace the blast radius** - what else calls this, depends on this, or shares the behavior. A change that looks local often isn't; the callers and the shared state are where a "small" change grows teeth.
- **Find the existing mechanism.** Prefer extending a pattern already in the codebase over introducing a new one. Often the cleanest change is the one that reuses what's there, and finding it changes the plan.

If `UBIQUITOUS_LANGUAGE.md` exists at the repo root, read it and reuse its terms for anything you name in the plan, so it matches the vocabulary `/implement` traces against.

For a **bug**, this step is a diagnosis: trace to the root cause, not the symptom. A fix at the symptom (clamping a bad value, swallowing an error) leaves the real defect live; name the root cause and fix there unless there's a stated reason not to. If the root cause doesn't yield to inspection, use `/debug` to find it before planning the fix.

Delegate breadth here when it helps - a search agent can map callers and usages faster than reading serially - but you own the conclusion.

### 3. Evaluate cost and benefit

Now judge whether the change is worth doing, and worth doing this way. Weigh:

- **Benefit** - how real and how common is the problem it solves? A genuine friction many users hit is worth more than a one-off preference. A bugfix's benefit is usually clear; a change's often needs pressing on.
- **Implementation cost** - what step 2 revealed: the size of the change, the blast radius, new dependencies, data migration, risk to existing behavior.
- **Ongoing cost** - the maintenance and conceptual surface it adds. A change that adds a special case, a new option, or a new concept the user must learn costs forever, not just once.
- **KISS and usability** - does it add complexity the benefit doesn't warrant? Watch the common-vs-edge tradeoff especially: a change that eases a rare edge case by complicating the common path needs real justification, because everyone pays for the few. A change that erodes the app's conceptual integrity or makes it harder to reason about is expensive even when it's easy to code.

The honest verdicts are: worth it as proposed; worth it done differently (a cheaper or cleaner alternative); worth it but it's actually a feature (hand to `/discovery`); or not worth it. "Not worth it" is a legitimate ending - a plan you talk the user out of is a good result.

### 4. Discuss and decide

Push back where you have reason to. When the change is weak, the cost outsized, or a better path exists, say so with your reasoning and propose the alternative - the user picks or redirects. When you're choosing an implementation approach a wrong default would get wrong, state the decision and your recommendation and let the user veto; don't make them originate it. Scope and the go/no-go stay the user's call, not a default you back into.

## Output

When the change is agreed and worth doing, write the plan to a short markdown file in the repo - propose a path and confirm it. Before presenting, unless the change is genuinely small (a one-liner, a single acceptance criterion), dispatch a fresh `general-purpose` subagent to read the written plan cold and report where it fights itself - an acceptance criterion the approach can't satisfy, two criteria that can't both hold, a verdict the approach contradicts, or a requirement a reader could take two ways; a fresh reader catches these because your own context can't forget the intent that silently reconciles them. Resolve what it finds and pin the reading you mean, then present the same content inline so the user can react. Run it once on the settled plan; targeted revisions from later feedback you can recheck yourself. Revise from feedback until they're satisfied; the file is what `/implement` builds and traces against, so it must match what you agreed and leave nothing for the implementer to guess. Resolve every open question before writing it - the plan carries no open-questions section.

Keep it to the shape below; drop any section a given change doesn't need.

```markdown
# Change: <title>

## What & why
<The change, and the real problem beneath it. One to three sentences.>

## Verdict
<Worth doing, and why - the cost/benefit call. Note the alternatives you weighed and why this one won, when that reasoning is load-bearing.>

## Approach
<Where in the code the change lands and what it reuses or extends, named as durable structure - "extend the existing `RateLimiter`, following the retry helper's backoff" - not a `file:line` that drift invalidates. For a bug, the root cause and where the fix goes.>

## Done when
- <given/when/then acceptance criterion for each behavior a wrong default could hurt - each becomes a test `/implement` writes RED first>
- <for a bug: the reproduction case, phrased so it becomes the failing test that pins the fix>
```

If, having investigated, the change is one the user should not make, don't write a plan - give them the reasoning and the alternative instead.
