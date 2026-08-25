# Ideas

The parking lot. Work worth doing that no current feature covers, each with
enough context to resurrect it: the problem, why it is not being built now, and
what it would touch. `/discovery` reads this at the start of a feature and
raises what fits, because a parking lot nobody revisits is a slower way of
forgetting.

The build list that rebuilt this pipeline lived here until it was finished. It
is in git history at commit `cfbd959` and the twenty commits before it.

---

**`/cleanup-repo` should produce a spec or tickets.** *To be discussed.* It
stops at a plan a human applies by hand, which is the one thing the maintenance
lane exists to stop: work nobody outside the code can observe goes through the
same build and the same reviews rather than around them. What it should emit is
the open question - a spec, where a cleanup is large enough to want decomposing,
or a set of maintenance tickets directly. Deferred until that is settled.
*Touches: cleanup-repo/SKILL.md, and possibly the maintenance ticket kind in the
five `TICKET_FORMAT.md` copies.*

**`/check-against-spec` should fail when it cannot drive the app.** It is the
acceptance: it drives the running feature the way a user would, and falls back
to code and test evidence only where nobody could drive it. Today a run where
*nothing* can be driven - the permissions do not cover starting the app, or the
project has no way in - degrades quietly into the reading the step was rewritten
to replace, and says so in a report that reaches nobody mechanically. A whole
run checked on evidence should end the run somewhere other than clean.
*Touches: check-against-spec/SKILL.md, loop.sh, tests/run.sh.*

**`/check-against-spec` should close with a verdict line, as `/critique` does.**
Only the review's verdict is machine-read, so the driver learns what the
acceptance found only through the tickets it filed. What it refuses to file
reaches nobody: a gap it will not reopen because a ticket already adjudicated it
leaves the run reporting *clean* with that disagreement outstanding. The same
four-count line, read the same way, closes it.
*Touches: check-against-spec/SKILL.md, loop.sh, tests/run.sh.*

**`ARCHITECTURE.md` needs a reader.** `/repo-overview` writes it, re-derived
from the code and never hand-patched, and nothing in the pipeline reads it -
unlike `UBIQUITOUS_LANGUAGE.md`, which five skills read and which has a step
wiring it into `CLAUDE.md`. The obvious readers are the two steps that skim the
codebase before writing anything: `/discovery`, which reads what the feature
will sit next to, and `/spec-to-tickets`, which reads the structures the spec
names. Both would need it treated as a lead rather than as truth, since it is
only as current as the last run.
*Touches: repo-overview/SKILL.md, discovery/SKILL.md, spec-to-tickets/SKILL.md.*
