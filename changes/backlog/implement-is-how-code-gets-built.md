---
effort: M
utility: L
---

# implement describes how code gets built, and nothing else

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

## Pipeline protocol in the general skill

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

## What a departure is, in eleven places

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

## Four answers to a discovery

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

Open: what decides between asking now and recording. `CLAUDE.md`: "A skill
does not stop to ask the developer. It saves its questions for the
pipeline's fixed stops." `implement/SKILL.md:16`: "do not build past it".

## Related

- `docs-only-what-the-code-cannot-show` already notes README.md:36's
  "`/implement` builds `CRITERIA.md` itself".
- Both `CRITERIA_FORMAT.md` copies say Left standing is "Written by
  `/implement` when it builds this file directly".

Depends on `standard-follows-the-manifesto`, whose Utility section has the
same question of a decision the plan didn't cover.
