# Tracer Bullets

The metaphor comes from *The Pragmatic Programmer*. A tracer bullet is a real bullet that glows in flight — fired so the shooter can see where they're aiming and adjust. In software, a tracer bullet ticket is a thin, end-to-end slice that goes from the user-facing surface all the way down to whatever it touches at the back, in a working but minimal form. Subsequent tickets thicken it.

The opposite — the **layer-by-layer antipattern** — is: ticket 1 is "build the database schema," ticket 2 is "build the data access layer," ticket 3 is "build the API," ticket 4 is "build the UI." None of those tickets ship anything users can see. None of them validate that the layers fit together until the very end, when it's expensive to discover they don't. If you find yourself producing a backlog where the first several tickets are all infrastructure with no user-visible behavior, stop and reorder.

Good slicing produces tickets like:

- "User can create a draft order with just a title (no items, no validation)" — ships a working but minimal end-to-end path
- "Drafts can have items added one at a time" — extends the path
- "Drafts can be submitted, triggering inventory check" — adds depth
- "Submission failures show a useful error" — hardens

Each one is shippable. Each one is independently testable. Each one delivers some user-visible value, even if small. If the project gets cancelled after ticket 2, you've still shipped something useful.
