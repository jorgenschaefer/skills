---
name: accept-change
description: Wrap up a change the developer has tried and accepted - check that every decision that matters is held by something that outlives the change file, put what could wait on the backlog, and delete the change file and its mock-ups. Started by the developer once the change solves their problem.
disable-model-invocation: true
---

# Accept a change

The developer has tried the change, and it solves their problem. Wrap it up so they can merge the branch.

The change is on its own branch. Its change file is in `changes/`. Read it.

1. **Check what holds each decision.** The change file is about to be deleted. Each decision under `## Decisions that matter` names what holds it afterwards: the code, a test, structure, or an ADR in `docs/adr/`. Check that each is there and holds the decision. Add what is missing, and run the project's checks.
2. **Put what could wait on the backlog** with `/backlog`, one item each.
3. **Delete the change file and its mock-ups** in `changes/`, and commit.

Then tell the developer the branch is ready to merge, without squashing: the change file and mock-ups are kept only in its history. Don't merge it yourself.

## Look out for

A start, not the limit.

- **The developer asks for a different behaviour.** Then the change is not ready to accept. Don't build it in this session. Write what they want into the change file and commit it. If it is hard to undo, run `/design-change` first. Then tell them to start `/build-change` in a fresh session.
