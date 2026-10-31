---
effort: S
utility: S
---

# The refactor drops friction notes that have not come up again

The user, on 2026-10-31, after acceptance began writing the review findings
about the code that nobody fixed into `changes/friction/`: the refactor
should clean out old friction notes that have not shown up again.

Today a note goes only when a refactor builds an item that deals with it:
"Delete the friction notes the items you built dealt with, and commit that.
Notes for items you did not build stay, so the next refactor sees them
again" (`refactor-codebase/SKILL.md:74`). Nothing else removes a note, so
notes pile up with every build, debug session and acceptance.

Open: a note can stop coming up because nobody has touched that code since,
while the problem is still in the code - a helper that still exists twice,
from a note acceptance wrote (`accept-change/SKILL.md:80`).
