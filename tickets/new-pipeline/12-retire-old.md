---
solution:  SOLUTION_NEW_PIPELINE.md
satisfies: AC-14
after:     9-first-run
status:    review
attempts:  1
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

Two documents still describe `/accept --abandon`, an interface that does not exist: the
flag belongs to `accept-run.sh`. `SOLUTION_NEW_PIPELINE.md` and `NEW_PIPELINE_IDEA.md`'s
stage (e) both carry it. Correct them here.

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

## Record

`tests/no-dangling.sh`, 2 cases, invoked by `tests/run.sh`
(8 + 18 + 22 + 32 + 11 + 27 + 37 + 24 + 3 + 11 + 2, green).

**AC-14's check is "nothing invocable remains", so that is what was written, before
anything was deleted.** Every `SKILL.md`, every format document beside one, and
`README.md` may not name a skill, a format or a script that is not there. The intents
and the ticket records are exempt: they name retired things on purpose, and that is
history rather than instruction.

It earned its keep immediately. After the deletion it named six leftovers, four of them
in documents nobody would have thought to check: `software-design/ADR_FORMAT.md` still
said `/to-solution` proposes ADRs and `/handover` proposes the late ones — the correction
ticket 11 deferred to here — and `ubiquitous-language-init/UBIQUITOUS_LANGUAGE_FORMAT.md`
said the same of the glossary. `/critique` sent a reader to `/check-against-spec` for the
acceptance. And one document still told someone to run `./accept.sh`.

**What went.** `to-solution`, `spec-to-tickets`, `check-against-spec`, `implement-ticket`,
`handover`, `loop.sh`, `accept.sh`, `critique/TICKET_FORMAT.md`, `tests/stub-claude` and
fifteen fixture transcripts.

**And the 257 cases that went with them.** `tests/run.sh` was nine hundred lines of
behaviour cases for `loop.sh` and `accept.sh`. Deleting the scripts and keeping their
tests would have left a suite asserting things about files that do not exist; deleting
both leaves the harness holding what is true of the repository as a whole — the
shared-format invariants, the mutation-tool refusal, the suite-exists check — and running
the ten suites that replaced them. The count went from 257 + 8 sub-suites to 8 + 11
suites, and the number is smaller because the old cases tested one script nine hundred
lines long.

**The README described a pipeline that no longer existed**, which is the same defect as
a dangling reference and larger: a diagram, four sections of prose and five catalogue
entries. Rewritten for the pipeline that is there, including the distinction the run
made concrete — everything that must hold when a session is dead or lying is a script,
everything that is judgement is a skill.

**Corrected here, as the ticket's context said to.** Two documents described
`/accept --abandon`, a flag that belongs to `accept-run.sh`.

**What stays.** `idea` and `critique`, reshaped; `git-commit-message`, `repo-overview`,
`improve-skill`, `cleanup-repo`, `upgrade-dependencies`, `ubiquitous-language-init`; and
`accept-run.sh`, which ticket 8 kept as a script for the reason the runner is one.
