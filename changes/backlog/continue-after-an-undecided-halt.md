---
effort: M
utility: M
---

# A run can continue once the developer settles a halt

When a build halts as `departure` or `blocked`, the developer decides, and
then the run has no way to go on. Seen in ausgaben on 2026-11-01, change
`2026-11-01-abschluss-am-letzten-tag-des-monats`, as an `undecided` halt,
a kind the runner no longer has. Today it would be a `departure`:

- The build was finished, reviewed and walked. The walker found that the
  journey's arrow in monat-abschliessen 4 did not match the app, so the
  session halted as `undecided` (`393cf6f`). It committed only `CHANGE.md`
  and left the whole build uncommitted in the working tree.
- `run.sh` refuses a dirty tree (`run/chunks.sh:71`), and a part already
  halted halts again on restart. So the runner could not be started again.
- The design session finished the build by hand: it fixed the journey and
  the test, deleted `## Halt`, set `status: done` and committed (`2684941`,
  `23b6928`). The runner never checked that commit.
- `## Left standing` stayed empty, because the build session never got to
  write it. Acceptance then had nothing from the build to go on: no review
  findings, no walker notes, nothing beyond the design.

The halt kinds are defined in the build prompt (`run/prompts.sh:27`) and
in `implement-plan/SKILL.md`: `departure`, `blocked` and `mystery`. Neither
says what happens to the work a halt leaves behind, or how the run goes on
once the developer has decided.
