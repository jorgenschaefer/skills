#!/usr/bin/env bash
#
# The test that live instructions point at things that exist.
#
#   tests/no-dangling.sh
#
# Retiring half a pipeline is mostly deletion, and the failure it invites is not
# deleting too much - it is leaving a sentence that sends an agent to a skill
# that is gone. The agent does not fail; it reads nothing, carries on, and the
# instruction that was supposed to bind it silently does not.
#
# Scoped to what an agent is actually told to do: every SKILL.md, the format
# documents beside them, and README.md. A change's own paper - its CRITERIA.md
# and tickets - is written for that one change and deleted with it.
#
# Sections are checked the other way round. Naming a section of a document was
# only ever done to CODING_STANDARDS.md, and that is now the thing being
# forbidden rather than resolved, so there is nothing left to resolve. A section
# of some other document - a ticket's `## Done when` - names a document the
# skill writes or reads; which one it means is often nowhere stated, and
# grepping for it would fire on every heading in the repository. Those are read
# by a person.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."

# shellcheck source=lib.sh
. "$HERE/lib.sh"

dangling="" docs=0 refs=0 missing="" coupled="" sectokens=0

# The standard is read whole or not at all. A document that names one of its
# sections is telling a reader which part to apply, which is the same as telling
# them the rest is optional - and it pins the wording of a heading it does not
# own. The copies are identical and `test.sh` is what holds them so, so
# whichever ones exist give the same answer.
standard="$(cat "$ROOT"/*/CODING_STANDARDS.md 2>/dev/null | grep '^#\{1,\} ' | sort -u)"

# One list for both checks: the narrower of the two used to miss a format
# document telling someone to run a script that was gone.
while IFS= read -r doc; do
  docs=$((docs + 1))
  from="${doc#"$ROOT"/}"

  # `/name` and `name/SOMETHING.md` in backticks: the two shapes these documents
  # use to send a reader somewhere.
  # shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    # `mockups/` and `tickets/NN-slug.md` are shapes, not references: a trailing
    # slash or a placeholder segment means the document is describing a path
    # rather than sending a reader to one.
    case "$ref" in */|*NN*|*'<'*) continue ;; esac
    refs=$((refs + 1))
    case "$ref" in
      */*) [ -e "$ROOT/$ref" ] || dangling+="$from -> $ref"$'\n' ;;
      *)   [ -d "$ROOT/$ref" ] || dangling+="$from -> /$ref"$'\n' ;;
    esac
  done < <(grep -o '`/[a-z][a-z0-9-]*`\|`[a-z][a-z0-9-]*/[A-Za-z0-9_.-]*`' "$doc" \
             | tr -d '`' | sed 's|^/||' | sort -u)

  # And the scripts. With or without the `./`: the leftover that got through
  # this check the first time was written `loop.sh`, not `./loop.sh`.
  # shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
  while IFS= read -r script; do
    [ -n "$script" ] || continue
    refs=$((refs + 1))
    [ -f "$ROOT/$script" ] || missing+="$from -> $script"$'\n'
  done < <(grep -o '`\.\{0,1\}/\{0,1\}[a-z][a-z0-9-]*\.sh`' "$doc" \
             | tr -d '`' | sed 's|^\./||' | sort -u)

  # And no section of the standard, named anywhere at all. A section of some
  # other document - a ticket's `## Done when` or its `## Record` - is a
  # skill specifying a document it writes or reads, which is its own business.
  # shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    sectokens=$((sectokens + 1))
    heading="${tok#\`}"; heading="${heading%\`}"
    ! printf '%s\n' "$standard" | grep -Fxq "$heading" \
      || coupled+="$from -> $heading"$'\n'
  done < <(grep -oE '`#+ [^`]+`' "$doc" | sort -u)

done < <(find "$ROOT" -name SKILL.md -o -name '*_FORMAT.md' -o -name README.md \
           | grep -v '/\.git/' | sort)

if [ -z "$dangling" ]; then
  ok "no live instruction points at something that is not there"
else bad "no live instruction points at something that is not there" "$dangling"; fi

if [ -z "$missing" ]; then
  ok "every script a document names is there"
else bad "every script a document names is there" "$missing"; fi

if [ -z "$coupled" ]; then
  ok "no document names a section of CODING_STANDARDS.md"
else bad "no document names a section of CODING_STANDARDS.md" "$coupled"; fi

# The checks above are all "no failures found", which is what an empty tree also
# looks like.
expect_counted "$docs" "documents"
expect_counted "$refs" "references"
expect_counted "$sectokens" "named sections"

finish
