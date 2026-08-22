# Close the holes that push work to the end of a run

## Context

Two full `loop.sh` runs finished with most of their tickets filed by the reviews
rather than by `/plan`:

- **`kh-finder`** (`spec-dokumentbestand`): 15 tickets — 4 planned, 11 filed by
  `/trace` and `/critique`.
- **`everlast-notebooklm`** (`notebooklm-mvp` → `finalize`): 29 tickets — 13
  planned, 16 filed by the reviews, and **it has not converged**. Ticket 29 is
  `todo` and uncommitted as of this morning, the loop has been restarted five
  times under two branch names, and the last three `/critique` passes reviewed a
  **test-only** diff.

Read against the tickets and the review transcripts in
`/tmp/loop-spec-dokumentbestand-*` and `/tmp/loop-notebooklm-mvp-*` /
`/tmp/loop-finalize-*`, the late tickets are six causes, not one. Four are the
pipeline's fault and are what this plan fixes.

### Confirmed in both projects

**`/implement`'s completion rule is scoped to the wrong thing.** `implement/SKILL.md:71`
says the ticket is done when *"every behavior it adds"* traces to a red-first
test. The ticket's contract is the criteria it **claims**. US-1.5's abort already
existed in `pdf_parse.py` when kh-finder's ticket 02 claimed it; US-9.3's comment
was rewritten as a side effect of ticket 01. Nothing was "added", so nothing had
to be pinned, and both closed green. Everlast's tickets 14, 15 and 20 are the
same class over CI config and a hook. `REVIEWS=full` in both runs — the quality
review ran and missed it, over a kh-finder ticket claiming 19 criteria.
→ **kh-finder 05, 06, 07, 08, 09; everlast 14, 15, 20.**

**`/plan` told the implementer not to test.** kh-finder ticket 04's `Verification`
reads *"Kein Test. Die Kriterien sind Aussagen über Prosa."* `/trace`'s rule is
the opposite. The implementer argued in its `Record` that it reads as "kein Test
*nötig*, nicht als Verbot", pinned US-10.1, left the rest — which came back as
tickets 06 and 07. Everlast repeats it over `ARCHITECTURE.md` (US-12.2) and a
README test count. Two skills in the same pipeline contradict each other.
→ **kh-finder 06, 07, 08; everlast 18, 21.**

### kh-finder only

**A quantified constraint nobody enumerated.** `C-2` — *"bei jeder Unklarheit
abbrechen und die Stelle nennen"* — covers a set with no list. `plan/SKILL.md:45`
requires a constraint be claimed by *at least* one ticket; C-2 was claimed by
four and therefore by none. The abort conditions no *story* named belonged to no
ticket. The implementers knew: ticket 11 wrote *"der Fall gehört damit derzeit
niemandem, obwohl C-2 ihn meint"*, ticket 10 handed the section level away, and
ticket 04 invented a section header by hand — *"Gemeldet, nicht hier
geschlossen"* — for two more. Those land in `Record`, which only `/handover`
reads, so `/trace` rediscovered them a pass later.
→ **10, 11, 14.**

### everlast only — and this is the one that has not stopped

**A check-checking-a-check regress.** Ticket 25 built an owner-filter scanner
over `notebookStore.ts`. Ticket 27 found the scanner blind to `$executeRaw`.
Ticket 29 found it blind to a nested `deleteMany:` *and* found that ticket 27's
rewritten comment now falsely claims both doors are shut. All three say in bold
that no user is exposed and the module is correct as it stands. The current nit
list names the next candidates. Each step is filed by the reviewer the previous
step's ticket was not filed by, and each overturns the previous ticket's
`Unresolved` adjudication.
→ **27, 29, and an open queue.**

**A refactor deleted coverage and the suite stayed green.** Ticket 26
consolidated two caller test suites into one protocol test. Ticket 28's finding:
*"The coverage existed before this run and does not exist after it."* Deleting a
test never turns anything red, and no skill says to look. kh-finder's `trace-2`
did look — *"Kein Test gelöscht oder abgeschwächt (`test_merge.py` 54→63 … keine
entfernte `def test`/`it(`)"* — but as one pass's own initiative, not as a rule.
→ **28.**

**A remediation ticket that fixed half a criterion.** US-0.1 has two halves — the
gate that blocks a red deploy, and the throwaway database the suite runs against.
Ticket 14 pinned the half `/trace`'s mutation happened to demonstrate. Ticket 15
pinned the other half a pass later.
→ **15.**

### Not the pipeline's fault, and left alone

everlast 16, 17, 19, 23 (duplication found once the copies existed), 24 (the
sign-in tests poison their own database on the eleventh run), kh-finder 12, 13
(vocabulary), kh-finder 15 (a defect in ticket 14's own fix, caught by
`/critique` after `/trace` exactly as designed). This is the yield the reviews
exist for. A consolidation found after three real copies exist is found at the
right time; `/plan` guessing the shared hook before any caller exists would
produce the same fallout with less evidence.

Intended outcome: kh-finder's feature runs at roughly 4 planned + 3 found;
everlast's regress terminates instead of queueing.

Out of scope: ticket-sizing rules, and IDEAS.md #10's per-ticket mutation
tooling. #10 stays ranked where it is; edit 1 covers its cheap half without
lifting the tooling ban.

---

## Edit 1 — scope `/implement`'s completion rule to criteria claimed

**`implement/SKILL.md:71`**, the opening line of *Build it*. Replace "every
behavior it adds traces to a test that failed first" with a rule over the
ticket's `Satisfies` list:

- For each id in `Satisfies`, name the test that pins it.
- Where this ticket wrote a RED run for it, that run **is** the proof — nothing
  further.
- Where it did not, because the behavior was already there or arrived as a side
  effect, break the behavior, watch that named test fail, restore. A criterion
  you cannot make fail is unpinned, and the ticket is not done.

Cost is proportional to the gap and is normally zero. On kh-finder it would have
been five deliberate breaks.

**`implement/SKILL.md:123`**, the quality review: it already asks the right
question per criterion but adjudicates it by reading. Add that the pre-existing
case is the one it must not judge by eye — hand it the criteria whose behavior
the ticket did not add and have it confirm the break-and-fail actually happened.

**`implement/SKILL.md:152`**, *Finish*: add the per-criterion pin to the
conditions for committing, alongside "both reviews clean, full suite green".

Wording only, in the surrounding register. There is no test harness for skill
prose — the check is the next real run.

## Edit 2 — a `Verification` section may narrow how a criterion is pinned, never say it isn't

**All five `TICKET_FORMAT.md` copies**, section *Verification, only where it
isn't obvious* (`:88-90`). Today it lists "an EARS constraint with no natural
unit test" as a legitimate case, which is what licensed *"Kein Test."*

State the floor: this section says **how** a criterion is pinned when the
criterion doesn't imply its own test — a text assertion over a README or
glossary, an integration-level test, which of two candidate tickets owns it. It
never says a criterion goes unpinned. A criterion nothing can pin is a discovery
defect and a `blocked` halt, not an implementer's problem.

Name the non-code case explicitly, since five of the late tickets across the two
projects were criteria over prose or config — a README, a glossary, a module
comment, `ARCHITECTURE.md`, a GitHub workflow. kh-finder already had
`glossar.test.js` sitting there and everlast's tickets 14 and 21 show the same
shape over YAML and Markdown: pinned by asserting on the file's text.

Check the `## Verification` line in the worked example (`:160`) still reads true.

**The five copies are byte-identical by design** (`md5sum` today:
`6c917e3cea4c9ca727954359dff7076b`) — `diff` is the parity check, and cross-skill
relative paths break on independent install. Apply once and copy.

## Edit 3 — make a quantified constraint enumerate or go back

**`plan/SKILL.md:45`**, the bullet *Every criterion is claimed by exactly one
ticket*. Its constraint clause — "claimed by *at least* one ticket" — is what
spread C-2 across four tickets and therefore none. Add the distinction:

- A constraint naming **one** property (a latency budget, a retry rule) is claimed
  by at least one ticket, unchanged.
- A constraint quantifying over a **set** — *every* abort condition, *every*
  input, *every* seam — is not claimable until the set is enumerated. Enumerate it
  against the real code and either assign each member to a ticket or write one
  ticket that owns the class with the list in it.

`/plan` already reads the codebase for the structures the spec names, so the
enumeration is work it is set up to do. Fold the check into the review pass's
three existing checks near `plan/SKILL.md:88`.

**`discovery/SPEC_FORMAT.md:22` and the worked example at `:70`.** Same defect one
step upstream. The format's own example is right (*"Verified by an integration
test with the service stubbed to fail"* — future, passive), but the kh-finder spec
wrote `_Verified: pdf_parse.py importiert nur die Standardbibliothek_` and *"wie
in tools/test_merge.py **bereits angelegt**"* — assertions of present fact, false
for C-1 and partial for C-2, that everyone downstream read as settled. Sharpen
the format line to say the clause names the check that **will** exist, never
claims one already does, and add the matching sentence to `discovery/SKILL.md:49`.

## Edit 4 — route an implementer's out-of-scope gap to `/trace`

The implementer never gains the power to add work, and `/trace` keeps ownership
of gap-filing. What changes is that the note lands somewhere `/trace` looks.

**All five `TICKET_FORMAT.md` copies**, section *What `/implement` appends*
(`:102-126`). Add a third `Record` subsection beside `Decisions` and
`Unresolved` — a gap found while building and deliberately not closed here
because `Out of scope` says so. kh-finder's ticket 04 already wrote this section
by hand under its own heading, which is the evidence it belongs in the format.
Same convention as its siblings: absent when empty, never a "none". An entry
carries what is wrong, where, and which criterion or constraint the writer thinks
covers it.

**`trace/SKILL.md:24`**, *What to check*. It reads the spec and the full diff; add
the `done` tickets' `Record` sections. Frame an entry as a **lead, not a verdict**
— `/trace` still verifies it adversarially and decides whether it is a gap,
exactly as for anything it finds itself.

**`loop.sh`**, `trace_prompt()` (~`:394`). One line telling the pass to read the
`Record` of each ticket built since the last checkpoint. It fits the existing
scoping paragraph, which already narrows a later pass to the commits since
`CHECKED_AT`.

**`tests/run.sh`** — TDD, and the harness exists. `expect_prompt` and `prompt_for`
(`:97-101`) assert on prompt content, and `:318-319` already assert the trace and
critique prompts name the ticket directory. Write the failing
`expect_prompt /trace <record wording>` case first, watch it fail, then change
`loop.sh`.

## Edit 5 — grade a finding about a check by what it lets through today

**`critique/SKILL.md:43`**, the severity paragraph. It already says *"assign it by
what happens if nobody fixes this"* — the regress happened because a hole in a
guard was scored by what a future edit might slip past it rather than by what the
product lets through now. Add the distinction:

- A finding about **production behavior** keeps its severity, unchanged.
- A finding about a **test or a check** is graded by what the product actually
  lets through today. A door nobody has walked through costs a reader nothing
  until someone writes the code the guard would have caught — that is a nit for
  `/handover` to triage, not a should-fix worth a ticket.

This does not suppress everlast's ticket 25: that was a surviving mutant on a
live owner filter in the module `C-1` rests on, and the product was one edit from
exposure. It reclassifies 27 and 29, both of which open by stating that no user
is exposed and the module is correct as it stands.

One thing not to lose. Ticket 29's real complaint was that ticket 27's rewritten
comment **states something false** — and tickets are deleted at acceptance, so the
comment is what outlives them. A comment that lies is a defect about the code, not
about a check, and keeps its severity. Say so, or the edit trades a regress for a
false comment left in the tree.

## Edit 6 — notice a test that was removed or weakened

Nothing in the pipeline looks, because deleting a test never turns anything red —
which is how everlast's ticket 26 removed coverage that had existed before the run
and shipped green.

**`trace/SKILL.md:26-29`**, *What to check*: add it as a fifth bullet beside every
criterion, constraint, non-goal and untraceable behavior. Over the run's diff, a
test removed, renamed away, or weakened is a finding — the pipeline's whole
guarantee is that behavior stays pinned, and a green suite is not evidence of
that. It is mechanical: removed `it(` / `test(` / `def test_` declarations and
shrunken assertions over the diff. kh-finder's `trace-2` already did exactly this
by hand; this makes it a rule rather than one pass's initiative.

**`implement/SKILL.md:128`**, the code review's two named properties: a third —
any test this ticket removed or weakened, and why that is not a loss of coverage.
Ticket-scoped, it catches the consolidation ticket at the moment it consolidates.

## Edit 7 — a remediation ticket covers the whole criterion

**`trace/SKILL.md`**, the remediation-ticket paragraph in *Output* (`:55`). A
mutation demonstrates one hole; the criterion may have more than one half. Add
that the ticket names the whole criterion and every part of it left unpinned, not
the part the mutation happened to reach. everlast's US-0.1 has two halves — the
gate that blocks a red deploy, and the throwaway database the suite runs against —
and got two tickets a pass apart because ticket 14 fixed only what the mutation
showed.

---

## Files

| File | Edits |
|---|---|
| `implement/SKILL.md` | 1 (`:71`, `:123`, `:152`), 6 (`:128`) |
| `{plan,implement,trace,critique,propose-change}/TICKET_FORMAT.md` | 2, 4 — one edit, five identical copies |
| `plan/SKILL.md` | 3 (`:45`, review pass ~`:88`) |
| `discovery/SPEC_FORMAT.md`, `discovery/SKILL.md` | 3 (`:22`/`:70`, `:49`) |
| `trace/SKILL.md` | 4 (`:24`), 6 (`:26-29`), 7 (`:55`) |
| `critique/SKILL.md` | 5 (`:43`) |
| `loop.sh` | 4 (`trace_prompt`) |
| `tests/run.sh` | 4 — failing case first |
| `IDEAS.md` | note on #10 that edit 1 covers its cheap half without the tooling |

## Verification

1. **Driver tests green:** `tests/run.sh` — the new `/trace` prompt case fails
   before the `loop.sh` edit and passes after; the existing cases (including
   `:318-319`) stay green.
2. **TICKET_FORMAT parity:** `md5sum */TICKET_FORMAT.md` yields exactly one
   distinct hash across all five copies. This is the check the duplication exists
   for.
3. **The contradiction is gone:** `grep -rn "Kein Test\|no test" */TICKET_FORMAT.md
   plan/SKILL.md` finds nothing licensing an unpinned criterion, and
   `trace/SKILL.md`'s "pinned by a test that would fail without it" has no skill
   disagreeing with it.
4. **Read the edits back against both runs.** For each of kh-finder 05–11 and 14,
   and everlast 14, 15, 18, 20, 21, 27, 28 and 29, name which edit would have
   caught it or downgraded it, and where. An edit that catches nothing on that
   list is wrong or wrongly worded. kh-finder 12, 13, 15 and everlast 16, 17, 19,
   23, 24 should still reach the end — they are the yield, not the bulge.
5. **The real check is the next run.** These are prose edits to skills; nothing
   executes them but a live `loop.sh`. Say so plainly rather than reporting them
   verified.

## Commits

Seven, one per edit, in the order above. Stage only each edit's own files; never
`git add -A`. The five `TICKET_FORMAT.md` copies are touched by both edit 2 and
edit 4, so those two commits each carry all five.

## Open, and yours — not in this plan

`MAX_PASSES=2` exists so non-convergence reaches a human, and IDEAS.md's
*Rejected* list defends it: *"Non-convergence is a signal, not a budget problem."*
On everlast the signal fired and was answered by restarting `loop.sh` five times,
twice under a new branch name — which resets the pass count and `CHECKED_AT`.
Edit 5 should stop this particular regress. Whether the driver should notice that
it is being restarted onto an unconverged ticket set is a separate decision, and
it is not one I would make inside this change.
