---
effort: L
utility: M
---

# Set a repo with code up for these skills

The user wants a use for "This is a new repo, set it up for my pipeline."
`repo-overview` stays for the other use, "I want to understand the repo",
and is a good starting point for this one.

Nothing sets a repository up today. What the skills expect of a project is
spread out:

- the `Fast check:` and `Slow check:` lines in `CLAUDE.md`, which `run.sh`
  reads, and with no line naming a fast check, the runner asks a session to
  find one (`run/checks.sh`, `find_checks`);
- a `run` skill for starting the software, which `implement-change` writes
  where there is none (`implement-change/SKILL.md`, "Before you write
  anything");
- `journeys/`. In a repo with code and no journeys, `design-user-journeys`
  writes the journeys a change affects from what the software does today,
  one change at a time. Nothing writes the rest, so the software's other
  journeys have no test that walks them;
- `UBIQUITOUS_LANGUAGE.md`, which `init-ubiquitous-language` writes.

`pipeline-in-an-empty-repo` creates the same files in a repo with no code.
Whichever of the two is built first decides how they are created, and the
other follows it.
