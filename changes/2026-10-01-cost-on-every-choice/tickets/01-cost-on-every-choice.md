---
criteria:  CRITERIA.md
closes:    AC-1, AC-2, AC-3, AC-4, AC-5
advances:
after:
status:    done
attempts:  0
---

## Build
Move find-criteria's rule that every alternative shows its effort and the complexity it adds out of the opening "three alternatives" paragraph and into `## Throughout`, so it covers every choice between alternatives in the loop, with effort as a T-shirt size and complexity in words. Drop the "No weighting, no scoring" sentence, and bring the README's description in line.

## Done when
> **AC-1** Whenever `/find-criteria` puts alternatives for what the change does or how it is built to the user, each alternative shows its effort and the complexity it adds to the code next to what it gives the user. That covers the approach, variants in a specimen, and any such choice that comes up later in the loop. Yes/no questions are not choices between alternatives and carry no cost: approving the ACs and nudges, writing an ADR, objecting to a nudge.

> **AC-2** Effort is a T-shirt size on the scale XS, S, M, L, XL. The skill doesn't tie the sizes to hours.

> **AC-3** Complexity is a few words naming what the option adds to the code (for example "a migration for entries and versions"), not a size.

> **AC-4** The sentence "No weighting, no scoring: the user picks, and you may recommend." is gone from `find-criteria/SKILL.md`, and nothing replaces it.

> **AC-5** The description of `find-criteria` in `README.md` says the same as the skill about what each option shows.

## Nudges
> Move the rule rather than copy it: the "three alternatives" paragraph keeps everything except the sentence about effort and complexity and the one AC-4 removes.

> Name the variants in a specimen in the rule, since that is where it failed on 2026-09-30.

## Context
`find-criteria/SKILL.md` (58 lines) is a Markdown skill, linked into `~/.claude/skills` by `sync.sh`, so editing it here is editing the one sessions read. Line 27 today:

> **Propose at least three genuinely different alternatives**, or say why the space holds fewer. Two that differ only in how much of the same thing they do are one. Give each its effort and the complexity it adds to the code. No weighting, no scoring: the user picks, and you may recommend.

On 2026-09-30, in the einsatz project's `/find-criteria für von-an-weg-im-etb` run, the opening alternatives carried effort and complexity, and the later choice between three input variants in the specimen carried neither and came with a recommendation. The rule was read as belonging to the opening alternatives only. The agreed design is to make it a rule under `## Throughout` (which today holds "End your turn at the first question mark", "Push back once" and "Stopping here is an ending"), where it applies to every choice between alternatives.

The skill's house style: each rule is one paragraph led by a bold imperative sentence, plain words, no lists inside a rule. The example of a good complexity line, from the einsatz run: "eine Migration für Einträge und Fassungen" - name what is added, not how big it is.

`README.md:170` describes find-criteria as offering "at least three genuinely different approaches with their effort and code complexity for the user to pick from". It says nothing about later choices, sizes or words.

The repository has no test that reads a skill's prose for meaning; `./test.sh` checks shared files are identical, shellcheck, the runner, that live instructions point at things that exist (`tests/no-dangling.sh`, which reads every SKILL.md and README.md), and `sync.sh`.

## Plan
1. **Take the cost sentence and the weighting sentence out of the "three alternatives" paragraph.** `find-criteria/SKILL.md:27` keeps its first two sentences and nothing else. Proof: `grep -n 'No weighting\|its effort' find-criteria/SKILL.md` finds nothing on that line.
2. **Add the rule under `## Throughout`**, before "End your turn at the first question mark", as one bold-led paragraph: every time alternatives for what the change does or how it is built are put to the user - the approach, the variants in a specimen, and any such choice later in the loop - each shows what it gives, its effort as a size from XS to XL, and in a few words what it adds to the code, not a size; a yes/no question (approving the ACs and nudges, an ADR, objecting to a nudge) is not such a choice. No tie of sizes to hours. Proof: read the paragraph against AC-1, AC-2 and AC-3 and both nudges, clause by clause.
3. **Bring `README.md:170` in line.** Replace "with their effort and code complexity for the user to pick from" with wording that says every choice between alternatives, the approach and later ones such as a specimen's variants, shows each option's effort as a size and what it adds to the code in words, next to what it gives, for the user to pick from. Proof: read it beside the new SKILL.md paragraph for AC-5.
4. **Run `./test.sh`.** Proof: all green; `tests/no-dangling.sh` in particular, since both files are among what it reads.

Decided here: the rule sits first under `## Throughout`, because it is the only rule there about content rather than turn-taking and reads better ahead of them. Cheap to move.

## Not here
- Having the recommendation weigh cost against gain. The user said seeing the cost is enough. Do not write anything about how a recommendation is chosen.
- Checking whether the effort and complexity given are right. No review step, no subagent.
- The specimen page itself does not carry the costs; they go where the choice is put to the user.
- `CRITERIA_FORMAT.md` and `find-criteria/VERIFY.md` stay as they are: choices are not recorded with their costs in `CRITERIA.md`.

## Left standing

- No automated test proves AC-1 to AC-5: the repository has no test that reads a skill's wording for meaning, and a grep would pin words rather than behaviour. Checked by reading the new text against each AC and nudge, by this build and by the review; `./test.sh` green.
