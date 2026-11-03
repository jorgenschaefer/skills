# Journey format

`journeys/<slug>.md`, one file per thing a user does, named after it, such as "pay-an-invoice.md". A journey describes the software as it is. A change edits the journeys it affects, so no two files describe the same thing.

```markdown
# <What the user does, in their words: "Pay an invoice">

**Who:** <the user, in their words: "a member who received an invoice">
**Wants:** <what they are trying to get done, not how>

## Steps
1. <What the user does, and what they see.>
2. <...>
3. <A step no test can show, such as "it feels quick", ends in *(judged)*.>
```

## What the parts are for

**A journey is light: who uses the software, and for what.** Agents read the journeys to find their way around the software and to learn what it is for. The details of each step live in the code and the hard tests.

**Written in the user's words.** The developer approves journeys without reading the code, and the code uses the same words for the same things.

**"Who" grants access.** Everything else is denied by default: a user can do and see what their journeys give them, and nothing more. A journey several kinds of user go through names each of them.

**A few steps: as many as a user would tell a colleague**, usually three to seven. Not every click, and not every special case.

**Steps are numbered, and a test names its journey and step.** When a test fails, it says which step broke. A change that renumbers the steps changes the tests with it.

**A step no test can show ends in *(judged)*.** The developer then knows that only an agent's opinion stands behind it.

**A journey holds no failure cases.** What the user sees when something fails is designed in a change's `spec.md`, and lasts in the code and its hard tests.
