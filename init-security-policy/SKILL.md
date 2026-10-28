---
name: init-security-policy
description: Give an existing project its security policy - SECURITY_POLICY.md, saying who may see and do what in the developer's words, drafted from what the system does when every way in is tried, and the policy check that holds the system to it from then on.
disable-model-invocation: true
---

# Initialise the security policy

Write the policy check into the project, draft `SECURITY_POLICY.md` from what that check finds the system allowing, and commit both once the developer has approved the policy.

This skill's `SECURITY_POLICY_FORMAT.md` settles the shape of the file and what the check does. Read it, the project's `CLAUDE.md`, and `UBIQUITOUS_LANGUAGE.md` where there is one, first.

## When not to start

**The project already has `SECURITY_POLICY.md`.** Change nothing. Say that the policy changes through the pipeline from now on: `/find-criteria` shows the rules a change touches, and the build writes the approved ones in.

**`CLAUDE.md` names no fast check** - no `Fast check:` line, and no `Check:` line. The policy check needs a command every build runs. Say so, name `/restructure` as what creates one, and stop with nothing written.

## Find every way in, and every kind of who

Read the code for every way in: a page, an API route, a command, a message from a queue, a file it imports, a scheduled job's input, an external system's answer. Read it for every kind of who: each role, nobody logged in, and each external system, both as a receiver of data and as a source of answers that cause actions. Where the codebase is larger than you can hold at once, have parallel `Explore` subagents each cover one area and return what they found with file and line. Merge their lists yourself: a way in shows where the areas meet.

## Write the policy check

Write it in the project's own language and test tooling, as `SECURITY_POLICY_FORMAT.md` describes it, and add it to the fast check - the command on the `Fast check:` line, or on a `Check:` line where there is none. Only where it can't be made fast does it go into the slow check, on the `Slow check:` line. Where there is none, declare one in `CLAUDE.md` and make CI run it. Three things decide whether it can be trusted:

- **It finds the ways in from the code** - the router's table, the command registry, the queue subscriptions, the scheduler's jobs - or from a structural check where the framework keeps no list. A way in that a list kept by hand forgot is exactly what it must catch.
- **Its markers are unmistakable and live only in its own test data.** Plant one in every field of every record, related records included, so a route that exposes data through a join shows the marker. Nothing outside the tests may hold a marker: the check fails where a migration, seed or source file does.
- **Each external system is faked at its boundary.** The fake records every outgoing call, so a marker sent out shows. Its answers can cause actions, and the check tries what each answer makes the system do.

**Where you cannot run the system, or cannot try a way in** - a missing service, a way in with no way to drive it in a test - stop. Say which way in, and what stopped you. Remove everything this skill wrote. A policy that leaves out a way in looks complete while saying only part of the truth.

## Draft the rules

Run the check with nothing allowed. Every marker it finds and every action it sees is something the system allows today. Write those as rules in `SECURITY_POLICY_FORMAT.md`'s shape: grouped by thing, one line saying who may see or do what, an exception inside the rule. Write them as the developer would say them, and do not judge them yet: the draft says what the system does, not what it should do. Rules nobody ever decided, that the code simply follows, belong there too.

Then make the check allow exactly what the rules say, each thing it allows naming its rule. Give every rule a test showing in one case that what it allows works.

**Prove each rule is needed.** Take each rule's allowances out of the check in turn, and run it: it must fail. A rule whose removal changes nothing is wider than the system, or a duplicate. Narrow it or merge it until every rule passes this.

**Where the project lets nobody see or do anything a policy would limit**, the policy is the one line `SECURITY_POLICY_FORMAT.md` shows for that. The check still runs, so the day a way in appears it fails.

## Ask the developer to look

Run both checks. Then show the developer the path to `SECURITY_POLICY.md` and ask them to read it. Where the policy check went into the slow check, say so, and why it couldn't be made fast: it then does not run while a build works, nor in the pre-commit hook. Point out at most five rules most worth a closer look, each with a line saying why - possibly sensitive data reaching many people, nobody logged in or an external system, and actions an external system's answer causes. Free text that can hold anything, such as a name or a note, counts as possibly sensitive.

**Where the developer disagrees with a rule**, the rule still says what the system does today. Write the disagreement as a backlog item yourself, not through `/backlog`, which commits on its own: a file in `changes/backlog/` whose front matter holds `effort` and `utility`, each XS to XL as the developer confirms, under a `#` title, with the disagreement as its body. Mark the rule disputed with that file's path. The item goes into this skill's commit. Changing what the system allows is a change of its own, through the pipeline.

**Where they want a rule worded differently**, reword it, as long as it still says what the system does.

## Commit

Commit only once the developer has approved the policy and both checks pass, the policy check among them. Commit everything this skill wrote, in one commit: `SECURITY_POLICY.md`, the policy check and what it needs, the change that makes the fast check or the slow check run it, the rules' tests, and the backlog items for disputed rules. Stage only those files.

Then say what changes from now on: the policy check runs in every build, `/find-criteria` shows a change the rules it touches, and the build writes the approved ones into the policy.
