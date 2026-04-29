# Release Note: Feature-First Docs Organization (Breaking Change)

All artifact output paths have moved from phase-named directories (`docs/discovery/`, `docs/design/`, `docs/tickets/`, `docs/refactor/`, `docs/reviews/`) to a unified feature folder: `docs/features/<slug>/`. Every skill that writes a feature artifact now requires the feature slug as a required argument at invocation time (e.g., `/discovery payment-retry`). This is a breaking change — existing artifacts at the old paths will not be found by the updated skills. Migrate your docs manually using the table below, then re-run `npx skills add jorgenschaefer/skills` to get the updated skills.

## Migration map

| Old path | New path |
|---|---|
| `docs/discovery/<slug>.md` | `docs/features/<slug>/brief.md` |
| `docs/design/<slug>.md` | `docs/features/<slug>/design.md` |
| `docs/tickets/<slug>/README.md` | `docs/features/<slug>/tickets/README.md` |
| `docs/tickets/<slug>/<NNN>-<name>.md` | `docs/features/<slug>/tickets/<NNN>-<name>.md` |
| `docs/refactor/<YYYY-MM-DD>-<slug>.md` | `docs/features/<slug>/proposal.md` |
| `docs/reviews/feature-brief-<slug>-<date>.md` | `docs/features/<slug>/reviews/brief-<date>.md` |
| `docs/reviews/design-doc-<slug>-<date>.md` | `docs/features/<slug>/reviews/design-<date>.md` |
| `docs/reviews/tickets-<slug>-<date>.md` | `docs/features/<slug>/reviews/tickets-<date>.md` |
| `docs/reviews/implementation-<ticket>-<date>.md` | `docs/features/<slug>/reviews/implementation-<ticket>-<date>.md` |
| `docs/tickets/boy-scout/<NNN>-<slug>.md` | `docs/features/boy-scout/tickets/<NNN>-<slug>.md` |
