# Cross-Cutting Concerns

Walk this list explicitly when designing or reviewing — most design failures happen because one of these was forgotten:

- Authentication and authorization
- Observability (logging, metrics, tracing, alerting)
- Error handling, retries, and partial failure
- Idempotency (for anything that mutates state)
- Rate limiting and abuse prevention
- Data migration (forwards and backwards)
- Backwards compatibility with existing clients
- Feature flags and rollout strategy
- Security and PII handling
- Performance under expected load
- Multi-tenancy / data isolation (if applicable)
- Internationalization / localization (if applicable)
- Accessibility (if user-facing)
- Cost of new cloud resources or external calls
