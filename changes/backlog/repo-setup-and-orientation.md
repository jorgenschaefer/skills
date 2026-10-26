---
effort: L
utility: M
---

# Set a repo up for the pipeline, and help me understand a repo

The user wants `repo-overview` and `ubiquitous-language` combined into two
uses, possibly two skills:

- **"This is a new repo, set it up for my pipeline."**
- **"I want to understand the repo"**: what it is about, how things
  interact, the data model, and so on.

## What is there today

- `repo-overview` writes `ARCHITECTURE.md` for "a developer who is new to
  this codebase", ending with "the few files a new developer should read
  first" (`repo-overview/SKILL.md:93`). `MANIFESTO.md`: "Humans do not read
  the code." The rule "What a fresh agent finds with one search or in one
  file needs no documentation" left the manifesto and waits to go into the
  standard (`standard-follows-the-manifesto`). Much of `ARCHITECTURE.md` is what an
  agent finds with one search, and it is re-derived only when someone runs it
  again; `restructure` reruns it ("Docs last").
- `ubiquitous-language` writes or refreshes `UBIQUITOUS_LANGUAGE.md` from
  the code's vocabulary and reports drift. The pipeline relies on it: the
  standard's naming rules, `find-criteria` and `criteria-to-tickets` asking
  for terms, `untangle` and `critique` reading it. This fits the manifesto:
  the developer "agrees with the user on the concepts: what the user calls
  things and how they fit together."
- Nothing sets a repo up for the pipeline. What the pipeline expects of a
  project is spread out: a `Check:` line in `CLAUDE.md` in the standard's
  form (`CODING_STANDARDS.md`, _Test Coverage_), written by a preparatory
  ticket (`criteria-to-tickets/SKILL.md:42`) or by `restructure` ("Checks
  first"); a `run` skill for starting the app, written by `implement` or
  `accept-criteria` when missing; structural rules as checks; and the
  glossary. `run-sh-without-a-check` is the failure this causes in a repo
  with no code yet.

Depends on `critical-user-journeys`, whose first journeys `repo-overview`'s
"Main workflows" would draft, on `run-sh-without-a-check`, and on
`method-layer`, which lists what the pipeline expects of a project.
