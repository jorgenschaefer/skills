# Jorgen's agent skills

Custom [agent skills](https://skills.sh) for Claude Code and other AI agents.

## Install all skills

```bash
npx skills add jorgenschaefer/skills
```

## Install a specific skill

```bash
npx skills add jorgenschaefer/skills@<skill-name>
```

## The feature pipeline

Most of these skills compose into one flow with two front doors and a single implementer.

```
A feature - one change worth shipping on its own:

  /discovery ──→ SPEC.md ──→ /plan ──→ tickets/ ──→ ./loop.sh
                                                      │
                                                      │  ┌─ /implement × N   unattended
                                                      ├──┤  /trace           gaps → tickets
                                                      │  └─ /critique        blockers → tickets
                                                      │     (repeat until both come back clean)
                                                      │
                                                      └─ /handover        promote, then delete

A small change or bugfix:

  /propose-change ──→ one ticket ──→ /implement
```

The split test routes between them: *could you ship this on its own, and would that be worth shipping?* Yes means a feature; no, but someone outside the code can see the difference, means a change; no difference at all means it doesn't want a ticket.

The ticket is the unit both lanes produce and the only thing `/implement` builds. A run has nobody to ask, so it never guesses - it halts, records why in the ticket, and the loop stops for a human. Everything requiring code is a ticket, including what the end-of-run reviews find: `/trace` files its gaps, and the loop turns `/critique`'s blockers into tickets too, so a late fix is built and re-verified rather than patched in behind the checks. `/critique` itself stays a generic review skill - the caller knows about tickets, the reviewer doesn't. Spec, tickets and briefs are deleted once the work is accepted; git history keeps them, and anything that must outlive the run is promoted into the glossary, a comment, or an ADR first.

## Available skills

- **cleanup-repo** - clean up the current project in two passes: find code to delete (dead code, code unrequired by tests/spec, absence-asserting tests) and code to refactor (YAGNI and KISS violations), then produce a reviewable plan and stop for approval before changing anything
- **coding-conventions** - the single source of truth for this project's code-quality standards (simple design, structure and locality, domain layering, validation at the boundary, test coverage, security); read by `/implement` when writing code and `/critique` when reviewing it, so the rules live in one place instead of drifting across skills
- **critique** - review code for quality against the shared `coding-conventions` standard, over either a branch diff or a whole project; verifies each finding before reporting and supplements rather than replaces Claude's own judgment
- **debug** - investigate a bug, test failure, or unexpected behavior to root cause before fixing: reproduce it, instrument component boundaries to find where it breaks, test one hypothesis at a time, and question the architecture after repeated failed fixes
- **decision-brief** - turn a proposed approach (a `/discovery` spec, plan, or PRD) into a one-page decision brief so a reviewer can decide whether to build it as-is or iterate first: surfaces the consequential, contentious, load-bearing, or hard-to-reverse decisions a reviewer might veto, restates each as a neutral tradeoff, and hands the verdict to the reviewer rather than recommending one
- **discovery** - interview the user about one feature, reacting to throwaway HTML mockups for UI decisions; holds the scope to a single shippable change and parks the rest in `IDEAS.md`; produces a spec covering why, success criteria, non-goals, domain, numbered user stories with given/when/then or EARS criteria, design, and implementation decisions
- **explain-diff** - explain a code change, branch, or PR as a self-contained HTML page: background for readers new to the surrounding system, the core intuition with diagrams, a walkthrough of the code, and an interactive quiz to check comprehension
- **git-commit-message** - encode the seven rules of a well-formed commit message (subject/body separation, 50-char imperative subject, no trailing period, 72-char body explaining what and why); auto-loaded when writing a commit, with the repo's existing history as the baseline and the rules as the floor
- **handover** - close out a finished run: orient the reader on what was built, then surface the calls made where the spec was silent, ranked by stakes and neutral on the verdict; on acceptance, promote what must survive into the glossary, a comment, or an ADR, and delete the paper
- **improve-skill** - improve an existing agent skill (make it more effective, more concise, and clearer for an LLM to follow) without changing what it does: applies safe wording edits directly and surfaces behavior-changing edits as decisions for the author
- **implement** - build exactly one ticket: reconcile it against the real codebase, TDD red/green/refactor, the project's own check command (a combined one where it exists, otherwise typecheck and lint), then a quality review and a code review before committing. Never asks a question - halts and records why, so an unattended run stops instead of guessing
- **plan** - decompose a settled `/discovery` spec into the tickets an unattended loop can build: audit the scope cold, split into tickets named for observable behavior, declare what each may rely on from the ones before it, settle only what splitting forces, then review the set for anything a builder would have to guess
- **propose-change** - evaluate a proposed small change or bugfix to existing behavior and turn it into one ticket `/implement` can build: investigate where it lands in the code, weigh cost against benefit, push back on weak ideas, and produce a self-contained ticket (or a reasoned no)
- **repo-overview** - orient a new developer to an unfamiliar codebase: tech stack, code organization, domain model, main workflows, and where to start reading
- **trace** - check a finished feature against the spec it was built from: every criterion met *and* pinned by a test that would fail without it, every constraint verified, every non-goal respected, and nothing built that traces to nothing; uses the project's mutation testing tool where one is configured, since that claim is the one worth executing rather than judging; files a ticket for each gap so it re-enters the same loop
- **ubiquitous-language-init** - bootstrap a UBIQUITOUS_LANGUAGE.md glossary in a brownfield project by excavating domain terminology from the existing codebase
- **upgrade-dependencies** - upgrade npm dependencies safely and incrementally: green baseline, then `npm update`, then remaining majors one at a time, running tests/tsc/lint at every step; also reconciles the Node version across `.nvmrc`, Dockerfile, and `@types/node`
- **wdim** - excavate a fuzzy idea, feeling, or critique into clearer phrasing of what the user actually means

## Adding a new skill

Each skill is a subdirectory containing a `SKILL.md` file:

```
my-skill/
  SKILL.md       # Required: frontmatter + instructions
  *.md           # Optional: additional reference files
```

`SKILL.md` frontmatter:

```yaml
---
name: my-skill
description: One-line description used for discovery.
---
```
