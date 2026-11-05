# The New SDLC With Vibe Coding (Google) — summary

Source: https://www.kaggle.com/whitepaper-the-new-SDLC-with-vibe-coding (51 pages, read 2026-11-06). The Kaggle page loads the PDF with JavaScript, so the text was read from a copy of the same PDF at https://readwise-assets.s3.amazonaws.com/media/wisereads/articles/the-new-sdlc-with-vibe-coding/1317.pdf (Adobe InDesign file, 51 pages).
Dated May 2026. Authors: Addy Osmani, Shubham Saboo, Sokratis Kartakis.
Subtitle: "From ad-hoc prompting to Agentic Engineering".
Audience: "software engineers, engineering managers, architects, and technical leaders" who want to adopt AI "without sacrificing the discipline that production software demands". It assumes no knowledge of AI or machine learning. It is one paper of a course series: it points to a "Day-3" paper on context engineering and a "Day 5" paper on spec-driven, production-grade development.

## Core idea

Programming moves "from writing code to expressing intent". The machine does the implementation; "The human provides intent, architecture, and judgment."

Vibe coding and agentic engineering are the two ends of a spectrum. "The key differentiator is not whether you use AI. It's how much structure, verification, and human judgment surrounds the AI's output."

The developer's main output is no longer code but "the system that produces code" (the factory model). The model is only the engine; everything around it is the harness, and most agent failures are "configuration failures" of that harness.

Numbers the paper quotes from other sources:

- Early 2026: 85% of professional developers use AI coding agents regularly, 51% daily; an estimated 41% of new code is AI-generated.
- Industry surveys: 25–39% productivity improvement.
- METR: experienced developers took 19% longer on certain tasks, mostly because of verifying, debugging and correcting AI output.

## The spectrum: vibe coding to agentic engineering

Vibe coding comes from Andrej Karpathy (February 2025): "fully give in to the vibes, embrace exponentials, and forget that the code even exists." Describe, accept, paste errors back. By early 2026 Karpathy himself introduced "agentic engineering" for the disciplined end.

Table 1 has three columns: vibe coding, structured AI-assisted coding, agentic engineering.

| Dimension | Vibe coding | Structured AI-assisted | Agentic engineering |
|---|---|---|---|
| Intent | casual prompts | detailed prompts with examples and constraints | formal specs, architecture docs, memory files |
| Verification | "Does it seem to work?" | manual testing, spot checks | automated test suites, CI/CD gates, LM judges |
| Understanding the code | developer may not read it | selective review of critical paths | full review of architecture; AI handles details |
| Errors | paste error back | developer finds root cause, AI fixes | agents self-diagnose within bounds; humans handle architecture |
| Scope | prototypes, scripts, hackathons | features in existing codebases | production systems, team scale |
| Risk | high; fine for disposable code | moderate; human judgment at key checkpoints | low; systematic verification at every stage |

- "The right position on this spectrum depends on the stakes." A weekend prototype can be pure vibe coding; a financial API needs agentic engineering. "the skill is knowing where to draw the line for each task."
- The biggest difference is verification. Tests check the deterministic parts. Evals check the non-deterministic parts: the agent's trajectory, its choice of tools, the quality of the final answer. Evals use labelled datasets, rubrics and LM judges. "Without both, the practice is always vibe coding, regardless of how sophisticated the prompts are."

## Context engineering

- Code quality depends "less on the cleverness of your prompts and more on the quality of the context provided."
- Six types of context: instructions, knowledge, memory (short-term and long-term), examples, tools, guardrails.
- **Static context** is always loaded: rule files (AGENTS.md, CLAUDE.md, GEMINI.md), system instructions, global memory, personas. It is expensive, because every token is in every call.
- **Dynamic context** is loaded on demand: skills, tool results, RAG documents, windowed history.
- What goes where is "a genuine engineering trade-off": too much static context "wastes tokens and dilutes signals", too little and the agent forgets rules. Treat the boundary as "a first-class architectural decision, reviewed and versioned".
- Agent Skills are "the most powerful pattern" for dynamic context: progressive disclosure, so only metadata is loaded at startup. They solve context rot, the lack of procedural memory, the overhead of multi-agent set-ups, and portability across tools.
- The guiding question: "what would a new team member need to know to contribute effectively, and how do I encode that knowledge in a form the AI can use?"

## The new SDLC, phase by phase

AI compresses the cycle "unevenly": implementation goes from weeks to hours, but "requirements, architecture, and verification remain stubbornly human-paced." Phases blur; the developer becomes "system designer and quality arbiter." The paper says this picture is from mid-2026 and "may look different in 12 months"; teams already try going "directly from specs to review".

- **Requirements and planning.** AI writes user stories from briefs, finds edge cases, drafts API schemas, builds prototypes from specs in minutes. "Requirements stop being a document handed off between teams. They become a conversation between humans and AI that produces specification and initial implementation simultaneously."
- **Design and architecture.** "the most stubbornly human-centric phase". Architecture is about trade-offs (consistency vs. availability, build vs. buy) that depend on business context "that AI cannot fully grasp". AI is good at implementing decisions once they are made. The developer's job is "making and documenting the structural decisions". (Nothing on UX or design systems.)
- **Implementation.** Agents build whole features. The work changes "from writing to reviewing, guiding, and verifying" (see the METR number above).
- **Testing and QA.** Check both the output (does it compile, do the tests pass) and the trajectory (the tool calls and reasoning). "a fluent output that skipped its verification steps is a more dangerous failure than one with a visible error." Agents write test cases, including edge cases and property-based tests. "tests and evals become the primary mechanism for communicating intent to AI agents". A "quality flywheel": evaluate against a benchmark, cluster failures by root cause, fix the prompts or tools, verify against a regression suite, monitor production.
- **Code review and deployment.** AI is the first-pass reviewer (bugs, style, security, performance). It "does not replace human review": design, maintainability and strategic fit still need human judgment. Agents can watch deployment health, roll back, and predict deployment risk. The Day 5 paper covers review at high PR volume ("bundled summaries, conditional LGTM, agent-driven code-review skills").
- **Maintenance.** Code that was "too risky to touch" can now be refactored, migrated and modernized with AI.

## The factory model

The developer builds the system that builds the software. It has five parts:

- specifications and context
- agents that implement them
- tests and quality gates
- feedback loops that send failures back to the agents
- guardrails

"Success comes from giving agents success criteria rather than step-by-step instructions, then letting them iterate."

## Harness engineering

"Agent = Model + Harness" (figure caption). The harness is everything except the model: prompts, tools, context policies, hooks, sandboxes, sub-agents, observability. "it is the team's surface area, not the model provider's."

Parts of the harness:

- **Instructions and rule files**: AGENTS.md, CLAUDE.md, skill files, sub-agent prompts.
- **Tools**: functions, MCP servers, APIs, and the text that says when to use them.
- **Sandboxes**: where code runs and what it can reach.
- **Orchestration**: sub-agents, model routing, hand-offs.
- **Hooks**: deterministic code at fixed points (before a tool call, after an edit, before a commit). "Hooks are the place for things the agent should never forget but often does."
- **Observability**: logs, traces, evals, cost and latency. Without it you cannot tell whether the agent is "quietly drifting".

The harness in each phase:

1. Requirements, planning, architecture: configure it (AGENTS.md, architectural constraints, the tools, the rules the agent cannot break).
2. Implementation: run it (sandboxes, tools).
3. Testing: the feedback loop. Orchestration sends failing test output back to the model to try again.
4. Review, deployment, maintenance: observe it. Hooks block, for example, a commit with a hard-coded password; observability lets humans audit "why an agent made a specific deployment decision."

Vibe coding and agentic engineering can use "the exact same agent"; the difference is "how deliberately you configure and apply the harness."

Numbers the paper quotes: on Terminal Bench 2.0, one team moved an agent from outside the top 30 to the top 5 by changing only the harness. LangChain gained 13.7 points by changing only the system prompt, tools and middleware.

"Most agent failures, examined honestly, are configuration failures": a missing tool, a vague rule, a missing guardrail, or a context full of noise.

## The developer's role: conductor and orchestrator

- **Conductor**: real-time pair programming in the IDE. Fits complex logic, tricky debugging, unfamiliar code. Risk: the developer becomes the bottleneck.
- **Orchestrator**: define goals, hand them to agents running in the background, check in and review. Fits well-defined work: bug fixes, features in established patterns, migrations, test generation.
- Skills the orchestrator needs: specification (precise enough to run "without ambiguity"), decomposition, evaluation ("Quickly assessing whether agent output meets quality standards"), and system design (the constraints, tests and feedback loops).

### The 80% problem

- Agents write about 80% of a feature fast. The rest (edge cases, error handling, integration, subtle correctness) needs context the models often lack.
- AI errors are now conceptual: wrong business assumptions, "failure to seek clarification on ambiguous requirements", missed edge cases, architecture that creates long-term burden. They are hard to see because the code "looks right" and may pass basic tests.
- Effective developers use AI for "rapid implementation of well-specified tasks" and keep "their own attention for what AI struggles with (ambiguous requirements, architectural trade-offs, and correctness verification)." "They don't try to be faster by accepting everything the AI produces."

## Coding agents in practice

- Three places: in the editor (completion, chat), in the terminal (multi-file work, runs tools and tests; "where serious vibe coding happens today"), in the background (cloud sandboxes, hours long, output is a PR).
- A background agent fits tasks "the developer can describe in a paragraph and walk away from". "The right starting point depends on the task, not on which category sits highest on some autonomy ladder."
- Building agents as products: Google's Agents CLI adds seven skills to any coding agent for the ADK lifecycle (scaffold, write, evaluate, deploy to Agent Runtime, observability). Coordination through shared session state, MCP and A2A.
- Example quoted: Anthropic's agent teams built a C compiler in Rust in two weeks; humans set direction and reviewed. "The bottleneck moved from writing the code to specifying what it should do and verifying that the agents did it."

## Economics

- Look at total cost of ownership, not velocity.
- **Vibe coding: low CapEx, high OpEx.** Token burn from unstructured context and repeated fix loops with "low first-pass success rates"; a maintenance tax from inconsistent "spaghetti" code; security fixes in production.
- **Agentic engineering: high CapEx, low OpEx.** Upfront work on API schemas, deterministic test suites and "most importantly, structuring the agent's context". After that, the cost per feature "drops dramatically" (the paper's claim; no numbers).
- Context engineering is "a financial strategy": a dense, high-signal context raises first-pass success.
- Model routing: large models for requirements, architecture and first implementation; smaller, cheaper models for test generation, code review and CI/CD monitoring.

## Where to start

The principle: "AI amplifies the engineering culture it lands in."

For individual developers:

1. Set up an AGENTS.md. "Start with ten lines: stack, conventions, hard rules, workflow. Add a rule every time the agent does something it should not do again."
2. Install a set of skills (such as Agents CLI).
3. Turn one repetitive workflow into your first agent.
4. "Write the tests and evals before generating the code. Together they are the contract with the AI."
5. "Review every line the agent produces that is going to ship." Be skeptical of clever code, check that imports are real packages, check error handling.
6. Keep your own skills sharp: debugging, system design, performance and correctness.

For engineering leaders:

1. Treat AGENTS.md, prompts, eval suites and skills as code: reviewed in PRs, versioned, "owned by named engineers". Otherwise "the harness drifts".
2. "Set the bar at the eval, not the demo." Evals need explicit rubrics (task success, tool use, trajectory, hallucination, response quality). Require eval coverage before an agent ships into a shared workflow.
3. Reshape review: AI code needs "the same or greater scrutiny", with attention to hallucinated dependencies, weak error handling and subtle correctness gaps. Train reviewers and tune checklists.
4. Separate prototyping from production in team norms: which projects, branches and environments use which mode. Otherwise "prototypes that ship by accident."
5. Treat the harness (prompts, skills, MCP connections, eval harnesses) as shared infrastructure.

For organizations:

1. An engineering investment, not a productivity feature. Without evals, observability and standards you get "speed without quality".
2. Build the production substrate first: evals in CI, traces of every agent run, scoped permissions per agent, security review for generated code.
3. Adopt MCP and A2A.
4. Plan for hybrid teams: "humans set direction, agents do the implementation, and clear handoff protocols govern the boundary."
5. Hire and train for judgment: specification, evaluation, architecture, review.

## Conclusion

Three durable principles:

1. "Structure scales, vibes don't." Vibe coding is fine for exploration; production needs specs, tests, guardrails and human oversight of architecture.
2. "AI amplifies your engineering culture" — strengths and weaknesses alike.
3. "The human role is evolving, not diminishing": from implementation to judgment.

Last line: "Generation is solved. Verification, judgment, and direction are the new craft."

## Recurring principles

1. How much structure to use depends on the stakes; vibe coding for disposable work, agentic engineering for production.
2. Verification is what separates the two: tests for deterministic behaviour, evals for agent behaviour. Write them before the code; they carry the intent.
3. Context matters more than prompts. Decide deliberately what is always loaded and what is loaded on demand.
4. The harness, not the model, decides most of the outcome. Most failures are configuration failures; fix the harness.
5. Treat the harness (rule files, skills, evals, prompts) as versioned, reviewed code with named owners.
6. Humans spend their attention where AI is weak: ambiguous requirements, architectural trade-offs, correctness.
7. Humans own architecture and review everything that ships; AI is a first-pass reviewer only.
8. Upfront investment (specs, tests, context) costs more at the start and less over the life of the code.

## Compared with the Anthropic and OpenAI summaries

See `anthropic-ai-native-sdlc-playbook.md` and `openai-ai-native-engineering-team.md`.

- **More conceptual.** Mental models (spectrum, factory, harness, conductor/orchestrator), not step-by-step plays. No chain of files like intent.md → spec.md → plan.md, and no Delegate/Review/Own split per phase.
- **Ceremony scales with stakes.** Only this paper says outright that a low-stakes task may use little process, and that teams must mark where the line is.
- **Evals for agents.** Like Anthropic, it puts evals next to tests, but it means evals of the agent's trajectory as well as its output.
- **Economics.** Only this paper argues in cost terms: CapEx vs. OpEx, tokens, routing cheap tasks to small models.
- **Review is stricter.** "Review every line ... that is going to ship." OpenAI and Anthropic focus more on high-signal AI review before the human.
- **Thin on design.** No design systems or UX; OpenAI's guide has the human own them.
- **Shared with both:** humans own architecture and judgment; tests are written first and define correct behaviour; agents need feedback loops they can run; a rule file (AGENTS.md, CLAUDE.md) holds the project's conventions.
- **Shared with Anthropic:** a rule is added when the agent repeats a mistake; hooks enforce what must hold.

## Not read

- The official Kaggle page renders the PDF with JavaScript and could not be read directly. The text was read from a copy of the same PDF hosted by Readwise.
- The nine figures are images; only their captions were read. The "useful equation" on page 26 is an image; its figure caption gives "Agent = Model + Harness".
- The companion papers (Day 3 on context engineering, Day 5 on spec-driven development), the "Introduction to Agents" whitepaper, and the linked blog posts were not read.
- The conclusion mentions a "taxonomy of ambient, workflow, and autonomous agents" that does not appear in the body text; the body uses editor, terminal and background instead.
- The endnote numbers in the text do not always match the endnote list.
