---
effort: M
utility: L
---

# Acceptance shows evidence a script reran, not the agent's account

At acceptance the developer, who does not read the code, gets the agent's
account of each criterion: "for each one say what you did and what you saw"
(`accept-criteria/SKILL.md:25`). Tests come in only where an AC is not met
(`:35`). The developer cannot tell an executed proof from a judgement.

`MANIFESTO.md`, under what the report shows: "the checks that prove it,
rerun by a script rather than reported by the agent. Example runs, requests
and responses where the human needs to see the behaviour itself. Tests are
presented as a list of what they prove." And under Utility: "Where no check
can show it, it is marked as judged, and a check that only approximates it
says so." Under checking: "Where a criterion is judged, the review is
adversarial."

Evidence:

- The runner reruns the checks itself (`run/checks.sh`), but as one
  pass/fail for the whole suite; nothing turns that into evidence per AC.
- Whether an AC is executed or judged is decided by the builder after the
  fact: Left standing lists "each criterion no automated test proves, and
  how it was checked instead" (`implement/SKILL.md`, "Finish"). `CRITERIA_FORMAT.md` has no
  place to mark an AC as judged, or a check as only approximating it, at
  approval time.
- Nothing hands the judged ACs to a reviewer whose job is to show they are
  not met. `critique` refutes its own findings, which is a different thing.

- critique's output now opens with a Tasks section: one line per AC its
  driver was handed, completed, given up or skipped and why
  (`critique/SKILL.md`, "Output"). It is a per-AC record of the judged
  usability check, but it reaches the developer only where a caller passes
  it on - `implement`'s Left standing and `REVIEW.md` carry findings, not
  tasks - and a hesitation the build fixed reaches them not at all.

From the review: the walk stays, for usability and for the problem as a
whole; the script-made table comes before it.

Depends on `approved-criteria-outlive-the-change`, which makes tests say
which approved criterion they prove.
