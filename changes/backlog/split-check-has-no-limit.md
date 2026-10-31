---
effort: S
utility: M
---

# The split checks its chunks again and again

`split-change-into-chunks/SKILL.md` ("Check, then commit", step 2) sends the
chunks through another check of the whole directory whenever a fix added a
chunk or changed a chunk's `journeys`, `after:` or design. There is no limit
on the rounds. `implement-change` has "Two rounds at most"; the split has
nothing like it.

In the workout-tracker run of 2026-10-31, the split checked its 17 chunks
seven times. Each check was a fresh subagent that took 4-6 minutes and read
the whole directory again. Each round found something new: the runner
refusing `Check:`, the wrong chunk order, chunks that were too big, unclear
owners of shared parts, the phone's login path. Only the seventh came back
clean.

The checks took 35 of the split's 48 minutes. The split cost $13.80, the
most of any session in the run (3.8M tokens read by the main session, 11.3M
by the checks). Nothing is built while it runs.

Evidence: `.git/run-logs/split-20261031-013200.jsonl` in
`~/Projects/workout-tracker`.
