#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

copy_to() {
  local file="$1"; shift
  for skill in "$@"; do
    cp "$ROOT/shared/$file" "$ROOT/$skill/$file"
  done
}

copy_to review-base.md \
  design-review discovery-review implementation-review planning-review
