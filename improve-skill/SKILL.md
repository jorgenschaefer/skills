---
name: improve-skill
description: Improve an existing agent skill so it does its job better in fewer words - "improve this skill", "tighten this SKILL.md", "review this skill", "this skill is too long", "make this skill more concise", "clean up my skill", "my skill never triggers", "fix this skill's description". Use it on any skill that reads as bloated, repetitive, vague or contradictory, on one that never fires when it should, and on a skill you have just finished writing. It edits the file and leaves the change uncommitted.
---

# Improve Skill

Make the skill achieve its purpose in as few words as the purpose allows: fix what works against the purpose, cut what does nothing, and declare every change to what the agent will do.

Never change `name:` or the directory name; people use that word in prompts and other skills.

Every file the skill carries is in scope. A file that exists word for word under another skill is a copy kept identical by hand, because a skill installs alone. Write your result over every copy in the same change; where you cannot see the others, name the file and say it has copies.

## Read it whole first

Read SKILL.md and every file it points at before judging a line. Then find what its runs left behind: transcripts, artifacts, the complaint that brought you here. Behaviour outranks text. Where nothing survives, say so.

## State the purpose

Quote the sentence that says what the skill is for. Where there is none, derive it and write it at the top. Judge every line against it.

## Fix what works against the purpose

Read the skill as the agent that will follow it, and rewrite in the file each passage that would make a run miss the purpose:

- A contradiction: two lines pulling opposite ways. Keep one.
- A line with two readings that lead to different runs.
- An instruction that works against the purpose.
- A step with no way to tell done from not done, or one asking for something where it meant everything - "produce a list" where every caller had to be accounted for.
- A form that does not fit its failure. Wrong-shaped output wants a positive recipe; an omitted element wants a slot in a template; a rule broken under pressure wants a prohibition that names the rationalizations.
- Hardcoded paths, counts and line numbers that will drift.
- Reference material that belongs behind a pointer, or a pointer the agent will not follow.
- The description. It decides whether the skill fires: phrased the way users ask, one trigger per distinct use, distinguishable from the skills beside it (read their descriptions), and only *when* to use - a process recap there becomes a shortcut past the body.

Each of these is a behaviour change and goes on the declared list with the problem it fixes. Add text only to fix a named problem.

## Cut what does nothing

A cut must not drop an instruction - anything that changes what the agent does: a qualifier (*only*, *every*, *unless*, *if it exists*, *genuinely*), a step or the order between dependent steps, an exception, a count, a format, a pointer, what a subagent returns. Most losses are a clause inside a shortened sentence.

Cut:

- Lines a competent agent obeys without them, across five runs rather than on a good one: encouragement, descriptions of its own tools, general principles. A project's own definition of a familiar term is not one of these.
- Restatements of the purpose.
- Duplication. Keep each rule in one place. A copy in a file or subagent prompt that is read alone is not a duplicate, nor is a repeat that narrows the rule.
- Sediment: lines about what the skill used to do.
- Words circling one idea, where a word the model already thinks with carries every part - *tight loop*, *tracer bullet*.

### Reasons, stories and filler

Model-written skills explain themselves to a reader. The usual shapes:

- incident reports from past runs - "one analysis that...", "in four runs..."
- the author's measurements behind a rule
- lines addressed to the reader rather than the agent - "this is the step that makes..."
- closing aphorisms
- the consequence of a rule restated after the rule
- "X, not Y" where Y is not a mistake the agent would make

History goes in git, not in the skill. Handle each reason or story one of three ways:

1. **Keep it as one clause** only where it does one of three jobs, and name which: it lets the agent apply the rule to cases the rule does not list; it holds a rule the agent will be tempted to break; it stops the agent "fixing" a rule that looks wrong without it.
2. **Distill it** where it carries an instruction: replace it by that instruction, stated directly. "Before running anything, check... One analysis that ran the tests hit the shared test database" becomes "Before running anything, tests included, check...".
3. **Delete it.**

### Guessed cuts

Where reading cannot settle whether a line carries an instruction, either test it or make the cut and mark it guessed in the report. To test, give several fresh subagents a task that tempts the failure the line prevents, three ways: with the line, with your rewrite, and with the line removed. If the removed version does not fail, the cut stands. Read the samples rather than counting them.

## Review in a fresh session

Spawn a subagent with a fresh context. Give it the original, the rewrite, the purpose and your declared list - not your reasoning for any edit. Ask it for, without judging whether each matters:

- every instruction in the original that is absent from the rewrite, quoted, including those phrased as reasons or stories
- every difference in behaviour the declared list does not name
- any passage the rewrite made harder to follow

Put back every loss that is not on the declared list and not a guessed or tested cut, as the instruction stated directly rather than the passage it came from. Check that every pointer still resolves.

Run the project's checks, even where they seem not to touch a skill, and report what they said. Where you find none, say so.

## Report

- Size before and after, in characters.
- **Behaviour changes**, each with the problem it fixes.
- **Guessed cuts**, so the author can revert them.
- What you tested and what it showed.
- What the reviewer found and what you did with each finding.

Leave the change uncommitted.
