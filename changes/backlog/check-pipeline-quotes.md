---
effort: XS
utility: S
---

# The manifesto lines PIPELINE.md quotes are checked

Every stage and rule in `PIPELINE.md` quotes the manifesto line it serves,
word for word. Nothing checks that the quotes still match `MANIFESTO.md`
after either file changes; at acceptance of `PIPELINE.md` (2026-10-29)
they were checked by a throwaway script. `tests/no-dangling.sh` does not
read `PIPELINE.md` or the backlog either, which is how a "Related:" line
to a deleted backlog item went unnoticed.
