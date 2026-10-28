---
effort: M
utility: L
---

# Slicing finds nothing left to decide

Slicing should only group the ACs into pieces that fit one context window.
In practice `/criteria-to-tickets` regularly finds questions for the
developer, so the change stops between approving the criteria and the run.
The user, on 2026-10-28: "criteria-to-tickets regularly asks questions.
find-criteria needs something so that does not happen so regularly anymore."

Evidence:

- `criteria-to-tickets/SKILL.md:52` reads the code each slice will touch
  and walks each slice against it "as its builder would", looking for
  behaviour the user sees that the ACs leave open, ACs that conflict, and a
  technical decision the code shows to be short. `:54` puts these to the
  user at the approval.
- `find-criteria/SKILL.md:9` and `:49` set the bar: the loop is done when
  "`/criteria-to-tickets` would not have to ask anything". Nothing in the
  skill gets there.
- In the pipeline's intended shape (`PIPELINE.md`, "A question found
  during IMPLEMENT"), IMPLEMENT runs without interruption and slicing decides nothing new; a
  question it still finds is decided within what was approved, recorded,
  and shown at acceptance.

Related: `adrs-at-the-slicing-approval`, about the ADRs put to the
developer at the same stop.
