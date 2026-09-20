#!/usr/bin/env bash
#
# Retire a finished run's paper: delete the intent, the solution and the
# tickets, and commit that.
#
#   ./accept-run.sh <topic>
#   ./accept-run.sh --abandon <topic>
#
# The paper is the record of what was asked for, and deleting it is the one act
# in this pipeline that destroys anything. Git history keeps every deleted file,
# so nothing is lost - but this commit is what marks a feature accepted, and it
# should mark work that is actually finished.
#
# So it refuses rather than trusts, and stops on the first check that does not
# hold: in a repository, on a branch of its own, a verdict that says accepted,
# every ticket done, and a clean tree so the commit is deletions and nothing
# else. Every refusal exits 2 having changed nothing.
#
# `--abandon` is for a topic dropped rather than finished. It waives the
# every-ticket-done check and only that one, and requires a verdict that says
# `abandoned` - because deciding to stop is a judgement, and the verdict is
# where a judgement is recorded.
#
# The judgement itself is `/accept`'s. This script is the part that must hold
# even when the session that called it is wrong.

set -uo pipefail

die() { printf '%s\n' "$*" >&2; exit 2; }

ABANDON=no
case "${1:-}" in
  --abandon) ABANDON=yes; shift ;;
esac
TOPIC="${1:-}"
[ -n "$TOPIC" ] || die "usage: accept-run.sh [--abandon] <topic>"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"

branch="$(git rev-parse --abbrev-ref HEAD)"
case "$branch" in
  main|master) die "refusing to accept on $branch: a run belongs on a branch of its own" ;;
esac

upper="$(printf '%s' "$TOPIC" | tr '[:lower:]-' '[:upper:]_')"
INTENT="INTENT_$upper.md"
SOLUTION="SOLUTION_$upper.md"
VERDICT="VERDICT_$upper.md"
TICKETS="tickets/$TOPIC"

paper=()
for f in "$INTENT" "$SOLUTION"; do [ -f "$f" ] && paper+=("$f"); done
[ -d "$TICKETS" ] && paper+=("$TICKETS")
[ "${#paper[@]}" -gt 0 ] || die "no paper for $TOPIC: expected $INTENT, $SOLUTION or $TICKETS"

[ -f "$VERDICT" ] || die "no $VERDICT: acceptance is a judgement, and this is where it is written"

want=accepted; [ "$ABANDON" = yes ] && want=abandoned
head -1 "$VERDICT" | grep -qi "verdict: *$want" \
  || die "$VERDICT does not say $want: $(head -1 "$VERDICT")"

# Unfinished work is the one check --abandon waives, because an abandoned run is
# unfinished by definition. It waives nothing else.
if [ "$ABANDON" = no ] && [ -d "$TICKETS" ]; then
  unfinished=""
  for t in "$TICKETS"/*.md; do
    [ -f "$t" ] || continue
    grep -q '^solution:' "$t" || continue
    status="$(sed -n '2,/^---$/s/^status: *//p' "$t" | head -1)"
    [ "$status" = done ] || unfinished+="$(basename "$t") is $status"$'\n'
  done
  [ -z "$unfinished" ] || die "not every ticket is done:"$'\n'"$unfinished"
fi

[ -z "$(git status --porcelain)" ] \
  || die "the tree is not clean: this commit should be deletions and nothing else"$'\n'"$(git status --porcelain)"

git rm -rq "${paper[@]}" || die "could not remove the paper"
git commit -q -m "Retire the paper for $TOPIC

$( [ "$ABANDON" = yes ] && echo "Abandoned rather than finished." || echo "Accepted." ) The
intent, the solution and the tickets were the record of what was asked for;
$VERDICT survives them and says what the work was for and what it cost. Git
history keeps the rest." || die "could not commit the deletion"

printf 'retired the paper for %s; %s survives\n' "$TOPIC" "$VERDICT"
