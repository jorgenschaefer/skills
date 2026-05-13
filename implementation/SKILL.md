---
name: implementation
description: Use this skill to run the full implementation loop for a feature. Invoke with a feature slug — the orchestrator iterates every Backlog ticket, spawning clean-context subagents for TDD implementation (implementation-tdd) and review (implementation-tdd-review). For implementing a single ticket manually, use implementation-tdd directly.
---

# Implementation

Orchestrates the full implementation loop for a feature: iterates the ticket backlog and, for each ticket, spawns clean-context subagents to implement and review it. If you want to implement a single ticket directly (with a TDD loop), use the `implementation-tdd` skill instead.

## Orchestrator loop

0. **Check backlog review.** List `docs/features/<slug>/` for `tickets-review-*.md` files. Find the newest (highest `<NN>`). If the verdict is Block or Request changes, report to the user and stop — implement only when the backlog is approved. Proceed if the user explicitly confirms or if no review file exists.

1. List `docs/features/<slug>/tickets/*.md`. Filter to files whose `**Status:**` field is `Backlog`, ordered by filename.

2. For each Backlog ticket:

   a. Read its `**Depends on:**` field. If any listed dependency ticket does not have `Status: Done`, skip this ticket and report the blockage to the user. Do not stop the loop — continue to the next ticket.

   b. **Spawn an `implementation-tdd` subagent** using the `Agent` tool with `subagent_type: "general-purpose"`. Use this prompt:

      > Invoke the `implementation-tdd` skill for feature slug `<slug>`. The ticket is at `<ticket-path>`. The Design Doc is at `docs/features/<slug>/design.md`.

   c. If the subagent output contains `**BLOCKED:**`, surface the issue and options to the user and stop the loop for this ticket. Continue to the next ticket.

   d. Collect commit hashes from the subagent output (the clearly labeled **Commit hashes:** list).

   e. **Spawn an `implementation-tdd-review` subagent** using the `Agent` tool with `subagent_type: "general-purpose"`. Use this prompt:

      > Invoke the `implementation-tdd-review` skill for feature slug `<slug>`. The ticket is at `<ticket-path>`. The Design Doc is at `docs/features/<slug>/design.md`. The implementation commits are: `<hash1>`, `<hash2>`. Use `git show <hash>` to view each.

   f. Wait for the reviewer subagent to finish. List `docs/features/<slug>/` and open the newest `implementation-tdd-review-*.md` file (the one just created). Check the verdict.

   g. If the verdict is **Request changes** or **Block**: spawn another `implementation-tdd` subagent to address the findings:

      > Invoke the `implementation-tdd` skill for feature slug `<slug>`. The ticket is at `<ticket-path>`. The Design Doc is at `docs/features/<slug>/design.md`. Address the findings in the review at `<review-path>`. The verdict was `<verdict>`.

      Collect new commit hashes from the output. If the output contains `**BLOCKED:**`, surface it to the user and stop.

      Then spawn a second `implementation-tdd-review` subagent to verify the fixes, using the new commit hashes:

      > Invoke the `implementation-tdd-review` skill for feature slug `<slug>`. The ticket is at `<ticket-path>`. The Design Doc is at `docs/features/<slug>/design.md`. The implementation commits are: `<new-hash1>`, `<new-hash2>`. Use `git show <hash>` to view each.

      Wait for the reviewer to finish. List `docs/features/<slug>/` and open the newest `implementation-tdd-review-*.md` file. If the verdict is still **Request changes** or **Block**, surface the remaining findings and the verdict to the user and stop — do not mark the ticket Done without user direction.

   h. Update the ticket's **Status** field to `Done` in the ticket file.

   i. **Boy-scout incidental findings.** Collect any findings listed in the implementation subagent output that fall outside the ticket's scope. Spawn a `general-purpose` subagent with this prompt:

      > Invoke the `boy-scout` skill. The following incidental findings were noticed during implementation of ticket `<ticket-name>` for feature slug `<slug>`:
      >
      > `<paste the list of findings here, one per line, each with file path and description>`
      >
      > Triage each finding: apply trivially safe fixes immediately; write a ticket at `docs/features/boy-scout/tickets/` for everything else. The `Noticed during` field should read: "implementation of `<ticket-name>` for `<slug>`".

   j. Report the ticket outcome to the user: what was implemented, the review verdict, what (if anything) was fixed, and any boy-scout tickets created.

3. When no Backlog tickets remain (or all remaining are blocked by unmet dependencies), report the feature complete and ready for final merge, or summarize which tickets are still blocked and why.
