# ADR 0005: Markdown as the universal format for skill instructions and workflow artifacts

**Status:** Accepted
**Date:** 2026-04-30
**Context:** Retrospective — extracted from codebase

> **Decision:** Markdown is the universal format for both skill instructions and all workflow artifacts. It is the industry standard for human-readable technical writing, LLMs are trained on it extensively, and it requires no parser — agents read and write it natively.

## Context

This ADR was extracted from the existing codebase. No prior design document exists for this decision.

Every skill instruction file (`SKILL.md`) is Markdown with a small YAML frontmatter block containing only `name` and `description`. Every workflow artifact produced by phase skills (Feature Briefs, Design Docs, Ticket Backlogs, ADRs, review files) is a `.md` file. Reference files within skill directories (e.g., `architecture-principles.md`, `code-style.md`, `review-base.md`) are also Markdown. No structured data format is used for artifact content; agents read and write prose Markdown directly.

## Decision

Markdown is the universal format for both skill instructions and all workflow artifacts. We use Markdown because it is the industry standard for human-readable technical writing, LLMs are trained on it extensively, and it requires no parser or transformation step — agents read and write it natively. Humans can edit it directly without tooling.

## Alternatives considered

**Structured formats (JSON, YAML) for artifact content.** Would enable deterministic field extraction by machines but would make content harder for humans to write and read. Not necessary: LLMs consume prose natively and can locate fields in well-structured Markdown without a formal parser. Rejected.

## Consequences

**Easier:** Any agent can read and produce artifacts without a parser. Humans can view and edit artifacts in any text editor. Skill instructions are readable without tooling.

**Harder:** Extracting a specific field from an artifact programmatically requires prompt engineering rather than parsing. Structural conventions (section headings, ordering) must be maintained by prose instructions rather than schema validation.

**Committed to:** All artifacts are Markdown files. YAML frontmatter in SKILL.md is kept minimal — only `name` and `description`. New skills and new artifact types must follow this format.

**Forecloses:** Introducing JSON or YAML artifact formats. Generating artifacts in formats that require a dedicated parser to consume.
