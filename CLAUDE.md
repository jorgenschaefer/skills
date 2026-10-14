This is a suite of skills for creating High Quality Software with coding agents.

The quality of software is measured by the following rubrics, in this order:

1. It is usable. It does what the user needs to do. The more helpful and usable it is, the better.
2. It is secure. A malicious person can not gain access or information they should not get.
3. It is maintainable. When feature requests or bug reports come in, it's easy to add them, today or five years from now. Development speed does not slow down over time because cruft or technical debt accumulates.

The skills serve a senior developer who signs off on the software they produce. Design every skill so that developer sees each decision they would have to answer for — product behaviour, security, stored and wire formats, interfaces, dependencies, anything hard to reverse — with evidence for each result rather than a claim, and nothing else. Where a skill cannot tell whether something is critical, it shows it in one line. Decisions wait for the pipeline's fixed stops rather than interrupting a run.

Many traditional ideas of good software apply to coding agents. These do not, and the skills are built around that:

- A skill installs alone and cannot reach a sibling's directory, so a reference file two skills need is copied into each, not shared.
- An agent does not judge its own work. Every stage is checked by something that did not produce it, with a fresh context.
- What has to hold when a session dies or lies is a script; what is judgement is a skill.
- A check that executes beats a check that judges.

README.md describes the pipeline and how the skills relate. Read it before changing what a skill is for.

Check: `./test.sh`
