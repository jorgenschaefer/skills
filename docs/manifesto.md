# Core ideas

These are the ideas behind good software with coding agents. They say what
matters, not how to do it. Any way of working is fine as long as it serves them.

## Software exists to solve real problems

Software is not a goal in itself. It supports people in their real work, and it
is good when they can trust it. Trust rests on four goals, in this order:

1. **Utility**: it does what the user needs, not just what they first asked for.
2. **Security**: nobody can do or see more than they should.
3. **Usability**: the user doesn't have to think about how to use it.
4. **Maintainability**: the next change is quick and easy.

Agentic coding changes how software is made. Many rules and best practices come
from the time before agents. They have to earn their place again. The four
goals don't, because they describe good software in either world.

## The developer's attention is the bottleneck

Agents make the work faster, so the developer's attention becomes the limit.
Spend it where it is worth the most.

**What matters is harm that is hard to undo.** Most harm can be measured by how
hard it is to undo. Leaked information cannot be unleaked. Data that was lost
or sent stays lost or sent. A promise made to other systems stays made. A user
who stopped trusting the software is hard to win back. An outage that is
over, with nothing lasting broken, is less bad.

**Decisions that matter go to the developer. The rest don't.** Building
software takes hundreds of small decisions. Most can be changed later without
any fuss, and the agent makes those itself. A few can do harm that is hard to
undo, and those are the developer's. Telling them apart is not easy, and it is
part of the work. A decision that was made does not become important just
because it was made.

**A review shows what matters.** When the developer looks at a change, they
see what is risky and hard to undo, not everything that changed.

**An agent tries the change first.** Before the developer spends time on a
change, an agent uses it the way a real user would and finds the problems it
can. To do that, the agent has to know what the software is really used for,
and by whom.

## Understand the problem and the domain

**Find the real problem.** People often bring a solution to a problem they
haven't named. A good solution needs the real problem. But a short request
doesn't need a long interview.

**Understand the domain.** Software models something in the real world. Focus
on that world and its rules, not on the software. The people and the code use
the same words for the same things.

## Build small and learn early

Nobody can specify everything in advance. You learn by using the software. So
build the smallest thing that solves the problem, use it early, and learn from
it. Do this before much time has gone into it, and before decisions that are
hard to undo have been made. Every feature has to earn its place.

## Think wide before narrowing

When exploring a problem, consider several views and approaches. Don't jump to
the first solution. Propose alternatives and put them to the developer so they
can think them through. Ask instead of assuming.

## Check with fresh eyes

Whoever wrote something reads their own intentions into it. A reviewer that
hasn't seen the reasoning, and tries to find what is wrong, sees what the author
cannot.

## Keep improving

Friction in the code, and in the way of working, gets noticed and fixed. This is
how the next change stays quick.
