# shellcheck shell=bash
#
# Sourced, never run: builds a throwaway repository in $WORK with the runner's
# own test harness - on main, one change in changes/2026-01-01-demo, a stub on
# PATH where `claude` would be - and defines R, st and demo_done to drive it.

# shellcheck source=SCRIPTDIR/../../../tests/run/harness.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/tests/run/harness.sh"
# The harness removes its workspaces when a test file exits; this one is kept
# until demo_done.
trap - EXIT
workspace
git -C "$WORK" checkout -q main
git -C "$WORK" mv changes/x changes/2026-01-01-demo
git -C "$WORK" commit -qm "dated change dir"
# The harness cuts topic before the rename; moved here, it holds the same change.
git -C "$WORK" branch -f topic main

R() {  # [ticket dir] - run.sh on it, then its exit code
  ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS=2 \
      bash "$RUNNER" "${1:-changes/2026-01-01-demo/tickets}" )
  echo "exit=$?"
}
st() {  # [lines] - the branch checked out, the commit graph, sessions launched
  echo "--- on: $(git -C "$WORK" rev-parse --abbrev-ref HEAD)"
  git -C "$WORK" log --oneline --graph --all | head -"${1:-12}"
  echo "sessions launched: $(wc -l < "$STUB_CALLS")"
}
demo_done() { rm -rf "$WORK"; }
