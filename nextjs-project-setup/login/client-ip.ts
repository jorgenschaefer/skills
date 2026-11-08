/**
 * The client IP from the X-Forwarded-For header. The reverse proxy (Caddy)
 * appends the peer it is really connected to on the right of a header the
 * client may have forged. So the last entry counts, not the first.
 *
 * This holds only if the app runs behind a trusted reverse proxy that sets
 * X-Forwarded-For. Without it, the client controls the whole header and can
 * pick the last entry freely. Then the rate limit (./rate-limit) breaks down,
 * because every request looks like a new IP. So the app must not be reachable
 * from the internet directly.
 */
export function clientIpFromForwardedFor(forwardedFor: string | null): string {
  const parts = (forwardedFor ?? "")
    .split(",")
    .map((part) => part.trim())
    .filter(Boolean);
  return parts.at(-1) ?? "local";
}
