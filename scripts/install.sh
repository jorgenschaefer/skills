#!/usr/bin/env bash

set -euo pipefail

if [ ! -d ~/.claude/skills ]; then
  echo "~/.claude/skills does not exist. Please create it."
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"

"$ROOT/scripts/propagate.sh"

cd ~/.claude/skills
ls "$ROOT"/*/SKILL.md | while read f ; do ln -sf $(dirname "$f") . ; done
