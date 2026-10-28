---
effort: S
utility: S
---

# The runner ignores a check line that is not in the standard's form

`run/checks.sh` reads the `Fast check:`, `Slow check:` and `Check:` lines with
`check_line` (`run/checks.sh:67`), which matches only the strict form: the
command in backticks and nothing after it. A line such as ``Check: true``,
without backticks, is not read at all. The runner then asks a session for a
command (`run/checks.sh:63`), and says nothing about the line it skipped. A
typo in the line quietly changes what every build runs.

`critique` already reports such a line as a should-fix, but only when it
reviews. The reviewer of a runner fix found this while driving the runner, in
the acceptance of the fast and slow checks change.
