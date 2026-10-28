---
effort: XS
utility: S
---

# The test stub finds the review by its brief, not by REVIEW.md

`tests/stub-session` tells the final review from a build by the first
`REVIEW.md` its prompt names (`tests/stub-session:113`). Any new sentence in a
brief that names `REVIEW.md` before the review's own path breaks the runner's
tests. In the fast and slow checks change it broke twice: once for a new
sentence naming REVIEW.md, and once for one test's check command. The file has
26 commits in its history.

The build left the suggestion: the stub could tell the review from a build by
the brief's opening words instead.
