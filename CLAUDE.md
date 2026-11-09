This is a suite of skills for creating High Quality Software with coding agents.

docs/manifesto.md says what good software with coding agents needs. Read it before adding a skill or changing what one is for. Every skill should serve one of its ideas. docs/workflow.md says what each skill is for, and docs/evidence/ what the test runs showed.

A skill only sees files in its own directory, so a file two skills need is copied into each.

Every change to a skill comes from evidence: name the observation it answers. Don't add rules because they feel right.

A skill that changes from evidence has two parts. The core comes first: the idea the skill serves and the steps of a typical run. It changes only when a step is wrong in typical runs, or when the manifesto changes. The rest of what was learned goes under `## Look out for` at the end: kinds of risk to look at first, and special situations with what to do in them. Ask of each sentence: if it were deleted, would the skill still do its job in a typical run? If yes, it belongs in `## Look out for`. Write each item as a general category, not as the incident; the incident stays in docs/evidence/. The list ends by saying it is a start, not the limit. When you add an item, merge it with one that is the same category, and drop any item that a test, structure, a tool fix or the core now holds.

README.md says how to install the skills and what the scripts do.

Fast check: `./test.sh`
