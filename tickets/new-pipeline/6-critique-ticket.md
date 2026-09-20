---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-15
after:     5-implement
status:    done
attempts:  1
reviews:   1
---

## Build

Teach `/critique` to review a commit against a ticket and write `## Findings` into it,
without losing the thing it already is.

## Done when

> **AC-15** `/critique`, in a session of its own, reviews each commit against the ticket
> it was built from, and writes what it wants changed into that ticket.

## Context

`/critique` survives this rewrite deliberately: it is the review anyone can run by
hand on any branch or diff, and it must stay usable that way. Taking a ticket is an
additional mode, not a replacement for its existing one.

It reviews against the ticket, never against the solution or the problem. A reviewer
allowed to reopen "is this the right approach" makes the pipeline relitigate every
prior stage.

## Not here

Deciding what happens after findings — counting the round, resetting the status,
enforcing the ceiling — is the runner's, ticket 7.

## Record

`tests/build-contract.sh`, now 15 cases covering both sessions of the loop, invoked by
`tests/run.sh` (256 + 18 + 22 + 32 + 10 + 15, green). Four are new and one was red.

**AC-15's deliverable is `the review writes the ticket's Findings`** — red before the
change, green after.

**The three constraints around it, each tested by breaking it — after the review showed
the first versions could be walked past.** `the review is never told to
read the solution`: appending "Read the `SOLUTION_X.md` the ticket names" fails it.
`the review never sets a status`: appending "Set `status: done` when the review is
clean" fails it. `the review still answers for a branch` guards the direction this
ticket could most easily break — narrowing a skill anyone can run into a pipeline
component.

Written the way the previous ticket's review forced: matching on the sentence, looking
for the imperative, and allowing the skill to *say* what it must not do.

**What the ticket mode adds beyond "review this diff".** The ticket is the standard and
the whole of it — `## Done when` is what the commit had to achieve, `## Not here` is
what it was not allowed to touch, and crossing that line is a finding even when the work
is good. And the `## Record` gets checked rather than trusted: the tests it names must
exist and must fail when the behaviour goes. A Record naming a test that passes with the
behaviour removed is the most serious finding available, because acceptance reads it as
evidence.

**Untested.** Everything the review actually does — whether it finds anything, whether
it refutes its own findings before filing them, whether it checks the Record rather than
reading it. Bash can hold the contract; it cannot hold the judgement.

**Not done here.** The runner reads the verdict and decides what follows — count a
round, set `doing` again, or `exhausted`. Ticket 7.

## Findings

One review round, thirteen findings. Eleven taken.

**I corrupted the header of the file whose job is to stop prose drifting.** A stray
edit turned "declare itself finished" into "declare itself d." in
`tests/build-contract.sh`. Restored, along with a line that still described the suite as
pinning two things when it pins six.

**The skill gave a pipeline caller two answers.** The ticket mode says findings go into
the ticket; a paragraph further down, from the old pipeline, says an unattended caller
gets them written up as separate remediation tickets — naming the same caller. A
reviewer handed a ticket would have had to guess. The old arrangement is now explicitly
scoped as the old arrangement, and named as not being the ticket mode.

**The Record check was not executable.** It told the reviewer to break behaviour, in a
file that says it does not modify code, with nothing saying the break is temporary or
that nothing may be committed — in a session that runs unattended on a branch another
session just committed to. It now says the edits go in the working tree, are put back
before reporting, and are never committed. It also now asks for removal *and* an edge
moved, which is the bar `/implement` was held to; asking the reviewer for less than the
builder made the check weaker than the claim it verifies.

**"The ticket is the standard, and the whole of it" deleted every quality finding**, read
literally — the opposite of the sentence two lines above promising everything in the file
still applies. It is the acceptance standard and the scope boundary; `coding-standard`
remains the quality standard, and a finding tracing to no criterion is still a finding.

**Four of the new cases could be walked past**, in the same families as the last round:
alternate verbs ("consult the solution"), an instruction split across two sentences, a
disclaimer word inside the instructing sentence, and — worst — a legitimate mention of
"the runner" in the skill making `the runner` useless as an exclusion. The deliverable
case was a bare string match, so inverting the instruction to "never write the ticket's
`## Findings`" left it green. All five defeats now fail the suite. `says_to` takes a
file now instead of being copied twice with three different whitelists.

**Two cases could report green about a file that was not there** — no existence guard on
the review side, unlike the build side.

**The repo's own guard caught my vocabulary.** Writing "revert every mutation" tripped
`no skill asks a build or an acceptance to run a mutation testing tool`, which forbids
the word outright in any skill. Blunt, and it worked: the paragraph says what it means
without borrowing the name of a tool this project decided against.

**Recorded, not delivered.** AC-15's "in a session of its own" is not this commit's to
satisfy. `/critique` asserts the premise and cannot cause it; the runner spawns the
session, in ticket 7.
