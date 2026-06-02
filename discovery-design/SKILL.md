---
name: discovery-design
description: Use after /discovery (and optional /discovery-increment) when a spec has user-facing UI that still leaves visual and interaction decisions an implementer would otherwise pick arbitrarily. Optional depth pass, distinct from /discovery-implementation (which covers how it's built). Triggers on "/discovery-design", "design the UI", "what should this look like", or before /implement on a feature with a meaningful interface.
---

# Discovery Design

Given a path to a `/discovery`-shaped spec (the whole discovery doc or a single `INCREMENT-NN.md` - any filename is fine), design the feature's UI: which existing components it reuses, what new ones it needs, and how every screen and state looks and behaves. Resolve those decisions and enrich the spec in place, so `/implement` builds the intended interface instead of inventing one. This pass covers how the feature looks; its sibling `/discovery-implementation` covers how it's built.

This is an optional depth pass, run just-in-time on whatever is about to be implemented - if a large spec was split, run it per `INCREMENT`. Skip it for features with no meaningful interface.

## Before starting

- The input is a path to the spec. If the user didn't supply one, ask before doing anything else.
- Confirm the file is recognizably `/discovery`-shaped (at minimum: Why and User Stories). If not, stop and tell the user.
- Skim the codebase for the existing design language - component library, design tokens, spacing and type scale, styling conventions, and any documented style guide. This is what new work must stay consistent with. Read it before proposing anything.
- Note the UI the spec already settles. Do not re-litigate it.

## The mechanic

Walk the spec's user-facing stories. For each, work out what the user sees and does: the screen, its layout, the components, and every state it passes through. At each point ask: "what would an implementer have to pick here that the spec doesn't say - and would a plausible-but-wrong choice produce the wrong interface?"

**Reuse before invent.** Prefer an existing component over a new one; an existing pattern over a new arrangement. Introduce something new only when nothing existing fits, and when you do, keep it consistent with the design language. Greenfield, there is no language yet - establishing it (tokens, type scale, spacing, the core interaction patterns) is a foundational decision; settle it with the user before building on it.

Decide and record the rest. The goal is that no UI decision is left for the implementer to make blind - not that every pixel becomes a question.

## How to ask: show, don't tell

Do not ask the user to picture a layout from prose. Build a small, concrete, throwaway HTML mockup of the option - or two side by side when you are weighing alternatives - and have them react to something real. Iterate on the mockup until the decision is settled, one topic per turn.

Build the mockups with the `frontend-design` skill, so they are polished and distinctive rather than generic - a mockup that looks like AI slop draws reactions about the slop, not the decision. Greenfield, this is where you use its push toward a bold, committed aesthetic to settle the design language with the user. Brownfield, apply its craft - typography, spacing, motion, restraint - within the existing language, matching the real components instead of inventing a new look.

These mockups are a communication device, not a deliverable. Keep them in a scratch directory and **delete them once the decisions are recorded** in the spec. The spec, not the mockup, is the artifact `/implement` consumes.

For any decision that is significant or hard to reverse - the design language itself, a new core component, a navigation model - present your recommendation and the key alternatives and wait for confirmation. Never settle one of these silently.

## What to look for

A floor, not a ceiling. Follow the spec's actual screens:

- **Layout and hierarchy.** Where things sit, what is primary, how a screen reflows responsively.
- **Components.** Which existing ones are reused; which new ones are needed and how they fit the design language.
- **States.** Empty, loading, error, partial, disabled, and the boundaries between them - the states a happy-path mockup omits.
- **Interaction and feedback.** What confirms an action, what a destructive action warns, how validation surfaces.
- **Accessibility basics.** Focus order, labels, contrast, keyboard paths - where a wrong default excludes users.

## When to stop

Done when every UI decision a wrong pick could hurt has an answer, and new pieces sit consistently within the design language (established, greenfield). Cheap, obvious styling that any reasonable implementer would get right stays with the implementer.

## Output

Enrich the spec in place. Present the additions and confirm with the user before writing the file back, then delete the scratch mockups:

- Add a **Design** section: per screen, the layout and components (reused vs new), the states, and an inline `_Why: ..._` when a wrong turn was the risk. Greenfield, record the established design language here.
- Tighten existing **acceptance criteria** where a design decision sharpened them.

Leave the rest of the spec untouched. The result is the same `/discovery`-shaped doc, now exhaustive enough that `/implement` builds the interface without guessing.
