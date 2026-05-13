#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

copy_to() {
  local file="$1"; shift
  for skill in "$@"; do
    cp "$ROOT/shared/$file" "$ROOT/$skill/$file"
  done
}

copy_to architecture.md \
  design design-review architecture-init

copy_to tracer-bullets.md \
  planning planning-review

copy_to cross-cutting-concerns.md \
  design design-review planning-review

copy_to ubiquitous-language-update.md \
  discovery discovery-review design design-review refactor-design refactor-design-review

copy_to review-base.md \
  discovery-review design-review planning-review implementation-tdd-review refactor-design-review

copy_to architecture-principles.md \
  design design-review planning planning-review implementation-tdd implementation-tdd-review \
  code-review refactor-design refactor-design-review

copy_to code-style.md \
  implementation-tdd implementation-tdd-review code-review

copy_to code-quality-dimensions.md \
  implementation-tdd implementation-tdd-review code-review
