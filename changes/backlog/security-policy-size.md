---
effort: M
utility: M
---

# The security policy stays readable in large projects

`SECURITY_POLICY.md` grows with the number of things times the kinds of
who, not with the size of the code. dom (about 256 files, two roles, two
external systems) came out at 19 rules in about 40 lines when
`/init-security-policy` was tried on a throwaway clone. A project with 40
things and 6 roles could reach more than 150 rules, and the developer is
meant to read and vouch for every one of them.

`SECURITY_POLICY_FORMAT.md` says nothing yet about keeping a large policy
readable. At acceptance, unchanged rules are already shown only by their
ids, for the same reason.
