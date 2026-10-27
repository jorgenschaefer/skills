# Criteria: a security policy the developer can vouch for

## Problem
The developer approves who may see and do what one change at a time. Acceptance then deletes what they approved, so the whole policy is never written down anywhere they can look. To know who can see a piece of data, they rely on their memory or ask an agent. In dom, they asked who can see the name of an Einsatz created through the API, which can hold an internal number or patient information. The agent answered that everyone logged in can see it, Wachleitung and Streife alike, and nobody else. The answer was right, but the developer knew that only from memory. Memory fades as agents build more, and an agent tracing routes can miss one that exposes the data another way, for example through a join. Instead, the developer should be able to see, in their own words, who may see and do what across the whole system, including rules nobody ever decided that the code simply follows. And they should know this is what the system does, because something shows that the system holds to it, not because an agent or their memory says so.

Instance: in dom, on 2026-10-27, the developer asked an agent "Wer kann den Namen eines Einsatzes sehen, der durch den API erstellt wird?". The answer was right, and the developer knew that only from their own memory of dom. Nothing has gone wrong yet.

## Acceptance criteria
### Behaviour
- **AC-1** After `/init-security-policy`, the project has a security policy the developer reads without code. It lists only what is allowed, grouped by thing. Each rule says who sees or does what, with any exception inside the rule. "Who" is a role, nobody logged in, or an external system.
- **AC-2** `/init-security-policy` drafts the rules from what the system does when tried: every rule in the draft is one the policy check found the system allowing, so taking any one rule out makes the check fail. It writes the file, asks the developer to look at it, and points out at most five rules most worth a closer look, such as possibly sensitive data reaching many people or an external system. In dom, Streife seeing the name of an Einsatz created through the API is among them.
- **AC-3** Where `/init-security-policy` cannot run the system or try a way in, it says what stopped it and leaves no policy behind.
- **AC-4** Where the developer disagrees with a rule, the rule stays as the system does it today, marked as disputed and naming the backlog item the disagreement became. `/init-security-policy` commits the policy only once the developer has approved it and the policy check passes.
- **AC-5** Every rule has a test showing, in one case, that what it allows works.
- **AC-6** The policy check fails when the system lets anyone see or do something no rule allows. That includes a person with a role, nobody logged in, and an external system that receives data or causes an action through its answer. It also includes a way in nobody thought of, such as data exposed through another route by a join.
- **AC-7** The policy check also fails when the system has a way in it did not try.
- **AC-8** `/find-criteria` shows the rules a change touches. Each of the change's Security policy ACs is a rule worded as it will stand in the policy, or a rule as it stands today that the change removes.
- **AC-9** A change's build writes its approved rules into the policy, with their tests, in the change's own commits.
- **AC-10** At acceptance, the developer sees the policy's rules before and after the change, in their words.
- **AC-11** A change that lets anyone see or do something no approved rule allows fails the policy check. Where the build adds a rule to make it pass, acceptance shows that rule as going beyond what was agreed.
- **AC-12** In a project with no security policy, `/find-criteria` says in one line that there is none and that `/init-security-policy` creates one. The change then goes on as it does today.
- **AC-13** Where a project lets nobody see or do anything a policy would limit, its policy says so in one line, approved like any other.
- **AC-15** A test for a rule, or the policy check, that a change weakens or deletes is shown at acceptance as a weakened check, saying what it no longer protects.
- **AC-18** In a project that already has a security policy, `/init-security-policy` changes nothing and says that the policy changes through the pipeline from now on.

### What production must show
None.

### Security policy
- **AC-14** The policy changes only through rules the developer approved: in a change's ACs, during `/init-security-policy`, or at acceptance, where a build went beyond what was agreed.

### Information model
- **AC-16** The security policy is kept in the project for as long as the project exists, and outlives every change.
- **AC-17** The marker values the policy check plants exist only in test data, never in production data.

## Agreed design
Each project keeps a lasting security policy: an allowlist in the developer's words, grouped by thing, with exceptions written inside a rule rather than as rules of their own. Each rule has a test showing that what it allows works. One check, the policy check, shows that nothing else is allowed: it drives the system as every role, as nobody logged in and as every external system, plants marker values in the data, tries every way in, watches every outgoing call, and fails where a marker or an action turns up that no rule allows, or where a way in exists it did not try.

`/init-security-policy` writes the policy check into an existing project, in the project's own code, and makes the policy's first version from what that check finds. The check is part of the project's `Check:` command, so every build runs it. writes the file, and points the developer at the rules most worth a look. A change works from the policy: `/find-criteria` shows the rules it touches, the build writes the approved ones into the file, and acceptance shows the policy before and after.

**Agreed; build to this, do not redesign.**

## Technical decisions
- **Concepts** The *security policy*: one per project, outliving every change, listing only what is allowed, grouped by thing. A *rule*: one line of it, saying who may see or do what with a thing, any exception inside the line ("Streife and Wachleitung see it; Streife without its name"). "Who" is a role, nobody logged in, or an external system, both as a receiver of data and as a source of answers that cause actions. A rule the developer disagreed with at `/init-security-policy` is *disputed*: it says what the system does, and names the backlog item that would change it. A change's Security policy ACs are rules added to the policy, changed in it or removed from it. A *way in* is any route by which something from outside reaches the system: a page, an API route, a command, a message from a queue, a file it imports, a scheduled job's input, or an external system's answer. The *policy check* tries every way in as every kind of "who", with *marker values* planted in the test data, and fails where a marker or an action turns up that no rule allows, or where a way in exists it did not try.
- **Wire formats** `SECURITY_POLICY.md` at a project's root, beside `UBIQUITOUS_LANGUAGE.md` - not `SECURITY.md`, which GitHub reserves for how to report a vulnerability - with its format in a file of its own, copied into each skill that reads or writes the policy. A new skill the developer types, `/init-security-policy`. The Security policy group in `find-criteria/CRITERIA_FORMAT.md` is written as rules. The project's `Check:` command keeps its form and also runs the policy check.
- **Hard to reverse** none. Changing the policy's format later means changing every project's file, but those are short and in the developer's words: work, not loss.

## Out of scope
- The outside attacker, agents steered by text they read, and the secure path being the easy one: `changes/backlog/security-beyond-access.md`.
- Executed evidence per AC at acceptance: `changes/backlog/acceptance-evidence-from-a-script.md`.
- Approved behaviour outside the security policy outliving the change: `changes/backlog/approved-criteria-outlive-the-change.md`.
- The information model as a lasting file.
- Changing what dom allows today.

## Ruled out
- **The tests are the policy, with no file** - a way in nobody wrote a test for stays invisible.
- **"Never" rules beside allow rules** - readers would have to work out which one wins; exceptions go inside the rule.
- **A "Not checked" section for ways in the check cannot try** - it invites excuses, and every way in can be tested.
- **The first change that touches security starts the policy** - a policy without its check looks complete while saying only part of the truth.
- **Holding security changes until a policy exists** - it blocks unrelated work on a setup step.
- **Grouping rules by role, or as a table** - the question a developer asks is who can see a thing.
