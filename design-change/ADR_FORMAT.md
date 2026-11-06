# ADR format

`docs/adr/NNNN-<slug>.md`, one file per decision that would be hard to undo.
Numbers have four digits, go up by one from the highest that exists, and are
never reused. The slug states the decision, such as
`0003-reminder-emails-go-to-members.md`.

A decision gets a file only if it would be costly to undo and the code does
not show it.

Unlike classic ADRs, a replaced decision is deleted, not marked superseded.
The folder shows only what binds today. Git history keeps the rest, and the
new decision names the number it replaces. Do not add a status field.

```markdown
# <N>. <The decision, as a statement>

Why: <the reason>
Cost to undo: <what cannot be taken back>
Decided: <YYYY-MM-DD>, by <who>
Replaces: <number, or none>
```
