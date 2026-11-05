---
effort: XS
utility: M
---

# signals.sh misses a hard test renamed to a soft name

`accept-change/signals.sh` lists the files a change touched that carry a
decision the developer answers for, hard tests among them. It reads
`git diff --name-only`, which names a renamed file by its new name only. A
hard test renamed to a soft name, such as `x.hard.test.ts` to `x.test.ts`,
is not listed: tried in a throwaway repository on 2026-11-05, the script
printed only the base.

That rename is the quietest way for a hard test to stop counting.
`review-code` should still catch it, but `signals.sh` is meant to catch
what a reviewer misses.
