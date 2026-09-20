#!/usr/bin/env bash
#
# What the format suites share: counting, the fenced template, reading one
# section, and the two guards every such suite needs - that the document says
# what the checker expects, and that the tree had something to check at all.
#
# Sourced, never run. `tests/intent-format.sh` and `tests/solution-format.sh`
# are the callers; a third is due when the ticket format lands.

passed=0 failed=0

ok()  { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
        [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }

# Everything between the ```markdown fence. Only the template counts: the prose
# around it discusses the sections by name, so a whole-file grep would stay green
# after the template lost one.
template_of() { sed -n '/^```markdown$/,/^```$/p' "$1"; }

# One section's body, without its own heading and without the next one's.
section_body() { sed -n "/^## $2\$/,/^## /p" "$1" | sed '1d;/^## /d'; }

# The sections the checker requires, asserted against the template that is
# supposed to specify them.
expect_sections() {
  local template="$1" where="$2"; shift 2
  local section
  for section in "$@"; do
    if printf '%s' "$template" | grep -q "^## $section\$"; then
      ok "the template specifies ## $section"
    else
      bad "the template specifies ## $section" "not in the fenced block of $where"
    fi
  done
}

# Sections that were dropped on purpose. A decision that quietly reverts is
# worse than one never made.
expect_dropped() {
  local template="$1"; shift
  local section
  for section in "$@"; do
    if printf '%s' "$template" | grep -q "^#\+ $section\$"; then
      bad "the template drops ## $section" "still present: it was dropped deliberately"
    else
      ok "the template drops ## $section"
    fi
  done
}

# An empty glob is zero cases and zero failures, which reads as success.
expect_counted() {
  [ "$1" -gt 0 ] \
    && ok "there are $2 to check" \
    || bad "there are $2 to check" "none found: the cases above checked nothing"
}

finish() {
  printf '\n%d passed, %d failed\n' "$passed" "$failed"
  [ "$failed" -eq 0 ]
}
