# shellcheck shell=bash
#
# What a session is told: the brief a build starts from, what a carried-on
# session is told on resuming, the question that finds the checks, and the
# brief of the final review. They are read together, because they have to say
# the same things the same way - what Left standing is, that the checks pass on
# the commit a session starts from.
#
# Sourced by run.sh, never run.

# The ticket protocol is stated here rather than in the skill. `/implement` is
# the generic build skill - it fires when anyone asks for code and knows nothing
# about tickets, statuses or halt kinds. A runner that needs those has to say so
# itself, which is the cost of the skill staying general.
brief() {  # ticket -> the prompt a fresh session on it starts from
  local prompt t built=""
  # By its absolute path: a session runs wherever the runner was started, and
  # one in a subdirectory looked for a relative path at the repository root.
  prompt="Use /implement on the work described in $(realpath "$1").

The project's checks are \`$VERIFY\`, and they pass on the commit you start from. A check that fails now failed because of this build.

That file is the whole brief. Its \`## Done when\` is the definition of done - not the diff, not what you would have built, not what CRITERIA.md probably meant. Its \`## Nudges\` are how it was agreed this gets built: follow them, and where you depart from one, say why. Its \`## Not here\` names what a neighbouring ticket owns, and building it is two tickets building the same code. Its \`## Plan\` is how it was decided this gets built; where you find the plan wrong, say so rather than following it off a cliff.

A criterion the frontmatter's \`closes:\` names is true once this ticket is built: write its test first and red, where its user acts - the action, the route, the form - and make it pass. One under \`## Toward\` is built only in part here, and closed by a later ticket: prove the narrower behaviour \`## Done when\` states, and leave the whole criterion to the ticket that closes it.

Do not open the CRITERIA.md the frontmatter names. The ticket quotes what it needs, and going upstream is how a ticket quietly becomes a different one.

When the criteria are green and the project's checks pass, write the ticket's \`## Left standing\`: review findings you did not fix, with the severity the reviewer gave each, and why, checks you did not run, each criterion it closes or advances that no automated test proves and how you checked it instead, where you departed from the plan, and where you departed from a nudge, with the reason. Only those - a finding you fixed and a criterion a test proves are what \`done\` already says. Nobody reads your closing message in an unattended run; Left standing is printed at the end of the run where this is the only ticket, handed to the final review where there are more, and read at acceptance. Set \`status: done\` in the frontmatter and commit the code and the ticket file together, in one commit.

If you cannot proceed, append a \`## Halt\` section naming the kind and stop: \`blocked\` (a precondition the ticket assumed is not there), \`undecided\` (a decision the ticket's criteria do not settle and that is not yours to settle), or \`mystery\` (a failure you cannot explain, which is different from one you cannot fix). Then set \`status: halted\`.

Never write \`status: doing\`. It belongs to the runner."
  # A session reads its own ticket and no other - so an item one build left
  # standing for the next was never seen by it. Pointed at rather than
  # extracted: a Left standing says it in whatever shape its build chose.
  for t in "${TICKET_FILES[@]}"; do
    [ "$(field "$t" status)" = "done" ] && built+=$'\n'"- $(realpath "$t")"
  done
  [ -z "$built" ] || prompt+="

Tickets in this directory already built:$built

Each one's \`## Left standing\` says what its build did not settle. Handle an item that falls inside this ticket's \`## Done when\`, and leave the rest; this ticket's \`## Not here\` still holds."
  printf '%s' "$prompt"
}

# The ways a session is carried on rather than started over. The first two are
# read by the loop, the last by the final review.
# shellcheck disable=SC2034
STOPPED_EARLY="Your turn ended before the ticket was finished, and whatever you had running in the background was killed; your uncommitted work is still in the tree. Carry on from there - rerun what was killed - and finish as the brief said."
# shellcheck disable=SC2034
INTERRUPTED="The run was interrupted while you were working, and has been started again. Your uncommitted work is still in the tree. Carry on from where you stopped - rerun whatever was cut short, a subagent or a check included - and finish as the brief said."
# shellcheck disable=SC2034
REVIEW_STOPPED_EARLY="Your turn ended before REVIEW.md was committed, and whatever you had running in the background was killed, critique included. Carry on from there - rerun what was killed, in the foreground this time - and finish as the brief said."

red_checks() {  # -> what a build's session is told when the checks fail on its commit
  printf '%s' "The project's checks fail on your commit $(git rev-parse --short HEAD): \`$VERIFY\`. The runner ran them and set the ticket back to \`status: doing\`. Fix it test-first like any other failure, commit, and set \`status: done\` again. The last lines of what they printed are below; all of it is in $CHECKS_LOG.

$(tail -40 "$CHECKS_LOG")"
}

checks_question() {  # -> what the session that finds the checks is asked
  printf '%s' "Find this project's verification command: the one shell line, run from $(pwd), that runs everything a change here has to pass - tests, type check, lint. Where CI runs these, what CI runs is the authority. Do not run it and change nothing; answer with the command."
}

review_brief() {  # -> the prompt the final review starts from
  local t left standing=""
  for t in "${TICKET_FILES[@]}"; do
    left="$(left_standing "$t")"
    [ -z "$left" ] || standing+=$'\n\n'"$(basename "$t") left standing:"$'\n'"$left"
  done
  [ -z "$standing" ] || standing="

What the builds left standing is below. Among it are review findings a build did not fix, with the severity its reviewer gave each - one run's build left a blocker there, and its review found the same bug again. Every blocker and should-fix among them is yours to settle as you settle critique's: fix it test-first - unless the fix departs from a nudge or needs a decision the criteria do not settle, and then it goes under \`## For you\` for the person. Leave the nits and everything else for acceptance, and hand none of it to critique.$standing"
  printf '%s' "Review the whole change this run built: \`git diff $(review_base)\`. The tickets in $(realpath "$TICKETS") built it, and each build was reviewed on its own - which cannot see what lies between them. Look for that: the same thing built twice, one concept under two names, seams between tickets that do not line up.

The project's checks are \`$VERIFY\`, and they pass on the commit you start from.

Spawn \`critique\` as a subagent with a fresh context, in the foreground - not with \`run_in_background\`: a turn you end while it runs ends this session and kills it, which lost one run its whole review. Hand it the diff, the result of the checks, and $(realpath "$(dirname "$TICKETS")/$(field "${TICKET_FILES[0]}" criteria)") as what was asked for - not the tickets' plans or what their builds left standing, which are the reasoning behind the code. Evaluate what comes back, fix what is worth fixing test-first, run the checks and commit. The nudges in that file are how it was agreed this gets built, and each build followed them or recorded why not: a fix that departs from a nudge is not made - it goes under \`## For you\`, with the finding. Then review again the same way, except that the second round drives only the screens the fixes since the first round touched - name them to critique - unless the first round found only nits: fix the ones worth fixing and stop there. Two rounds at most: stop when a review comes back clean or with only nits, or when the second round is done.

Then write what you left standing to $(realpath "$REVIEW") and commit it. It opens with \`## For you\`: at most five things still open once this review is done, a line or two each, each naming the ticket it came from or the review. What needs the person's decision first - every fix you did not make because it departs from a nudge or needs a decision the criteria do not settle - then the rest of what is open, from what the builds left standing and from your own findings alike, most important first. Where more is open than five lines hold, the last says how many more are below it. Where nothing is open, it says \`Nothing.\` Below it, under headings of your own, the rest: findings you did not fix and why, checks you did not run. Nobody reads your closing message in an unattended run: the run ends by printing \`## For you\` and nothing else of REVIEW.md - the rest is read at acceptance - and it counts the review as finished only once that file is committed.$standing"
}
