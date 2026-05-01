#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
"$ROOT/scripts/propagate.sh"

out_of_sync=()
check() {
  local file="$1"; shift
  for skill in "$@"; do
    if ! git -C "$ROOT" diff --quiet -- "$skill/$file" 2>/dev/null; then
      out_of_sync+=("$skill/$file")
    fi
  done
}

check review-base.md \
  design-review discovery-review implementation-review planning-review refactor-design-review

check architecture-principles.md \
  code-review design design-review implementation planning planning-review refactor-design refactor-design-review

check code-style.md \
  code-review implementation

if [[ ${#out_of_sync[@]} -gt 0 ]]; then
  echo "Propagation updated files that are not staged. Stage them and recommit:"
  printf '  %s\n' "${out_of_sync[@]}"
  echo "Run: git add ${out_of_sync[*]} && git commit"
  exit 1
fi
