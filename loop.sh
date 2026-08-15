#!/usr/bin/env bash
#
# Drive one feature's ticket loop to completion, unattended.
#
#   ./loop.sh path/to/tickets
#
# Builds every ready ticket in dependency order, then checks the result against
# the spec, reviews it, and hands it back. Stops at the first halt: /implement
# records the reason in the ticket rather than guessing past it, so a stopped
# loop means a human is needed, not that something crashed.

set -uo pipefail

TICKETS="${1:-tickets}"
SPEC_DIR="$(cd "$(dirname "$TICKETS")" && pwd)"
MAX_PASSES=3

[ -d "$TICKETS" ] || { echo "no ticket directory: $TICKETS" >&2; exit 2; }

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
  echo "not a git repository" >&2; exit 2; }
case "$branch" in
  main|master)
    echo "refusing to run on $branch - work on a feature branch so a bad run is one 'git branch -D' away" >&2
    exit 2 ;;
esac

# --- ticket frontmatter -------------------------------------------------------

field() { sed -n "s/^$2:[[:space:]]*\([^#]*\).*/\1/p" "$1" | head -1 | xargs; }
status_of() { field "$1" status; }
deps_of() { field "$1" depends_on | tr -d '[]' | tr ',' ' '; }
ticket_for() { ls "$TICKETS/$1"-*.md 2>/dev/null | head -1; }

ready() {
  local dep file
  for dep in $(deps_of "$1"); do
    file="$(ticket_for "$dep")"
    [ -n "$file" ] && [ "$(status_of "$file")" = "done" ] || return 1
  done
}

next_ticket() {
  local file
  for file in "$TICKETS"/[0-9]*.md; do
    [ -e "$file" ] || continue
    [ "$(status_of "$file")" = "todo" ] || continue
    ready "$file" && { printf '%s\n' "$file"; return 0; }
  done
  return 1
}

# --- the loop -----------------------------------------------------------------

# /implement sets `status` in the ticket before it finishes. That, not the exit
# code, is the signal: a session that dies without setting it reads as a halt
# rather than passing silently.
drain() {
  local ticket
  while ticket="$(next_ticket)"; do
    echo "==> implement $(basename "$ticket")"
    claude -p "/implement $ticket"
    if [ "$(status_of "$ticket")" != "done" ]; then
      echo
      echo "!! halted on $(basename "$ticket")"
      sed -n '/^## Halt/,$p' "$ticket"
      return 1
    fi
  done
}

# Both end-of-run checks feed findings back as tickets, so a fix re-enters the
# same loop with the same TDD and review discipline instead of being patched by
# hand after everything else has been verified. /trace runs first: a gap it finds
# becomes code, and that code should pass under /critique rather than land behind
# it. /critique stays a generic review skill - the prompt here, not the skill,
# knows this pipeline files tickets.
CRITIQUE_PROMPT="Run /critique over the diff from this branch's start.
For each Blocker and Should-fix, file a remediation ticket in $TICKETS,
following TICKET_FORMAT.md as documented in the /implement skill.
Do not file nits - leave those in your report for /handover to triage."

# Bounded, because work the loop cannot converge on should reach a human.
for pass in $(seq "$MAX_PASSES"); do
  drain || exit 1

  echo "==> trace (pass $pass)"
  claude -p "/trace $SPEC_DIR"
  drain || exit 1

  echo "==> critique (pass $pass)"
  claude -p "$CRITIQUE_PROMPT"

  if ! next_ticket >/dev/null; then
    reviews_clean=1
    break
  fi
  echo "==> reviews filed work; draining again"
done

if [ -z "${reviews_clean:-}" ]; then
  echo "!! reviews still filing work after $MAX_PASSES passes - stopping for a human" >&2
  exit 1
fi

echo "==> handover"
claude -p "/handover $SPEC_DIR"
