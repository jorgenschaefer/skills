#!/usr/bin/env bash
#
# The tests for retiring a run's paper.
#
#   tests/accept.sh
#
# Deleting the intent, the solution and the tickets is the one act in this
# pipeline that destroys something. Git keeps every deleted file, so nothing is
# lost - but the commit marks the work accepted, and it should mark work that is
# actually finished. So the script refuses rather than trusts, and these cases
# are the refusals.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../accept-run.sh"
passed=0 failed=0
WORKSPACES=()

ok()  { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
        [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }
cleanup() { [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
            printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"; }
trap cleanup EXIT

workspace() {  # every ticket done, tree clean, on a branch: the accepting case
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  # Outside the repository: a scratch file inside it would make the tree dirty,
  # which is one of the things being tested.
  OUT="$(mktemp)"
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  printf '# Intent: t\n\n## Done when\n- **C-1** a\n\n## Ratified\nyes\n' > "$WORK/INTENT_T.md"
  printf '## Behaviour\n- **AC-1** a *(C-1)*\n' > "$WORK/SOLUTION_T.md"
  printf '# Verdict: accepted\n\n## Conditions\n- C-1 met\n' > "$WORK/VERDICT_T.md"
  mkdir -p "$WORK/tickets/t"
  printf -- '---\nsolution:  SOLUTION_T.md\nsatisfies: AC-1\nafter:\nstatus:    done\nattempts:  1\nreviews:   1\n---\n\n## Build\nx\n' \
    > "$WORK/tickets/t/1-one.md"
  printf 'code\n' > "$WORK/thing.txt"
  git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm work
  git -C "$WORK" checkout -q -b topic
}

accept() { ( cd "$WORK" && bash "$SCRIPT" "$@" > "$OUT" 2>&1 ); echo $?; }
out() { cat "$OUT"; }
tracked() { git -C "$WORK" ls-files "$1" | head -1; }

# --- it refuses rather than trusts

workspace; git -C "$WORK" checkout -q main
rc="$(accept t)"
[ "$rc" != 0 ] && grep -qi 'branch' "$OUT" \
  && ok "it refuses on the main branch" || bad "it refuses on the main branch" "rc=$rc $(out)"

workspace; printf 'x\n' >> "$WORK/thing.txt"
rc="$(accept t)"
[ "$rc" != 0 ] && grep -qi 'clean\|uncommitted' "$OUT" \
  && ok "it refuses a dirty tree" || bad "it refuses a dirty tree" "rc=$rc $(out)"

workspace; sed -i 's/^status: .*/status:    review/' "$WORK/tickets/t/1-one.md"
git -C "$WORK" commit -qam wip
rc="$(accept t)"
[ "$rc" != 0 ] && grep -q '1-one' "$OUT" \
  && ok "it refuses while a ticket is unfinished, and names it" \
  || bad "it refuses while a ticket is unfinished, and names it" "rc=$rc $(out)"

workspace; rm "$WORK/VERDICT_T.md"; git -C "$WORK" commit -qam noverdict
rc="$(accept t)"
# The message matters: a missing verdict falls through to the next check
# otherwise, and tells the person their verdict says the wrong thing.
[ "$rc" != 0 ] && grep -q 'no VERDICT_T.md' "$OUT" \
  && ok "it refuses without a verdict, and says the verdict is missing" \
  || bad "it refuses without a verdict, and says the verdict is missing" "rc=$rc $(out)"

workspace; sed -i 's/^# Verdict: accepted/# Verdict: rejected/' "$WORK/VERDICT_T.md"
git -C "$WORK" commit -qam rejected
rc="$(accept t)"
[ "$rc" != 0 ] && grep -qi 'rejected' "$OUT" \
  && ok "it refuses on a rejected verdict" || bad "it refuses on a rejected verdict" "rc=$rc $(out)"

workspace
rc="$(accept nosuchtopic)"
[ "$rc" != 0 ] && ok "it refuses a topic with no paper" || bad "it refuses a topic with no paper" "$(out)"

# every refusal changes nothing
[ -z "$(git -C "$WORK" status --porcelain)" ] && [ -n "$(tracked INTENT_T.md)" ] \
  && ok "a refusal deletes nothing" || bad "a refusal deletes nothing" "$(git -C "$WORK" status --porcelain)"

# --- and accepts

workspace
rc="$(accept t)"
[ "$rc" = 0 ] && ok "it accepts a finished run" || bad "it accepts a finished run" "rc=$rc $(out)"
[ -z "$(tracked INTENT_T.md)" ] && [ -z "$(tracked SOLUTION_T.md)" ] && [ -z "$(tracked 'tickets/t/*')" ] \
  && ok "the paper is gone" \
  || bad "the paper is gone" "$(git -C "$WORK" ls-files | tr '\n' ' ')"
[ -n "$(tracked VERDICT_T.md)" ] \
  && ok "the verdict survives" || bad "the verdict survives" "VERDICT_T.md was deleted"
[ -n "$(tracked thing.txt)" ] \
  && ok "the code survives" || bad "the code survives" "thing.txt was deleted"
[ "$(git -C "$WORK" log --oneline | wc -l)" = 2 ] \
  && ok "the deletion is one commit" \
  || bad "the deletion is one commit" "$(git -C "$WORK" log --oneline | tr '\n' ' ')"
git -C "$WORK" show --stat HEAD | grep -q 'thing.txt' \
  && bad "the commit is deletions and nothing else" "it touched the code" \
  || ok "the commit is deletions and nothing else"

# --- abandonment waives one check, and only one

workspace; sed -i 's/^status: .*/status:    review/' "$WORK/tickets/t/1-one.md"
sed -i 's/^# Verdict: accepted/# Verdict: abandoned/' "$WORK/VERDICT_T.md"
git -C "$WORK" commit -qam abandon
rc="$(accept --abandon t)"
[ "$rc" = 0 ] && [ -z "$(tracked INTENT_T.md)" ] \
  && ok "--abandon retires a run whose tickets are unfinished" \
  || bad "--abandon retires a run whose tickets are unfinished" "rc=$rc $(out)"

workspace; git -C "$WORK" checkout -q main
sed -i 's/^# Verdict: accepted/# Verdict: abandoned/' "$WORK/VERDICT_T.md"
git -C "$WORK" commit -qam abandon
rc="$(accept --abandon t)"
[ "$rc" != 0 ] \
  && ok "--abandon still refuses the main branch" \
  || bad "--abandon still refuses the main branch" "it waived more than the one check"

workspace
rc="$(accept --abandon t)"
[ "$rc" != 0 ] && grep -qi 'abandoned' "$OUT" \
  && ok "--abandon needs a verdict that says so" \
  || bad "--abandon needs a verdict that says so" "rc=$rc $(out)"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
