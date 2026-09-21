---
name: accept-intent
description: Use the finished feature and say whether it solved the problem.
disable-model-invocation: true
---

# Accept an intent

You are given an intent - `intents/<slug>/01-INTENT.md`, or the `## Intent` section of the solution beside it where no intent document was written. Say whether the problem it describes was solved.

This is the only stage that asks that question. Every check before it compared an artifact to the one before it, and a chain of sound links proves nothing about what started it.

## Drive the feature

**Use it the way its user would**, in the running product. Do not read the diff and conclude: deciding by eye whether code would behave a certain way is prediction, and prediction is what this stage exists to replace.

## Walk the conditions

Take `## Done when` condition by condition, by id, and for each say whether you could find it in the product - what you did, and what you saw.

A condition you could not check is not a condition you passed. Say which it was and why you could not.

## Read the Records

Each ticket's `## Record` names the test that pins each criterion. Read them as you walk: they are the build's claim that a criterion was covered rather than asserted, and nothing else reads them now.

Where a Record names a test for a criterion whose condition you could not find in the product, say so plainly. That gap - green tests, absent behaviour - is the most useful thing this stage can report.

## Report

Which conditions you found, which you did not, and what you did to check each. No verdict on whether to merge: that is the reader's.
