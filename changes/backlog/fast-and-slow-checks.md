---
effort: M
utility: L
---

# Fast checks on every build, slow checks less often

Every build waits for the project's whole `Check:` command. In dom the
security policy check adds 20 to 50 seconds to `npm run check`, which then
takes about 58 seconds in all (849 tests). Every run of the pipeline pays
that wait, several times per ticket.

The developer's idea: split the checks into fast ones that run all the time
and slow ones that run less often.

`MANIFESTO.md` says a check for anything the developer approved counts only
if it fails when the code breaks it, "and that is confirmed on every
change". Running slow checks less often has to fit that.

Related: `critical-user-journeys.md` has the same open question for slow
end-to-end checks.
