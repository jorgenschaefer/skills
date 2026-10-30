---
effort: M
utility: M
---

# Ask how or why something happens, and get the answer in the user's concepts

The developer wants to ask how or why the software does something, and get
the answer in the journeys' words, told where the code thinks of things
differently. `SDLC.md`: "The user journeys are written in the user's words.
The code uses the same words for the same things." The user, on 2026-10-27: "a way to ask such a question … might be a completely
new backlog item", and about `explain-code`: "I still think explain-code is
misaligned, too, and I'm not 100% sure what its goal is."

- `explain-code` assumes a developer who once followed the code: "once the
  developer can no longer follow it" (its description). It ends by listing
  "the files that code is in" (`explain-code/SKILL.md`, "Show it").
- It smooths over where the code's concepts differ from the user's words,
  the second half of what the developer wants. The rewriter never sees the
  code and "may cut, merge and drop detail" (`explain-code/SKILL.md:28`);
  the checker reports only contradictions, and "a missing detail is never a
  finding" (`:29`). Nothing reports where the code's concepts do not match
  the words used where the answer shows.
- `debug`'s first outcome explains why the software works as it does, and
  overlaps this.
