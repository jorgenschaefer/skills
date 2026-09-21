#!/usr/bin/env bash
#
# What the suites share: counting, and the two guards every one of them needs.
#
# Sourced, never run. `test.sh` is a caller and so is every suite under here.

passed=0 failed=0

ok()  { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
        [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }

# A check of the form "nothing is wrong" reports the same thing over an empty
# tree as over a clean one. Every suite that loops over a glob says how many
# cases it found, so a suite that stopped finding anything cannot read as green.
expect_counted() {
  [ "$1" -gt 0 ] \
    && ok "there are $2 to check" \
    || bad "there are $2 to check" "none found: the cases above checked nothing"
}

finish() {
  printf '\n%d passed, %d failed\n' "$passed" "$failed"
  [ "$failed" -eq 0 ]
}
