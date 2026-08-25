---
name: improve-skill
description: Improve one existing agent skill - sharper, leaner, clearer - without changing what it does.
disable-model-invocation: true
---

# Improve Skill

A skill is a prompt an agent executes. Your job is to make one work better – sharper at its task, leaner on tokens, clearer to follow – while preserving what it does.

**The cardinal rule: improve how the skill works, never silently change what it does.** Reword, cut, and restructure freely. But the moment an edit would change the skill's behavior, scope, judgment calls, output, or when it fires, it stops being a wording fix and becomes a decision for the author. Keeping those two kinds of edit apart is the one thing that makes this skill safe – a subtle behavior change smuggled in as "cleanup" is the failure to avoid.

## Scope

Operate on the one skill the user names (or the current skill directory). Read all of it first – `SKILL.md` and every reference file it points to – and understand its purpose before touching a word: the outcome it exists to produce, the judgment it encodes, and where it sits among sibling skills. Improving a skill you have only half-read is how you damage it.

## Read the runs

If `loop.sh` runs the skill you are improving, every run it made left its transcripts under `${XDG_STATE_HOME:-~/.local/state}/loop`, one directory per run and accumulating. They are the only evidence of how the skill behaved rather than how it reads, so let them set the agenda: an instruction stepped around, a halt reason that recurs, a finding filed run after run, a section no run ever reached. A run that went right is grounds for *removing* a line – the one thing reading the prose can never establish. Where no run exercised the skill, say so and work from the text.

## Evaluate against these lenses

Apply everything you know about good prompts; these sharpen focus on what is easy to miss.

- **Effectiveness.** Is it written at the right altitude? Durable principles and judgment where the situation varies, concrete steps only where a wrong default does real harm. Flag brittle over-specification – hardcoded paths, line numbers, exact counts – that drifts or fails to generalize. The skill should encode *how to decide*, not just what to type. Check that it handles failure, says when to stop, hands off to the right sibling skill when the task isn't its own, and specifies its output when something downstream consumes it.
- **Triggering.** The `description` is the highest-leverage line in the file – it is always in context and decides whether the skill fires at the right time. It should be precise, phrased the way a user actually asks, and disambiguated from sibling skills so they don't compete. Keep it to *when to use* – triggers, symptoms, the shape of the request – not a summary of the skill's process or output: a description that recaps the workflow becomes a shortcut the agent follows in place of the body, doing fewer steps than the skill specifies. Confirm `disable-model-invocation` and the name match the skill's intent and the repo's conventions.
- **LLM clarity.** Remove instructions that contradict each other or pull in opposite directions. Prefer positive imperative framing; when the skill must forbid something, say what to do instead. Fix ambiguous referents (an "it" with no clear antecedent) and terms used loosely – define a term once and use it consistently.
- **Concision.** Cut motherhood statements a competent agent already does, plus padding, hedging, and repetition. Every sentence must change behavior or go. Use progressive disclosure: keep `SKILL.md` lean and move long templates, examples, or reference material into separate files the agent loads only when it needs them.
- **Single source of truth.** A rule stated in three places drifts into three versions. State each rule once, in the place it belongs, and reference it rather than restating it.

## Match the form to the failure

When you change guidance to fix an effectiveness problem, first name the failure it's meant to fix, then pick the form that fits it – the form that bulletproofs one failure backfires on another:

- **Violates a known rule under pressure** (knows better, does it anyway) → a firm prohibition with the rationalizations named and countered.
- **Produces wrong-shaped output** (bloated, buried, restates the input) → a positive recipe stating what the output *is*, and in what order. A prohibition ("don't restate") backfires here: under a competing pull the agent negotiates with "don't", and testing shows the prohibition arm produces *more* of the unwanted content than a recipe – often more than no guidance at all.
- **Omits a required element it otherwise produces** → a structural slot: a REQUIRED field in the template it fills, not a prose reminder.
- **Should behave differently by condition** → a conditional keyed to something observable ("if a brief exists, reference it"), not an unconditional rule plus exemptions.

Avoid nuance and exemption clauses whichever form you pick: "don't X unless it matters" reopens the negotiation, and "this doesn't apply to code blocks" still suppresses code blocks. Express a real exception as its own conditional.

## Separate safe edits from behavior-changing ones

Sort every proposed edit into one of two buckets and treat them differently:

- **Safe** – same behavior, better wording: tightening prose, cutting redundancy, fixing an ambiguous referent, reordering for readability. Apply these directly.
- **Behavior-changing** – alters what the skill does, its scope, a judgment call, its output format, or its triggering. Do not apply these. Surface each as a decision, with the reasoning and your recommendation, and let the author choose. When you are unsure which bucket an edit falls in, treat it as behavior-changing – the cost of a wrong guess is asymmetric.

## Verify behavior-affecting edits

A wording change meant to change how the agent behaves – to make it comply with a rule, or to reshape its output – is a hypothesis, not a fact; a rewrite that reads better can bind behavior worse. Before you trust one, micro-test it. (Purely cosmetic edits – a typo, a redundant sentence, a reorder that can't change meaning – need no test.)

- **Sample fresh contexts.** Run the edit as it will actually live – the whole skill or the relevant section as context, and a task that tempts the failure – across several fresh subagent samples (5+; single samples lie).
- **Always include a no-guidance control.** Run the same task with the guidance removed. If the control doesn't exhibit the failure, there's nothing to fix – drop the edit rather than add words for a problem that isn't there.
- **Read every flagged sample by hand.** Template echoes and quoted counter-examples masquerade as hits; a raw count mis-states both failure and success.
- **Treat variance as the signal.** When the wording binds, samples converge on one shape. Five different readings across five samples means it isn't binding – tighten the form before adding words.

Keep the guidance only if the tested version beats the control. An edit that doesn't move behavior against the baseline is words for their own sake – cut it.

## Process and output

Apply the safe edits – any meant to change behavior only after they beat the baseline (see Verify behavior-affecting edits) – then report both buckets together so the author sees the full picture:

- **Applied** – the safe edits you made, grouped so they're easy to scan, not a line-by-line diff dump.
- **Needs your call** – each behavior-changing edit as: what it changes, why it would help, and your recommendation. The author approves, adjusts, or rejects; apply the approved ones.

If the skill is already in good shape, say so plainly rather than inventing edits to justify the invocation. A short "applied three tightenings, nothing behavioral to decide" is a fine result.
