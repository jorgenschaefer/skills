---
name: improve-skill
description: Improve an existing agent skill so it does its job better in fewer words - "improve this skill", "tighten this SKILL.md", "review this skill", "this skill is too long", "make this skill more concise", "clean up my skill", "my skill never triggers", "fix this skill's description". Use it on any skill that reads as bloated, repetitive, vague or contradictory, on one that never fires when it should, and on a skill you have just finished writing. It edits the file and leaves the change uncommitted.
---

# Improve Skill

Make the skill achieve its purpose in as few words as the purpose allows, in language a developer new to the project understands on first reading. Fix what works against the purpose, cut what does nothing, and list every change to what the agent will do. Shorter must not mean harder to read.

Never change `name:` or the directory name. People use that name in prompts and in other skills.

Improve every file the skill carries, not only SKILL.md. If a file exists word for word under another skill, it is a copy kept identical by hand, because a skill installs alone. Write your result over every copy in the same change. If you cannot see the other copies, name the file you changed and say that it has copies.

## Read it whole first

Read SKILL.md and every file it points at before you judge a line. Then look for what its runs left behind: transcripts, the files they produced, the complaint that brought you here. If the runs and the text disagree, trust the runs. If no runs left anything, say so.

## State the purpose

Quote the sentence that says what the skill is for. If there is none, work it out and write it at the top. Judge every line against it.

## Fix what works against the purpose

Read the skill as the agent that will follow it. Rewrite in the file every passage that would make a run miss the purpose:

- Two lines that contradict each other. Keep one.
- A line that can be read two ways, where the two readings lead to different runs.
- An instruction that works against the purpose.
- A step where the agent cannot tell whether it is done, or one that asks for some where it means all: "produce a list" when every caller has to be accounted for.
- An instruction in the wrong form. If runs produce output of the wrong shape, describe the right shape. If they leave something out, add a slot for it to a template. If they break a rule under pressure, forbid it and name the excuses.
- Paths, counts and line numbers written into the text that will go out of date.
- Reference material the agent needs only in some runs. Move it to a separate file behind a pointer.
- A pointer worded so that the agent will not follow it.
- Hard language. Rewrite so each sentence is understood on first reading: one instruction per sentence, the agent as subject, "if" rather than "where", no stacked negations. Use only terms that already exist in the project, the field or a dictionary. Replace a label the author invented, or a metaphor used as a name, by the plain statement. A thing mentioned once needs no name.
- The description. It decides whether the skill fires. Phrase it the way users ask, with one trigger for each distinct use, and make it distinguishable from the descriptions of the skills next to it - read them. Keep it to when to use the skill: if it summarises the process, the agent follows the summary and skips the body.

Each of these fixes changes behaviour. List each one with the problem it fixes. Add text only to fix a problem you name.

## Cut what does nothing

A cut must not drop an instruction. An instruction is anything that changes what the agent does, including:

- a qualifier: *only*, *every*, *unless*, *if it exists*, and a word that raises a bar, such as *genuinely* in "three genuinely different approaches"
- a step, or the order of two steps when one depends on the other
- an exception
- a count, a format or a pointer
- what a subagent is told to return

Most lost instructions are a clause dropped while shortening a sentence.

Cut:

- A line a competent agent would follow without being told, across five runs and not only on a good one: encouragement, descriptions of the agent's own tools, general principles. Keep the project's own definition of a familiar term.
- A line that restates the purpose.
- Duplication. Keep each rule in one place. A copy in a file or subagent prompt that is read on its own is not a duplicate. Neither is a repeat that narrows the rule.
- A line about what the skill used to do.
- Several sentences circling one idea, if an existing term says all of it: *tight loop*, *tracer bullet*.

### Reasons, stories and filler

Model-written skills explain themselves to a human reader. Look for:

- reports of past runs: "one analysis that...", "in four runs..."
- the measurements the author used to justify a rule
- sentences addressed to the reader rather than the agent: "this is the step that makes..."
- a short saying at the end of a paragraph
- a rule's consequence, restated after the rule
- "X, not Y", where Y is not a mistake the agent would make

The history of a rule belongs in the commit message, not in the skill. For each reason or story, do one of these:

1. **Keep it as one clause** if it does one of the following, and say which: it lets the agent apply the rule to cases the rule does not list; it holds a rule the agent will be tempted to break; or it stops the agent from "fixing" a rule that looks wrong without it.
2. **Replace it by the instruction it carries**, stated directly. "Before running anything, check... One analysis that ran the tests hit the shared test database" becomes "Before running anything, including tests, check...".
3. **Delete it.**

### Cuts you are unsure about

If reading cannot tell you whether a line carries an instruction, either test the cut, or make it and mark it as guessed in the report. To test it, give several fresh subagents a task that tempts the mistake the line prevents, three ways: with the line, with your rewrite, and with the line removed. If the version without the line does not fail, the cut stands. Read what the subagents did; do not just count results.

## Review in a fresh session

Spawn a subagent with a fresh context. Give it the original, the rewrite, the purpose and your list of behaviour changes. Do not give it your reasons for any edit. Ask it to report the following without judging whether each one matters:

- every instruction in the original that is missing from the rewrite, quoted, including those written as reasons or stories
- every difference in behaviour that your list does not name
- every passage the rewrite made harder to understand

Put back every lost instruction that is not on your list and not a guessed or tested cut. Put it back as the instruction, stated directly, not as the passage it came from. Check that every pointer still leads to a file that exists.

Run the project's checks, even if they seem unrelated to a skill, and report what they said. If you find no checks, say so.

## Report

- Size before and after, in characters.
- **Behaviour changes**, each with the problem it fixes.
- **Guessed cuts**, so the author can revert them.
- What you tested, and what the test showed.
- What the reviewer found, and what you did with each finding.

Leave the change uncommitted.
