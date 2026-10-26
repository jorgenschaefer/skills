This is a suite of skills for creating High Quality Software with coding agents.

MANIFESTO.md defines what high quality software is and how agents build it. Every skill serves it; read it before changing what a skill does.

The skills serve a developer who does not read the code. Design every skill so that developer sees what the manifesto puts in front of a human — what they approve before implementation and what the report shows after — with evidence for each result rather than a claim. Where a skill cannot tell whether something is critical, it shows it in one line. A skill does not stop to ask the developer. It saves its questions for the pipeline's fixed stops.

A skill only sees files in its own directory, so a file two skills need is copied into each.

README.md describes the pipeline and how the skills relate. Read it before changing what a skill is for.

Check: `./test.sh`
