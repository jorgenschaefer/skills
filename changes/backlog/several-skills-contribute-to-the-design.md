---
effort: L
utility: L
---

# Several skills contribute to the design

The user, on 2026-11-02: "I can see multiple skills contributing to a first
design. design-user-journeys adds user journeys, design-frontend adds a
well-designed frontend, design-domain maybe discusses a difficult domain?"

Today `design-user-journeys` does all of it: the journeys, the walk, the
prototype (`design-user-journeys/SKILL.md:37`), the layout questions, and
"what it keeps" under "Data". This came up while splitting the build off
from the design, in `plan-the-build-and-decide-only-what-is-hard-to-change.md`.
That item covers the build. This one covers the design.

## The skills

- **`design-user-journeys`**: who uses the software and for what, as light
  journeys (below). It comes first, because the other two build on it.
- **`design-domain`**: the things the user works with, how they hang
  together, their rules and their lifecycle, in the user's words.
- **`design-frontend`**: the look and feel, and the prototype that
  `design-user-journeys` builds today. The plugin skill
  `frontend-design:frontend-design` could be a base.

Anthropic's playbook does something close to this (`anthropic-sdlc.md`,
Stage 2): one session with skills for brand, security, compliance and UX
writes one spec. Where two skills pull against each other, the agent shows
the conflict and a human decides it.

## What was proposed, not yet agreed

- **Each skill is optional.** No UI means no `design-frontend`; simple data
  means no `design-domain`. `design-user-journeys` decides at its end which
  ones run, and asks the developer.
- **One `CHANGE.md`.** All of them write into the same file, in their own
  sections, so `create-plan` gets one spec.
- **What outlives the change.** The journeys last, and so would a domain
  document. The prototype is deleted at acceptance, as today. A frontend
  design system - colours, type, components - would last too.

## Light journeys

Agreed. The user: "User journeys should still exist, but be very light - they
need to be kept around for the agent to orient itself in the software, to
find out what the intended use is, but not to know every single step and
special case. That's what the code is for." And: "we already put a lot more
detail into the user journeys than I intended to be there, because we have
no other place for that to be."

Why the detail is there today: only a journey's test lasts. "Every other test
is yours" (`implement-change/SKILL.md:32`). So a rule that must last needs a
journey step. `CHANGE_FORMAT.md:56`, in all four copies: "A design detail
that must last, such as "overdue invoices are shown in red", becomes
something the user sees in a journey step, so it gets a test."
`design-user-journeys/SKILL.md:45` asks for this.

So a journey keeps who uses the software and for what. During the change, the
details of each step and the special cases live in the prototype and in
`CHANGE.md`'s design - both temporary, both agreed with the developer. After
acceptance they live in the code and the hard tests (from the plan item); a
hard test's name says its rule in the user's words.

## Where the domain fits

`design-domain` would give a place to things that have none today:

- `SDLC.md`, Future Changes: "The domain model is a good idea, but has no
  place yet", and "Stored data (database schemas) and wire formats are
  relevant but are not mentioned yet."
- The rules that should be hard tests, such as "an invoice is overdue 30
  days after it was sent". A list of rules is part of a domain model.
- `UBIQUITOUS_LANGUAGE.md`, which `init-ubiquitous-language` writes. Only
  `repo-overview` and `explain-diff` read it; no skill of the SDLC journeys
  does.
- A permanent place for what must last, which
  `designs-declare-what-must-be-true.md` asks for.

It also divides the hard decisions. `design-domain` settles their substance
in the user's words - "a training keeps the name of its plan, so deleting a
plan loses nothing" - and `create-plan` turns them into a schema, pointing
back to the domain line each one comes from. The developer decides the
substance in the design, and in the plan only checks the translation.

The evidence for it is in the plan item, from `workout-tracker` on
2026-11-02: the data came only as a list in words, and how the things hang
together did not come up - "whether a training points to its plan or only
keeps its name". The developer: "Mir fehlt tatsächlich die klare
Darstellung, wie das in der DB gespeichert wird. Ohne das fühle ich mich
unsicher."

## What it touches

`SDLC.md` ("Add a feature", Future Changes); `design-user-journeys`; new
skills `design-domain` and `design-frontend`; `idea` where it hands over;
the four copies of `CHANGE_FORMAT.md` and the copies of `JOURNEY_FORMAT.md`;
`walk-user-journeys` and `accept-change`, which walk the journeys;
perhaps `init-ubiquitous-language`.
