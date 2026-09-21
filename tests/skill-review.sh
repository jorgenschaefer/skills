#!/usr/bin/env bash
#
# The tests for the merge of `improve-skill` and the vendored
# `writing-great-skills` into one skill, `skill-review`.
#
#   tests/skill-review.sh
#
# Two skills said overlapping things about the same subject, one of them
# vendored from another repository. Merging them is mostly deletion, and the
# failure it invites is a lens quietly going missing - a reviewer that no longer
# checks triggering, or no longer knows what a no-op is, reads exactly as green
# as one that does. So the ideas are listed in a fixture and checked here.
#
# The other half is that the originals are actually gone: a merge that leaves
# both sources in the tree has produced a third statement of the same rules,
# which is the duplication the skill itself warns about.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
SKILL="$ROOT/skill-review/SKILL.md"
LENSES="$HERE/fixtures/skill-review-lenses.txt"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

if [ ! -f "$SKILL" ]; then
  bad "the review is its own skill" "no $SKILL"
  finish
  exit
fi
ok "the review is its own skill"

# Nothing lost. The fixture is the decision about what the merge had to keep;
# an empty or unreadable one would pass every case below without checking any.
if [ ! -s "$LENSES" ]; then
  bad "the list of lenses is readable" "missing or empty: $LENSES"
  finish
  exit
fi

lenses=0 missing=""
while IFS= read -r line; do
  case "$line" in ''|'#'*) continue ;; esac
  label="${line%% :: *}" pattern="${line#* :: }"
  lenses=$((lenses + 1))
  grep -qE "$pattern" "$SKILL" || missing+="$label"$'\n'
done < "$LENSES"

expect_counted "$lenses" "lenses the merge had to carry"
[ -z "$missing" ] \
  && ok "the merged skill carries every lens of both originals" \
  || bad "the merged skill carries every lens of both originals" "$missing"

# The originals are gone. Named individually, because each leaves in a different
# way: one is a directory of this repository, the other is vendored into two
# install trees and pinned in a lock file.
for gone in improve-skill .agents/skills/writing-great-skills .claude/skills/writing-great-skills; do
  [ -e "$ROOT/$gone" ] \
    && bad "$gone is retired" "still in the tree" \
    || ok "$gone is retired"
done

grep -q 'writing-great-skills' "$ROOT/skills-lock.json" \
  && bad "the lock file no longer pins a retired skill" "writing-great-skills is still pinned" \
  || ok "the lock file no longer pins a retired skill"

# A skill nobody can find is a skill nobody runs, and this repository's index of
# its own skills is README.md.
grep -q 'skill-review' "$ROOT/README.md" \
  && ok "README names the skill" \
  || bad "README names the skill" "no mention of skill-review"

finish
