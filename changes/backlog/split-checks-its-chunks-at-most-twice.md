---
effort: XS
utility: S
---

# The split checks its chunks at most twice

In the `workout-tracker` run of 2026-11-02 the split took 34 minutes, 22 of
them in five rounds of the fresh verifier. `split-change-into-chunks/SKILL.md`
("Check, then commit") sends the chunks through the check again whenever a
fix changed a chunk's `journeys`, `after:` or design, with no limit.

The fourth round found that `after:` needs full chunk names, which
`run.sh`'s drift check already tests. The fifth found "only small gaps".

Proposed in the retro: two rounds at most, as in `implement-change`.

Evidence: `split-20261102-202534.jsonl` in
`~/Projects/workout-tracker/.git/run-logs/`.
