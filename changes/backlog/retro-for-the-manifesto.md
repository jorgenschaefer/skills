---
effort: M
utility: M
---

# retro looks at recent runs and finds improvements against the manifesto

The user wants `retro` reworked so it is better suited to looking at recent
runs and finding improvements, and tailored towards `MANIFESTO.md`.

## What is there today

`.claude/skills/retro/SKILL.md` looks back over one session or one
`run.sh` run, named by the user or the current one. It reads the logs in
`.git/run-logs/` through scripts it writes into the scratchpad each time,
checks whether the fixes since the previous run held, looks for moments
(a person stepping in, defects caught late, rules that did not hold or did
harm, cost, searching, interference, the unprompted), and fixes with the
strongest mechanism that fits. It judges a run by whether it went worse than
it should have, not against the manifesto: nothing asks whether a run
put before the human what the manifesto says it should, whether a stage
judged its own work, or whether an approved check was weakened.

It is linked from this repository's `.claude/skills` and not synced.
