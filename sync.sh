#!/usr/bin/env bash
#
# Put this project's skills where sessions look for them.
#
#   ./sync.sh [target]          # target defaults to ~/.claude/skills
#
# Links rather than copies, so editing a skill here is editing the one a session
# reads - the alternative is a sync you have to remember to run, and a session
# quietly running last week's wording.
#
# Then it removes the links that no longer resolve. A skill that gets renamed
# leaves one behind, and a dangling link is the worst of the failures available
# here: nothing errors, the agent reads nothing, and the instruction that was
# supposed to bind it silently does not.
#
# A skill the repository links from its own .claude/skills is for working on
# the skills here, so it stays out of the target.
#
# It only ever removes symlinks. `~/.claude/skills` holds skills synced from
# elsewhere and skills written in place, and those are directories.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-$HOME/.claude/skills}"

mkdir -p "$DEST" || exit 1
DEST="$(cd "$DEST" && pwd)"

linked=0 removed=0 blocked=""

for skill in "$HERE"/*/; do
  skill="${skill%/}"
  [ -f "$skill/SKILL.md" ] || continue
  name="$(basename "$skill")"
  [ -e "$HERE/.claude/skills/$name" ] && continue

  # A real directory of that name is somebody else's skill, and replacing it
  # with a link deletes the only copy. Say so and leave it.
  if [ -d "$DEST/$name" ] && [ ! -L "$DEST/$name" ]; then
    blocked+="  $name is a directory here already, not a link - left alone"$'\n'
    continue
  fi

  # -n, so that replacing an existing link writes the link rather than
  # following it and landing one directory inside the skill.
  ln -sfn "$skill" "$DEST/$name" && linked=$((linked + 1))
  printf 'linked   %s\n' "$name"
done

for entry in "$DEST"/*; do
  [ -L "$entry" ] || continue
  [ -e "$entry" ] && continue
  target="$(readlink "$entry")"
  rm "$entry" && removed=$((removed + 1))
  printf 'removed  %s -> %s (dangling)\n' "$(basename "$entry")" "$target"
done

[ -z "$blocked" ] || printf '%s' "$blocked"
printf '%d linked, %d dangling removed, in %s\n' "$linked" "$removed" "$DEST"
