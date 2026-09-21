# Planning one slice

What goes in a ticket's `## Plan`. One slice at a time, worked out against the code as it actually is.

## Read before you plan

**Open the files the slice will touch.** Name them in the plan. A plan written against an imagined codebase is the failure this step exists to prevent: it reads as confident, it survives review, and it falls apart in the first ten minutes of the build, by which time the person who could have caught it is gone.

**Find what already does this, or half of it.** The plan should reuse what is there. A step that writes something the project already has is a step that adds a second way to do it.

## The plan is steps, in order

Each step is small enough to be wrong on its own - if a step fails, it should be obvious which one and what it was trying to do. A plan of three steps that each take a day is not a plan, it is a summary.

Each step says:

- **What changes**, in a sentence.
- **Which files**, by path. New files are marked as new.
- **What proves it** - the test that will pin it, or the command that will show it working. Every step has one. A step nothing can prove is a step whose result nobody can check, and it is where the build quietly diverges.

## The boundary

**Say what this slice does not do**, and where the excluded thing lives instead. This becomes the ticket's `## Not here`, and it is what stops two slices building the same code twice.

## What is still unknown

**Name what you could not settle from reading**, and what would settle it - a file to look at, a question for a person, a thing to try. A plan that pretends to a certainty it does not have costs more than one that flags the gap, because the builder discovers the gap anyway and has to decide alone.

## No new requirements

The plan implements exactly the criteria the ticket quotes, and nothing beyond them.

The pull here is real: while reading the code you will see three things worth doing that nobody asked for. They are not this slice. `IDEAS.md` is the parking lot, and a criterion the solution should have had is something to say out loud, not something to plan in.
