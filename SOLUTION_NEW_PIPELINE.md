# Solution: five acts, two of them the harness you are already in

## Intent

Two of them, which is why every tag below is qualified:

- `INTENT_PROCESS_COST.md` — the process costs more attention than it pays back.
  Tagged `cost:C-n`.
- `INTENT_WRONG_PROBLEM.md` — nothing establishes that the work solved the problem.
  Tagged `problem:C-n`.

They are independent problems with one answer here, which is a claim this solution has
to earn rather than assume: either could have been solved without the other. The full
design, with the reasoning behind each choice, is `NEW_PIPELINE_IDEA.md`; this file is
the buildable statement of it.

## Approach

Five stages, each emitting one artifact, each ending with a reviewer in a fresh
context that checks the artifact against what the stage was given:
`/idea → /solve → /slice → /implement → /accept`.

Two of those stages are not separate places to go. Slicing happens inside plan mode and
building happens inside auto mode, with their skills discovered by description rather
than typed — so the process is the path you were already on, and with no skills loaded
at all it degrades to plan mode plus auto mode producing a sane result. That is what
makes one door possible without making small changes pay for it.

Everything that has to hold when a session is dead or misbehaving — iteration,
ceilings, ticket claiming, drift detection, waiting out usage limits — lives in a
runner script outside every session. Everything that is judgement lives in a skill.

The artifacts are an unbroken chain of ids: `C-n` conditions in the intent, `AC-n`
criteria tagging the conditions they serve, tickets tagging and copying the criteria
they cover, tests naming the criteria, and a verdict walking the conditions back. The
chain is what makes absences mechanical to find and what lets the last stage judge
against the first.

## Behaviour

- **AC-1** `/idea` produces `INTENT_<TOPIC>.md`, whose `Done when` is numbered `C-n`
  conditions, each stated so it can later be checked true or false without asking the
  author what it meant. It ends by a person confirming they recognize their problem.
  *(problem:C-1, problem:C-2)*
- **AC-2** `/solve` produces `SOLUTION_<TOPIC>.md` with required `Accepted tradeoffs`
  and `Ruled out` sections, and acceptance criteria `AC-n` each tagged with the `C-n`
  they serve. Given prose instead of an intent file, it derives the conditions first,
  stops for confirmation, and only then forms an approach.
  *(cost:C-1, cost:C-3, problem:C-2)*
- **AC-3** `/slice` works out the slicing inside plan mode, and writes
  `tickets/<topic>/` only after the slicing is approved. Each ticket copies the
  criteria it covers verbatim. *(cost:C-1, cost:C-3)*
- **AC-4** `/implement` builds one ticket and commits; it never reviews its own work
  and never marks its own ticket done. *(problem:C-4)*
- **AC-5** `/accept` uses the finished feature, walks the `C-n` conditions, and emits
  `VERDICT_<TOPIC>.md` with a routing destination on rejection. It is the only stage
  that judges against the problem rather than against the previous artifact.
  *(problem:C-1, problem:C-3)*
- **AC-6** The runner drives `tickets/<topic>/` to completion unattended: it claims
  tickets, enforces the attempt and review ceilings from counters kept in the ticket
  files, refuses to start on the main branch, runs the bidirectional drift pre-flight,
  and waits out usage limits before resuming. *(cost:C-4, cost:C-5)*
- **AC-7** Every unattended stop is a named halt written into the ticket — `blocked`,
  `undecided`, `mystery` from a session; `exhausted`, `drift` from the runner — and is
  addressed to a person. *(cost:C-4, cost:C-6)*
- **AC-8** `/verify` performs every artifact review, as a subagent with a fresh
  context, against the stage's input only. *(problem:C-4)*
- **AC-9** Each artifact section has a named consumer, stated in the design: the intent
  is read by `/solve` and `/accept`, the solution by `/slice` and the runner's
  pre-flight, the ticket by `/implement` and `/critique`, the verdict by a person at
  the merge. A section nothing reads is removed rather than kept. *(cost:C-2)*
- **AC-10** Three mandatory human decisions per change, fixed regardless of how large
  the change is: recognize the problem, approve the slicing, read the verdict and
  merge. Every other interruption is a named
  conditional — an `undecided` interrupt, a halt, raising a ceiling, abandoning, or a
  re-slice approval. *(cost:C-6)*
- **AC-11** On acceptance the paper is deleted in one commit, after promoting anything
  durable. The verdict survives and doubles as the pull request description.
  *(cost:C-2)*
- **AC-12** The coding standard is its own skill, fires whenever code is written rather
  than only under a ticket, and contains no design guidance. *(cost:C-2)*
- **AC-13** A software-design skill carries domain language, module boundaries and what
  deserves an ADR, surfaces while a change is being planned, and writes a ratified ADR
  at plan exit while the argument for it is still in context. *(cost:C-2)*
- **AC-14** Every skill and script the new pipeline replaces is deleted, in one commit,
  after the pipeline has been run end to end once. Nothing is left behind that a person
  or a model could invoke by mistake. *(cost:C-1, cost:C-3)*
- **AC-15** `/critique`, in a session of its own, reviews each commit against the ticket
  it was built from, and writes what it wants changed into that ticket. *(problem:C-4)*

## Edge cases

- **Prose in, no intent file.** The conditions-and-constraints block inside the
  solution *is* the intent. A verdict routing back to (a) promotes it into a real
  intent file, because a problem statement under revision deserves its own document.
- **The solution changes mid-run.** The runner's pre-flight stops the run; unbuilt
  tickets are re-sliced through plan mode and a second approval. Committed tickets are
  immutable, and a committed ticket that has drifted is a person's decision.
- **A build surfaces a decision the constraints are silent on.** `undecided` halt. The
  session cannot ratify a constraint, so it stops.
- **A session dies mid-ticket.** The runner resets `doing → ready`; sessions never
  claim or release their own work.
- **A condition turns out to be uncheckable.** The verdict marks it `unverifiable` and
  routes back to (a). It is a defect in the intent, not in the work.
- **A topic is dropped.** `/accept --abandon` waives the every-ticket-done check, and
  only that one, and records why.

## Non-goals

- Code quality of the output. `/critique` and the coding standard own the standard
  itself, and this solution does not change what either of them considers good code.
  It does move things: `coding-conventions` splits by when it is read (AC-12, AC-13),
  and `/critique` gains a mode — reviewing a commit against a ticket — which is a
  different claim from rewriting either of them.
- Multi-repo, multi-person, or parallel topics beyond "one topic per branch".
- Migrating the old `*_MERGE_LANES.md` paper. It was deleted in `267625a` and lives in
  git history, which is what the archive constraint says is enough.

## Accepted tradeoffs

- **No memory across topics.** Nothing models the domain or records decisions unless
  the design skill judges there is something worth writing and a person ratifies it. A
  run of small changes leaves no trace. Accepted because the old pipeline wrote all of
  it down every time and never established that it helped — the cost of finding out is
  lower than the cost of continuing to pay.
- **Discovery is stochastic.** `cost:C-3`'s single door rests on skill descriptions
  matching the right requests, and measurement says they mostly do: one prompt in the
  trial fired 3 times of 4. Accepted, because a miss degrades to an ordinary plan and
  announces itself by producing no tickets — but it means the door is reliable rather
  than guaranteed, and the figure was measured with no other skills competing.
- **The quality ceiling is whatever `/solve` proposes first.** The reviewer is a
  validator, not a selector: it can find an omitted cost but cannot know a better
  solution existed. Accepted in exchange for the middle running unattended.
- **Written tickets are a transcription of what was approved**, verified only by the
  runner's pre-flight rather than at the moment of writing.
- **More moving parts in the runner**, which is a script and therefore the least
  pleasant thing here to change.

## Ruled out

- **Adapt the existing pipeline: prune the unread sections, keep the skills.** Cheaper
  and lower-risk, and it was the obvious move. It loses because the door problem and
  `problem:C-1` are structural, not editorial: `/check-against-spec` compares the feature to the
  spec by construction, and no amount of pruning makes it ask whether the spec answered
  the right question. Pruning also requires knowing which sections are unread, which is
  the thing nobody knows.
- **Drop the pipeline entirely — plan mode, auto mode, and the coding standard.**
  Satisfies `cost:C-1`, `cost:C-3` and most of `cost:C-2` immediately, and a serious
  option. It loses the whole of `INTENT_WRONG_PROBLEM.md` and `cost:C-4`: nothing
  writes the problem down, so nothing can check against it, and nothing bounds an
  unattended run. It is the right answer for a one-line fix, which is
  why the design degrades to exactly this rather than forbidding it.
- **Keep `spec_hash` and citing tickets.** Proven machinery, and it solves the mid-run
  edit problem. It loses to self-contained tickets, which solve the same problem by
  making it impossible rather than detectable — a ticket carrying its own criteria
  cannot be redefined from a distance.

## Open concerns

- Neither intent is ratified, so every tag above is a claim about a target that may
  move. `INTENT_WRONG_PROBLEM.md` is the weaker of the two: it was inferred rather than
  reported, and if it turns out not to be the customer's problem, roughly a third of
  this solution answers a question nobody asked.
- `ubiquitous-language-init` has no decided place.
- `/verify`'s per-stage contracts are described but not written; whether one skill can
  carry four contracts without becoming four skills in a trenchcoat is untested.
- The runner is the largest single piece of new work and the only part the third review
  refused to call ready before its session boundary was pinned down. It is now pinned,
  and still unbuilt.
