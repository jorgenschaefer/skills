# Ubiquitous Language

Domain terms used across this project. Each entry gives the canonical term and its meaning in this context.

---

**Feature folder** — A directory under `docs/features/<slug>/` that contains all artifacts produced for a single feature, regardless of which phase produced them.

**Feature slug** — A short kebab-case identifier that uniquely names a feature and appears in its folder name and artifact filenames. Serves as the common thread connecting artifacts across phases.

**Entry point** — The first skill invoked for a feature, which produces the initial artifact that feeds the rest of the workflow. Currently either `discovery` (produces a Feature Brief) or `refactor-project` (produces a Refactoring Proposal).

**Entry artifact** — The initial document in a feature folder, produced by the entry point skill. Either `discovery.md` (from `discovery`) or `refactoring.md` (from `refactor-project`). Downstream skills look for the entry artifact to understand the feature's scope before proceeding.

**Phase artifact** — Any document produced by a workflow skill (Feature Brief, Design Doc, Refactoring Proposal, Ticket Backlog, individual tickets, ADRs, review files). Phase artifacts are scaffolding — useful while building, but not the long-term output.

**Permanent artifact** — An artifact that carries forward to influence future work regardless of feature status. Currently: `UBIQUITOUS_LANGUAGE.md` and ADRs. Distinguished from phase artifacts, which are reference-only once their phase is done.
