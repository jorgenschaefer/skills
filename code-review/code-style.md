# Code Style Principles

Two principles for agents writing or reviewing code.

## Clear Over Clever

Write the simplest, most boring code that works. Bugs are ten times harder to find than code is to write — cleverness makes bugs invisible; obviousness makes them stand out. The bar for "dumb but obvious" is high.

Concrete signals to push back on:
- Dense expressions or non-obvious idioms that hurt readability without earning their complexity
- Deeply nested conditionals where a flatter structure would be clearer
- Optimization trades readability for speed — a worthwhile trade only when backed by measurement. Without a measured bottleneck, the readable version is correct.

## Single Responsibility Principle: One Thing, Nameable

The same coherence rule applies at every level — directories, files, classes, functions, methods: a unit should do one thing you can name without referencing its context. Size is a symptom, not the disease; split when pieces have distinct, independently nameable purposes; keep together what changes for the same reason — not just because something is long.

Concrete signals to push back on:
- Needs "and" to describe what it does, or its contents can't be summarized without listing them
- Extracted names reference the caller or context ("helper", "util", numbered variants) — scattering, not simplifying
- Contains clearly distinct steps or concerns crammed into one unit, regardless of length

## Dead-Weight Free

Remove dead weight before committing. Dead weight includes:
- Commented-out code
- Debug prints and `console.log`/`print` statements
- Unused imports
- Leftover `TODO` comments about the current change
- Any other artifacts that don't belong in production code
