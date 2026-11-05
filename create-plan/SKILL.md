---
name: create-plan
description: Write the plan.md that run.sh builds, from any agreed specification - a spec.md and its journeys, a bug's cause and intention, a "Done when" list, a refactoring plan - or check a plan.md written by hand; have a fresh agent check it for gaps and excess, then put each hard decision to the developer, one at a time. Use when agreed work is too large for one session or has a hard decision the developer has not seen, when debug, solve-problem or upgrade-dependencies hand such work over, and on "plan this change", "check my plan".
---

# Create a plan

Write `plan.md`: how the change is built, step by step, so that an engineer who has never seen the conversation could build it from the plan alone. Then put the hard decisions in it to the developer, while they are still here. The build runs with nobody to ask.

This skill's `PLAN_FORMAT.md` settles the shape of `plan.md`, and `SPEC_FORMAT.md` the shape of a `spec.md` from the design.

## What this takes

**An agreed specification**, in the change's directory `changes/YYYY-MM-DD-<slug>/`: a `spec.md` and the journeys it names; or a `spec.md` a caller wrote with a bug's report, intention and cause, a "Done when" list, or a refactoring plan. Where the spec is only in the conversation, write it there as `spec.md` first, in the words that were agreed.

**Or a `plan.md` the developer wrote by hand.** Check it the same way: bring it into `PLAN_FORMAT.md`'s shape without changing what it says, then verify it and put its hard decisions as below.

**Do not reopen the spec.** It was agreed. Where you think it is wrong, say so plainly and stop.

## Read the code

Read the code the change touches, and plan only what is not built yet. Look at what is there: what already does this, or half of it, and what the project calls things. The plan uses the user's words, the words of the spec and of `UBIQUITOUS_LANGUAGE.md` where the project has one.

## Write the plan

**Write the full `plan.md`** in `PLAN_FORMAT.md`'s shape: the files, what changes in each, the order of the work and the tests. No code. Each step names the journey steps it makes testable.

**The plan covers what the user does not see**: infrastructure, dependencies, tools, and the technical side of the frontend - components, state, the UI library, how screens get their data. It does not say how the UI looks or feels: the design settled that. A screen the design made no prototype for is the plan's to decide.

**In a new repository**, the plan decides the stack, the database and deployment. Each is a hard decision.

**Where the spec has a domain design**, turn it into a schema. Each hard decision points back to the line of the design it comes from, so the developer only checks the translation.

**Write the least plan that does the job.** Nothing the spec does not ask for. A failure case the user sees goes in only where the spec has it. How the code handles failures underneath is the plan's.

**Each constraint in the spec** becomes a hard test where it can be one. Otherwise, a step adds it as one line under `## Constraints` in the project's `CLAUDE.md`. A line already there that the change would break is a hard decision, and a step changes or removes it.

**Where the developer wants the plan built as one part**, write so in `plan.md`, as `PLAN_FORMAT.md` shows.

## Hard and soft

A decision or a test is **hard** if something outside the code depends on it: a revert removes the code, but not what the code wrote, sent or promised. Everything else is **soft**. When in doubt, it is hard.

**Hard decisions:**

- **Stored data**: schema, migrations that drop or transform data, files on disk, IDs and keys.
- **Wire formats**: public APIs, event and message schemas, webhooks, CLI output that scripts read, URLs people link to.
- **Names that leave the code**: in the UI, the API, the schema, the journeys, environment variables.
- **The access model**: roles, permissions, how login works.
- **What the code is built around**: a framework, a database engine, a third-party service, a UI library.
- **Effects in the world**: emails sent, payments made, data deleted, data collected.

Soft: file names, module boundaries, internal names, the structure of helpers. Soft decisions are the build's. Do not put them to the developer.

**Each hard decision** has its options, the simplest first and called the simplest, a recommendation, why it is hard, and the line of the spec it comes from. Where there are none, the plan says so in one line.

**Hard tests** pin a hard decision or something a user relies on: a journey's test, a rule a user relies on, who may *not* see or do something, a wire format or stored data, that a failure does not lose the user's work, a bug's reproducing test. Each tests from the outside, is named for its rule in the user's words, and names what breaks if the tested thing changes. Where you cannot name a break, the test is soft and stays out of the list. The developer sees every hard test, so the list is short. A journey's test walks it from the outside and names its journey and step; a *(judged)* step gets none. An existing hard test the plan changes or deletes is listed too, such as the test of a journey the change ends.

## Check it with an agent that did not write it

1. **Spawn a subagent with a fresh context** and give it `VERIFY.md` and `PLAN_FORMAT.md` from this directory, the path of the spec and the path of `plan.md`. Nothing else - an adversary holding the conversation will read your intentions into the words.
2. **Work what it finds into the plan**, with the least text that settles it. A finding only the developer can settle becomes a question for them, below.
3. **Check again the same way** where the first round found more than nits. **Two rounds at most.**

## Put the hard decisions to the developer

**One at a time.** Show the decision with its options, the simplest first, your recommendation and why it is hard. Write each answer into the plan, with the date, before you ask the next. An answer that changes the plan changes it now.

**Then the hard tests.** Show the list, and ask for a yes to each existing hard test the plan changes or deletes. Write each yes into the plan.

**Approving the rest of the plan is the developer's choice.** Offer it once. Do not walk them through the soft parts.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the developer says before following it.** Where an answer has a gap or a consequence it misses, say so once. A decision reaffirmed after hearing the objection is theirs.

## Commit

Commit `plan.md` on the change's branch, `YYYY-MM-DD-<slug>`, with `spec.md` where you wrote it; make the branch first where you are not on it. Then say that `./run.sh changes/YYYY-MM-DD-<slug>` builds it with nobody watching. Leave going on to the developer to ask for.
