# AI-Driven Development Lifecycle (AI-DLC) Method Definition (AWS) — summary

Sources, all read 2026-11-06:

- Method definition paper: https://prod.d13rzhkk8cj2z0.amplifyapp.com/ (serves `aidlc.pdf`, 8 pages). This is the "white paper" the blog links to. The text is undated; the PDF file was made on 2025-07-23.
- Blog post "AI-Driven Development Life Cycle: Reimagining Software Engineering": https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/ (about 1,000 words, 2025-07-31).
- GitHub repository awslabs/aidlc-workflows: https://github.com/awslabs/aidlc-workflows (README, `docs/guide/00-introduction.md`, `docs/guide/workflow-profiles.md` up to the MVP profile; version 2.11.3).
- "AI-DLC Workflows 2.0" specification in that repository: `assets/AI-DLC-Workflows-2.0-Specification.pdf` (6 pages, undated; the PDF file was made on 2026-07-22).

Author: Raja SP, Principal Solutions Architect at AWS. He leads AWS's Developer Transformation Programs. The 2.0 specification names no author.
Audience: the blog is for "business and technology leaders". The paper is for teams that build complex systems, "typically involving multiple teams working cohesively within large and/or regulated organizations". Simple systems with few trade-offs are out of scope; the paper sends them to low-code and no-code tools.

## Core idea

The paper names two ways companies use AI today. In **AI-assisted** development, AI helps with single tasks. In **AI-autonomous** development, AI is expected to build whole applications alone. AWS says both give poor results for speed and quality. AI-DLC is a third way, the "AI-Driven" one: AI runs the process, and humans approve.

- "Reimagine rather than retrofit". Do not add AI to Scrum. Build a new method around it. "We need automobiles and not the faster horse chariots."
- **Reverse the conversation direction.** AI starts and leads the conversation, not the human. AI breaks an intent into tasks, makes recommendations and proposes trade-offs. "Humans serve as approvers, validating, selecting options, and confirming decisions at critical junctures." The paper compares this to Google Maps: the human sets the destination, the system gives the directions.
- One pattern repeats for every activity: AI makes a plan, asks clarifying questions, and implements only after a human has validated the plan.
- The blog names two "dimensions": "AI Powered Execution with Human Oversight" (AI "defers critical decisions to humans") and "Dynamic Team Collaboration" (the team works together in one room while AI does the routine work).
- AI stores plans, requirements and design artifacts in the project repository. This is the "context memory" that carries work across sessions and phases.

## Key principles (paper, section II)

1. **Reimagine rather than retrofit.** Iterations shrink to hours or days. Rituals built for weeks-long cycles (daily standups, retrospectives) matter less. The paper asks whether story points and velocity still make sense, or whether business value should replace velocity.
2. **Reverse the conversation direction** (see above).
3. **Design techniques are part of the core.** Scrum and Kanban leave design techniques to the team. AWS says this gap led to poor software quality. AI-DLC builds the technique in. There will be "flavors" for Domain-Driven Design (DDD), Behavior-Driven Development (BDD) and Test-Driven Development (TDD). The paper describes only the DDD flavor: AI splits the system into independent, right-sized **bounded contexts** (DDD's term for a part of the domain with its own model) that can be built in parallel.
4. **Align with AI capability.** Today's AI cannot reliably turn high-level intent into code alone. "The developers retain ultimate responsibility for validation, decision-making, and oversight."
5. **Cater to building complex systems** (see Audience).
6. **Keep what helps humans and AI work together.** User stories stay, because they are "well-defined contracts" between humans and AI. The **Risk Register** (the organisation's list of known risks) stays, so that AI plans and code follow the organisation's risk rules.
7. **Make the change easy through familiar terms.** A practitioner should be able to start in one day. Old terms get new names when their meaning changes; for example, Sprints become **Bolts**.
8. **Fewer specialised roles.** Developers work across front end, back end, infrastructure, DevOps and security. Product Owners and developers stay, for oversight, validation and strategic decisions. New roles are added "only when critically necessary".
9. **Minimise stages, maximise flow.** Fewer hand-offs. But human validation stays, so AI code does not become "quick-cement" (rigid and hard to change later). Each human check works "as a form of 'loss function'": it finds and removes wasted work before it happens downstream.
10. **No hard-wired workflows.** AI-DLC does not prescribe a workflow per kind of work (new system, refactoring, defect fix, scaling). AI proposes a **Level 1 Plan** (the top-level list of steps) for the intent. Humans check and adjust it. Then AI breaks each step into **Level 2** sub-tasks, and so on.

## Artifacts

- **Intent**: a high-level statement of purpose: a business goal, a feature, or a technical outcome such as performance scaling. It is where AI starts breaking down the work.
- **Unit** (also "Unit of Work"): a self-contained piece of work that comes from an Intent and delivers measurable value. Like a subdomain in DDD or an Epic in Scrum. It contains user stories. Units are loosely coupled, so they can be built and deployed independently. AI proposes the Units; developers and Product Owners check and refine them.
- **Bolt**: the smallest iteration, like a Sprint but measured in hours or days. A Bolt covers a defined scope, for example some user stories of one Unit. A Unit can need one or more Bolts, in parallel or one after another. AI plans the Bolts; humans validate them.
- **Domain Design**: the business logic of a Unit, without infrastructure. AI uses DDD building blocks: aggregates, value objects, entities, domain events, repositories, factories.
- **Logical Design**: the Domain Design extended for the non-functional requirements (NFRs), with architecture patterns such as CQRS or circuit breakers. AI writes **Architecture Decision Records (ADRs)**, and developers validate them.
- **Code and Unit Tests**: generated from the Logical Design, with AWS services chosen by AI. AI runs the unit tests, analyses the results and proposes fixes to the developer.
- **Deployment Units**: what is shipped: packaged code (container images, Lambda functions), configuration (Helm charts) and infrastructure (Terraform or CloudFormation). AI generates the tests: functional, static and dynamic security, load. Humans check and adjust the test scenarios. Then AI runs them and links failures to code, configuration or dependencies.

All artifacts are linked to each other, for traceability in both directions (for example, a domain model element to its user story).

## Inception phase

Turns Intents into Units.

- Ritual: **Mob Elaboration**. The whole team (Product Owner, developers, QA, other stakeholders: "the mob") sits in one room at one shared screen, led by a facilitator.
- AI proposes the breakdown of the Intent into user stories, acceptance criteria and Units. The mob fixes parts that are "under-engineered or over-engineered" and adds real-world constraints.
- Output per Unit: a PRFAQ (Amazon's "press release and frequently asked questions" document; optional), user stories, NFR definitions, risks (matched against the Risk Register), measurement criteria traced to the business intent, and suggested Bolts.
- Claim: Mob Elaboration "condenses weeks or even months of sequential work into a few hours".
- Steps in the worked example ("Develop a recommendation engine for cross-selling products"):
  1. AI asks clarifying questions ("Who are the primary users? What key business outcomes should this achieve?").
  2. AI writes user stories, NFRs and risks. The team corrects them.
  3. AI groups stories into Units, such as "User Data Collection".
  4. The Product Owner adjusts the Units. Example: User Data Collection lacks privacy rules, so the Product Owner adds GDPR requirements.
  5. AI writes the PRFAQ. Developers and the Product Owner check it and the risks.

## Construction phase

Turns Units into tested Deployment Units.

- Order: Domain Design, then Logical Design, then code, then automated tests.
- Ritual: **Mob Construction**. All teams sit in one room, as in Mob Elaboration. They exchange the integration specifications from the domain models, make decisions and deliver their Bolts. The figure also shows **Mob Testing** (Product Owner, developers and AI); the example names "Mob Programming and Mob Testing rituals".
- At each task AI recommends tasks and offers options, for example design patterns, "User Experience" and tests. Developers validate every output and make the critical decisions.
- Worked example:
  - AI models the entities (Product, Customer, Purchase History). Developers refine the business logic, for example how to handle new customers with no purchase history.
  - AI proposes patterns (event-driven) and technology (AWS Lambda). Developers approve the trade-offs or override them: "Accepts Lambda for scalability but overrides the storage to DynamoDB for faster query performance."
  - AI generates code and functional, security and performance tests. Developers review code and test cases.
  - AI runs all tests and proposes fixes. Developers approve the fixes and rerun.
- **Brown-field** (changing an existing system): AI first reverse-engineers the code into models. **Static models** show components, responsibilities and relationships. **Dynamic models** show how components interact for the most important use cases. Developers and product managers check and correct these models. The rest is the same as for a new system. Inception and Operations are the same in both cases.

## Operations phase

Deployment, observability and maintenance.

- AI packages Deployment Units. Developers approve the deployment configuration and start the rollout to staging and production.
- AI analyses metrics, logs and traces, finds anomalies and predicts SLA violations. It uses incident runbooks to propose actions (scaling, tuning, fault isolation). It carries them out only "when approved by the Developers".
- Example: AI sees a latency spike and proposes scaling the engine, or more DynamoDB throughput.

## The workflow

The figure lists nine steps. Each step "builds semantically richer context to the next step".

- Inception: 1. Build context from existing code. 2. Elaborate the intent with user stories. 3. Plan the units of work.
- Construction: 4. Model the domain, code and test. 5. Solve for non-functional requirements. 6. Resolve the deployment architecture, code and test. 7. Generate infrastructure as code and test.
- Operations: 8. Deploy in production. 9. Monitor and manage incidents.

"Each step serves as a strategic decision point where human oversight functions like a loss function - catching and correcting errors early before they snowball downstream."

## Prompts (paper, Appendix A)

The paper gives prompts to practise AI-DLC by hand.

- A setup prompt fixes the folders: `aidlc-docs/plans`, `aidlc-docs/requirements`, `aidlc-docs/story-artifacts`, `aidlc-docs/design-artifacts`, and `aidlc-docs/prompts.md` for all prompts in order.
- Every task prompt gives AI a role ("expert product manager", "experienced software architect", "Cloud Architect") and repeats one pattern: write a plan as a Markdown file with checkboxes; mark steps that need the human's clarification; "Do not make critical decisions on your own"; ask for review and approval; after approval, do one step at a time and tick it off.
- The human answers with "I approve. Proceed." after reviewing and changing the plan.
- Prompts cover user stories, Units, the component model ("Do not generate any codes yet"), code generation, architecture and deployment (with a validation plan and a validation report), and IaC/REST APIs.

## Adoption (paper, section VI)

- **Learning by practising**: teams practise the rituals on real problems instead of reading documentation. AWS Solutions Architects run this as a field offering called "AI-DLC Unicorn Gym".
- **Embedding in tools**: customers build their own developer tooling around AI-DLC (Cognizant FlowSource, Aspire CodeSpell, HCL AIForce are named).
- The paper says AI-DLC "does not deviate much from the existing Agile methods".

## Relation to Kiro and Amazon Q Developer

- The blog names Amazon Q Developer and Kiro as tools that already change how software is built. To start, it points to "Amazon Q Developer rules and Kiro custom workflows", and links Kiro's steering documentation.
- The aidlc-workflows repository runs the method in Kiro CLI and Kiro IDE, and equally in Claude Code, Codex CLI, Cursor, opencode and GitHub Copilot. It recommends Claude Opus 4.8. "The methodology itself is provider-independent."
- So in the primary sources, Kiro is one tool to run AI-DLC in. It is not the method itself.

## AI-DLC Workflows 2.0 (the later specification)

Version 1 ran the lifecycle as stages "with a human in the loop". Version 2 keeps the method but aims "progressively towards autonomous software delivery — reducing human intervention as machine-checkable verification expands". Its principles:

1. **Human judgement can be distilled into machines.** Today AI-DLC "relies heavily on human stakeholders at every stage". That is a starting point to improve, not a permanent state.
2. **Every intent starts ambiguous.** AI must ask clarifying questions "without making assumptions" before it solves anything.
3. **AI as a self-correcting solver.** Given inputs, outputs and post-conditions, AI can loop until it meets them. This needs post-conditions "checkable by a program the AI cannot modify", a tractable success criterion, and cheap iterations. Build & Test and infrastructure fit this. Requirements, design critique and UI mock-ups keep human validation for now. Every loop has a halting condition (maximum iterations or token budget). If AI does not converge, it escalates to a human.
4. **Three compartments per task**: (1) "What": inputs, outputs and required intermediate artifacts; (2) "How do we know it's right": post-conditions for self-checking; (3) "What did we learn": which observations become candidate rules. Example: without a UI standard, AI must ask a human about a dashboard's colour scheme. With the organisation's UI standard and a check for violations, it need not ask.
5. The construct fits every stage, creative or mechanical.
6. **Staged decomposition, not one shot.** "Build me this app" in one step fails: too many post-conditions at once, and too large a search space. Version 1's stages were "too opinionated" for customers, so version 2 uses **Skills** (per the agentskills.io specification) as the smallest building block. Stages and phases become flexible ways to group them.
7. **Autonomy in safe increments.** Start with the rules you can already codify, add more over time, and let the safe increment grow.
8. **Extensibility.** Customers can add rules, replace rules, or add new stages.
9. **Learning from practice ("Compound Engineering").** Every human correction is a candidate rule. If a user keeps rewriting one section or overriding one design decision, the stage proposes a post-condition or a guardrail. A human approves it before it becomes active.

Verification comes in two kinds. **Inferential** rules are LLM instructions, for checks that are not pass/fail, such as most code review rules. The specification warns that a model that judges its own output may meet "the letter of the check without satisfying its intent". So a stage with only LLM-judged checks "will not self-halt"; it still shows its output to a human. **Computational** checks are scripts or linters, for rules with zero tolerance, for example "no API endpoint shall be exposed without authentication".

An orchestrator composes the stages into a workflow, adapts the plan while it runs, enforces halting conditions, handles escalations and keeps an audit trail. Implementation guidelines include: "non-bootstrap stages require explicit approval"; "new rules are admitted deliberately, not silently"; and "agents do not recursively spawn other agents".

## The aidlc-workflows repository

- Command: `/aidlc Build a REST API for inventory management`. AI-DLC picks a workflow, "asks for missing decisions, and stops at approval gates before moving forward".
- 5 phases (Initialization, Ideation, Inception, Construction, Operation), 33 stages, 14 agents (11 domain experts, 2 reviewers, 1 composer), 132 audit event types. State lives in `aidlc-state.md`.
- "Small Mob, Broad Agents": a few broad agents instead of many narrow ones, because narrow specialists recreate "waterfall handoff chains".
- After each stage from Ideation on, the human reviews and approves. In Construction, routine checkpoints can pass without stopping.
- 11 **workflow profiles** set how much ceremony a piece of work gets. Examples: Express (7 stages, for clear requirements), Bugfix (6), Proof of concept (5), Classic (15, the version-1 style), Feature (30), Enterprise (30, Comprehensive depth, for regulated work). Express is not for "ambiguous, cross-team, regulated, or architecture-heavy work. Its speed comes from intentionally removing those decision surfaces." Enterprise keeps everything "because the cost of an undocumented decision is higher than the cost of the additional ceremony".
- Reviews in Classic are advisory: one pass per stage, with findings shown at the approval gate.

## Recurring principles

1. AI leads: it plans, asks, proposes options and trade-offs. Humans validate, choose and approve at every step.
2. No implementation before a human has approved the plan. "Do not make critical decisions on your own."
3. Human checks are a "loss function": catch errors early, before they grow downstream.
4. Work is broken down in levels: Intent, Units, Bolts, tasks; Level 1 Plan, then Level 2.
5. Every artifact is a file in the repository. Together they are the AI's context memory and give traceability.
6. A design technique is part of the method. The defined flavor is DDD: domain model first, then logical design, then code.
7. Decisions are made together, in mob rituals in one room.
8. Old artifacts that help alignment stay: user stories, Risk Register, ADRs, PRFAQ.
9. AI generates and runs the tests; humans check the test scenarios and approve fixes.
10. (Version 2) Human effort should fall over time: turn human judgement into checks a program can run, then give AI more autonomy in safe steps.

## Compared with the Anthropic and OpenAI summaries

See `anthropic-ai-native-sdlc-playbook.md` and `openai-ai-native-engineering-team.md`.

- **More ceremony at the start.** AI-DLC adds group rituals (Mob Elaboration, Mob Construction) and a fixed design technique (DDD). Neither Anthropic nor OpenAI prescribes a design method or a team ritual.
- **Different direction of control.** AI drives and humans approve each step. OpenAI has the agent do a first pass that humans review. Anthropic has humans approve fixed files (intent, spec, plan).
- **Less on review and CI.** The paper says little about code review, CI or hooks. Version 2 adds machine-checkable post-conditions and an audit trail, closer to Anthropic's hooks and evals.
- **Shared:** humans own the critical decisions; work is planned before it is built; artifacts live in the repository; corrections become lasting rules (Anthropic: "twice → CLAUDE.md"; AI-DLC 2.0: "every correction is a candidate learning"); autonomy grows step by step.

## Not read

- The blog's "mental model" figure; its content was read from the text around it.
- The rest of the aidlc-workflows documentation: the phases and stages guide (stage names), agents, interaction modes, rules and learning loop, worked examples, the glossary, and the workflow profiles after MVP.
- Other AWS posts: "Building with AI-DLC using Amazon Q Developer" (AWS DevOps blog), "How Dynata scaled AI across the development lifecycle with AI-DLC and Kiro IDE" (AWS Architecture blog), and the Rescale post (AWS Machine Learning blog).
- The aws-samples repositories (sample-collaborative-ai-dlc, sample-ai-driven-development-lifecycle-platform).
- Kiro's own documentation.
