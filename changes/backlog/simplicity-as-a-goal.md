---
effort: L
utility: XL
---

# Every stage adds, none takes away: simplicity as a goal

The user, on 2026-11-03, after the retro of the `workout-tracker` run of
2026-11-02: "I feel the whole process is missing the KISS+YAGNI principles.
Claude is thinking very complicated all the time, agreeing to complicated
solutions. Do we need that as an underlying rule for everything?"

## Rules that exist and did not hold

- `implement-change/SKILL.md`: "Write the least code that does the job."
- `idea/SKILL.md` and `design-user-journeys/SKILL.md`, "Weigh what the user
  says": "look for what would make it better - a gap, a simpler form, …".
- `design-user-journeys/VERIFY.md`: "Nothing unasked for."

The code the builds wrote was reasonable for what they were asked. The
complexity came in with the decisions before the build.

## Where it came in

**Every adversary looks for gaps; none looks for excess.**

- `design-user-journeys/VERIFY.md` asks, for each thing the user does, to
  "list the ways it can fail", and to probe feedback, undo and layouts.
  "Nothing unasked for" is one line beside them. In this design (session
  `707c3e2c`, 15:51) the verifier's findings added: all trainings kept on
  the phone, a third state „speichert …“ for the save display.
- `walk-user-journeys` tries "the edges no journey names".
- `review-change` reports what is missing or wrong, and the build fixes it.

Each finding becomes a journey line, a test, a walk and a fix. No agent says
"this step does not serve the problem".

**Choices come as menus of reasonable options.** `design-user-journeys` asks
for three alternatives per step, not whether the step is needed. The pushback
came from the developer: "1 wäre nett, 2 reicht eigentlich erstmal" (14:38).

**The technical decisions had no stage at all.** The agent's first draft had
its own `Op` protocol, Dexie and SQLite; the developer cut it down twice. The
simplest storage that fits the agreed "last write wins" - one document,
kept on the phone and sent whole - was never offered. See
`plan-the-build-and-decide-only-what-is-hard-to-change.md`, "workout-tracker,
the build".

**The result:** 4 journeys with 37 steps and 21 "When it goes wrong"
cases, 132 Playwright tests, 9 hours of build. See
`build-the-smallest-useful-change-first.md` for what could have waited.

## Proposed in the conversation

1. **A goal in `SDLC.md`**, so the skills have a reason to point at: the
   smallest software that solves the problem; every feature, failure case
   and moving part earns its place. Less software is less that can break the
   user's trust, so it serves Utility and Maintainability.
2. **The adversaries look for excess as hard as for gaps.** Every verifier
   and reviewer reports "what could go" as findings of equal weight, each
   tied to the part of the problem it does not serve.
3. **A failure case earns its place.** A "When it goes wrong" case goes into
   a journey only where it would really happen to this user: each one costs
   a test, a walk and usually a fix.
4. **The simplest option comes first, and is named so**, at every decision,
   in the design and the technical decisions alike.

Points 2 and 3 do the work; 1 gives them their reason. A rule repeated in
every skill would not: the rules above already say it.

## What it touches

`SDLC.md`; `design-user-journeys` and its `VERIFY.md`;
`split-change-into-chunks/VERIFY.md`; `review-change`; `walk-user-journeys`;
`idea`; the four copies of `CHANGE_FORMAT.md` and the copies of
`JOURNEY_FORMAT.md` where they speak of failure cases.
