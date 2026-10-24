---
effort: M
utility: L
---

# The usability check completes tasks and says where a person would hesitate

The check of what a user sees follows a script and reports only whether
each step worked. A screen where a person would not find the button, or
would guess what a field means, passes.

`MANIFESTO.md`, Usability: "An agent checks it by completing the tasks from
the acceptance criteria through the program's real interface, without
reading the code. It reports where a person would hesitate, guess or give
up, not only whether it got through." Usability is for "the people and
programs it is meant for".

Evidence:

- `critique/SKILL.md:22`: critique writes its driver "the scenarios - each
  screen, each size, the actions, and what should be visible after each".
  The driver "judges nothing" and reports what happened. The judging is done
  by critique, which has read the diff and the standard - and so knows what
  each control does.
- Only screens are driven ("where a user sees the change"). A change to a
  CLI or an API gets no task-based check of how it is to use.
- `/accept-criteria` drives the product too, but has read the diff, and its
  walk is with the user.

The reason the driver is a separate subagent - to keep the screenshots out
of the reviewer's every later turn - still holds if it reports hesitation in
text.
