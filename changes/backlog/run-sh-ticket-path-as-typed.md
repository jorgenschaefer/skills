---
effort: XS
utility: XS
---

# run.sh takes the ticket path as typed

`./run.sh changes/<dir>/tickets/.` halts every ticket as drift - "names
changes/<dir>/tickets/CRITERIA.md, which is not there" - and commits that
halt, on any branch. Started on main, it also names the run's branch
`tickets` rather than `<dir>`.

The ticket directory is checked only for existence (`run.sh:65`) and is
then used as typed, through `dirname "$TICKETS"`: `run.sh:112` (the run's
branch), `run.sh:122` (the token log), `run.sh:127` (`REVIEW.md`),
`run/drift.sh:17` (the false drift), `run/report.sh:64` and
`run/prompts.sh:80`. A trailing slash, `./…`, an absolute path and a start
from inside the change directory all work; `tickets/.` does not.

Found while accepting `changes/2026-10-19-run-sh-branch-on-main`. The
suggestion then was to normalise the path once, where it enters.
