#!/usr/bin/env bash
#
# Whether every reference on an explanation page points at something that
# exists: each `data-f="path:line"` in the file at B, each `data-a` in the file
# at A, and each `data-c` a commit.
#
#   check-refs.sh <page.html> <A> <B>
#
# Prints one line per broken reference and exits 1 if there is any; prints how
# many it checked otherwise. A page with no reference at all fails too, since
# every claim on it is meant to carry one.

set -euo pipefail

page="${1:?usage: check-refs.sh <page.html> <A> <B>}"
A="$(git rev-parse --verify -q "${2:?usage: check-refs.sh <page.html> <A> <B>}^{commit}")" || { echo "check-refs.sh: no commit $2" >&2; exit 1; }
B="$(git rev-parse --verify -q "${3:?usage: check-refs.sh <page.html> <A> <B>}^{commit}")" || { echo "check-refs.sh: no commit $3" >&2; exit 1; }

checked=0 broken=0

file_ref() {  # sha ref -> true if the file exists at sha and has that line
  local sha="$1" path="${2%:*}" line="${2##*:}"
  [[ "$line" =~ ^[1-9][0-9]*$ ]] || return 1
  git cat-file -e "$sha:$path" 2>/dev/null || return 1
  [ "$(git show "$sha:$path" | wc -l)" -ge "$line" ]
}

while IFS= read -r ref; do
  checked=$((checked + 1))
  attr="${ref%%=*}" value="${ref#*=\"}" value="${value%\"}"
  case "$attr" in
    data-f) file_ref "$B" "$value" && continue ;;
    data-a) file_ref "$A" "$value" && continue ;;
    data-c) git cat-file -e "$value^{commit}" 2>/dev/null && continue ;;
  esac
  printf 'broken\t%s\t%s\n' "$attr" "$value"
  broken=$((broken + 1))
done < <(grep -oE 'data-[fac]="[^"]*"' "$page")

if [ "$checked" -eq 0 ]; then
  echo "check-refs.sh: $page has no references" >&2
  exit 1
fi
[ "$broken" -eq 0 ] || exit 1
printf 'checked\t%s\n' "$checked"
