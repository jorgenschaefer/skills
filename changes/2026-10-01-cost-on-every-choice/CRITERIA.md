# Criteria: show the cost of every option find-criteria offers

## Problem
`/find-criteria` already tells the model to give each alternative its effort and the complexity it adds to the code (`find-criteria/SKILL.md`, the "Propose at least three genuinely different alternatives" paragraph). In a run in late September 2026 it gave neither. It recommended the option that was slightly nicer for the user but much more complex, and the user caught that only by working out the complexity themselves. What is wrong: the requirement is written down but didn't hold, so the user can't count on seeing what each alternative costs. What should be true instead: whenever alternatives are laid out, the user sees each one's cost next to what it gives, without working it out themselves. That way they can overrule a recommendation whose gain doesn't justify its cost.

The instance: `/find-criteria für von-an-weg-im-etb` in the einsatz project on 2026-09-30 (`changes/2026-09-30-von-an-weg-im-etb/` there). The first choice, the approach (A separate fields, B a header line in free text, C a suggestion menu in the text field), gave each option its *Aufwand* and *Komplexität*. The second choice came up while the specimen was being built: three ways to enter Von/An on a phone (1 fields with suggestions, 2 chips per field, 3 recently used pairs). It gave no effort and no complexity for any of them and recommended Variante 2. The rule is scoped to the alternatives at the start of the loop, and a later choice was not read as falling under it.

## Acceptance criteria
- **AC-1** Whenever `/find-criteria` puts alternatives for what the change does or how it is built to the user, each alternative shows its effort and the complexity it adds to the code next to what it gives the user. That covers the approach, variants in a specimen, and any such choice that comes up later in the loop. Yes/no questions are not choices between alternatives and carry no cost: approving the ACs and nudges, writing an ADR, objecting to a nudge.
- **AC-2** Effort is a T-shirt size on the scale XS, S, M, L, XL. The skill doesn't tie the sizes to hours.
- **AC-3** Complexity is a few words naming what the option adds to the code (for example "a migration for entries and versions"), not a size.
- **AC-4** The sentence "No weighting, no scoring: the user picks, and you may recommend." is gone from `find-criteria/SKILL.md`, and nothing replaces it.
- **AC-5** The description of `find-criteria` in `README.md` says the same as the skill about what each option shows.

## Agreed design
The cost rule leaves the "Propose at least three genuinely different alternatives" paragraph in `find-criteria/SKILL.md` and becomes a rule under `## Throughout`, which applies to every choice between alternatives put to the user. The size scale for effort and the rule that complexity is said in words go with it.

## Nudges
- Move the rule rather than copy it: the "three alternatives" paragraph keeps everything except the sentence about effort and complexity and the one AC-4 removes.
- Name the variants in a specimen in the rule, since that is where it failed on 2026-09-30.

## Out of scope
- Having the recommendation weigh cost against gain. The user said seeing the cost is enough.
- Checking whether the effort and complexity given are right.

## Ruled out
- **The specimen page carries each variant's cost** - covers specimens only, not other choices that come up later.
- **A fresh subagent reviews each set of options before the user sees it** - costs time and tokens on every choice to guard against wrong estimates, which have not been a problem.
- **Every choice is recorded with its costs in `CRITERIA.md` and checked by the criteria's reviewer** - comes after the user has already chosen.
