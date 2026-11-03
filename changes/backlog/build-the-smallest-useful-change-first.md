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

## Fewer journeys alone did not make it small

The second `workout-tracker` run, of 2026-11-02, built 4 journeys instead of
11, in 10 chunks instead of 17. It took 9 hours instead of about 10, and
about $99 instead of about $150. The time hardly moved, for two reasons:

- **Each chunk has a fixed cost** of about 20 to 35 minutes - two rounds of
  review and walk, and the fast check about four times - however little it
  builds. Chunk 09 built 242 lines of app code and 656 of tests, in 82
  minutes.
- **The hard part stayed.** Offline sync was chunks 03 and 05 (95 minutes),
  the cause of the one flaky test (44 minutes), and 5 of the 14 points under
  "For you" in `REVIEW.md`.

What the problem needed, as `CHANGE.md` states it: the plan in the gym,
"Letztes Mal" for each exercise across plans, today's sets written down, and
all of it without network. What could have waited, judged in the retro:
correcting and deleting trainings (chunk 09); the notices for refused
changes with their content in words; reordering exercises, renaming an
exercise everywhere, „Notiz übernehmen“, „schon im Plan“; deleting a plan
while one of its trainings is open; logging out every device on a new
password, and the 500 ms delay.

So the size of a change is counted in chunks, not journeys, and the
technical choices count as much as the features. See
`plan-the-build-and-decide-only-what-is-hard-to-change.md`, "workout-tracker,
the build", for the storage choice that made offline sync this large.

This changes the "Add a feature" journey in `SDLC.md`.
