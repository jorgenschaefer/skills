# shellcheck shell=bash
#
# What a session is told: the brief a build starts from, what a carried-on
# session is told on resuming, the question that finds the checks, and the
# brief of the final review. They are read together, because they have to say
# the same things the same way - what Left standing is, that the checks pass on
# the commit a session starts from.
#
# Sourced by run.sh, never run.

# The chunk protocol is stated here rather than in the skill. `/implement-change`
# builds a change from its description and knows nothing about statuses or halt
# kinds. A runner that needs those has to say so itself.
brief() {  # chunk -> the prompt a fresh session on it starts from
  local prompt t built=""
  # By its absolute path: a session runs wherever the runner was started, and
  # one in a subdirectory looked for a relative path at the repository root.
  prompt="Use /implement-change on the work described in $(realpath "$1").

$(checks_named). The checks pass on the commit you start from, and a check that fails now failed because of this build. The runner runs both checks on your commit itself, so run only the fast check.

That file is the whole brief, with the journeys its frontmatter names. Its design was agreed with the person: build to it, and where it links a prototype, build to that. Its \`## Not in this change\` names what you must not build here. How to build it is yours to work out from the code, and so is every implementation question on the way: decide it, and record under \`## Left standing\` the ones /implement-change says to leave standing.

The journeys in journeys/ were approved before the build. Never change them: the runner stops the run on a build that does. Where the build cannot follow a journey as it is written, halt as \`undecided\`."
  is_split && prompt+="

Do not open $(realpath "$CHANGE"). The chunk carries what it needs, and going upstream is how a chunk quietly becomes a different one."
  prompt+="

When the work is done and the fast check passes, write into the file's \`## Left standing\` what /implement-change says to leave standing. Nobody reads your closing message in an unattended run; Left standing is handed to the final review where there is more than one chunk, and read at acceptance. Set \`status: done\` in the frontmatter and commit the code and the file together, in one commit.

If you cannot proceed, append a \`## Halt\` section naming the kind and stop: \`blocked\` (a precondition the design assumed is not there), \`undecided\` (behaviour the user sees that the design and the journeys do not settle), or \`mystery\` (a failure you cannot explain, which is different from one you cannot fix). Then set \`status: halted\`.

Never write \`status: doing\`. It belongs to the runner."
  # A session reads its own chunk and no other - so an item one build left
  # standing for the next was never seen by it. Pointed at rather than
  # extracted: a Left standing says it in whatever shape its build chose.
  for t in "${CHUNK_FILES[@]}"; do
    [ "$(field "$t" status)" = "done" ] && built+=$'\n'"- $(realpath "$t")"
  done
  [ -z "$built" ] || prompt+="

Chunks of this change already built:$built

Each one's \`## Left standing\` says what its build did not settle. Handle an item that falls inside this chunk's design, and leave the rest; this chunk's \`## Not in this change\` still holds."
  printf '%s' "$prompt"
}

split_brief() {  # -> the prompt the session that splits the change starts from
  printf '%s' "Use /split-change-into-chunks on the change in $(realpath "$CHANGE_DIR").

$(checks_named). The checks pass on the commit you start from.

Nobody is watching: ask nothing. Where the skill says to halt, append a \`## Halt\` section to $(realpath "$CHANGE") naming the kind, set its \`status: halted\`, commit it, and stop. Never write \`status: doing\`. It belongs to the runner."
}

# The ways a session is carried on rather than started over. The first two are
# read by the loop, the last by the final review.
# shellcheck disable=SC2034
STOPPED_EARLY="Your turn ended before the chunk was finished; what you did is still in the tree and in your commits. Carry on from there and finish as the brief said."
# shellcheck disable=SC2034
INTERRUPTED="The run was interrupted while you were working, and has been started again. Your uncommitted work is still in the tree. Carry on from where you stopped - rerun whatever was cut short, a subagent or a check included - and finish as the brief said."
# shellcheck disable=SC2034
REVIEW_STOPPED_EARLY="Your turn ended before REVIEW.md was committed. Carry on from there - rerun a review that did not report - and finish as the brief said."

red_checks() {  # -> what a build's session is told when the checks fail on its commit
  printf '%s' "The project's checks fail on your commit $(git rev-parse --short HEAD): $RED. The runner set the chunk back to \`status: doing\`. Fix it, commit, and set \`status: done\` again.$(red_output)"
}

red_review_checks() {  # -> what the final review is told when the checks fail on its commit
  printf '%s' "The project's checks fail on your commit $(git rev-parse --short HEAD), after $(realpath "$REVIEW") was committed: $RED. Fix it and commit, with the fix added to REVIEW.md among the fixes no reviewer saw.$(red_output)"
}

# Nothing where no check ran: a CLAUDE.md naming the fast check twice is red
# before either runs, and has no failure to fix.
red_output() {  # -> what a session handed red checks is told about fixing and running them, and what they printed
  local log
  [ "${#RED_LOGS[@]}" -gt 0 ] || return 0
  printf '%s' " Fix a red check like any other failure, and run the fast check while you fix it. Where the slow check is red, you may run it too, to confirm your fix. The last lines of what each red check printed are below."
  for log in "${RED_LOGS[@]}"; do
    printf '\n\n%s:\n%s' "$log" "$(tail -40 "$log")"
  done
}

checks_named() {  # -> the project's checks, named in a sentence without its full stop
  if [ -n "$SLOW_CHECK" ]; then
    printf '%s' "The project's fast check is \`$FAST_CHECK\`, and its slow check is \`$SLOW_CHECK\`"
  else
    printf '%s' "The project's fast check is \`$FAST_CHECK\`, and it has no slow check"
  fi
}

checks_question() {  # -> what the session that finds the checks is asked
  printf '%s' "Find this project's verification command: the one shell line, run from $(pwd), that runs everything a change here has to pass - tests, type check, lint. Where CI runs these, what CI runs is the authority. Do not run it and change nothing; answer with the command."
}

review_brief() {  # -> the prompt the final review starts from
  local t left standing=""
  for t in "${CHUNK_FILES[@]}"; do
    left="$(left_standing "$t")"
    [ -z "$left" ] || standing+=$'\n\n'"$(basename "$t") left standing:"$'\n'"$left"
  done
  [ -z "$standing" ] || standing="

What the builds left standing is below. Among it are review findings a build did not fix, with the severity its reviewer gave each - one run's build left a blocker there, and its review found the same bug again. Every blocker and should-fix among them is yours to settle as you settle the review's: fix it - unless the fix would change what the design or the journeys say, and then it goes under \`## For you\` for the person. A fix a build made after its last review was seen by no reviewer: check each against the finding it answers, and settle one that is wrong or incomplete like a should-fix. Leave the nits and everything else for acceptance, and hand none of it to the reviewer.$standing"
  printf '%s' "Review the whole change this run built: \`git diff $(review_base)\`. The chunks in $(realpath "$CHUNKS") built it, and each build was reviewed on its own - which cannot see what lies between them. Look for that: the same thing built twice, one concept under two names, seams between chunks that do not line up.

$(checks_named). The checks pass on the commit you start from. The runner runs both checks again on your commits once your review is committed, so run only the fast check yourself.

Spawn \`review-change\` as a subagent with a fresh context. Hand it the diff, the result of the checks - the runner's last run of both checks, green on the commit you start from, or, once you have changed the code, your own run of the fast check - saying which it is, and $(realpath "$CHANGE") and the journeys it names as what was asked for, and its problem as what the change is for - not the chunks or what their builds left standing, which are the reasoning behind the code. Evaluate what comes back, fix what is worth fixing, run the fast check and commit. A fix that would change what the design or the journeys say is not made: it goes under \`## For you\`. Never change the journeys in journeys/: they were approved before the build, and the runner stops the run on a review that changes them. Then review again the same way, except that in the second round the reviewer walks only the journeys the fixes since the first round touched - name them to it. Where the first round found only nits, fix the ones worth fixing, and review again only if one of those fixes changes what the user sees or gets back, or where an action leads. Two rounds at most: stop when the second round is done, or when a review comes back clean or with only nits and none of your fixes changed what the user sees or gets back.

Then write what you left standing to $(realpath "$REVIEW") and commit it. It opens with \`## For you\`: what is still open once this review is done, a line or two each, each naming the chunk it came from or the review. What needs the person's decision first - every fix you did not make because it would change what the design or the journeys say - then the rest of what is open, from what the builds left standing and from your own findings alike, most important first. Where nothing is open, it says \`Nothing.\` Below it, under headings of your own, the rest: findings you did not fix and why, the fixes you made after the last review, which no reviewer saw, checks you did not run, and for your own fixes what a build leaves standing - read /implement-change for what that is. Nobody reads your closing message in an unattended run: REVIEW.md is read at acceptance, and the run counts the review as finished only once that file is committed.$standing"
}
