---
name: accept
description: Use the finished feature and say whether it solved the problem - walking the intent's conditions, writing the verdict, and retiring the paper once it is accepted. The last act of a run, and the only one that judges against the problem rather than against the previous artifact.
disable-model-invocation: true
---

# Accept

Everything before this compared an artifact to the artifact before it: tickets to the solution, code to the ticket. Each link is sound and the chain still proves nothing about what started it. This is where that is answered.

`VERDICT_FORMAT.md` settles the shape of the page. This file is what you do.

## Use the thing

**Drive the feature the way its user would**, before you read anything. Not the diff - the diff is what the per-ticket reviews already saw, and a verdict written from it is a fourth opinion on the same evidence.

**Then walk the intent's `Done when`, condition by condition, by id.** For each one: what establishes it? A test that pins it, an observation you made, a number you measured. A condition you cannot establish either way is `unverifiable`, which is not a pass.

**Judge against the conditions as written.** Not against your reading of the problem, not against what the solution set out to do. A verdict that re-derives the problem agrees with the work by construction, because the work is what you have in front of you.

**Read the tickets' `## Record` as claims, not as evidence.** They say a test pins each criterion. The per-ticket review checked that; you are checking something else - that the criteria, all built, add up to the conditions. A feature can pass every ticket and satisfy no condition, and that is the failure this stage exists to catch.

## Route a rejection

"No" is not actionable on its own. Say which part of the chain failed, because each one goes back to a different place:

- **The problem was misframed** - back to `/idea`. The intent is what needs rewriting.
- **The solution does not address the problem** - back to `/solve`. The intent still holds.
- **A criterion nobody claimed went unbuilt** - back to `/slice`. The slicing lost it.
- **The code does not match its ticket** - back to `/implement`, and note it: the per-ticket review should have caught that, so the pipeline has a hole as well as the work.
- **A condition is unverifiable** - back to `/idea`. It was never observable, which is a defect in the intent.

Append the routing to the intent's `## Routed back`, with the date. A list that grows long is the sign that the intent, and not the work, is what needs changing.

## Accepting

**Promote anything durable first.** A note that belongs in the architecture document, a domain term that belongs in the glossary. ADRs were written at plan exit, while the argument for them was still in context; what reaches you is whatever the build turned up afterwards. Deletion is the moment the rest is lost, so it is the moment to ask.

**Commit the verdict and the promotions before you retire anything.** The script refuses a dirty tree, and it is right to: its own commit has to be deletions and nothing else, or the history cannot show what retiring a run actually removed.

**Then retire the paper**: `./accept-run.sh <topic>`. It refuses rather than trusts - in a repository, on a branch of its own and not a detached HEAD, paper that exists, a verdict that says accepted, every ticket done, a clean tree, and nothing inside the paper that git has been told to ignore. Every refusal changes nothing. Do not work around one; it is telling you the run is not finished.

**A topic dropped rather than finished** is `./accept-run.sh --abandon <topic>`, with a verdict that says `abandoned` and why. It waives the every-ticket-done check and nothing else. An intent nobody pursued is information about the intent, and the verdict is the only trace that survives it.

## What you do not do

**You do not merge.** A person reads the verdict and merges: the verdict says the work satisfies the intent, not that a maintainer wants it.

**You do not fix what you find.** A verdict that quietly repairs the thing it is judging has stopped being a judgement.

**You are unchecked.** Nothing reviews this stage, which is why it judges against something written before the work existed rather than against anything you could talk yourself into. The customer is the only adversary you have.
