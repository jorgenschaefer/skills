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
2. **Understand** (`understand-change` skill). Find the real problem behind
   the request and how the domain works in the real world. Propose at least
   three approaches, the simplest first. Ask instead of assuming. Stop when
   the developer has a direction. Designs nothing. Creates a branch for the
   change, unless the developer wants it on the current one, and writes the
   change file on it.
3. **Design** (`design-change` skill). Design what in this change is costly to
   change: how the user moves through the task, the design system, the data,
   and in a new project the stack. Ask the developer where there is a real
   choice, with options and a recommendation. Where there is only one sensible
   option, tell them in one line or a mock-up. Make every other decision
   without mentioning it. Writes the design, every decision told or asked and
   the mock-ups into `changes/`, and the ADRs into `docs/adr/`. Commits them
   before the build, on the change's branch. If the change skipped step 2,
   creates the branch first.
4. **Build** (`build-change` skill, with steps 5 and 6), started by the
   developer in a fresh session. Starts from the change file: the smallest
   thing that does the job, in the domain's words, with the tests the change
   file names and the project's checks green.
5. **Check.** A reviewer with a fresh context (`/review-change`) tries to
   find what is wrong with the diff, and lists the decisions made during the
   build that are hard to undo and not in the change file. A user stand-in
   with a fresh context (`/try-change`) uses the change on the running
   software as a real user would. The builder fixes what the two found,
   then runs both once more and fixes what they find then.
6. **Report.** Show the developer only what is hard to undo and what is
   still open. What they settle goes into the change file, with what holds
   it. The developer tries the change. If it does not solve their problem,
   back to step 2.
7. **Accept** (`accept-change` skill), started by the developer once the
   change solves their problem. Checks that each decision that matters is
   held by something that outlives the change file. If the developer asks
   for a different behaviour here, it goes into the change file, and the
   build starts again in a fresh session. What could wait goes to
   the backlog, and the change file and its mock-ups are deleted and
   committed. The developer merges the branch. Merge without squashing: the
   change file and mock-ups are kept only in the branch's history.

## How understand-change and design-change are split

- **`understand-change` understands.** What are we solving, how does the real
  world work, and roughly which way do we go? It designs nothing.
- **`design-change` designs what is costly to change, and the builder the
  rest.** The line runs between costly and cheap to change, not between look,
  interaction and data:

| | Costly to change: `design-change` | Cheap to change: builder |
|---|---|---|
| **Interaction** | how the user moves through the task, what they enter when | the order of two fields |
| **Look** | the design system: components, type, colours, spacing | the colour of one button |
| **Data** | where it lives, what past records mean, deleting | an internal name |

A new app needs a design system, so `design-change` asks about it, with real
alternatives the developer can see, not ASCII. In an existing app, a
completely new page is shown to the developer as a mock-up before it is
built, even when there is nothing to ask. So "tell" has two forms: a line of
text, or a picture.

## The change file

The change file holds what was agreed for one change, and is deleted when the
change is done. Its format, and which skill writes which section, are in
`understand-change/CHANGE_FORMAT.md`. What holds each decision after the
change file is gone is in `design-change/SKILL.md`, under "Recording them".

There is no rule about test-driven development or coverage. In the first run
the bugs that mattered were the cases nobody had in mind, and such rules test
what someone has in mind.
