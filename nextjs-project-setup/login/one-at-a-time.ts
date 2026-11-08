const BUSY_MESSAGE =
  "Too many logins are running right now. Please try again in a moment.";

/** More waiting checks than this are refused at once, not queued. */
const MAX_WAITING = 3;

let last: Promise<unknown> = Promise.resolve();
let waiting = 0;

export class BusyError extends Error {
  constructor() {
    super(BUSY_MESSAGE);
    this.name = "BusyError";
  }
}

/**
 * Runs the login checks one after the other. With the pause after a wrong
 * password, guesses sent in parallel get no faster than one a second. A
 * flood of guesses is refused instead of piling up in memory.
 */
export function oneAtATime<T>(run: () => Promise<T>): Promise<T> {
  if (waiting >= MAX_WAITING) {
    return Promise.reject(new BusyError());
  }
  waiting++;
  const result = last.then(run, run).finally(() => {
    waiting--;
  });
  last = result.catch(() => {});
  return result;
}
