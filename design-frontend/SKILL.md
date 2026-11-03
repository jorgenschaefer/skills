---
name: design-frontend
description: Work out with the developer how the screens of a change look and feel - matching the design system already in the code, or, for a new app, picking one from several proposed - with a prototype they can click through. Use when a change adds or changes what a user sees, when create-spec needs the frontend part of a design, and for a redesign on its own.
---

# Design the frontend

Work out with the developer how the screens look and feel, with a prototype they can click through, until whoever builds them would not have to ask anything about what a user sees.

## Start from the problem

**Take what the change is for from your caller**, or from the conversation: the problem, the journeys, and the domain where there is one. Where there is none, ask what the change is for before you design anything.

**You may start from the plugin skill `frontend-design:frontend-design`** where it is installed.

## Find the design system

**In an app that exists, the design system is the code**: the theme - colours, type, spacing - the shared components, and the screens already there. Read them, and design the new screens to match. Write no design-system document: it would only drift from the code.

**For a new app, propose several design systems** that fit the app and its users, side by side, the simplest first and called the simplest, with a recommendation and why. Use a prototype where seeing them says more than describing them. The developer picks one. The first change builds it as code: the theme and the first shared components.

**Why the UI looks as it does is about the user**, such as "used one-handed in the gym". It belongs in a journey's "Who" or in `intent.md`.

## Work out the screens

**Offer alternatives where there are real ones**, the simplest first and called the simplest. Give each its effort and the complexity it adds, next to what it gives, then recommend one and say why. Effort is a size from XS to XL. Complexity is a few words naming what it adds, not a size.

**Build a prototype where seeing a screen says more than describing it.** A rough one they can click through: publish it as a Claude Artifact, and keep a copy in `prototype/` in the change's directory your caller names, made now if it is not there. Used on your own, ask the developer where it goes. Once the design is agreed, `prototype/` holds the agreed prototype and nothing else.

**For anything a user sees, ask about**: the feedback after every action, actions that cannot be undone, the layout at the narrowest and widest supported screen, and how prominent rarely used actions are.

**Use the user's words** on every screen: the words of the journeys, and of `UBIQUITOUS_LANGUAGE.md` where the project has one.

**Do not put details of the code to the developer** - components, files, libraries. Those are the plan's.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the developer says before following it.** For each answer, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**The design is done when the screens can be built from the prototype and what you agreed, without asking anything.**

## Hand it back

**Show the agreed design and the prototype, and ask whether this is right.**

**Hand the agreed design and the path of the prototype back to your caller.** Where you were used on your own, the developer commits them.
