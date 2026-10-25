---
effort: S
utility: S
---

# The code review looks through the same lens as the builder

`MANIFESTO.md`: "Reviewers use different framings, which reduces the blind
spots they share with the author but does not remove them." And: "Where a
criterion is judged, the review is adversarial."

The builder and its reviewer read the same document as their lens.
`implement/SKILL.md:10`: "Read this skill's `CODING_STANDARDS.md` whole and
apply all of it". `critique/SKILL.md:8`: "Read this skill's
`CODING_STANDARDS.md` first ... Review against them". A fresh context keeps
the author's reasoning out of the review, but not the author's lens: what the
standard does not make the builder look for, it does not make the reviewer
look for either.

Some of the framing already differs: critique drives the running app, hunts
down callers, compares the tests before and after (`critique/SKILL.md:18-30`),
and the final review looks between tickets (`run/prompts.sh:76`). But the
first pass is framed as judging against the standard, the same task the
author had, and the adversarial part is the refutation of its own findings
(`critique/SKILL.md:34`), which filters for precision instead of hunting for
what breaks. The spec stages are different: each has its own `VERIFY.md`
(`idea`, `find-criteria`, `criteria-to-tickets`), written for that stage's
adversary rather than for its author.

The standard is what the code is held to, so the review cannot drop it.

No run has yet shown a defect that the builder and both reviews missed
because they shared this lens.

Depends on `standard-follows-the-manifesto`, since the standard is the lens.
