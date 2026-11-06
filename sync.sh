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
# the skills here, so it stays out of the target, and a link to it from an
# earlier run is removed.
#
# It only ever removes or replaces its own links, and dangling ones.
# `~/.claude/skills` also holds skills synced from elsewhere and skills written
# in place: directories, files, and links into other repositories. A name that
# is taken by one of those is reported and left alone.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-$HOME/.claude/skills}"

mkdir -p "$DEST" || exit 1
DEST="$(cd "$DEST" && pwd)" || exit 1

linked=0 removed=0 blocked=""

# Whether $1 is a link to $2: the one this script makes.
ours() { [ -L "$1" ] && [ "$(readlink -f "$1")" = "$(readlink -f "$2")" ]; }

for skill in "$HERE"/*/; do
  skill="${skill%/}"
  [ -f "$skill/SKILL.md" ] || continue
  name="$(basename "$skill")"

  if [ -e "$HERE/.claude/skills/$name" ] || [ -L "$HERE/.claude/skills/$name" ]; then
    if ours "$DEST/$name" "$skill" && rm "$DEST/$name"; then
      removed=$((removed + 1))
      printf 'removed  %s (kept for this repository)\n' "$name"
    fi
    continue
  fi

  # Anything else of that name is somebody else's: a directory or file written
  # in place, or a link into another repository. `ln -sfn` would replace a file
  # or a link and put a stray link inside a directory. Say so and leave it.
  if { [ -e "$DEST/$name" ] || [ -L "$DEST/$name" ]; } && ! ours "$DEST/$name" "$skill"; then
    blocked+="  $name is here already and is not a link to this repository - left alone"$'\n'
    continue
  fi

  # -n, so that replacing an existing link writes the link rather than
  # following it and landing one directory inside the skill.
  if ln -sfn "$skill" "$DEST/$name"; then
    linked=$((linked + 1))
    printf 'linked   %s\n' "$name"
  fi
done

for entry in "$DEST"/*; do
  [ -L "$entry" ] || continue
  [ -e "$entry" ] && continue
  target="$(readlink "$entry")"
  if rm "$entry"; then
    removed=$((removed + 1))
    printf 'removed  %s -> %s (dangling)\n' "$(basename "$entry")" "$target"
  fi
done

[ -z "$blocked" ] || printf '%s' "$blocked"
printf '%d linked, %d removed, in %s\n' "$linked" "$removed" "$DEST"
