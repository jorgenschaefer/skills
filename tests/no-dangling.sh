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

dangling=""
while IFS= read -r doc; do
  from="${doc#$ROOT/}"
  # `/name` and `name/SOMETHING.md` in backticks: the two shapes these documents
  # use to send a reader somewhere.
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    # `mockups/` and `tickets/NN-slug.md` are shapes, not references: a trailing
    # slash or a placeholder segment means the document is describing a path
    # rather than sending a reader to one.
    case "$ref" in */|*NN*|*'<'*) continue ;; esac
    case "$ref" in
      */*) [ -e "$ROOT/$ref" ] || dangling+="$from -> $ref"$'\n' ;;
      *)   [ -d "$ROOT/$ref" ] || dangling+="$from -> /$ref"$'\n' ;;
    esac
  done < <(grep -o '`/[a-z][a-z-]*`\|`[a-z][a-z-]*/[A-Za-z_.-]*`' "$doc" \
             | tr -d '`' | sed 's|^/||' | sort -u)
done < <(find "$ROOT" -name SKILL.md -o -name '*_FORMAT.md' -o -name README.md \
           | grep -v '/\.git/' | sort)

[ -z "$dangling" ] \
  && ok "no live instruction points at something that is not there" \
  || bad "no live instruction points at something that is not there" "$dangling"

# And the scripts a document tells someone to run.
missing=""
while IFS= read -r script; do
  [ -f "$ROOT/$script" ] || missing+="$script"$'\n'
done < <(grep -rho '`\./[a-z-]*\.sh`' "$ROOT"/*/SKILL.md "$ROOT"/README.md 2>/dev/null \
           | tr -d '`' | sed 's|^\./||' | sort -u)
[ -z "$missing" ] \
  && ok "every script a document tells someone to run is there" \
  || bad "every script a document tells someone to run is there" "$missing"

finish
