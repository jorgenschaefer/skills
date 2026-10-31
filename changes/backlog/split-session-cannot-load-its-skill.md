---
effort: XS
utility: S
---

# The split session cannot load its skill

`split-change-into-chunks/SKILL.md` has `disable-model-invocation: true`. So
the session the runner starts for the split does not see the skill, even
though it is installed in `~/.claude/skills`. The runner's prompt
(`split_brief` in `run/prompts.sh`) says "Use /split-change-into-chunks on
...". In a `claude -p` session that text does not start the skill.

In the workout-tracker run of 2026-10-31 the session said:
"`/split-change-into-chunks` isn't in this session's skill list, so I read and
followed it from `~/Projects/skills/split-change-into-chunks/`". It had
searched for it with `find /` (35 seconds). It worked because the skills
repository happens to be on this machine. Where the session does not find the
file, it splits the change without the skill.

The build sessions do not have this problem: `implement-change` has no
`disable-model-invocation`, and their `Skill` call loads it.

Evidence: `.git/run-logs/split-20261031-013200.jsonl` in
`~/Projects/workout-tracker`.
