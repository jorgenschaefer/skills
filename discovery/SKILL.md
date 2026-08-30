---
name: discovery
description: Use when a change to this codebase is being worked out with the user - fired explicitly via /discovery, or whenever a feature, a bug or a passing idea needs developing into something an implementer can build from. The one way in.
---

# Discovery

Find the problem beneath what was asked for, choose the solution that best fits the project it lands in, settle the experience with the user, and write it down thoroughly enough that an implementer could build it from what you wrote plus the codebase, without asking the user anything.

Thoroughness is a property of what you write, not of the conversation: scale the interview to the change. A small one may warrant two questions and a half-page; a large one, many. The bar is that every decision a wrong default could hurt is settled - not a fixed question count.

## Where this ends

You are the one door into the pipeline, and three things come out of it:

- **A spec.** The default, and what most of this is written for: a change big enough that `/spec-to-tickets` decomposes it into tickets an unattended loop builds.
- **One ticket.** The change is a single observable thing - a bugfix, a small behaviour change - and a spec for it would be ceremony. It goes to `tickets/` where the specs live, in the shape `TICKET_FORMAT.md` specifies: no `spec` or `spec_hash`, criteria written out in full rather than cited, and a leading `## Why`. `/implement` builds it with the user still present.
- **A reasoned no.** The idea does not survive the interview. See *The no is a finding*, in phase 1.

Which of the three it is comes out of phase 1 and is never a question you open with. The split test below tells a feature from a change.

Work nobody outside the code could observe - a refactor, a consolidation, a dependency upgrade, a rename that reaches every caller - is none of the three. There is almost nothing to discover, so it takes almost no interview: it becomes a **maintenance ticket**, in the shape `TICKET_FORMAT.md` gives that kind. Say what is wrong with the code now, what should be true after, and what is out of scope, and let it go through the same build and the same reviews as everything else. Done by hand instead, it is the change least likely to be checked and the one whose mistakes are hardest to find.

## One feature

A spec describes **one** feature: a single change someone outside the code can observe, substantial enough to be worth shipping on its own. Not three changes. Not polish nobody would notice.

Nothing downstream will save you from getting this wrong. There is no slicing step any more - `/spec-to-tickets` decomposes the spec into tickets and an unattended loop builds all of them, so an oversized spec becomes a long run whose result nobody can review in one sitting. `/spec-to-tickets` re-applies this test cold and will send an oversized spec back, but that costs a whole discovery cycle. Hold the line here instead.

State what the feature delivers as a release note: one line a user would care about, no bullets, no "and". Then try to break it - **could you ship half of this, and would that half still be worth shipping?** If yes, it is two features, and the honest move is to pick one.

This is a move you make continuously, not a check at the end. Scope grows a sentence at a time, and every "while we're at it" gets the split test on the spot - **could you ship it on its own, and would that be worth shipping as an improvement in itself?**

- **It passes** - park it. Append it to `IDEAS.md` where the specs live, with enough context to resurrect: the problem it solves, why it was deferred, what it would touch. Then return to the change at hand. Parking is not refusing, and saying so keeps it from feeling like one.
- **It doesn't stand alone** - it belongs in this feature. Absorb it.

**Then say what comes after the feature.** The spec's `## Now and later` holds the smallest slice worth shipping and the part deliberately held back. The split test catches a second feature hiding inside this one; this catches one feature specified well past the point it should have shipped at. Later is not a non-goal - a non-goal is out of scope for good, later is scope you are choosing not to build yet.

One case you flag rather than split: a feature that passes the split test and is still plainly large. Splitting it would produce halves that aren't independently shippable, and that tradeoff is the user's to make. Say what you see and offer the choice - one long run with a big review at the end, or two runs where the first doesn't stand on its own.

## The shape

Four phases, in order, and each one's exit condition is the next one's ground:

1. **The problem** - what is actually wrong, agreed in the user's words before any solution is discussed. Ends by naming which of the endings above this is heading for.
2. **The solution** - candidates weighed against the project as it already is, and one chosen.
3. **The experience** - how the chosen solution is met: journeys, interface, criteria.
4. **The record** - the spec or the ticket, hardened into something buildable without you.

Both lanes run 1, 2 and 4. **Phase 3 belongs to the spec lane alone, and phase 2 on the small lane is four questions rather than a survey** - a bugfix that acquires a domain-model turn and a mockup walk has cost more to specify than it would have cost to fix. Where a phase says *small lane*, that paragraph is the whole of that phase for it.

The order is load-bearing, not decorative. A solution discussed before the problem is agreed gets discussed twice, and an interface drawn before the solution is chosen is a drawing of the wrong thing.

## Phase 1 - The problem

**Read before you ask.** Skim the codebase for what the change will sit next to: terminology, conventions, and adjacent features it must integrate with. For UI, note the existing design language - component library, design tokens, spacing and type scale, styling conventions - so new screens stay consistent. If `UBIQUITOUS_LANGUAGE.md` exists, read it and reuse its terms. If `ARCHITECTURE.md` exists, read it as a lead rather than as truth - it is only as current as the last `/repo-overview` run, and the code settles anything the two disagree on. The code answers "what exists"; the user answers "what's new".

Read `IDEAS.md` too, if one exists where the specs live. It holds what earlier features parked, and something in it may belong in this one. Raise what fits - a parking lot nobody revisits is just a slower way of forgetting.

Then open by reflecting the request back. Users arrive with a solution far more often than with a problem, and the solution they bring is evidence about the problem rather than a description of it.

**Dig until you have the instance.** A problem stated in general - it's slow, people get confused, we need a way to do X - is not yet something a solution can be weighed against. Get to:

- what happens today, step by step, in the situation that goes wrong;
- what the user does instead - the workaround they have already built;
- how often it bites, and what it costs when it does;
- one concrete recent time it happened.

The last is the one to insist on. A problem with no instance behind it is a preference, and the two are worth very different amounts of work. Where there genuinely is no instance yet - a feature for users who do not exist yet - say that is what you have, because it changes how much everything after this should cost.

**For a bug, the excavation is the diagnosis.** The *why* is already settled, so what this phase owes is the two things a fix is judged against and the cause underneath them: what happens now, what should happen, and a case that reproduces it. A fix that clamps a bad value or swallows an error leaves the defect live and hides it. Where the cause will not yield to inspection there is no ticket yet - an unattended session cannot diagnose either, so an undiagnosed bug becomes a `mystery` halt rather than a fix. Diagnose it here, with the user, or say that is what the next session is for.

**Then state the problem back and get agreement to it, before any solution is discussed.** One paragraph, in the user's own words, saying what is wrong and what would be true instead. This is the phase's exit condition, and the cheapest correction available: everything after it is built on the reading of the problem you agree to here.

### The no is a finding

A reasoned no is one of the three endings, and its grounds are all claims about the problem - so none of them is reachable without having gone looking:

- **Already solved.** You found the thing in the codebase that does it, or the path the user did not know was there. Name it.
- **Cost out of proportion.** The instance is rare or cheap, and what solving it would cost to build and to carry is not. Say both sides of that.
- **A symptom of something else.** The stated problem goes away if a different one is fixed, and you can say which.
- **Worth doing, but not the way it was asked for.** Not a no to the problem - a no to the solution, and phase 2 is where it gets answered rather than here.

Say it with the reasoning and name what you would do instead. A no you cannot put behind one of these is not a no, it is a reluctance.

### Name the lane

Phase 1 ends by saying which ending this is heading for: a spec, one ticket, a maintenance ticket, or a no. It cannot be known before the problem is understood, which is exactly why it is never a question you open with - and the split test above is what tells the first from the second.

## Phase 2 - The solution

Two or three candidates, one of them whatever the user arrived with. For each: what it does, what it costs to build and to carry afterwards, and - the part that decides it - which existing concept it extends, or what new one it introduces.

**The bar is asymmetric, and stating it is the point.** A solution that fits the project's existing concepts and architecture wins ties and near-ties. A diverging one has to be *much* better, not merely better, because divergence is paid for twice: once building it, and again by everyone who afterwards reads a codebase with two ways of doing one thing in it. "It fits what is already here" is a real argument, not a failure of imagination.

**Recommend one, and say why the others lose.** Where the user's candidate is not the one you recommend, say so plainly, with your reasoning - once. Push back on reasoning that is weak, circular, or contradicted by the codebase. If they reaffirm after hearing it, that is their call: build it, and record in the spec that it was theirs, so nothing downstream reopens a settled argument.

**A diverging winner is an ADR proposal.** It is exactly the structural choice a later reader would otherwise undo without ever learning what it cost. Propose it - the decision, your recommendation, the alternatives while they are still live - and never write one autonomously. *Records that outlive the feature*, in phase 4, says what that commits the project to.

**Small lane:** the same judgement, four questions rather than a survey.

- **Trace the blast radius.** What else calls this, depends on it, or shares the behaviour being changed. A one-line change with four callers is not a one-line change.
- **Find the mechanism that already exists.** Extend the pattern the codebase already uses in preference to introducing one beside it. This is the fit bar at one ticket's scale.
- **Weigh it.** Benefit against what it costs to build *and* to carry afterwards, and against what it complicates for the common case.
- **Four honest verdicts, not two:** worth it; worth it done differently; not worth it now; not worth it at all.

### Model the domain

Behind every candidate is a domain, and how each one carves it up is usually what separates them. Modelling it finds the decisions no story names and keeps the vocabulary honest. As you weigh the candidates, identify:

- **Bounded Contexts:** areas where the same name carries a different meaning. Most changes live inside one; note it only when the change crosses a boundary or establishes a new one.
- **Actors:** who performs actions - these become the roles in your user stories.
- **Work Objects:** what actors act upon, usually nouns.
  - **Entities:** work objects with a distinct identity that persists through state changes.
  - **Aggregates:** groups of entities treated as one unit, with a root and a boundary; outside entities reference only the root, which enforces its invariants. Where the boundary sits is a real decision - it dictates what can change together and what must stay consistent, and it is often the thing that makes one candidate fit and another not.
- **Actions:** what actors do to work objects, usually verbs.
- **Domain Events:** occurrences that matter to the business, especially ones with downstream consequences.

Trace each thing the user will do as a domain story - "this actor does this action on this work object, which raises this event" - and the missing steps announce themselves: an action with no actor, a work object nobody creates, an event nothing reacts to. The domain story is the analysis; the user story in phase 3 is what you record.

**Then show the model back, in a turn of its own** - once the solution is chosen, and before phase 3 hardens anything on top of it: the domain stories you traced, and per aggregate what changes together and the invariant its root holds. In the user's language - whether something is an entity or a value object is your problem, not theirs, and a turn spent on that vocabulary is a turn they cannot correct you in.

Foreground what they can veto, because a model presented as a finished picture gets nodded at:

- these two are one thing - or they are two, and you have merged them;
- this may lag that, so they need not change together;
- that is not what we call it here;
- you have missed an actor, or named an event nothing reacts to.

This is the cheapest correction in the pipeline; every ticket after it is built on what they agree to here.

### Survey what already exists

Go module by module through what the chosen solution needs, and find what the codebase already has that resembles it. For each, a verdict and the reason: **reuse** it as it stands, **extend** it, **absorb** it into what this builds, **replace** it, or deliberately **sit beside** it.

This is the fit bar made concrete. A solution that mostly reuses and extends is the one that fits; a survey coming back full of `replace` is telling you the candidate diverges more than it looked like it did, and that is worth saying out loud before the choice hardens.

Bounded to what this change touches - this is not an audit of the repository.

Every verdict is recorded in the spec's `## Implementation decisions`, the reuse and sit-beside ones included. A verdict left unwritten reads later as a module nobody looked at, and `/check-against-spec`'s orphan sweep files a ticket to delete what you deliberately kept. Each verdict you reached with the codebase actually open in front of you is a **default**, marked as one with what in the code would overturn it.

An `absorb` or `replace` that no criterion requires is scope rather than survey: park it in `IDEAS.md`. One a criterion does require is a hard-to-reverse structural choice, so it gets an ADR and its own yes.

### Record what lost

The candidates you rejected and why go in the spec's `## Solution`, beside the one chosen and what it extends. An idea rejected for good reasons and written down nowhere gets rediscovered and argued from scratch - by the implementer, by a reviewer, by the user in three weeks. This matters most where the idea that lost was the user's own, because that is the one everything downstream will drift back toward helpfully.

## Phase 3 - The experience

The spec lane's alone: how the chosen solution is met, end to end.

### Journeys

Identify the journeys - the paths a user takes through the feature from end to end - and the tasks that compose each. The journey is what you write down, in the spec's `## Journeys`: its trigger, its steps in sequence, the domain effect each step has, and the screens it walks through. Say where the last step puts the user down - the screen or the state they are left looking at. A journey that ends "and it is saved" has skipped the part where anyone finds out it worked.

**Then show the journeys back, in a turn of its own** - before anything is sketched or drawn on them. The screens are the walk's question and it asks better than prose can, so spend this turn on what a walk cannot ask: the trigger, what each step changes, and where the last one puts the user down.

Foreground what they can veto, because a path presented as a finished sequence gets nodded at:

- it does not start there - wrong occasion, or wrong actor;
- that step does not change that;
- those two are one step, or one of them is two;
- the last step leaves them somewhere they would not stop.

Every story below decomposes from these, and the finished feature is checked by driving them. So this is the correction to make before the walk is built on it, rather than at `### Write it` when it already has been.

### Show, don't tell

**Options first, at the shape level.** Sketch two or three genuinely different ways the feature could be met - inline against modal against its own screen, wizard against single form, a new command against a flag on one that exists - and have the user pick. Cheap sketches, because what is being chosen is the shape and not the pixels. Two options that differ only in wording are not a choice: where you can only construct one honest candidate, say so rather than manufacturing a second.

**Then the walk of the one they picked.** Build the journey, not the decision: a throwaway HTML mockup of the walk - screen one through screen five, in the order the user meets them - with the `frontend-design` skill, so they react to something real rather than picture it from prose. A layout judged on its own gets judged again the moment someone sees where it sits in the flow, and the questions that matter most - what is missing here, why am I back on this screen - are only askable of a walk.

**Keep the walk, delete the sketches.** The option sketches did their job the moment the user pointed at one. The walk of the chosen journey goes to `mockups/` beside the spec, and `## Design` links it, so the implementer builds against what was agreed rather than against a paragraph describing it. It is paper like the spec: `./accept.sh` deletes it with everything else when the run is accepted, and git history keeps it. A mockup that outlives the run is a second source of truth that nobody updates.

**Reuse before invent.** Prefer an existing component over a new one, an existing pattern over a new arrangement. Introduce something new only when nothing existing fits, and keep it consistent with the design language. Greenfield, there is no language yet - establishing it (tokens, type scale, spacing, core interaction patterns) is a foundational decision; settle it with the user before building on it.

Where the feature has no interface, the same two moves apply to whatever drives it: the shapes the command or the call could take, then the sequence of the whole exchange.

### Stories and criteria

A user story per task, naming the journey it belongs to, and acceptance criteria for any story whose behavior isn't obvious or has a non-obvious edge case. Phrase criteria as concrete given/when/then conditions, so they translate directly into failing tests.

Where the behavior is a standing invariant rather than an event - a rule that holds while some state is true, a threshold, a security or performance property - write it in EARS instead (`WHILE <state> the system shall …`, `IF <condition> THEN the system shall …`). Gherkin needs a scenario per case to say what EARS says in a line, and three near-identical scenarios hide the one rule underneath them. Non-functional limits go to the spec's `## Constraints` rather than under a story, and each says how it will be verified - future tense, because the check does not exist yet and naming one that does ticks the constraint off against coverage that was never about this feature.

Criteria stay loose here; phase 4 is where they harden.

### Finding the decisions

Walk the feature as red/green steps - "to write this test and make it pass, what would I have to decide that the spec doesn't tell me?" That catches the decisions the stated stories imply. The ones that hurt most are named by no story; two sweeps catch those:

- **Lifecycle.** For each entity the feature touches, walk create, read, update, delete, and who can see it. Respect aggregate boundaries - a non-root entity is created, changed, and deleted only through its root. A feature that adds a create path but is silent on edit, delete, visibility, or dependents is hiding decisions, not omitting them.
- **Actors and authorization.** Who may do each action, who else touches the same data, what is sensitive. Assuming an action is unrestricted is a wrong default that hurts.

Beyond those, let the feature's shape say which usual hiding spots apply - don't force a checklist onto a feature with no use for it:

- **UI:** the states a happy path omits (empty, loading, error, partial, disabled); what confirms an action and what a destructive one warns; layout hierarchy and responsive reflow; accessibility (focus order, labels, contrast, keyboard paths).
- **Behavior:** error, timeout, retry, and idempotency at each external seam; validation rules and where they apply; migration of existing data; ordering, concurrency, and partial failure; non-functional limits (scale, volume, performance budget).

## Phase 4 - The record

Discovery is done when every decision a wrong default could hurt has an answer - from the codebase, a confirmed recommendation, or the user - and nothing the change forces is left for the implementer to guess. Pay closest attention to hard-to-reverse decisions: language, frameworks, data models, aggregate boundaries, anything code commits you to.

Before writing anything down, confirm your running list of defaults and verify none actually needed the user. Resolve any question still open now - neither a spec nor a ticket ever carries an open-questions section. If a question survives, discovery isn't over.

### Records that outlive the feature

Three things you write survive the run. The spec, the tickets and the mockups are deleted when it is accepted; these are not, so each is permanent-tier and each gets its own explicit yes, asked for the moment you propose it rather than collected into a list at the end. Both lanes: on the small lane the user is in front of you, so it gets its yes on the spot.

- **A term** in `UBIQUITOUS_LANGUAGE.md`.
- **An ADR** - shape and location in `ADR_FORMAT.md` - for a structural choice a later reader would otherwise undo without ever learning what it cost. Write it here, where the alternatives are still live and the reasoning is still true, and never autonomously: put the decision and your recommendation, and let the user say whether it becomes a record at all. List it in the spec's `## ADRs` by number and path, alongside the ones the change is merely built under. Read the ones the project already has, the way you read `UBIQUITOUS_LANGUAGE.md` - a spec that contradicts a ratified ADR is one `/critique` will send back.
- **A journey ratified into a workflow test** under `tests/workflows/`, which every feature after this one has to keep green. Agreeing a journey is not ratifying it: ratification is a second yes, asked separately, and it is rare. Most features walk a path the project already has and ratify nothing. Propose one only where this feature establishes a journey nothing else covers.

  One file per journey, named for the journey in the user's language, and **quoting** its `## Journeys` entry rather than paraphrasing it - the test is the record, so there is no companion document to drift out of date. It drives the journey end to end, step by step in the order the entry gives, and asserts what that entry says each step does: the domain effect, and where the last one puts the user down. Not a unit test with a journey's name on it.

  Wire it into the project's check command, which is what makes feature twelve's run keep feature three's journeys green at every ticket, and commit it with the spec. And nothing else may change it afterwards without saying so first: a ticket that touches one carries a written authorisation, and the driver halts one that does not.

Everything else you settle is binding for this change or a default, and both go when the paper does - a default on the small lane is marked in the ticket that carries it, with what in the code would overturn it, and the implementer is bound by it either way.

**Promote what must outlive the code.** A piece of reasoning a later reader would otherwise undo belongs in a comment at the code it explains, not in the ticket - the ticket is paper and goes when the run is accepted.

**Check hard-to-reverse external choices against a primary source** before you write them down - a version, a limit, an API's actual behaviour, whether a library still does what you remember - and cite what you read in the decision. `coding-conventions` already makes this argument for looking up a package version; it binds harder here, because a spec records the choice as settled and nothing downstream looks again.

### Harden it

The spec lane's closing sweep across the whole feature, now that its shape is settled - what turns it from an agreement into a contract an implementer can build without improvising.

- **Complete the criteria.** Every behavior a wrong default could hurt gets a criterion, given/when/then or EARS; each one becomes a test `/implement` writes RED first. A story left with no criteria is where the implementer invents behavior - close it here.
- **Number everything.** Journeys `J-1`, stories `US-1`, criteria `US-1.1`, constraints `C-1`, defaults `D-1`. Tickets cite these rather than copying them, so an unnumbered one is a thing no ticket can claim and no review can check off. This is not optional at any spec size.
- **Check every story names its journey**, and that every journey's steps are covered by stories. A story belonging to no journey is a story nobody asked for; a journey step no story covers is a hole the run will not fill.
- **Bind the decisions.** Every decision that touches existing code names the real structure it reuses or extends, drawn from the codebase - a durable choice, not a `file:line` that drift will invalidate.
- **Map the dependencies.** Record them as the `Depends on` notes in User Stories, so `/spec-to-tickets` can decompose along them.

### Write it

Write the spec to a markdown file in the repo - propose a path and confirm it - following the shape in `SPEC_FORMAT.md`, and present the same content inline so the user can react. It is what `/spec-to-tickets` decomposes and `/implement` is checked against, so it must match what you agreed. Revise from feedback until they're satisfied.

**Have it read cold before you present it.** Dispatch a fresh `general-purpose` subagent over what you wrote, with two questions: **what is the first thing you would have to guess**, and **where does this fight itself** - a success criterion a non-goal rules out, an acceptance criterion that contradicts a domain decision, two decisions that can't both hold, a requirement a reader could take two ways. Your own context cannot forget the intent that silently reconciles a document, which is why the reader has to be one that never had it. Resolve what it finds and pin the reading you mean, then present. Once on the settled document; targeted revisions from later feedback you can recheck yourself.

**Small lane:** the ticket is the document, and it gets the same cold read - harder, if anything, since a lone ticket has no spec behind it to answer either question. Skip it only for a change that is genuinely one line. No hardening sweep, no numbering, no spec file: criteria written out in full, a leading `## Why`, and `/implement` next.

### The receipt

Close with it: **at most five lines**, one per permanent-tier item this discovery produced - a term, an ADR, a ratified journey - each naming what it commits the project to, and an offer to reopen any of them now. Nothing else belongs in it.

Most discoveries produce nothing permanent, and then the receipt is a single line saying so. Five is a cap rather than a target, and needing more than five is a finding in itself: say that plainly and let the user decide what to reopen.

Every item in it already got its own yes when it was proposed, so the receipt is the last chance to take one back rather than the first sight of it. The ranked closing brief this replaced grew with the spec until nobody read it to the end, which is how the one item that needed a veto got skimmed past.

Then point them at the next step: `/spec-to-tickets` for a spec, `/implement` for a ticket. `/spec-to-tickets` marks the defaults more than one ticket must hold to, and hashes the spec as it leaves it; from that hash on the spec is frozen, each ticket carries it, and an edit halts the loop.

## Throughout

These hold in every phase, which is why none of them is one.

### Role

You are a discussion partner, not a stenographer. So:

- **Surface topics the user hasn't raised.** If something seems load-bearing and they haven't mentioned it, bring it up.
- **Propose alternatives.** When the user names a solution, offer one or two plausible alternatives. They'll pick or redirect.
- **Push back.** When their reasoning seems weak, circular, or contradicted by the codebase, say so with your own reasoning. Aim for the best solution, not the first one they thought of. Once, though: a reaffirmed decision is theirs, and re-arguing it costs more than the mistake would.

### The mechanic: sort every decision

A change forces dozens of decisions. Sort each into one bucket:

- **The codebase answers it.** Resolve it silently and move on. Always check the code before asking.
- **A wrong default would hurt, but there's a defensible best answer** - a technical choice like how to wrap a dependency, where a seam sits, a data shape, where an aggregate boundary falls. Decide it, then surface it for a veto: state the decision, your recommendation, and the key alternatives. Don't make the user originate it; do let them overrule it. This is a **default**: it goes in the spec's `## Defaults` with what in the code would overturn it, or, where it qualifies a decision it cannot be read apart from, marked and numbered beside that decision instead. You are deciding it without the evidence the builder will have - which is exactly why the builder may overturn it on evidence found in the code, and never on taste.
- **A wrong default would hurt, and the answer is genuinely the user's** - a business rule, a priority, a product tradeoff the code cannot imply. You cannot default this. Ask.

"Would a wrong default hurt" is the test throughout: it hurts when it changes behavior the user would notice, costs money, risks data, or is hard to reverse. Everything else - local names, file layout, cheap reversible choices - stays with the implementer.

**Surface your assumptions; don't just avoid them.** The defaults that hurt are the ones you pick so confidently they never feel like a question. Keep a running list of what you're defaulting and confirm them for veto ("I'm assuming X and Y unless you say otherwise").

### How to ask

**End your turn at the first question mark.** The moment a turn reaches a question that seeks new information, send it - a second question or "and also" waits for the next turn. This is a rule about output shape, not a preference: one turn, one open question, so the user never has to label which part of their reply answers which question. Confirming assumptions for veto ("I'm assuming X unless you say otherwise") is not an originating question, but it gets its own turn, never mixed with a question.

### Vocabulary discipline

Every project has its own language. Use it precisely.

- **Ask for definitions.** When the user uses a project-specific term with no single obvious meaning, ask what it means; don't bake in your inference.
- **Reuse before invent.** Before naming a concept or actor yourself, check the codebase and `UBIQUITOUS_LANGUAGE.md` for a term that fits. An existing "StaffMember" beats a new "Administrator"; an existing "Application" beats a new "Submission".
- **Verify new terms.** When you must introduce one, voice it as a proposal, check it's genuinely distinct rather than a synonym for something already in the system, and ask whether there are deprecated synonyms to retire.
- **Maintain the glossary.** As terms surface or shift meaning, propose updates to `UBIQUITOUS_LANGUAGE.md` (shape in `UBIQUITOUS_LANGUAGE_FORMAT.md`); propose creating it if absent. Use each term consistently once defined.
- **Gate the summary.** The Ubiquitous-language and Roles sections record only names that pass this discipline, not conversation-framing terms you coined while interviewing.
