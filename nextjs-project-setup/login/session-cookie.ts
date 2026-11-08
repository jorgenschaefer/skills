import { cookies } from "next/headers";
import type { NextResponse } from "next/server";

// Apart from ./session, so the proxy can renew the cookie without loading the
// database client. ./session takes the lifetime from here.

const DAY_MS = 24 * 60 * 60 * 1000;
export const SESSION_LIFETIME_MS = 30 * DAY_MS;
/** A session used at least once every half lifetime never runs out. */
export const RENEW_WHEN_LESS_THAN_MS = SESSION_LIFETIME_MS / 2;

const COOKIE_NAME = "session";

/**
 * `__Host-` requires `Secure`, which only production (HTTPS) has, so the name
 * and the flag hang on the same decision.
 */
export function sessionCookie() {
  const secure = process.env.NODE_ENV === "production";
  return {
    name: secure ? `__Host-${COOKIE_NAME}` : COOKIE_NAME,
    attributes: {
      httpOnly: true,
      sameSite: "lax",
      secure,
      path: "/",
    } as const,
  };
}

/** Pass `expiresAt` for sessions that end at a fixed time (./session-cutoff). */
export async function setSessionCookie(token: string, expiresAt?: Date) {
  const { name, attributes } = sessionCookie();
  (await cookies()).set(name, token, {
    ...attributes,
    ...(expiresAt
      ? { expires: expiresAt }
      : { maxAge: SESSION_LIFETIME_MS / 1000 }),
  });
}

/** For the proxy, where `cookies()` cannot reach the response. */
export function renewSessionCookie(response: NextResponse, token: string) {
  const { name, attributes } = sessionCookie();
  response.cookies.set(name, token, {
    ...attributes,
    maxAge: SESSION_LIFETIME_MS / 1000,
  });
}

export async function readSessionToken(): Promise<string | undefined> {
  return (await cookies()).get(sessionCookie().name)?.value;
}

export async function deleteSessionCookie() {
  // Without the same attributes, the browser ignores the delete of a
  // __Host- cookie.
  const { name, attributes } = sessionCookie();
  (await cookies()).delete({ name, ...attributes });
}
