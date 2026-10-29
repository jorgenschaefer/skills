---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5, AC-6
advances:
after:
status:    ready
attempts:  0
---

## Build
`./test.sh` checks that every quote on a *Serves* line of `PIPELINE.md` appears word for word in `MANIFESTO.md`, and fails, naming the line, where one does not.

## Done when
> **AC-1** `./test.sh` checks every quote on a *Serves* line of `PIPELINE.md`. When each one appears word for word in `MANIFESTO.md`, the check passes.

> **AC-2** When a quote does not appear in `MANIFESTO.md`, `./test.sh` fails, and its output names the line number in `PIPELINE.md` and the quote that was not found. This holds whether the manifesto line was reworded or removed, or the quote was edited in `PIPELINE.md`.

> **AC-3** When the check finds no quotes at all - the *Serves* lines changed form, or `PIPELINE.md` is missing - it fails rather than passing.

> **AC-4** Word for word includes the Markdown markup: a quote that keeps the words but loses the `**` around a term counts as not found. Whitespace does not: a run of spaces or a line break inside a quote, or in the manifesto, counts as a single space.

> **AC-5** Double quotes outside a *Serves* line, such as "fix" in the section on what outlives a change, are not checked. A *Serves* line that says it serves no manifesto line passes without a quote.

> **AC-6** A *Serves* line that has no quote and does not say it serves no manifesto line fails, and the output names its line number - a paraphrase, or a quote typed with curly quotes, is caught rather than skipped. So is a *Serves* line with a double quote that is never closed: it fails, and the output names its line number.

## Technical decisions
> **Concepts** none.

> **Wire formats** none. `./test.sh` keeps its exit code: 0 when every case passes, non-zero otherwise.

> **Hard to reverse** none.

## Context
The agreed design is a check that executes, run by `./test.sh` with the rest of the suite.

`PIPELINE.md` writes its *Serves* lines in two forms today: `*Serves:*` under a rule and `- **Serves:**` in a stage's list. A line may hold several quotes, prose between them, and `**` markup inside a quote. One that serves nothing says "no manifesto line". On 2026-10-29 every quote was found word for word in `MANIFESTO.md`, so the check passes on the files as they are.

`./test.sh` runs the suites under `tests/` side by side, from a list it names, and lints every script under `tests/` with shellcheck. `tests/lib.sh` holds what the suites share: `ok`, `bad`, `expect_counted` and `finish`.

The groups What production must show, Security policy and Information model all say "None.".

## Not here
- Stale links in the backlog, and in `PIPELINE.md` beyond its quotes.
- Whether a quote still fits the stage it is attached to. That stays a judgement.

## Left standing
