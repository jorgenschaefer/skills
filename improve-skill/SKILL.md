---
name: improve-skill
description: Use to improve an existing agent skill – make it more effective at its job, more concise without losing effectiveness, and clearer for an LLM to follow – while preserving what it does. Fired explicitly via /improve-skill. Operates on one skill at a time.
disable-model-invocation: true
---

# Improve Skill

A skill is a prompt an agent executes. Your job is to make one work better – sharper at its task, leaner on tokens, clearer to follow – while preserving what it does.

**The cardinal rule: improve how the skill works, never silently change what it does.** Reword, cut, and restructure freely. But the moment an edit would change the skill's behavior, scope, judgment calls, output, or when it fires, it stops being a wording fix and becomes a decision for the author. Keeping those two kinds of edit apart is the one thing that makes this skill safe – a subtle behavior change smuggled in as "cleanup" is the failure to avoid.

## Scope

Operate on the one skill the user names (or the current skill directory). Read all of it first – `SKILL.md` and every reference file it points to – and understand its purpose before touching a word: the outcome it exists to produce, the judgment it encodes, and where it sits among sibling skills. Improving a skill you have only half-read is how you damage it.

## Evaluate against these lenses

Apply everything you know about good prompts; these sharpen focus on what is easy to miss.

- **Effectiveness.** Is it written at the right altitude? Durable principles and judgment where the situation varies, concrete steps only where a wrong default does real harm. Flag brittle over-specification – hardcoded paths, line numbers, exact counts – that drifts or fails to generalize. The skill should encode *how to decide*, not just what to type. Check that it handles failure, says when to stop, hands off to the right sibling skill when the task isn't its own, and specifies its output when something downstream consumes it.
- **Triggering.** The `description` is the highest-leverage line in the file – it is always in context and decides whether the skill fires at the right time. It should be precise, phrased the way a user actually asks, and disambiguated from sibling skills so they don't compete. Confirm `disable-model-invocation` and the name match the skill's intent and the repo's conventions.
- **LLM clarity.** Remove instructions that contradict each other or pull in opposite directions. Prefer positive imperative framing; when the skill must forbid something, say what to do instead. Fix ambiguous referents (an "it" with no clear antecedent) and terms used loosely – define a term once and use it consistently.
- **Concision.** Cut motherhood statements a competent agent already does, plus padding, hedging, and repetition. Every sentence must change behavior or go. Use progressive disclosure: keep `SKILL.md` lean and move long templates, examples, or reference material into separate files the agent loads only when it needs them.
- **Single source of truth.** A rule stated in three places drifts into three versions. State each rule once, in the place it belongs, and reference it rather than restating it.

## Separate safe edits from behavior-changing ones

Sort every proposed edit into one of two buckets and treat them differently:

- **Safe** – same behavior, better wording: tightening prose, cutting redundancy, fixing an ambiguous referent, reordering for readability. Apply these directly.
- **Behavior-changing** – alters what the skill does, its scope, a judgment call, its output format, or its triggering. Do not apply these. Surface each as a decision, with the reasoning and your recommendation, and let the author choose. When you are unsure which bucket an edit falls in, treat it as behavior-changing – the cost of a wrong guess is asymmetric.

## Process and output

Apply the safe edits, then report both buckets together so the author sees the full picture:

- **Applied** – the safe edits you made, grouped so they're easy to scan, not a line-by-line diff dump.
- **Needs your call** – each behavior-changing edit as: what it changes, why it would help, and your recommendation. The author approves, adjusts, or rejects; apply the approved ones.

If the skill is already in good shape, say so plainly rather than inventing edits to justify the invocation. A short "applied three tightenings, nothing behavioral to decide" is a fine result.
