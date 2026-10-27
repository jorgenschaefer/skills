---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18
advances:
after:
status:    done
attempts:  0
---

## Build
A lasting security policy for every project the pipeline works on: a new typed skill, `/init-security-policy`, that writes the policy check into a project and drafts the policy from what it finds, and `/find-criteria`, `/implement` and `/accept-criteria` working from that policy in every later change.

## Done when
> **AC-1** After `/init-security-policy`, the project has a security policy the developer reads without code. It lists only what is allowed, grouped by thing. Each rule says who sees or does what, with any exception inside the rule. "Who" is a role, nobody logged in, or an external system.

> **AC-2** `/init-security-policy` drafts the rules from what the system does when tried: every rule in the draft is one the policy check found the system allowing, so taking any one rule out makes the check fail. It writes the file, asks the developer to look at it, and points out at most five rules most worth a closer look, such as possibly sensitive data reaching many people or an external system. In dom, Streife seeing the name of an Einsatz created through the API is among them.

> **AC-3** Where `/init-security-policy` cannot run the system or try a way in, it says what stopped it and leaves no policy behind. The same holds where the project has no `Check:` command: it says so, names `/restructure` as what creates one, and leaves no policy behind.

> **AC-4** Where the developer disagrees with a rule, the rule stays as the system does it today, marked as disputed and naming the backlog item the disagreement became. `/init-security-policy` commits the policy only once the developer has approved it and the policy check passes.

> **AC-5** Every rule has a test showing, in one case, that what it allows works.

> **AC-6** The policy check fails when the system lets anyone see or do something no rule allows. That includes a person with a role, nobody logged in, and an external system that receives data or causes an action through its answer. It also includes a way in nobody thought of, such as data exposed through another route by a join.

> **AC-7** The policy check also fails when the system has a way in it did not try.

> **AC-8** `/find-criteria` shows the rules a change touches. Each of the change's Security policy ACs is a rule worded as it will stand in the policy, or a rule as it stands today that the change removes.

> **AC-9** A change's build writes its approved rules into the policy, with their tests, in the change's own commits.

> **AC-10** At acceptance, the developer sees the policy's rules before and after the change, in their words.

> **AC-11** A change that lets anyone see or do something no approved rule allows fails the policy check. Where the build adds a rule to make it pass, acceptance shows that rule as going beyond what was agreed.

> **AC-12** In a project with no security policy, `/find-criteria` says in one line that there is none and that `/init-security-policy` creates one. The change then goes on as it does today.

> **AC-13** Where a project lets nobody see or do anything a policy would limit, its policy says so in one line, approved like any other.

> **AC-15** A test for a rule, or the policy check, that a change weakens or deletes is shown at acceptance as a weakened check, saying what it no longer protects.

> **AC-18** In a project that already has a security policy, `/init-security-policy` changes nothing and says that the policy changes through the pipeline from now on.

> **AC-14** The policy changes only through rules the developer approved: in a change's ACs, during `/init-security-policy`, or at acceptance, where a build went beyond what was agreed.

> **AC-16** The security policy is kept in the project for as long as the project exists, and outlives every change.

> **AC-17** The marker values the policy check plants exist only in test data, never in production data.

## Technical decisions
> **Concepts** The *security policy*: one per project, outliving every change, listing only what is allowed, grouped by thing. A *rule*: one line of it, saying who may see or do what with a thing, any exception inside the line ("Streife and Wachleitung see it; Streife without its name"). "Who" is a role, nobody logged in, or an external system, both as a receiver of data and as a source of answers that cause actions. A rule the developer disagreed with at `/init-security-policy` is *disputed*: it says what the system does, and names the backlog item that would change it. A change's Security policy ACs are rules added to the policy, changed in it or removed from it. A *way in* is any route by which something from outside reaches the system: a page, an API route, a command, a message from a queue, a file it imports, a scheduled job's input, or an external system's answer. The *policy check* tries every way in as every kind of "who", with *marker values* planted in the test data, and fails where a marker or an action turns up that no rule allows, or where a way in exists it did not try.

> **Wire formats** `SECURITY_POLICY.md` at a project's root, beside `UBIQUITOUS_LANGUAGE.md` - not `SECURITY.md`, which GitHub reserves for how to report a vulnerability - with its format in a file of its own, copied into each skill that reads or writes the policy. A new skill the developer types, `/init-security-policy`. The Security policy group in `find-criteria/CRITERIA_FORMAT.md` is written as rules. The project's `Check:` command keeps its form and also runs the policy check.

> **Hard to reverse** none. Changing the policy's format later means changing every project's file, but those are short and in the developer's words: work, not loss.

## Context
This repository is the pipeline's skills, written in Markdown. The "project" and "system" the ACs speak of are a project those skills are used in, such as dom. The policy check is code `/init-security-policy` writes into that project, in that project's own language and tests, and runs from that project's `Check:` command. This repository's own check is `./test.sh`.

The agreed design: each project keeps a lasting `SECURITY_POLICY.md`, an allowlist in the developer's words, grouped by thing, with exceptions written inside a rule rather than as rules of their own, and a test per rule showing that what it allows works. One policy check shows that nothing else is allowed: it drives the system as every role, as nobody logged in and as every external system, plants marker values in the data, tries every way in, watches every outgoing call, and fails where a marker or an action turns up that no rule allows, or where a way in exists it did not try. `/init-security-policy` writes that check into an existing project and makes the policy's first version from what the check finds. A change then works from the policy: `/find-criteria` shows the rules it touches, the build writes the approved ones into the file, and acceptance shows the policy before and after.

Ruled out with the developer, so not to be proposed again: the tests as the policy with no file; "never" rules beside allow rules; a "Not checked" section for ways in the check cannot try; the first change that touches security starting the policy; holding security changes until a policy exists; grouping rules by role, or as a table.

What exists today:
- `find-criteria/SKILL.md` asks "who may see and do what" with nothing shown first ("Ask about the other three groups"). `find-criteria/CRITERIA_FORMAT.md`'s Security policy group has the example "a member never sees another member's contact details" - a "never" rule.
- `implement/SKILL.md` treats a permission no AC group names as a departure, and `run/prompts.sh` tells every build the same.
- `accept-criteria/SKILL.md` already shows a weakened check by what it no longer protects ("Show what changed from what was agreed"), and on acceptance deletes only the change's directory.
- `ubiquitous-language/UBIQUITOUS_LANGUAGE_FORMAT.md` is the nearest model: a project-root file with its format in a file beside the skill.
- `backlog/SKILL.md` is the shape of an item in `changes/backlog/`, which a disputed rule names (AC-4).
- `README.md` describes the pipeline and lists every skill.

Decided here: the format file is `SECURITY_POLICY_FORMAT.md`, held byte-identical by `init-security-policy`, `find-criteria`, `implement` and `accept-criteria`. The generic checks `./test.sh` already runs hold both the copies and every `/init-security-policy` a skill names; they need no new test.

The AC group What production must show says "None.".

## Not here
- Running `/init-security-policy` on dom or any other real project. The build does not change another repository; the dom instance in AC-2 is walked at acceptance.
- Changing what dom allows today.
- The outside attacker, agents steered by text they read, and the secure path being the easy one: `changes/backlog/security-beyond-access.md`.
- Executed evidence per AC at acceptance: `changes/backlog/acceptance-evidence-from-a-script.md`.
- Approved behaviour outside the security policy outliving the change: `changes/backlog/approved-criteria-outlive-the-change.md`.
- The information model as a lasting file.

## Left standing
- Review findings not fixed: a disputed rule keeps naming its backlog item after `/idea` deletes that item, and no skill may clear the mark short of a change whose AC rewords the rule (should-fix). A rule the developer approves in a direct `/implement` with no criteria is not among the ways `SECURITY_POLICY_FORMAT.md` lets the policy change (nit). A "removes" AC whose rule and access must go in one ticket is not spelled out in `/criteria-to-tickets` (nit).
- Fixes after the last review, which no reviewer saw: `/init-security-policy` writes a disputed rule's backlog item itself instead of through `/backlog`, which would commit it on its own (should-fix 1). The format says bookkeeping such as sessions and timestamps is not an action needing a rule (should-fix 2). Acceptance no longer reports a check that stopped trying a way in the change deleted (should-fix 3). Access a build widened through the check, not only a rule it added, is kept only on a keep, with its rule reworded (should-fix 4). The wording on slices that open access, and on the check finding a change's new ways in (nits 1 and 2).
- No AC is proven by an automated test: the skills are prose, and `./test.sh` checks only that the four copies of `SECURITY_POLICY_FORMAT.md` match and that `/init-security-policy` resolves. Each AC was checked by two fresh agents walking the skills as a session would. AC-2's dom instance is for acceptance.
- Beyond the files the ticket names: `criteria-to-tickets/SKILL.md` gained one line, so a ticket that opens access comes after the rule that allows it; otherwise a run's policy check fails partway.
- Costly to reverse: rule ids `R-n`, numbered from the file's git history and never reused, and Security policy ACs shaped "adds:", "changes R-n to:", "removes R-n:". Every project's policy and later criteria are written against both.
- Blast radius: every later `/find-criteria`, `/implement` and `/accept-criteria` run in a project with a policy. `./sync.sh` has to run once to link the new skill into `~/.claude/skills`.
