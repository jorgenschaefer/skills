# Criteria format

`changes/YYYY-MM-DD-<slug>/CRITERIA.md`. The runner reads the criteria and technical decisions mechanically, so their shape below is not decoration: an AC is a list item starting `- **AC-n**`, and a technical decision a list item under `## Technical decisions`.

```markdown
# Criteria: <the change, in a few words>

## Problem
<The agreed problem statement: what is wrong, what would be true instead, with no mechanism in it. Then the one real instance - the last time it happened, what it cost - pointing at something a reader could go and look at. Where there is none, say so.

Written before the approach was chosen, and what acceptance judges the finished thing against.>

## Acceptance criteria
### Behaviour
- **AC-1** <One observable behaviour, checkable true or false by someone holding it against the finished thing months from now.>
- **AC-2** <What the user experiences when that behaviour fails: "when the other member has declined, the first sees 'declined' and the shift stays theirs".>

### What production must show
- **AC-3** <What someone has to hear about, and how fast: "ten failed logins in a minute alert the admin within five minutes".>

### Security policy
- **AC-4** <One rule of the security policy the change adds, changes or removes: "adds: a member sees their own contact details; the admin sees every member's", "changes R-3 to: ...", "removes R-7: nobody logged in sees a shift's start time".>

### Information model
None.

<All four groups, in this order, in every file. Each holds ACs or the plain line `None.`, and "None." is an answer: if a group says "None." and the build adds a permission, an alert or something kept there, the build has departed from what was approved. These are the decisions the developer answers for, put in words they can judge without the code. A detail of the code - a table, a column, a file, a module - is never an AC.

- **Behaviour** - what the user can do and sees, failure cases included: each behaviour has an AC for what the user experiences when it fails.
- **What production must show** - errors, but also a sudden drop in users or a flood of login attempts: who hears about it, and how fast.
- **Security policy** - who may see and do what, as rules added to the project's `SECURITY_POLICY.md`, changed in it or removed from it, in `SECURITY_POLICY_FORMAT.md`'s shape. Only allowing rules: an exception goes inside the rule, never as a "never" rule of its own.
- **Information model** - what the system keeps, logs and traces included, for how long, and what it never keeps.

Hard: acceptance checks every one. What must stay as it is ("the phone layout is unchanged") is an AC too, and so is an edge case that matters.

The numbers are the contract with everything downstream: tickets quote them word for word, and acceptance walks them by id. They are never renumbered and never reused. An AC that no longer holds is deleted, and its number goes with it.>

## Agreed design
<The chosen approach in a few lines. Where a specimen was built, link it - the published Artifact and the copy in `specimens/` beside this file - with:

**Agreed; build to this, do not redesign.**>

## Technical decisions
- **Concepts** <The things the change adds to or changes in what the system keeps, and how they relate, in the glossary's words: "a swap request belongs to one shift and to two members". A new concept gets its term here, agreed with the developer. Not tables, columns or files - or "none".>
- **Wire formats** <The endpoints, payloads, events, flags, config keys, environment variables and exit codes something outside this change depends on, and what an old caller sees - or "none".>
- **Hard to reverse** <A change that discards information - data deleted, a field dropped, history merged - and a dependency the codebase will be built around, each with what it gives and what it costs - or "none".>

<Approved like the ACs: these are the developer's decisions that are not behaviour, and a mistake in one costs more than a rebuild. All three are always present, and "none" is an answer - if a decision says "none" and the build adds a concept or an endpoint, or deletes data, the build has departed from what was approved. A build may go beyond one where the code calls for it and records the departure; acceptance shows it for approval. How the code holds a concept - its tables, columns, files and modules - is the builder's. Tickets quote them word for word.>

## Out of scope
- <One thing this change deliberately does not do, so a builder does not wander into it and a reviewer does not file its absence as a defect. Omit the section when there is nothing.>

## Ruled out
- **<The alternative>** - <why it lost, in a line, so no later agent proposes it again.>

## Left standing
<Written by `/implement` when it builds this file directly, with no tickets: what it says to leave standing. Read by the user before deleting the change's directory. Absent when the change is built from tickets, which carry their own.>
```

## What this format is not

**It is not a plan.** It says what the finished thing does and how it was agreed to be built, not what order to build it in.

**It is not permanent.** It is deleted with the rest of the change's directory once the change is accepted. A decision that has to outlive the change is an ADR, in `docs/adr/`.
