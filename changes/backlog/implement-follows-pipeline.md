---
effort: L
utility: L
---

# IMPLEMENT follows PIPELINE.md, and implement describes how code gets built

`PIPELINE.md` now says what the pipeline is meant to be. The skills, the
runner and the formats were written before it, and in places do something
else. The user, on 2026-10-28: "The next step then is to hold the skills to
that description." Split by phase from `hold-the-skills-to-pipeline` on
2026-10-29.

The developer's account of the pipeline and every disagreement decided
while writing `PIPELINE.md` are in the change's `CRITERIA.md`, `## Left
standing`, at commit 4a70caf (`git show 4a70caf:changes/2026-10-28-pipeline/CRITERIA.md`).

Deviations in IMPLEMENT known when `PIPELINE.md` was accepted:

- A question found during IMPLEMENT: `implement/SKILL.md:16` ("ask ... and
  do not build past it") and `:54`, `CODING_STANDARDS.md:97`, the runner's
  `undecided` halt (`run/prompts.sh:31`), the final review deferring rather
  than building a best guess (`run/prompts.sh:101`),
  `.claude/skills/align/SKILL.md:51`. Until this is done, sessions in this
  repository meet only implement's "ask", since `CLAUDE.md` no longer says
  to save questions for the stops.
- A departure counted only in "None." groups: `run/prompts.sh:23`,
  `TICKET_FORMAT.md:38`, `criteria-to-tickets/SKILL.md:37`,
  `CRITERIA_FORMAT.md:27`. `PIPELINE.md`: anything that changes what was
  approved.
- The single-ticket brief (`criteria-to-tickets/SKILL.md:96`) claims to
  match the runner's (`run/prompts.sh:19-33`) and does not.
- Re-slice after drift: `run/drift.sh:113` against
  `criteria-to-tickets/SKILL.md:85-86`; `attempts` runner-owned
  (`TICKET_FORMAT.md:12`) but reset by a re-slice.
- The check line's form: `critique/SKILL.md:28` against `run/checks.sh:67`.
  `check_line` matches only the strict form, the command in backticks and
  nothing after it. A line such as ``Check: true``, without backticks, is
  not read at all: the runner asks a session for a command
  (`run/checks.sh:63`) and says nothing about the line it skipped, so a typo
  quietly changes what every build runs. `critique` reports such a line as a
  should-fix, but only when it reviews. Found by the reviewer of a runner fix
  while driving the runner, in the acceptance of the fast and slow checks
  change.
- What critique is handed in the CRITERIA path: `implement/SKILL.md:18`
  against `:36` and `run/prompts.sh:101`.
- Alerts shown to fire: `PIPELINE.md` (IMPLEMENT, Checked by) has the
  reviewer check that each thing someone has to hear about sets off its
  alert. No skill does this.

## implement describes how code gets built, and nothing else

Merged from `implement-is-how-code-gets-built` on 2026-10-29: it rewrites
the same paragraphs in `implement`, `run/prompts.sh` and
`criteria-to-tickets` as the deviations above.

`implement` is meant to describe implementing, the way `git-commit-message`
describes how a commit happens: it is how code gets built, whoever asks.
`run/prompts.sh:11` states the same intent: "`/implement` is the generic build
skill - it fires when anyone asks for code and knows nothing about tickets,
statuses or halt kinds."

The user's idea: what `implement` gained beyond that moves to a skill of its
own, say `implement-ticket`. Both skills assume that their input, once they
are called, is user-approved. Only what they discover themselves may need the
user's review, and for each such discovery they decide: ask now, or add it to
"discovered" in the output.

### Pipeline protocol in the general skill

- `implement/SKILL.md:18` is a paragraph on `CRITERIA.md`: its ACs, its
  technical decisions and AC groups as limits, departures, writing `## Left
  standing` into the file and committing it with the change.
- `:64`, what the report leaves standing, is cut for the pipeline: departures
  from a technical decision or an AC group, names not taken from the glossary,
  and "a skill or runner that called you collects it into its own `## Left
  standing`".
- The ticket protocol is stated twice outside the skill: in the runner's
  brief (`run/prompts.sh:23`) and, for a single ticket, in
  `criteria-to-tickets/SKILL.md:93`, which tells `/implement` "what the runner
  tells every build".

### What a departure is, in eleven places

What counts as a departure from what was approved is restated in about
eleven files, each in its own words: both `CRITERIA_FORMAT.md` copies,
`TICKET_FORMAT.md`, `criteria-to-tickets/SKILL.md`, `implement/SKILL.md:18`,
`accept-criteria/SKILL.md`, the runner's briefs in `run/prompts.sh` and
README.md, among others. In the 2026-10-27 change that replaced nudges with
AC groups, every review round found another file that disagreed - the
README took three - and acceptance found one more: the runner's briefs
counted only technical decisions, not a "None." AC group (fixed in
1efa8e6). `run/prompts.sh` changed 20 times between 2026-09-01 and
2026-10-27. The build suggested one sentence kept in one place; a skill
sees only its own directory, so it would be copied, as `test.sh` already
keeps `CODING_STANDARDS.md`'s copies identical.

A trap in the same file: the briefs are double-quoted bash strings, so a
bare `"` in one silently vanishes from what the session reads. Nothing
checks it; it was caught on 2026-10-27 only by driving the runner.

### Four answers to a discovery

What a build does with something its input does not settle:

- `implement/SKILL.md:16`: ask, "before or during the build - and do not
  build past it".
- `:52`: stop, on "a decision the request does not settle and that is not
  yours to settle".
- `:69`: report "other decisions that would be costly to reverse".
- `run/prompts.sh:23`: "every implementation question on the way: decide it,
  and report it".

Nothing says when which one applies. `MANIFESTO.md`: "Something found while
building that may change what the user wants is a decision the plan didn't
cover, and waits for the developer." And: "Decisions that are the
developer's wait for them. The change is not accepted until they are
decided."

`PIPELINE.md` ("A question found during IMPLEMENT") settles it for the
pipeline: within what was approved the agent decides; where the answer
would change it, the agent builds its best guess, records it as a
departure, and ACCEPT puts it to the developer. `implement` outside the
pipeline, asked by someone in the session, is still open.

### Related

- Both `CRITERIA_FORMAT.md` copies say Left standing is "Written by
  `/implement` when it builds this file directly".

Depends on `standard-follows-the-manifesto`, whose Utility section has the
same question of a decision the plan didn't cover.
