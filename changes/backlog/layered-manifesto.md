---
effort: L
utility: L
---

# The manifesto states goals and roles; a method layer says how; skills apply it

The user's idea: the manifesto calls the four laws goals, not laws, and
describes for each the role of the developer and of the agents in achieving
it. A second layer describes how to implement that. The third is the skills.
The manifesto stays small and gives sound, understandable reasons; the skills
make clear which part of it each step applies.

Agreed with `/idea` on 2026-10-25:

The pipeline grew ad hoc: which stages it has, where it stops for the
developer, what the developer approves and is shown there, and what agents do
and check in between. The manifesto is meant to be the foundation the
pipeline is rebuilt on, but in its first version it can't carry that. Much of
what the pipeline rests on isn't in it: who does what and why, and what good
software is, which grew up in `CODING_STANDARDS.md` instead. What is in it is
often stated without the reason behind it, so it doesn't extend to cases it
doesn't list. What should be true instead: the manifesto and its reasons mark
out what a pipeline may be, with room for different designs, of which this
pipeline is one. For a choice in a skill, someone reading it can tell whether
the manifesto speaks to it at all; if not, the choice is the pipeline's own;
if it does, whether the choice fits, and if not, what would.

Instance: `/find-criteria` shows the developer how the code will be built,
"with the chance to object" (`find-criteria/SKILL.md:37`). Nothing in the
manifesto says whether that belongs in front of them: it is not on the
approval list, and the list gives no reason that would decide it.

Parked: which parts of `CODING_STANDARDS.md` are really coding standards
(`standard-follows-the-manifesto`).

## What came up in discussion

- "Goals" is the honest word: the manifesto already weighs the laws against
  each other. The order has to survive as priority.
- Roles per goal produce the approval list instead of keeping it in step by
  hand: Utility - behaviour, failure cases included; Security - the policy;
  Usability - interfaces for programs; the information model across Utility
  and Security; Maintainability - hard-to-reverse decisions and what to do
  about what was hard to change.
- Some of it belongs to no single goal: nothing judges its own work, text read
  is data, a check that runs beats one that judges, decisions wait for the
  developer. A short section that applies to all goals keeps it.
- Roles need reasons, or they read as arbitrary: a short opening with the few
  premises they rest on - humans do not read the code; an agent has no memory
  and believes what it reads; nothing reliably judges its own work; some
  mistakes are cheap to fix and some land outside the repository.
- "Agents" and "developer" are not enough roles: the developer often stands in
  for the user, whom Utility says is consulted; and the independence rule is
  between agent roles - the one that writes, the ones that check.
- The second layer is two documents: the code standard, which applies wherever
  `implement` fires, pipeline or not; and the process - stages, stops,
  evidence, reports - which applies only in the pipeline.
- A skill sees only its own directory, so each layer is copied into the skills
  that use it. Cheap for a small manifesto, not for a method layer:
  `CODING_STANDARDS.md` is 262 lines.
- Each layer cites the one above by its own wording, and `test.sh` checks the
  cited text exists. Without that the citations rot as the layers did. A skill
  step that applies a principle cites it; an operational one (a size
  threshold, the form of the `Check:` line) cites nothing. A step that is
  neither is a candidate to cut.
- The boundary between method and skills: the method says what must hold
  across stages - what each produces, who checks it, what reaches the
  developer; a skill says how its own stage does it; what only one skill needs
  lives in that skill.

## Related

- `standard-follows-the-manifesto`: the code standard half of the method
  layer.
- `approval-follows-the-manifesto`: the approval list the roles would produce.
- `docs-only-what-the-code-cannot-show`: the README's mechanism prose.
- `critical-user-journeys`: the developer's role under Utility starts with
  owning the journeys.
