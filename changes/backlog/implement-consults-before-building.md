---
effort: S
utility: M
---

# /implement settles what the human approves before it builds

`/implement` fires on any "add", "fix" or "build" and goes straight to
work. Before building it checks only whether the request settles what gets
built (`implement/SKILL.md:16`). A bare request that adds an endpoint other
programs call, changes who may see something, keeps new personal data or
takes on a dependency is built without the human approving any of that.

`MANIFESTO.md`: "The consultation happens before implementation; what it
settles is what gets built", and before implementation a human approves
behaviour, interfaces, security policy, information model and
hard-to-reverse decisions. "Consulted adequately" can be proportionate: a
trivial fix needs no consultation.

The same line says to ask "before or during the build - and do not build
past it". `CLAUDE.md` says "Decisions wait for the pipeline's fixed stops
rather than interrupting a run", and the manifesto treats something found
during implementation as "a decision the plan didn't cover", which waits
for the human in the report.

Which categories the human approves is the subject of
`approval-follows-the-manifesto`.
