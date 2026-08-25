#!/usr/bin/env bash
#
# Accept a finished run: delete the paper it was built from, and commit that.
#
#   ./accept.sh path/to/spec-dir
#
# The spec and the tickets are the record of what was asked for, and deleting
# them is the one act in the pipeline that destroys it. Git history keeps every
# deleted file, so nothing is lost - but this commit is what marks the feature
# accepted, and it should mark work that is actually finished.
#
# So it refuses rather than trusts, and stops on the first check that does not
# hold: in a repository, on a branch of its own, one spec beside a ticket
# directory, every ticket done, and the tree clean so the commit is deletions
# and nothing else. Every refusal exits 2 having changed nothing.
#
# You run this yourself, after reading the run's handover. Nothing upstream can:
# accepting is the judgement the whole pipeline defers to a human, and it is
# deliberately not something an unattended session can reach.

set -uo pipefail

SPEC_DIR="${1:-}"
[ -n "$SPEC_DIR" ] || { echo "usage: $0 path/to/spec-dir" >&2; exit 2; }
[ -d "$SPEC_DIR" ] || { echo "no such directory: $SPEC_DIR" >&2; exit 2; }

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "not a git repository - there is no run's paper here to delete" >&2; exit 2; }

# A detached HEAD is refused with the default branches: the commit that marks
# the feature accepted would be unreachable the moment anyone changed branch.
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
  echo "this repository has no commits yet, so it holds no finished run" >&2; exit 2; }
case "$branch" in
  main|master|HEAD)
    echo "refusing to accept on $branch - a run is accepted on its own branch, before the merge" >&2
    exit 2 ;;
esac

# The spec directory holds one run's paper. The repository holds the project,
# and its README is not a spec - so being pointed at the root is a mistake to
# refuse rather than the widest possible deletion to carry out.
[ "$(cd "$SPEC_DIR" && pwd -P)" != "$(cd "$ROOT" && pwd -P)" ] || {
  echo "refusing to accept $SPEC_DIR - that is the whole repository, not one run's paper" >&2
  exit 2; }

TICKETS="$SPEC_DIR/tickets"
{ [ -d "$TICKETS" ] && [ ! -L "$TICKETS" ]; } || {
  echo "no ticket directory: $TICKETS" >&2; exit 2; }

# Which file is the spec is not a guess to make where the wrong answer deletes
# the other one.
specs=("$SPEC_DIR"/*.md)
[ "${#specs[@]}" -eq 1 ] && [ -e "${specs[0]}" ] || {
  echo "expected one spec beside $TICKETS, found: ${specs[*]}" >&2; exit 2; }
SPEC="${specs[0]}"

# `status` is the ticket's own word for whether it was built, read here the way
# `loop.sh`'s `field` reads it - the same frontmatter vocabulary, deliberately
# copied so this script stands alone with nothing to source. The two change
# together.
built=() unbuilt=()
for ticket in "$TICKETS"/[0-9]*.md; do
  [ -e "$ticket" ] || continue
  status="$(sed -n 's/^status:[[:space:]]*\([^#]*\).*/\1/p' "$ticket" | head -1 | xargs)"
  if [ "$status" = "done" ]; then
    built+=("$(basename "$ticket" .md)")
  else
    unbuilt+=("$(basename "$ticket" .md) - $status")
  fi
done

[ "${#unbuilt[@]}" -eq 0 ] || {
  { echo "refusing to accept a run with work left in it:"
    printf '  %s\n' "${unbuilt[@]}"; } >&2
  exit 2; }
[ "${#built[@]}" -gt 0 ] || { echo "no tickets in $TICKETS - nothing to accept" >&2; exit 2; }

# Anything else in the tree would ride in on the one commit whose whole meaning
# is that the reviewed work is finished.
[ -z "$(git status --porcelain)" ] || {
  echo "refusing to accept with a dirty tree - commit or stash first, so this commit is deletions only" >&2
  exit 2; }

# What git ignores, git cannot delete - so an ignored file under the spec
# directory would outlive the paper around it and leave the run half accepted.
# Whoever put it there decides what happens to it.
ignored="$(git status --porcelain --ignored=matching -- "$SPEC_DIR")"
[ -z "$ignored" ] || {
  { echo "refusing to accept - $SPEC_DIR holds files git is ignoring, which this cannot delete:"
    printf '%s\n' "$ignored"; } >&2
  exit 2; }

# `:(literal)` because these are paths, and git would otherwise read a `*` or a
# `[` in one of them as a pattern matching more than the path it came from.
feature="$(basename "$SPEC" .md | tr '_-' '  ')"
git rm -rq -- ":(literal)$TICKETS" ":(literal)$SPEC" || exit 2
git commit -q -F - <<EOF || { echo "the deletion is staged but nothing was committed" >&2; exit 2; }
Accept $feature

The run is accepted, so the paper it was built from goes. Git history
keeps the spec and the tickets; this commit is what marks the feature
finished.

$(printf '  %s\n' "${built[@]}")
EOF

echo "accepted $feature - ${#built[@]} tickets, $SPEC and $TICKETS deleted in $(git rev-parse --short HEAD)"
