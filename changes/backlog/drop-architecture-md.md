---
effort: M
utility: M
---

# ARCHITECTURE.md goes in its current form

The user, on 2026-10-29: "I want to get rid of ARCHITECTURE.md in its
current form. It's not a good artifact."

It fails what a lasting artifact needs (`approved-criteria-outlive-the-change`,
"Lasting approvals"): nobody approves it, nothing checks it against the
code, and it is re-derived only when someone runs `repo-overview` again. An
agent has no memory and believes what it reads, so a stale description
leads it wrong with confidence.

Where it is written and read:

- `repo-overview` writes it (`repo-overview/SKILL.md`), and
  `restructure` reruns `repo-overview` on it (`restructure/SKILL.md:65`).
- `accept-criteria/SKILL.md` says it is not among what was agreed, and
  `tests/signals.sh` checks that `signals.sh` does not name it as a rule.
- `repo-setup-and-orientation` leans on it.

What it gives a fresh agent - orientation - the artifacts for lasting
approvals would give better: the concepts, how they relate, what can happen
to them, and the journeys. Where code lives, an agent finds by searching.

Depends on `approved-criteria-outlive-the-change`, whose artifacts take
over orientation.
