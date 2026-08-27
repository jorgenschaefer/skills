# Ideas

The parking lot. Work worth doing that no current feature covers, each with
enough context to resurrect it: the problem, why it is not being built now, and
what it would touch. `/discovery` reads this at the start of a feature and
raises what fits, because a parking lot nobody revisits is a slower way of
forgetting.

The build list that rebuilt this pipeline lived here until it was finished. It
is in git history at commit `cfbd959` and the twenty commits before it.

---

**`/cleanup-repo` should produce a spec or tickets.** *To be discussed.* It
stops at a plan a human applies by hand, which is the one thing the maintenance
lane exists to stop: work nobody outside the code can observe goes through the
same build and the same reviews rather than around them. What it should emit is
the open question - a spec, where a cleanup is large enough to want decomposing,
or a set of maintenance tickets directly. Deferred until that is settled.
*Touches: cleanup-repo/SKILL.md, and possibly the maintenance ticket kind in the
five `TICKET_FORMAT.md` copies.*

**`/check-against-spec` should fail when it cannot drive the app.** It is the
acceptance: it drives the running feature the way a user would, and falls back
to code and test evidence only where nobody could drive it. Today a run where
*nothing* can be driven - the permissions do not cover starting the app, or the
project has no way in - degrades quietly into the reading the step was rewritten
to replace. A whole run checked on evidence should end the run somewhere other
than clean. The number is now in front of the driver rather than only in the
prose: the acceptance's verdict line closes with how many criteria it fell back
on, and nothing reads that field yet. What it cannot say is how many there were
altogether, so the threshold - all of them, or more than the handful the skill
already calls a finding of its own - is the open question.
*Touches: loop.sh, tests/run.sh, and possibly the verdict line's fourth field.*

**`ARCHITECTURE.md` needs a second reader.** `/repo-overview` writes it,
re-derived from the code and never hand-patched. `/discovery` now reads it in
its first phase, as a lead rather than as truth - it is only as current as the
last run, and the code settles anything the two disagree on. The other obvious
reader is `/spec-to-tickets`, which reads the structures the spec names before
splitting along them, and it still does not.
*Touches: spec-to-tickets/SKILL.md.*

**A step that reverts the working tree has no safe way to do it.** No step
does any more - the acceptance's fallback, which ran the branch's tests against
`main`'s code, is gone - but the two halves under it outlived their example and
are what the entry is now for. The run of 2026-08-27 on `kh` reverted by hand
in the live tree, because the two idioms that isolate it - `git worktree add`
and `git checkout main -- <paths>` - are both denied by the auto-mode
classifier with nobody there to approve either: ten source files copied to
`/tmp`, overwritten from `git show main:...`, one moved aside, the suite run,
then copied back. Non-atomic and outside git, in a step whose whole retry
ladder exists because sessions die. Two halves, settleable separately: which
commands an unattended run needs standing permission for, and whether the
driver should refuse to carry on over a tree a non-build step left dirty. The
second is the half that still bites without any reverting at all - the driver
reads the tree only under `tests/workflows/`, so a step that leaves it dirty
for any reason reaches `accept.sh` as a refusal nobody saw coming.
*Touches: loop.sh.*

**The reviews inside a ticket cannot see what the ticket proved.** `## Record`
is written in `## Finish`, after both reviews have read the work, so a reviewer
asked to judge a ticket against its own record is judging a section that cannot
exist yet - and the reviewer's sandbox blocks tools the builder used, so it
cannot re-run the evidence either. In the 2026-08-27 run both fired on ticket
01 at once: a blocker claiming the C-4 walkthrough had not run and no `Record`
existed, neither answerable from where the reviewer stood. The builder
adjudicated it away, correctly, and that is the cost - not the round, but a
builder getting practice at talking a blocker down, which is the failure the
adversarial review exists to prevent. Open: whether the evidence moves to the
reviewer - `Pinned by` and the decision log written before the reviews, the
verification output handed over with the diff - or the reviewer moves to the
evidence.
*Touches: implement/SKILL.md, and the order of its `## Review it` and
`## Finish`.*

**The review's fix is what the next review finds.** `/critique` reads the
branch whole, files what it finds, and re-reads only that. The 2026-08-27 run
filed ticket 09 on the first read; the second read found the collision ticket
09 had just created, and filed ticket 10. There is no pass after that, so the
run ended `requires human review` over a comment-only fix that wanted nothing
from a human but another pass. Re-running drains it, at the price of a whole
second run - `critique-1` re-reads the branch from its start - and `MAX_RUNS`
is two. Deliberately out of scope of the stop-reason defect, which was about
what an ending says rather than which endings there are. Open: a third read
scoped to what the second filed, or a fourth ending that names re-running as
the answer instead of asking for a decision nobody has to make.
*Touches: loop.sh, tests/run.sh, README.md's three endings.*

**Nothing in a run can file a finding about the repository.** The mockup under
`docs/spec/mockups/` is referenced from the committed spec and has never been
added to git. Tickets 02 and 03 left it open, the acceptance reported it
without filing - no criterion, constraint or non-goal names it, so it fails the
destination test - and `/critique` declined it too, because a file with no git
object is in no diff. Four gates saw it, all four declined correctly, and it is
still there two runs later. The class is wider than the file: anything true of
the repository that is neither in the diff nor named by the spec is visible to
every gate and filable by none. The cheap half is `accept.sh`, which already
refuses on ignored files under the spec directory and could refuse on untracked
ones the same way - today it deletes the spec and leaves behind the mockup that
spec references, which is the outcome its own comment says the deletion exists
to prevent. The rest is the open question: which gate, if any, owns the branch
being self-contained.
*Touches: accept.sh, and whichever of check-against-spec/SKILL.md or
critique/SKILL.md takes the destination.*

**A ticket that changes no behaviour still pays for the whole apparatus.**
Ticket 10 of the 2026-08-27 run changed eight comments and cost thirty minutes,
fifty-one turns and $8.44: a RED-first test, the mutation-gate deliberation,
two peer-model subagent reviews, a `Record`, two commits. Ticket 09 was $6.65
for glossary prose. Between them the two tickets the review filed were an
eighth of the run's cost. The apparatus is not wrong - the collision was real
and the test written for it pins it - but it is priced for a criterion, and a
remediation ticket with no `Satisfies` may not want all of it. Which parts a
behaviour-free ticket can skip without the maintenance lane becoming the way
around the reviews is the question, and it is the one `/cleanup-repo` above is
already deferred on.
*Touches: implement/SKILL.md, implement-ticket/SKILL.md.*

**The run inherits its permission mode and never records it.** `step_flags`
sets a model and an effort for each kind of step and no permission mode, so
what an unattended run may do is whatever the operator's ambient configuration
happened to say. On 2026-08-27 that was auto mode, which tells an agent to
prefer the shell over the file tools: across nine builds, 1382 Bash calls
against 12 `Edit` and one `Write` - 289 heredocs, 266 `python3` scripts
rewriting source files in place, 70 `sed -i`, 150 `cp` backups. Re-emitting
whole files is most of why the builds were $121.82 of the run's $129.36, and it
means the same invocation of `loop.sh` behaves differently on another machine.
Naming the mode in `step_flags` and printing it beside the log path settles the
recording; which mode is right for a run with nobody watching is the decision.
*Touches: loop.sh.*

**Make `/implement` generic.** It is the craft skill - RED-first, the project's
checks, two adversarial reviews, bounded attempts - and none of that is about
tickets. But it still reads like the loop's builder: `Satisfies`, `spec_hash`,
`Preconditions`, `Out of scope`, `Record`, `status: done`, four halt codes, and
a description that only fires for a ticket. So the most common implementation
task in any project reaches it only if somebody types the name.

It should take a requirement in whatever shape it arrives - a ticket, an issue,
a paragraph, a failing test - and build it to the same standard, on one
condition: the requirement is specific enough that nothing has to be guessed.
Where it is not, the rule already in the skill holds - never build past an
ambiguity - and C1's split says what happens next varies with who is present.
**Open: what the default is for a caller that says nothing.** Asking is right
with a human there and wrong in a pipe; failing is safe and annoying. The
answer may be that a caller who supplies no resolution gets a question, and
that `/implement-ticket` remains the one that answers it with a halt.

Everything ticket-shaped moves to `/implement-ticket`: reading the frontmatter,
the hash check, the four halt codes, the `Record` it writes back, and staging
the ticket alone. What stays is what would be true of building anything -
which is the test for where each line belongs.
*Touches: implement/SKILL.md, implement-ticket/SKILL.md, and the description
that decides when either fires.*

**Skills that name a sibling skill do not install standalone.** `/critique` and
`/implement` both say "read the `coding-conventions` skill", and `/cleanup-repo`
cites its only-looks-dead list. Installed one at a time -
`npx skills add jorgenschaefer/skills@critique` - that instruction finds
nothing, so the skill most worth having on its own is the one that breaks.
Seven of the other skills name `coding-conventions` and three tell the agent to
read it whole. The shared format documents already have an answer: each
consuming skill carries its own byte-identical copy and `diff` is the parity
check. Open is whether the same answer fits a hundred-and-seventy-line standard
seven skills point at, or whether the dependency should be declared somewhere
instead of copied. Settle this before the rest of this list: every generic
skill below inherits it.
*Touches: coding-conventions/SKILL.md and the seven skills that name it,
README.md.*

**`coding-conventions` is stack-neutral except where it isn't.** Everything in
it travels - simple design, clarity, concurrency, cost at scale, accessibility,
changing what already runs, coverage, security, dependencies - apart from
`## Domain layering`, whose seams are a React/Next.js/Prisma/TanStack Query
write path naming Server Actions, Zod and Prisma types directly. Roughly
fifteen lines in a hundred and seventy, and the section a Go or Python project
would be most misled by, because the domain-naming rule underneath it is the
part that generalises. Open: whether the seams stay as a worked example marked
as one, or whether a stack-neutral core splits from a `coding-conventions-web`
beside it. That is a decision, not an edit.
*Touches: coding-conventions/SKILL.md.*

**`/handover` should stand alone as a pull request description.** What it does -
what this branch does now, how it works, what to look at first, what is still
uncertain, kept to a page - is craft with nothing to do with a run. Two things
tie it down: the instruction not to restate the mechanical half, which only
means anything while the driver is printing that half beside it, and the whole
`## Promote before the paper goes` section, which exists because `./accept.sh`
is about to delete the spec and the tickets. Both are conditional on a caller
that has paper, and with no caller saying so, neither applies. The best return
for the work on this list.
*Touches: handover/SKILL.md.*

**Three skills carry a pipeline tail they do not need.** `/critique` is already
written both ways - "where the review has requirements behind it… where there
are none, `coding-conventions` is the destination" - and only its closing two
paragraphs, on workflow-test authorisation and filing findings as remediation
tickets, assume a loop; both are already fenced behind "where the caller asks".
`/cleanup-repo` names one sibling skill. `/improve-skill` reads `loop.sh`'s
transcripts by name where any run transcript would do. One editing pass each,
and none of them changes what the skill does.
*Touches: critique/SKILL.md, cleanup-repo/SKILL.md, improve-skill/SKILL.md.*

**`/check-against-spec` has a generic acceptance skill inside it.** Drive it
rather than read it, the two ways a criterion fails, the test for where nobody
can drive it, the orphan sweep, the bar a gap has to clear -
none of that needs a pipeline. What does: criteria numbered `US-N.M` and
constraints `C-N`, journeys as the script, and an output that files tickets
into a queue. A generic version reports instead of filing, and needs a fallback
for a feature with no numbered spec behind it, which is most of them. After the
three above rather than before: it is a rewrite of the output half, not a
conditional.
*Touches: check-against-spec/SKILL.md.*

**`/upgrade-dependencies` is npm-only.** One paragraph of pipeline framing is
all that ties it to a run and dropping it is trivial; the genuine limit is the
other axis. `npm ci`, `npm update`, `npm outdated`, `ERESOLVE`,
`package-lock.json`, `.nvmrc`, `@types/node` and `engines.node` run through the
whole skill. Every ecosystem has the same three passes - baseline, the updates
the ranges already allow, then the majors one at a time - so the shape travels
and the commands do not. Either it is renamed for what it actually covers, or
the passes are stated once and the commands become the project's to establish,
the way `/implement` establishes its verification command.
*Touches: upgrade-dependencies/SKILL.md.*
