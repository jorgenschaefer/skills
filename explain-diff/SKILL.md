---
name: explain-diff
description: Explain a git change - the commits between two refs, a branch or a PR - so the developer can own it without reading the diff, as a local HTML page. Use on "explain this diff", "what changed between X and Y", "walk me through this branch", "help me understand this change". It explains and does not judge; a review is critique's.
---

# Explain diff

Explain the change between two refs so the developer can say in good conscience that it is a good change, without reading the diff, in a page short enough that they read it to the end.

## The range

Explain `A..B` as given. With one ref, it is `<ref>..HEAD`. With none, it is the merge base with the default branch `..HEAD`. Say which range you took when it was not given whole.

## Facts first

Run `facts.sh <A> <B>` from this skill's directory, in the repository. Its header says what each line means. Every line it prints is accounted for on the page: a `decision` file in section 4 or 6, a `deleted` file wherever its rule went, a `tests` line with removed declarations or added skips in section 5.

**Read every file at B, through `git show <B>:<path>`**, and the old version at A. When `facts.sh` says `worktree not at B`, the files on disk are not the change.

**The claim** is what the change said it would do. Read, in this order: the `claim` files (`CRITERIA.md`, tickets, `REVIEW.md` of a pipeline change, at the commit `facts.sh` names), then the commit messages, then a PR description if there is one. Where there is none, the page says "no stated intent; inferred from the code", and section 1 is your reading of the code.

Read every non-test file of the diff in full. Read tests by their names, and in full only where section 5 needs it.

## The page

Copy `page.html` from this skill's directory to a temporary directory outside the repository - the session's scratchpad where it has one - and fill it in. It is a local file only: the code it quotes stays on the machine. Write in the user's language, and use the project's domain terms as the code and `UBIQUITOUS_LANGUAGE.md` spell them.

**Every claim carries its evidence** as a reference: `data-f="path:line"` for a line at B, `data-a` for one at A, `data-c` for a commit. Something taken from a document without checking it in the code says so ("per `REVIEW.md`"). Something inferred says so.

**A section with nothing to say says so in one line** ("no migration, no schema change"). That a section was checked is information; a missing section is not.

**The whole page reads in five minutes.** No section longer than a screen. Where the range mixes unrelated changes, the summary says so first and names the groups.

The header names the range, commits, files and lines changed, and where the claim came from. Then a summary of at most five sentences: what the change does for a user, and what it leaves alone. Then the seven sections.

1. **Intent and workflow.** The claim in two sentences, with its source. The happy path as numbered steps a user takes, with the real URLs, commands or screens, each with a reference. The failure path in one or two sentences. Claim vs. code: only where they differ, including a claim document that a later commit made out of date. What changes for existing users, from comparing A with B: changed defaults, moved or removed pages, options and buttons, messages, rules that got stricter or looser.

2. **Structure.** An SVG graph of the changed modules only, in three columns (entry points, logic, data) using the template's boxes and edges. Each box has the module name and what it does in at most five words. Arrows go between logic modules and to data. An entry point's direct reads go in its box text rather than in arrows across the graph. Unchanged modules appear only where a changed one depends on them, dashed. Below the graph, one sentence per module: what it does, including what a caller has to know (a return value that changed, a parameter it requires). Then one line for what the graph leaves out. A module that needs more than five words probably does two things: name it in section 6.

3. **Security and access.** A table of every entry point the change adds or alters, with the guard in front of it and a reference. Then which data a user can now reach that they could not before, whether any redirect or outgoing call takes its target from user input, and which test pins the guards. End with one line: what got looser, or "Looser than before: nothing found."

4. **Stored and wire formats, hard to reverse.** Database migrations and what they do to existing rows; dependencies added or upgraded; APIs, URLs, file formats, configuration and environment variables; data the change writes that the old code cannot read. End with one line: whether a revert undoes the change completely, and if not, what it leaves behind.

5. **What the tests pin.** A table: each behaviour that sections 1, 3 and 7 name, and the test at B that pins it, or "no test". Write this section last. Below it, in a few lines: tests deleted, declarations removed without replacement, and skips added, each with what it covered. And whether you ran the project's check or are citing someone who did.

6. **Precedents.** What the next change will copy: a new pattern, a new dependency direction between modules, a second way of doing something the codebase already does. Something inconsistent whose weight you cannot judge gets one line.

7. **Surprises.** At most five, ranked by consequence: what a reader of sections 1 to 4 would not predict. For every rule the change replaces, read the deleted code at A and compare: a rule that got looser or stricter without the claim saying so is the first candidate.

## Before you hand it over

Run `check-refs.sh <page> <A> <B>`. It fails on any reference to a file or line that does not exist at its ref, and on a page without references. Fix the page until it passes. It checks that a line exists, not that it is the right one: check that yourself for each reference in sections 1, 3 and 7.

Where a headless browser is available, render the page and look at the graph. Crossing edges that make it unreadable are fixed by moving boxes, or by moving a reference into box text, not by adding more arrows.

## Handing it over

Reply with the page's absolute path. Nothing else is needed: the page is the report.

The conversation may go on. Answer questions about the change the way the page is written: with a reference at B for every claim, and inference marked as inference. Where an answer shows that the page is wrong, fix the page and say so.
