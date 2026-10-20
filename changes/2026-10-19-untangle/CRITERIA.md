# Criteria: explain-code and untangle, code that reads like its description

## Problem
In a part of the code whose logic has grown complicated, such as the weight tracker's rule for when a series shows as "gaining weight", the developer no longer knows what the rule is. Reading the code doesn't tell them. An agent that has read the code doesn't help either. When it proposed fixes for a "missed gain", its explanations made no sense to the developer in terms of the rule. A readable account of the rule can be produced, but it doesn't match how the code works, so understanding the account still doesn't tell the developer where or how a change would go. They approve product changes they can't judge, and they lose control of software they wrote. Instead, the developer can understand what such a part of the code does, and that understanding carries over to the code. A change they can put in terms of the rule points to a place in the code, and an agent's explanation of a code change makes sense in terms of the rule. What the code does stays the same. Whether its cases are all still needed is a separate problem.

The instance: the weight tracker's "gaining weight" rule, in `/home/jorgen/Projects/weight-tracker` under `src/verdict/` and `src/trend/`, grew complicated until the user no longer understood it and could not learn it from the code. When a "missed gain" came up, they depended entirely on an agent's proposed fixes and could not say what they wanted. By hand, one agent described the code in prose, a second without code access rewrote it for readability, and a third refactored the code to follow it; before the refactor the user's ideas for changes did not map onto the code, after it the result "looked really good". A first build of this change, the skill `untangle` on the branch `2026-10-19-code-reads-like-its-description`, was not accepted: it took only the verdict asked about rather than everything the page shows from the same code, its account was "super dense" while a short numbered explanation in chat was "very nice, concise", its coverage classification separated nothing, and it was "completely overengineered". The commits of the "missed gain" fixes are not named.

## Acceptance criteria
- **AC-1** `explain-code` is typed only: its frontmatter sets `disable-model-invocation: true`. `explain-code/` holds only `SKILL.md`.
- **AC-2** Started as `/explain-code <a question in words>` with no file named, it asks nothing before showing the explanation. Started with no question, it asks for one.
- **AC-3** The explanation is shown in chat. It opens with everything shown where the answer shows - a screen, a command's output, a response - that comes from the code deciding the answer, in the words used there, and closes with the files that code is in.
- **AC-4** A subagent that reads the code writes the explanation, and a second subagent that opens no file rewrites it. The rewriter is told it may cut, merge and drop detail, and that the explanation opens with a summary of a few sentences in terms explained below it, then a section for each term under a title naming what it describes, whose own terms get titled sections further down. Nothing tells it to keep every claim, branch or example.
- **AC-5** Before each version is shown, a fresh agent that wrote neither version reads it together with the code. It reports only statements the code contradicts. Each finding is fixed by correcting or dropping that statement, and a missing detail is never a finding.
- **AC-6** Where the developer says something is unclear, the explanation is revised through the writer, the rewriter and the checker again. The skill ends when the developer says they understand it, and it writes no file.
- **AC-7** `untangle` is typed only: its frontmatter sets `disable-model-invocation: true`. `untangle/` holds only `SKILL.md` and a byte-identical copy of `find-criteria/CRITERIA_FORMAT.md`.
- **AC-8** Where the conversation holds no explanation the developer has said they understand, `untangle` tells them to type `/explain-code <their question>` and then `/untangle` again, and stops.
- **AC-9** It then proposes in chat, in the explanation's terms: for each concept, its module path and what the module offers; one call from an existing test, rewritten against the new interface; the callers outside the scope that will move; a sample change put in the explanation's terms; and the four technical decisions for the rework, each held against the scope files and the callers that move, "none" included. The developer corrects or approves it. Nothing is written before they approve.
- **AC-10** Cases the developer called surprising during the explanation appear in the generated `CRITERIA.md` under `## Out of scope`, and `untangle` runs `/backlog` to add one item to the project's backlog for deciding whether those cases are still needed.
- **AC-11** On approval, the skill writes `EXPLANATION.md` and `CRITERIA.md` in `changes/YYYY-MM-DD-<slug>/`, the latter in `CRITERIA_FORMAT.md`'s shape. Its problem says, for the developer's question, that they no longer know what this part of the code does, that a change put in the explanation's terms should point to one place in the code, and that what the code does stays the same; then the instance the developer gave in the conversation, or a line saying they gave none. Its agreed design is the approved shape, a pointer to `EXPLANATION.md`, the scope files, and the three steps in order: (1) the interface over the old code, (2) new tests against it plus the test map, (3) the code replaced behind the interface. Its technical decisions are the ones approved under AC-9. Its nudges are the template's, and its `## Ruled out` holds the shapes the developer rejected under AC-9, or is omitted where there were none.
- **AC-12** The generated ACs say: each concept is a module at the approved path, offering what was approved; the new tests were committed green against the old code; `test-map.md` in the change's directory lists every test that existed before the change in a file importing a scope file directly, each with either the new test that is its home or "no longer reachable" and the reason; from the first commit that changes code behind the interface onward, the only change any commit makes to a test file is deleting an old test `test-map.md` lists; `test-map.md` holds a fresh agent's verdict on every row, that the new home holds the old test's inputs, expected values and assertions, or that the "no longer reachable" reason is borne out by the code; the diff touches only the scope files, the new modules, the listed callers and test files; no code outside the new modules calls the old internals, and the whole suite is green; `checks.md` in the change's directory holds a description a fresh agent wrote from the new modules alone, which names every concept `EXPLANATION.md` gives a section and contradicts none of its statements; and `checks.md` holds the diff stat of the approved sample change, made by a fresh agent on a throwaway branch, touching one module per concept it changes.
- **AC-13** `untangle` ends by naming `/criteria-to-tickets` and does not go on by itself.
- **AC-14** `/explain-code How does the verdict on "nimmt zu" show up?`, run in `/home/jorgen/Projects/weight-tracker`, explains „Langfristig · 4 Wochen“, „Frühwarnung · letzte Tage“ with „Nimmt zu“, „Stagniert“ and „Nimmt ab“, „Heute · … über/unter dem Trend“, „Der Trend steigt seit N Tagen“, and over how many days the trend's pace is measured.
- **AC-15** `/untangle` on that explanation reaches a `CRITERIA.md` that `/criteria-to-tickets` slices without asking.

## Agreed design
Two typed skills. `explain-code` finds the code by tracing back from where the answer shows - a screen, a command's output - widens the question to everything shown there from that code, and explains it in chat: a writer that reads the code, a rewriter that never sees it and may cut freely, and a checker that reports only false statements. It revises with the developer until they say they understand. `untangle` takes that explanation from the conversation, and sends the developer to `/explain-code` where there is none, has the developer approve the module shape and a sample change, and writes a `CRITERIA.md` from a fixed template that `/criteria-to-tickets`, `run.sh` and `/accept-criteria` carry through: the interface over the old code, new tests and a map from every old test to its new home, then the code replaced behind the interface.

## Technical decisions
- **Stored formats** none in this repository; `explain-code` writes nothing. In a project `untangle` runs on, the change's directory gains `EXPLANATION.md` and, from the rework, `test-map.md` and `checks.md`, all deleted with the directory; and the project's backlog gains the item of AC-10.
- **Wire formats** none. The generated file follows the existing `CRITERIA_FORMAT.md`.
- **Trust boundaries** none.
- **Dependencies** none, here or in the project.

## Nudges
- Keep the generated ACs' template in one place in `untangle/SKILL.md`.
- The change's directory is `changes/2026-10-19-untangle/`, built on the branch `2026-10-19-untangle`. The old branch `2026-10-19-code-reads-like-its-description` is left alone.
- README: list `explain-code` among the skills outside the pipeline, beside `explain-diff`; add `untangle` as a way into `CRITERIA.md` beside `/find-criteria`, entered after `/explain-code`; and name `untangle` beside `find-criteria` as holding `CRITERIA_FORMAT.md`, in the README's paragraph on shared files and in `test.sh`'s comment on them.
- Delete `changes/backlog/code-reads-like-its-description.md`, and update `changes/backlog/find-code-before-understanding-is-lost.md`, which points at it.
- Add a backlog item for a `CODING_STANDARDS.md` rule, roughly "a module opens with its concept, and its parts are the concepts of its domain".

## Out of scope
- Writing tests where coverage is thin: the existing tests are taken as pinning the behaviour.
- Cross-cutting behaviours such as permissions, logging or units.
- Mutation testing.
- The `CODING_STANDARDS.md` rule itself (a backlog item).
- Finding behaviours before understanding is lost (`find-code-before-understanding-is-lost.md`).
- Removing a rule's cases (`rule-cruft.md`).
- Changes to `run.sh`.
- An HTML page for the explanation.

## Ruled out
- **One skill for both the explanation and the shape** - an explanation is useful without any rework.
- **`untangle` running `explain-code` itself, or holding a copy of it** - a typed skill cannot be invoked by another, and a copy is a second procedure to keep in step.
- **Passing the explanation as a file** - a file every time the developer only wanted to understand something.
- **`explain-code` firing on its description** - three subagents on questions a sentence would answer.
- **Explaining and reworking in one session** - its own build loop beside `/implement`, and a session that dies mid-refactor leaves it half done.
- **Reworking first and explaining the result** - the shape comes from the old code's cuts, and the developer sees it only afterwards.
- **Finding the scope by coverage or the import graph** - both show what is reachable, not where the question ends; coverage separated nothing in the first build.
- **Changing only the tests' imports** - the tests call internals a real rework moves.
- **Mutation testing or coverage comparison for the new tests** - a dependency per project, or blind to assertions; every old test gets a mapped home instead.
- **Dropping tests of weird edge cases** - leaves a case unpinned exactly while the code behind it is rewritten.
- **A correctness check that asks for completeness** - it made the first build's account too dense to follow.
- **Checking the explanation only by the round trip** - a false explanation would be found after the code was reshaped around it.
- **An adversary for the generated `CRITERIA.md`** - every part that varies per run already has a checker that did not write it.
- **Writing the tickets directly** - a second place that has to know the ticket format.
