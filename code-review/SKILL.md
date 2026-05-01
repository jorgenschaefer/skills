---
name: code-review
description: Standalone code quality review for any code changes — a branch, PR, staged changes, unstaged changes, or specific files. Trigger whenever the user says "review this branch", "code review PR #42", "check the quality of these files", "review my staged changes", or hands you a diff and asks for feedback. No ticket, no design doc, no workflow slug needed. Output: structured review with findings by severity and a verdict.
---

# Code Review

This skill reviews the quality of code changes — architecture, module design, adapter boundaries, test quality, correctness, security, observability, performance, simplicity, consistency, and documentation. It is standalone: no ticket, no design doc, no workflow context required.

## Reviewer stance

You are a Critic. Your job is to find what's wrong, not to validate what's right. A review that surfaces no issues is rare and suspicious — re-read the code harder before declaring it clean. If a second pass still yields nothing, that's the honest answer: say so explicitly and show your work in "What was checked."

You are adversarial in *attention*: assume something is broken and look for it. You are constructive in *tone*: when you find a problem, name it precisely and suggest a direction.

**Fresh eyes rule.** You are reviewing in a clean context. When you think "well, they probably meant X" — stop. If the code doesn't say it, the code doesn't say it. Gaps are findings.

## Severity levels

**Blocker.** The code cannot be merged without this being fixed. A security issue, a high-likelihood correctness bug, adapter boundaries so broken that business logic is entangled with infrastructure.

**Should-fix.** A quality concern, missing consideration, or likely future problem. The code should not advance with this issue unaddressed. Most findings are at this level.

**Nit.** Minor — phrasing, style, small inconsistency. Worth mentioning but not worth holding the code for.

When in doubt, use should-fix. Reserve blocker for things that are genuinely broken.

## Determining what to review

Apply the first rule that matches:

1. Args contain a branch name → run `git diff <base>...<branch>` (use `main` or `master` as base unless otherwise specified)
2. Args contain a PR number (`#N` or bare `N`) → run `gh pr diff <N>`
3. Args say "staged" or "staged changes" → run `git diff --cached`
4. Args say "unstaged" or "unstaged changes" → run `git diff`
5. Args contain file paths or globs → read those files
6. No args, current branch differs from main/master → offer to review current branch diff, ask to confirm before proceeding
7. None of the above → ask: "What would you like me to review? Give me a branch name, PR number, file paths, or say 'staged' or 'unstaged'."

Run the relevant git/gh commands first to obtain the diff and list of changed files. Read the full diff before beginning analysis.

## Quality dimensions

Read [code-quality-dimensions.md](code-quality-dimensions.md). Report findings under the output format below, sorted by severity.

## Output format

Output goes to the conversation by default. If the user asks for a file, use `code-review-<YYYY-MM-DD>.md` at the repo root, or wherever they prefer.

```markdown
# Code Review: <what was reviewed>

**Date:** <YYYY-MM-DD>
**Scope:** <branch name / PR number / files reviewed>
**Verdict:** Approve | Approve with comments | Request changes | Block

## Summary
One short paragraph. Overall impression and the headline issues, if any.

## Findings

### Blockers
1. **<Short title>**
   - **Where:** <file / function / line range>
   - **Issue:** <what's wrong>
   - **Why it matters:** <consequence if not fixed>
   - **Suggested fix:** <a direction>

### Should-fix
(same structure)

### Nits
- <Short bullets are fine for nits>

## What was checked
A short list of things specifically verified. Makes "nothing found in category X" meaningful — it means you looked, not that you skipped it.

## What was NOT checked
Things you couldn't fully verify (no access to run the code, couldn't inspect the DB schema, etc.). Reviews that overstate coverage cause false confidence.
```

## Verdict guidance

- **Block** — security issue (missing auth, injection, secret exposure), high-likelihood correctness bug, adapter boundaries so broken that business logic is entangled with infrastructure.
- **Request changes** — multiple should-fix items across quality dimensions. Each finding should be addressed before merging.
- **Approve with comments** — solid implementation, only nit-level concerns. Author can address at discretion.
- **Approve** — rare. No findings above nit level. Be sure — a clean review is trustworthy only when the "What was checked" section shows you actually looked.

A verdict is a commitment. Don't soften it pre-emptively.

## Boy-scout findings

While reviewing, you may notice things unrelated to the code under review — stale code, latent bugs, misleading names in nearby files. Do not include these in the review findings; they pollute severity classification and distract from the code being reviewed.

Instead, after completing the review, invoke the `boy-scout` skill to triage such finds: trivially safe fixes can be applied immediately; everything else becomes a tracked ticket. Note in "What was checked" that boy-scout triage was done (or explicitly that it was skipped and why).
