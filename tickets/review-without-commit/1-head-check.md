---
solution:  SOLUTION_REVIEW_WITHOUT_COMMIT.md
satisfies: AC-1, AC-2, AC-4, AC-5, AC-6
after:
status:    review
attempts:  3
reviews:   1
---

## Build

Teach the runner to remember where `HEAD` was before it launched a build session, and
to stop believing a session that says it built something without moving it.

## Done when

> **AC-1** The runner records `HEAD` before each build session and, on `status:
> review`, requires it to have moved.

> **AC-2** A session that reported a build without committing is retried within
> the attempt budget, as a crashed one is. When the budget is spent, the runner
> halts the ticket as `unbuilt` — saying the session claimed a build and
> committed nothing, rather than that the budget ran out — and the run stops, as
> it does on every other halt.

> **AC-4** The runner suite exercises a session that sets `review` and commits
> nothing, and the stub can be told to behave that way.

> **AC-5** A rework pass, which commits again on an earlier commit, does not
> halt.

> **AC-6** The runner refuses to start in a repository with no commits, where
> `HEAD` cannot be read and the check would otherwise pass by accident.

## Context

`run.sh` launches the build session at the `session "$ticket" implement` call and then
reads `status` out of the ticket. `review` is accepted there with no further check.
Around it: a crashed session already resets the claim and spends an attempt, which is
the tolerance this failure is being given too, and `halt()` writes a `## Halt` section
and sets `status: halted`; every caller of it exits.

`tests/stub-session` is the instrument. It commits on `implement:review` today, which
is why no case in the 29 has ever exercised this. It needs an outcome that sets the
status and commits nothing.

The refusal for a repository with no commits goes beside the other pre-launch refusals.
`--is-inside-work-tree` succeeds there, and `git rev-parse --abbrev-ref HEAD` fails, so
the branch check passes by accident today.

## Not here

The halt kind's appearance in `implement/SKILL.md` and `NEW_PIPELINE_IDEA.md` is ticket
2. Write the halt; do not teach it.

## Record

`tests/run.sh` — 257 passed, 0 failed, which includes `tests/runner.sh` at 37.

**AC-1, AC-2** — `a session that committed nothing still spends an attempt`, `a build
that never commits halts once the budget is spent`, `the halt is named for what
happened, not for the budget`, `and says the session claimed a build and committed
nothing`. `head_before` is read just before the build session and compared once
`review` has been accepted, so a status the session wrote is checked against a commit
it cannot fake. An unmoved HEAD is given a crash's tolerance — the claim goes back and
the attempt is spent — and the halt fires on the attempt that spends the last of the
budget rather than letting the next pass report `exhausted`.

**AC-4** — the stub's new `implement claim-only`: it appends to the ticket and sets
`review`, and commits nothing. `implement review` was the only build outcome before,
which is why none of the suite's cases could reach this.

**AC-5** — `a rework that commits again is not read as a build that committed nothing`.
A rework's commit lands on the one the first pass left, so HEAD has moved twice rather
than not at all; it is asserted on the run the findings case already makes — findings, a
second build, a clean review — which is the run this criterion is about.

**AC-6** — `it refuses a repository with no commits, for the reason it gives`, `a
repository with no commits launches nothing`. `git rev-parse HEAD` beside the other
pre-launch refusals, above the branch check that passes there by accident.

**Each criterion was broken and watched to fail.** Deleting the refusal fails AC-6's two
cases; inverting the HEAD comparison fails the rework case and sixteen more; removing the
unbuilt block fails four; moving the budget edge from `-ge` to `-gt` fails the two that
name the halt — and, worth saying, *not* the case asserting it halted at all, which the
wrong halt satisfies. The kind and its wording are what pin AC-2, not the status.

**Second pass, answering the findings.** The refusal's stated reason was false — an empty
repository's `rev-parse HEAD` prints the literal `HEAD`, so the comparison in fact tells a
build from a claim there. The comment and the `die` message now give the reason that holds:
the branch refusal passes by accident, and a correctness check should not rest on a command
echoing its own argument back. `it refuses a repository with no commits, for the reason it
gives` is the case that pins it — it went RED on the old message before the new one was
written. The `-ge` against the selection's `-gt` now says in the comment why it differs, and
the rework case no longer repeats the setup of the one above it: both assertions read the
same run, so the plan has one place to change.

## Findings

One review round: one should-fix, two nits. Every `Record` claim was checked by mutation
and every one held — deleting the refusal fails AC-6's two cases, inverting the
comparison fails seventeen, `-ge` to `-gt` fails the two that name the halt, removing the
block fails four, and `tests/run.sh` is 257 passed / 0 failed with `tests/runner.sh` at 37.

**The refusal is justified by something that is not true** (`run.sh:33-36`, and the same
claim again in `tests/runner.sh:99-101` and in the commit message). The comment says that
in a repository with no commits "a session that committed nothing would look exactly like
one that did". It would not. `git rev-parse HEAD` in an empty repository exits 128 but
prints the literal string `HEAD` on stdout, so `head_before` would be `HEAD`; a session
that commits makes the second read a sha and the comparison unequal, and a session that
commits nothing leaves it `HEAD` and the comparison equal. The check gets both cases
right there. The real reason for the refusal is the one the `## Context` gives and the
first half of the comment already says — the branch refusal passes by accident — plus
not wanting to rest a correctness check on `rev-parse` echoing its own argument back.
The `die` message carries the same false reason: "a run needs a HEAD to tell a build from
a claim" says the thing the check does not in fact need. Whoever next touches this reads
a stated rationale, checks it, finds it wrong, and has no way to tell whether the refusal
is load-bearing or the comment is stale — which is the whole cost of a comment that does
not stand on its own. Say the true reason in all three places.

**The two budget edges disagree and nothing says why** (`run.sh:188` against `run.sh:158`).
The same counter is compared `-ge MAX_ATTEMPTS` in the unbuilt path and `-gt MAX_ATTEMPTS`
in the selection above it, thirty lines apart, and both are deliberate: the unbuilt halt
fires on the attempt that spends the last of the budget, because letting it fall through
would report `exhausted` and lose the thing AC-2 exists to say. The comment above the
block explains the tolerance but not the edge, so the `-ge` reads as the off-by-one
someone will helpfully correct — and the suite will agree with them on the case that only
asserts it halted at all. A clause in the comment is enough.

**The rework case repeats the setup of the case three lines above it**
(`tests/runner.sh:211-218` against `202-207`): identical `workspace`, an identical
six-element `plan`, an identical `run`, differing only in what is asserted afterwards. A
change to that plan has two places to make it, and the second runner invocation buys
nothing the first could not have carried. Fold the `rc = 0` and no-`## Halt` assertions
into the existing case.


