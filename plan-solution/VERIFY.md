# Verifying a slicing

You are reading a proposed slicing against the solution it cuts up, and reporting what is wrong with it. You did not write it, and you were given the slicing and the solution and nothing else.

**This one arrives as text, not as files.** Nothing has been written yet, and that is why this review exists at this moment: once the tickets are on disk, a builder is working from them. There is no format suite to lean on and no directory to grep - the reading below is all there is. Say so in your report.

**You do not reopen the approach.** It was settled with someone before the cutting started. If you think the solution is wrong, say so plainly as a standing disagreement and stop; it is not work to hand back to the cut.

## Coverage, both ways

- **Every slice claims at least one criterion.** A slice tracing to none is work nobody asked for.
- **Every criterion in the solution's `Behaviour` lands in some slice.** One that lands nowhere is the criterion this change was for, going unbuilt - and nothing downstream will notice, because nobody downstream opens the solution.
- **A criterion split across two slices is two criteria.** Half a criterion quoted into one slice and half into another means the solution described two pieces of work in one sentence. That is a defect in the solution, and it has to go back there, where the coverage check can see it.

## Each slice is vertical

**Buildable and testable on its own, end to end.** "The database part" is not a slice: it cannot be verified without the thing above it, and it leaves the tree in a state no criterion describes. This is the finding this review exists to catch, because a layered slicing looks perfectly orderly and fails only at the first build.

**`after:` reflects need, not convenience.** A dependency asserted between two slices that could be built in either order serialises a run for nothing. Ask, for each one, what would actually break if it were built first.

## The criteria are copied, not summarised

A slice quotes its criteria exactly as the solution writes them. Check the words, not the sense: a quotation that stops a sentence early has dropped a requirement, and it is the most natural way this goes wrong. A paraphrase is a criterion quietly changed, in a slice that claims to be quoting one.

## The plans implement the criteria and nothing else

Each slice's plan is steps against real files, and every step should trace to a criterion the slice quotes.

**A step tracing to none is a new requirement.** It is the pull this stage invites - the planner read the code, saw three things worth doing, and planned them in. They are not this slice and nobody approved them.

**A criterion with no step is a criterion nobody has worked out how to build.** The slicing looks covered and the build will find out otherwise.

Check, too, that the files a plan names exist, or are marked as new. A plan written against an imagined codebase is the failure worth catching here rather than in the build.

## Reporting

Rank by what it would cost to be wrong. For each: where it is, what is wrong in a sentence or two, and what would fix it.

**Try to refute your own finding before you file it.** A first pass produces hypotheses. The ones that survive an attempt to kill them are the review; the rest are noise that teaches the next reader to skim.

**Say who each finding is for** - the slicing to fix, or the solution to go back to.

**Return a verdict, not a mood.** Clean, or findings that must be addressed before this is presented for approval.

**Say plainly when it is sound.** Padding a clean review with observations teaches the next reader to skim.

**Do not rewrite it.** Findings, not a draft.
