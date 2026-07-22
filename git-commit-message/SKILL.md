---
name: git-commit-message
description: Use when writing a git commit message before running `git commit`.
---

# Git Commit Message

**The repo's existing history is the baseline; these seven rules are the floor.** Read a few recent messages (`git log --oneline -20`, then a full one or two) and match their conventions — a Conventional Commits prefix (`feat:`, `fix:`), a ticket reference, a casing scheme. Where the repo pins a choice, follow it; for everything it leaves open, apply the rules below. When a convention genuinely conflicts with a rule (e.g. Conventional Commits lowercases the subject, against rule 3), the convention wins for that rule only — every non-conflicting rule still holds.

## The seven rules

1. **Separate subject from body with a blank line.** Line 1 is the subject; if there is a body, line 2 is blank and the body starts on line 3. `git log`, `shortlog`, and `rebase` rely on this split. Skip the body only when the subject already says everything.

2. **Limit the subject to 50 characters.** Treat 50 as the target and 72 as the hard cap. If the change won't fit, it is likely doing more than one thing — consider splitting the commit.

3. **Capitalize the subject line.** `Add`, not `add` — unless the repo's scheme says otherwise.

4. **Do not end the subject line with a period.**

5. **Use the imperative mood in the subject.** Write it to complete *"If applied, this commit will ___"* — `Fix the parser`, `Add retry logic`, not `Fixed`, `Fixes`, or `Changes to`. This matches git's own generated messages (`Merge`, `Revert`).

6. **Wrap the body at 72 characters.** Git does not wrap text, so hard-wrap the lines yourself; leave URLs and other unwrappable tokens intact.

7. **Use the body to explain what and why, not how.** The diff already shows how the code changed. The body carries what the diff can't: the prior behavior, the new behavior, and why this solution over another. Bullet points are fine; separate paragraphs with a blank line.

## Committing a multi-line message

Pass the message through a here-doc rather than stacking `-m` flags, so the blank line and body wrapping survive:

```bash
git commit -m "$(cat <<'EOF'
Summarize the change in the imperative

Explain what changed and why it was needed, wrapped at 72
columns. Describe the prior behavior and the reason for this
approach.
EOF
)"
```

Before committing, re-read the finished message against all seven rules.
