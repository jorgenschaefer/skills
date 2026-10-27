#!/usr/bin/env bash
#
# The tests for run/drift.sh: the pre-flight that stops a run where the tickets
# and CRITERIA.md no longer agree.
#
#   tests/run/drift.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the drift pre-flight, in both directions
#
# A session never reads CRITERIA.md and a committed ticket is revisited by
# nobody, so this is the only place the two can be found to disagree.

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out"; then
  ok "a ticket whose criterion left CRITERIA.md stops the run"
else bad "a ticket whose criterion left CRITERIA.md stops the run" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "drift stops it before any session"
else bad "drift stops it before any session" "$(calls)"; fi
# The stop is named where a person will look, not only on a terminal nobody is
# watching - which is the whole reason the runner is unattended.
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: the ticket's criterion moved"
else bad "drift is written into the ticket: the ticket's criterion moved" "$(tkt 1-one)"; fi

workspace
sed -i '/^- \*\*AC-2\*\*/a - **AC-3** a third thing happens.' "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out"; then
  ok "a criterion in no ticket stops the run"
else bad "a criterion in no ticket stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: a criterion no ticket quotes"
else bad "drift is written into the ticket: a criterion no ticket quotes" "$(tkt 1-one)"; fi
# Reported once, not once per ticket in the directory.
if [ "$(grep -c 'AC-3 is closed by no ticket' "$WORK/.out")" = 1 ]; then
  ok "an uncovered criterion is reported once, not once per ticket"
else bad "an uncovered criterion is reported once, not once per ticket" "$(out)"; fi

# A criterion that no longer holds is deleted, and its number goes with it: the
# gap is what keeps the number from being handed out twice.
workspace
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/changes/x/CRITERIA.md"
rm "$WORK/changes/x/tickets/1-one.md"
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"
git -C "$WORK" commit -qam delete
plan build
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a criterion deleted from CRITERIA.md leaves a gap, and that is no drift"
else bad "a criterion deleted from CRITERIA.md leaves a gap, and that is no drift" "rc=$rc $(out)"; fi

# Deleting a criterion a ticket still quotes is the upstream edit the check
# exists for, and it says so rather than reporting a mismatch against nothing.
workspace
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/changes/x/CRITERIA.md"
git -C "$WORK" commit -qam delete
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-1 is gone from' "$WORK/.out"; then
  ok "a ticket quoting a deleted criterion stops the run"
else bad "a ticket quoting a deleted criterion stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: its criterion was deleted"
else bad "drift is written into the ticket: its criterion was deleted" "$(tkt 1-one)"; fi

# A criterion can be a list item of several paragraphs: sub-items, a blank
# line, and an indented paragraph that still belongs to it. The ticket quotes
# the blank line as a bare `>`. Both are the same criterion, and the second
# paragraph is part of what is compared.
multi_paragraph() {  # the closing sentence in CRITERIA.md
  perl -0pi -e "s/^- \*\*AC-1\*\* the first thing happens\.\n/- **AC-1** the first thing happens:\n  - one way;\n  - another way.\n\n  $1\n/m" \
    "$WORK/changes/x/CRITERIA.md"
  perl -0pi -e 's/^> \*\*AC-1\*\* the first thing happens\.\n/> **AC-1** the first thing happens:\n> - one way;\n> - another way.\n>\n> It fails otherwise.\n/m' \
    "$WORK/changes/x/tickets/1-one.md"
  commit
}
workspace
multi_paragraph "It fails otherwise."
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a criterion of several paragraphs, quoted as it stands, is no drift"
else bad "a criterion of several paragraphs, quoted as it stands, is no drift" "rc=$rc $(out)"; fi

workspace
multi_paragraph "It fails otherwise, loudly."
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-1 no longer matches' "$WORK/.out"; then
  ok "a criterion's second paragraph reworded is drift"
else bad "a criterion's second paragraph reworded is drift" "rc=$rc $(out)"; fi

# A ticket's `## Done when` goes on after its quotes, in plain words: the part
# of each criterion under `## Toward` this slice makes true. That sentence is
# the ticket's own, and no part of the criterion above it.
workspace
perl -0pi -e 's/^(> \*\*AC-1\*\* the first thing happens\.\n)/$1\nThe first part of it, without filters.\n/m' \
  "$WORK/changes/x/tickets/1-one.md"
commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a sentence after a quoted criterion is not part of it"
else bad "a sentence after a quoted criterion is not part of it" "rc=$rc $(out) $(tkt 1-one)"; fi

# A line of only spaces looks blank and is blank, as it is between quotes.
workspace
perl -0pi -e 's/^(> \*\*AC-1\*\* the first thing happens\.\n)/$1  \nThe first part of it, without filters.\n/m' \
  "$WORK/changes/x/tickets/1-one.md"
commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a line of only spaces after a quoted criterion ends it"
else bad "a line of only spaces after a quoted criterion ends it" "rc=$rc $(out) $(tkt 1-one)"; fi

# A change sliced before the technical decisions were three: four of them,
# and a nudge in CRITERIA.md that the first ticket quotes.
old_shape() {
  local decisions='- **Stored formats** none.\n- **Wire formats** none.\n- **Trust boundaries** none.\n- **Dependencies** none.\n\n## Nudges\n- reuse the list that is already there.\n'
  perl -0pi -e "s/^## Technical decisions\n.*?(?=^## )/## Technical decisions\n$decisions\n/ms" "$WORK/changes/x/CRITERIA.md"
  local f quotes
  for f in "$WORK"/changes/x/tickets/*.md; do
    quotes='> **Stored formats** none.\n\n> **Wire formats** none.\n\n> **Trust boundaries** none.\n\n> **Dependencies** none.\n\n## Nudges\n'
    case "$f" in */1-one.md) quotes+='\n> reuse the list that is already there.\n' ;; esac
    perl -0pi -e "s/^## Technical decisions\n.*?(?=^## )/## Technical decisions\n\n$quotes\n/ms" "$f"
  done
  commit
}

workspace; old_shape
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a change sliced in the old shape, four technical decisions and a nudge, runs"
else bad "a change sliced in the old shape, four technical decisions and a nudge, runs" "rc=$rc $(out)"; fi

workspace; old_shape
sed -i 's/reuse the list that is already there./reuse the list./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: a nudge it quotes is not in' "$WORK/.out" \
   && [ "$(field 1-one status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket whose nudge is not in CRITERIA.md word for word stops the run"
else bad "a ticket whose nudge is not in CRITERIA.md word for word stops the run" "rc=$rc $(out)"; fi

# The technical decisions were approved, and every ticket carries all of them
# word for word: a builder that never saw "none" cannot know that the concept
# it adds is a departure.
workspace
sed -i 's/^> \*\*Concepts\*\* none\./> **Concepts** none yet./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: a technical decision it quotes is not in' "$WORK/.out" \
   && [ "$(field 1-one status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket whose technical decision is not in CRITERIA.md word for word stops the run"
else bad "a ticket whose technical decision is not in CRITERIA.md word for word stops the run" "rc=$rc $(out)"; fi

workspace
sed -i 's/^- \*\*Hard to reverse\*\* none\./- **Hard to reverse** none, beyond the parser./' "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: does not quote a technical decision in' "$WORK/.out" \
   && grep -q '2-two.md: does not quote a technical decision in' "$WORK/.out"; then
  ok "a technical decision a ticket does not quote stops the run"
else bad "a technical decision a ticket does not quote stops the run" "rc=$rc $(out)"; fi

workspace
sed -i 's/^- \*\*Hard to reverse\*\* none\./- **Hard to reverse**\n  none./' "$WORK/changes/x/CRITERIA.md"; commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a technical decision broken over two lines still matches its quote"
else bad "a technical decision broken over two lines still matches its quote" "rc=$rc $(out)"; fi

# A technical decision can be a list item of several paragraphs as a criterion
# can, quoted the same way, with the blank line as a bare `>`.
multi_paragraph_decision() {  # the closing sentence in CRITERIA.md
  perl -0pi -e "s/^- \*\*Hard to reverse\*\* none\.\n/- **Hard to reverse** none:\n  - no data deleted;\n  - no field dropped.\n\n  $1\n/m" \
    "$WORK/changes/x/CRITERIA.md"
  local f
  for f in "$WORK"/changes/x/tickets/*.md; do
    perl -0pi -e 's/^> \*\*Hard to reverse\*\* none\.\n/> **Hard to reverse** none:\n> - no data deleted;\n> - no field dropped.\n>\n> Not a dependency either.\n/m' "$f"
  done
  commit
}
workspace
multi_paragraph_decision "Not a dependency either."
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a technical decision of several paragraphs, quoted as it stands, is no drift"
else bad "a technical decision of several paragraphs, quoted as it stands, is no drift" "rc=$rc $(out)"; fi

workspace
multi_paragraph_decision "Not a dependency either, ever."
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'a technical decision it quotes is not in' "$WORK/.out"; then
  ok "a technical decision's second paragraph reworded is drift"
else bad "a technical decision's second paragraph reworded is drift" "rc=$rc $(out)"; fi

# A quoted decision found early in a long list is found, not lost: under
# pipefail a `grep -q` that stops reading at the match fails the pipe it ends,
# and the runner read that as drift - on whichever items the race picked.
workspace
for i in $(seq 1 2000); do
  printf -- '- **Decision %s** long enough to fill the pipe before the match is read.\n' "$i"
done > "$WORK/.more"
sed -i "/^- \*\*Hard to reverse/r $WORK/.more" "$WORK/changes/x/CRITERIA.md"
for i in $(seq 1 2000); do
  printf -- '\n> **Decision %s** long enough to fill the pipe before the match is read.\n' "$i"
done > "$WORK/.quotes"
for f in "$WORK"/changes/x/tickets/*.md; do
  sed -i "/^> \*\*Hard to reverse/r $WORK/.quotes" "$f"
done
commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a technical decision followed by many others still matches its quote"
else bad "a technical decision followed by many others still matches its quote" "rc=$rc $(out)"; fi

# A change sliced before technical decisions existed has none on either side.
workspace
for f in "$WORK/changes/x/CRITERIA.md" "$WORK"/changes/x/tickets/*.md; do
  perl -0pi -e 's/^## Technical decisions\n.*?(?=^## )//ms' "$f"
done
commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a change with no technical decisions is no drift"
else bad "a change with no technical decisions is no drift" "rc=$rc $(out)"; fi

# --- which ticket closes which criterion
#
# A criterion can take several tickets to build. Exactly one closes it - the
# one after which it is true, and which writes its test - and it comes after
# every ticket that advances it, or the test it writes is red for want of work
# still waiting to run.

workspace
sed -i 's/^closes: .*/closes:/; s/^advances:.*/advances:  AC-2/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-2 is closed by no ticket' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a criterion only advanced, and closed by no ticket, stops the run"
else bad "a criterion only advanced, and closed by no ticket, stops the run" "rc=$rc $(out)"; fi

workspace
ticket 3-three AC-2 "the second thing happens." "1-one"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-2 is closed by more than one ticket: 2-two 3-three' "$WORK/.out" \
   && [ ! -s "$STUB_CALLS" ]; then
  ok "a criterion closed by two tickets stops the run, naming both"
else bad "a criterion closed by two tickets stops the run, naming both" "rc=$rc $(out)"; fi

workspace
advancer 3-three AC-2 "the second thing happens." ""; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '2-two.md: closes AC-2 and does not come after 3-three, which advances it' "$WORK/.out" \
   && [ "$(field 2-two status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket closing a criterion before one that advances it stops the run"
else bad "a ticket closing a criterion before one that advances it stops the run" "rc=$rc $(out)"; fi

# After it by way of another ticket is after it.
workspace
advancer 3-three AC-2 "the second thing happens." ""
sed -i 's/^after: .*/after:     3-three/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a closing ticket after an advancing one by way of a third runs"
else bad "a closing ticket after an advancing one by way of a third runs" "rc=$rc $(out)"; fi

# The frontmatter is what coverage is counted from and the quote is what the
# builder reads, so the two have to name the same criteria.
workspace
sed -i 's/^advances:.*/advances:  AC-2/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: claims AC-2 and does not quote it' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket claiming a criterion it does not quote stops the run"
else bad "a ticket claiming a criterion it does not quote stops the run" "rc=$rc $(out)"; fi

workspace
sed -i 's/^## Technical decisions$/> **AC-2** the second thing happens.\n\n## Technical decisions/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: quotes AC-2 and neither closes nor advances it' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket quoting a criterion it does not claim stops the run"
else bad "a ticket quoting a criterion it does not claim stops the run" "rc=$rc $(out)"; fi

workspace
rm "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'not there' "$WORK/.out"; then
  ok "a ticket whose CRITERIA.md is gone stops the run"
else bad "a ticket whose CRITERIA.md is gone stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: CRITERIA.md is gone"
else bad "drift is written into the ticket: CRITERIA.md is gone" "$(tkt 1-one)"; fi

# A ticket with nothing left to build is deleted, and whatever came after it has
# to be told, or it waits for a ticket that will never be done.
workspace
rm "$WORK/changes/x/tickets/1-one.md"
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/changes/x/CRITERIA.md"
git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm delete
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'names 1-one, which is not a ticket' "$WORK/.out"; then
  ok "a ticket whose after: names a deleted ticket stops the run"
else bad "a ticket whose after: names a deleted ticket stops the run" "rc=$rc $(out)"; fi
if [ "$(field 2-two status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a dangling after: halts its ticket before any session"
else bad "a dangling after: halts its ticket before any session" "$(tkt 2-two) $(calls)"; fi

# A built ticket whose criterion changed is re-sliced in place: its words
# updated and its status put back, so the runner builds it again. The re-slice
# deletes the final review, which reviewed what is about to change.
workspace
plan build build review
run > /dev/null
sed -i 's/the first thing happens./the first thing happens, differently./' \
  "$WORK/changes/x/CRITERIA.md" "$WORK/changes/x/tickets/1-one.md"
sed -i 's/^status: .*/status:    ready/; s/^attempts: .*/attempts:  0/' "$WORK/changes/x/tickets/1-one.md"
git -C "$WORK" rm -q changes/x/REVIEW.md
git -C "$WORK" commit -qam reslice
: > "$STUB_CALLS"
plan build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 2 ] && grep -q '1-one' <(head -1 "$STUB_CALLS"); then
  ok "a done ticket put back to ready is built again, and only it"
else bad "a done ticket put back to ready is built again, and only it" "rc=$rc $(calls) $(out)"; fi
if [ "$(field 1-one status)" = "done" ] && [ "$(field 2-two status)" = "done" ]; then
  ok "the rebuilt ticket ends done beside the one left alone"
else bad "the rebuilt ticket ends done beside the one left alone" "$(field 1-one status) / $(field 2-two status)"; fi


# A ticket that only splits a large file before the others add to it closes and
# advances nothing, and is still a ticket: built first, and no drift.
workspace
cat > "$WORK/changes/x/tickets/3-split.md" <<'EOF2'
---
criteria:  CRITERIA.md
closes:
advances:
after:
status:    ready
attempts:  0
---

## Build
Split the large file the other tickets add to.

## Done when
It is split, the behaviour is unchanged, and the checks pass.

## Technical decisions

> **Concepts** none.

> **Wire formats** none.

> **Hard to reverse** none.
EOF2
sed -i 's/^after: *$/after:     3-split/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q '3-split.md' <(head -1 "$STUB_CALLS") && [ "$(field 3-split status)" = "done" ]; then
  ok "a ticket that closes no criterion, only splitting a file, is built first and is no drift"
else bad "a ticket that closes no criterion, only splitting a file, is built first and is no drift" "rc=$rc $(out) $(calls)"; fi

finish
