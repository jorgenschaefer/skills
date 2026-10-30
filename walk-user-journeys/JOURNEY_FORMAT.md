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

## When it goes wrong
- <At step n, if <what goes wrong>, the user sees <what they see>, and <what happens to their work>.>
```

## What the parts are for

**Written in the user's words.** The developer approves journeys without reading the code, and the code uses the same words for the same things.

**"Who" grants access.** Everything else is denied by default: a user can do and see what their journeys give them, and nothing more. A journey several kinds of user go through names each of them.

**Steps are numbered, and a test names its journey and step.** When a test fails, it says which step broke. A change that renumbers the steps changes the tests with it.

**A step no test can show ends in *(judged)*.** The developer then knows that only an agent's opinion stands behind it.

**"When it goes wrong" holds the failure cases.** Each gets a test like a step. Omit the section when nothing at all can go wrong.
