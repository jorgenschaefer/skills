---
effort: L
utility: M
---

# Security beyond who may see and do what

`SDLC.md`'s Security goal: "Nobody can do or see more than they are
supposed to." Its rule for that is default deny: every way into the
software denies access unless a journey's "Who" allows it.
`implement-change`, `review-change` and `walk-user-journeys` hold a change
to that rule. Three parts of the goal are not about it:

- **The outside attacker.** Default deny covers someone without a login
  only where a way in exists that a journey names. Nothing looks at what
  the deployment exposes beyond that, and `upgrade-dependencies` never
  looks at security advisories.
- **An agent steered by text it read**, in two places:
  - the software, wherever it hands user text to an LLM;
  - the runner itself. Build sessions run unattended as
    `claude -p --permission-mode auto` (`run/session.sh`), read code,
    dependencies and web pages, and commit. The skills say that text read
    from outside is data, never instructions, and nothing checks it.
- **The secure path is the easy one**, since security that is hard to use
  gets worked around. No skill asks for it.

Parked on 2026-10-27 from an `/idea` session about security. Nothing has
gone wrong so far. dom handles names that can hold patient information.
