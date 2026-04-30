# Review: docs/features/shared-skill-content/design.md

**Reviewer:** Claude (claude-sonnet-4-6), clean context
**Date:** 2026-04-30
**Artifact:** [docs/features/shared-skill-content/design.md](design.md)
**Verdict:** Request changes

## Summary

The design is well-scoped, specific, and clearly aligned with the Feature Brief. The propagation model is concrete, the file structure is explicit, and the ADR is solid. Two should-fix issues prevent advancing: the pre-commit hook has a subtle logic flaw that will silently allow out-of-sync propagated files to pass the check under a common workflow, and the design does not address what happens when `propagate.sh` is run inside `pre-commit` but there are already staged files. Both are implementation-critical gaps at the tooling core of this feature. Several nits around terminology and one UBIQUITOUS_LANGUAGE.md observation are also noted.

## Findings

### Blockers

None.

### Should-fix

1. **Pre-commit hook logic is broken for the standard workflow**
   - **Where:** Proposed design — "Pre-commit hook" section
   - **Issue:** The hook runs `propagate.sh` then checks `git diff --quiet` to detect whether propagated files changed. But `git diff` without `--staged` or `--cached` checks only the *working tree against the index* — it does not check staged changes. The normal workflow is: author edits `shared/architecture-principles.md`, runs `git add .`, then commits. At hook run time, the source file and its propagated copies are all staged. The hook runs `propagate.sh`, which copies the (already-in-sync) source file over the already-in-sync working-tree copies. `git diff` sees nothing dirty. The hook exits 0. The commit proceeds — whether or not the copies were actually in sync before the commit. The only scenario the hook catches is: author edits the source, stages *everything* including the stale copies, and then the hook's re-propagation produces a working-tree change that was not staged. That scenario is possible but not the only failure mode.
   - **Why it matters:** The hook is the enforcement mechanism for the entire feature. A hook that can be trivially bypassed by following the documented workflow (step 3: `git add .`) means propagation discipline depends entirely on author memory, which is exactly the problem this feature solves.
   - **Suggested fix:** After running `propagate.sh`, use `git diff --name-only HEAD` (comparing working tree + index against HEAD) or compare the source files to their copies directly with `diff` before the script exits, regardless of git state. For example, after propagation, verify with `diff` that each destination matches its source, and exit 1 if any differ. Alternatively, the hook could stage the propagated files automatically (with `git add`) and continue — a pattern used in many formatting hooks — though this changes the semantics from "fail and tell me" to "fix and continue."

2. **Hook does not handle the case where propagated files were already staged before the hook runs**
   - **Where:** Proposed design — "Pre-commit hook" section and "Workflow: adding a new guideline" section
   - **Issue:** The described workflow says: edit the source file, run `propagate.sh` manually, then `git add .`. If the author follows this workflow exactly, the hook's re-run of `propagate.sh` is a no-op and `git diff` finds nothing — this is the correct path. But the doc also positions the hook as a safety net for authors who forget to run `propagate.sh` before staging. In that case, the hook runs propagation *after* the files are staged, producing unstaged working-tree changes. The hook then exits 1 with "stage them and recommit." But after the failed commit, the author must `git add` the newly-propagated files and recommit — triggering the hook again. The hook re-runs `propagate.sh` again over the already-correct copies. This double-propagation is harmless but makes the error recovery loop non-obvious. The doc should describe what the author does after the hook fails.
   - **Why it matters:** A hook that fails with "stage them and recommit" without explaining what to do next is a bad developer experience, and the author of this repo is the sole user. This is not a blocker, but the recovery steps should be spelled out in `CLAUDE.md` or the hook's error message.
   - **Suggested fix:** Expand the hook's failure message to include the exact commands (`git add <listed files> && git commit`). Update `CLAUDE.md` accordingly.

### Nits

- The design says `design-review/SKILL.md` is "unchanged (already references review-base.md)" in the file structure table. When checked against the actual `design-review/SKILL.md`, it does not reference `review-base.md` in its frontmatter or opening — it reads `review-base.md` by instruction in the skill text (`read review-base.md first`). That is a reference, but a prose instruction rather than a link. The design should confirm whether this still works when `review-base.md` becomes a propagated copy rather than a manually maintained one — the answer is almost certainly yes, but saying so explicitly would close the loop.
- The design states the hook can be installed with `cp scripts/propagate.sh .git/hooks/pre-commit`. This would replace the script wholesale, but the hook has different behavior from `propagate.sh` (it also runs the git diff check). These are not the same file. The hook content is shown separately in the design — but the installation command is wrong. Suggest `cp scripts/pre-commit.sh .git/hooks/pre-commit` or similar, with the hook living as its own script.
- "Build step" is not in `UBIQUITOUS_LANGUAGE.md`. The discovery-review flagged this as a nit; the design uses the term in the Summary and Rollout sections. Worth adding to the glossary since the term recurs across this feature's artifacts.
- The Rollout plan's step 4 says "Update the five SKILL.md files that need new/changed references." The design also identifies `design-review` and `planning-review` as getting `architecture-principles.md` as a new propagated file, which would require SKILL.md updates too (to read it). The count of "five" files may be correct (since design-review and planning-review already reference review-base.md and the design says their SKILL.md is "unchanged"), but the architecture-principles.md addition to those skills is not mentioned as requiring a SKILL.md framing sentence. Confirm whether agents reading architecture-principles.md in design-review and planning-review require an instruction in SKILL.md or whether it is self-referencing. If an instruction is needed, the five-file count is wrong.

## What was checked

- Brief alignment: each design goal checked against brief goal; non-goals verified as unaddressed; constraints cross-checked against design
- Brief's open questions resolved: (1) number of shared files — three, explicitly mapped; (2) verbatim copy vs. template — resolved as verbatim with per-skill framing; (3) propagation trigger — resolved as pre-commit hook with standalone script fallback
- Discovery-review should-fix item (committed vs. not-committed constraint): confirmed the design explicitly states propagated copies are committed
- File structure: checked against existing skill directories in repo root — all named skills exist
- Propagation script logic: read carefully, traced the copy operations against the propagation map table — consistent
- Pre-commit hook logic: traced the git diff behavior against the described workflows — identified the flaw reported above
- SKILL.md changes: cross-checked the design's claim of "five SKILL.md files" against the file structure table
- ADR 0001: read in full; consequences section is substantive and covers both what becomes easier and what the decision forecloses — well done
- Existing ADRs: only one ADR exists; read fully; no prior decisions contradicted
- Ubiquitous language: read `UBIQUITOUS_LANGUAGE.md`; no canonical terms misused; one missing term flagged
- Codebase awareness: confirmed `implementation` skill reference-file pattern by reading `implementation/SKILL.md` and `implementation/` directory listing — design correctly describes the existing pattern and extends it
- Alternatives considered: three alternatives evaluated with explicit rejection rationale; tradeoffs named
- Rollout plan: read and traced; rollback story ("revert the commit") is credible for a no-deployment tooling change
- Testing strategy: appropriate for the artifact type — no service, no database, no production system; diff-based verification is correct
- Risks section: both named risks are real and specific; migration fidelity and design-review complexity are the right concerns to flag
- boy-scout triage: no unrelated findings noted; triage skipped as unnecessary

## What was NOT checked

- Whether the skills.sh installer behavior matches the description (constraint taken at face value from the brief)
- Runtime agent behavior: whether agents invoked with a skill after propagation actually find and read the referenced files correctly — the design's testing strategy calls for a functional test, which was not run here
- The actual content divergence between the 7-11 existing inline blocks — content migration fidelity is flagged as a risk in the design and deferred to implementation; not verified here
