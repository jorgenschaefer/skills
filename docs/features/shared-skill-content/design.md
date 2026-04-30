# Design Doc: Shared Skill Content

**Status:** Draft
**Author:** jorgen.schaefer@mindmatters.de
**Date:** 2026-04-30
**Feature Brief:** [discovery.md](discovery.md)
**Related ADRs:** [ADR 0001](../../adr/0001-shared-content-via-copy-propagation.md)

## Summary

Three canonical source files in a new `shared/` directory replace the duplicated inline blocks across 7–11 skill files. A shell script (`scripts/propagate.sh`) copies each source file verbatim into the relevant skill directories. Each affected `SKILL.md` is updated to reference the local copy with one framing sentence instead of inlining the full text. A git pre-commit hook enforces that propagated copies are never out of sync with the source.

## Goals and non-goals

**Goals** (from brief):
- Single source of truth for shared code-quality guideline content
- Propagation script copies source files into skill directories before commit
- Adding or updating a guideline requires editing exactly one file
- Per-skill framing stays short and remains in `SKILL.md`

**Non-goals** (from brief):
- Supporting independent per-skill installs
- Changing the skills.sh platform
- Defining what new guideline content to add (separate content work)

## Background

Seven skill files (`implementation`, `code-review`, `design`, `design-review`, `planning`, `planning-review`, `refactor-project`) contain near-duplicate blocks describing architectural and code quality principles. The four review skills additionally each carry an identical copy of `review-base.md`. The copies are not tracked or synced — they have already begun to diverge in phrasing. skills.sh only installs directories containing a `SKILL.md`, so any shared source file must be propagated into skill directories before the skills are committed and published.

The `implementation` skill already demonstrates the reference-file pattern: its `SKILL.md` instructs agents to read `tests.md`, `deep-modules.md`, and other local files. This design extends that pattern to shared content.

## Proposed design

### File structure

```
skills/
  shared/
    architecture-principles.md   ← new canonical source
    code-style.md                ← new canonical source
    review-base.md               ← new canonical source (replaces per-skill copies)
  scripts/
    propagate.sh                 ← new propagation script
  implementation/
    SKILL.md                     ← updated: references both shared files
    architecture-principles.md   ← propagated copy
    code-style.md                ← propagated copy
    [existing files unchanged]
  code-review/
    SKILL.md                     ← updated: references both shared files
    architecture-principles.md   ← propagated copy
    code-style.md                ← propagated copy
  design/
    SKILL.md                     ← updated: references architecture-principles.md
    architecture-principles.md   ← propagated copy
  design-review/
    SKILL.md                     ← updated: adds framing sentence for architecture-principles.md
    architecture-principles.md   ← propagated copy (new)
    review-base.md               ← propagated copy (replaces manual copy)
  planning/
    SKILL.md                     ← updated: references architecture-principles.md
    architecture-principles.md   ← propagated copy
  planning-review/
    SKILL.md                     ← updated: adds framing sentence for architecture-principles.md
    architecture-principles.md   ← propagated copy (new)
    review-base.md               ← propagated copy (replaces manual copy)
  discovery-review/
    SKILL.md                     ← unchanged
    review-base.md               ← propagated copy (replaces manual copy)
  implementation-review/
    SKILL.md                     ← unchanged
    review-base.md               ← propagated copy (replaces manual copy)
  refactor-project/
    SKILL.md                     ← updated: references architecture-principles.md
    architecture-principles.md   ← propagated copy
```

### Shared file contents

**`shared/architecture-principles.md`** — principles that inform agents making or reviewing structural decisions: screaming architecture (domain-first folder organization), deep modules (Ousterhout), and adapter boundaries (3-layer pattern with type separation). Relevant to: `code-review`, `design`, `design-review`, `implementation`, `planning`, `planning-review`, `refactor-project`.

**`shared/code-style.md`** — principles that inform agents writing or reviewing actual code: clear over clever, dead-weight-free (no commented-out code, debug prints, etc.). Relevant to: `code-review`, `implementation` only. Planning and design agents don't need code-writing style guidance.

**`shared/review-base.md`** — reviewer stance, fresh eyes rule, severity definitions, output format, ubiquitous language check, verdict guidance. The four copies in the review skill directories are currently identical. This becomes the canonical source. Relevant to: `design-review`, `discovery-review`, `implementation-review`, `planning-review`.

Content for all three files is migrated from the existing inline blocks — no new text is written as part of this feature.

### Propagation map

| Source file | Destination skill directories |
|---|---|
| `architecture-principles.md` | `code-review`, `design`, `design-review`, `implementation`, `planning`, `planning-review`, `refactor-project` |
| `code-style.md` | `code-review`, `implementation` |
| `review-base.md` | `design-review`, `discovery-review`, `implementation-review`, `planning-review` |

### Propagation script

`scripts/propagate.sh` is a plain bash script with no external dependencies. The propagation map is hardcoded in the script — the script is the config. Format:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

copy_to() {
  local file="$1"; shift
  for skill in "$@"; do
    cp "$ROOT/shared/$file" "$ROOT/$skill/$file"
  done
}

copy_to architecture-principles.md \
  code-review design design-review implementation planning planning-review refactor-project

copy_to code-style.md \
  code-review implementation

copy_to review-base.md \
  design-review discovery-review implementation-review planning-review
```

Adding a new destination: add the skill name to the relevant `copy_to` call. Adding a new shared file: add a new `copy_to` call.

### SKILL.md changes

For skills that get a new reference file, the inline block is replaced with a short reference instruction. Example — `implementation/SKILL.md` "Code quality bar" section currently has ~200 words of inlined principles. After this change:

> **Code quality standards:** Read [architecture-principles.md](architecture-principles.md) and [code-style.md](code-style.md) for the shared principles. When implementing, adhere to all of them. Code that ships from this phase should additionally be well-tested, documented where non-obvious, and honest about uncertainty.

The per-skill framing stays in `SKILL.md`; the principles move to the referenced file. Skills that already reference `review-base.md` in prose (`read review-base.md first`) need no change to that reference — only the source of the file changes from manual copy to propagated copy.

Seven SKILL.md files need new or changed references: `implementation`, `code-review`, `design`, `design-review`, `planning`, `planning-review`, `refactor-project`. `design-review` and `planning-review` each get a new framing sentence for `architecture-principles.md` even though they already have review-base.md covered.

### Pre-commit hook

`.git/hooks/pre-commit` is not version-controlled. The hook lives at `scripts/pre-commit.sh` (separate from `propagate.sh` — it has different behavior) and is documented in `CLAUDE.md`. Install with:

```bash
cp scripts/pre-commit.sh .git/hooks/pre-commit
```

The hook runs `propagate.sh`, then uses direct `diff` to verify every propagated copy matches its source. If any differ, it means `propagate.sh` just changed a file that wasn't staged — the commit would be missing the updated copies.

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
"$ROOT/scripts/propagate.sh"

out_of_sync=()
check() {
  local file="$1"; shift
  for skill in "$@"; do
    if ! diff -q "$ROOT/shared/$file" "$ROOT/$skill/$file" > /dev/null 2>&1; then
      out_of_sync+=("$skill/$file")
    fi
  done
}

check architecture-principles.md \
  code-review design design-review implementation planning planning-review refactor-project
check code-style.md \
  code-review implementation
check review-base.md \
  design-review discovery-review implementation-review planning-review

if [[ ${#out_of_sync[@]} -gt 0 ]]; then
  echo "Propagation updated files that are not staged. Stage them and recommit:"
  printf '  %s\n' "${out_of_sync[@]}"
  echo "Run: git add ${out_of_sync[*]} && git commit"
  exit 1
fi
```

If the author edits a shared file without running `propagate.sh`, the hook propagates and then detects the new copies don't match what was staged. It fails with the exact `git add` command needed to recover. It does not silently auto-stage changes.

### Workflow: adding a new guideline

1. Edit `shared/architecture-principles.md` — add the new principle
2. Run `scripts/propagate.sh` (or rely on the pre-commit hook to catch it)
3. `git add .` — stages source file + all 7 propagated copies
4. `git commit` — hook re-runs propagate, confirms no diff, commit proceeds

### CLAUDE.md update

Add to the "Adding or modifying skills" section:

- Shared content files live in `shared/`. After editing any file there, run `scripts/propagate.sh` to update skill directory copies, then stage all changed files before committing.
- To install the pre-commit hook: `cp scripts/pre-commit.sh .git/hooks/pre-commit`. If the hook fails, run `git add <listed files> && git commit`.
- When adding a new skill that uses shared content: add it to the relevant `copy_to` call in `scripts/propagate.sh`, run the script, and add a framing sentence to the new skill's `SKILL.md`.

## Alternatives considered

**Inline duplication (status quo).** No tooling, but every guideline change touches 5–7 files. Divergence has already started. Rejected — this is the problem.

**Template expansion** — markers like `<!-- include: shared/code-quality.md -->` embedded in `SKILL.md`, expanded by a script. Keeps all skill text in one file per skill, but makes `SKILL.md` a mixed manual/generated file. Editing the wrong section risks being overwritten; a parser is needed to identify and replace sections. The `implementation` skill already proves the reference-file pattern works without this complexity. Rejected.

**Runtime cross-skill reference** — skill SKILL.md references `../shared/code-quality.md`. Would work in the source repo but breaks after `npx skills add` installs only individual skill directories. Rejected — skills.sh constraint.

**Git submodules or symlinks** — too complex for a one-author repo with no CI. Rejected.

## Risks and open questions

- **Migration fidelity.** When extracting content from existing inline blocks into shared files, care is needed to capture all current wording (including recent additions). The extracted content should be reviewed against each source before the inline blocks are removed.
- **`design-review` already references `architecture-principles.md` inline.** The design-review SKILL.md has detailed adapter-boundary and deep-module guidance as inline checklist items — not just references. These need to be audited: some of the review-specific framing (flag X as should-fix) belongs in `design-review/SKILL.md`, not in `shared/architecture-principles.md`. The migration for design-review is more involved than for other skills.

## Rollout plan

No deployment. This is a tooling and content change in a local repo. Cut over all at once:

1. Create `shared/` with the three files (content migrated from inline blocks)
2. Write `scripts/propagate.sh` and `scripts/pre-commit.sh`
3. Run the script — creates initial propagated copies
4. Update the seven SKILL.md files that need new/changed references
5. Update `CLAUDE.md`
6. Commit everything

Rollback: revert the commit. The inline blocks were committed before they were removed; `git revert` or `git checkout <hash>` restores them.

## Testing strategy

After running `scripts/propagate.sh`, verify:

```bash
diff shared/architecture-principles.md implementation/architecture-principles.md
diff shared/architecture-principles.md code-review/architecture-principles.md
# etc.
```

Functional test: invoke the `implementation` and `code-review` skills in a test project and confirm the agents find and read the reference files correctly.

After SKILL.md changes: manually review each updated skill to confirm the per-skill framing is correct and the inline blocks are fully removed.

## Out of scope

Content of the new guideline points (the ones that prompted this feature — adding them is a separate editing task once the mechanism is in place). Adding a check script that validates all propagated files are in sync without running a commit.
