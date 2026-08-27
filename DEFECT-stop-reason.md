# Defect: a run that ends badly does not say why

**Repository:** `~/Projects/skills` (Jorgen's agent skills)
**File:** `loop.sh` — `report()` (l. 707) and `finish_run()` (l. 727)
**Tests:** `tests/run.sh`, fixtures in `tests/fixtures/`, stub in `tests/stub-claude`
**Severity:** the run's whole closing brief is wrong for the reader it exists for.
No data loss, no bad commit — the loop stops correctly. It just does not say
what it stopped on.

---

## One sentence

`loop.sh` knows exactly why a run ended where it did, prints that reason to
**stderr as a bare `!!` line above the report box**, and then never puts it in
the box or in the `/handover` prompt — so the closing brief names a *state* and
never a *cause*, and on two of the four non-clean paths the cause is
unrecoverable from the report.

---

## What happened

A real run, `2026-08-27`, on `~/Projects/drk-barmbek/kh`, branch `zugang`.
Transcripts: `~/.local/state/loop/zugang-20260827-005910-136048/`.

The run built nine tickets, ran the acceptance, ran `/critique` twice, and
stopped. What the user saw:

```
── the run ──────────────────────────────────────────────
state: requires human review
acceptance: VERDICT: 0 gaps filed, 2 gaps reported, 0 standing disagreements, 22 criteria checked on evidence
review: VERDICT: 0 blockers, 1 should-fix, 2 nits, 0 standing disagreements
```

Read that on its own terms: **zero blockers, zero standing disagreements,
zero gaps filed** — and yet a state that says a human must rule on something.
The two lines contradict each other, and nothing in the box resolves them. The
user's question was, verbatim: *"the description I see does not tell me what I
need to review. What is it?"*

The actual cause: `critique-2` filed one should-fix as
`docs/spec/tickets/10-loese-die-absage-kollision-in-js-app-auf.md`, and there is
no build pass after the second review to build it. The loop refuses — correctly,
and by explicit design (`loop.sh:864-865`) — to report unbuilt work as a
delivered feature. So it stopped.

**Nothing needed a human decision.** Ticket 10 is a comment-only prose fix. The
correct response was to re-run `loop.sh`, which drains ticket 10 and re-checks.
The user could not know that from the report.

---

## Why

### 1. The reason is echoed to stderr, outside the box, and never captured

`loop.sh:866-867`:

```bash
if next_ticket >/dev/null; then
  # Filed by the last read, with nothing after it to build them. Unbuilt work
  # reported as a delivered feature is the one failure this must not produce.
  echo "!! the review filed work on its second read, and nothing builds it" >&2
  finish_run "requires human review" "$verdict"
  exit 1
```

The `!!` line is a one-line side-effect on the *other stream*, printed *before*
`report()` draws its box. In a long unattended run it has scrolled past by the
time anyone reads the ending; if stderr and stdout are separated at all, it is
gone. `finish_run` receives `state` and `verdict` and nothing else — the string
that explains the stop is dropped on the floor at the exact moment it is known.

### 2. `report()` has no slot for a reason

`loop.sh:707-723`:

```bash
report() {
  local state="$1" verdict="$2" entries
  entries="$(run_entries)"
  echo
  echo "── the run ──────────────────────────────────────────────"
  echo "state: $state"
  [ -z "$CHECK_VERDICT" ] || echo "acceptance: $CHECK_VERDICT"
  [ -z "$verdict" ] || echo "review: $verdict"
  ...
```

Three lines: the state, and two verdict counts. The verdicts answer *what the
checks found*. Nothing answers *why this run stopped* — and for the whole class
of stops that are structural rather than a finding, those are different
questions with different answers.

### 3. `/handover` is told the state and not the cause

`loop.sh:737-739`:

```bash
  run_step handover "handover" \
    "$(printf "/handover %s\nThe run's state: %s. Write the pull request description for it.\n" \
       "$SPEC_DIR" "$state")" "$BRIEF_FILTER" \
```

The handover agent gets the literal string `requires human review` and no more.
In this run it re-derived ticket 10 on its own by reading the tickets directory
and did mention it — but as the closing item of a section titled *"Was offen
steht"*, one bullet among five under *"Wo das noch falsch sein kann"*. It read
as an aside, not as *this is what stopped the run.* That was luck, not design:
the agent was never told there was a cause to find, so nothing makes it look.

`report()`'s own header comment (l. 645-649) states the intent that is broken
here — *"what state the run reached, what every build recorded, what the review
counted"* — the cause is simply not in that list, on either half of the brief.

---

## Blast radius — every non-clean exit

| line | state | reason echoed at | recoverable from the box? |
|---|---|---|---|
| 761 | `halted` | l. 534 / 540-541 / 550-557 (stderr block) | **no** |
| 822 | `requires human review` | l. 821 (stderr) | **no** |
| 867 | `requires human review` | l. 866 (stderr) | **no** — this run |
| 870 | `requires human review` | carried in the `verdict` slot | yes |
| 873 | `requires human review` | implied by the verdict counts | partly — if it fired on `check_stands` the *review* verdict reads clean and only the `acceptance:` line hints |

Three of five lose it outright. All five lose it for `/handover`.

Note l. 870 already does the right thing by smuggling the reason into the
`verdict` argument (`"no verdict line - the review did not say"`). That is the
shape the other paths need, done properly rather than by overloading a field.

---

## Required behaviour

1. Every path that ends a run records **why**, at the point that knows it.
2. `report()` prints that reason **inside the box**, adjacent to `state:`, so a
   reader who sees `state: requires human review` immediately sees what for.
3. The `/handover` prompt carries the reason, so the PR description leads with
   what stopped the run instead of re-deriving it if it happens to look.
4. A clean run prints no reason line at all.
5. Existing output — the three verdict lines, the log path, `run_entries`, the
   trailing next-command block — is unchanged. This adds; it does not rearrange.

---

## Suggested shape (recommended, not mandated)

Follow the file's existing idiom: `CHECK_VERDICT` (l. 705) is already a global
set at the point of knowledge and read by `report()`. Do the same rather than
threading a third positional through `finish_run`, which would force
`finish_run halted "" "$reason"` at l. 761.

```bash
# Why a run ended where it did, set at the point that knows it. `state:` names
# the ending, this names the cause - and without it the box can read clean while
# the run is not. Read by both halves of the closing brief: the report below,
# and the /handover prompt, which otherwise gets the state and nothing else.
STOP_REASON=""

# Says it once and keeps it, because the reader of a stderr line mid-run and the
# reader of the box at the end are not the same person.
stop_because() {
  STOP_REASON="$1"
  echo "!! $1" >&2
}
```

Then replace the bare `echo "!! ..." >&2` at l. 821 and l. 866 with
`stop_because "..."`; set `STOP_REASON` alongside the multi-line stderr blocks
in `drain` (l. 534, 550) with a one-line summary; and in `report()`:

```bash
  echo "state: $state"
  [ -z "$STOP_REASON" ] || echo "because: $STOP_REASON"
```

and in `finish_run`'s prompt:

```bash
    "$(printf "/handover %s\nThe run's state: %s%s. Write the pull request description for it.\n" \
       "$SPEC_DIR" "$state" "${STOP_REASON:+ - $STOP_REASON}")" "$BRIEF_FILTER" \
```

Word the reason so it survives on its own: the reader has no other context.
`the review filed ticket 10 on its second read, and no pass is left to build it`
is a reason; `filed work on its second read` is a fragment of one.

---

## How to test — TDD, and the harness is already there

`tests/run.sh` builds a throwaway repo per case, puts `tests/stub-claude` on
`PATH` as `claude`, and drives `loop.sh` against a `plan` file — one line per
expected call: `<fixture> <exit-code> <action>`. `drive` captures **stdout and
stderr combined** (l. 84, `2>&1`), so `expect_out` alone cannot prove this
defect fixed: the `!!` line already matches. Two assertions that can:

- **`expect_order "state:" "<reason>"`** — proves the reason is *inside* the box
  rather than only above it. Fails today, because the `!!` at l. 866 prints
  before `report()` draws anything.
- **`expect_prompt handover "<reason>"`** — proves `/handover` was told. Fails
  today outright. This is the stronger of the two.

There is **no existing case for the l. 866 path** (`grep "second read"
tests/run.sh` → the only hit is l. 535, an unrelated case about scope
narrowing). Write it. The `file` action in `stub-claude` writes a fresh `todo`
ticket into the directory the prompt names, which is exactly what a review that
filed something does:

```bash
workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 record
checked.jsonl 0 -
reviewed.jsonl 0 file
clean.jsonl 0 done
reviewed.jsonl 0 file
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "work filed by the second read with nothing to build it ends the run"
expect_out "state: requires human review" "it says which ending"
expect_order "state:" "nothing builds it" "and the box says why, not just stderr above it"
expect_prompt handover "nothing builds it" "the handover is told the cause, not only the state"
```

Verify the plan against the real call sequence before relying on it — check
`reviewed.jsonl`'s verdict (`0 blockers, 0 should-fix, 2 nits, 0 standing
disagreements`) still routes the way the case needs.

Then add the same two assertions to the existing cases at **l. 433** (blockers),
**l. 446** (standing disagreement), **l. 471** (acceptance standing), and the
halt case at **l. 419**, and cover the `MAX_PASSES` exhaustion path at l. 821-822
if it has no case either. Run `tests/run.sh` — the whole suite, not the new case
alone.

---

## Out of scope

- **Do not change when the loop stops.** Every one of these paths halts for a
  good reason, argued in the comment above it. This is about what it *says*, not
  what it *does*. No control flow changes.
- **Do not rename the `requires human review` state.** It is a fair observation
  that the l. 866 stop needs no human *judgement* — only another pass — and that
  the state name overstates it. That is a design question for Jorgen, worth
  raising in the ticket or in `IDEAS.md`, not decided here. The string is
  asserted in at least four test cases.
- **Do not touch `run_entries`, `verdict_line`, `VERDICT_RE`, or
  `CHECK_VERDICT_RE`.** They are not implicated.
- **Do not change the `/handover` skill.** The defect is that the driver does not
  tell it enough. The skill is fine.

## Conventions to respect

- The repo commits with a scope-free subject in its own imperative voice —
  read `git log --oneline` before writing one.
- `loop.sh` comments explain *why*, at length, above the thing they justify.
  Match that; a bare `# set the reason` would be out of place in this file.
- Plain bash, no new dependencies. The repo's stated position is that a repo of
  Markdown skills and two scripts should not need a test framework.
