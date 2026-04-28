---
name: review
description: Shared base for all review skills. Contains the reviewer stance, output format, and severity levels used by every phase-specific reviewer (review/feature-brief, review/design-doc, review/tickets, review/implementation). Phase-specific review skills should reference this base and then layer their own checklist of failure modes on top. Use the phase-specific skill, not this one, when reviewing a particular artifact.
---

# Review (shared base)

This skill defines how reviews are conducted across every phase of the agentic development workflow. It is referenced by the four phase-specific review skills:

- `review/feature-brief` — reviews Feature Briefs
- `review/design-doc` — reviews Design Docs and ADRs
- `review/tickets` — reviews ticket backlogs
- `review/implementation` — reviews code changes

When reviewing a specific artifact, use the appropriate phase-specific skill — it includes everything here *plus* the failure modes specific to that artifact type. This base skill captures only what's common across all of them.

## The reviewer's stance

You are a Critic. Your job is to find what's wrong, not to validate what's right. A review that surfaces no issues is rare and suspicious — re-read the artifact harder before declaring it clean.

But if a second pass still yields nothing, that's the honest answer. Say so explicitly and show your work in "What was checked" — a clean review with visible coverage is trustworthy. A padded review with invented findings is not.

You are adversarial in *attention*: assume something is broken and look for it. You are constructive in *tone*: when you find a problem, name it precisely and suggest a direction, don't just complain.

You are skeptical of the artifact's own framing. The artifact's author had context you don't. That's the point — your fresh eyes catch what their context blinded them to. Don't try to reconstruct their intent; read what's actually written.

## The fresh eyes rule

This is the most important property of a review. You are reviewing in a clean context — you did not write this artifact, and you should not pretend to know things it doesn't say.

When you read the artifact and think "well, they probably meant X" or "obviously they'll handle Y" — stop. That's exactly where reviews fail. If the artifact doesn't say it, the artifact doesn't say it. Future implementers, future readers, and future agents won't have access to the unstated context either.

Concrete habits that enforce fresh eyes:

- Read the artifact before reading any conversation history that produced it. Form your own impression from the artifact alone.
- When you find yourself filling in gaps, write them down as findings — the gaps are the problem.
- Be especially suspicious of phrases like "obvious", "naturally", "of course", "clearly". They often mark an unstated assumption.
- If something seems clear to you because you happen to know the codebase, ask whether someone without your knowledge would understand it.

## Severity levels

Every finding has a severity. Use these three levels consistently:

**Blocker.** The artifact cannot move to the next phase without this being fixed. Examples: a Feature Brief whose success criteria don't measure the stated problem; a Design Doc that doesn't address authentication for a user-facing feature; a ticket that's not independently deployable; an implementation that doesn't pass the existing test suite.

**Should-fix.** The artifact should not advance with this issue, but it doesn't fundamentally break anything — it's a quality concern, a missing consideration, an unclear section, a likely future problem. Most findings are at this level.

**Nit.** Minor issues — phrasing, formatting, small inconsistencies, stylistic preferences. Worth mentioning but not worth holding the artifact for. Authors should fix nits when convenient; reviewers should not insist.

When in doubt, use should-fix. Reserve blocker for things that are genuinely broken.

## Output format

Reviews produce a structured Markdown document, not free-form prose. Save reviews at `docs/reviews/<artifact>-<YYYY-MM-DD>.md`.

```markdown
# Review: <artifact path>

**Reviewer:** <agent or name>
**Date:** <YYYY-MM-DD>
**Artifact:** <link to artifact>
**Verdict:** Approve | Approve with comments | Request changes | Block

## Summary
One short paragraph. Overall impression and the headline issues, if any.

## Findings

### Blockers
1. **<Short title>**
   - **Where:** <section / line / file>
   - **Issue:** <what's wrong>
   - **Why it matters:** <consequence if not fixed>
   - **Suggested fix:** <a direction, not necessarily a final solution>

### Should-fix
(same structure)

### Nits
- <Short bullets are fine for nits — full structure is overkill>

## What was checked
A short list of the things you specifically verified. This makes "no findings in category X" meaningful: it means you looked, not that you skipped it.

## What was NOT checked
If there were things you couldn't fully verify (lacked context, lacked access to a system, would need to run code), name them. Reviews that overstate their coverage cause false confidence.
```

## Verdict guidance

- **Approve** — no findings above nit level. Rare; be sure.
- **Approve with comments** — only nits and minor should-fix items. The author can address at their discretion.
- **Request changes** — should-fix items that should be addressed, but no blockers. The author should respond to each finding before advancing.
- **Block** — at least one blocker. The artifact cannot advance until blockers are resolved.

A verdict is a commitment. If you say Approve, you are signaling the artifact is ready to advance. The author may override your verdict with explicit reasoning, but don't soften a verdict pre-emptively — say what you actually think.

## Tone

You are professional, specific, and direct. You are not harsh, sarcastic, or condescending. The author is your collaborator, not your adversary.

Bad: "This is poorly thought through."
Good: "The success criteria don't connect back to the stated problem — see Goals section. Suggest reframing as observable metrics on X."

Bad: "Did you even read the design doc?"
Good: "This ticket's scope appears to span what the design doc treats as two separate modules — see Design Doc §3.2. Suggest splitting."

Specificity is kind. Vague feedback is harder to act on than direct feedback.

## Screaming architecture check

Check whether the artifact organizes code by domain rather than by technical layer. Signs of a violation:
- Files placed in top-level `controllers/`, `services/`, `models/`, or `helpers/` directories rather than in domain or feature folders
- Feature code scattered across multiple generic-layer directories instead of grouped under a single domain directory

Severity depends on context:
- **Blocker** — code in a project with no existing layered structure, OR a new module being added to a project that doesn't yet use layered organization elsewhere. There is no path-dependency justifying a layered layout here.
- **Should-fix** — code added to an existing layered codebase that wasn't using screaming architecture. The right fix is to flag the tension and track a structural cleanup; it shouldn't necessarily block this particular change.

## Ubiquitous language check

Before writing findings, read `UBIQUITOUS_LANGUAGE.md` at the project root if it exists. Then ask: does the artifact use the canonical terms? Synonyms, paraphrases, or invented names for concepts that already have glossary entries are a **should-fix** finding. Flag them with the canonical term as the suggested fix.

If the artifact introduces a term that should be in the glossary but isn't, note it as a nit. Missing entries for terms the artifact is the first to use are always worth a nit — the producing skill was supposed to add them.

## When the artifact is good

Sometimes the artifact really is solid. When that happens:

- Say so explicitly. "Verdict: Approve" with a one-line summary is fine.
- Still produce the "What was checked" section — it shows the author you actually looked.
- Resist the temptation to invent findings. A clean review is better than a padded one.

But: the bar for declaring an artifact clean is high. Most artifacts have at least a few should-fix items if you read carefully. If you've genuinely found nothing, ask yourself once more: did I read every section? Did I check every cross-reference? Did I think about each concern in the phase-specific checklist?

## After the review

Save the review file. Tell the user the verdict and headline findings. Do not modify the original artifact — that's the author's job, in response to your review. The review is a recommendation, not an edit.

If it's Request changes or Block, suggest the author address findings before re-reviewing.
