---
name: backlog
description: Add to, extend or pick from the project's backlog in changes/backlog/. Use on "create a backlog item for ...", "add this to the backlog", "put that on the backlog", "what should we build next", "what's next from the backlog", and when /accept-criteria hands over a follow-up.
---

# Backlog

## The item

`changes/backlog/<slug>.md`, one file per item:

```markdown
---
effort: M
utility: L
---

# <Title>

<Body>
```

- **Sizes** run XS, S, M, L, XL. Effort is the work to build it; utility is what it gives the user.
- **The body is what the user had in mind**, as far as it got: an idea for `/idea` to start from, or the problem `/idea` already settled. Add the evidence from the code - files, lines, where it showed up. Do not add a solution the user did not have.
- Write in the language the backlog's items already use; in an empty backlog, in the user's.

## Before anything else: convert an older backlog

Where `changes/backlog/` holds items in another shape - numbered files, a directory per item, no sizes, a `complexity` field - convert every one to the shape above: keep the body, drop `complexity`, and propose effort and utility where they are missing. Get the sizes confirmed, then commit the conversion on its own.

## Adding an item

1. **Read the code the item touches.**
2. **Look for an item it overlaps.** Where one exists, add the new finding to that item instead of writing a new one, and propose its sizes again.
3. **Propose effort and utility**, each with a one-line reason. Write the file once the user confirms or corrects them.
4. **Commit that file alone.** When `/accept-criteria` handed you the item, do not commit - it commits the item with its deletion.

## Picking the next item

1. **Rank** by utility minus effort, counting XS as 1 to XL as 5; on a tie the smaller effort goes first.
2. **Check the top three against the current code.** Where the problem no longer shows, show the evidence and propose deleting the item. Where a size no longer holds, propose a new one. Apply what the user agrees to and commit it, then rank again.
3. **Recommend one item and a runner-up**, each with why.
4. **Hand on the item the user picks.** Where it states a problem a reader who was not here could restate, tell the user to type `/find-criteria changes/backlog/<slug>.md`. Otherwise run `/idea` with the item.

Do not delete a picked item; `/accept-criteria` deletes it once the change is accepted.
