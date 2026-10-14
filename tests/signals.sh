#!/usr/bin/env bash
#
# The tests for accept-criteria's signals.sh: which of a change's files it
# names, and the base it names them from.
#
#   tests/signals.sh
#
# Each case builds a throwaway repository with a change's paper in it, because
# the base is found from that repository's history.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SIGNALS="$HERE/../accept-criteria/signals.sh"

# shellcheck source=lib.sh
. "$HERE/lib.sh"

WORKSPACES=()
cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

# A repository with a lockfile and a source file from before the change, then
# the change's paper, then whatever the case builds.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  echo '{}' > "$WORK/package-lock.json"; echo x > "$WORK/app.js"
  git -C "$WORK" add . && git -C "$WORK" commit -qm before
  mkdir -p "$WORK/changes/x"; echo x > "$WORK/changes/x/CRITERIA.md"
  git -C "$WORK" add . && git -C "$WORK" commit -qm paper
}
build() {  # path... -> each written and committed
  local p
  for p in "$@"; do mkdir -p "$WORK/$(dirname "$p")"; echo changed >> "$WORK/$p"; done
  git -C "$WORK" add . && git -C "$WORK" commit -qm build
}
signals() { ( cd "$WORK" && "$SIGNALS" changes/x ); }

workspace
build package-lock.json db/schema.sql app/migrations/0002_add_owner.py alembic/versions/ab12_owner.py \
  api/openapi.yaml Dockerfile .github/workflows/ci.yml k8s/deploy.yaml docs/adr/0001-x.md CLAUDE.md \
  ARCHITECTURE.md app.js
out="$(signals)"
expected=$'dependencies\tpackage-lock.json
stored formats\tdb/schema.sql
stored formats\tapp/migrations/0002_add_owner.py
stored formats\talembic/versions/ab12_owner.py
wire formats\tapi/openapi.yaml
operations\tDockerfile
operations\t.github/workflows/ci.yml
operations\tk8s/deploy.yaml
agreed rules\tdocs/adr/0001-x.md
agreed rules\tCLAUDE.md'
missed=""
while IFS= read -r line; do grep -qxF -- "$line" <<<"$out" || missed+="$line"$'\n'; done <<<"$expected"
if [ -z "$missed" ]; then
  ok "each file a decision usually lives in is named with its kind"
else bad "each file a decision usually lives in is named with its kind" "missed: $missed got: $out"; fi

# ARCHITECTURE.md is re-derived from the code: it says what is, not what was
# agreed, and a refresh of it is no decision.
if ! grep -q 'ARCHITECTURE.md' <<<"$out"; then
  ok "ARCHITECTURE.md is not named as an agreed rule"
else bad "ARCHITECTURE.md is not named as an agreed rule" "$out"; fi

if ! grep -q 'app.js' <<<"$out"; then
  ok "a file that carries no decision by its name is left to the reader"
else bad "a file that carries no decision by its name is left to the reader" "$out"; fi

# The paper itself is no decision, and is deleted on acceptance anyway.
if ! grep -q 'changes/x' <<<"$out"; then
  ok "the change's own directory is not named"
else bad "the change's own directory is not named" "$out"; fi

# The base is the commit before the paper: a lockfile changed before the
# change began is somebody else's decision.
workspace
build app.js
out="$(signals)"
if [ "$(head -1 <<<"$out")" = "base	$(git -C "$WORK" rev-parse HEAD~2)" ] && ! grep -q 'package-lock.json' <<<"$out"; then
  ok "the diff starts at the commit before the change's paper"
else bad "the diff starts at the commit before the change's paper" "$out"; fi

workspace
build app.js
if [ "$(head -1 <<<"$( cd "$WORK" && "$SIGNALS" changes/x/ )")" = "base	$(git -C "$WORK" rev-parse HEAD~2)" ]; then
  ok "the change's directory may be named with a trailing slash"
else bad "the change's directory may be named with a trailing slash"; fi

# Paper in the root commit has no commit before it: the diff is then from
# nothing, and everything the change holds is named.
EMPTY="$(mktemp -d)"; WORKSPACES+=("$EMPTY")
git -C "$EMPTY" init -q -b main
git -C "$EMPTY" config user.email t@t; git -C "$EMPTY" config user.name t
mkdir -p "$EMPTY/changes/x"; echo x > "$EMPTY/changes/x/CRITERIA.md"; echo '{}' > "$EMPTY/package.json"
git -C "$EMPTY" add . && git -C "$EMPTY" commit -qm paper
out="$( cd "$EMPTY" && "$SIGNALS" changes/x )"
if [ "$(head -1 <<<"$out")" = "base	$(git -C "$EMPTY" hash-object -t tree /dev/null)" ] \
   && grep -qx $'dependencies\tpackage.json' <<<"$out"; then
  ok "paper in the root commit is diffed from the empty tree"
else bad "paper in the root commit is diffed from the empty tree" "$out"; fi

workspace
if ! ( cd "$WORK" && "$SIGNALS" changes/nothing ) 2>/dev/null; then
  ok "a change directory never committed is refused"
else bad "a change directory never committed is refused"; fi

finish
