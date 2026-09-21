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
# documents beside them, and README.md. The intents and the ticket records are
# history and name retired things on purpose.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

dangling="" docs=0 refs=0 missing=""

# One list for both checks: the narrower of the two used to miss a format
# document telling someone to run a script that was gone.
while IFS= read -r doc; do
  docs=$((docs + 1))
  from="${doc#$ROOT/}"

  # `/name` and `name/SOMETHING.md` in backticks: the two shapes these documents
  # use to send a reader somewhere.
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
  while IFS= read -r script; do
    [ -n "$script" ] || continue
    refs=$((refs + 1))
    [ -f "$ROOT/$script" ] || missing+="$from -> $script"$'\n'
  done < <(grep -o '`\.\{0,1\}/\{0,1\}[a-z][a-z0-9-]*\.sh`' "$doc" \
             | tr -d '`' | sed 's|^\./||' | sort -u)
done < <(find "$ROOT" -name SKILL.md -o -name '*_FORMAT.md' -o -name README.md \
           | grep -v '/\.git/' | sort)

[ -z "$dangling" ] \
  && ok "no live instruction points at something that is not there" \
  || bad "no live instruction points at something that is not there" "$dangling"

[ -z "$missing" ] \
  && ok "every script a document names is there" \
  || bad "every script a document names is there" "$missing"

# Both checks above are "no failures found", which is what an empty tree also
# looks like.
expect_counted "$docs" "documents"
expect_counted "$refs" "references"

finish
