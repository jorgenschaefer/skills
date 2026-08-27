---
id: 01
status: done
depends_on: []
---

# Stop telling every build to run a mutation gate

## Why

The pipeline mandates a mutation-testing gate at every ticket and a whole-run
sweep at acceptance, and neither has ever run: all ten tickets of the
2026-08-27 run recorded that no mutation testing tool was configured, and the
one attempt to configure Stryker for real saturated the machine (the operator's
account; the repository records only the ten `Left open` entries, at
`IDEAS.md:106-113`). The cost is paid every ticket regardless - prose in four
files, a deliberation in every build, a sentence appended to every build's
prompt, and an acceptance fallback that reverts the working tree by hand in a
way no unattended run can do safely.

What the gate was for survives it, in two places that already exist.
`implement/SKILL.md`'s `### Prove the contract before the reviews see it`
already breaks each claimed behaviour and watches the named test fail, in a
build, where editing the tree is legal. `check-against-spec/SKILL.md:30` already
requires the acceptance to name, for every criterion it drove, the test that
would fail if the behaviour were deleted - and `:97` already routes a criterion
it cannot name to a remediation ticket, whose build does the breaking. So the
run-scope case the gate's sweep existed for - a behaviour one ticket pinned and
a later ticket quietly unpinned - keeps a path that ends in execution, without
the acceptance itself ever editing source.

## Satisfies

- **Given** the skills as installed, **when** the repository's own suite runs,
  **then** no skill instructs a build or an acceptance to run a mutation
  testing tool, to read surviving mutants, or to report such tooling as
  missing.
- **Given** an unattended run driving a build for a ticket, **when** the driver
  composes that build's prompt, **then** the prompt instructs the build only to
  build the ticket, and carries no instruction to run a mutation gate nor to
  report missing mutation tooling.

## Preconditions

- None. Nothing was built before this.

## Touches

- `loop.sh` - `implement_prompt` loses its mutation paragraph and returns the
  `/implement-ticket` line alone. Of the comment above it, only the four lines
  about the gate go; the four about `status` being the signal rather than the
  exit code are what `drain()` reads and stay.
- `tests/run.sh` - the assertion that the build prompt carries the
  installing-is-a-ticket-of-its-own sentence becomes an assertion that the
  prompt carries no mutation instruction at all. It currently matches only the
  paragraph's second sentence and its needle names no mutation word, so
  inverting it alone would leave the first sentence pinned by nothing; both
  limbs of the criterion need covering. The neighbouring assertion that the
  prompt does not authorise a build to change the project guarded a sentence
  that is going, and over a one-line prompt it pins nothing - delete it. *A
  default: keep it if a future prompt is expected to grow an authorising
  clause.*
- `tests/run.sh` - a new assertion over the skills' own text, pinning the first
  criterion. The shared-files block that checks the five `TICKET_FORMAT.md`
  copies are byte-identical is the precedent and the place for it; one
  repository-wide check, not one per file.
- `implement/SKILL.md` - `### The mutation gate` is deleted whole. `### Prove
  the contract before the reviews see it` gains boundary perturbation beside
  removal: breaking a behaviour means moving it as well as deleting it, since a
  test can notice a behaviour vanish and still pass when a comparison shifts by
  one, which is the case `coding-conventions`' rule that the edges of the input
  range are pinned exists for. It attaches to both branches of that section -
  the criterion proved by a RED run as much as the one proved by hand - because
  a RED run proves the test noticed the behaviour arriving, not that it would
  notice the boundary moving.
- `check-against-spec/SKILL.md` - `## Check the tests mechanically, not by
  reading` is deleted whole, the revert-the-tree fallback and the file-a-ticket
  -for-tooling paragraph with it. Nothing takes its place: the second of the
  two ways a criterion fails is already answered where it is raised, and the
  route from there to execution is already the remediation ticket.
- `check-against-spec/SKILL.md` - three references outside that section, each
  of which stops making sense once it goes: the scoping paragraph that treats a
  ticket whose `Record` shows the gate ran as already checked by execution, and
  which should read on the pin check instead; the `Gaps reported` output field
  that offers "a mutant with nothing behind it" as its example; and the second
  failure mode in the two-ways list, which the deleted section opened by
  naming.
- `README.md` - the first clause of **Checks that execute rather than judge**.
  The principle holds and stays. Its remaining two examples - driving the
  feature, and workflow tests in the project's check command - already execute;
  the clause describing the gate is replaced by the per-ticket check that does.
- `IDEAS.md` - "The mutation gate is re-decided on every ticket" is dissolved
  and goes. "A step that reverts the working tree has no safe way to do it"
  keeps both open halves - which commands an unattended run needs standing
  permission for, and whether the driver should refuse over a tree a non-build
  step left dirty - and loses the mutation fallback as its example and from its
  `Touches` line; if nothing else in the repository still reverts a tree, say
  in the entry what now motivates it. The entry on extracting a generic
  acceptance skill lists the mutation gate among what would travel; re-cut that
  list. The behaviour-free-ticket entry cites the mutation-gate deliberation as
  part of what ticket 10 paid for; it is evidence about a past run and stays as
  written.

## Out of scope

- Any project's mutation testing configuration. Nothing is installed, removed
  or configured in any repository this pipeline builds. This changes what the
  skills ask for and nothing else.
- `check-against-spec/SKILL.md:21` - the rule that the acceptance leaves the
  tree as it found it. It is what makes the deleted fallback unsafe and it is
  why nothing executed replaces it at run scope. Do not weaken it to make room
  for one.
- `critique/SKILL.md`'s coverage-map paragraph, including its aside that you do
  not need to mutate code because the mapping is the check. After this ticket
  the acceptance is a mapping check too, so the aside agrees with its siblings
  rather than contradicting them.
- `check-against-spec/SKILL.md:97`, the remediation-ticket paragraph. It
  already prescribes break-watch-restore and is the step this ticket relies on;
  leave its wording alone.
- The gate itself, while this build runs. `implement/SKILL.md` still carries
  `### The mutation gate` when the build starts, and the build is bound by the
  skill as it stands - so record what every ticket before it recorded, one last
  time, and delete the section as the work rather than as a way out of obeying
  it.
- The parked question of what a behaviour-free ticket may skip
  (`IDEAS.md:116`). Related, separately settleable, and "while I'm here" is the
  material this kind of change goes wrong on.

## Verification

- The first criterion is pinned by asserting on the skills' text rather than on
  runtime behaviour, which is what `TICKET_FORMAT.md` prescribes for a criterion
  over a document. It owns the whole prose deletion; the per-file edits are not
  separately pinned.
- The second criterion is pinned in `tests/run.sh` against the driver's
  composed prompt, and needs assertions covering both limbs rather than the one
  that exists.
- The text assertion has to exempt this ticket, `IDEAS.md`'s surviving entries
  and git history, all of which name the gate legitimately. Tickets are
  committed with the code, so an unexempted repository-wide check passes only
  until the ticket is staged.

## Record

**Commit:** 1155583

**Pinned by:**
- Criterion 1 (no skill asks for a mutation testing tool) - `tests/run.sh`,
  "no skill asks a build or an acceptance to run a mutation testing tool".
  RED first: it named `check-against-spec/SKILL.md` and `implement/SKILL.md`
  before either was edited. Proved again by planting a mutation instruction in
  a single untouched skill, and by the two tools the first regex missed
  ("PIT's incremental mode", "Infection"), each of which passed before the
  regex was widened and fails now.
- Criterion 2 (the prompt asks for the ticket and nothing else) - `tests/run.sh`,
  "a build is asked for the ticket and for nothing else". RED first against the
  old prompt. Proved on both limbs plus the "only": reintroducing just the
  first sentence fails it, and so does an added line naming Stryker but not
  containing the word "mutation", which the original needle let through.

**Decisions:**
- **[medium]** Facing a tripwire that had to exempt the places naming the gate
  on purpose, scoped it to every `*.md` with `--exclude=IDEAS.md
  --exclude-dir=tickets`; rejected scoping to `*/SKILL.md`, which needs no
  exemptions but leaves the five `TICKET_FORMAT.md` copies unwatched - and a
  build reads those as part of the skill - `tests/run.sh:907`.
- **[medium]** Facing three prompt assertions where the criterion says "only",
  replaced them with one exact-equality check on the whole prompt; rejected
  adding a fourth needle, which cannot express "only" - `tests/run.sh:645`.
  Consequence worth knowing: any legitimate future line in the build prompt now
  fails a test by design, which is the criterion working rather than a brittle
  test.
- **[medium]** The ticket's default said to delete the now-vacuous
  `expect_no_prompt "authorised"`. I overturned it, arguing its neighbour
  `expect_no_prompt "quality review"` was equally vacuous. The quality review
  showed the evidence was false: the case sets `REVIEWS=code` as bait, an env
  var `loop.sh` never reads, so the neighbour is armed and `authorised` was
  armed by nothing. Overturn withdrawn, ticket's default applied.

**Unresolved:**
- **[low]** Code review: `expect_no_prompt /implement-ticket "quality review"`
  (`tests/run.sh:644`) is mechanically subsumed by the equality check beside it
  and should go on fewest-elements grounds. Kept: it is the only assertion that
  names what the `REVIEWS=code` bait tests, and the equality check is brittle by
  design - the day the build prompt legitimately grows a second line, the
  equality is rewritten and this is what still guards the property.
- **[low]** Code review: `\bpit\b` is a GNU-grep extension that silently never
  matches under BSD grep, disarming that needle rather than erroring. Kept: the
  suite is already GNU-bound at four other points - `md5sum`, coreutils
  `timeout`, `prompt_for`'s multi-character `RS`, and `sed -i` in the stub.

**Left open:**
- The mutation gate did not run on this ticket. This project has no mutation
  testing tool configured, and setting one up is a change to the project rather
  than part of this ticket. Recorded as the section being deleted required, one
  last time.
- The prose this ticket *adds* is pinned by nothing - deleting the "Break it
  twice" paragraph or the acceptance's new instruction fails no test. The
  ticket scoped this out and the repo has no mechanism for pinning prose
  presence, only prose absence.
- `tests/run.sh:312` - `expect_no_out "halted on"` went stale when `c495bc9`
  reworded halts to "<name> halted", so the case believes it has two guards and
  has one. Not this ticket's: it traces to no criterion here and is not coverage
  this ticket removed.
- `tests/run.sh:633` - `expect_no_out "tickets//"` is vacuous for its plan; the
  doubled slash reaches the prompt, which the line above catches, and never the
  output. Arrived with `f3f0424`. Same reason for leaving it.
- The tripwire scans only `*.md`, and the equality check covers only the build
  prompt. `check_prompt` and `critique_prompt` in `loop.sh` could grow a
  mutation instruction unseen. Neither ever carried one, so there was no
  removal here to pin.
- A review subagent ran `git checkout implement/SKILL.md` mid-review and
  discarded this build's uncommitted work, then reconstructed it from a diff it
  had captured; I verified the repair byte-exactly by hash before continuing.
  Nothing in the pipeline tells a reviewer the tree is not theirs to touch, and
  an unattended run would not have noticed. This is a finding about the
  pipeline rather than about this ticket, so it belongs in `IDEAS.md` and is not
  filed here.
