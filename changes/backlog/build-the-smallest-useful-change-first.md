---
effort: M
utility: L
---

# Build the smallest useful change first

The user, on 2026-10-31: "The pipeline has the same general problem as the
old software, specify it all up front, then build it all, then see how it
works. I'm wondering if cutting it down to an MVP in some form would be
useful when code is cheap as per agentic coding?"

The instance: the workout-tracker change. About 1-2 hours of design with the
developer gave 11 journeys and a 73-line `CHANGE.md`; the run built them in
17 chunks over about 10 hours, for about $150. The developer could use
nothing until acceptance, and every design decision - the offline copy, the
upload rules, raising targets, archiving, the app update - was made before
any of the software existed. Some things only showed on the running
software: the offline navigation problem came up in chunk 08, 5 hours into
the run.

Nothing in `SDLC.md`, `idea` or `design-user-journeys` speaks of the size of
a change. `idea` already settles "the one real instance" of the problem.

Chunk size does not stand against small changes: the split works by journey
step, not by journey (`split-change-into-chunks/SKILL.md`, "Writing a
chunk"). In this run "Training durchführen" was built across seven chunks,
and project setup was a preparatory chunk of its own (01).

Risks seen so far:

- The first step of a first change carries all the groundwork. The split
  allows no chunk that only builds what a later chunk uses, apart from
  preparatory ones, and says nothing about a single step over 2000 lines.
  Chunk 08 (phone start, offline copy, service worker) was one of three the
  split left near the size limit.
- Stored and wire formats are expensive to change once data exists, so
  "code is cheap" does not cover them.
- Each change has fixed costs: a design session and an acceptance with the
  developer, finding the checks, the split, the final review.

This changes the "Add a feature" journey in `SDLC.md`.
