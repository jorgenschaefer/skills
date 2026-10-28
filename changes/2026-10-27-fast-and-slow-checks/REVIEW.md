## For you

Needs your decision first:

- **This repository's own `CLAUDE.md` still says `` Check: `./test.sh` ``** (review, round 1, should-fix). The change makes `critique` report that line as a should-fix, so every review of this repository will report it again. I did not rename it to `Fast check:`. `./test.sh` takes about 3 minutes, and the standard now says the fast check takes at most 30 seconds. Renaming the line would declare a 3-minute fast check. Splitting the suite is the job of a preparatory ticket you approve (AC-12), and the criteria leave it out of scope here.

The rest of what is open, most important first:

- **No automated test proves the criteria that live in skill wording** (01): AC-6 to AC-9, AC-11, AC-12, and the skill side of AC-1, AC-2 and AC-10. `./test.sh` only checks that the shared files' copies are identical. Two reviews per ticket and two final reviews checked them by reading.
- **Decisions the builds made that the criteria do not settle** (01, 02):
  - `critique`, given both `Check:` and `Fast check:`, runs the `Fast check:` command.
  - `/criteria-to-tickets` shows the fast check's time at every approval, not only when it is over 30 seconds.
  - The runner runs the slow check even when the fast check is red. A session then learns about both at once, at the cost of the slow check's time.
  - A run started again over a committed review halts on red checks; it does not hand them back to the review session.
  - The review session handed red checks adds its fix to REVIEW.md.
  - Check logs have unique names, `fast-check-…-XXXX.log` and `slow-check-…-XXXX.log`.
- **A project with no slow check reads "both checks" in its briefs** (review, round 2, nit). The brief says "it has no slow check" and then "the runner runs both checks on your commit". My fix 51396f9 brought this in. Before it, the briefs said "every check", and the skills already said "both checks". No session runs anything wrong because of it.
- **A run started on main makes its branch before it refuses a `CLAUDE.md` with both `Check:` and `Fast check:`** (02, nit). Starting again on main is then refused because the branch exists. Red checks at the start already behaved this way.
- **Two preparatory tickets can both come "first"** (01, nit): a malformed `Check:` line that is also slow. Nothing says which comes first.
- **`MAX_ATTEMPTS=1` prints "through 1 attempts"** (02, nit).
- **`tests/stub-session` finds the review by the first `REVIEW.md` in its prompt** (02). A new sentence naming REVIEW.md broke it twice. It could tell the review from a build by the brief's opening words instead.

## Review findings not fixed

- Round 1, should-fix: this repository's `Check:` line. See `## For you`.
- Round 2, nit: "both checks" where there is no slow check. Two rounds were done, and a fix now would be one no reviewer saw. Going back to "every check" would bring back round 1's nit.

## Fixes made in this review

Both were made after round 1, and round 2 saw them.

- 51396f9 (round 1, nit): the runner's build and review briefs say "both checks" instead of "every check", the name the skills and the README use. Test first in `tests/run/prompts.sh`.
- 7f5eec4 (round 1, nit): `retro/SKILL.md` names the check logs, `fast-check-*.log` and `slow-check-*.log`. Before this change the checks' output went to `verify-*.log`, which retro's list already matched.

No fix was made after round 2.

## Fixes the builds made after their last review

I checked each against the finding it answers. All hold:

- `init-security-policy/SKILL.md` makes CI run a `Slow check:` line it declares.
- `criteria-to-tickets/SKILL.md`'s "No fast check" bullet is short sentences with the same meaning.
- `run/prompts.sh` tells the build and the review to run the fast check, not "the checks".
- `run/report.sh` points at `git stash list` when the review's checks stay red.
- `tests/run/report.sh` asserts the review's hand-back line and the REVIEW.md instruction.

## Checks

- `./test.sh` passed on da6a9c5 and on 7f5eec4: 256 ok, 0 failed, about 3 minutes each.
- This repository has no slow check, so none ran. No test moved between the checks.
- Round 1 drove the runner with a stub in place of `claude` for AC-3, AC-4, AC-5 and AC-10. Round 2 drove it for AC-2 only.

## Blast radius and revert of this review's fixes

- 51396f9 changes the words every pipeline session reads in its brief. It changes no format and no exit code. A revert brings back "every check".
- 7f5eec4 changes only what a retro is told to read. A revert undoes it.
