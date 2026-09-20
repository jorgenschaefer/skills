---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-14
after:     9-first-run
status:    ready
attempts:  0
reviews:   0
---

## Build

Delete the pipeline this one replaces, in one commit, once the new one has been run
end to end.

## Done when

> **AC-14** Every skill and script the new pipeline replaces is deleted, in one commit,
> after the pipeline has been run end to end once. Nothing is left behind that a person
> or a model could invoke by mistake.

## Context

Going: `to-solution`, `spec-to-tickets`, `check-against-spec`, `implement-ticket`,
`handover`, `loop.sh`, `accept.sh`, and whatever remains of the old `implement`.

`accept-run.sh` stays: ticket 8 kept the mechanical half of acceptance as a script
rather than folding it into the skill, for the reason the runner is a script, and wrote
it against the new paper layout beside the old one.
Staying: `idea` and `critique` reshaped, `git-commit-message`, `repo-overview`,
`improve-skill`, `cleanup-repo`, `upgrade-dependencies`, and `ubiquitous-language-init`
if ticket 11 kept it.

It runs last for a reason. Until ticket 9 has driven a real change through, the old
pipeline is the only one known to work, and deleting it earlier means a halt leaves
this repository with no working process at all.

Deletion is not archival: git history keeps every file, which the archive constraint in
`INTENT_PROCESS_COST.md` says is enough.

The check is that nothing invocable remains. A skill half-deleted — directory gone,
references in `README.md` intact — still gets found and read.

## Not here

Deleting the paper of this run. `/accept` does that on the verdict, ticket 8.
