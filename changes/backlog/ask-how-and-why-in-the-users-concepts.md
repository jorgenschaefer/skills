---
effort: M
utility: M
---

# Ask how or why something happens, and get the answer in the user's concepts

The manifesto: "On request, an agent explains any part of the program in
those words, and says where the code thinks of things differently." The
user, on 2026-10-27: "a way to ask such a question … might be a completely
new backlog item", and about `explain-code`: "I still think explain-code is
misaligned, too, and I'm not 100% sure what its goal is."

- `explain-code` assumes a developer who once followed the code: "once the
  developer can no longer follow it" (its description). It ends by listing
  "the files that code is in" (`explain-code/SKILL.md`, "Show it").
- It smooths over where the code's concepts differ from the user's words,
  the second half of the manifesto's sentence. The rewriter never sees the
  code and "may cut, merge and drop detail" (`explain-code/SKILL.md:28`);
  the checker reports only contradictions, and "a missing detail is never a
  finding" (`:29`). Nothing reports where the code's concepts do not match
  the words used where the answer shows. Moved here from `refactor-phase`
  on 2026-10-29, which builds on `explain-code` once this item has settled
  what it is for.
