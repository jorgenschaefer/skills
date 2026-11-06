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
if [ -L "$DEST/alpha" ] && [ "$(readlink -f "$DEST/alpha")" = "$(readlink -f "$SRC/alpha")" ]; then
  ok "a directory holding a SKILL.md is linked"
else bad "a directory holding a SKILL.md is linked" "$(ls -l "$DEST")"; fi

if [ -L "$DEST/beta" ]; then
  ok "every skill is linked, not just the first"
else bad "every skill is linked, not just the first" "$(ls -l "$DEST")"; fi

if [ ! -e "$DEST/tests" ]; then
  ok "a directory with no SKILL.md is left out"
else bad "a directory with no SKILL.md is left out" "$(ls -l "$DEST")"; fi

if [ ! -e "$DEST/sync.sh" ]; then
  ok "a file beside the skills is left out"
else bad "a file beside the skills is left out" "$(ls -l "$DEST")"; fi

# --- a skill this repository keeps for itself --------------------------------
#
# A skill linked from the repository's own .claude/skills is for working on
# the skills here, and a session in any other project has no use for it.

workspace
mkdir -p "$SRC/.claude/skills" && ln -s ../../alpha "$SRC/.claude/skills/alpha"
sync >/dev/null 2>&1
if [ ! -e "$DEST/alpha" ] && [ -L "$DEST/beta" ]; then
  ok "a skill linked from the repository's .claude/skills is left out"
else bad "a skill linked from the repository's .claude/skills is left out" "$(ls -l "$DEST")"; fi

# --- running it twice ---------------------------------------------------------
#
# The `-n` bug: the second `ln` follows the existing link and writes inside the
# skill it was meant to replace, and the skill is still there, so nothing looks
# wrong until a session cannot find it.

workspace
sync >/dev/null 2>&1
sync >/dev/null 2>&1
if [ -L "$DEST/alpha" ] && [ ! -e "$SRC/alpha/alpha" ]; then
  ok "a second run replaces the link rather than nesting inside it"
else bad "a second run replaces the link rather than nesting inside it" "$(ls -l "$DEST" "$SRC/alpha")"; fi

if [ "$(find "$DEST" -mindepth 1 -maxdepth 1 | wc -l)" = 2 ]; then
  ok "a second run leaves the same two links"
else bad "a second run leaves the same two links" "$(ls -l "$DEST")"; fi

# --- a skill that moved -------------------------------------------------------

workspace
sync >/dev/null 2>&1
mv "$SRC/beta" "$SRC/gamma"
sync >/dev/null 2>&1
if [ ! -e "$DEST/beta" ] && [ ! -L "$DEST/beta" ]; then
  ok "the link to a renamed skill is removed"
else bad "the link to a renamed skill is removed" "$(ls -l "$DEST")"; fi

if [ -L "$DEST/gamma" ]; then
  ok "the renamed skill is linked under its new name"
else bad "the renamed skill is linked under its new name" "$(ls -l "$DEST")"; fi

# --- a dangling link from somewhere else --------------------------------------

workspace
ln -s "$WORK/never-existed" "$DEST/orphan"
sync >/dev/null 2>&1
if [ ! -L "$DEST/orphan" ]; then
  ok "a dangling link pointing outside the project is removed too"
else bad "a dangling link pointing outside the project is removed too" "$(ls -l "$DEST")"; fi

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
if [ -d "$DEST/synced/thing" ] && [ -f "$DEST/handwritten/SKILL.md" ]; then
  ok "a real directory in the target is left alone"
else bad "a real directory in the target is left alone" "$(ls -l "$DEST")"; fi

if [ -L "$DEST/live-elsewhere" ]; then
  ok "a link that still resolves is left alone"
else bad "a link that still resolves is left alone" "$(ls -l "$DEST")"; fi

# --- a name that is taken ----------------------------------------------------
#
# The guard only matters where a name clashes with a skill here. Without the
# clash, a case above stays green with the guard deleted.

workspace
mkdir -p "$DEST/alpha" && echo mine > "$DEST/alpha/SKILL.md"
out="$(sync 2>&1)"
if [ ! -L "$DEST/alpha" ] && [ "$(cat "$DEST/alpha/SKILL.md")" = mine ] \
   && [ "$(find "$DEST/alpha" -mindepth 1 | wc -l)" = 1 ]; then
  ok "a directory with a skill's name is left as it was"
else bad "a directory with a skill's name is left as it was" "$(ls -lR "$DEST")"; fi

if printf '%s' "$out" | grep -q 'alpha.*left alone'; then
  ok "a directory with a skill's name is reported"
else bad "a directory with a skill's name is reported" "$out"; fi

workspace
echo precious > "$DEST/alpha"
out="$(sync 2>&1)"
if [ ! -L "$DEST/alpha" ] && [ "$(cat "$DEST/alpha")" = precious ]; then
  ok "a file with a skill's name is left as it was"
else bad "a file with a skill's name is left as it was" "$(ls -l "$DEST")"; fi

if printf '%s' "$out" | grep -q 'alpha.*left alone'; then
  ok "a file with a skill's name is reported"
else bad "a file with a skill's name is reported" "$out"; fi

workspace
mkdir -p "$WORK/other/beta" && : > "$WORK/other/beta/SKILL.md"
ln -s "$WORK/other/beta" "$DEST/beta"
out="$(sync 2>&1)"
if [ "$(readlink -f "$DEST/beta")" = "$(readlink -f "$WORK/other/beta")" ]; then
  ok "a link into another repository with a skill's name is left as it was"
else bad "a link into another repository with a skill's name is left as it was" "$(ls -l "$DEST")"; fi

if printf '%s' "$out" | grep -q 'beta.*left alone'; then
  ok "a link into another repository with a skill's name is reported"
else bad "a link into another repository with a skill's name is reported" "$out"; fi

# --- a skill that became this repository's own -------------------------------

workspace
sync >/dev/null 2>&1
mkdir -p "$SRC/.claude/skills" && ln -s ../../beta "$SRC/.claude/skills/beta"
sync >/dev/null 2>&1
if [ ! -e "$DEST/beta" ] && [ ! -L "$DEST/beta" ] && [ -L "$DEST/alpha" ]; then
  ok "a link to a skill now kept for this repository is removed"
else bad "a link to a skill now kept for this repository is removed" "$(ls -l "$DEST")"; fi

# --- a target it cannot enter -------------------------------------------------
#
# Without a stop, the target becomes "" and the links land in /.

workspace
chmod 000 "$DEST"
out="$(sync 2>&1)"; status=$?
chmod 755 "$DEST"
if [ "$status" -ne 0 ] && ! printf '%s' "$out" | grep -q '^linked'; then
  ok "a target it cannot enter stops the run"
else bad "a target it cannot enter stops the run" "status $status: $out"; fi

# --- a target that is not there yet -------------------------------------------

workspace
rm -rf "$DEST"
sync >/dev/null 2>&1
if [ -L "$DEST/alpha" ]; then
  ok "a target directory that does not exist yet is created"
else bad "a target directory that does not exist yet is created" "$(ls -l "$WORK")"; fi

# --- the default target -------------------------------------------------------
#
# Called with no argument it writes to ~/.claude/skills, which is the whole
# point of it; HOME is moved so the test says so without touching the real one.

workspace
( cd "$WORK" && HOME="$WORK/home" "$SRC/sync.sh" ) >/dev/null 2>&1
if [ -L "$WORK/home/.claude/skills/alpha" ]; then
  ok "with no argument it syncs to ~/.claude/skills"
else bad "with no argument it syncs to ~/.claude/skills" "$(find "$WORK/home" 2>&1)"; fi

# --- it says what it did ------------------------------------------------------

workspace
sync >/dev/null 2>&1
mv "$SRC/beta" "$SRC/gamma"
out="$(sync 2>&1)"
if printf '%s' "$out" | grep -q gamma && printf '%s' "$out" | grep -q beta; then
  ok "the run names the skill it linked and the link it removed"
else bad "the run names the skill it linked and the link it removed" "$out"; fi

finish
