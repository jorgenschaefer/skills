# Solution: the runner remembers where HEAD was

## Intent

`INTENT_REVIEW_WITHOUT_COMMIT.md` — answers C-1 through C-3. Tagged `C-n`, since it
answers one intent.

## Approach

The runner records `HEAD` before it launches a build session. When that session comes
back having written `status: review`, the runner compares: if `HEAD` has not moved, the
session reported a build and committed nothing, and the ticket takes a halt of a kind
the runner writes — `unbuilt`.

It sits with the other things the runner does because a session cannot be asked to prove
it committed: that is the same party's word for the same claim. The runner already
holds the only fact that settles it, because it is the process that was there before the
session started and is still there after.

A rework pass commits on top of an earlier one, so `HEAD` moves again and the check is
silent. A session that halts, or dies, never reaches the check at all.

## Behaviour

- **AC-1** The runner records `HEAD` before each build session and, on `status: review`,
  requires it to have moved. *(C-1)*
- **AC-2** A session that reported a build without committing is retried within the
  attempt budget, as a crashed one is. When the budget is spent, the runner halts the
  ticket as `unbuilt` — saying the session claimed a build and committed nothing, rather
  than that the budget ran out — and the run stops, as it does on every other halt.
  *(C-1, C-2)*
- **AC-3** `unbuilt` joins `exhausted` and `drift` as the runner's halt kinds in the two
  places that teach the vocabulary: `implement/SKILL.md`, which tells a session which
  kinds are not its to raise, and `NEW_PIPELINE_IDEA.md`'s halt list. *(C-2)*
- **AC-4** The runner suite exercises a session that sets `review` and commits nothing,
  and the stub can be told to behave that way. *(C-3)*
- **AC-5** A rework pass, which commits again on an earlier commit, does not halt.
  *(C-1)*
- **AC-6** The runner refuses to start in a repository with no commits, where `HEAD`
  cannot be read and the check would otherwise pass by accident. *(C-1)*

## Edge cases

- **A session that commits nothing but does commit** — an empty commit moves `HEAD`, so
  this passes the check. That is the intent's open question, and the answer is that it is
  a different failure: the diff is empty and `/critique` is looking at it, which is the
  party whose job that is.
- **A rework pass that changes nothing** — a review sent the ticket back, the session
  decided the finding was wrong and committed nothing. `HEAD` has not moved since *that*
  session started, so it halts as `unbuilt`. Correct: disagreeing with a review is an
  `undecided` halt, not a silent no-op.
- **A repository with no commits** — `git rev-parse HEAD` fails, and with no `set -e` the
  recorded value would be empty, after which any commit counts as movement and the check
  passes by accident. The runner does not refuse this today: `--is-inside-work-tree`
  succeeds in a commitless repository and the branch check matches neither `main` nor
  `master`, so the run proceeds. AC-6 closes it, because a check that fails open is worse
  than no check.

## Non-goals

- Judging the commit. `/critique` runs next and owns that.
- Catching a session that commits someone else's work, or writes a false `## Record`.
  Different untruths, both `/critique`'s.
- The other findings ticket 7 recorded unfixed.

## Accepted tradeoffs

- **`SOLUTION_NEW_PIPELINE.md` and ticket 7 will say the runner has two halt kinds when
  it has three.** Their `AC-7` lists `exhausted` and `drift`, and ticket 7 quotes it
  verbatim. Editing the solution without editing the ticket makes the next run of
  `tickets/new-pipeline` halt on `drift`; editing the ticket breaks the rule that a
  committed ticket is immutable, because its words are what the code was built against.
  So both stay as they are, wrong about a vocabulary that grew after they were written,
  and the two places a reader is actually taught the kinds are correct.

- **A sixth halt kind.** The vocabulary is the thing a person reads when a run stops, and
  each addition costs a little of what makes it readable. Bought: a stop that says what
  happened instead of `exhausted`, which would say the budget ran out when the budget was
  not the problem.
- **It proves a commit happened, not that the commit is the work.** A session that
  commits an unrelated file passes. That is deliberate — the next thing that runs is a
  review of exactly that diff.

## Ruled out

- **Retry it as an ordinary failed attempt, with no halt kind of its own.** Smaller: the
  behaviour already exists for a crashed session, and nothing new is added to the
  vocabulary. It loses on C-2, and only there: the ticket would end at `exhausted`,
  telling the person the budget ran out when the truth is that a session claimed work it
  had not done.

  Retrying itself was never the objection, and an earlier draft of this section said
  otherwise. `/verify` caught it: the two questions are independent, and the answer taken
  is both — retry as a crash is retried, then halt as `unbuilt` when the budget is spent.
  The ratifier settled it, because the intent's constraints were silent.
- **Have the session write its commit sha into the `## Record`, and verify it.** Ties the
  claim to a specific commit rather than to any movement, which is strictly more
  information. It loses on the intent's first constraint: it asks the party under
  suspicion to supply the evidence, and a session that did not commit can write a sha
  belonging to work someone else did.

## Open concerns

- Nothing in the runner distinguishes a session that committed the ticket file alone from
  one that committed code. The check passes for a session that wrote only its own
  `## Record`.

  Left open deliberately, and not for the reason this section first gave. `/verify`
  pointed out that catching it needs the file list rather than the diff's contents, so
  the "that is the review's" argument does not hold. Put to the ratifier, who chose
  movement alone: the runner does not ask what moved. It is now a constraint in the
  intent rather than an unexamined boundary here.
