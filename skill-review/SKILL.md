---
name: skill-review
description: Review one existing agent skill and report what would make it work better. Reports only; changes nothing.
disable-model-invocation: true
---

# Skill Review

A skill is a prompt an agent executes, and it exists to wrangle determinism out of a stochastic system. **Predictability** - the agent taking the same process every run, not producing the same output - is the root virtue, and every lens below is a lever on it.

You review one skill against those lenses and report. **You change nothing** - not the skill, not the files it points at, not the repository around it. The author reads the findings and decides which to apply. A review that edits on its way through has taken the author's decision for them, and taken it without the evidence the next section asks for.

## Scope

The skill the user names, or the skill directory you were started in. Read all of it first - SKILL.md and every file it points at - before judging a word: the outcome it exists to produce, the judgment it encodes, and the moment it is supposed to fire. Reviewing a skill you have half-read is how a lens gets applied to something that was never the skill's job.

Then read the descriptions of the skills it sits beside. A description is only as good as its separation from the ones competing with it, and that competition is invisible from inside one file.

## Read the runs

How a skill behaved beats how it reads, and it is the only evidence that can tell you a line is not carrying anything. Find what its runs left behind: transcripts where the harness keeps them, the artifacts it was supposed to produce, the record of what it did, the complaint that brought you here. A failure someone can name outranks every lens below.

Say which you had. Where nothing survives a run of this skill, say that too, and work from the text - and be slower to call a line unnecessary, because nothing in front of you can establish that a run went right without it.

## The lenses

Apply everything you know about writing for a model; these sharpen focus on what is easy to miss.

**Triggering.** The `description` is the highest-leverage line in the file: on a model-invoked skill it sits in the context window every turn and decides whether the skill fires at the right moment. It should be phrased the way a user actually asks, name one trigger per distinct way the skill is used, and be separable from its neighbours' descriptions. Keep it to *when to use*, not a summary of the process: a description that recaps the workflow becomes a shortcut the agent follows in place of the body, doing fewer steps than the skill specifies.

Check the invocation itself, not just the wording. A skill only ever invoked by hand, and reached by no other skill, pays for its description every turn and buys nothing; `disable-model-invocation: true` makes it free, and its description becomes a one-line summary for a human. A skill another skill must reach has to be model-invoked whatever the author intended.

**Altitude.** Durable principles and judgment where the situation varies; concrete steps only where a wrong default does real harm. Hardcoded paths, line numbers and exact counts are brittle over-specification - they drift out of date, or they generalize to the next case wrongly. The skill should encode *how to decide*, not only what to type. Check the edges too: what it does when something is missing, when it stops, when it hands off to a sibling skill because the task is not its own, and - where something downstream consumes what it produces - what shape that output has.

**The information hierarchy.** Material sits on a ladder, ranked by how immediately the agent needs it: an ordered step in SKILL.md; a definition or rule in SKILL.md, consulted on demand; and reference pushed out into a separate file reached by a pointer, loaded only when the pointer fires. Push too little down and the top bloats; push too much and the agent never sees what it needed. The cleanest test is the different ways the skill gets used: inline what every one of them needs, push behind a pointer what only some reach. A pointer's *wording*, not its target, decides whether the agent goes and reads it. And once material is down there, keep a concept's definition, rules and caveats under one heading rather than scattered.

**Completion criteria.** Each step ends on a condition that tells the agent the work is done. Ask of every one: can the agent tell done from not-done, and where it matters, does the criterion demand everything rather than something - "every modified caller accounted for" rather than "produce a list". A vague criterion invites **premature completion**: the agent ends a step while attention slips to being finished. Sharpen the criterion first; only where it is irreducibly fuzzy *and* you have seen the rush is splitting the later steps out of view worth its cost.

**Leading words.** A leading word is a compact concept already in the model's pretraining that the agent thinks with while running the skill - *lesson*, *fog of war*, *tracer bullets*, *red*. It anchors a whole region of behaviour in a few tokens by recruiting priors the model already holds, and it anchors invocation too when the same word lives in the user's own prompts and docs. Hunt for passages begging to collapse into one: a triad spelled out at three sites, a sentence of description gesturing at a single idea. "Fast, deterministic, low-overhead" is a *tight* loop. Assume the skill is carrying restatements a leading word retires.

**Pruning.** Cut everything that does not change what the agent does.

- **Do not re-state what the model would do on its own.** A line the agent already obeys by default costs tokens to say nothing, and it dilutes the lines that do bind. The test is one sentence at a time, in isolation: would the agent behave differently without it? Run it on encouragement ("be thorough", "think carefully", "use good judgment"), on descriptions of the model's own tools, and on any principle a competent agent brings with it. When a sentence fails, the finding is to delete the whole sentence, not to tighten its words. Be aggressive here; this is where most of the weight of a bloated skill is.
- **Duplication.** The same meaning in more than one place costs tokens, drifts into disagreeing versions, and inflates that meaning's rank past what the author intended. Each rule belongs in one authoritative place, so changing the behaviour is a one-place edit.
- **Relevance.** Sediment settles because adding feels safe and removing feels risky. Ask of each line whether it still bears on what the skill does today.
- **Sprawl.** A skill can be too long even when every line is live and unique. The cure is the ladder, not the delete key: disclose reference behind a pointer, and split the ways it is used so each path carries only what it needs.

**Form.** When guidance is there to fix a failure, the form has to fit that failure - the form that bulletproofs one backfires on another. Name the failure first, then check the form against it:

- *Violates a rule it knows, under pressure* -> a firm prohibition with the rationalizations named and countered.
- *Produces wrong-shaped output* (bloated, buried, restating its input) -> a positive recipe stating what the output is, and in what order. A prohibition backfires here: testing shows "don't restate" produces more of the unwanted content than no guidance at all.
- *Omits an element it otherwise produces* -> a structural slot, a required field in a template it fills, not a prose reminder.
- *Should behave differently by condition* -> a conditional keyed to something observable ("if a brief exists, reference it"), not an unconditional rule plus exemptions.

Steering by prohibition is the default mistake: *don't think of an elephant* names the elephant. Prompt the positive, so the unwanted behaviour is never spoken, and keep a prohibition only as a guardrail that cannot be phrased positively - paired, then, with what to do instead. Nuance and exemption clauses reopen the negotiation whichever form is chosen: "don't X unless it matters" is an invitation, and "this doesn't apply to code blocks" still suppresses code blocks. A real exception is its own conditional.

**Clarity.** Instructions that contradict each other or pull in opposite directions leave the agent to pick, and it picks differently every run. Ambiguous referents - an "it" with no clear antecedent - and a term used loosely in two senses do the same. Define a term once and use it consistently.

**Granularity.** Each split spends something: a new model-invoked skill costs its description in the context window every turn, and a split anywhere costs the author a thing to remember. Split only when the cut earns it - when a distinct trigger should fire the skill on its own, when another skill must reach it, or when the steps still ahead tempt the agent to rush the one in front of it. The reverse is a finding too: two skills saying overlapping things about one subject are one skill and a duplication problem.

## The bar a finding has to clear

Treat every candidate as a hypothesis and try to refute it before it reaches the report. A review loses trust faster to confident false positives than to anything else.

- **A constructed failure.** The concrete run in which this line makes the agent do the wrong thing: the request that comes in, and what the agent does with it that the author did not want. "This could be tighter" is not one. Keep the scenario with the finding - it is the proof and the author's reproduction both.
- **Not a preference.** A wording you would have chosen differently is not a finding. The question is whether the skill is worse for what it says, not whether you can imagine something better.
- **Labelled by what it changes.** Say for each finding whether it is a wording change that leaves behaviour alone, or a change to what the skill does - its scope, a judgment call, its output, when it fires. The second kind is the author's decision and nobody else's, and a behaviour change smuggled in as cleanup is the outcome this whole review exists to avoid. When you cannot tell which kind it is, call it the second; the cost of a wrong guess is asymmetric.

## Verify before reporting

A finding that claims something about behaviour - that a line does nothing, or that a rewrite would bind better - is a prediction, and a rewrite that reads better often binds worse. Where the claim is cheap to check, check it before you report it:

- **Sample fresh contexts.** Run the skill, or the section under the claim, as it will actually live, on a task that tempts the failure, across several fresh subagent samples. Single samples lie.
- **Always include a no-guidance control.** Run the same task with the line removed. If the control does not exhibit the failure, the line is a no-op and the finding is to cut it; if the control behaves the same as the rewrite, the rewrite is words for their own sake.
- **Read every flagged sample by hand.** Template echoes and quoted counter-examples masquerade as hits, and a raw count mis-states both failure and success.
- **Treat variance as the signal.** When wording binds, samples converge on one shape. Five different readings across five samples means it is not binding, and the fix is a tighter form rather than more words.

Where testing a claim is not worth what it costs, report the finding and say it is untested. What you must not do is report a prediction as a fact.

## Output

Findings go to the conversation. Group them by severity, worst first:

- **Blockers** - the skill fails at its job. It does not fire when it should, or fires when it should not; it contradicts itself so the agent has to choose; it sends the agent to something that is not there; a criterion is loose enough that the agent stops before the work is done.
- **Should-fix** - it works, but costs the agent or the author real effort: dead weight in the context window, a rule stated three ways, an altitude that will not survive the next case.
- **Nits** - minor.

For each: where it is (quote the line, or `SKILL.md` and the heading), what it does to a run, the failure you constructed, whether the fix is wording or behaviour, and the wording you would use. Where a lens came up clean, say so in a line rather than padding it.

Close with what you would do first, in one or two sentences. If the skill is in good shape, say that plainly instead of inventing findings to justify the invocation - "three tightenings worth making, nothing behavioural" is a fine result.
