---
name: decision-brief
description: Use when someone must decide whether to build a plan as-is or iterate on it first – turns a proposed approach (a /discovery spec, plan, or PRD) into a one-page decision brief surfacing the decisions a reviewer might veto. Fires on /decision-brief or a request for a decision brief, one-pager, or Entscheidungsvorlage from a plan.
---

# Decision Brief

A decision brief compresses a proposed approach into one page a reviewer can act on: ratify the plan and build, or send it back to iterate. The intent behind the plan is already settled – the brief tests the plan, not the why.

## The reviewer decides, not the brief

The goal the plan serves lives in the reviewer's head, not on the page. So the brief never recommends ratify or iterate: it surfaces the decisions and hands the verdict to the reviewer, who alone holds the goal to judge against. Neutrality here is structural, not willpower – there is nothing to advocate, because the one choice that matters isn't yours to make. The strongest opinion the brief carries is a ranking: which decisions matter most.

## Surface decisions, not defects

This is a decision aid, not a review. A flaw – a self-contradiction, a step that can't deliver what the plan claims – reaches the page only when it rises to a decision the reviewer would want to weigh in on, and then it earns its place as a stake like any other. Leave the rest; a review skill hunts defects, this one hunts decisions.

## Input

Read the source as prose describing a proposed approach – a `/discovery` spec, plan-mode plan, `/propose-change` doc, or PRD – and assume no section structure, so the brief holds up whatever shape the source takes.

## What earns a place: the veto test

A plan makes hundreds of choices; the brief carries only those a reasonable reviewer might want to veto before building. A choice earns its place when it is at least one of:

- **Consequential** – it materially changes whether or how the outcome is reached.
- **Contentious** – a reasonable reviewer might have chosen differently.
- **Load-bearing** – the plan quietly assumes its way past it, and if the assumption is wrong the plan doesn't deliver.
- **Expensive to reverse** – cheap to get wrong now, costly to unwind after building.

Everything else stays off the page: implementation detail, choices with an obvious right answer, anything cheap to change later.

Sweep the whole plan, not its headline choices – every consequential decision ends up either on the page or consciously dropped for failing this test. The brief's value is the decision you surface that the reader would have skimmed past, so dig for the ones no section announces: an assumption stated as fact, a scope line that quietly excludes something, a sequence that commits the build before a risk is tested.

## De-spin every item

The plan is advocacy, so each choice arrives pre-spun ("chose A for its flexibility"). Restate each as a two-sided tradeoff: what it commits to – a chosen option over its alternative, or an assumption relied on rather than verified – what it gains, and what it gives up (for an assumption, what breaks if it's wrong). An item that names only the gain is the pitch in fewer words – find the cost it's paying and name that too.

## The page

```
WHAT THIS PLAN PROPOSES
  One neutral sentence: what the plan sets out to build.

THE DECISIONS                (ranked by stakes, highest first)
  - Chose X over Y – gains ... – gives up ...                [where in the source]
  - Assumes Z; if wrong, the plan doesn't deliver: ...       [where in the source]
  - ...
```

One ranked list, not two: a load-bearing assumption is a decision the plan made by default, so it takes its place among the rest, ranked by stakes. Ranking is what holds it to one page: the reviewer reads top-down and stops when the rest is clearly ratifiable, so the item most likely to trigger iteration sits first. Source pointers are the drill-down, not a second document – cite where each decision lives in the plan so a skeptical reviewer can verify it without reading the long version.

## Deliver

Present the brief inline. If the source is a file, also write the brief to a markdown file beside it – propose a path and confirm – so the reviewer can forward it to whoever makes the call.
