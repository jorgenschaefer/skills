# The manifesto states premises, roles and goals

The pipeline grew ad hoc: which stages it has, where it stops for the
developer, what the developer approves and is shown there, and what agents do
and check in between. The manifesto is meant to be the foundation the
pipeline is rebuilt on, but in its first version it can't carry that. Much of
what the pipeline rests on isn't in it: who does what and why, and what good
software is, which grew up in `CODING_STANDARDS.md` instead. What is in it is
often stated without the reason behind it, so it doesn't extend to cases it
doesn't list. What should be true instead: the manifesto and its reasons mark
out what a pipeline may be, with room for different designs, of which this
pipeline is one. For a choice in a skill, someone reading it can tell whether
the manifesto speaks to it at all; if not, the choice is the pipeline's own;
if it does, whether the choice fits, and if not, what would.

Instance: `/find-criteria` shows the developer how the code will be built,
"with the chance to object" (`find-criteria/SKILL.md:37`). Nothing in the
manifesto says whether that belongs in front of them: it is not on the
approval list, and the list gives no reason that would decide it.

Parked: which parts of `CODING_STANDARDS.md` are really coding standards
(`standard-follows-the-manifesto`).

## Tasks

Do each task in order. After each, a subagent with a fresh context reviews it against the task; work in what it finds.

1. Replace `MANIFESTO.md` with `specimens/MANIFESTO.md` in this directory, word for word.
2. In `CLAUDE.md`, line 3 becomes: "MANIFESTO.md states what software built by agents is for, who does what in building it, and why. Every skill serves it; read it before changing what a skill does." In line 5, "what the manifesto puts in front of a human" becomes "what the manifesto puts in bold"; the rest of the line stays.
3. In `.claude/skills/align/SKILL.md`: "law" becomes "goal" at `:22` ("even where a law would condemn it") and `:24` ("serves one law and costs another"). At `:59`, "Follow `MANIFESTO.md`'s \"After implementation\" list" becomes: report the items the manifesto puts in the report - evidence, decisions the plan didn't cover, blast radius and revert, tradeoffs, new dependencies, what was hard to change - leaving out what is empty. At `:67`, "all but its premise: agents write and read the code" becomes "all but its first premise: humans do not read the code".
4. In `accept-criteria/SKILL.md:87`, "the law at risk" becomes "the goal at risk"; "law of the standard" in `implement/SKILL.md` and `accept-criteria/SKILL.md` means `CODING_STANDARDS.md` and stays. In `README.md:205`, "the sections the manifesto gives a report after implementation" becomes "the items the manifesto puts in the report".
5. In `changes/backlog/*.md`, re-point every quote of `MANIFESTO.md` that is not in the new text. These are known:
   - `approved-criteria-outlive-the-change.md:13`, "Changing anything the human approved is the human's decision": quote "Changing anything they approved is theirs to decide."
   - `approved-criteria-outlive-the-change.md:15` and `critical-user-journeys.md:63`, "A test for anything the human approved counts only if it fails when the code breaks it, and that is checked on every change": quote "A check for anything the developer approved counts only if it fails when the code breaks it, and that is confirmed on every change".
   - `approval-follows-the-manifesto.md:21`, "Not how it is stored": now follows from "How the code is built is not theirs to judge (1)."
   - `find-code-before-understanding-is-lost.md:49`, "No report of what was hard to change is acted on in the change that wrote it ...": quote "They decide what is done about what was hard to change; the change that found it does not act on it."
   - `reviewer-shares-the-authors-lens.md:8`, "Reviewers use different framings ...": the sentence left the manifesto for `method-layer` (task 7); the item now rests on premise 3, "Whoever made a mistake shares the blind spot that made it."

   For any other: where the new text makes the same point, quote the new sentence; where it does not, say in a few words where the point went - the premise it now follows from, `standard-follows-the-manifesto` for a code rule (task 6), `method-layer` for a process rule (task 7). One that fits none of these is a decision the plan didn't cover: leave the quote and report it.
6. In `changes/backlog/standard-follows-the-manifesto.md`, list the code rules that left the manifesto and that the standard does not state yet: the boy scout rule and its conditions (it changes nothing the developer approved and follows the idioms already there; anything larger is a change of its own); "What a fresh agent finds with one search or in one file needs no documentation"; test the constraint, not the decision it led to; a contract test or benchmark where a test environment can't see a constraint; "Only what remains is written down"; a mistake fails where it is made, not where it shows up. YAGNI, KISS, colocation, searchable names, invalid states and one way to do each thing are already in the standard and need no entry. Note that the standard still says "laws" where the manifesto now says "goals".
7. Add `changes/backlog/method-layer.md` (effort L, utility M), in the shape of the other items, from the "What came up in discussion" bullets of the `layered-manifesto` item (`git show ced93f2:changes/backlog/layered-manifesto.md`): the second layer is a process document - stages, stops, evidence, reports, which applies only in the pipeline - beside the code standard, which applies wherever `implement` fires; each layer is copied into the skills that use it, cheap for a small manifesto but not for the 262-line standard; skill steps cite the layer above by its wording and `test.sh` checks the cited text exists, a step that applies a principle cites it, an operational one (a size threshold, the form of the `Check:` line) cites nothing, and one that is neither is a candidate to cut; the method says what must hold across stages - what each produces, who checks it, what reaches the developer - and a skill how its own stage does it. Add as an alternative for the citations: short fixed ids for the manifesto's rules that skill steps name. Open the item with the question it starts from: whether citations are needed at all, settled by first holding the new manifesto against a few real skill choices. List the process rules that left the manifesto, as task 5 finds them, among them "Reviewers use different framings, which reduces the blind spots they share with the author but does not remove them", with a pointer to `reviewer-shares-the-authors-lens`.
8. Re-point the backlog items that depend on `layered-manifesto`:
   - `docs-only-what-the-code-cannot-show`, `repo-setup-and-orientation`, and `standard-follows-the-manifesto` for its method-layer half: depend on `method-layer` instead.
   - `retro-for-the-manifesto`: drop the dependency.
   - `deployment-checklist`: drop the dependency, and note that what the report shows is now the bold items in the manifesto, and deployment steps fall under blast radius and revert ("what a revert would not undo").
   - `approval-follows-the-manifesto`: drop the dependency, and note that what the developer approves is now the bold items in the manifesto's developer lines, and "How the code is built is not theirs to judge" rules out the nudges.
9. `./test.sh` passes. Commit tasks 1 to 4 together; in the commit body, quote the two sentences of the new manifesto that decide `find-criteria/SKILL.md:37`: "How the code is built is not theirs to judge (1)." and "What is in bold below is what goes in front of them, and nothing else." Commit tasks 5 to 8 separately.
10. Spawn a subagent with a fresh context and give it only the problem statement above and the changes these tasks made, with this prompt: "Do these changes solve this problem? Report first what concerns the changes as a whole, then each finding with the change it concerns." Work in what it finds.
