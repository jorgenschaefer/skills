---
effort: L
utility: M
---

# Security beyond who may see and do what

`MANIFESTO.md`'s Security goal: "Nobody can do or see more than they are
supposed to - a malicious user, an outside attacker, or an agent steered by
text it read." And for the writer: "The secure path is the easy one, since
security that is hard to use gets worked around."

Parked on 2026-10-27 from `/idea` on `security-in-the-standard`, whose
agreed problem is the developer vouching for who may see and do what. These
three parts are not about that policy:

- **The outside attacker.** The standard's attacker "holds a valid session
  and is changing the number" (`implement/CODING_STANDARDS.md:81`). Nothing
  covers what someone without a session can reach. `upgrade-dependencies`
  never looks at security advisories.
- **An agent steered by text it read**, in two places:
  - the product, wherever it hands user text to an LLM;
  - the pipeline itself. Build sessions run unattended as
    `claude -p --permission-mode auto` (`run/session.sh:89`), read code,
    dependencies and web pages, and commit.
- **The secure path is the easy one.** No skill asks for it.

Nothing has gone wrong so far. dom handles names that can hold patient
information.
