---
name: learn-from-sessions
description: Read this project's Claude Code sessions since the last run, find where the work fell short or went well, and propose where each finding goes - the project's CLAUDE.md or code, an evidence file in the skills repository, or nowhere. The developer decides what is applied.
disable-model-invocation: true
---

# Learn from sessions

Read what happened in this project's sessions, and find what should change so the next session goes better. You only find candidates. The developer decides what is applied.

## Find the sessions

The skills repository is where this skill's directory really lives: follow the link from this skill's base directory with `readlink -f`, and take its parent. Its `docs/manifesto.md` says what good software with coding agents needs, and its `docs/evidence/` holds the evidence files written so far. Read the manifesto and one evidence file before you start.

List this project's sessions that have not been read yet:

```
python3 <this skill's directory>/sessions.py <project path>
```

If a `learn-from-sessions-report.md` is already in the directory of the session logs, an earlier run ended before the developer answered. Show its findings along with the new ones.

Leave out the session you are running in: the newest one, whose last message asks for this skill. If this is the first run in the project and there are more than about ten sessions, ask the developer from which date to start, and mark the older ones as read (below) without reading them.

Turn each session into a readable conversation in the scratchpad, and read it:

```
python3 <this skill's directory>/narrate.py <log file> > <scratchpad>/<session id>.txt
```

If there are more than a few sessions, give each to a subagent. Tell it to read the sections "What to look for" and "Each finding" in this file, and to return its findings in that form.

## What to look for

Where did the work fall short of the four goals in the manifesto, utility, security, usability and maintainability, or of its other ideas? Where did the developer have to step in, correct something, repeat something, or find something too late? What took more of the developer's attention than it should have?

Look first at these places, all seen before. They are a start, not the limit:

- the developer corrected the agent, or had to push for something;
- the developer asked a question that showed a gap;
- a skill should have started and did not;
- the agent decided something hard to undo on its own;
- a later session found bugs the build missed.

**Look for what worked too.** A good result that came without a rule is evidence that no rule is needed. Looking only for faults leads only to adding things.

## Each finding

- **What happened**, in a sentence or two.
- **Where**: the session ID, and a quote from the session that shows it. No quote, no finding.
- **Why**, as far as the session shows: which instruction, skill or gap led to it.
- **Where it goes**:

| Destination | When |
|---|---|
| The project's `CLAUDE.md` or code | It is about this project: its domain, its conventions, a missing check. |
| The skills repository, as an evidence file | It is about how a skill or the workflow behaves, in any project. |
| Nowhere | A one-off, or already known. |

Before you call a finding about a skill new, read the skills repository's `docs/evidence/`: it may be known already. The same kind of finding seen in several sessions is one finding, with each session listed. Seen in three sessions is stronger than seen once.

## Report

First write the findings, grouped by destination, the strongest first, to `learn-from-sessions-report.md` in the directory of the session logs. Then mark every session you read as read:

```
python3 <this skill's directory>/sessions.py <project path> --mark <session id>...
```

If the session ends before the developer answers, nothing is lost. Then show the developer the findings, and let them pick what to apply.

- **Findings about this project**: make the changes the developer picks, with them, in this repository.
- **Findings about skills**: write them into `docs/evidence/YYYY-MM-DD-<project>.md` in the skills repository, in the form of the evidence files there. Describe each pattern in your own words. Don't copy the project's code or data into it: the evidence file lives in another repository. Don't change any skill: turning evidence into skill changes is work for that repository. Commit the evidence file there.

When the developer is done, delete the report file.
