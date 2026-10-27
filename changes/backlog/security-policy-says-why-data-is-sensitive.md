---
effort: S
utility: M
---

# Rules pointed out for a closer look say why the data is sensitive

`/init-security-policy` points out at most five rules worth a closer look,
each with a line saying why. Tried on a clone of dom, it pointed out R-14
("Every Streife sees every marker that is placed on the map: its name, its
position, and the incident system's ID") because of the incident system's
ID. The reason that matters is the name: free text the incident system
fills, which can hold patient information.

`init-security-policy/SKILL.md` already says free text such as a name or a
note counts as possibly sensitive. Which reason a run picks varies from run
to run, so one more sentence there may not be enough.
