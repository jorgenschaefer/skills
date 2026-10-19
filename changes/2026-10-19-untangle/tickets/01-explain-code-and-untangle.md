---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15
advances:
after:
status:    ready
attempts:  0
---

## Build
Two new typed skills: `explain-code`, which explains in chat what a part of the code does, and `untangle`, which turns an explanation the developer understands into a module shape and writes the `CRITERIA.md` that reworks the code behind it. Plus the README, `test.sh` comment and backlog changes that go with them.

## Done when
> **AC-1** `explain-code` is typed only: its frontmatter sets `disable-model-invocation: true`. `explain-code/` holds only `SKILL.md`.

> **AC-2** Started as `/explain-code <a question in words>` with no file named, it asks nothing before showing the explanation. Started with no question, it asks for one.

> **AC-3** The explanation is shown in chat. It opens with everything shown where the answer shows - a screen, a command's output, a response - that comes from the code deciding the answer, in the words used there, and closes with the files that code is in.

> **AC-4** A subagent that reads the code writes the explanation, and a second subagent that opens no file rewrites it. The rewriter is told it may cut, merge and drop detail, and that the target is a short numbered list. Nothing tells it to keep every claim, branch or example.

> **AC-5** Before each version is shown, a fresh agent that wrote neither version reads it together with the code. It reports only statements the code contradicts. Each finding is fixed by correcting or dropping that statement, and a missing detail is never a finding.

> **AC-6** Where the developer says something is unclear, the explanation is revised through the writer, the rewriter and the checker again. The skill ends when the developer says they understand it, and it writes no file.

> **AC-7** `untangle` is typed only: its frontmatter sets `disable-model-invocation: true`. `untangle/` holds only `SKILL.md` and a byte-identical copy of `find-criteria/CRITERIA_FORMAT.md`.

> **AC-8** Where the conversation holds no explanation the developer has said they understand, `untangle` tells them to type `/explain-code <their question>` and then `/untangle` again, and stops.

> **AC-9** It then proposes in chat, in the explanation's terms: for each concept, its module path and what the module offers; one call from an existing test, rewritten against the new interface; the callers outside the scope that will move; a sample change put in the explanation's terms; and the four technical decisions for the rework, each held against the scope files and the callers that move, "none" included. The developer corrects or approves it. Nothing is written before they approve.

> **AC-10** Cases the developer called surprising during the explanation appear in the generated `CRITERIA.md` under `## Out of scope`, and `untangle` runs `/backlog` to add one item to the project's backlog for deciding whether those cases are still needed.

> **AC-11** On approval, the skill writes `EXPLANATION.md` and `CRITERIA.md` in `changes/YYYY-MM-DD-<slug>/`, the latter in `CRITERIA_FORMAT.md`'s shape. Its problem says, for the developer's question, that they no longer know what this part of the code does, that a change put in the explanation's terms should point to one place in the code, and that what the code does stays the same; then the instance the developer gave in the conversation, or a line saying they gave none. Its agreed design is the approved shape, a pointer to `EXPLANATION.md`, the scope files, and the three steps in order: (1) the interface over the old code, (2) new tests against it plus the test map, (3) the code replaced behind the interface. Its technical decisions are the ones approved under AC-9. Its nudges are the template's, and its `## Ruled out` holds the shapes the developer rejected under AC-9, or is omitted where there were none.

> **AC-12** The generated ACs say: each concept is a module at the approved path, offering what was approved; the new tests were committed green against the old code; `test-map.md` in the change's directory lists every test that existed before the change in a file importing a scope file directly, each with either the new test that is its home or "no longer reachable" and the reason; from the first commit that changes code behind the interface onward, the only change any commit makes to a test file is deleting an old test `test-map.md` lists; `test-map.md` holds a fresh agent's verdict on every row, that the new home holds the old test's inputs, expected values and assertions, or that the "no longer reachable" reason is borne out by the code; the diff touches only the scope files, the new modules, the listed callers and test files; no code outside the new modules calls the old internals, and the whole suite is green; `checks.md` in the change's directory holds a description a fresh agent wrote from the new modules alone, which names every numbered concept of `EXPLANATION.md` and contradicts none of its statements; and `checks.md` holds the diff stat of the approved sample change, made by a fresh agent on a throwaway branch, touching one module per concept it changes.

> **AC-13** `untangle` ends by naming `/criteria-to-tickets` and does not go on by itself.

> **AC-14** `/explain-code How does the verdict on "nimmt zu" show up?`, run in `/home/jorgen/Projects/weight-tracker`, explains „Langfristig · 4 Wochen“, „Frühwarnung · letzte Tage“ with „Nimmt zu“, „Stagniert“ and „Nimmt ab“, „Heute · … über/unter dem Trend“, „Der Trend steigt seit N Tagen“, and over how many days the trend's pace is measured.

> **AC-15** `/untangle` on that explanation reaches a `CRITERIA.md` that `/criteria-to-tickets` slices without asking.

## Technical decisions
> **Stored formats** none in this repository; `explain-code` writes nothing. In a project `untangle` runs on, the change's directory gains `EXPLANATION.md` and, from the rework, `test-map.md` and `checks.md`, all deleted with the directory; and the project's backlog gains the item of AC-10.

> **Wire formats** none. The generated file follows the existing `CRITERIA_FORMAT.md`.

> **Trust boundaries** none.

> **Dependencies** none, here or in the project.

## Nudges
> Keep the generated ACs' template in one place in `untangle/SKILL.md`.

> The change's directory is `changes/2026-10-19-untangle/`, built on the branch `2026-10-19-untangle`. The old branch `2026-10-19-code-reads-like-its-description` is left alone.

> README: list `explain-code` among the skills outside the pipeline, beside `explain-diff`; add `untangle` as a way into `CRITERIA.md` beside `/find-criteria`, entered after `/explain-code`; and name `untangle` beside `find-criteria` as holding `CRITERIA_FORMAT.md`, in the README's paragraph on shared files and in `test.sh`'s comment on them.

> Delete `changes/backlog/code-reads-like-its-description.md`, and update `changes/backlog/find-code-before-understanding-is-lost.md`, which points at it.

> Add a backlog item for a `CODING_STANDARDS.md` rule, roughly "a module opens with its concept, and its parts are the concepts of its domain".

## Context
This replaces a first build of `untangle`, on the branch `2026-10-19-code-reads-like-its-description`, that was not accepted as "completely overengineered": a 188-line `SKILL.md`, a `VERIFY.md`, an HTML page template, a coverage-classification script with its own suite, and about fifteen fresh-context agents per run. What helped the user was one short numbered explanation in chat. That branch shows what not to build; do not take its text over. AC-1 and AC-7 hold both skills to `SKILL.md` alone (plus the `CRITERIA_FORMAT.md` copy), and the skills' length is part of what acceptance judges.

`explain-code` traces back from where the answer shows to the code that decides it, then widens to everything shown there from that code: the first build's question about „Nimmt zu“ was one of three values on the page, and the user had to name the rest themselves. The rewriter that never sees the code is what made the user's by-hand explanation readable; the first build's rewriter was told to keep every claim, example and test id, which made its account dense. The checker is there for truth only.

`untangle` follows `find-criteria`'s ways where they fit: one question per turn, the explanation taken from the conversation the way `find-criteria` takes `/idea`'s problem. `/backlog` fires by description, so `untangle` can run it; `explain-code` is typed only, so `untangle` cannot, and sends the developer to it instead, as `backlog/SKILL.md` does with `/find-criteria`. The generated `CRITERIA.md` gets no adversary of its own.

`test.sh` already checks every file more than one skill holds for byte-identical copies, so the `CRITERIA_FORMAT.md` copy is checked without a change to the test; only its comment (`test.sh:23`) and the README's paragraph on shared files (`README.md:80`) name the holders. The README's list of skills outside the pipeline is at `README.md:193`, the skill entries from `README.md:197`.

AC-14 and AC-15 are runs on `/home/jorgen/Projects/weight-tracker` that need the developer in the conversation; they are walked at acceptance, not by this build.

## Not here
- Writing tests where coverage is thin: the existing tests are taken as pinning the behaviour.
- Cross-cutting behaviours such as permissions, logging or units.
- Mutation testing.
- The `CODING_STANDARDS.md` rule itself (a backlog item).
- Finding behaviours before understanding is lost (`find-code-before-understanding-is-lost.md`).
- Removing a rule's cases (`rule-cruft.md`).
- Changes to `run.sh`.
- An HTML page for the explanation.

## Left standing
