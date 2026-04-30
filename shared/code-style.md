# Code Style Principles

Two principles for agents writing or reviewing code.

## Clear Over Clever

Write the simplest, most boring code that works. Bugs are ten times harder to find than code is to write — cleverness makes bugs invisible; obviousness makes them stand out. The bar for "dumb but obvious" is high.

Concrete signals to push back on:
- Dense expressions or non-obvious idioms that hurt readability without earning their complexity
- Deeply nested conditionals where a flatter structure would be clearer
- Premature optimization without a measured bottleneck — the readable version is the right version

## Dead-Weight Free

Remove dead weight before committing. Dead weight includes:
- Commented-out code
- Debug prints and `console.log`/`print` statements
- Unused imports
- Leftover `TODO` comments about the current change
- Any other artifacts that don't belong in production code
