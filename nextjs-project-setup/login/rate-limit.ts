import { createHash } from "node:crypto";
import { type Groups, parseIpv6 } from "./ip-address";

/** The answer to a user whose attempt the login limit refuses. */
export const RATE_LIMITED_MESSAGE =
  "Too many failed attempts. Please wait a moment and try again.";

/** An attempt counted in advance; give it back if it should not count as a failure. */
interface LoginReservation {
  release(): void;
}

/**
 * A simple in-process rate limit against brute force at the login. Each
 * attempt counts against two counters, both in the same time window:
 *
 * - the **pair counter** (`ip:username`) slows down guessing one account
 *   from one IP;
 * - the **IP counter** (`ip`) slows down password spraying, where an attacker
 *   tries one password against many usernames from one IP.
 *
 * An attempt is reserved **before** the password check (`tryReserve` checks
 * and counts in one synchronous step), so that parallel requests cannot all
 * get past the check before the first one counts. A successful attempt gives
 * its reservation back (`attempt`). Login and password change count against
 * the same counters. IPv6 addresses count per /64. No captcha, no permanent
 * account lockout.
 */
export class LoginRateLimiter {
  private readonly attempts = new Map<string, number[]>();
  // When the last sweep ran; sets how often it runs (see tryReserve).
  private lastSweep = Number.NEGATIVE_INFINITY;

  constructor(
    private readonly maxPairAttempts = 5,
    private readonly maxIpAttempts = 20,
    private readonly windowMs = 5 * 60 * 1000,
  ) {}

  /** How many keys are tracked, to watch the memory use. */
  get trackedKeyCount(): number {
    return this.attempts.size;
  }

  /** The characters of all tracked keys together, to watch the memory use. */
  get trackedKeyChars(): number {
    let chars = 0;
    for (const key of this.attempts.keys()) chars += key.length;
    return chars;
  }

  /**
   * Runs the check of an attempt within the limit. Refuses without the check
   * when a budget is used up. A falsy result stays counted as a failure; a
   * success or a check that throws does not count.
   */
  async attempt<T>(
    ip: string,
    username: string,
    check: () => Promise<T>,
  ): Promise<{ status: "rate-limited" } | { status: "checked"; result: T }> {
    const reservation = this.tryReserve(ip, username);
    if (!reservation) return { status: "rate-limited" };

    let result: T;
    try {
      result = await check();
    } catch (error) {
      reservation.release();
      throw error;
    }
    if (result) {
      reservation.release();
      this.resetPair(ip, username);
    }
    return { status: "checked", result };
  }

  /**
   * Counts an attempt if both budgets still allow it; otherwise `null`.
   * A refused attempt does not count.
   */
  tryReserve(
    ip: string,
    username: string,
    now: number = Date.now(),
  ): LoginReservation | null {
    const keys = [pairKey(ip, username), ipKey(ip)];
    if (
      this.recent(keys[0], now).length >= this.maxPairAttempts ||
      this.recent(keys[1], now).length >= this.maxIpAttempts
    ) {
      return null;
    }
    // At most once per window, so that a flood (spraying) does not cause an
    // O(n) sweep on every attempt.
    if (now - this.lastSweep >= this.windowMs) this.sweep(now);
    for (const key of keys) this.record(key, now);

    let released = false;
    return {
      release: () => {
        if (released) return;
        released = true;
        for (const key of keys) this.unrecord(key, now);
      },
    };
  }

  /**
   * After a successful login, clears **only** the pair counter. The IP
   * counter stays (it only runs out with the window), so that an attacker
   * with one valid account cannot empty the spraying budget at will.
   */
  resetPair(ip: string, username: string): void {
    this.attempts.delete(pairKey(ip, username));
  }

  // Only reads: the timestamps of a key that are still in the window. It does
  // **not** write to the map, or every refused attempt would create a
  // (possibly empty) bucket.
  private recent(key: string, now: number): number[] {
    return (this.attempts.get(key) ?? []).filter(
      (t) => t > now - this.windowMs,
    );
  }

  /** Adds an attempt and drops the stale timestamps of that key. */
  private record(key: string, now: number): void {
    const times = this.recent(key, now);
    times.push(now);
    this.attempts.set(key, times);
  }

  private unrecord(key: string, time: number): void {
    const times = this.attempts.get(key);
    if (!times) return;
    const index = times.indexOf(time);
    if (index >= 0) times.splice(index, 1);
    if (times.length === 0) this.attempts.delete(key);
  }

  /**
   * Drops keys that have no timestamp left in the window. Without this sweep,
   * keys nobody asks for again (such as rotating IPs while spraying) would
   * stay in the map forever; `record` only trims the key it writes.
   */
  private sweep(now: number): void {
    const cutoff = now - this.windowMs;
    for (const [key, times] of this.attempts) {
      if (times.every((t) => t <= cutoff)) this.attempts.delete(key);
    }
    this.lastSweep = now;
  }
}

/**
 * The username goes in as a hash. An attempt is counted before the password
 * check, so without the hash every key would keep an anonymous user's
 * username of any length in memory for the whole window.
 */
function pairKey(ip: string, username: string): string {
  const name = createHash("sha256")
    .update(username.toLowerCase())
    .digest("base64url");
  return `pair:${limiterAddress(ip)}:${name}`;
}

function ipKey(ip: string): string {
  return `ip:${limiterAddress(ip)}`;
}

/**
 * The address the limit counts under. For IPv6, the /64: one connection
 * usually gets a whole /64 and can change addresses within it freely. For an
 * IPv4-mapped address (`::ffff:203.0.113.7`), the IPv4 address. Anything that
 * is not IPv6 (IPv4, `"local"`) stays as it is.
 */
export function limiterAddress(ip: string): string {
  const hextets = parseIpv6(ip);
  if (!hextets) return ip;
  if (isIpv4Mapped(hextets)) {
    return [
      hextets[6] >> 8,
      hextets[6] & 0xff,
      hextets[7] >> 8,
      hextets[7] & 0xff,
    ].join(".");
  }
  return `${hextets
    .slice(0, 4)
    .map((h) => h.toString(16))
    .join(":")}::/64`;
}

function isIpv4Mapped(hextets: Groups): boolean {
  return hextets.slice(0, 5).every((h) => h === 0) && hextets[5] === 0xffff;
}

// One counter per process (one container), kept across hot reloads.
const globalForLimiter = globalThis as unknown as {
  loginRateLimiter?: LoginRateLimiter;
};

globalForLimiter.loginRateLimiter ??= new LoginRateLimiter();
export const loginRateLimiter = globalForLimiter.loginRateLimiter;
