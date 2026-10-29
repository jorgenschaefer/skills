# Criteria: the manifesto quotes in PIPELINE.md are checked

## Problem
`PIPELINE.md` justifies each stage and rule by quoting the manifesto line it serves, word for word. When `MANIFESTO.md` is reworded or a line is removed, a quote can stay as it was. It still reads as a sensible sentence, so nobody reading `PIPELINE.md` notices. The stage then cites a reason the manifesto no longer gives, and whoever changes the pipeline next works from that reason. What should be true instead: when either file changes, any quote that no longer appears in the manifesto is found before the change is accepted, and nobody has to compare the two files by hand to find it.

There is no instance yet: on 2026-10-29, when `PIPELINE.md` was accepted (commit 5a2fd6c), every quote was found word for word in `MANIFESTO.md` by a throwaway script. The risk is real because the manifesto is reworded often - for example in commits 23c6504 "Replace the manifesto with premises, roles and goals" and f3b2ffd "Say that a check is confirmed per change, before acceptance".

## Acceptance criteria
### Behaviour
- **AC-1** `./test.sh` checks every quote on a *Serves* line of `PIPELINE.md`. When each one appears word for word in `MANIFESTO.md`, the check passes.
- **AC-2** When a quote does not appear in `MANIFESTO.md`, `./test.sh` fails, and its output names the line number in `PIPELINE.md` and the quote that was not found. This holds whether the manifesto line was reworded or removed, or the quote was edited in `PIPELINE.md`.
- **AC-3** When the check finds no quotes at all - the *Serves* lines changed form, or `PIPELINE.md` is missing - it fails rather than passing.
- **AC-4** Word for word includes the Markdown markup: a quote that keeps the words but loses the `**` around a term counts as not found. Whitespace does not: a run of spaces or a line break inside a quote, or in the manifesto, counts as a single space.
- **AC-5** Double quotes outside a *Serves* line, such as "fix" in the section on what outlives a change, are not checked. A *Serves* line that says it serves no manifesto line passes without a quote.
- **AC-6** A *Serves* line that has no quote and does not say it serves no manifesto line fails, and the output names its line number - a paraphrase, or a quote typed with curly quotes, is caught rather than skipped. So is a *Serves* line with a double quote that is never closed: it fails, and the output names its line number.

### What production must show
None.

### Security policy
None.

### Information model
None.

## Agreed design
A check that executes, run by `./test.sh` with the rest of the suite.

## Technical decisions
- **Concepts** none.
- **Wire formats** none. `./test.sh` keeps its exit code: 0 when every case passes, non-zero otherwise.
- **Hard to reverse** none.

## Out of scope
- Stale links in the backlog, and in `PIPELINE.md` beyond its quotes.
- Whether a quote still fits the stage it is attached to. That stays a judgement.

## Ruled out
- **Labels on manifesto lines in place of quotes** - M effort, the reason disappears from `PIPELINE.md`, and a line reworded to mean something else still passes.
- **An instruction to compare the two files** - a judgement, which is what the problem rules out.
