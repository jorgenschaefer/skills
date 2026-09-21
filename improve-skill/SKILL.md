---
name: improve-skill
description: Cut an existing agent skill down to what changes what the agent does - "improve this skill", "tighten this SKILL.md", "this skill is too long", "make this skill more concise", "clean up my skill", "my skill never triggers", "fix this skill's description". Use it on any skill that reads as bloated, repetitive or vague, on one that never fires when it should, and on a skill you have just finished writing. It edits the file and leaves the change uncommitted, so the author reads a diff rather than a report.
---

# Improve Skill

Cut the skill to what changes what the agent does. What you would *add* is a proposal in the report, never an edit, and a skill that was already tight comes back nearly untouched.

Every edit is a deletion, or a replacement by something shorter - a clause out of the middle of a sentence counts, and is usually where the most is available. That is the whole of your licence over the file.

A replacement is legitimate when nobody can name an instruction the short version drops. One that loses a caveat, a condition or a pointer is not a shorter version of the passage; it is a behaviour change, and belongs in the list you declare at the end.

Never change `name:` or the directory name. People have that word in their prompts and their other skills.

Every file the skill carries is in scope, not just SKILL.md. Where one of them exists word for word under another skill it is a copy kept identical by hand, because a skill installs alone and cannot reach a sibling's directory. Cut it, then write the result over every other holder in the same change - a copy that drifts is worse than the sentence you tightened. Where the other holders are not in front of you, name the file you changed and say it has copies, so whoever can see them finishes it. The other holders are not out of scope: a shared file left alone because touching it "also affects the siblings" is the one file in the skill that never gets better.

## Read it whole first

SKILL.md and every file it points at, before you judge a line: the outcome it exists to produce, the judgment it encodes, the moment it fires. A line you cut because you could not see its job is the failure mode of this skill.

Then find what its runs left behind - transcripts, the artifacts it produced, the complaint that brought you here. Behaviour outranks text. Where nothing survives, say so, and be slower to call a line dead, because nothing in front of you shows a run going right without it.

## Name the base

A skill has one sentence that says what it is for. Everything downstream that merely follows from that sentence is already said, and can go.

Quote it where it is there. Where it is not, derive it and write it in - a skill whose thesis was never stated accumulates that thesis in pieces, a clause at a time, at five sites, and stating it once retires all five. That is usually the largest cut available and the one to make first, and it is the single addition this skill is allowed, because it is written in order to delete with. Where it does not retire more than it costs, it is a proposal like any other.

## Cut

Aggressively. Most of the weight of a bloated skill is here.

- **Lines the model already obeys.** Read one sentence in isolation: would a competent agent behave differently without it - not on the run you are imagining, but across five of them? A skill is there to get the same process out of a stochastic system, so a line that only narrows what a bad run does is load-bearing, however redundant it looks against a good one. Encouragement ("be thorough", "think carefully"), descriptions of the agent's own tools, and principles any competent agent brings with it fail even that test. Delete the sentence whole - tightening a no-op leaves a shorter no-op.
- **Consequences of the base.** From the pass above.
- **Duplication.** Each rule in one authoritative place, so changing the behaviour is a one-place edit. Repetition also inflates a rule's rank past what the author intended.
- **Words around the instruction.** Agent-written prose explains itself to a reader: rationale trailing the instruction, the same point in other words, hedges, a preamble setting up the next line. Cut to the instruction. Rationale stays only where the agent is expected to resist the instruction.
- **A concept the model already holds.** A triad spelled out at three sites, or a sentence circling one idea, often collapses into a word the model already thinks with - *lesson*, *fog of war*, *tracer bullets*, *red*. "Fast, deterministic, low-overhead" is a *tight* loop. The word recruits the priors and retires the restatements, and where it is one the author's own docs and prompts use, it anchors invocation too.
- **Sediment.** Lines that bear on what the skill used to do.
- **One side of a contradiction.** Two lines pulling opposite ways leave the agent to pick, and it picks differently every run. Deleting the wrong one is a behaviour change; say which you kept.

## What you propose rather than write

These are the improvements that add, so they belong in the report as the wording you would use, for the author to paste or decline. Look for them in the same pass, and do not write them into the file:

- **The description.** The highest-leverage line - it sits in context every turn and decides whether the skill fires. Phrased the way a user actually asks, one trigger per distinct use, separable from the skills it sits beside (read their descriptions - the competition is invisible from inside one file). Keep it to *when to use*: a description recapping the process becomes a shortcut the agent takes instead of the body. Shortening it is a cut and you may make it; a missing trigger is an addition and you may not.
- **A missing completion criterion.** A step ending on a condition the agent cannot tell done from not-done, or one demanding something rather than everything - "produce a list" where the skill meant "every caller accounted for".
- **Altitude.** Hardcoded paths, counts and line numbers that will drift or generalize wrongly, and what to say instead.
- **A form that does not fit its failure.** A wrong-shaped output wants a positive recipe; an omitted element wants a required slot in a template; a rule broken under pressure wants a prohibition with the rationalizations named. Prohibition is the default mistake - *don't think of an elephant* names the elephant.
- **The ladder.** Reference material that should move behind a pointer, or a pointer whose wording will not make the agent go.

## Test the cuts you are guessing about

Where you cannot tell from the text whether a line is load-bearing, don't guess - run it. The task is one that tempts the failure the line exists to prevent, across several fresh subagents, three ways: with the line, with your rewrite, and with the line simply removed. That last one is the control that matters. If the control does not fail, the line was a no-op and the cut stands; if the control matches your rewrite, the rewrite is words for their own sake.

Read the samples rather than counting them. Converged samples mean the wording binds; five readings across five samples mean it does not, and the fix is a tighter form, not more words.

This costs real time, so spend it only on the cuts you would otherwise be guessing at.

## Review in a session that did not rewrite it

Spawn a subagent with a fresh context. Hand it the original text, your rewrite, and the skill's purpose - **not** your reasoning for any edit. A reviewer that has followed you to each decision will read your intentions into the result. Ask it for:

- Every instruction in the original that is absent from the rewrite, quoted from the original. Most of what goes missing is a clause rather than a sentence - *if it exists*, *where the repo has one*, *a short structured summary* - which disappears inside a line being shortened and leaves prose that still reads correctly.
- Every difference in what the skill will do that your declared list does not name.
- Any passage the rewrite made harder to follow.

Then put back every instruction it found missing, or, where you meant the loss, name it in the behaviour list - one or the other for each finding, with nothing argued away. Check that every file the skill still points at exists and every pointer still fires.

Run the project's checks and report what they said. Where you cannot find them, say so. The pull here is to decide from the outside that they do not apply to you - that the suite is about the real repository rather than this copy, that the environment is not set up, that nothing you touched could have broken them. Run them and find out; the guess is free to make and wrong about half the time.

## Report

- What it weighed before and after, in characters. Lines understate a pass that worked mostly inside them. It is shorter, or you have something to explain.
- **What you changed about its behaviour**, as a list. Scope, a judgment call, the output shape, when it fires. This is the author's territory and a behaviour change smuggled in as cleanup is the outcome this whole skill exists to avoid - when you cannot tell which kind an edit was, list it.
- **What you would add**, as wording ready to paste. Say what each one fixes.
- What you tested, and what you cut on reading alone.
- What the reviewer found.

Leave the change uncommitted. The author reads a diff.
