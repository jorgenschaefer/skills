---
name: explain-code
description: Explain what a part of the code decides, once the developer can no longer follow it - "how does the verdict on 'nimmt zu' come about?" - as a short, plain explanation in chat that is checked against the code.
disable-model-invocation: true
---

# Explain code

The developer asks about something the code decides that they can no longer explain. Give them an explanation they understand and that is true of the code. Short and plain beats complete: they need the concepts and how they combine, not every branch - the code still holds every detail.

## Start

`/explain-code <the question in words>`. With no question, ask for one. Ask nothing else before the explanation - not even where the code is: not knowing is part of why they are here.

## Find the code, and widen the question

Start where the answer shows - a screen, a command's output, a response - and trace back to the code that decides it. Then read forward from that code to everything else shown in the same place that comes from it.

The question is usually one instance of something larger. "How is 'nimmt zu' worked out" was one of three values a card shows, beside a four-week view that can say the same thing, a daily figure and a "since N days". Explain all of what that code decides, not only the part asked about.

Note the files that code is in.

## Write it

Three subagents, each with a fresh context:

1. **The writer reads the code.** Give it the question, where the answer shows and what else shows there, and the files. It describes what the code decides and how, in the words used where it shows.
2. **The rewriter never sees the code.** Give it the writer's description, the question and the list of what shows where the answer shows, nothing else, and tell it to open no file. It writes for someone who knows the domain and not the code, top-down, the way good code reads: a summary of a few sentences that answers the whole question in terms it does not yet explain, then a short section for each of those terms, under a title naming what it describes. A section may itself use terms explained further down, each with a titled section of its own, as deep as the subject needs; every term is explained once. It may cut, merge and drop detail, but each thing on that list stays explained.
3. **The checker reads it against the code.** Give it the rewritten explanation and the files. It reports only statements the code contradicts, each with the line that contradicts it and what the code does there. A missing detail is never a finding.

A finding goes to a fresh rewriter with the current explanation, and is fixed by correcting or dropping that statement - never by adding a qualifier or a case. Then a fresh checker checks the new version. Show only a version the last checker found nothing in; after three rounds that still leave findings, drop the statements still disputed and show that.

## Show it

In chat, in the developer's language:

- **First, in a line or two,** everything shown where the answer shows that comes from this code, in the words used there - so a missing piece is noticed at a glance.
- **Then the explanation**: the summary, then its titled sections.
- **Last, the files** that code is in.

## Until they understand

Ask whether it is clear. Where they say a part is unclear, or ask about one, a fresh writer answers it from the code, given the current explanation and their words; a fresh rewriter works the answer into the explanation; and a fresh checker checks it, as above.

Where they call a case surprising - something the rule does that they would not have expected - say back which case it is, so it stays in the conversation.

It ends when they say they understand it. It writes no file. Reworking the code to follow the explanation is `/untangle`, typed next in this conversation - say so, and leave going on to them.
