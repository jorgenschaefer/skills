import { redirect } from "next/navigation";
import { cache } from "react";
import { validateSessionToken } from "./session";
import { readSessionToken } from "./session-cookie";

/**
 * The one place that checks the login. Every page, Server Action and route
 * handler goes through one of the wrappers below; guard.test.ts fails for any
 * that does not.
 *
 * The app provides ./session, because it depends on the database. It must
 * export `validateSessionToken(token: string, now: Date): Promise<boolean>`,
 * which says whether the token stands for a running session.
 */

const UNAUTHORIZED_MESSAGE = "Not logged in.";
const LOGIN_PAGE = "/login";

export class UnauthorizedError extends Error {
  constructor() {
    super(UNAUTHORIZED_MESSAGE);
    this.name = "UnauthorizedError";
  }
}

/** Whether the request comes with a running session, once per request. */
export const hasSession = cache(async (): Promise<boolean> => {
  const token = await readSessionToken();
  return token ? validateSessionToken(token, new Date()) : false;
});

/** For Server Actions: runs the action only with a session. */
export function guardedAction<Args extends unknown[], Result>(
  action: (...args: Args) => Promise<Result>,
): (...args: Args) => Promise<Result> {
  return async (...args) => {
    if (!(await hasSession())) {
      throw new UnauthorizedError();
    }
    return action(...args);
  };
}

/** For route handlers: answers 401 without a session. */
export function guardedRoute<Args extends unknown[]>(
  handler: (...args: Args) => Promise<Response>,
): (...args: Args) => Promise<Response> {
  return async (...args) => {
    if (!(await hasSession())) {
      return Response.json({ error: UNAUTHORIZED_MESSAGE }, { status: 401 });
    }
    return handler(...args);
  };
}

/** For pages: sends whoever has no session to the login page. */
export function guardedPage<Props>(
  page: (props: Props) => Promise<React.ReactNode>,
): (props: Props) => Promise<React.ReactNode> {
  return async (props) => {
    if (!(await hasSession())) {
      redirect(LOGIN_PAGE);
    }
    return page(props);
  };
}
