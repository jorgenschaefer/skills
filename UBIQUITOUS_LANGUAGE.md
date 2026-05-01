# Ubiquitous Language

Domain terms used across this skills project and the agentic development workflow it implements.

## Workflow structure

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Workflow** | The full sequence of phases (discovery → design → planning → implementation) through which a feature travels from idea to shipped code | Process, pipeline |
| **Phase** | A named stage in the workflow, each with a dedicated skill, defined inputs, and a defined output artifact | Step, stage |
| **Skill** | An agent behavior definition — a directory with a `SKILL.md` that specifies role, inputs, process, and output format for one phase | Command, slash command, task |
| **Sub-skill** | A skill nested inside a parent skill directory; inherits shared content from the parent and adds phase-specific behavior | Child skill |
| **Entry point** | The skill that starts a feature's workflow, producing the initial artifact all downstream skills read | Starting skill |
| **Clean context** | The property of running a skill in a conversation that did not produce the artifact it reads — required by review sub-skills to avoid the author's blind spots | Fresh eyes, independent review |

## Feature tracking

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Feature** | A discrete unit of product or technical work tracked through the workflow from discovery to implementation | Task, story, project |
| **Feature slug** | A short kebab-case identifier that names a feature and appears in its folder path and artifact filenames | Feature ID, feature name |
| **Feature folder** | The directory `docs/features/<slug>/` that holds all artifacts produced for a single feature across all phases | Feature directory |

## Artifacts

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Feature Brief** | The output of the discovery phase — captures the problem, affected users, constraints, and success criteria; contains no design or implementation details | Discovery doc, requirements doc |
| **Refactoring Proposal** | The output of refactor-design — captures architectural friction and a proposed improvement plan; serves as an alternative entry artifact when the work is driven by structural concerns rather than a new feature | Refactor doc, technical debt report |
| **Design Doc** | The output of the design phase — a concrete technical plan with alternatives considered and decisions recorded; exists to be reviewed and challenged before any code is written | Architecture doc, tech spec, RFC |
| **ADR** | Architecture Decision Record — documents a single significant technical choice, the options considered, and the rationale; lives at `docs/adr/<NNNN>-<slug>.md` | Decision log, design decision |
| **Ticket Backlog** | The output of the planning phase — a set of independently-deployable tickets that together implement the Design Doc | Task list, sprint backlog, work breakdown |
| **Ticket** | A single unit of work within a Ticket Backlog — independently testable, independently deployable, and ideally a tracer bullet that delivers value on its own | Story, task, issue |
| **Review file** | The output of a review sub-skill — saved alongside the artifact it reviewed as `<artifact>-review-<NN>.md` | Review doc, code review (prefer "review file" to avoid confusion with the code-review skill) |

## Artifact categories

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Entry artifact** | The initial document in a Feature folder — either a Feature Brief or a Refactoring Proposal — that downstream skills read to understand a feature's scope | Input artifact, starting artifact |
| **Phase artifact** | Any document produced by a workflow skill; useful while building but treated as reference-only once its phase is complete | Intermediate artifact |
| **Permanent artifact** | An artifact that carries forward to influence future work regardless of feature status — currently ADRs and `UBIQUITOUS_LANGUAGE.md` | Long-lived artifact |

## Phase dynamics

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Product-technical boundary decision** | A requirement or configuration value the user already knows and has decided, which only becomes relevant once the problem is fully understood — e.g. "truncate lists at 5 items", "default timeout is 30s". Not derived through technical analysis; the user brings it. Too specific for the Feature Brief, but not a design output either. Belongs in the Design Doc, surfaced by the clarification round. | Product detail, implementation detail, design decision |
| **Clarification round** | A step in the design phase triggered by product-technical boundary decisions not in the Feature Brief, or by any pending ADR. The agent presents both together in a single structured message before producing the Design Doc. ADR confirmations are always included — writing an ADR without user input is never acceptable. Skipped only when no gaps exist and no ADRs are planned. | Check-in, clarification pass, design questions |

## Relationships

- A **Feature** has exactly one **Feature slug** and one **Feature folder**
- A **Feature folder** holds all **Phase artifacts** for that feature across every phase
- A **Phase** corresponds to exactly one **Skill**; a **Sub-skill** belongs to one parent **Skill**
- An **Entry point** produces exactly one **Entry artifact** — either a **Feature Brief** (discovery) or a **Refactoring Proposal** (refactor-design)
- A **Design Doc** is accompanied by zero or more **ADRs**; the **ADRs** are **Permanent artifacts**, the **Design Doc** is a **Phase artifact**
- A **Ticket Backlog** contains one or more **Tickets**
- A **Review file** is paired with the specific **Phase artifact** it reviewed

## Example dialogue

> **Dev:** "We have a Feature Brief. Can we skip straight to planning?"
>
> **Domain expert:** "No — planning consumes a Design Doc, not a Feature Brief. The Design Doc is what tells the Planner how to slice the work into Tickets."
>
> **Dev:** "The feature is small. Can the Design Doc just be one paragraph?"
>
> **Domain expert:** "Yes, as long as it records the ADRs for any non-obvious choices. The design-review step is your gate — it catches hand-waving before it becomes a Ticket Backlog nobody can implement."
>
> **Dev:** "Do the ADRs live inside the Feature folder?"
>
> **Domain expert:** "No — `docs/adr/` at the repo root. ADRs are Permanent artifacts: once the feature is done the Design Doc is reference-only, but the ADRs carry forward to inform every future design."
>
> **Dev:** "And when I run design-review, should I do it in the same conversation that produced the Design Doc?"
>
> **Domain expert:** "Definitely not. The review sub-skills depend on clean context — a reviewer who wrote the artifact can't give it fresh eyes."

## Skill authoring

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Shared content file** | A canonical source file in `shared/` whose content is copied into one or more skill directories by the propagation script; the authoritative version of text that appears in multiple skills | Master file, template |
| **Propagation** | The act of copying shared content files from `shared/` into their destination skill directories, performed by `scripts/propagate.sh` before committing | Build step, sync, deployment |
| **Propagation script** | `scripts/propagate.sh` — the script that copies each shared content file to its configured destination skill directories | Build script, sync script |

## Flagged ambiguities

- **"review"** is used for both the phase (the act of reviewing an artifact) and the review skills (`design-review`, etc.) and the output file. Canonical usage: **Review** or **review skill** for the phase/skill, **review file** for the artifact it produces.
- **"entry point" vs "entry artifact"**: these are distinct. An **entry point** is a skill (discovery or refactor-design); an **entry artifact** is the document that skill produces. Don't use them interchangeably.
- **"feature"** sometimes refers to the product concept (what is being built) and sometimes the tracking context (the Feature folder and its slug). Context usually disambiguates, but when precision matters, prefer "Feature" for the concept and "Feature folder" or "Feature slug" for the tracking artifact.
