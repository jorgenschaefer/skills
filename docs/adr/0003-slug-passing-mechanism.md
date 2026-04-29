# ADR 0003: Slug-Passing Mechanism — How Skills Receive the Feature Slug

**Status:** Accepted
**Date:** 2026-04-28
**Context:** [Feature-First Docs Design Doc](../design/feature-first-docs.md)

## Context

The feature-first-docs reorganization requires every skill to know the feature slug in order to construct the correct output path (`docs/features/<slug>/...`). The feature brief listed slug passing as an open question for the design phase, with four candidate approaches: required argument at invocation time, reading from a project-level config file, scanning for an existing folder, or other.

## Decision

The slug is a required argument provided at invocation time (e.g., `/discovery payment-retry`). Skills fail fast — or ask before proceeding — if no slug is supplied and none can be derived from other arguments.

## Alternatives considered

**Project-level config file (e.g., `.feature-slug` or `docs/features/.current`).** A config file at the repo root or inside `docs/features/` would record the active feature slug, letting skills read it without the user repeating themselves. Rejected because it introduces implicit shared state: switching branches, working on two features simultaneously, or forgetting to update the file creates silent path mismatches. The failure mode — artifacts silently written to the wrong feature folder — is worse than the friction of passing a slug explicitly.

**Scan `docs/features/` for an existing folder.** If exactly one feature folder exists, the skill could infer the slug without being told. Rejected because it breaks immediately when there are two or more features in progress (which the brief explicitly describes as the normal case — "2–3 features in parallel on separate branches"). An ambiguous scan forces a disambiguation prompt anyway, so nothing is saved, and the code path for single-feature repos gives a false sense of automation that breaks at the worst time.

**Derive slug from current git branch name.** Parse the branch name and extract a slug. Rejected because branch names are not guaranteed to match feature slugs, the skill system has no access to git state, and the coupling between branch discipline and folder layout is surprising.

## Consequences

- Every skill invocation that targets a feature artifact requires the user to pass a slug. This is one extra word at the prompt; the payoff is explicit, predictable path construction.
- The boy-scout pseudo-feature (`docs/features/boy-scout/`) is the only exception: its folder is permanent and its path is hardcoded in the relevant skills; no per-invocation slug is needed.
- Review sub-skills can also accept a file path in place of a slug (e.g., when the user pastes a path from a file browser). They derive the slug from the path rather than requiring re-entry.
