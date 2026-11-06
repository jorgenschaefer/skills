# Making a change

How a developer changes something in a project with these skills, whether the
project already has code or is new. It serves the ideas in
`docs/manifesto.md`. Changes too large for one session are not covered yet.

The developer is involved at three points: saying what they want, the
decisions that matter, and looking at the result. Everything else is the
agent's.

## The steps

1. **Say what you want**, in plain words. A clear, small change skips to
   step 3. An unclear or larger one goes to step 2.
2. **Explore** (skill). Find the real problem behind the request and how the
   domain works in the real world. Propose at least three approaches, the
   simplest first. Ask instead of assuming. Stop when the developer has a
   direction. Designs nothing. Writes the change file.
3. **Decide** (skill). Design what in this change is costly to change: how
   the user moves through the task, the design system, the data, and in a
   new project the stack. Ask the developer where there is a real choice,
   with options and a recommendation. Where there is only one sensible
   option, tell them in one line or a mock-up. Make every other decision
   without mentioning it. Writes the design, every decision told or asked
   and the mock-ups into `changes/`, and the ADRs into `docs/adr/`. Commits
   them before the build.
4. **Build.** Plain Claude Code: the smallest thing that does the job, in the
   domain's words, with the project's checks green.
5. **Check** (skill, with step 6). A reviewer with a fresh context tries to
   find what is wrong with the diff. A user stand-in uses the change on the
   running software as a real user would. The builder fixes what they find.
6. **Report.** Show the developer only what is hard to undo and what is
   still open. The developer tries it. If it does not solve their problem,
   back to step 2.
7. **Wrap up.** Commit. What could wait goes to the backlog. Delete the
   change file and its mock-ups.

## How explore and decide are split

The two skills were split along two different axes: `explore` by phase
(before there is a direction), `decide` by criterion (hard to undo). Things
fell between them in the first test run. The new split:

- **`explore` understands.** What are we solving, how does the real world
  work, and roughly which way do we go? It designs nothing.
- **`decide` designs what is costly to change, and the builder the rest.**
  The line runs between costly and cheap to change, not between look,
  interaction and data:

| | Costly to change: `decide` | Cheap to change: builder |
|---|---|---|
| **Interaction** | how the user moves through the task, what they enter when | the order of two fields |
| **Look** | the design system: components, type, colours, spacing | the colour of one button |
| **Data** | where it lives, what past records mean, deleting | an internal name |

A new app needs a design system, so `decide` asks about it, with real
alternatives the developer can see, not ASCII. In an existing app, a
completely new page is shown to the developer as a mock-up before it is
built, even when there is nothing to ask. So "tell" has two forms: a line of
text, or a picture.

## The change file

`changes/YYYY-MM-DD-<slug>.md`. It holds what was agreed for this one change,
so it can be built and checked. It is deleted when the change is done, so
nothing in it is read later as a rule. Git history keeps it.

```markdown
# <Title>

## Problem
<What is wrong, in the user's words, and one real instance.>

## Approach
<The general direction chosen. Also considered: <the others, one line each>.>

## Design
<What is costly to change: how the user moves through the task, the design
system, the data. Links to the mock-ups in changes/.>

## Decisions that matter
- <the decision> - held by <the code | a test of what | docs/adr/NNNN-<slug>.md>

## Could wait
- <item> -> backlog
```

`explore` writes Problem, Approach and Could wait. `decide` adds Design and
Decisions that matter: every decision it told or asked, each with what holds
it after the change file is gone. An empty section says "None."

## Decisions that matter

`docs/adr/NNNN-<slug>.md`, one file per decision that would be hard to undo
and that the code does not show. They outlive the change. A later
change that would break one brings it back to the developer. The format is in
`decide/ADR_FORMAT.md`.
