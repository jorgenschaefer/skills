---
name: accept-intent
description: Use the finished feature and say whether it solved the problem.
disable-model-invocation: true
---

# Accept an intent

You are given an intent - `intents/<slug>/01-INTENT.md`, or the `## Intent` section of the solution beside it where no intent document was written. Say whether the problem it describes was solved.

## Drive the feature

**Use it the way its user would**, in the running product. Do not read the diff and conclude: deciding by eye whether code would behave a certain way is prediction, and prediction is what this stage exists to replace.

Start it the way the project says to - a `run` skill, `CLAUDE.md`, the README - before building a harness of your own. Where you had to build one, write it up as the project's run skill, `.claude/skills/run/SKILL.md`, with the scripts it drives beside it. Leave it uncommitted and name it in the report - whether it stays is the reader's call. A harness described only in a report is rebuilt by the next walk, and never reaches the builds, which do not read reports.

Where you cannot get the product running at all, stop and say so - that is the report, and every condition is unchecked.

## Walk the conditions

Take `## Done when` condition by condition, by id, and for each say whether you could find it in the product - what you did, and what you saw.

A condition you could not check is not a condition you passed. Say which it was and why you could not.

## Read the Records

Each ticket's `## Record` names the test that pins each criterion. Read them as you walk: they are the build's claim that a criterion was covered rather than asserted, and nothing else reads them now.

Where a Record names a test for a criterion whose condition you could not find in the product, say so plainly. That gap - green tests, absent behaviour - is the most useful thing this stage can report.

Each Record also says what its build left standing: findings not fixed, checks not run, departures from the plan.

## Report

One entry per condition id, including every id you could not check: what you did to check it, and what you saw. Then what the builds left standing, one line per item with its ticket, saying whether your walk touched it. No verdict on whether to merge: that is the reader's.
