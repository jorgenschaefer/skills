import bcrypt from "bcryptjs";

export const MIN_PASSWORD_LENGTH = 12;

/** bcrypt reads only the first 72 bytes and silently ignores the rest. */
const MAX_PASSWORD_BYTES = 72;

const PASSWORD_TOO_SHORT_MESSAGE = `The password must have at least ${MIN_PASSWORD_LENGTH} characters.`;
const PASSWORD_TOO_LONG_MESSAGE = `The password must be at most ${MAX_PASSWORD_BYTES} bytes long (letters like ä count twice).`;
const PASSWORD_IS_USERNAME_MESSAGE =
  "The password must not be the same as the username.";

/**
 * bcrypt cost for an interactive login (current advice). One place for real
 * hashes and the dummy hash, so their times match.
 */
const BCRYPT_COST = 12;

/**
 * Compare against this hash when the user is unknown, so the response time
 * does not tell whether a username exists. Computing it costs about a second
 * when the module loads.
 */
export const DUMMY_PASSWORD_HASH = bcrypt.hashSync(
  "timing-equalizer",
  BCRYPT_COST,
);

/** A password that breaks the policy; its message is for the user. */
export class PasswordPolicyError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "PasswordPolicyError";
  }
}

/** Applies wherever a password is set; `hashPassword` does not check it. */
export function assertPasswordPolicy(password: string, username: string): void {
  if (password.length < MIN_PASSWORD_LENGTH) {
    throw new PasswordPolicyError(PASSWORD_TOO_SHORT_MESSAGE);
  }
  if (Buffer.byteLength(password, "utf8") > MAX_PASSWORD_BYTES) {
    throw new PasswordPolicyError(PASSWORD_TOO_LONG_MESSAGE);
  }
  if (password.toLowerCase() === username.toLowerCase()) {
    throw new PasswordPolicyError(PASSWORD_IS_USERNAME_MESSAGE);
  }
}

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, BCRYPT_COST);
}

export async function verifyPassword(
  password: string,
  hash: string,
): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
