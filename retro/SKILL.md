---
name: retro
description: Look back over a coding session or a `run.sh` run and change what let it go worse than it should have - the pipeline's skills and runner, or the project it worked in - so the next one does not repeat it. Typed.
disable-model-invocation: true
---

# Retro

You are finding what in the agent's environment let a session go worse than it should have, and changing that so the next session does not repeat it. The environment is the pipeline - the skills in this repository, `CODING_STANDARDS.md`, `run.sh` and its library - and the project the session worked in: its checks, its `run` skill, its docs. The code the session produced is not yours to fix here.

## Read the record

The user names the session or the run; with neither, it is the current session.

- **A `run.sh` run** leaves one stream-json log per session in `<project>/.git/run-logs/` - `<ticket>-<time>.jsonl`, `review-*`, `verify-*` - and a `.tokens` file per change. Its change directory is deleted at acceptance, so read the tickets' `## Halt` and `## Left standing` and `REVIEW.md` from the project's history with `git show <commit>:<path>`. The commits after the run are part of the record: what the person fixed by hand at acceptance or between runs is where the pipeline failed to stand alone.
- **An interactive session** is `~/.claude/projects/<its working directory, / as ->/<session id>.jsonl`.

The logs are too large to read into your context. Write a script into your scratchpad that narrates a log - user text, assistant text, one line per tool call - and one that counts, per session: cost, turns, context read by main session and subagents, context read per kind of tool call, the number of `result` events, and halts and usage-limit waits. Read narration only where the numbers point.

**Find the skills the run read.** A run reads the skills as they were on its date, so `git log --since` in this repository: a finding a later commit already addresses is reported as already fixed, not fixed again.

**Did the last fixes hold?** For every commit here since the previous run on this project that touches what this session exercised, check whether what it fixed happened again. A recurrence comes first in the report, and its fix is a different mechanism from the one that failed: a rule that a reviewer was told to follow and that did not hold is not repaired by saying it again.

Before running anything in the project, check that no run or session is working it - `fuser <project>/.git/run.lock`, and `git status` for work in progress. One analysis that ran the tests to check a fix hit the shared test database under a live build's reviewer.

## Find the moments

- **A person stepped in.** A halt, a question the person had to answer, a fix they made by hand. Each is the pipeline failing at the one thing an unattended run is for.
- **A defect caught late, or not at all.** Name the earliest stage that could have caught it and why it did not. The fix goes there, which is often upstream of where it tripped: a red baseline in a build came from a mockup an earlier stage wrote where the linter reads.
- **A rule that exists and did not hold.** Find why - it was scoped to the first of several choices, or it said to wait without a way of waiting that keeps an unattended session alive. Restating it changes nothing.
- **A rule that held and did harm.** A number that became the target: the 500-line limit met by merging tests and leaving five files at 495-499 lines.
- **Cost.** Where the context read went, by kind of call. What multiplies it is turns taken while the context is already large: reviewers driving the app at 88k a turn spent a third of one run.
- **Searching, missing information, expensive tools.** The agent searched long for something a pointer would have given it, needed something it could not reach - a log, a service - or made calls that returned far more than it used.
- **Interference.** Sessions or agents sharing a checkout, a port, a database or a browser.
- **The unprompted.** Something the agent did that nothing asks for. Bad, it is a finding; good, it is a candidate for writing down, since it will otherwise depend on the next session thinking of it too.

## Every finding rests on an instance

Point at the log line, the commit or the ticket. A failure that could plainly happen but did not is not a finding.

**Try to refute each finding before you report it.** Name what in the record would show it wrong, and look. Test a threshold you want to propose against the other runs in the logs - a file-count limit drawn from one run's outlier correlated at 0.43 across 51 tickets. Check a claim about how Claude Code behaves against its documentation, not memory. Say which numbers you measured and which you estimated.

## Choose where the fix goes

**Pipeline or project.** A failure that would recur in any project is fixed in the pipeline. One that comes from this project - its checks, its way of running the app - is fixed in the project, and changed only when the user asks for it there; otherwise give the wording.

**The strongest mechanism that fits:**

1. **Something that executes.** What has to hold when a session is dead or lying belongs in `run.sh`. A mechanical violation - a pattern, a file location, a criterion a script can measure - gets a check, test or hook in the project. Look for one that exists and is not wired before proposing a new one. Never make a proxy the gate: a check on a number the goal is not about gets the number met and the goal missed.
2. **Something without a stake checks it.** A judgement call goes to the adversary that sees that stage's output: `VERIFY.md`, `critique`, `CODING_STANDARDS.md`. Where a builder can excuse itself with a claim ("it is one part"), make the claim something a reviewer checks.
3. **An instruction** in the stage that produces the output.

Never `CLAUDE.md` for a repeated mistake: it loads into every session and goes stale. Moving or rescoping a rule that exists beats adding one, and deleting a rule that does harm or changes nothing is a fix.

## Report, then stop

Most costly first, by what a recurrence costs: a person's time, then a wrong result, then tokens. For each:

```markdown
### 1. <what to change, as an imperative> — pipeline | project
What happened: <the instance, with its log line, commit or ticket>
Why: <the cause, and why nothing caught it>
Fix: <where, which mechanism, the wording or the check in outline>
Effort: <XS-XL>
```

After them, what is already fixed and by which commit. Then end your turn: the user picks.

## Make the picked changes

One commit per fix, with a body that carries the instance and the numbers to compare against next time, so the next retro can tell whether it held. A change to `run.sh` or its library gets its failing test in `tests/` first; `./test.sh` is green before each commit. A skill's new wording says what the agent does, in the fewest words that keep the reason it needs to generalize.
