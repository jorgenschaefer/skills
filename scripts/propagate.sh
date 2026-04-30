#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

copy_to() {
  local file="$1"; shift
  for skill in "$@"; do
    cp "$ROOT/shared/$file" "$ROOT/$skill/$file"
  done
}

copy_to adr-format.md \
  adr-init design

copy_to ubiquitous-language-update.md \
  design discovery

copy_to review-base.md \
  design-review discovery-review implementation-review planning-review

copy_to architecture-principles.md \
  code-review design design-review implementation planning planning-review refactor-project

copy_to code-style.md \
  code-review implementation
