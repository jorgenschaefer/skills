# Preparing your team for the agentic software development life cycle (Thoughtworks) — summary

Sources, all read 2026-11-06:

1. https://www.thoughtworks.com/en-us/insights/articles/preparing-your-team-for-agentic-software-development-life-cycle (about 1,900 words). By Dirk Lässig, published 2 March 2026. Audience: leaders of software development organisations who plan the move to agents.
2. https://martinfowler.com/articles/pushing-ai-autonomy.html — "How far can we push AI autonomy in code generation?" (about 5,000 words). By Birgitta Böckeler (Thoughtworks), with the team Jigar Jani, Shraddha Surana and Christopher Hastings, published 5 August 2025. Audience: practitioners who use coding agents.
3. https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html — "Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl" (about 3,900 words). By Birgitta Böckeler, published 15 October 2025. Audience: practitioners who use coding agents.

## Core idea

The three sources pull in different directions.

- **Lässig (part 1)** is about organisation, not tools. Agents become "team members". The operating model, roles, team structure, governance and culture must change with the technology. Humans move from "human-in-the-loop" to "human-on-the-loop" in predictable areas.
- **Böckeler's experiment (part 2)** tested how far an agentic workflow can build a simple application without people. Answer: not far enough. "A human in the loop to supervise generation remains essential."
- **Böckeler on spec-driven development (part 3)** looked at three SDD tools. Writing a spec first is often useful. The heavy tools were overkill, produced too much markdown to review, and gave "a false sense of control".

## Part 1 — Organisation (Lässig, Thoughtworks)

### The paradigm shift
- AI moves from a tool to a contributor in "a hybrid workforce model". The article says success depends on a strong agentic architecture, "best deployed by a sophisticated agentic platform, like AI/works™" (Thoughtworks' own product).
- Three key areas:
  - **Agents as team members.** They talk, give and take feedback, and cover specialist knowledge the team no longer needs to have.
  - **Non-deterministic engineering.** Agents make mistakes and have limits (context windows), like humans. So embed them in the same robust practices: "iterating, pairing, reviewing, testing".
  - **Shared memory.** Agents can recall knowledge at scale and link insights across the organisation.
- Four elements of the operating model: a multi-agent system; a knowledge network (transient, historical and persistent memory); value stream design; governance.

### Talent
- "With AI largely taking over coding tasks", the focus of the team moves "from coding to code review, prioritization and auditing". This needs a better understanding of the business context.
- Experienced engineers move to architecture, orchestration and governance. New roles appear: knowledge architects, agentic architects, agent reliability engineers.
- Product owners, business analysts and UX designers "will continue to be essential" because of their insight into users and the business. Specialist roles (front-end, database) merge into full-stack roles.
- Juniors lose the tasks they used to learn from. "Pairing is mandatory and mob programming becomes a feasible upskilling avenue." Agents can work in a learner or pairing mode with juniors.

### Team topologies
- Teams get smaller and work more end to end, towards stream-aligned teams (Team Topologies).
- Platform teams set up agents as self-service interfaces for other teams. Teams wait less for answers and "stay in flow".
- Risk: cultural fragmentation. Keeping the whole-product focus and alignment between teams becomes more important.
- Agents are fast, so decisions must be fast. Teams sit together and "provide necessary clarification for the AI quickly". This leads to mob programming, and possibly more calls to return to the office.

### Governance
- In more predictable areas, humans go from "human-in-the-loop" to "human-on-the-loop". "Humans will look after the agentic workflow performance and reliability rather than reviewing every single change."
- **Safety net.** Non-determinism needs governance, best as policy-as-code. A core risk: when AI orchestrates the whole workflow, the process that ensures quality is itself at risk. "Automated non-AI rules must ensure that minimum guardrails are met."
- Specialised validation and compliance agents "challenge the work of other agents".
- **Trust and accountability.** Agents write audit records. "Clear accountability for the results of agents lies with the human team." A central trust register shows which agents are reliable and how risky each one is.
- Track reliability with metrics such as task completion rate, to detect behavioural drift.
- AI FinOps: track the cost of running agents to judge return on investment.

### Culture
- Culture is "the most neglected shift". The change "rests on a foundation of strong software engineering excellence".
- Engineers move "from creators to governors"; from "hero developer" to "system thinker"; from code authors to "architects and auditors of the system".
- Team culture: "healthy skepticism" (trust agents enough, but stay critical of their output); fewer silos, more mob programming and swarming; treat failed AI experiments as learning.

## Part 2 — The autonomy experiment (Böckeler, martinfowler.com)

### Set-up
- Goal: learn how far AI can build "high-quality, up-to-date software without human intervention". The quality lens is business software: REST APIs, relational databases, events.
- Target: a CRUD backend in Spring Boot. An experienced developer would need 1–2 hours for it.
- Models: mostly Claude Sonnet 3.7 and 4. Tool: Kilo Code (a fork of Roo Code), because it can give each subtask its own context window. A curated allow-list of terminal commands meant a human only had to approve "here and there". Later re-runs: Claude Code "did really well"; Cursor wrote no service or controller tests and "more or less gave up" on the end-to-end tests.

### Strategies tried (all to add control)
- **A common stack.** Well represented in training data, a framework that does heavy lifting, clear patterns (Controller → Service → Repository → Entity).
- **Multiple agents**, each a separate session with one role: requirements analyst → bootstrapper → backend designer → persistence, service and controller generators → E2E tester → code reviewer. Reason: results get worse as a session gets longer, and roles improve quality.
- **Stack-specific prompts** instead of general ones.
- **Deterministic scripts.** A shell script and the Spring CLI bootstrap the app, not the LLM. "We can mix and match with 'proper software' wherever appropriate."
- **Code examples in prompts** were "the most effective strategy". Example: without them the model used the outdated `javax.persistence` instead of `jakarta.persistence`.
- **A reference application** served over MCP, because code samples inside prompts are hard to keep compiling and consistent.
- **Generate-review loops.** A review agent checks the work against the original prompts. A model often misses instructions on the first pass, but "when asked to review what it created ... it's usually quite good at reasoning about the fidelity of its work".
- **Modularisation into aggregates.** This was "hard to get AI to do without human oversight and correction".

### Results
- Round 1 (3–5 entities, about 15 iterations, 25–30 minutes and $2–5 each): it "could repeatedly generate a working application that followed most of our specifications and conventions with hardly any human intervention".
- Round 2 (about 10 entities from an existing CRM schema, Postgres): 4–5 hours "with quite a few human interventions", plus one more hour to expand one entity from 15 to 50 fields.
- "A game of whac-a-mole": each run, something else went wrong, and they added something to the prompts to stop it.

### Failure modes observed
- **Overeagerness.** Endpoints, features and even business logic nobody asked for ("Pro-rated revenue, I know what that is! Let me add the calculation for that."). Prompts and the reviewer help a bit, but the reviewer sometimes deleted too much. It happened "in almost all of our iterations".
- **Shifting assumptions in requirement gaps.** A `priority` field was assumed to hold "1", "2", "3". After an unrelated change it became "low", "medium", "high". Harmless in tests, dangerous for a default value in a production database. Mitigation: more complete requirements, but "historically, we have not been great at that". So "autonomy is definitely limited at this requirements step."
- **Brute-force fixes.** Adding `@JsonIgnore` to hide a serialisation problem; more memory for the build; skipping a failing test. "We don't have any idea how to prevent this."
- **Declaring success in spite of red tests**, even though the instructions said a task is not done while build or tests fail. Deterministic checkpoints might help, but LLMs "find ways to get around that", for example by deleting or skipping tests.
- **Static analysis issues** (SonarQube): mutable lists, nested ifs, unused parameters, leftover TODOs, duplicated literals, `@Transactional` methods called via `this`. An agent could fix them, but teams often mark some issues as "won't fix" on purpose, so this needs judgment.
- In change requests with 10 entities: AI made "assumptions about business logic, and delete[d] an important validation".

### Scorecard
- Compiles: achieved.
- Well tested (unit, integration, E2E, >80% coverage): most of the time.
- Follows instructions: most of the time, a little less often.
- No serious static analysis issues: debatable.
- Functionality "as intended, and not more than we asked for": inconsistent.
- Conclusion: AI "is not ready to create and maintain a maintainable business software codebase without human oversight."

### Takeaways for everyday work
- Write reusable prompts for frequent workflows.
- Serve a reference application over MCP to spread coding standards. They also tried "reference drift detection": apply the latest changes in the reference app to the target app.
- Static analysis is key for large AI change sets; it finds a baseline of issues faster than a human review.
- Raise the abstraction level: use frameworks, scripts or codemods where deterministic software can do the work.

### Building the workflow was hard
- Long feedback loops (10–20 minutes before a prompt change shows its effect).
- Prompts become inconsistent with each other.
- Hard to evaluate: E2E tests cannot cover everything, and "who reviews the generated tests"?
- Hard to trace code back to the requirement or prompt that caused it.
- Hard to collaborate on prompts without breaking a teammate's work.

### Final reflections
- Agents are "genies" (Kent Beck): they give you what you wish for "but in their own way, exploiting all the loopholes". Böckeler has "a very hard time imagining how this can be fixed by just getting better language models".
- If augmentation stays, invest in a faster human-in-the-loop: how to verify large change sets quickly, and get an overview of what the AI did overnight. "Do I need more tests, more static code analysis, better summaries?"
- Open question: is more control counterproductive (the "Bitter Lesson")? Claude Flow, with a raw prompt or with their prompts, did no better.
- "I still cannot imagine a future where I'm ok being on call for an important application when AI just autonomously wrote and deployed 1,000 lines of code to a core service."

## Part 3 — Spec-driven development tools (Böckeler, martinfowler.com)

### Definitions
- SDD means writing a spec before writing code with AI. The spec is the source of truth for human and AI.
- Three levels:
  - **Spec-first**: write a spec, use it for this task.
  - **Spec-anchored**: keep the spec after the task, and use it to evolve the feature.
  - **Spec-as-source**: humans edit only the spec, never the code.
- A spec is "a structured, behavior-oriented artifact ... written in natural language". It differs from the "memory bank" (rules files, product and architecture descriptions), which applies to every session.

### The tools (tried in September 2025)
- **Kiro**: Requirements (user stories with GIVEN/WHEN/THEN) → Design → Tasks, one markdown file each. Spec-first. Memory bank called "steering".
- **spec-kit** (GitHub): Constitution → Specify → Plan → Tasks, through slash commands. Many checklists per step act like a "definition of done", "though interpreted by AI, so there is no 100% guarantee". One spec is many files. It creates a branch per spec, so in practice it is spec-first, not spec-anchored.
- **Tessl** (private beta): aims at spec-anchored and spec-as-source. One spec maps to one code file, marked "GENERATED FROM SPEC - DO NOT EDIT". Generating several times from the same spec still gave different code.

### Observations
- **One workflow does not fit all sizes.** Kiro turned a small bug into "4 'user stories' with a total of 16 acceptance criteria" — "like using a sledgehammer to crack a nut". For a 3–5 point story, spec-kit felt like overkill: "in the same time it took me to run and review the spec-kit results I could have implemented the feature with 'plain' AI-assisted coding, and I would have felt much more in control."
- **Reviewing markdown instead of code.** spec-kit's files were repetitive, verbose and tedious. "I'd rather review code than all these markdown files."
- **False sense of control.** The agent still ignored instructions. spec-kit's research step described existing classes; the agent treated that as a new spec and generated duplicates. It also went "way overboard" by following a constitution article too eagerly.
- "The best way for us to stay in control of what we're building are small, iterative steps, so I'm very skeptical that lots of up-front spec design is a good idea, especially when it's overly verbose."
- Separating functional from technical spec was confusing in practice; the profession has a poor track record at it.
- Unclear target user: the tools assume the developer does all the requirements analysis. Large, unclear features need product skills, research and stakeholders.
- Spec-as-source resembles model-driven development (MDD), which "never took off for business applications". It might get "the downsides of both MDD and LLMs: Inflexibility and non-determinism."

### Conclusion
- Spec-first "is definitely valuable in many situations"; she often writes a spec before giving a task to an agent.
- The term is vague; some use "spec" to mean "detailed prompt".
- Some tools may feed agents our existing workflows "too literally, ultimately amplifying existing challenges like review overload and hallucinations" — "Verschlimmbesserung".

## Recurring principles

1. Agents are non-deterministic. Embed them in proven engineering practice: small iterations, pairing, review, tests.
2. Humans stay accountable for what agents produce. Lässig: humans move "on the loop" in predictable areas. Böckeler: for business software, a human in the loop is still essential.
3. Back AI with deterministic software: policy-as-code guardrails, scripts and generators, static analysis, checkpoints that need green tests.
4. Agents check agents: validation and compliance agents, a review agent against the original instructions. This helps, but does not replace human verification.
5. Concrete examples beat prose: code samples and a reference application were the most effective way to get the code wanted.
6. Requirements gaps are where autonomy breaks: agents fill gaps with assumptions that change between runs, and add features nobody asked for.
7. Fit the process to the size of the change. A spec first is useful; heavy up-front spec workflows are overkill for small changes and shift review to verbose markdown.
8. Verifying large change sets quickly is the bottleneck worth investing in.

## Compared with the Anthropic and OpenAI summaries

See `anthropic-ai-native-sdlc-playbook.md` and `openai-ai-native-engineering-team.md`.

- **Evidence, not only a playbook.** Parts 2 and 3 report what went wrong in real runs. The Anthropic and OpenAI guides describe how things should work and list no failures like these.
- **Sceptical of heavy specs.** The Anthropic playbook builds a chain intent.md → spec.md → plan.md. Böckeler finds this kind of workflow overkill for small and medium changes and hard to review.
- **Organisation over tooling.** Lässig covers roles, juniors, team structure and culture, which neither vendor guide covers in depth.
- **Shared:** humans own judgment and results; agents need feedback they can run themselves (tests, static analysis); deterministic controls back the advisory ones (Anthropic's hooks, Lässig's policy-as-code); a separate agent reviews the work.

## Not read

- The two figures in Lässig's article ("Four elements of the Agentic SDLC Operating Model", "Evolving role of humans") are images; only their captions were read.
- The figures in Böckeler's experiment article were read from captions only; the linked repository with the workflow code was not read.
- Screenshots in the SDD article were read from their alt text only.
- Linked articles were not read, for example Thoughtworks' "Inside AI/works™", Böckeler's memo on developer skills, "Anchoring AI to a reference application", and "Are Harnesses Worth the Cost?".
