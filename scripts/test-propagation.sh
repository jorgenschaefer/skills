#!/usr/bin/env bash
# Test script for ticket #001: propagation mechanism
# Does not use set -e so failing assertions don't abort the run.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

assert_zero() {
    local desc="$1" val="$2"
    [[ "$val" -eq 0 ]] && pass "$desc" || fail "$desc (exit $val)"
}

assert_nonzero() {
    local desc="$1" val="$2"
    [[ "$val" -ne 0 ]] && pass "$desc" || fail "$desc (expected non-zero)"
}

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    echo "$haystack" | grep -qF "$needle" && pass "$desc" || fail "$desc (not found: '$needle')"
}

cleanup() {
    if [[ -f "$ROOT/scripts/propagate.sh" ]]; then
        # Restore shared/review-base.md from the committed skill copy
        git -C "$ROOT" show HEAD:design-review/review-base.md > "$ROOT/shared/review-base.md" 2>/dev/null \
            || git -C "$ROOT" restore "$ROOT/shared/review-base.md" 2>/dev/null || true
        "$ROOT/scripts/propagate.sh" 2>/dev/null || true
        git -C "$ROOT" restore --staged \
            design-review/review-base.md \
            discovery-review/review-base.md \
            implementation-tdd-review/review-base.md \
            planning-review/review-base.md 2>/dev/null || true
        git -C "$ROOT" restore --staged shared/review-base.md 2>/dev/null \
            || git -C "$ROOT" rm --cached shared/review-base.md 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "=== file existence and executability ==="

r=0; [[ -f "shared/review-base.md" ]] || r=$?
assert_zero "shared/review-base.md exists" "$r"

r=0; [[ -x "scripts/propagate.sh" ]] || r=$?
assert_zero "scripts/propagate.sh exists and is executable" "$r"

r=0; [[ -x "scripts/pre-commit.sh" ]] || r=$?
assert_zero "scripts/pre-commit.sh exists and is executable" "$r"

echo "=== propagation ==="

r=0; scripts/propagate.sh || r=$?
assert_zero "propagate.sh runs without error" "$r"

r=0; diff -q shared/review-base.md design-review/review-base.md > /dev/null 2>&1 || r=$?
assert_zero "design-review/review-base.md matches source" "$r"

r=0; diff -q shared/review-base.md discovery-review/review-base.md > /dev/null 2>&1 || r=$?
assert_zero "discovery-review/review-base.md matches source" "$r"

r=0; diff -q shared/review-base.md implementation-tdd-review/review-base.md > /dev/null 2>&1 || r=$?
assert_zero "implementation-tdd-review/review-base.md matches source" "$r"

r=0; diff -q shared/review-base.md planning-review/review-base.md > /dev/null 2>&1 || r=$?
assert_zero "planning-review/review-base.md matches source" "$r"

echo "=== change propagation ==="

echo "# SENTINEL_TEST" >> shared/review-base.md
r=0; scripts/propagate.sh || r=$?
assert_zero "propagate.sh runs after shared file edit" "$r"

r=0; grep -q "SENTINEL_TEST" design-review/review-base.md || r=$?
assert_zero "changes propagate to design-review" "$r"

r=0; grep -q "SENTINEL_TEST" discovery-review/review-base.md || r=$?
assert_zero "changes propagate to discovery-review" "$r"

r=0; grep -q "SENTINEL_TEST" implementation-tdd-review/review-base.md || r=$?
assert_zero "changes propagate to implementation-tdd-review" "$r"

r=0; grep -q "SENTINEL_TEST" planning-review/review-base.md || r=$?
assert_zero "changes propagate to planning-review" "$r"

# shared/review-base.md may be untracked; restore content from committed skill copy
git show HEAD:design-review/review-base.md > shared/review-base.md 2>/dev/null \
    || git restore shared/review-base.md 2>/dev/null || true
scripts/propagate.sh

echo "=== pre-commit hook: detects unstaged propagated copies ==="

echo "# SENTINEL_HOOK_TEST" >> shared/review-base.md
git add shared/review-base.md

precommit_out=""
precommit_exit=0
precommit_out=$(scripts/pre-commit.sh 2>&1) || precommit_exit=$?

assert_nonzero "pre-commit.sh exits non-zero when propagated copies not staged" "$precommit_exit"
assert_contains "pre-commit.sh prints git add recovery command" "$precommit_out" "git add"

echo "=== architecture-principles.md: shared file ==="

r=0; [[ -f "shared/architecture-principles.md" ]] || r=$?
assert_zero "shared/architecture-principles.md exists" "$r"

r=0; grep -qi "screaming architecture\|domain-first\|domain.first" shared/architecture-principles.md 2>/dev/null || r=$?
assert_zero "shared/architecture-principles.md covers screaming architecture" "$r"

r=0; grep -qi "deep module" shared/architecture-principles.md 2>/dev/null || r=$?
assert_zero "shared/architecture-principles.md covers deep modules" "$r"

r=0; grep -qi "adapter" shared/architecture-principles.md 2>/dev/null || r=$?
assert_zero "shared/architecture-principles.md covers adapter boundaries" "$r"

r=0; grep -q "architecture-principles.md" scripts/propagate.sh 2>/dev/null || r=$?
assert_zero "propagate.sh includes architecture-principles copy_to call" "$r"

r=0; grep -q "architecture-principles.md" scripts/pre-commit.sh 2>/dev/null || r=$?
assert_zero "pre-commit.sh includes architecture-principles check call" "$r"

echo "=== architecture-principles.md: propagated copies ==="

for skill in code-review design design-review implementation-tdd implementation-tdd-review planning planning-review refactor-design; do
    r=0; diff -q shared/architecture-principles.md "$skill/architecture-principles.md" > /dev/null 2>&1 || r=$?
    assert_zero "$skill/architecture-principles.md matches source" "$r"
done

echo "=== architecture-principles.md: SKILL.md references ==="

for skill in implementation-tdd implementation-tdd-review code-review design planning refactor-design; do
    r=0; grep -q "architecture-principles.md" "$skill/SKILL.md" 2>/dev/null || r=$?
    assert_zero "$skill/SKILL.md references architecture-principles.md" "$r"
done

r=0; grep -q "architecture-principles.md" design-review/SKILL.md 2>/dev/null || r=$?
assert_zero "design-review/SKILL.md references architecture-principles.md" "$r"

r=0; grep -q "architecture-principles.md" planning-review/SKILL.md 2>/dev/null || r=$?
assert_zero "planning-review/SKILL.md references architecture-principles.md" "$r"

r=0; grep -qi "should-fix" design-review/SKILL.md 2>/dev/null || r=$?
assert_zero "design-review/SKILL.md retains should-fix review framing" "$r"

echo "=== code-style.md: shared file ==="

r=0; [[ -f "shared/code-style.md" ]] || r=$?
assert_zero "shared/code-style.md exists" "$r"

r=0; grep -qi "clear over clever" shared/code-style.md 2>/dev/null || r=$?
assert_zero "shared/code-style.md covers clear over clever" "$r"

r=0; grep -qi "debug print\|dead.weight\|commented.out" shared/code-style.md 2>/dev/null || r=$?
assert_zero "shared/code-style.md covers dead-weight-free" "$r"

r=0; grep -q "code-style.md" scripts/propagate.sh 2>/dev/null || r=$?
assert_zero "propagate.sh includes code-style copy_to call" "$r"

r=0; grep -q "code-style.md" scripts/pre-commit.sh 2>/dev/null || r=$?
assert_zero "pre-commit.sh includes code-style check call" "$r"

echo "=== code-style.md: propagated copies ==="

r=0; diff -q shared/code-style.md code-review/code-style.md > /dev/null 2>&1 || r=$?
assert_zero "code-review/code-style.md matches source" "$r"

r=0; diff -q shared/code-style.md implementation-tdd/code-style.md > /dev/null 2>&1 || r=$?
assert_zero "implementation-tdd/code-style.md matches source" "$r"

r=0; diff -q shared/code-style.md implementation-tdd-review/code-style.md > /dev/null 2>&1 || r=$?
assert_zero "implementation-tdd-review/code-style.md matches source" "$r"

echo "=== code-style.md: SKILL.md references ==="

r=0; grep -q "code-style.md" code-review/SKILL.md 2>/dev/null || r=$?
assert_zero "code-review/SKILL.md references code-style.md" "$r"

r=0; grep -q "code-style.md" implementation-tdd/SKILL.md 2>/dev/null || r=$?
assert_zero "implementation-tdd/SKILL.md references code-style.md" "$r"

r=0; grep -q "code-style.md" implementation-tdd-review/SKILL.md 2>/dev/null || r=$?
assert_zero "implementation-tdd-review/SKILL.md references code-style.md" "$r"

# Live skill invocation (confirming agents find and read code-style.md at runtime) is
# manual: invoke code-review and implementation skills in a test project and observe.

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ "$FAIL" -eq 0 ]]
