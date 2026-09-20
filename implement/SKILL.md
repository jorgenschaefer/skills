---
name: implement
description: Build one ticket end to end - its criteria driven out test-first, the project's checks green, the evidence written back into the ticket, one commit. Fires on "/implement", "build this ticket", and whenever a runner or another skill hands you a ticket path.
---

# Implement

One ticket. The ticket is the whole brief: it carries its criteria quoted from the solution, and everything you need to build them without opening anything upstream.

`coding-standard` is what the code has to look like, and it applies here as it applies anywhere code is written. `software-design` is for a change that moves a seam. What follows is only what is different about building under a ticket.

## Before you start

**The ticket's `Done when` is the definition of done.** Not the diff, not what you would have built, not what the solution probably meant. If the criteria are not enough to build from, that is a `blocked` halt, not a gap to fill with judgement.

**Never open the solution.** The ticket quotes what it needs; the quotation is deliberate, and going upstream for context is how a ticket quietly becomes a different ticket. If the ticket does not say enough, it is the ticket that is wrong.

**Respect the ticket's `## Not here`.** It names the adjacent thing another slice owns, and building it is not generosity - it is two tickets building the same code, and a commit that claims one criterion while carrying another's work.

**Find the project's verification command** - the one that runs the tests, the types and the linter. Where there is none, run what exists and say so in the `Record`.

## Build it, test first

Kent Beck's red/green/refactor loop, in the smallest steps that make sense. Each phase is a separate test run; bundling "write the test and the code, then run once" is not TDD even when the artifacts end up identical, because the RED run is the only thing that proves the test exercises the behaviour.

1. **RED.** One trivially small failing test for the next bit of behaviour. Run it, and confirm **the assertion fires and reports an expected/actual mismatch**. "Module not found", an import error or a syntax error is not RED - it only proves the test could not run. Add the minimal scaffolding until the assertion itself fails, then go on. If the test passes immediately, you wrote the code first: revert it, get the failure, re-implement.
2. **GREEN.** The simplest change that could possibly work. Faking the answer with a constant is fine; the next test forces the general case. If you cannot see a small change that passes, the test is too big - revert and write a smaller one.
3. **REFACTOR.** Tests green, no new behaviour, remove duplication. Most cycles this is empty. Do not manufacture work to fill it.

## Prove the contract before you hand it over

For every criterion the ticket claims, **name the test that fails without it**. Where you wrote a RED run, that run is the proof and you already have it. Where you did not - the behaviour turned out to exist, or something you did not write covers it - break the behaviour, watch the named test fail, and restore it. Deciding by eye whether a test *would* notice a change is prediction; this executes it.

**Break it twice: remove the behaviour, and move its edge.** A test can notice a behaviour vanish and still pass when a comparison shifts by one. Take the edges - either side of each comparison, the empty case, the single-element case - move one in the code, and watch the named test fail there too.

A criterion whose test you cannot name, or whose test still passes with the behaviour removed or its edge moved, is unbuilt work: write that test now, RED first. A criterion nothing can pin is a `blocked` halt, not a line to write around.

## Halt rather than improvise

A session that cannot proceed writes the halt into the ticket and stops. The kinds are yours to raise:

- **`blocked`** - a precondition the ticket assumed is not there.
- **`undecided`** - a decision the ticket's criteria and the project's standards do not settle, and that is not yours to settle either. A tradeoff nobody accepted is not a detail.
- **`mystery`** - a failure you cannot explain, which is different from one you cannot fix. Say what you observed and what you ruled out.

`exhausted` and `drift` are not yours. A session that has run out of attempts is not running to report it, and a session never reads the solution, so it cannot know the ticket has drifted from one.

**The pull is to work around it.** A missing precondition looks like five minutes of work, and often is - and then the ticket has built something nobody specified, in a commit that claims to build something else. Stop.

## Do not reopen the solution

You will see a better approach than the one the ticket implements. Sometimes you will be right. It is still not this session's decision: the approach was chosen with someone, against constraints you cannot see from here, and changing it in the build is how a pipeline stops converging.

Where it is genuinely wrong rather than merely different, that is an `undecided` halt with what you saw. Where it is a smaller thing than that, `IDEAS.md` is the parking lot.

## Finish

**One ticket, one unit of work.** Commit when the criteria are green and the verification command passes - the code and the ticket file together, so the evidence and the work it describes arrive as one change. Stage the files this ticket touched and nothing else; never `git add -A`.

**Write the ticket's `## Record`**: which test names which criterion, and the verification command you ran. It is the only evidence that a criterion was covered rather than claimed, and the acceptance stage reads it.

**On a second pass, the ticket's `## Findings` is the brief.** A review sent it back; fix what it found, RED first like anything else, and leave the criteria alone - a finding is not a licence to reopen what the ticket asks for. The rework is another commit. The ticket is the unit of work, not the commit.

**Set `status: review`, or `status: halted`.** Never `status: done`, and never claim a ticket by writing `status: doing` - the runner owns both ends. A session that marks its own work finished has reviewed itself by omission.

**You do not review your own work.** `/critique` reads the commit against the ticket, in a session that did not write it, because a reviewer that has already accepted every step of the reasoning is not a reviewer.
