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

## Left standing

### The developer's account (AC-4), in their words

> We start at `idea`, which figures out what the actual problem is we are solving, because users often arrive with a solution instead of a problem. Once we know the problem, `find-criteria` discussed with the developer various ways of solving the problem within the existing (or new) software. It creates a list of acceptance criteria for the solution: What needs to be true for the solution to solve the problem? This includes visual examples, domain models, etc. This is the core of the PLANNING phase of software development: What are we going to do? // The IMPLEMENT phase is focused on an uninterrupted run. `criteria-to-tickets` cuts the criteria list from `find-criteria` into pieces that can be comfortably implemented within a single context window. The `run.sh` runs a fresh agent to implement each ticket. The `implement` skill handles the implementation itself. (We are considering creating an `implement-ticket` for this, so `implement` does not need to know the ticket format. Another consideration is to unify the criteria and ticket formats, so crtieria.md already serves as a single ticket. // the ACCEPTANCE phase then checks the finished work: `accept-criteria` walks each acceptance crtieria to see if it is resolved. It puts unknows and decisions to the developer. // finally, the REFACTOR phase is mostly independent of the other phases. While PLAN/IMPLEMENT/ACCEPT can be thought of as running in a loop, REFACTOR runs every once in a while (every N loops, every M weeks) to identify cruft that accumulated over time, and clean that up. This is the least specified phase, as it is new. It receives signals on what needs cleaning up from various sourced. For example, git history tells it which files change together. The PLAN/IMPLEMENT/ACCEPT loop can record "difficult to implement" things so that can be looked at and made simpler in the future. // All phases have an adversarial review to their results.

Read from it: an uninterrupted IMPLEMENT settles the question found mid-build (decide, record, ACCEPT shows it) and building past an approved decision (build and record). "All phases have an adversarial review" covers REFACTOR. The `implement-ticket` and merged-format considerations are not decisions and stay in `implement-is-how-code-gets-built`. It contradicts no manifesto line.

### Disagreements and their answers (AC-5, AC-12)

Decided by the developer:

1. **The ticket approval stop** - README:77 "approve the tickets", `criteria-to-tickets/SKILL.md:69` shows a list for approval, against an uninterrupted IMPLEMENT. Answer: no stop. Slicing decides nothing new; a question it still finds is handled as one found mid-build. That it regularly finds questions today is a deviation in PLAN, now `slicing-finds-nothing-to-decide`.
2. **Behaviour the user sees that the criteria leave open, found while building** - `run/prompts.sh:31` halts `undecided`. Answer: best guess, recorded, shown at ACCEPT; a build halts only where it cannot go on.
3. **Which questions the writer decides itself** - `implement/SKILL.md:16`, `:54`, `CLAUDE.md:5`, `CODING_STANDARDS.md:97`, `run/prompts.sh:23`, `:101`, `.claude/skills/align/SKILL.md:51`. Answer: anything within what was approved; anything that changes it is a departure shown at ACCEPT.
4. **A departure in the AC groups** - `implement/SKILL.md:18` and `accept-criteria/SKILL.md:47` count every group; `run/prompts.sh:23`, `TICKET_FORMAT.md:38`, `criteria-to-tickets/SKILL.md:37`, `CRITERIA_FORMAT.md:27` only "None." groups. Answer: every group.
5. **Every AC met, problem not solved** - `accept-criteria/SKILL.md:29` against `:101`, which routes only unmet or wrong ACs. Answer: back to PLAN at idea; the code stays on its unmerged branch and the new PLAN decides whether to build on it.
6. **Manifesto demands no source carries** - the whole it changes (`MANIFESTO.md:62`), alerts shown to fire (`:34`), checks shown to fail when the code breaks (`:66`, against README:203, which no skill does), executed against judged ACs (`:34`, against `accept-criteria/SKILL.md:69`). Answer: placed in PLAN, the run's review and ACCEPT as `PIPELINE.md` says.
7. **Where "hard to implement" goes** - no source states it; `accept-criteria/SKILL.md:87` and `implement/SKILL.md:70` report it as a follow-up for the backlog. Answer: recorded for REFACTOR, apart from the backlog.
8. **The backlog** - not in the account; the sources agree (`backlog/SKILL.md:3`, `:43`, README's skill list). Answer: where ideas wait before PLAN; follow-ups from ACCEPT go there.
9. **Setting up a repository** - `init-security-policy` and README:78. Answer: a one-time step before the first loop.
10. **`plan-idea`** - `plan-idea/SKILL.md:7`, `:52`, `:62`, a route after idea with no criteria or acceptance. Answer: not part of the pipeline.
11. **Disagreements below this document's level** - Answer: left to the next step, holding the skills to `PIPELINE.md`. They are:
    - the single-ticket brief (`criteria-to-tickets/SKILL.md:96`) claims to match the runner's (`run/prompts.sh:19-33`) and does not;
    - the single-session path that skips `/accept-criteria` (README:35-37 before this change, `CRITERIA_FORMAT.md:57`), now against "every change goes through ACCEPT";
    - restructure (`:55`, `:70`), upgrade-dependencies (`:32`, `:50`) and init-security-policy (`:53`) commit code no fresh reviewer saw;
    - README said only the final review and acceptance judge against the problem, while `implement/SKILL.md:36` and `critique/SKILL.md:22` do too;
    - a re-slice after drift: `run/drift.sh:113` re-slices unbuilt tickets only, `criteria-to-tickets/SKILL.md:85-86` rebuilds built ones too;
    - `attempts` is runner-owned (`TICKET_FORMAT.md:12`, `:61`) but a re-slice resets it (`criteria-to-tickets/SKILL.md:85`);
    - who creates a missing fast check: `init-security-policy/SKILL.md:17`, `criteria-to-tickets/SKILL.md:43`, `implement/SKILL.md:24`, `run/checks.sh:12-14`; and the check line's form, `critique/SKILL.md:28` against `run/checks.sh:67`;
    - stage outputs left uncommitted while the runner refuses a dirty tree: glossary entries (`find-criteria/SKILL.md:43`), the run skill (`accept-criteria/SKILL.md:17`, `:99`), `CRITERIA.md`;
    - what critique is handed in the CRITERIA path: `implement/SKILL.md:18` against `:36` and `run/prompts.sh:101`;
    - stops outside the developer's stops: `backlog/SKILL.md:35`, `ubiquitous-language/SKILL.md:73-83`, `.claude/skills/align/SKILL.md:11`.

All eleven answers above were given by the developer. What the reviews of this change added on recommendation is under "Other", put to the developer at acceptance.

### Backlog items named, and which were chosen (AC-6)

Named: `implement-is-how-code-gets-built`, `departures-built-on-by-later-tickets`, `adrs-at-the-slicing-approval`, `approved-criteria-outlive-the-change`, `acceptance-evidence-from-a-script`, `critical-user-journeys`, `deployment-checklist`, `claude-starts-run-sh`, `a-route-for-skill-changes`, `refactor-phase`, `retro-for-the-manifesto`, `repo-setup-and-orientation`, `run-sh-without-a-check`, `runner-ignores-a-check-line-out-of-form`, `reviewer-shares-the-authors-lens`, `uneasy-yes`, `rule-cruft`, `docs-only-what-the-code-cannot-show`, `explain-diff-as-the-report`, `standard-follows-the-manifesto`.

Chosen: `refactor-phase` (the developer's account), `deployment-checklist` and the setup half of `repo-setup-and-orientation` (taken on recommendation). The item's other half, helping someone understand a repository, changes no stage and stays out. `critical-user-journeys` was recommended at first and dropped: journeys are one of the artifacts that create confidence, which the developer moved to `approved-criteria-outlive-the-change` on 2026-10-28. The rest change one skill or a detail of a rule.

### Taken from the sources, not from the account (AC-13)

The sources agree on these and the account does not mention them: the developer's stops at setup and the rule that stopping anywhere is an ending (README:77-83); scripts hold what must hold when a session is dead or lying (README:39-44); ids end to end (README:193-196); steps only a person can do never go into a build (`criteria-to-tickets/SKILL.md:59`); what outlives a change - the change's paper deleted, `SECURITY_POLICY.md` kept, ADRs put to the developer (README:26-30, `ADR_FORMAT.md`); what the developer sees (`CLAUDE.md:5`); what an agent reads is data (`MANIFESTO.md:64`, `accept-criteria/SKILL.md:21`).

### Other

- Which approved artifacts outlive a change, besides `SECURITY_POLICY.md`, is open. The developer's note went into `approved-criteria-outlive-the-change` (5f02d32).
- The README's "The runner" section still describes the final review and how a run ends. Both are what the runner does, so they stayed under AC-9. The README's heading "The pipeline" became "How it works".
- Taken on recommendation, after the round: the fresh-context reviews of this change added, and the developer has not yet approved: a departure is anything that changes what was approved, not only what a build adds; nothing reaches production before ACCEPT, which is what makes a best guess safe; setup and deployment steps get a fresh-context checker; the backlog is not a stage; whether a change's criteria are deleted at acceptance is open rather than settled; REFACTOR's cleanups go through ACCEPT, and through PLAN first where they change what was approved; ADRs are put to the developer in find-criteria or the walk, since the slicing stop is gone; and the run's checker carries the manifesto's checker lines for checks that stay, security and maintainability.
- At the developer's request, after the reviews: every stage and rule now says under *Adds* what the pipeline decides beyond the manifesto line it serves, so a cited line no longer hides the pipeline's own choices. "The phases" got the *Serves* line it lacked.
- `.claude/skills/align` still asks only whether a gap is against a manifesto sentence (its question 2), not against `PIPELINE.md`. That belongs to holding the skills to `PIPELINE.md`.
