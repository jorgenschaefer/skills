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
- **What proves it** - the test that will pin it, or the command that will show it working. Every step has one. A step nothing can prove is a step whose result nobody can check, and it is where the build quietly diverges. A criterion about what a user sees or is refused is proven where the user acts - the action, the route, the form - not at a function behind it: whatever sits between the two can decide the outcome first, and the test stays green on a refusal no user ever meets.

## The boundary

**Say what this slice does not do**, and where the excluded thing lives instead. This becomes the ticket's `## Not here`, and it is what stops two slices building the same code twice.

## Rehearse the build

**Walk the finished plan as if you were building it, step by step.** At each step, two questions: do you know enough to build the right thing, and enough to build it right. The first is what the step is for, the second is how it is made. A step that leaves either open has produced a question - the builder hits the same gap anyway, alone, with nobody left to ask.

**Collect what you decided that would be expensive to reverse** - a format other code will be written against, a name that spreads, a dependency taken on. Say in the plan that you decided it. Being uncertain is not the only reason to surface something.

The questions go back at the approval, and `SKILL.md` says how. Carry into the ticket only what nobody there could settle, with what would settle it - a file to look at, a thing to try.

## No new requirements

The plan implements exactly the criteria the ticket quotes, and nothing beyond them.

The pull here is real: while reading the code you will see things worth doing that nobody asked for. They are not this slice.
