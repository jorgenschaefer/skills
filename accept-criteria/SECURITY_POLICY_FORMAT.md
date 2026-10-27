# Security policy format

`SECURITY_POLICY.md` at the project root, beside `UBIQUITOUS_LANGUAGE.md`, says who may see and do what across the whole system, in the developer's words. It is not `SECURITY.md`: GitHub keeps that name for how to report a vulnerability.

It outlives every change. It lists only what is allowed. Whatever it does not allow, the project's policy check fails on.

## Language

Write it in the domain language `UBIQUITOUS_LANGUAGE.md` declares, or the developer's where there is no glossary, and name each thing and role by its glossary term. The developer reads it without the code: no tables, columns, routes or files.

## Rules

One `##` heading per thing, and under it one rule per list item. A rule says who may see or do what with that thing, in one line:

```markdown
## Einsatz

- **R-1** Wachleitung und Streife sehen jeden Einsatz; Streife ohne seinen Namen.
- **R-2** Wachleitung legt einen Einsatz an und schließt ihn.
- **R-3** Das Leitstellensystem legt über die API einen Einsatz an.
```

- **Who** is a role, nobody logged in, or an external system by its name. An external system may call in through a way in, like a role. It may also receive data - "the mail service receives a member's address" - or cause an action through its answer - "the payment provider's answer marks an order as paid".
- **An exception goes inside the rule**, after a semicolon. There are no "never" rules: a reader would have to work out which rule wins.
- **Ids** are `R-n`, numbered in the order rules were added, never reused. A rule that goes is deleted, and its number goes with it, so a new rule takes the number after the highest the file ever held, as its git history shows. A test names the id of the rule it shows; the policy check names the id of the rule each thing it allows comes from.

A rule the developer disagreed with at `/init-security-policy` is **disputed**. It still says what the system does, and ends with the backlog item that would change it:

```markdown
- **R-5** Das Leitstellensystem erhält die Adresse jedes Einsatzes. *Disputed:* `changes/backlog/adresse-nur-fuer-eigene-einsaetze.md`
```

Where the project lets nobody see or do anything a policy would limit, the file holds one line under its title, approved like any rule:

```markdown
- **R-1** Nobody logged in, and every external system, may see and do everything this tool offers: it has no users and keeps nothing about anyone.
```

## What holds it

**Every rule has a test** in the project's tests, showing in one case that what the rule allows works. The test names the rule's id.

**The policy check** is code in the project, and the project's `Check:` command runs it. It finds every way in - a page, an API route, a command, a message from a queue, a file it imports, a scheduled job's input, an external system's answer - from the code rather than from a list kept by hand. It plants marker values in every field of the test data, related records included, and tries every way in as every role, as nobody logged in and as every external system. It drives each way in through the path production uses. It watches every response, every outgoing call and every change to the system's own data. A change counts as an action where a user would call it doing something - creating, changing, deleting, sending - and not where it is bookkeeping every request does, such as a session or a timestamp. It fails:

- where a marker turns up, or an action happens, that no rule allows - including by a route nobody thought of, such as a join;
- where a way in exists that it did not try;
- where a rule has no test or nothing the check allows comes from it, or the check allows something that names no rule;
- where a marker value appears anywhere outside the test data.

## How it changes

Only through rules the developer approved:

- **A change's Security policy ACs.** Each adds, changes or removes one rule: "adds: <the rule as it will stand>", "changes R-1 to: <the rule as it will stand>", "removes R-7: <the rule as it stands today>". The build writes them in, with their tests and what the check allows, in the change's own commits.
- **`/init-security-policy`**, which writes the first version.
- **Acceptance**, where a build added a rule beyond what was agreed and the developer keeps it.

Nothing else edits the file.
