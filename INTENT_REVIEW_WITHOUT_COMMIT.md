# Intent: a ticket can reach done with nothing built

## Problem

A build session says it has finished by writing `status: review` into its ticket. The
runner takes that at face value: it launches the review, and on a clean verdict writes
`done`.

Nothing checks that the session committed anything. A session that sets the status and
exits - because it ran out of context, because it misread its own instructions, because
it decided the work was already there - hands the reviewer the tree as it was. The
review has nothing to find, comes back clean, and the runner marks the ticket done. The
next ticket starts, its dependency satisfied by work that does not exist.

What makes this worth fixing rather than watching for is that every downstream check
inherits the lie and none of them can see it. `/critique` reviews a diff it was not told
to expect; the ticket's `## Record` describes tests for behaviour nobody wrote; and
`/accept` reads that Record as evidence a criterion was built. The one artifact that
would give it away - an unchanged `HEAD` - is visible only to the process that launched
the session, and that process is not looking.

## Evidence

- `run.sh` accepts `status: review` from a session with no further check; the only
  thing it looks at afterwards is whether `## Findings` appeared.
- `slice/SLICE_FORMAT.md` defines the status as what a session writes "when it has
  committed", so the format already claims the property the runner does not verify.
- Ticket 7's review found it and recorded it unfixed: "The runner still trusts
  `status: review` without checking a commit happened."
- The same review found the test stub always commits when it sets `review`, so the
  entire runner suite - 29 cases - has never exercised a session that does not.
- `loop.sh`, the driver being retired, took `git rev-parse HEAD` before each session
  for this reason.

## Done when

- **C-1** A session that sets `status: review` without committing does not reach
  `done`. Checkable by running one that does exactly that.
- **C-2** What happens instead is named and addressed to a person, in the ticket, in
  the same vocabulary as every other way a run stops - not a bare failure.
- **C-3** The runner suite exercises a session that claims to have built and did not.
  Today no case does.

## Constraints

- **The check belongs outside the session.** A session cannot be asked to prove it
  committed; that is the same party's word for the same claim.
- **No new dependency, plain bash**, like the rest of the harness.
- **It must not refuse legitimate work.** A rework pass commits again on top of an
  earlier one, and a ticket built in two commits is normal.
- **A session that misreports gets the same tolerance as one that crashes.** Retry it
  within the attempt budget; the budget is what bounds it. Added 2026-09-21, after
  `/verify` found the approach gave this one failure no retries and the constraints were
  silent on whether it should.
- **Movement is enough; the runner does not ask what moved.** Whether the commit touches
  anything beyond the ticket file is not its question. Added 2026-09-21, same interrupt:
  the boundary stays where `Not this` drew it, even though checking the file list would
  not have meant reading the diff.
- **Off limits: changing what a session writes.** `review` and `halted` are the two
  ends a session owns, and this is about what the runner does with them.

## Not this

- Whether the commit is any good. That is `/critique`'s, and it runs after.
- A session that lies in its `## Record` about which test pins what. Also `/critique`'s,
  and a different kind of untruth.
- The other things ticket 7 recorded unfixed - the usage-limit predicate, the
  unrecoverable failures. Separate problems, separate answers.

## Whatever they arrived with

Nothing. Found by the review of ticket 7 and recorded rather than fixed, because it was
outside that ticket's criteria.

## Open questions

- Is an empty commit - a session that commits nothing but does commit - the same
  failure or a different one?

## Ratified

2026-09-21, by Jorgen Schäfer, on the evidence — the format already claims the property
the runner does not check, ticket 7's review found it and left it unfixed, and the test
stub always commits, so no case in the runner suite has ever exercised a session that
does not.

## Routed back

Nothing yet.
