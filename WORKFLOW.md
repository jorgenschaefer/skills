# Changing an existing project

How a developer changes something in a project that already has code, with
these skills. It serves the ideas in `IDEAS.md`. Changes too large for one
session are not covered yet.

The developer is involved at three points: saying what they want, the
decisions that matter, and looking at the result. Everything else is the
agent's.

## The steps

1. **Say what you want**, in plain words. A clear, small change skips to
   step 3. An unclear or larger one goes to step 2.
2. **Explore** (skill). Find the real problem behind the request and how the
   domain works in the real world. Propose at least three approaches, the
   simplest first. Ask instead of assuming. Stop when the developer has a
   direction. Writes the change file.
3. **Decide** (skill). Name the decisions in this change that would be hard
   to undo. Ask the developer where there is a real choice, with options and
   a recommendation. Where there is only one sensible option, tell them in
   one line. Make every other decision without mentioning it. Writes the
   ADRs, and lists them in the change file.
4. **Build.** Plain Claude Code: the smallest thing that does the job, in the
   domain's words, with the project's checks green.
5. **Check** (skill, with step 6). A reviewer with a fresh context tries to
   find what is wrong with the diff. A user stand-in uses the change on the
   running software as a real user would. The builder fixes what they find.
6. **Report.** Show the developer only what is hard to undo and what is
   still open. The developer tries it. If it does not solve their problem,
   back to step 2.
7. **Wrap up.** Commit. What could wait goes to the backlog. Delete the
   change file.

## The change file

`changes/YYYY-MM-DD-<slug>.md`. It holds what was agreed for this one change,
so it can be built and checked. It is deleted when the change is done, so
nothing in it is read later as a rule. Git history keeps it.

```markdown
# <Title>

## Problem
<What is wrong, in the user's words, and one real instance.>

## Approach
<The approach chosen. Also considered: <the others, one line each>.>

## Design
<What was agreed about how it looks and behaves, if anything.>

## Decisions that matter
- docs/adr/NNNN-<slug>.md (new | replaced)

## Could wait
- <item> -> backlog
```

An empty section says "None."

## Decisions that matter

`docs/adr/NNNN-<slug>.md`, one file per decision that would be hard to undo
and that the code does not show. They outlive the change. A later
change that would break one brings it back to the developer. The format is in
`decide/ADR_FORMAT.md`.
