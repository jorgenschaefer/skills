# Architecture

Cross-cutting decisions that constrain future design choices. Verify each against the codebase before relying on it — rationale drifts.

## Workflow structure

| Decision | Rule | Why |
|---|---|---|
| Sequential phased workflow | Each phase must complete and produce its artifact before the next phase begins. Do not merge multiple phases into one skill invocation or automate the pipeline without human checkpoints. | Enables human-in-the-loop review after each phase and keeps each phase's context clean of prior phases' accumulated assumptions. |
| Clean context for reviews | Review skills must always be invoked in a fresh conversation that did not produce the artifact under review. Do not run a review skill in the same conversation as the producing skill. | An LLM that produced an artifact is primed to agree with it; only a reviewer starting from a clean context can genuinely challenge it. |

## Artifact lifecycle

| Decision | Rule | Why |
|---|---|---|
| Feature folders are transient | Delete `docs/features/<slug>/` once a feature is shipped and its final review approved. Do not archive or preserve phase artifacts after the feature is in the code. | Once the feature is in the code, the code is the truth; stale phase artifacts accumulate outdated information and mislead future agents. |
| Permanent artifacts | [`ARCHITECTURE.md`](ARCHITECTURE.md) and [`UBIQUITOUS_LANGUAGE.md`](UBIQUITOUS_LANGUAGE.md) are permanent and must stay accurate as the codebase evolves. All other workflow artifacts are deleted with the feature folder. | These files are the cross-conversation memory for agents; they must remain current to be useful. |

## Organization

| Decision | Rule | Why |
|---|---|---|
| Feature slug as primary key | Every feature tracked through the workflow must have a kebab-case feature slug. All artifacts for a feature live under `docs/features/<slug>/`. Do not organize workflow artifacts by phase or use any other identifier. | One human-readable key makes it clear what belongs together and what can be deleted together; `docs/features/` shows exactly what is in flight. |

## Format and tooling

| Decision | Rule | Why |
|---|---|---|
| Markdown for all artifacts | All skill instructions and workflow artifacts are Markdown files. Do not introduce JSON, YAML, or other structured formats for artifact content. | LLMs read and write Markdown natively; no parser is required; humans can edit artifacts in any text editor. |
| Shared content via copy-propagation | Shared instructional content lives in `shared/` and is copied into skill directories by `scripts/propagate.sh`. Do not use runtime cross-skill file references or inline the same content in multiple skills by hand. | `skills.sh` installs skill directories individually; a shared directory at the repo root is not available after single-skill installation. Copy-propagation keeps each installed skill self-contained while maintaining a single source of truth. |
