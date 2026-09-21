#!/usr/bin/env bash
#
# The tests for the sync: what it does to ~/.claude/skills.
#
#   tests/sync.sh
#
# `sync.sh` writes into the directory every session reads its skills from, and
# the two ways that goes wrong are both silent. A link laid over an existing one
# without `-n` lands *inside* it, so the skill installs one directory deeper and
# stops being found. A link left behind after a skill is renamed points at
# nothing, and an agent told to reach it reads nothing and carries on.
#
# Each case builds a throwaway source tree and a throwaway target and runs the
# real script against them, because the thing being checked is what is on disk
# afterwards.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SYNC="$HERE/../sync.sh"

# shellcheck source=lib.sh
. "$HERE/lib.sh"

WORKSPACES=()
cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

# A source tree shaped like this repository: skills, and things that are not
# skills, told apart by whether they hold a SKILL.md.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  SRC="$WORK/src"; DEST="$WORK/dest"
  mkdir -p "$SRC/alpha" "$SRC/beta" "$SRC/tests" "$DEST"
  : > "$SRC/alpha/SKILL.md"
  : > "$SRC/beta/SKILL.md"
  : > "$SRC/tests/lib.sh"
  cp "$SYNC" "$SRC/sync.sh"
}

sync() { ( cd "$WORK" && "$SRC/sync.sh" "$DEST" ); }

# --- what gets linked ---------------------------------------------------------

workspace
sync >/dev/null 2>&1
[ -L "$DEST/alpha" ] && [ "$(readlink -f "$DEST/alpha")" = "$(readlink -f "$SRC/alpha")" ] \
  && ok "a directory holding a SKILL.md is linked" \
  || bad "a directory holding a SKILL.md is linked" "$(ls -l "$DEST")"

[ -L "$DEST/beta" ] \
  && ok "every skill is linked, not just the first" \
  || bad "every skill is linked, not just the first" "$(ls -l "$DEST")"

[ ! -e "$DEST/tests" ] \
  && ok "a directory with no SKILL.md is left out" \
  || bad "a directory with no SKILL.md is left out" "$(ls -l "$DEST")"

[ ! -e "$DEST/sync.sh" ] \
  && ok "a file beside the skills is left out" \
  || bad "a file beside the skills is left out" "$(ls -l "$DEST")"

# --- running it twice ---------------------------------------------------------
#
# The `-n` bug: the second `ln` follows the existing link and writes inside the
# skill it was meant to replace, and the skill is still there, so nothing looks
# wrong until a session cannot find it.

workspace
sync >/dev/null 2>&1
sync >/dev/null 2>&1
[ -L "$DEST/alpha" ] && [ ! -e "$SRC/alpha/alpha" ] \
  && ok "a second run replaces the link rather than nesting inside it" \
  || bad "a second run replaces the link rather than nesting inside it" "$(ls -l "$DEST" "$SRC/alpha")"

[ "$(ls "$DEST" | wc -l)" = 2 ] \
  && ok "a second run leaves the same two links" \
  || bad "a second run leaves the same two links" "$(ls -l "$DEST")"

# --- a skill that moved -------------------------------------------------------

workspace
sync >/dev/null 2>&1
mv "$SRC/beta" "$SRC/gamma"
sync >/dev/null 2>&1
[ ! -e "$DEST/beta" ] && [ ! -L "$DEST/beta" ] \
  && ok "the link to a renamed skill is removed" \
  || bad "the link to a renamed skill is removed" "$(ls -l "$DEST")"

[ -L "$DEST/gamma" ] \
  && ok "the renamed skill is linked under its new name" \
  || bad "the renamed skill is linked under its new name" "$(ls -l "$DEST")"

# --- a dangling link from somewhere else --------------------------------------

workspace
ln -s "$WORK/never-existed" "$DEST/orphan"
sync >/dev/null 2>&1
[ ! -L "$DEST/orphan" ] \
  && ok "a dangling link pointing outside the project is removed too" \
  || bad "a dangling link pointing outside the project is removed too" "$(ls -l "$DEST")"

# --- what is not ours ---------------------------------------------------------
#
# `~/.claude/skills` holds more than this project: skills synced from elsewhere,
# and skills someone wrote in place. A sync that tidies those away has deleted
# work nothing else has a copy of.

workspace
mkdir -p "$DEST/synced/thing" && : > "$DEST/synced/thing/SKILL.md"
mkdir -p "$DEST/handwritten" && : > "$DEST/handwritten/SKILL.md"
ln -s "$SRC/alpha" "$DEST/live-elsewhere"
sync >/dev/null 2>&1
[ -d "$DEST/synced/thing" ] && [ -f "$DEST/handwritten/SKILL.md" ] \
  && ok "a real directory in the target is left alone" \
  || bad "a real directory in the target is left alone" "$(ls -l "$DEST")"

[ -L "$DEST/live-elsewhere" ] \
  && ok "a link that still resolves is left alone" \
  || bad "a link that still resolves is left alone" "$(ls -l "$DEST")"

# --- a target that is not there yet -------------------------------------------

workspace
rm -rf "$DEST"
sync >/dev/null 2>&1
[ -L "$DEST/alpha" ] \
  && ok "a target directory that does not exist yet is created" \
  || bad "a target directory that does not exist yet is created" "$(ls -l "$WORK")"

# --- the default target -------------------------------------------------------
#
# Called with no argument it writes to ~/.claude/skills, which is the whole
# point of it; HOME is moved so the test says so without touching the real one.

workspace
( cd "$WORK" && HOME="$WORK/home" "$SRC/sync.sh" ) >/dev/null 2>&1
[ -L "$WORK/home/.claude/skills/alpha" ] \
  && ok "with no argument it syncs to ~/.claude/skills" \
  || bad "with no argument it syncs to ~/.claude/skills" "$(find "$WORK/home" 2>&1)"

# --- it says what it did ------------------------------------------------------

workspace
sync >/dev/null 2>&1
mv "$SRC/beta" "$SRC/gamma"
out="$(sync 2>&1)"
printf '%s' "$out" | grep -q gamma && printf '%s' "$out" | grep -q beta \
  && ok "the run names the skill it linked and the link it removed" \
  || bad "the run names the skill it linked and the link it removed" "$out"

finish
