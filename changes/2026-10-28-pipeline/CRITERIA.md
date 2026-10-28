# Criteria: write down what the pipeline is meant to be

## Problem
What the pipeline is meant to be - its stages, its stops, what each produces and who checks it, and the decisions it makes beyond the manifesto, such as a refactor phase every few changes - is stated nowhere as intent. It is spread over the README, CLAUDE.md and single skills, mixed with descriptions of what they currently do. So when two skills disagree, or a skill differs from the manifesto, nobody can say whether the skill is wrong or the pipeline changed. The manifesto says a question found mid-build that may change what the user wants waits for the developer, but not whether the build stops or saves it for a fixed stop: `implement` says stop, CLAUDE.md says save it, the runner says decide and report, and none of them is the deviation. What would be true: for each stage and each rule across stages, it is known what the pipeline intends and which manifesto line it serves, if any - so every skill, and the README, can be held to it.

Instance: `implement/SKILL.md:16` ("ask - before or during the build - and do not build past it"), `CLAUDE.md:5` ("A skill does not stop to ask the developer. It saves its questions for the pipeline's fixed stops.") and `run/prompts.sh:23` ("every implementation question on the way: decide it, and report it"), against `MANIFESTO.md`'s "Something found while building that may change what the user wants is a decision the plan didn't cover, and waits for the developer." The backlog item `implement-is-how-code-gets-built` records it, and it is still unsettled on 2026-10-28.

## Acceptance criteria
### Behaviour
- **AC-1** `PIPELINE.md` at the repository root describes the intended pipeline: for each stage, what it is for, what it produces, who checks it and when it runs; and each rule that holds across stages - at that level, never how a stage does its work.
- **AC-2** Each stage and each rule across stages quotes the manifesto line it serves, or says that it is the pipeline's own decision.
- **AC-3** `PIPELINE.md` says nothing about what is built today: no sentence says whether a skill already does something, or that something is not built yet.
- **AC-4** First, the developer describes in their own words how they envision the pipeline - its stages, its stops, what holds it together. `PIPELINE.md` states that account wherever it speaks, unless it contradicts the manifesto; then the session writing `PIPELINE.md` shows the developer the contradiction with the manifesto's wording, and the developer's decision goes in. The account is kept, in the developer's words, in this file's `## Left standing`.
- **AC-5** Where the developer takes no view on a disagreement in that round, the recommendation goes in, and `## Left standing` lists it as taken on recommendation. `## Left standing` lists every disagreement with its sources and its answer.
- **AC-6** In the same round, the session writing `PIPELINE.md` names each backlog item that adds or changes a stage, and the developer decides which of them belong to the intended pipeline. Those chosen are in `PIPELINE.md` at the level of AC-1; the refactor phase is among them. `## Left standing` lists the items named and which were chosen.
- **AC-7** `PIPELINE.md` states what happens to a question found mid-build: whether the build stops or saves it for a fixed stop, and which questions the writer may decide itself.
- **AC-8** `PIPELINE.md` says how it is changed: a later change that alters a stage's intent or a rule across stages edits `PIPELINE.md` in the same change, and the developer approves that edit like an AC.
- **AC-9** The README states none of the pipeline's intent - not the diagram, the stages, the stops, what is approved, who checks what, the shortcuts for small changes, or "What holds it together" - and points to `PIPELINE.md` for it. It keeps installing, the skill list, and how the runner, sync and tests work: what each does and refuses, not which stage it serves.
- **AC-10** `CLAUDE.md` names `PIPELINE.md` as what to read before changing what a skill is for, and states no rule for how the pipeline or a skill deals with the developer; the ones it holds today ("Design every skill so that developer sees what the manifesto puts in bold", "evidence for each result", "shows it in one line", "saves its questions for the pipeline's fixed stops") are settled in `PIPELINE.md` as AC-4 and AC-12 say. It keeps what the repository is, that a file two skills need is copied into each, the pointer to `MANIFESTO.md`, and the fast check.
- **AC-11** `MANIFESTO.md` is unchanged.
- **AC-12** Where the developer's account says nothing about a stage or a rule across stages, the session writing `PIPELINE.md` puts to the developer, in one round, every disagreement it found between the README, CLAUDE.md, the skills and the runner, each with the sources' wording and a recommendation. `PIPELINE.md` states the answer decided.
- **AC-13** A stage or rule across stages that the developer's account does not mention and the sources agree on goes into `PIPELINE.md` as the sources state it, and `## Left standing` lists it as taken from the sources rather than from the account.
- **AC-14** The project skill `align` reads `PIPELINE.md` beside `MANIFESTO.md` for the pipeline's intent, and plans edits to the `PIPELINE.md` passages a change alters rather than to README passages stating intent.

### What production must show
None.

### Security policy
None.

### Information model
None.

## Agreed design
A document of its own, `PIPELINE.md`, at the repository root beside `MANIFESTO.md`, not copied into the skills. It describes the pipeline as intended, not as built, and is a first draft that later changes revise.

Built in one session rather than by `run.sh` or `/implement`: the developer's account and the decision round need the developer during the build, and `/implement` is built for code. The result is reviewed by a subagent with a fresh context that gets this file, `MANIFESTO.md` and the diff, then accepted with `/accept-criteria`.

## Technical decisions
- **Concepts** *The pipeline*: the intended sequence of stages and the rules across them, between the manifesto and the skills. `PIPELINE.md` describes it.
- **Wire formats** none.
- **Hard to reverse** none.

## Out of scope
- Holding the skills to `PIPELINE.md`, and changing any skill but `align`. That is the next step.
- How skill steps cite the manifesto or `PIPELINE.md`.
- Which skill carries which stage.
- Designing the refactor phase, or any stage, beyond the level of AC-1.
- A check in `test.sh` for `PIPELINE.md`.

## Ruled out
- **Rewriting the README's pipeline section as the intent** - it keeps intent mixed with installing.
- **A copy of `PIPELINE.md` in every skill** - copies pay off only once skills cite the intent at runtime, which is parked.
- **A second part of `MANIFESTO.md`** - it breaks "A pipeline can work however it likes, as long as it follows this."
- **Disagreements left as open lines** - they leave each such rule where the problem started.
- **Describing the pipeline as built today** - the document is the target, not an inventory.
- **`/implement` for the build** - it holds the work to the code standard and reviews by driving a product; this change has neither.
