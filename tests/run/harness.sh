# shellcheck shell=bash
#
# What every suite of the runner's tests stands on. Each case builds a
# throwaway repository in the layout the pipeline actually uses - a change's
# CRITERIA.md with the tickets under it - puts a stub on PATH where `claude`
# would be, and runs the real run.sh against it.
#
# Sourced, never run: tests/run.sh and every suite under tests/run/ start here.
# They sit at different depths, so paths are found from this file, not from $0.

TESTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$TESTS/../run.sh"

# shellcheck source=../lib.sh
. "$TESTS/lib.sh"

WORKSPACES=()
cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

# One change: two criteria and a ticket for each, the second after the first,
# and a nudge the first one quotes. On a branch whose history starts before the
# change's paper, as a real one does.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  git -C "$WORK" commit -q --allow-empty -m start
  mkdir -p "$WORK/changes/x/tickets"
  cat > "$WORK/changes/x/CRITERIA.md" <<'EOF'
# Criteria: x

## Problem
x

## Acceptance criteria
- **AC-1** the first thing happens.
- **AC-2** the second thing happens.

## Nudges
- reuse the list that is already there.

## Ruled out
- x
EOF
  ticket 1-one AC-1 "the first thing happens." "" "reuse the list that is already there."
  ticket 2-two AC-2 "the second thing happens." "1-one"
  git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm paper
  git -C "$WORK" checkout -q -b topic
  # The stub's own files sit in the workspace and are nobody's change: without
  # this every case would be refused as a dirty tree.
  printf '/.*\n' >> "$WORK/.git/info/exclude"
  STUB_CALLS="$WORK/.calls"; STUB_PLAN="$WORK/.plan"; STUB_SESSIONS="$WORK/.sessions"
  STUB_ARGS="$WORK/.args"
  : > "$STUB_CALLS"; : > "$STUB_PLAN"; : > "$STUB_SESSIONS"; : > "$STUB_ARGS"
  STUB_VERIFY=true
  export STUB_CALLS STUB_PLAN STUB_SESSIONS STUB_ARGS STUB_VERIFY
  mkdir -p "$WORK/.bin" && ln -sf "$TESTS/stub-session" "$WORK/.bin/claude"
  # How long the runner asked to sleep, one line per sleep, and no wait at all.
  # The clock `date +%s` reads moves by what was slept instead, plus whatever
  # .suspend holds on the next sleep: a machine suspended in the middle of it.
  SLEPT="$WORK/.slept"; : > "$SLEPT"; CLOCK="$WORK/.clock"; date +%s > "$CLOCK"
  cat > "$WORK/.bin/sleep" <<STUB
#!/bin/sh
echo "\$1" >> "$SLEPT"
echo \$(( \$(cat "$CLOCK") + \$1 + \$(cat "$WORK/.suspend" 2>/dev/null || echo 0) )) > "$CLOCK"
rm -f "$WORK/.suspend"
STUB
  cat > "$WORK/.bin/date" <<STUB
#!/bin/sh
if [ "\$1" = +%s ]; then cat "$CLOCK"; else exec $(command -v date) "\$@"; fi
STUB
  chmod +x "$WORK/.bin/sleep" "$WORK/.bin/date"
}

ticket() {  # slug, id, text, after, nudge
  cat > "$WORK/changes/x/tickets/$1.md" <<EOF
---
criteria:  CRITERIA.md
closes:    $2
advances:
after:     $4
status:    ready
attempts:  0
---

## Build
x

## Done when

> **$2** $3

## Nudges
${5:+
> $5
}
## Context
x

## Not here
x
EOF
}

# A ticket that builds part of a criterion another ticket closes.
advancer() {  # slug, id, text, after
  cat > "$WORK/changes/x/tickets/$1.md" <<EOF
---
criteria:  CRITERIA.md
closes:
advances:  $2
after:     $4
status:    ready
attempts:  0
---

## Build
x

## Done when
part of it happens.

## Toward

> **$2** $3

## Nudges

## Context
x

## Not here
x
EOF
}

plan()  { printf '%s\n' "$@" > "$STUB_PLAN"; }
commit() { git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm edit; }
run()   { ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}" \
              bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?; }
field() { sed -n "s/^$2: *//p" "$WORK/changes/x/tickets/$1.md" | head -1; }
tkt()   { cat "$WORK/changes/x/tickets/$1.md"; }
out()   { cat "$WORK/.out"; }
calls() { cat "$STUB_CALLS"; }
