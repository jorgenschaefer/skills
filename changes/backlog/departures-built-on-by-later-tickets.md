---
effort: M
utility: S
---

# A departure later tickets build on is expensive to refuse

Building past an agreed decision and approving the departure at acceptance
(README.md:60, the final review in `run/prompts.sh`) is sound: nothing
merges without acceptance. A build that needs more than a technical
decision allows builds it and records the departure (`run/prompts.sh:23`).
But a "no" gets expensive once later tickets build on the departure: each of
them has to be redone. The review suggested that such a departure halts.

No instance yet. Split out of `approval-follows-the-manifesto` by `/idea` on
2026-10-27.
