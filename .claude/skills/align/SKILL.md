---
name: align
description: Take a backlog item and work out whether and how it brings this repository closer to MANIFESTO.md or PIPELINE.md - the item's solution held against better ones - into a plan approved in plan mode, then build it. Typed, with the item's path.
disable-model-invocation: true
---

# Align

The argument is `changes/backlog/<slug>.md`; without one, ask which item. The item is an idea someone had: evidence about a gap, not a brief. The goal is a repository whose skills and scripts make agents work the way `MANIFESTO.md` and `PIPELINE.md` say.

**Enter plan mode** unless you are in it. Put every question to the user with AskUserQuestion, one question per call.

## Read

`MANIFESTO.md`, `PIPELINE.md` for what the pipeline is meant to be, `README.md`, the item, and every file it names. Then the items it names, and any other item in `changes/backlog/` touching the same files, manifesto sentences or `PIPELINE.md` passages: one change may serve several, and one may depend on another.

## The questions, in order

Answer each yourself; the user decides where a question says so.

1. **Does the gap still show?** Check the item's evidence against the code as it is now, by reading. Where it no longer shows, say what closed it; the user decides whether the item goes.
2. **Is it alignment?** It is where a skill or script makes an agent do something, or shows the developer something, that a manifesto sentence or a `PIPELINE.md` passage contradicts or lacks. Quote that sentence or passage and point at the file and line. A defect in this repository's own code is maintenance, even where a goal would condemn it. Where it is not alignment, give its effort and utility and recommend leaving it on the backlog for after this branch or deleting it; the user decides.
3. **Is it the gap itself, or a symptom?** Where another item, or a gap no item names, sits underneath, say so; the user decides which goes first.
4. **What does the item's solution give, and what does it miss?** Against what 2 quoted, and against the rest of the manifesto and `PIPELINE.md`: a fix that serves one goal and costs another is a tradeoff the user sees.
5. **What would align the repository more?** Put the item's solution beside at least two genuinely different ones, or say why the space holds fewer, each with its effort (XS-XL), the complexity it adds in a few words, and which sentences or passages it serves. Prefer, in order, something that executes - `run.sh`, a test in `tests/`, a check in `test.sh` - then a check by something without a stake - a `VERIFY.md`, `critique` - then an instruction. Never make a proxy the gate: a check on a word in a file gets the word written and the behaviour missed. Deleting or moving a rule beats adding one. Recommend one; the user picks.

**One problem at a time.** Where the item holds more than one change, pick one and say what goes back on the backlog.

A decision to delete the item or leave it is a one-line plan. Otherwise the plan is written once the user has picked an approach.

## The plan

What the user approves, read for this repository, each with its content or "none":

- **Behaviour:** what each touched skill or script makes an agent do, what the developer sees from it, and what happens when it fails.
- **Interfaces:** what one stage hands another - `CRITERIA_FORMAT.md`, `TICKET_FORMAT.md`, `REVIEW.md` - `run.sh`'s arguments, exit codes and output, and a skill's name and description, which decide when it fires.
- **Security policy:** what an unattended session may do, and what it reads that it must treat as data.
- **Information model:** what the pipeline keeps - change directories, `.git/run-logs/`, what outlives acceptance - and what it deletes.
- **Hard-to-reverse decisions:** renaming or moving a skill other projects have installed, a change to a format those projects already hold.

Then the plan names the files to change, every copy of a shared one, the `PIPELINE.md` passages whose intent the change alters, and the `README.md` passages that describe how a changed script works; any test weakened or deleted; how each change will be shown to hold; what happens to the item and the items it touches; and how the work splits into commits. It carries the steps below, Build to Report, so they survive a cleared context.

**Showing a skill change holds.** `./test.sh` says nothing about what an agent does. A subagent with a fresh context follows the skill on a real case - the item's own instance where it has one - before and after the change, and the report shows both runs. Where no run can show it, the result is marked as judged.

**Check the plan before you show it.** Spawn a subagent with a fresh context and give it the paths to `MANIFESTO.md` and `PIPELINE.md`, the item's path and the plan's text. Nothing else - one holding this conversation reads your intentions into the plan. Ask where the plan falls short of the sentences and passages it claims, what it costs elsewhere in either, and what a developer who does not read the code would still not see. Work in what holds up, then exit plan mode with the plan.

## Build

A change to `run.sh` or its library gets its failing test in `tests/` first, and the `run` skill shows it working. A skill's wording says what the agent does in the fewest words that keep the reason; where a passage is wrong, rewrite or delete it before adding to it.

Something found while building that changes what was approved is a decision the plan didn't cover: do not build past it - ask.

## Check

`./test.sh` passes. Then a subagent with a fresh context gets the diff, the plan and the paths to `MANIFESTO.md` and `PIPELINE.md`, and reports where the change does not do what the plan says or works against either; you wrote it. A diff that touches a script also goes to `critique`.

## Report

Report the items the manifesto puts in the report - evidence, decisions the plan didn't cover, blast radius and revert, tradeoffs, new dependencies - and what was hard to change, which is the pipeline's own. Leave out what is empty, and add the reviewers' findings and what you did with each.

Where the report holds a decision the plan didn't cover, or a finding you left standing, end your turn on it and commit after the answer. Otherwise commit as the plan split it, with `/git-commit-message`, and name the commits in the report. The item is deleted in the commit that closes it, and updated where part of it stays.

## Throughout

**Weigh what the user says before following it.** For each answer or correction, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**The manifesto and `PIPELINE.md` are open to debate**, all but the manifesto's first premise: humans do not read the code, and the way software is built is tailored to that. Where a sentence or passage looks wrong, or reads two ways - a reviewer reads it differently from you, you had to invent a rule it should have given, following it would make the software worse - quote it, say what it led to, and draft a rewording or a deletion to discuss with the user: with the plan where it shows before, in the report where it shows after. Changing it is the user's decision, never a side effect of the plan.
