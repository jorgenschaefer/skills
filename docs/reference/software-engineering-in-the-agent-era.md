# Software Engineering in the Agent Era: From Trustworthy Change to Human–Agent Software Organizations (arXiv 2609.04630) — summary

Source: https://arxiv.org/abs/2609.04630 (44 pages: 41 pages of text and 3 of references, read 2026-11-06).
Authors: Zhongjie Wang and Mingyi Liu, Faculty of Computing, Harbin Institute of Technology, China.
Date: 4 September 2026 (v1). The survey of related work is frozen at 2 September 2026.
Kind: a theory paper. It defines concepts and says how to measure them. It contains no experiment, case study or data of its own. The authors say so: "The contribution is theory construction and operationalization; empirical validity remains open."
Audience: software engineering researchers. Tool builders and engineering leads may find the concepts useful, but the paper gives no step-by-step practice.

## Core idea

Agents make one thing cheap and elastic: digital execution (reading code, writing code and tests, migrating, running tools). Other things do not scale with it: deciding what the system should do, verification, integration, human attention, and accepting the remaining risk. The paper writes this as "Execution Capacity ≫ Judgment, Verification, Integration, and Responsibility."

So the thing to govern is no longer human activity, but the software change itself. The shift is "Human Process Control → Trusted Change Governance."

Three constructs carry the paper:

- **Trustworthy Change (TC)**: one software change, followed from intent to operation. It can span many agents, tasks and commits.
- **Human–Agent Cell (HAC)**: one human with their agents, context, tools, permissions and budget. It is the unit that does the work. It produces candidates and evidence, but "execution alone does not confer acceptance authority."
- **Responsibility Topology**: how the authority to accept residual risk is spread in an organization. Either one final anchor (single-center), or several independent anchors who must all accept (multi-anchor).

Formula: "Agent SE = Common Engineering Core + Responsibility Topology."

The authors say the parts are not new. Responsibility, change management, specification, verification and oversight all predate the paper. The claim is narrower: agents change how these parts fit together.

## The running example

One example runs through the whole paper. It is an illustration, "not a case study". An order system has `status = {active, cancelled}`. `cancelled` mixes two meanings: the user cancelled, or the payment timed out. The fix adds `expired`.

In code this is one enum value and a few branches. Agents can spread it quickly through models, services, SDKs, tests, analytics and docs. But the open questions are larger:

- What if a successful payment callback arrives after the timeout?
- Does the new status interact with refunds in progress?
- Can historical data tell the two closure reasons apart?
- How does an old SDK behave when it sees the new value?
- When does analytics adopt the new meaning?
- Who may accept the changed order and payment behaviour?

The point: "a small artifact change need not imply a small semantic scope, verification scope, or responsibility scope."

## From human process control to change governance (Section 2)

Table 2 lists where agent capability outruns the rest, and the control each case needs:

| Capability grows faster than... | Typical failure | Control needed |
|---|---|---|
| intent clarification | fast implementation of undecided meaning | intent and specification |
| integration | locally correct changes conflict system-wide | semantic integration |
| verification | candidate changes pile up | verification backpressure |
| shared-state sync | agents act on stale facts | context coherence |
| task authority (tool power) | agent acts too widely | task contract and sandboxing |
| risk acceptance (release) | deployment before risk is closed | responsibility gate |
| lifecycle cost (generation gets cheap) | rework and long-term duties underestimated | accounting per accepted change |

All share one shape: "execution has completed while the engineering conditions of the software change remain open."

Five loops govern a change: Intent → Delegation → Verification → Integration → Operation. Specification turns intent into something that can be delegated. Evidence is what verification produces. Responsibility runs through all five loops; it is "not a sixth stage."

Existing methods keep their place but sharpen: requirements limit semantic freedom; architecture limits how far a change spreads and how much context it needs; tests and formal methods build evidence; configuration management keeps the line between candidate and baseline; DevOps feeds runtime facts back.

## Human–Agent Cell and Responsibility Topology (Section 3)

**HAC** = ⟨human, agents, local memory, tools, permission, budget⟩. Changing the model or adding agents does not make a new HAC; changing the human does.

- Input: an authoritative-state snapshot, a task-and-resource contract, and signals that state changed.
- Output: a candidate change, proposals for authoritative state, and local evidence.
- "Local memory does not automatically become organizational fact." A fact becomes binding only by: Proposal → Authorized Acceptance → Versioned Commit.

**Responsibility Anchor**: a natural person or institutional role with formal authority to accept or reject residual risk for a baseline or domain (for example Product Owner, Security Owner, Release Authority). An agent can act inside a delegated boundary and be logged as executor. But acceptance of residual risk stays with an identifiable human or legal subject. The paper cites the EU AI Act as consistent with this.

**Single-center**: one anchor R* can accept or reject risk for the whole baseline, and can override everyone else. A one-person company is the common case, but headcount does not define it.

**Multi-anchor**: at least two anchors, each with an acceptance right in a domain that the other cannot normally revoke. A change is accepted only when all anchors in its required set K accept.

Key claims:

- Topology is independent of the number of humans, agents or HACs. A founder who goes from one agent to twenty is still single-center. Two engineers can be multi-anchor.
- Extra reviewers, contractors or agents add execution or evidence capacity. They do not create a new responsibility center.
- Topology is not the same as CODEOWNERS, approval counts or repo permissions. To identify it, look at three sources: written rules (de jure), technical enforcement (branch protection, IAM, release gates), and what actually happens (de facto). If they disagree, record the conflict; until it is resolved the change has no valid acceptance path.
- "Delegation Graph ≠ Responsibility Graph." Agents can finish their tasks and the responsible anchor can still reject the result.
- Distributed execution causes context divergence and staleness. Distributed authority causes joint acceptance and the need to close responsibility. The paper keeps these two sources apart (Table 4).

## Trustworthy Change (Section 4)

A TC is a cross-artifact identity for one change. It is not six new documents. Its six components (Table 5):

1. Intent and specification: purpose, success and failure conditions, forbidden outcomes.
2. Delegation and resource envelope: who acts, with which permissions, scope and resources.
3. Change and provenance: what changed, where it came from, execution history.
4. Evidence: claims and what supports them.
5. Integration and runtime state: baseline, release, monitoring, recovery.
6. Responsibility: who proposed, authorized, verified and accepted it.

**States**: Candidate → Eligible → Accepted (plus Rejected, Abandoned, and Acceptance Pending).

- Candidate: execution produced something ready to evaluate. Its cost counts whether or not it is accepted.
- Eligible: no rejection condition R1–R6 applies.
- Accepted: Eligible, and every required anchor has accepted.

The split keeps three things apart that "done" usually blurs: implementation finished, technically qualified, and risk accepted. "Organizational willingness to proceed cannot make an inadequately evidenced candidate Eligible."

**Rejection conditions (Table 6)**:

- R1 Intent/specification: goal, non-goals, boundary or key meaning still undecided.
- R2 Delegation/resource: authority exceeded, wrong scope, budget out of control.
- R3 Change/provenance: origin or process cannot be traced.
- R4 Evidence: a material claim lacks enough evidence.
- R5 Integration/operation: release plan, observability or recovery not ready.
- R6 Responsibility: the required responsible subject or acceptance path is missing or invalid.

R2, R3 and parts of R5 can often be automated. R1 and R4 often need human or expert judgment. R6 needs analysis of formal authority. An anchor that exists but has not signed yet is "Acceptance Pending", not an R6 failure. The agent that produced a candidate "cannot by itself close the responsibility structure required for its own candidate."

Eligibility is relative to a version of the authoritative state. If a fact the change depends on changes, eligibility must be checked again. Acceptance is also not permanent: new runtime facts can invalidate its assumptions and start a new TC.

Responsibility questions per loop: who may define the goal; who may authorize agent action; who judges the evidence sufficient; who may admit the change to the baseline; who accepts runtime risk and recovery duties.

Four assurance questions for any TC: Is intent decided enough? Are the claims evidenced enough? Does operation still support the acceptance assumptions? Is responsibility still identifiable and actionable?

Table 7 maps classic change management onto TC (change request → intent; impact analysis → specification and risk analysis; review/testing → evidence; change approval → responsibility acceptance; and so on). What agents add: delegated permission, resource envelopes, agent provenance, evidence independence, runtime drift, and topology.

## Common engineering methods (Section 5)

### Intent and progressive specification

Separate five kinds of information: fact, evidence, assumption, preference, decision. In the example: "cancelled conflates two causes" is a fact; support data is evidence; "the new enum will not break old clients" is an assumption until verified; "users should see the difference" is a preference; introducing `expired` is a decision. Decisions that change meaning should go into authoritative state.

Specification is a path: natural intent → clarification → structured specification → executable constraint → formal specification.

- Too little specification gives agents too much room: more divergence, clarification and rework.
- Too much costs effort to write, maintain and load as context.
- The target is a **Minimum Sufficient Specification**. This is a hypothesis, not a finding. Figure 6 (cost curves) is "illustrative - not fitted to data".
- How much rigor is needed depends on "ambiguity, impact, irreversibility, and verifiability."
- Agents are good at finding ambiguity, asking clarifying questions, drafting specifications, and proposing contracts, tests and properties. "Semantic commitment remains with the authorized human responsibility subject."

### Architecture, change locality and task contracts

Architecture for agent work should be:

- agent-operable: stable commands, clear schemas, repeatable environments, callable tools;
- human-understandable: responsible people can still follow states, dependencies, interfaces and invariants;
- human-takeoverable: agent tasks can be stopped, reproduced, rolled back, handed off.

**Change locality** has three spans: artifact span (files, modules, interfaces touched), context span (how much context and how many invariants must be loaded), responsibility span (how many HACs, domains and anchors). Poor locality is expected (not shown) to raise context, integration and verification cost. Good modularity may lower agent context and verification cost, not only human cognitive cost.

For security, authorization, accounting and other critical logic: a **"Deterministic Core + Probabilistic Shell"**. Deterministic mechanisms bound the unacceptable consequences; agents do the work around them.

**Task contract**: {Goal, Context, Scope, Permission, Budget, Acceptance, Stop, Handoff}. Resource envelope: ⟨Token, Compute, Tool, Wall-clock time, Human attention⟩.

The stop condition is first class. The agent should stop and escalate when it needs unauthorized data, wider write permission, "an irreversible migration", more budget, or faces a high-risk consequence it cannot judge within its boundary.

**Threat model**: the main risk is untrusted input connected to high-privilege tools. Threats: direct and indirect prompt injection, tool/MCP poisoning, data exfiltration, privilege escalation, persistent context poisoning. The goal is not that the agent spots every attack, but "Compromise of Interpretation ⇏ Unbounded Compromise of Action": permissions, sandboxes, hooks, egress rules and confirmation for high-impact actions limit the harm. Table 8 pairs each threat with controls.

### Construction and evidence-based verification

- Aim: candidates that are "comparable, verifiable, and revocable inside controlled environments" (branches, worktrees, containers, sandboxes).
- Minimum provenance: model or agent, context version, tool calls, dependency changes, manual edits, build/test environment.
- More candidates are cheap to make, but each adds comparison and verification cost.
- Verification starts by stating claims (e.g. "payment timeout ⇒ expired"), then links each claim to evidence.
- Evidence quality depends on coverage and **independence**: model/method, context, criterion and responsibility independence.
- The wider problem than hallucination is **common-mode failure**: agents that share a base model, training data, missing assumptions or retrieval sources make the same mistakes. "Model diversity alone does not establish evidence independence."

**Risk-adaptive evidence (Table 9)**, given as illustration:

| Change type | Minimum evidence |
|---|---|
| Low risk, local, easy to reverse | deterministic test + provenance + reproducible command |
| Cross-module or public contract | regression + contract test + executable reproduction |
| Data or state migration | invariant + representative migration test + rollback rehearsal |
| Concurrency, payment, authorization | property/fuzz/concurrency test + independent verification |
| Security or compliance property | independent review + policy check + explicit acceptance |
| Very high risk and formalizable | executable/formal constraint + independent evidence |

Different anchors may set different minimum evidence for their domains.

### Integration, operation and recovery

- Only an Accepted TC may change the authoritative baseline.
- "Agent SE must distinguish textual merge from semantic integration": two candidates can merge cleanly in Git and still contradict each other in contracts, state models or data meaning.
- New drift sources after release: model drift, context drift, cost drift, architecture drift.
- On anomalies, autonomy shrinks step by step: auto-execute → human approval → read-only → stop.
- Systems should support rollback, restore, reproduce and handoff.

## Single-center software engineering (Section 6)

"Distributed execution capacity with concentrated final responsibility."

- Schematic bound: effective concurrency ≤ min(how far the change can be split into independently verifiable parts, integration bandwidth, verification bandwidth, economic capacity). "Schematic rather than a calibrated empirical law."
- More agents raise the arrival rate of candidates, not the service rate of verification and acceptance. When generation outruns verification, a **verification queue** forms. The responsible person then leans on summaries, automated reviewers and quick approvals, "which may weaken genuine engineering judgment." The queue is an observable backpressure signal.
- Diagnostic: if the delay is in test runs, review bandwidth or understanding the architecture, add tools or HACs. If one anchor is asked to accept risks that need lasting independent judgment (regulation, safety, separation of duties), more capacity does not help: "The problem has moved from execution scaling to responsibility design."
- Evidence independence is harder with one center. Ways to raise it: deterministic static analysis, property-based testing, mutation testing, hidden tests, other model families, real-user validation, external expert review.
- The anchor's attention is the bottleneck: intent + specification + review + integration + incident + context recovery. If a small feature forces the anchor to rebuild understanding of many modules and agent traces, "high automation does not translate into stable leverage."
- As building gets cheap, deciding whether to make a change matters more. Full cost = creation + verification + integration + operation + long-term responsibility. Optimize cost per accepted change, not the price of a model call.
- Operations: known, low-risk, reversible actions can be pre-authorized to agents (collect logs, diagnose known failures, prepare rollback). High-impact, uncertain or irreversible actions go to the anchor. Choosing rollback vs forward fix vs temporary mapping "remains a risk-acceptance decision."
- Continuity: **takeoverability** (can a new person take over: find the baseline, get permissions, stop agents, restore service) and **anchor-absence resilience** (can the system wait or degrade safely while the anchor is away). "High automation creates neither property by itself."
- Table 11 failure modes: verification queue, same-origin assurance, cognitive overload, piling-up lifecycle obligations, anchor dependency.

## Multi-anchor team software engineering (Section 7)

- **Shared Authoritative Engineering State**: the set of binding facts (product intent, current spec, architecture decisions, API/data contracts, global invariants, ownership, accepted TCs, risk and release state). Each item has content, proposer, accepting anchors, version, effective time, and invalidation policy.
- "Authority and retrievability are distinct dimensions." A note can be accurate and widely copied yet have no authority. "Shared Memory ≠ Shared Authoritative State."
- Consistency by risk: strong for invariants, public contracts, ownership, production schemas, release state; eventual for exploratory plans; local for scratch memory and unaccepted ideas.
- **Context invalidation**: when authoritative state changes, each in-flight task picks Continue, MarkStale, Refresh, Replan, Reverify or Stop. In the example, contract v3 → v4: backend already on v4 continues; client on v3 refreshes and replans; payment late-callback analysis reverifies; a historical backfill that would need unsupported inference stops.
- A nine-step walk-through of the example under multi-anchor governance. Step 6: the payment candidate has no evidence for a late successful callback, so R4 fails, "even if the code compiles and ordinary unit and SDK tests all pass."
- "Execution Closure ≠ Responsibility Closure": all HACs can be done while one anchor has not accepted.
- **Layered evidence**: local → cross-cell → team → organization/external. Local is cheapest and most correlated. Cross-cell asks another HAC to check.
- **Augmented Conway hypothesis**: agent delegation and context dependency may shape software co-change structure beyond human communication. Proposed as testable, not tested.
- Team states: Planned → Delegated → Executing → Candidate → Eligible → Acceptance Pending → Accepted. Organizational memory should keep decisions, rationales, specs, invariants, ownership, accepted TCs and known risks. Chat transcripts and agent traces can be kept for audit but are not authoritative.
- Table 12 failure modes: context staleness, unauthorized truth (an unaccepted proposal treated as fact), delegation–responsibility misalignment, cross-cell semantic conflict, false independence (reviewers share a model), verification congestion, invalidation storm, responsibility orphan (an anchor leaves).
- The paper explicitly does not define a team process: "we do not prescribe a fixed team process script."

## Reference tool architecture (Section 8)

Three layers: HAC (local execution, permissions, candidate evidence), team (shared facts, invalidation, acceptance, integration), organization (identity, policy, compliance, cost).

Table 13 maps existing tool features to the framework:

- AGENTS.md / CLAUDE.md: part of the authoritative-state snapshot or task context; "authority depends on acceptance and versioning."
- Spec / plan: intent and specification.
- Skills / custom agents: delegated execution capability.
- MCP / tools: tool capability in a task contract.
- Hooks: delegation guard, stop condition, deterministic verification.
- Sandbox / worktree / VM: permission boundary and candidate isolation.
- Subagents: nodes in the delegation graph.
- Tests / CI: evidence and input to eligibility.
- CODEOWNERS / IAM: one form of evidence for the responsibility graph.
- Token usage / model routing: resource envelope.

The authors claim only that the framework can be built on existing infrastructure (Git, CI, IAM, policy engines). "It is not empirical validation of utility, cost, organizational impact, or developer experience."

## Measurement and economics (Section 9)

- Derive metrics from the concepts (goal–question–metric), not from whatever data is easy to collect.
- "A high commit count does not imply high TC throughput; many agent trajectories do not imply many independent verification sources; and a large team does not imply a multi-anchor topology."
- Unit of account: the **Accepted TC**, for comparisons within one project, not across projects.
- "Token ≠ Human Hours." Proposed measures: tokens per accepted change, human attention per accepted change, cost of rejected candidates, context staleness rate.
- "Verification investment should therefore scale with risk and impact rather than being maximized uniformly."
- Effort estimation: predictors could include ambiguity, context size, change locality, tool steps, risk, verification requirement and topology. No functional form is assumed.
- Ambiguity proxies: number of clarifying questions, unresolved spec slots, mutually exclusive readings, divergence between candidates, replans caused by clarification.
- Moving to multi-anchor: hard triggers (law, separation of duties, independent safety acceptance) decide it directly. Without them it is a cost comparison, and lower cost alone does not justify a new anchor.
- Human attention should be measured by structure (context switches, deep-work intervals, time to regain context), not just hours, and with care for privacy.
- Table 15 lists candidate metrics by category (output, resources, waste, flow, architecture, team context, verification, continuity).
- Closing example: measured only by coding time, the `expired` change looks dramatically faster with agents. But "Coding acceleration describes Construction; Agent SE must observe the complete Trustworthy Change Flow."

## Research and industry landscape (Section 10)

The authors separate what each kind of source can support. That a product has a feature shows only that it is in use, not that it improves quality. The external evidence they cite (none of it theirs):

- A 12-week case study (Davis et al.) proposes "governance conversion": recurring failures from fast agent work turn into durable engineering controls.
- AgentLens: final test success can hide process failures and "lucky passes."
- A benchmark study: labels such as "bug fix" or "feature" are poor proxies for what a task demands.
- OpenAI 2026 reports on contamination and signal/noise in coding benchmarks.
- A mixed-methods study of 448 Microsoft developers: accepted AI autonomy varies by task and person, and task accountability is linked to lower willingness to let AI act for the developer. The paper says this "does not validate Responsibility Topology."
- METR 2026: multi-agent concurrency and task selection make simple wall-clock comparisons hard to read.
- A source-code study of eleven production coding-agent harnesses finds common subsystems (loops, tools, context, safety, orchestration, extensions).
- Industry: EPAM's Agentic Development Lifecycle and a McKinsey August 2026 synthesis stress roles, approval gates and verification. "These sources are practice evidence, not proof."
- Adjacent governance work: AI-SDLC protocol language (approval gates, boundaries), graduated oversight by regulatory impact and reversibility, risk architecture for AI-native teams. The authors place their topology beside these, not above them.

Trend summary: "Prompt → Harness → Agent Runtime → Team/Organization Control."

## Falsifiable research agenda (Section 11)

Eight propositions, each with a signal that would weaken it (Table 19):

- P1 A minimum sufficient level of specification exists per task type.
- P2 Agent concurrency is limited by verification capacity: with fixed verification, accepted throughput saturates or falls.
- P3 More evidence independence means fewer escaped defects.
- P4 Change locality affects total cost.
- P5 Context invalidation reduces stale-context errors.
- P6 Topology explains outcomes beyond headcount and system size.
- P7 Mismatch between delegation and responsibility predicts unauthorized changes and rollbacks.
- P8 Takeoverability predicts transfer time and recovery cost.

Proposed studies:

- Specification levels for the same change: S0 one sentence; S1 plus normal examples; S2 plus counterexamples and non-goals; S3 state machine or decision table; S4 executable contracts or formal properties. Measure divergence, clarifications, tokens, verification effort, rework, escaped defects.
- Value of clarification: compare Always Ask, Never Ask, Confidence-Based Ask, Risk-Based Ask. VoC = expected loss without clarification − cost of clarification. Question: which mix of ambiguity and risk justifies interrupting the agent for a human decision.
- Verification sources compared: generator self-check, same-model reviewer, different-model reviewer, deterministic tool, cross-HAC check, domain expert.
- Concurrency turning point; attention fragmentation; "blind takeover" by someone not involved day to day; simulated absence of the anchor.
- Benchmarks should grow from Issue → Patch → Test Pass to Intent → Clarification → Candidate → Evidence → Acceptance → Runtime. Studies should report model, version, harness, tools, permissions, context, budget and date.

## Discussion and conclusion (Section 12)

- Very small human cores may run more products for longer. Multi-person responsibility stays necessary for independent professional duty, separation of duties, regulation, or continuous operations.
- The value of an extra person shifts from more labour to "independent knowledge, independent context, independent evidence, and independent acceptance." If everyone uses the same model and context, "headcount does not automatically increase assurance."
- Autonomy should not be the measure of maturity. Adapt it to impact, reversibility, detectability, available evidence and responsibility structure.
- "Requiring humans to approve every important action can itself create verification bottlenecks and rubber-stamping. Human attention should be concentrated where semantic commitment and residual-risk acceptance are actually required."
- Once a prompt contains state machines, interfaces, invariants and acceptance criteria, "it has entered the domain of specification." Engineers still need to understand behaviour, state, architecture, security, performance and data. Their value lies in "deciding what should change, constraining digital execution, identifying the evidence on which change may be accepted, and knowing when to reject or stop."
- Larger context windows do not make modularity obsolete. Goal of architecture: "Enable most changes to close within bounded context and bounded responsibility scope."
- Organizational memory shifts from "can we find it?" to "is what we found still authoritative?": Knowledge Retrieval → Authority Management.
- Limits: only two topology types; hierarchical, federated and other forms are out of scope. The framework "is not a finished empirical theory"; any of its central claims may fail measurement.
- Summary chain: HAC → Candidate Change → Eligible Change → Accepted Trustworthy Change. Agents grow the left side; engineering is responsible for reaching the right side "for reasons that can be inspected and challenged."

## Recurring principles

1. Govern the change, not the activity. Code done, technically qualified, and risk accepted are three separate states.
2. Execution is cheap; verification, integration, attention and acceptance are the bottleneck. More agents only lengthen the verification queue.
3. An agent produces candidates, proposals and evidence. Only an identifiable human or role accepts residual risk, and never for its own candidate.
4. Local memory and chat are not facts. A fact becomes binding only through authorized acceptance and a versioned commit, and changing it invalidates work built on it.
5. Verification links stated claims to evidence. The evidence needed scales with risk, and its independence matters more than the number of reviewers.
6. Specify as much as the risk needs and no more. Rigor depends on ambiguity, impact, irreversibility and verifiability.
7. Agents act with wide autonomy inside an explicit contract, with a first-class stop condition for irreversible, unauthorized or high-risk steps.
8. Spend human attention where meaning is decided and risk is accepted, not on approving every action.
9. Keep most changes local in code, context and responsibility. Modularity matters more with agents, not less.
10. State every claim so that it can be tested and fail.

## Compared with the Anthropic and OpenAI summaries

The other two are summarized in `anthropic-ai-native-sdlc-playbook.md` and `openai-ai-native-engineering-team.md`.

- **Different kind of source.** The other two are practitioner guides with steps, tools and customer examples. This is an academic theory paper with formal definitions, no practice steps, and no data of its own. It marks its own hypotheses clearly.
- **Unit of control.** The others are organized by lifecycle phase. This paper is organized around one object, the change, and its states (Candidate, Eligible, Accepted).
- **Who decides.** OpenAI's Delegate / Review / Own and Anthropic's human gates both say humans own judgment. This paper makes it formal: who holds the right to accept residual risk, and whether there is one such person or several.
- **New concerns not in the others:** stale context and invalidation of in-flight work, evidence independence and common-mode failure between agents on the same model, the verification queue as a limit on parallelism, takeover and absence of the responsible person, and counting cost per accepted change.
- **Shared:** humans own semantic decisions and risk acceptance; agents need a way to produce verifiable evidence; isolation (worktrees, sandboxes) and hooks bound the agent; autonomy shrinks or grows with risk; incidents and runtime facts start new changes.

## Not read

- Figures were read only as the text pdftotext extracted from them (labels and captions). Their layout was not checked.
- The paper has no appendices.
- None of the 58 cited works were read, including the empirical ones the paper relies on (the 448-developer Microsoft study, AgentLens, the harness study, METR, the Davis et al. case study).
