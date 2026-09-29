# Plan: rework the development pipeline

This replaces `idea → find-solution → plan-solution → run.sh → accept-intent`
with `idea → find-criteria → criteria-to-tickets → /implement or run.sh → accept-criteria`.
There is no backwards compatibility: the old formats and ids go.

## What works today and must survive

- `idea` forces a re-check of what is wanted. It focuses on the actual problem
  instead of the solution brought in.
- Alternative solutions for the actual problem get proposed.
- `run.sh` works across budget limits, so changes can be built overnight.

## The problems

1. **The criteria that get built are never approved.** `idea` shows its
   conditions. `find-solution` writes its criteria into `02-SOLUTION.md` and
   nothing shows them back. The file is too long to read: 212 and 272 lines in
   the two `einsatz` runs. It is also thin on what matters: did it understand
   the intent, does it use the same buttons, does it reuse sensible components.
2. **Criteria emerge through a conversation, not stages.** They are spread
   across Done-when (idea), AC (find-solution) and edge cases settled while
   slicing. In the Seitenleiste run, find-solution amended the intent's C-2 and
   plan-solution amended the solution. No stage ever shows the whole list.
3. **There is no light path.** A trivial change produces half a dozen
   documents and tickets, so the pipeline gets skipped.
4. **The comparison is heavier than needed.** Agreeing on criteria and
   weighing candidates against them was never used. What was needed was each
   alternative's effort and code complexity.
5. **What vs. how.** Product behaviour is to be approved. Implementation choices
   ("reuse the phone components in the sidebar") are only to be *seen*, with
   the option to object.
6. **Big tickets look like the main cost.** Measured over 23 ticket builds in
   `einsatz` (27–29 Sep 2026), counting context tokens read:
   - A small ticket cost 1.0M in the main session plus 0.3M for review.
   - `01-hauptansichten-mit-leiste` cost 102M plus 27M for review over 466
     turns, averaging 218k context per turn.
   - Review subagents are 10–25% of a ticket's cost.

   Cost grows faster than ticket size, because every turn re-reads a growing
   context. Only two tickets were that expensive, and poor context management
   inside those sessions could explain them as well as size does. The token
   log below exists to settle that.
7. **Acceptance needs the user in it.** It should be an interactive session,
   not an unattended walk at the end of `run.sh`.

## Layout

Everything one change produces lives in `intents/YYYY-MM-DD-<slug>/`:

- `CRITERIA.md`
- `specimens/`: the agreed specimen only
- `tickets/NN-<slug>.md`
- `REVIEW.md`: written by run.sh's final review, when it runs

The directory is scaffolding for one change: accept-criteria deletes it at the
end. ADRs outlive the change, so they go where the project keeps its ADRs,
not here.

## The pipeline

```
idea ──(context)──→ find-criteria ──→ CRITERIA.md ──→ criteria-to-tickets ─┬─ 1 ticket  → /implement <ticket>
  ↑                      │                                                  └─ n tickets → run.sh
  └── no problem visible ┘                                                           then: /accept-criteria
```

Invocation:

- `idea` fires by description.
- `find-criteria`, `criteria-to-tickets` and `accept-criteria` are typed (`disable-model-invocation`).

### idea

Gets from the solution the user brought to the problem underneath it.

- **Output:** a problem statement in context, used by `find-criteria` in the
  same session. There is no file and no fixed section list.
- **Keeps:**
  - problem first;
  - one real instance;
  - stating the problem back and getting agreement;
  - the proposed mechanism must not appear in the statement;
  - the reasoned no (already solved, or a symptom of something else).
- **Drops:** Done-when, conditions, constraints and the intent format.
- **Adversary:** fresh context, given the problem statement, the instance and
  the user's original solution as text. It re-derives the problem cold.
- **Handoff:** ends by naming `/find-criteria`.

### find-criteria

Works out acceptance criteria with the user until the user says it is done.
Replaces `find-solution`.

**Input.** Anything: idea's context, a sentence, or a trivial request.
- If no problem statement is in context and none is visible behind the request,
  it runs `/idea` first and continues afterwards.
- For a trivial change where the problem is plain from the request, it states
  the problem in a sentence and gets a yes.
- It does not carry idea's rules itself. The problem-first discipline lives in
  one skill.

**The loop**, one question per turn:
- Works out criteria.
- Reads the codebase first, so that alternatives and their estimates rest on
  what is there.
- Proposes at least three genuinely different alternatives, or says why the
  space holds fewer. Each comes with its effort and code complexity. There is
  no weighting or scoring; the user picks.
- Builds a specimen only when the difference is visual. It is published as a
  Claude Artifact, with a copy in `specimens/`.
- Raises the implementation decisions visible from the approach as nudges.
- Settles every open question. Each one ends up as an AC, a nudge, a ruled-out
  line, or explicitly out of scope. None survives into the file.

**Adversary, before the approval.** Fresh context, given the Problem and the
draft criteria. It checks that:
- the ACs serve the Problem, with none missing and none unasked for;
- each AC can be tested;
- the ACs make sense for users and for good software;
- criteria-to-tickets could slice from the file without asking anything.

**Approval.** When the user says it is done, the full list is shown, with the
adversary's findings already worked in. The approval can send the loop back.

**Output: `CRITERIA.md`.**
- **Problem:** the agreed statement plus the one real instance. It was written
  before the approach was chosen, and it is what accept-criteria judges the
  finished thing against.
- **Acceptance criteria:** `AC-n`, hard, and checked by accept-criteria.
  - Ids are never renumbered or reused.
  - What an idea constraint used to cover ("smartphone stays unchanged") is an AC.
  - Edge cases that matter are ACs.
- **Agreed design:** the chosen approach in a few lines, plus the specimen
  (Artifact link and local copy), marked "agreed; build to this, do not
  redesign".
- **Nudges:** soft implementation guidance, such as "reuse the phone
  components" or "do not touch DeviceView". Nothing checks these, but any
  departure from one is recorded (see the ticket's Record).
- **Ruled out:** one line per rejected alternative and why, so later agents do
  not propose it again.

### criteria-to-tickets

Replaces `plan-solution`. It keeps that skill's `PLANNING.md`, `ADR_FORMAT.md`,
`TICKET_FORMAT.md` (adapted), `VERIFY.md` (the slicing adversary) and its copy
of `CODING_STANDARDS.md`.

**Slicing**
- Slices stay vertical: each can be built and verified on its own.
- Among vertical cuts, session size is the main constraint: a slice that would
  clearly run long is split along a real seam.
- When small and vertical conflict, vertical wins.
- The size rule stays loose (few plan steps, few files) until the token log
  shows where the limit is.

**What it finds while planning.** Planning reads the code, which turns up two
kinds of question:
- **Product questions** (an ambiguous AC, an unowned edge case) are put to the
  user at the approval. The answer is written into `CRITERIA.md` as a new or
  amended AC before any ticket quotes it. An answer that changes the cut goes
  back to `find-criteria`.
- **Implementation decisions** are shown at the approval and not written back.

**Adversary.** It reviews the slicing as text, before any ticket file exists,
the same as today.

**Tickets.** Written after approval, including for a single slice.
- The frontmatter points at `CRITERIA.md`.
- Sections:
  - Build;
  - Done when (ACs quoted word for word);
  - Nudges (quoted word for word);
  - Context;
  - Plan;
  - Not here;
  - Record;
  - Halt.
- The Record has a fixed `### Left standing` subsection for review findings not
  fixed, checks not run, departures from the plan, and **departures from a
  nudge, with the reason**.

**Re-slicing.** The procedure stays as it is today, pointed at `CRITERIA.md`.

**Handoff.** One ticket means `/implement <ticket>`. Several mean `run.sh`.

### run.sh

- **Builds tickets as today:** claims, attempt budget, waiting out usage
  limits, halts.
- **Pre-flight check.** Stays, pointed at `CRITERIA.md`. It checks that every
  quoted AC and nudge still matches the file word for word, and that every AC is
  quoted by some ticket.
- **Token log.** Records tokens per ticket (main session plus subagents) and
  prints a per-ticket summary at the end. It is there to calibrate the size
  rule and to test the context-management explanation from problem 6.
- **Final review**, when there is more than one ticket and none halted:
  - One session over the whole branch diff. It runs through the same
    usage-limit handling as the builds.
  - Purpose: what no single ticket's review can see, such as duplication and
    inconsistency across tickets, and seams that do not line up. Smaller
    tickets make these more likely.
  - The session runs critique, evaluates the findings, fixes what is worth
    fixing and commits, for at most two rounds, the way `/implement` does.
    The session enforces that limit; `run.sh` does not count rounds.
  - It writes what it left standing to `REVIEW.md`.
- **No accept walk.** It ends by printing halts, each ticket's
  `### Left standing` and `REVIEW.md`.

### accept-criteria

Replaces `accept-intent`. It is an interactive session with the user, after
either path.

- The agent drives the running product the way its user would. It walks
  `CRITERIA.md`'s ACs by id, showing what it did and saw so the user can look
  and try along.
- It compares what was built with the agreed design and specimen.
- It holds the whole against the Problem, and says so if the ACs are met but
  the problem is not solved.
- It reads the tickets' Records, including nudge departures, and `REVIEW.md`.
- It reports each AC as met, not met, or could not be checked, plus anything a
  build or the review left standing that the walk did not settle.
- **Once the user accepts**, it deletes the change's directory (`CRITERIA.md`,
  tickets, specimens, `REVIEW.md`) and commits the deletion. What the change
  was for survives in git history and in the commits that built it. If the
  user does not accept, nothing is deleted.

## Removed

- `find-solution`, `plan-solution` and `accept-intent`.
- `INTENT_FORMAT.md`, `SOLUTION_FORMAT.md`, and find-solution's and
  accept-intent's `VERIFY.md`.
- `C-n` condition ids.
- Weighted comparison of candidates.
- The two-document intent/solution split.
- The accept walk in `run.sh`.

## Follow-on

- The README and `test.sh` follow these changes.
- The runner's pre-flight cases are adapted to `CRITERIA.md`, not deleted.
- New cases cover the token log and the final review.
- The no-dangling check covers the renamed skills.
