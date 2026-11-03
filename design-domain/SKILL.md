---
name: design-domain
description: Work out with the developer the things the user works with - how they hang together, their rules and their lifecycle, in the user's words - starting from the domain model drawn from the schema and UBIQUITOUS_LANGUAGE.md, and keep the glossary up to date. Use when a change adds or changes what the software keeps or the rules about it, when create-spec needs the domain part of a design, and on "sort out the domain", "what is the data model here".
---

# Design the domain

Work out with the developer the things the user works with, how they hang together, their rules and their lifecycle, in the user's words, until whoever plans the schema would not have to ask anything.

This skill's `UBIQUITOUS_LANGUAGE_FORMAT.md` settles the shape of `UBIQUITOUS_LANGUAGE.md`.

## Start from the problem

**Take what the change is for from your caller**, or from the conversation: the problem, and the journeys where there are any. Where there is none, ask what the change is for before you design anything.

## Draw the model as it is

**Read the schema, the migrations and `UBIQUITOUS_LANGUAGE.md` first.** Where the project has no glossary, say that `/init-ubiquitous-language` writes one, and carry on with the words the code and the journeys use.

**Draw the current model for the developer**: the things, and how they hang together - which belongs to which, how many of each, what happens to one when the other is deleted. In the glossary's words, not the table names. Leave out IDs, join tables, timestamps, sync columns and whatever else is there only for the code. A small diagram says this quicker than a list; use one where it helps.

**Get the developer's yes that this is the software as it is.** A wrong picture is corrected here, not designed around.

## Work out the change

**Walk the things the change adds or changes with the developer**: what each is, how it hangs together with the rest, its rules, and its lifecycle - how it comes to exist, what changes it, and what happens when it goes, to it and to what points at it.

**Offer alternatives at each decision where there are real ones**, the simplest first and called the simplest. Give each its effort and the complexity it adds, next to what it gives, then recommend one and say why. Effort is a size from XS to XL. Complexity is a few words naming what it adds, not a size.

**Ask what happens to what the software already holds** when the change alters it.

**Say why the model is shaped as it is, as a rule a user relies on**: "a training keeps the name of its plan, so deleting a plan loses nothing". Each such rule is what `create-plan` makes a hard test, named in the user's words.

**Use the user's words.** A new thing gets its name from the user.

**Do not put details of the code to the developer** - tables, columns, types, indexes. Those are `create-plan`'s.

**End your turn at the first question mark.** One turn, one open question.

**Weigh what the developer says before following it.** For each answer, look for what would make it better - a gap, a simpler form, a consequence it misses - and propose it, or object where you think it is wrong. Once: a decision reaffirmed after hearing the objection is theirs.

**The design is done when the model and its rules can be written so that whoever plans the schema would not have to ask anything.**

## Hand it back

**Show the agreed model** as it will be after the change - the drawing and the rules - and ask whether this is right.

**Update `UBIQUITOUS_LANGUAGE.md`** where the change brings new words or changes what a word means, following the format's updating rules. Where there is no glossary, leave it: `/init-ubiquitous-language` writes one.

**Hand the agreed model and its rules back to your caller.** Write no other file: the model is drawn when it is needed, not kept beside the schema, where it would drift. Where you were used on your own, the agreed model stays in the conversation, and the developer commits the glossary.
