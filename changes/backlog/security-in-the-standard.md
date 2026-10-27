---
effort: L
utility: XL
---

# The developer can vouch for who may see and do what

## The problem, agreed with `/idea` on 2026-10-27

The developer approves who may see and do what one change at a time.
Acceptance then deletes what they approved, so the whole policy is never
written down anywhere they can look. To know who can see a piece of data,
they rely on their memory or ask an agent. In dom, they asked who can see
the name of an Einsatz created through the API, which can hold an internal
number or patient information. The agent answered that everyone logged in
can see it, Wachleitung and Streife alike, and nobody else. The answer was
right, but the developer knew that only from memory. Memory fades as agents
build more, and an agent tracing routes can miss one that exposes the data
another way, for example through a join. Instead, the developer should be
able to see, in their own words, who may see and do what across the whole
system, including rules nobody ever decided that the code simply follows.
And they should know this is what the system does, because something shows
that the system holds to it, not because an agent or their memory says so.

## Evidence

- Acceptance deletes the change's directory, `CRITERIA.md` and its Security
  policy group included (`accept-criteria/SKILL.md`, "Once the user
  accepts").
- `find-criteria/SKILL.md:35` asks who may see and do what without first
  showing what the change exposes, so "None." can be a guess.
- No skill treats a security AC differently from a behaviour AC: the build
  implements it, and at acceptance the agent says what it did and what it
  saw.
- `CODING_STANDARDS.md`'s Security section (`implement/CODING_STANDARDS.md:75`,
  five identical copies) covers object-level authorization, input never
  becoming code, never turning a check off, and secrets. The manifesto asks
  the writer for more: "Every way in goes through security checks an agent
  finds easily, access is denied unless a check allows it". It asks the
  checkers to "attempt what is forbidden, and fail when a way in bypasses
  the checks". The standard asks for neither.

## Related

- `approved-criteria-outlive-the-change` keeps one change's approval and
  its tests alive after acceptance.
- `acceptance-evidence-from-a-script`: security ACs shown with executed
  evidence.
- Rule 3 of `cut-files-by-concept`: access checks and untrusted input in
  files of their own, enforced by an import check.
- `security-beyond-access`: the outside attacker, an agent steered by text
  it read, and the secure path being the easy one, parked from this item.
