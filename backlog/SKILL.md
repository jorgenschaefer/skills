---
name: backlog
description: Add to, extend or pick from the project's backlog in changes/backlog/. Use on "create a backlog item for ...", "add this to the backlog", "put that on the backlog", "what should we build next", "what's next from the backlog", and when /accept-change hands over a follow-up, /create-spec an item that could wait, or /debug a feature request.
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
- **The body is what the user had in mind**, as far as it got, or what the skill that handed it over found: an idea for `/idea` to start from. Add the evidence from the code - files, lines, where it showed up. Do not add a solution the user did not have.
- **Once `/idea` has run, the item also holds what it agreed**, below the notes, in the headings of this skill's `INTENT_FORMAT.md`. Keep those headings and what is under them when you extend the item.
- Write in the language the backlog's items already use; in an empty backlog, in the user's.

## Before anything else: convert an older backlog

Where `changes/backlog/` holds items in another shape - numbered files, a directory per item, no sizes, a `complexity` field - convert every one to the shape above: keep the body, drop `complexity`, and propose effort and utility where they are missing. Get the sizes confirmed, then commit the conversion on its own.

## Adding an item

When `/idea` hands you a new idea, it gives you the parts in `INTENT_FORMAT.md`'s headings. Write them as given, and add the item as below.

1. **Read the code the item touches.**
2. **Look for an item it overlaps.** Where one exists, add the new finding to that item instead of writing a new one, and propose its sizes again.
3. **Propose effort and utility**, each with a one-line reason. Write the file once the user confirms or corrects them.
4. **Commit that file alone.** When `/accept-change` or `/create-spec` handed you the item, do not commit - each commits the item with its own work.

## Picking the next item

1. **Rank** by utility minus effort, counting XS as 1 to XL as 5; on a tie the smaller effort goes first.
2. **Check the top three against the current code.** Where the problem no longer shows, show the evidence and propose deleting the item. Where a size no longer holds, propose a new one. Apply what the user agrees to and commit it, then rank again.
3. **Recommend one item and a runner-up**, each with why.
4. **Run `/idea` with the item the user picks**, naming its path, however settled it reads: an item is a quick note, and what it is meant to improve, and whether that is worth the work, are worked out there.

Do not move or delete a picked item. `/create-spec` moves it into the change's directory as `intent.md`, on the change's branch, and `/accept-change` deletes it with that directory once the change is accepted. `/solve-problem` deletes it with the commit that solves it, and `/idea` where the user agrees it is already solved or not worth the work.
