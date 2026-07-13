---
name: debug
description: Use when a bug, test failure, or unexpected behavior needs investigating and the cause isn't clear – especially when a fix isn't obvious or earlier fixes haven't stuck. Fired explicitly via /debug. To turn an already-understood bug into a change plan use /propose-change; to build new behavior use /implement.
disable-model-invocation: true
---

# Debug

Find the root cause before you change anything. A fix you can't tie to a cause is a guess, and guesses leave the real defect live while spawning new ones. The discipline here is what makes debugging fast – guess-and-check thrashing is the slow path, especially under the time pressure that makes guessing tempting.

Scale it to the bug: a one-line typo needs none of this ceremony; a failure that crosses components needs all of it. What never scales away is the spine – cause before fix, one change at a time, and stop before you thrash.

## Find the cause before fixing

No fix until you can name the root cause. To get there:

- **Read the error completely.** The stack trace, line numbers, and codes often name the cause outright – don't skim past them to a theory.
- **Reproduce it reliably first.** If you can't trigger it on demand, you can't know you've fixed it – gather more data rather than theorize from one sighting.
- **Check what changed.** Recent commits, a new dependency, a config or environment difference – a bug that just appeared usually has a recent cause.
- **Instrument the boundaries.** When the failure crosses components (request → service → store, CI → build → sign), log what enters and leaves each stage and run once to see *where* it breaks before asking *why*. Narrow to the failing component, then investigate that one.
- **Trace the bad value to its origin.** Follow it backward up the call stack to where it first goes wrong, and fix there – not where the symptom finally surfaced.

## Test one hypothesis at a time

State a single hypothesis – "X is the cause because Y" – and test it with the smallest change that would confirm or kill it, one variable at a time. If it's wrong, form a new hypothesis; don't layer another fix on top of the last. When you don't understand something, say so and keep investigating rather than pretend a theory is settled.

## Fix the root cause

Write a failing test that reproduces the bug first, then make the single change that addresses the cause – no bundled refactoring or "while I'm here" edits. Verify against evidence: the new test passes, nothing else broke, and the original symptom is actually gone, not merely masked. Arrived here from `/implement`? Return to its RED/green loop with the test you just wrote; standalone, the fix still gets its own RED-first test and commit.

## When fixes keep failing, question the design

After about three failed fixes, stop trying. Repeated failure – each fix uncovering a new problem elsewhere, or every candidate demanding "massive refactoring" – is the signature of a wrong architecture, not a missing fourth attempt. Surface it to the user and question the design rather than swinging again.

If genuine investigation shows there is no single root cause – the behavior is environmental, timing-dependent, or external – document what you ruled out and implement appropriate handling (a retry, a timeout, a clear error). But most "no root cause" verdicts are incomplete investigation; suspect that first.

## Signs you're guessing, not debugging

Proposing a fix before reproducing the bug; changing several things at once; "let me just try X and see"; reaching for fix number four. Each means stop and go back to finding the cause.
