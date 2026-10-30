# shellcheck shell=bash
#
# What every suite of the runner's tests stands on. Each case builds a
# throwaway repository in the layout a change really has - its CHANGE.md, the
# journeys it names and its chunks - puts a stub on PATH where `claude` would
# be, and runs the real run.sh against it.
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

# One change: two journeys and a chunk for each, the second after the first.
# On a branch whose history starts before the change's paper, as a real one does.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  git -C "$WORK" commit -q --allow-empty -m start
  mkdir -p "$WORK/changes/x/chunks" "$WORK/journeys"
  printf '# One\n\n**Who:** x\n**Wants:** x\n\n## Steps\n1. the first thing happens.\n' > "$WORK/journeys/one.md"
  printf '# Two\n\n**Who:** x\n**Wants:** x\n\n## Steps\n1. the second thing happens.\n' > "$WORK/journeys/two.md"
  cat > "$WORK/changes/x/CHANGE.md" <<'EOF'
---
journeys:  journeys/one.md, journeys/two.md
after:
status:    ready
attempts:  0
---

# x

## Problem
x

## Design
x
EOF
  chunk 1-one journeys/one.md ""
  chunk 2-two journeys/two.md "1-one"
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

chunk() {  # slug, journeys, after
  cat > "$WORK/changes/x/chunks/$1.md" <<EOF
---
journeys:  $2
after:     $3
status:    ready
attempts:  0
---

# $1

## Problem
x

## Design
x

## Not in this change
x
EOF
}

# The change unsplit: CHANGE.md is what gets built, or split on a first start.
unsplit() { git -C "$WORK" rm -rq changes/x/chunks; git -C "$WORK" commit -qm unsplit; }

plan()  { printf '%s\n' "$@" > "$STUB_PLAN"; }
commit() { git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm edit; }
run()   { ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}" \
              bash "$RUNNER" changes/x > "$WORK/.out" 2>&1 ); echo $?; }
field() { sed -n "s/^$2: *//p" "$(chunk_path "$1")" | head -1; }
chk()   { cat "$(chunk_path "$1")"; }
chunk_path() { if [ "$1" = CHANGE ]; then echo "$WORK/changes/x/CHANGE.md"; else echo "$WORK/changes/x/chunks/$1.md"; fi; }
out()   { cat "$WORK/.out"; }
calls() { cat "$STUB_CALLS"; }
