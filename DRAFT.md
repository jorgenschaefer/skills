# Code is cheap, trust is not

This page asks two questions. What is a good way to build software when agents
write the code? And how do we keep trusting software that nobody wrote by hand?

## What changed

Most of what we know about building software rests on assumptions that no
longer hold.

1. **Code was expensive.** So we specified before we built, reviewed with care,
   and avoided throwing work away. Now code is cheap. Trying something and
   throwing it away often costs less than specifying it.
2. **The author stayed.** The people who wrote the code remembered why. An agent
   remembers nothing from one session to the next. Anything someone needs to
   know later must be written where the next agent will find it.
3. **The author answered for the work.** A human author has a reputation and a
   track record. An agent has neither, and it is just as confident when it is
   wrong as when it is right. What an agent says about its own work is not
   evidence.
4. **Writing code was the bottleneck.** Now the bottleneck is the human: their
   attention, and their judgement about what the software should do.

## Trust

Users trust software when it works. Every break they notice costs some of that
trust, and some breaks cost more: money, data, safety. Reading the code is no
longer a way to earn trust, because agents write too much of it. Trust has to
come from evidence that does not depend on the author.

## What is critical

Not everything the user decides needs protecting. "The dashboard shows the net
sum of my accounts, with shares at today's market value" is a rule: if it
breaks, it costs. "The header should be a bit taller" is a preference: if it
goes back, nothing is lost.

- **The user says what is critical:** which breaks would cost, and how much.
- **The agent points out risk:** the rules a change touches, and the rule hiding
  behind a preference ("the header never covers the content").
- **The agent asks only about rules,** never about preferences.

What is critical outlives every change. It is the user's concepts ("net worth
means all accounts plus shares at market value") and the worst cases.

## Three lines of defence

1. **Lasting checks** catch a break before the change ships.
2. **Observability** catches a break in production before users do.
3. **Users** notice. By then, trust is already lost.

For every critical rule, the agent says which line catches a break first, and
how fast. If the answer is "a user", that is a gap, and the user sees it.

## Lasting checks

A lasting check pins a rule whose break would cost.

- It names its rule, in the user's words or by the id of a worst case.
- It goes through a real interface: what a user or another program can use. It
  never reaches into the code.
- It is shown to bite: someone broke the code on purpose and saw the check fail.
- Weakening or deleting it is reported. For a worst case, it is the user's
  decision, made before the change.

Every other test is scaffolding. It helps build a change, and the agent may
delete it later without asking. How the agent builds, test first or not, is up
to the agent.

This is what lets code be cheap. Any part can be thrown away and rewritten, as
long as its lasting checks still pass.

## Keeping the code easy to change

Agents don't feel the pain of messy code, and they don't remember it. So the
pain has to be written down.

- **After each change, the agent records what was hard.** When "this was hard"
  keeps coming up in one area, that area needs cleaning up.
- **The code follows the concepts.** The agent reports where it doesn't ("net
  worth is computed in three places"), and the user decides whether that is
  worth cleaning up. Nobody approves an architecture.
- **Changes are small, and each has its checks,** so a break can be traced to
  the change that caused it.

## Spending human attention

- **Attention goes where the risk is.** A change that touches a critical rule
  gets the user's full attention. A change that touches none gets little.
- **Try before you specify, where that is cheaper.** A prototype the user can
  see often says more than criteria they approve on paper. Specify first where a
  mistake can't be undone.
- **The user can ask how anything works** and get the answer in their own words.

## What stays the same

The goals stay, in this order: utility, security, usability, maintainability.
The human decides what the software does and answers for it.
