---
effort: XL
utility: XL
---

# Lasting approvals outlive the change, and acceptance shows the evidence

Once a change is accepted, nothing a fresh agent can find says what a human
approved, or which test is the check for it. A later change can undo an
approved behaviour, policy or data rule, delete or weaken its test, and
nobody notices that this was a decision for the human.

`MANIFESTO.md` asks for the opposite, for what the developer marked as
lasting: "Changing a lasting approval is theirs to decide"; "Each lasting
approval is written down where the next agent finds it, and held by a
check, or marked as judged where no check can show it"; "A check for a
lasting approval counts only if it fails when the code breaks it, and that
is confirmed for every change before it is accepted"; "Weakening or
deleting a check for anything approved is reported; for a lasting approval,
it is a decision about what it checks."

Evidence:

- `/accept-criteria` deletes the change's directory, `CRITERIA.md` included
  (`accept-criteria/SKILL.md`, "Once the user accepts"; `PIPELINE.md`, "What outlives a change"). What
  it was for "survives in git history", which a fresh agent does not search.
- Tests name the ACs they pin by id (`implement/SKILL.md:18`), and every
  change numbers its ACs from `AC-1`, so after deletion `AC-3` in a test
  name points at nothing and is ambiguous across changes.
- `PIPELINE.md` (ACCEPT, "Before acceptance") says every check for a
  lasting approval "is shown to fail when the code breaks it". No skill or script does this. The only failure ever watched is TDD's RED run, once,
  at build time (`CODING_STANDARDS.md`, "Use TDD").
- `critique` reports lost tests as a finding for the builder to fix
  ("Tests that left", `critique/SKILL.md`), not as a decision for the human,
  and cannot tell an approved constraint's test from any other.

From the review: deleting the paperwork to keep stale documents away is a
sound instinct. The direction discussed was to let the checks carry the
approval - tests named by the approved behaviour in plain words - and to
break the code on approved tests whose code a diff touches, rather than
mutation-testing everything on every change. Only what no check can hold
stays written down.

In the weight tracker, the developer approved each fix to the "gaining
weight" rule, one at a time. Nobody saw the fixes add up to a pile of
special cases instead of one approach. In the end the developer could no
longer say what the rule was meant to do, and nothing written down said it
either.

The manifesto says, in the first line under "For every goal": "The
developer answers for the software as a whole, not for one change at a
time." This item carries one part of that: where a later change quietly
alters behaviour the developer approved earlier, that reaches them without
their having to notice or ask.

The user, on 2026-10-28, writing down what the pipeline is meant to be: "The
main thing I'm unsure right now is the artifacts that create confidence. We
already have SECURITY_POLICY.md. In my mind, there's also the domain model
(ER-style) and domain actions, but this is all very vague and not settled at
all." So which approved artifacts outlive a change - beside
`SECURITY_POLICY.md` perhaps a domain model, domain actions, the critical
user journeys below, the approved criteria - is open, and `PIPELINE.md`
names only the security policy until this item settles the rest.

## Lasting approvals (settled 2026-10-29)

Not everything approved lasts. The developer marks what is lasting when they
approve it: the decisions that must hold until they change them. Most of
what a change approves holds for that change only. A button approved to the
right of a field may move below it in a later change's criteria, and that
is ordinary work, not a breach. Where a build moves it without criteria
saying so, that is a departure from this change, shown at acceptance with
its reason. `MANIFESTO.md` and `PIPELINE.md` say this since 0512059.

So the artifacts hold the lasting approvals only, and stay small enough for
the developer to vouch for every line. An artifact earns its place by the
manifesto's two goals - the developer's trust, and memoryless agents
changing the software fast and correctly:

- the developer can read it without the code, and vouches for each line;
- a check holds the code to it - an agent believes what it reads, so an
  artifact that drifted is worse than none;
- an agent uses it, for what it would otherwise rebuild from the code or
  get wrong.

`SECURITY_POLICY.md` passes all three. `UBIQUITOUS_LANGUAGE.md` has only a
judged drift check. Candidates, from what the developer approves: a domain
model (concepts, how they relate, what is kept and for how long), domain
actions or events with their rules, and the critical user journeys below.
What production must show has no lasting home either. The policy is
already organised per concept and per action, so these may combine into one
file per concept, with journeys apart - or not. `ARCHITECTURE.md` fails all
three tests and goes once these take over orientation
(`drop-architecture-md`).

### Tried on `../haushaltsbuch` (2026-10-29)

The developer named the core: Konto and Buchung, a Buchung moving an amount
between two Konten, and creating or updating either. Everything else is
views. Security plays no part in a local single-user app. Drafts of the
domain model and the domain actions were written from the code. The
developer struck what was not theirs to vouch for: ISO dates, the
Buchungstyp never being stored, parsing euros without `parseFloat`, every
write going through a domain function (implementation), and the
Bilanzgleichung (a view detail). Seven model rules and seven action rules
stayed, such as "a Buchung has exactly two legs", "Eigenkapital holds only
the Anfangsbestand", and "Soll and Haben are two different Konten".

The project already keeps such rules in two places, neither small: the
"Tragende Invarianten" in `CLAUDE.md`, and `UBIQUITOUS_LANGUAGE.md` (71 KB,
100 terms), which mixes them with UI details that last only until the next
change.

Replays of past breaks were planned and dropped: they would measure whether
a file helps an agent keep a rule before it is settled what the files are.

| Artifact | Who writes it | What it holds | Held by | Changing the check |
|---|---|---|---|---|
| Domain model | The developer approves; drafts can come from the code | Rules about the data | Schema constraints, tests | A decision for the developer |
| Domain actions | The same | Rules about the writes | Tests | A decision for the developer |
| Critical user journeys | The developer only | The user's goals that matter | End-to-end tests that implement them | Discussed with the developer: the new way may fit the journey better |
| `SECURITY_POLICY.md` | Exists | Who may see and do what | Rule tests and the policy check | Exists: ACs that add, change or remove R-n |
| `UBIQUITOUS_LANGUAGE.md` | Exists | Terms | `/ubiquitous-language`'s drift check, judged | A decision for the developer |

**The glossary** is the project's agreed terminology. It maps the user's
words to what the code calls them: data, but also what the UI shows, and
everything else. Terms are lasting: a renamed or reused term silently
changes what every rule and journey written in it says. The domain model is
a subset of it: every object in the model has a glossary entry, but not
every entry is in the model. The model adds the objects' fields, which
usually have entries of their own, and the relations between objects; its
rules are written in those terms. The database schema gives a first draft of
both, but neither is complete from it. The `haushaltsbuch` drafts above held
rules only, without the objects, fields and relations they rest on.

The glossary's format already asks for one sentence per term, "Not how it
is built, what a screen shows, or why it is so"
(`UBIQUITOUS_LANGUAGE_FORMAT.md`). In `haushaltsbuch`, 34 of 100 entries
run past 600 characters, because nothing else held rules or how a view
works: changes wrote them there ("Glossar beschreibt Monatsansicht und
Δ-Balken"), and `find-criteria/SKILL.md:43` adds a new term "in the shape
its existing entries have", so long entries breed long ones. Such an entry
splits three ways. `Kontenplan`, about 900 characters today, keeps "the
Konten with their hierarchy across all four Kontoklassen" as its sentence.
"At most one parent, and children inherit its Kontoklasse" goes to the
model. "No page of its own" and how its toggles behave belong to the change
that approved them, and are held by the code and its tests.

**The model and the actions are one file**, `DOMAIN.md`, settled
2026-10-29. It opens with an ER diagram in Mermaid: the objects and their
relations, no fields, which would only repeat the sections. Then one section
per object: its fields, its relations, its rules, and the actions on it with
their rules. Every action rule in the `haushaltsbuch` draft belonged to one
object, and the breaks found in its history were all a new write path
missing a rule its object already had; grouped by object, that rule sits
beside the path. An action that touches several objects goes under the one
it acts on and names the others by their terms. `SECURITY_POLICY.md`, the
journeys and the glossary stay apart. Whether a large project splits it into
a file per object waits for `drk-barmbek`.

**The format of `DOMAIN.md`** follows `SECURITY_POLICY_FORMAT.md`, settled
2026-10-29:

- Written in the domain language and the glossary's terms; no tables,
  columns or files, since the glossary maps the terms to the code.
- Every rule and every action rule has an id `D-n`, one series for the whole
  file, numbered in the order added and never reused: a rule moved to
  another object keeps its id. Fields and relations have none; the diagram,
  the glossary and the schema hold them. A glossary term is its own id;
  journeys are `J-n`.
- Every rule has a test that fails when the code breaks it and names its
  id; where a schema constraint holds it, the test tries to break the
  constraint. A check that executes: every `D-n` has a test naming it, and
  every id a test names exists. A rule no test can show ends with *Judged:*
  and why.
- Ids in test names are wanted here. `haushaltsbuch`'s `CLAUDE.md` bans
  `US-NN` in tests because the story dies with the change; a `D-n` lasts.
- It changes only through approved ACs - "adds:", "changes D-n to:",
  "removes D-n:" - and through an init skill for an existing project, which
  drafts from the schema and the code for the developer to strike. Where
  the code does what the developer disagrees with, the rule says what the
  code does and ends with *Disputed:* and the backlog item that would change
  it.

**The mark of a lasting approval** is an AC that writes into a lasting file:
`DOMAIN.md`, `SECURITY_POLICY.md`, the journeys, or a glossary term. There
is no separate flag. `CRITERIA_FORMAT.md`'s *Concepts* decision becomes the
change's Domain ACs.

Open:

- A check that every object and field in the model has a glossary entry:
  it executes, and it is not a proxy, since a missing entry is the gap
  itself.
- The format: ids, and tests that name them, as in
  `SECURITY_POLICY_FORMAT.md`.
- What production must show still has no home.

`drk-barmbek` is the second project to try the result on.

The evidence at acceptance below builds on this: it needs tests that say
which approved criterion they prove. `refactor-phase` also builds on it:
the approved criteria are the list of behaviours it ranks.

## Critical user journeys

Merged from `critical-user-journeys` on 2026-10-29: when `PIPELINE.md` was
written, the developer moved journeys among the artifacts that create
confidence, which this item settles.

Nothing the pipeline uses or writes says what the software is for: the two or
three critical user journeys (CUJs) - the end-to-end paths that make it worth
using, such as "a customer finds a product and pays for it". They sit far above
the acceptance criteria: a handful per product against hundreds of ACs, each a
happy path at the level of the user's goal, without error cases, which are too
many and too detailed at that level. A change's ACs say how that change moves a
journey; the journey itself is never written down or approved.

Evidence:

- `CODING_STANDARDS.md:89` (five copies) asks "Does the software support the
  main workflows smoothly?" and nothing defines them.
- `repo-overview` writes "Main workflows" into `ARCHITECTURE.md`
  (`repo-overview/SKILL.md:77`), derived from the code: what is, not what was
  meant, and approved by nobody.
- The usability check completes the change's ACs as tasks
  (`MANIFESTO.md`, Usability), so a change that breaks a journey it did not
  touch goes unnoticed; acceptance holds the change against its own Problem,
  never against the journey.
- `ubiquitous-language` walks "each major workflow" through its terms
  (`ubiquitous-language/SKILL.md:62`) and invents the workflows each time.

How it was discussed to fit:

- **Manifesto:** the developer owns the journeys - the top of what the
  developer decides, "what the software does", and the one approval that
  outlives every change. Changing one is a decision the plan didn't cover.
  The usability agent completes the journeys through the real interface, not
  only the change's ACs. Its written form is the user's goal, in the
  developer's words: "As a user, I can see where I spent my money this year,
  and find out where the majority went." Which of the many things the
  software lets you do are critical cannot be read from the code; some are
  designed, some just emerge. An end-to-end test is the journey's current
  implementation. A change that needs it changed goes to the developer as a
  question: the new way may serve the journey better.
- **A lasting file**, e.g. `JOURNEYS.md` beside `UBIQUITOUS_LANGUAGE.md`,
  with a format file copied into each skill that uses it. Accepted ACs live
  on as tests grouped under the journey they serve.
- `idea` places the problem on a journey; one that fits none is either a new
  journey or not worth doing.
- `find-criteria`: `CRITERIA.md` names the journey the change serves; adding
  or changing a journey is approved explicitly, one more approval beside the
  four AC groups and three technical decisions. Where the project has none,
  the first change writes them.
- `implement` / `critique`: the usability driver also gets the journeys the
  change touches; a journey check weakened or deleted is reported as a
  decision.
- `accept-criteria` walks the change's journey end to end and holds the
  result against it as well as against the Problem.
- `repo-overview`'s "Main workflows" are not a draft of the journeys: they
  list what the code allows, which is what the developer has to choose from.
- `restructure`: a feature that serves no journey is a candidate among
  "features that cost more than they give"; `backlog` ranks utility by the
  journey an item serves; `ubiquitous-language` walks the approved journeys;
  `explain-diff` places a change's happy path on its journey.

Journeys carry the parts of the software that no recent change touched. A
journey's end-to-end check is the most direct evidence that the software as
a whole works. When a journey breaks, the developer hears of it without
having to notice or ask.

Open:

- When the journey checks run: end-to-end checks are slow and flaky, but
  every check for something approved has to fail when the code breaks it,
  confirmed for every change. Part of this is settled: end-to-end tests
  belong in the project's slow check (`CODING_STANDARDS.md`, _Test
  Coverage_), and `run.sh` runs the slow check before the first build, after
  every ticket and after the final review.
- Whether `find-criteria` writes the first journeys, or something else does.

## Acceptance shows evidence a script reran, not the agent's account

Merged from `acceptance-evidence-from-a-script` on 2026-10-29: its evidence
needs the tests this item names after what was approved, and both change
what `/accept-criteria` shows and deletes.

At acceptance the developer, who does not read the code, gets the agent's
account of each criterion: "for each one say what you did and what you saw"
(`accept-criteria/SKILL.md:25`). Tests come in only where an AC is not met
(`:35`). The developer cannot tell an executed proof from a judgement.

`MANIFESTO.md`, under Utility: "The report shows the evidence, rerun by a
script rather than reported by the writer", and "Where no check can show it,
it is marked as judged." For every goal: "Where a criterion can only be
judged, the review is adversarial." Showing example runs, listing tests by
what they prove, and marking a check that only approximates a criterion left
the manifesto and are not yet in `PIPELINE.md`.

Evidence:

- The runner reruns the checks itself (`run/checks.sh`), but as one
  pass/fail for the whole suite; nothing turns that into evidence per AC.
- Whether an AC is executed or judged is decided by the builder after the
  fact: Left standing lists "each criterion no automated test proves, and
  how it was checked instead" (`implement/SKILL.md`, "Finish"). `CRITERIA_FORMAT.md` has no
  place to mark an AC as judged, or a check as only approximating it, at
  approval time.
- Nothing hands the judged ACs to a reviewer whose job is to show they are
  not met. `critique` refutes its own findings, which is a different thing.

- critique's output now opens with a Tasks section: one line per AC its
  driver was handed, completed, given up or skipped and why
  (`critique/SKILL.md`, "Output"). It is a per-AC record of the judged
  usability check, but it reaches the developer only where a caller passes
  it on - `implement`'s Left standing and `REVIEW.md` carry findings, not
  tasks - and a hesitation the build fixed reaches them not at all.

From the review: the walk stays, for usability and for the problem as a
whole; the script-made table comes before it.
