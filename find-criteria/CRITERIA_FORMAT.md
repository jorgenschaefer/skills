# Criteria format

`changes/YYYY-MM-DD-<slug>/CRITERIA.md`. The runner reads the criteria and nudges mechanically, so their shape below is not decoration: an AC is a list item starting `- **AC-n**`, a nudge a plain list item under `## Nudges`.

```markdown
# Criteria: <the change, in a few words>

## Problem
<The agreed problem statement: what is wrong, what would be true instead, with no mechanism in it. Then the one real instance - the last time it happened, what it cost - pointing at something a reader could go and look at. Where there is none, say so.

Written before the approach was chosen, and what acceptance judges the finished thing against.>

## Acceptance criteria
- **AC-1** <One observable behaviour, checkable true or false by someone holding it against the finished thing months from now.>
- **AC-2** <...>

<Hard: acceptance checks every one. What must stay as it is ("the phone layout is unchanged") is an AC too, and so is an edge case that matters.

The numbers are the contract with everything downstream: tickets quote them word for word, and acceptance walks them by id. They are never renumbered and never reused. An AC that no longer holds is deleted, and its number goes with it.>

## Agreed design
<The chosen approach in a few lines. Where a specimen was built, link it - the published Artifact and the copy in `specimens/` beside this file - with:

**Agreed; build to this, do not redesign.**>

## Nudges
- <One piece of implementation guidance: "reuse the phone components in the sidebar", "do not touch DeviceView".>

<Soft: nothing checks the build against them, but a build that departs from one records the departure and why. Tickets quote them word for word. Omit the section when there are none.>

## Out of scope
- <One thing this change deliberately does not do, so a builder does not wander into it and a reviewer does not file its absence as a defect. Omit the section when there is nothing.>

## Ruled out
- **<The alternative>** - <why it lost, in a line, so no later agent proposes it again.>
```

## What this format is not

**It is not a plan.** It says what the finished thing does and how it was agreed to be built, not what order to build it in. The slicing reads this and decides that.

**It is not permanent.** It is deleted with the rest of the change's directory once the change is accepted. A decision that has to outlive the change is an ADR, in `docs/adr/`.
