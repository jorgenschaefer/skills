---
name: init-project
description: Set a project that already has code up for this suite of skills - its glossary, its first user journeys and a hard test for each. Use on "/init-project", "set this project up for the pipeline", "start using these skills here".
disable-model-invocation: true
---

# Set up an existing project

Give a project that already has code what the skills of a change expect to find: a glossary of its domain terms, a few user journeys, and a hard test that walks each journey. Everything else grows one change at a time, as the changes touch it.

This skill's `JOURNEY_FORMAT.md` settles the shape of a journey, and `UBIQUITOUS_LANGUAGE_FORMAT.md` the shape of `UBIQUITOUS_LANGUAGE.md`.

**If the project has no code yet, say so and stop.** There is nothing to set up from. Its first change is designed with `/idea` and `/create-spec` like any other.

**Make a branch named `YYYY-MM-DD-init-project`** before you write anything.

## Read the project

Find the things the user works with and what they do to them, in the user's words: "a reviewer rejects an application", not "calls `update()`". Read:

- the entry points: routes, the API, the CLI, the screens;
- the stored and wire formats: the schema, the migrations, and the resources and events of a public API or message format;
- the existing tests, and how the software is started;
- `journeys/` and `UBIQUITOUS_LANGUAGE.md`, if they exist.

If the codebase is larger than you can hold at once, have parallel `Explore` subagents each survey one area, and merge what they find.

## Agree the journeys

**Propose three to six journeys** that the software already has and that no file in `journeys/` describes. Name the code each one rests on. Recommend the one to three that would hurt the user most if they broke, and say why. The developer picks.

**Write each picked journey from what the software does today**, in `JOURNEY_FORMAT.md`'s shape. Confirm each with the developer, one at a time. Ask who goes through it, since "Who" grants access. If the developer wants the software to work differently, write the journey as it is anyway, and name the wish as a change for `/idea`.

**End your turn at the first question mark.** One turn, one open question.

## Agree the domain terms

**Propose terms from two sources**: the words the agreed journeys use, and the things in the stored and wire formats. Leave out what is there only for the code: IDs, join tables, timestamps, sync columns. Each entry is one sentence, in `UBIQUITOUS_LANGUAGE_FORMAT.md`'s shape. If the code uses two names for one thing, propose one as the term and the other as an alias to avoid.

**The developer cuts what they don't want.** If the project already has a glossary, propose only the terms it lacks, and follow the format's updating rules for the entries already there.

**Write the agreed terms into `UBIQUITOUS_LANGUAGE.md`.**

## Build the hard tests

**Each agreed journey gets one hard test that walks it from the outside.** The test clicks, types or calls the API, and never calls the code's internals. It names its journey and each step it checks. A step marked *(judged)* gets no check.

**If the project has no way to test from the outside, choosing one is a hard decision.** Show the options, the simplest first and called the simplest, with a recommendation. The developer chooses.

**If the tests will not fit in one session, do not start them.** Write the journeys and the test tooling into `changes/YYYY-MM-DD-init-project/spec.md`, and hand it to `/create-plan`.

**Otherwise, build the tests with `/implement-code`.** Give it as its spec the journeys, the test tooling the developer chose if they chose one, and this rule: each test passes against the software as it is, so break the code it walks once and watch the test fail. A test never seen failing pins nothing. Tell it that you commit.

## Commit

Commit the journeys, the glossary and the tests together, with `git-commit-message`. If the tests went to `/create-plan`, commit `spec.md` in their place. Stage only these files; never `git add -A`. Merging the branch is the developer's.

Report the journeys and terms you wrote, and each hard test with the journey it walks. Also list the journeys you proposed that the developer did not pick: the next change that touches one of them writes it.
