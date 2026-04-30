# Feature Brief: Shared Skill Content

**Status:** Draft
**Author:** jorgen.schaefer@mindmatters.de
**Date:** 2026-04-30

## Summary

Several skills contain near-duplicate blocks describing what good code looks like — adapter boundaries, screaming architecture, deep modules, code clarity. Adding or updating a guideline requires editing 5–7 files, and the copies have already begun to diverge. This feature addresses that maintenance problem by establishing a single source of truth for shared content and a propagation step that keeps each skill's copy in sync.

## Problem

When the author wants to add a new code-quality guideline — prompted by a case where the implementation skill produced bad code the review skill didn't catch — the same text must be added to every affected skill file. There is no single place to edit. The risk of forgetting a file or phrasing things inconsistently grows with every update.

The affected skills today are: `implementation`, `code-review`, `design`, `design-review`, `planning`, `planning-review`, `refactor-project`. The duplicated content covers adapter boundaries (3-layer architecture), screaming architecture (domain-organized folders), deep modules (Ousterhout), code clarity ("clear over clever", dead-weight-free), and ubiquitous language references.

The copies are not identical: the same principle appears in different registers depending on the skill's role — an implementation guideline ("keep business logic isolated from adapters") vs. a reviewer checklist ("flag: business logic importing from an ORM"). This is intentional and must be preserved.

## Users and stakeholders

One person: the author. The skills are published for others to install, but the maintenance problem is entirely the author's.

## Why now

A reviewer skill failed to flag bad code that the implementation skill produced. The author wants to add new guideline points to prevent recurrence. That update would require touching 5–7 files, which exposed the maintenance problem clearly enough to address it now.

## Goals

- A single source file for code-quality guideline content.
- A propagation script that copies content from the source file into each affected skill's directory before commit.
- Adding or updating a guideline requires editing exactly one file.
- The per-skill framing ("adhere when implementing" vs. "flag when reviewing") stays short — one or two sentences — and remains per-skill.

## Non-goals

- Supporting independent skill installs (i.e., `npx skills add jorgenschaefer/skills@implementation` working standalone). The author always installs all skills together and does not need this.
- Changing the skills.sh platform or its install mechanism.
- Eliminating all duplication — only content that is genuinely shared principle belongs in the canonical file. Skill-specific framing and application context stay per-skill.
- Defining which specific new guideline points to add. That is content work separate from the mechanism.

## Constraints

- **skills.sh does not support shared context natively.** The installer only copies directories containing a `SKILL.md`; a root-level `shared/` directory would not be installed. Any shared-file mechanism must be handled in the source repository before the skills are published.
- **Per-skill copies must be committed.** The propagated per-skill files must exist in the committed repository so that a fresh clone has fully working skills without requiring any local setup step. The source of truth and the generated copies both live in git.
- **Content varies by skill role.** The same principle is expressed in different registers per skill. The propagation mechanism may need to support either verbatim copying or per-skill customization (a wrapper that embeds shared content into a per-skill template).
- **No new runtime dependencies.** The propagation tooling must be simple enough to run as a git hook or a standalone script with no complex setup.

## Success criteria

- The author can add a new code-quality guideline by editing one file. After running the build step, the change appears in every affected skill.
- The installed skills are self-contained: each skill directory includes everything it needs, with no cross-skill file references at runtime.
- The build step runs without errors on a clean checkout.

## Open questions

- **Which content to extract, and into how many files?** Content could go in one large file or be split by category (e.g., architecture guidelines vs. code-level guidelines). Needs design-phase decision.
- **Verbatim copy or per-skill template?** Since per-skill framing differs, the propagation step either (a) copies the source file verbatim into each skill directory and each SKILL.md wraps it with a sentence of context, or (b) each skill has a small template that embeds the shared content in the right position. The right model depends on how much the framing actually differs in practice. Design phase should audit the existing differences.
- **Propagation trigger.** A pre-commit git hook is the likely mechanism, but a standalone script the author runs manually is also viable. Tradeoffs: hooks are automatic but invisible; scripts are explicit but require discipline. Design phase to propose an approach; author will confirm during design review.

## Out of scope for this brief

Architecture of the propagation script, specific new guideline content to add, and any changes to the skills.sh platform.
