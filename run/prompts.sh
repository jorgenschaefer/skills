# shellcheck shell=bash
#
# What a session is told: the brief a build starts from, what a carried-on
# session is told on resuming, the question that finds the checks, and the
# brief of the final review. They are read together, because they have to say
# the same things the same way - what Left standing is, that the checks pass on
# the commit a session starts from.
#
# Sourced by run.sh, never run.

# The part protocol is stated here as well as in /implement-plan: the runner
# reads these statuses and halt kinds, so it says itself what it reads.
brief() {  # part -> the prompt a fresh session on it starts from
  local prompt t built=""
  # By its absolute path: a session runs wherever the runner was started, and
  # one in a subdirectory looked for a relative path at the repository root.
  prompt="Use /implement-plan on $(realpath "$1").

$(checks_said "The checks pass on the commit you start from, and a check that fails now failed because of this build. The runner runs both checks on your commit itself, so run only the fast check.")

That file is your part of the plan in $(realpath "$PLAN"). Its hard decisions were approved by the person; every other decision on the way is yours.

The journeys in journeys/ were approved before the build. Never change them: the runner stops the run on a build that does. Where the build cannot follow a journey as it is written, halt as \`departure\`.

When the work is done and the fast check passes, write into the file's \`## Left standing\` what /implement-plan says to leave standing. Nobody reads your closing message in an unattended run; Left standing is handed to the final review where there is more than one part, and read at acceptance. Set \`status: done\` in the frontmatter and commit the code, the file and any updates to the plan together, in one commit.

If you cannot proceed, append a \`## Halt\` section naming the kind and stop: \`departure\` (a hard decision or a hard test would have to change), \`blocked\` (a precondition the plan assumed is not there), or \`mystery\` (a failure you cannot explain, which is different from one you cannot fix). Then set \`status: halted\`.

Never write \`status: doing\`. It belongs to the runner."
  # A session reads its own part - so an item one build left standing for the
  # next is pointed at. Pointed at rather than extracted: a Left standing says
  # it in whatever shape its build chose.
  for t in "${PART_FILES[@]}"; do
    [ "$(field "$t" status)" = "done" ] && built+=$'\n'"- $(realpath "$t")"
  done
  [ -z "$built" ] || prompt+="

Parts of this plan already built:$built

Each one's \`## Left standing\` says what its build did not settle. Handle an item that falls inside this part's steps, and leave the rest."
  printf '%s' "$prompt"
}

# The split skill is hidden from the model, so a Skill call cannot load it. The
# CLI loads it where the prompt starts with its command, and hands the rest of
# the prompt to it as its arguments. Text before the command stops it loading.
split_brief() {  # -> the prompt the session that splits the plan starts from
  printf '%s' "/split-plan on $(realpath "$PLAN").

$(checks_said "The checks pass on the commit you start from.")

Nobody is watching: ask nothing. Where the skill says to halt, append a \`## Halt\` section to $(realpath "$PLAN") naming the kind, set its \`status: halted\`, commit it, and stop. Never write \`status: doing\`. It belongs to the runner."
}

# The ways a session is carried on rather than started over. The first two are
# read by the loop, the last by the final review.
# shellcheck disable=SC2034
STOPPED_EARLY="Your turn ended before the part was finished; what you did is still in the tree and in your commits. Carry on from there and finish as the brief said."
# shellcheck disable=SC2034
INTERRUPTED="The run was interrupted while you were working, and has been started again. Your uncommitted work is still in the tree. Carry on from where you stopped - rerun whatever was cut short, a subagent or a check included - and finish as the brief said."
# shellcheck disable=SC2034
REVIEW_STOPPED_EARLY="Your turn ended before plan.md was committed at \`status: done\`. Carry on from there - rerun a review that did not report - and finish as the brief said."

red_checks() {  # -> what a build's session is told when the checks fail on its commit
  printf '%s' "The project's checks fail on your commit $(git rev-parse --short HEAD): $RED. The runner set the part back to \`status: doing\`. Fix it, commit, and set \`status: done\` again.$(red_output)"
}

red_review_checks() {  # -> what the final review is told when the checks fail on its commit
  printf '%s' "The project's checks fail on your commit $(git rev-parse --short HEAD), after $(realpath "$PLAN") was committed at \`status: done\`: $RED. Fix it and commit, with the fix added to what you left standing in plan.md, among the fixes no reviewer saw.$(red_output)"
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

# A project with no checks yet gets them from a build, and the runner reads them
# from CLAUDE.md, so a build that sets them up has to declare them there.
checks_said() {  # what to say of the checks where there are some -> the paragraph a brief says them in
  if [ -z "$FAST_CHECK$SLOW_CHECK" ]; then
    printf '%s' "The project has no checks yet. Where this work sets up its tests, lint or type check, declare the one command that runs them all in CLAUDE.md, in the same commit, on a \`Fast check:\` line with the command in backticks. The runner runs it on that commit and on every commit after it."
  else
    printf '%s' "$(checks_named). $1"
  fi
}

checks_named() {  # -> the project's checks, named in a sentence without its full stop
  local fast="The project's fast check is \`$FAST_CHECK\`"
  [ -n "$FAST_CHECK" ] || fast="The project has no fast check"
  if [ -n "$SLOW_CHECK" ]; then
    printf '%s' "$fast, and its slow check is \`$SLOW_CHECK\`"
  else
    printf '%s' "$fast, and it has no slow check"
  fi
}

checks_question() {  # -> what the session that finds the checks is asked
  printf '%s' "Find this project's verification command: the one shell line, run from $(pwd), that runs everything a change here has to pass - tests, type check, lint. Where CI runs these, what CI runs is the authority. Name only a command that works on the code as it is now, not one a plan or a design describes: where the project has no checks yet, answer with no command. Do not run it and change nothing; answer with the command."
}

review_brief() {  # -> the prompt the final review starts from
  local t left standing=""
  for t in "${PART_FILES[@]}"; do
    left="$(left_standing "$t")"
    [ -z "$left" ] || standing+=$'\n\n'"$(basename "$t") left standing:"$'\n'"$left"
  done
  [ -z "$standing" ] || standing="

What the builds left standing is below. Among it are review findings a build did not fix, with the severity its reviewer gave each - one run's build left a blocker there, and its review found the same bug again. Every blocker and should-fix among them is yours to settle as you settle the review's: fix it - unless the fix would change a hard decision of the plan or what the journeys say, and then you leave it standing for the person. A fix a build made after its last review was seen by no reviewer: check each against the finding it answers, and settle one that is wrong or incomplete like a should-fix. Leave the nits and everything else for acceptance, and hand none of it to the reviewer.$standing"
  printf '%s' "Review the whole change this run built: \`git diff $(review_base)\`. The parts in $(realpath "$PARTS") built it, and each build was reviewed on its own - which cannot see what lies between them. Look for that: the same thing built twice, one concept under two names, seams between parts that do not line up.

$(checks_said "The checks pass on the commit you start from. The runner runs both checks again on your commits once your review is committed, so run only the fast check yourself.")

Spawn a subagent with a fresh context that uses \`review-code\`. Hand it the diff, $(realpath "$PLAN") as the spec it reviews against, and the result of the checks - the runner's last run of both checks, green on the commit you start from, or, once you have changed the code, your own run of the fast check - saying which it is. Not the parts or what their builds left standing, which are the reasoning behind the code. Evaluate what comes back, fix what is worth fixing, run the fast check and commit. A fix that would change a hard decision of the plan or what the journeys say is not made: you leave it standing for the person. Never change the journeys in journeys/: they were approved before the build, and the runner stops the run on a review that changes them. Then review again the same way. Two rounds at most: stop when the second round is done, or when a review comes back clean or with only nits.

Then write what you left standing into $(realpath "$PLAN"), under a \`### End review\` heading at the end of its \`## Left standing\`. It opens with what is still open once this review is done, a line or two each, each naming the part it came from or the review: what needs the person's decision first - every fix you did not make because it would change a hard decision of the plan or what the journeys say - then the rest, from what the builds left standing and from your own findings alike, most important first. Where nothing is open, it says \`Nothing.\` Below that, the rest: findings you did not fix and why, the fixes you made after the last review, which no reviewer saw, checks you did not run, and for your own fixes what a build leaves standing - read /implement-code for what that is. Set plan.md's \`status: done\` in its frontmatter and commit it. Nobody reads your closing message in an unattended run: plan.md's Left standing is read at acceptance, and the run counts the review as finished only once plan.md is committed at \`status: done\`.$standing"
}
