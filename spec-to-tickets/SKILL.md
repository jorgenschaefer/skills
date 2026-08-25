---
name: spec-to-tickets
description: Decompose a settled /discovery spec into the tickets an unattended /implement loop consumes. --refresh re-derives the unbuilt ones after a drift halt.
disable-model-invocation: true
---

# Spec to Tickets

Turn a settled `/discovery` spec into the `tickets/` an unattended `/implement` loop can build without asking anyone anything.

That last clause is the job. Once the loop starts there is nobody to ask, so every question the work forces has to be answered before it does - and the questions that are yours are a narrow band. Discovery settled what the system does. You settle only what *splitting the work* forces: where the seams fall, what each ticket may rely on from the ones before it, and in what order they can be built.

If a question would matter even for a feature built as a single ticket, it belonged in discovery. Send it back rather than answering it here.

**Expect to ask nothing.** A small feature with a clean spec decomposes without a single question. If you always find questions, your boundary with discovery is wrong and you are re-deciding what is already settled.

## Before starting

- The input is a path to the spec. If the user didn't supply one, ask where it lives before doing anything else.
- Read the spec whole, then read the codebase for the structures it names - what exists now, under what names, with what shape. Every contract you write is a claim about code, so it has to be a claim you checked.
- Read the `coding-conventions` skill. Seams you place and contracts you declare are design decisions, and that is the standard they are held to.
- Read `TICKET_FORMAT.md`. It is the output shape and it settles most of what would otherwise be judgement.
- Read `SPEC_FORMAT.md`. You write one mark back into the spec - see *Promote the binding defaults* - and it says where and in what form.

## Audit the scope before decomposing

You are the first reader of this spec who wasn't in the room while it grew. Discovery defends the scope ceiling during the conversation and has the same blind spot the user does about what accumulated - so the cold read is yours, and it comes before any decomposition work.

State what the spec delivers as a release note: one line a user would care about, no bullets, no "and". Then try to break it - **could you ship half of this, and would that half still be worth shipping?**

- **Half is independently worth shipping** - the spec describes more than one feature. Stop. Send it back to `/discovery` to be split into separate specs, and say which halves you found.
- **Nothing smaller is worth shipping** - it is one feature. Continue.
- **Nothing about it is observable outside the code** - this is maintenance, not a feature. Stop, and send it back to `/discovery`, where it becomes a maintenance ticket.

Stop too if the spec isn't settled: criteria missing, decisions left open, an open-questions section surviving. Those are discovery's to close, and inventing the gaps here buries them in tickets nobody will re-read.

One exception you flag rather than refuse: a spec that passes the split test but is plainly large. It is one feature, so splitting it produces halves that aren't independently shippable - that is the user's call, not a refusal. Say what you found, offer the choice between a long run with a big final review and two runs that don't stand alone, and take the answer.

## Decompose

A ticket is one `/implement` run: one agent, one context window, no questions. Size to that, and remember the run also spends context on two reviews and their bounded fix rounds - so a ticket that would exactly fill a window is already too big.

Split along the dependencies the spec mapped, and hold to four rules:

- **Every ticket is a verb phrase about observable behavior.** "Let a reviewer reject an application", never "add the rejection service". A ticket you can't name that way is a horizontal slice, and horizontal slices invite interfaces nothing calls - the failure an unattended run is least equipped to notice. Allow one only where a real dependency forces it.
- **Every criterion is claimed by exactly one ticket.** Stories may split across tickets; criteria may not, since a criterion is the smallest unit a test pins. Check the coverage both ways before writing anything: no criterion orphaned, none claimed twice. Constraints (`C-N`) are claimed by *at least* one ticket rather than exactly one - a seam's retry behaviour or an idempotency rule can be a property several tickets must each hold - but a constraint claimed by none is one nothing will ever verify.
- **A constraint that quantifies over a set is claimable only once the set is enumerated.** "Every endpoint enforces the rate limit", "all money fields round the same way" - until somebody lists that class's members against the real code, claiming it is a claim about nothing. Enumerate it from the code, write the enumeration down, and then either assign every member to a ticket or give one ticket the whole class with the list in it. What the previous rule allows is a constraint several tickets each hold in their own work; this forbids one they each claim in general terms, which is a constraint every ticket assumed another was holding and which comes back after the run as remediation tickets.
- **Order so a halt is cheap.** The loop stops at the first ticket that blocks, drifts, or goes mysterious. Put the tickets carrying the most uncertainty early, where the halt costs one ticket instead of ten, and where what you learn can still change the rest.

## Declare contracts

Each ticket names what it `Touches` - existing structure it changes - and what it `Provides` - what later tickets may rely on. `Provides` is the only part a later ticket can be wrong about, so it is the surface drift happens on.

**Keep that surface small.** Declare a contract only where a later ticket actually consumes it. Every entry is a promise made before the code exists, and each one is a way for ticket 9 to be built against something ticket 4 stopped doing.

**Describe by durable intent, never by signature.** "The `Reservation` aggregate gains a confirmation path that rejects double-booking", not `confirm(id: string): Promise<Result>`. A signature written here is a guess - wrong in detail, right in substance - and pinning the detail manufactures drift out of decisions that were never load-bearing. Pin the substance and let the implementer choose the shape.

## Settle what splitting forces

Sort every decision the decomposition raises into one of three buckets - the same mechanic discovery uses, one altitude down:

- **The codebase answers it.** Resolve it silently. Always look before asking.
- **A wrong default would hurt, but there's a defensible best answer** - where a seam sits, which existing structure a ticket extends rather than replaces, whether two tickets share an abstraction or each keep their own. Decide it, then surface it for a veto: the decision, your recommendation, the alternative you rejected.
- **A wrong default would hurt and the answer isn't yours** - almost nothing lands here, because product decisions belong to discovery. When one does, it usually means the spec has a gap. Check whether it should go back rather than be answered here.

**Promote the binding defaults.** Discovery marked its defaults as overturnable on evidence found in the code, which is safe exactly while one ticket owns the decision. The moment two do it is false: ticket 4 overturns the default on what it can see, ticket 9 was built on the original, and neither is wrong on its own evidence.

So go through every `D-n` in the spec - those collected under `## Defaults` and those marked in place beside a decision, the duplication survey's module verdicts included, which are the ones your seams are most likely to share - and add `(binding)` to each one that more than one ticket has to hold to. Mark it where it already stands; a verdict moved away from the decision it qualifies stops meaning anything.

Nowhere else, and never in a `Provides`: a date format or a naming convention is not something ticket 9 consumes from ticket 4, and putting it there manufactures a `drift` halt out of a convention.

**End your turn at the first question mark.** The moment a turn reaches a question that seeks new information, send it - a second question or "and also" waits for the next turn. This is a rule about output shape, not a preference: one turn, one open question, so the user never has to label which part of their reply answers which question. Confirming assumptions for veto ("I'm assuming X unless you say otherwise") is not an originating question, but it gets its own turn, never mixed with a question.

## Write the tickets

Write `tickets/NN-slug.md` beside the spec, in the shape `TICKET_FORMAT.md` specifies, numbered in dependency order. Mark the binding defaults before you hash, never after: the hash has to cover the spec as marked, or every ticket freezes a version that does not say what binds it.

Stamp each with `spec_hash` - the first 12 characters of `sha256sum` over the spec file - which freezes the spec for the run: tickets cite criteria rather than copying them, so an edit mid-run would silently change what the unbuilt tickets mean.

Fill `Out of scope` with real restraint, not a formality. No human sees the diff between one ticket and the next, so name what an implementer would plausibly reach for and must not: the adjacent case a later ticket owns, the abstraction premature until a third caller exists, the deferred story this ticket sits next to.

## Review the tickets

Dispatch a fresh `general-purpose` subagent over the written tickets, with `run_in_background: false` so it blocks - a detached reviewer hands back an `agentId` and nothing else, and there is no useful work to do while it reads. It takes a falsification stance: assume the set is unbuildable and try to prove it. Never a confirmation pass.

Give it the tickets, the spec, and the codebase, and this framing: *you are about to build these tickets one at a time, with no human available, no access to the conversation that produced them, and nothing to read but the ticket, the spec, and the code. For each ticket, find the first thing you would have to guess.* Anything it has to guess is a question this skill failed to settle.

Have it check five more things:

- every spec criterion claimed by exactly one ticket, and every constraint by at least one;
- every constraint quantifying over a set enumerated against the code, with every member assigned or the class owned outright;
- every `D-n` whose subject more than one ticket touches marked `(binding)`;
- every `Provides` entry actually consumed by a later ticket, and every `Preconditions` entry actually provided by an earlier one;
- every ticket nameable as observable behavior.

Treat the verdict as a claim to verify: a clean result counts only when the report shows the review happened - the guesses it hunted for and where it looked, cited to specific tickets. Fix what it finds and re-dispatch once. Two rounds is the ceiling: a ticket set still leaving things to guess after a second pass has a problem the decomposition can't fix by iterating, so stop and take the standing findings to the user with the hand-off below.

## Hand off

This is the last point at which a human can cheaply stop hours of wrong work - everything after it is expensive to unwind - so close by surfacing what a reader would otherwise skim past.

Present it inline and leave it there. It is read once, by someone deciding, and a hand-off written to a file is one that outlives the decision it was for.

Do not summarise the tickets; a table of contents tells a reviewer nothing they can veto. Surface what *you* decided: which existing modules change and how, which contracts were declared and what they commit later tickets to, which calls you made under a veto and which you defaulted in silence, where a load-bearing assumption is stated as though it were fact, and where the decomposition is most likely to be wrong.

Rank by stakes, and state each as the tradeoff it was - what it commits to, what that buys, what it gives up. A decision that arrives with only its upside named is one the reader can agree with but not judge, and a flat unranked list is one nobody reads to the end.

Only what you decided. The spec's own decisions were ratified as discovery made them, and re-raising them here spends the reader's attention on choices they have already settled - which is how the item that actually needed a veto gets skimmed past.

## Refresh

`/spec-to-tickets --refresh` re-derives the unbuilt tickets after the loop halts on `drift` or `stale-spec`. The premise is that reality moved: either the code an unbuilt ticket assumed, or the spec every ticket cites.

- Leave `done` tickets untouched. They are a record of work that happened, and their `Record` sections feed the handover.
- Re-derive every `todo` and `blocked` ticket against the codebase as it actually is now - read the code, not the prose of the tickets you are replacing, which is the drifted material. Renumber nothing; ids are referenced by `depends_on` and by commit messages.
- Re-check which defaults are binding before re-stamping. A refresh moves seams, so a default one ticket owned may now be shared. Adding `(binding)` is not patching a spec decision - it records which tickets depend on one - and it goes in before the hash, as it did the first time.
- Re-stamp `spec_hash` on everything you rewrite.
- Run the review again. A refresh is where contracts quietly stop matching, so the pass that hunts for guesses matters more here than on the first run, not less.

If a completed ticket turns out to contradict a decision the spec states - the spec was wrong, not merely unbound - stop and send the user back to `/discovery`. Never patch a spec decision from here.
