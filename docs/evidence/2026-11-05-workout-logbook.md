# Evidence: the workout logbook, 2026-11-05

What we observed when using the new skills on a real project. Skills change
because of what is in here, not because of how they feel. Each observation
says what happened, where to look, and why it happened, as far as we know.

## The test run

On 2026-11-05, a new app in `~/Projects/workout-tracker-3`: a workout logbook
that works offline at the gym, to replace a Google Sheet. It was a new project,
not an existing one.

| Step | Session | Commits |
|------|---------|---------|
| `explore`, then `decide`, then the mock-ups | `a01516c8` | `146eeb2` to `50cc43c` |
| Build, plain Claude Code, fresh context | `598465eb` | `9242341` to `0f663b1` |
| Review by hand, then questions about structure, tests and TDD | `3ee51f13` | none |

The session logs are in
`~/.claude/projects/-home-jorgen-Projects-workout-tracker-3/`.

## Observations

### 1. UI/UX was never put to the developer

`explore` wrote a "rough sketch" of the screens in ASCII and moved on.
`decide` asked about the address and the login only. The developer had to ask
"Shouldn't we design the user interactions first?", and then again for real
alternatives as clickable mock-ups instead of ASCII.

Why: `explore` says "a rough sketch in text is often enough". `decide` says
"layout ... is not hard to undo", so it had no reason to bring it up.

The developer's view: the line runs between look and interaction. Size and
colour are easy to change. Whether the interaction matches the domain and how
the user really works is not, and it reaches into the data. In this app,
saving after every set led to IDs made on the phone, a queue of saves and
replayed saves. This belongs in `decide`.

### 2. The change file missed what the build needed

When asked "Can I hand the plan to an agent in a fresh context?", the agent
found three gaps: the stack, part of the data shape, and the mock-ups were
only in the chat or the scratchpad.

Why: `decide` says to tell the developer about one-option decisions, but not
to write them down. "The code is the record" fails before there is code.
Nothing says the mock-ups belong in the repository.

### 3. The skills assume an existing project

`docs/workflow.md` and `decide` ("read the code the change touches") assume there
is code. In a new project there is none, which made observation 2 worse.

### 4. Everything was committed to main

The change file, the design and the ADR went straight to `main`, and so did
the five build commits. `decide` held back the ADR until "the first build
commit", but the developer wanted it committed before handing over.

### 5. `decide` did not start during the build, and the builder decided alone

The build loaded only `nextjs-project-setup` and `git-commit-message`. Its
report says "No new ADR: none of these decisions seemed hard to undo". By
`decide`'s own list, several were:

- saves the server refuses are dropped (lost trust, and the root of the data
  loss the review found);
- the login limit is global, so anyone can lock the developer out;
- every screen is a query string on `/` (URLs, and a pattern much else rests on);
- results are stored in a JSON column (shape of stored data);
- Node 26, TypeScript 7, Prisma held at 7.10 (the stack).

The description alone does not make `decide` start in the middle of a build.

### 6. Nobody but the builder checked the build

No fresh-context review and no user stand-in ran; the check skill does not
exist yet. The builder walked the app in Chrome itself: happy paths and one
offline case. It never tried a database outage, bad input or parallel logins,
which is where the review found the serious bugs.

### 7. The report was good, but came too late

"Decisions I made that you may want to know about" and "Small gaps" are close
to what step 6 of `docs/workflow.md` asks for. But the developer was told after the
build, when they should have been asked before it.

### 8. The review found serious bugs the build missed

The developer asked for bugs, ways to see or do more than allowed, and code
that makes future changes hard. The reviewer confirmed its two worst
suspicions with throwaway tests instead of guessing. Main findings:

- A database outage answers 409, and the client drops the save. Saves lost
  silently.
- The UI accepts values the server refuses. That entry then never saves again.
- The badge for refused saves disappears after a minute.
- Units belong to the exercise, so changing them rewrites past sessions.
- The login limit can be passed with parallel requests, and anyone can trigger
  it for everyone.
- Login sessions cannot be ended, and the whole logbook stays on the phone.
- Every route has to remember to check the login.
- "Old saves keep working after a deploy" is only a comment.
- Last-writer-wins was in the change file, which gets deleted, and nowhere else.

### 9. Plain Claude Code built a good structure

The review called the structure a good base: clean layers, the rules as pure
functions in one place, one contract between client and server, every save a
repeatable upsert, the offline logic kept in one layer. The serious problems
were not about structure.

### 10. TDD would not have prevented the bugs that matter

The bugs come from assumptions nobody noticed: a failing database, parallel
requests, a gap between client and server, a data-model choice. TDD tests the
behaviour the developer has in mind, and these were exactly the cases nobody
had in mind. The code that looks test-driven is already the cleanest. A rule
like "test more" or "80% coverage" would be weaker still. None of the review's
bugs would be caught by the tests that exist.

### 11. A short list of tests by kind of risk would have caught them

- Each outside dependency fails: what does the code answer, and does the
  client retry?
- Each contract between two parts is tested from both sides together, and old
  saves still parse.
- Security code is tested under parallel and hostile use.
- Anything that can lose data has a test saying it is not lost.

For this app, these four would have caught the data loss, the validation gap
and the rate-limit bypass.

### 12. Conventions are better turned into structure

A rule each piece of code has to remember will break. Check the login once for
all routes, build every save one way, retry by default. Then the wrong version
is hard to write.

### 13. Some problems were design questions nobody asked

- How are things deleted? There is no delete at all, and adding it later
  touches the queue and may need tombstones.
- Does a field change over time, and what do past records mean then? (The
  units.)
- How many users? "No accounts" was decided, but not what it costs to undo.
- A pattern that makes every new record type touch nine places.

The review session itself said these belong in `decide` and the ADRs, not in
tests.

### 14. Things fell between `explore` and `decide`

The interaction design (1) and the design questions about data (13) belonged
to both skills, and neither did them. `explore` also proposes approaches that
are often hard to undo themselves, such as "offline first".

Why: the two skills were split along different axes. `explore` was split by
phase (before there is a direction), `decide` by criterion (hard to undo).
Those axes cross, so some things landed in both and some in neither.

In the discussion afterwards, the line between look and interaction did not
hold either. A design system is look, but every screen is built on it, so it
is costly to change. The developer also wants to see a completely new page
before it is built, even when there is nothing to ask.

Agreed: `explore` understands and designs nothing; `decide` designs whatever
is costly to change, whether interaction, look or data, and the builder the
rest. The split is in `docs/workflow.md`.

## What this suggests

Not yet agreed. For discussion.

- **`decide` looks too narrowly.** It missed the interaction design (1), what
  happens to user input when something fails (5, 8), how access ends and where
  data stays (8), questions about the life of the data (13), and patterns
  (12, 13). The sentence that puts layout next to colour has to go.
- **`decide` must write down what it tells, not only what it asks.** The
  one-option decisions belong in the change file (2). Before the code exists,
  the code cannot be their record. Decisions that only live in the change file
  are lost when it is deleted (8).
- **Mock-ups belong in the repository** next to the change file (2).
- **`decide` needs a more reliable way to start during a build** than its
  description (5).
- **The build may need guidance after all.** The structure was good without
  it (9), but the tests that catch real bugs were missing (11).
- **A promise to the outside world gets a test that holds it** (8, 11). This
  is the useful core of the old hard tests.
- **The check step matters** (6, 8). The reviewer should probe the four kinds
  of risk in 11, with throwaway tests where a suspicion can be confirmed.
- **The workflow has to cover new projects** (3) and say which branch a change
  goes on (4).

## Open questions

1. Does the build need a skill, a CLAUDE.md rule, or nothing?
2. Where does the list of tests by kind of risk live: in the build, in the
   check, or both?
3. How does `decide` start reliably in the middle of a build?
4. Does a change get its own branch, and who creates it?
