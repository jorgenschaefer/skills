import { randomBytes, scrypt, timingSafeEqual } from "node:crypto";

export const MIN_PASSWORD_LENGTH = 12;

const PASSWORD_TOO_SHORT_MESSAGE = `The password must have at least ${MIN_PASSWORD_LENGTH} characters.`;
const PASSWORD_IS_USERNAME_MESSAGE =
  "The password must not be the same as the username.";

/** scrypt cost N = 2^17, r = 8, p = 1, as OWASP advises. */
const LOG2_N = 17;
const BLOCK_SIZE = 8;
const PARALLELIZATION = 1;
const KEY_LENGTH = 32;
const SALT_LENGTH = 16;

/**
 * Compare against this hash when the user is unknown, so the response time
 * does not tell whether a username exists. It needs no computing: checking a
 * password against it costs the same as against a real hash, and no password
 * gives an all-zero key.
 */
export const DUMMY_PASSWORD_HASH = format(
  LOG2_N,
  Buffer.alloc(SALT_LENGTH),
  Buffer.alloc(KEY_LENGTH),
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
  if (password.toLowerCase() === username.toLowerCase()) {
    throw new PasswordPolicyError(PASSWORD_IS_USERNAME_MESSAGE);
  }
}

/**
 * "scrypt:<log2N>:<salt>:<hash>", salt and hash in base64url. The cost is in
 * the hash, so it can be raised later without breaking old hashes. No "$" in
 * it, so Docker Compose leaves the value alone when it reads .env.
 */
export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(SALT_LENGTH);
  const hash = await derive(password, salt, LOG2_N);
  return format(LOG2_N, salt, hash);
}

export async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  const [scheme, cost, salt, hash, ...rest] = stored.split(":");
  const log2N = Number(cost);
  if (
    scheme !== "scrypt" ||
    !Number.isInteger(log2N) ||
    log2N < 1 ||
    log2N > 20 ||
    !salt ||
    !hash ||
    rest.length > 0
  ) {
    throw new Error("Not a hash from bin/hash-password-scrypt.mjs");
  }
  const expected = Buffer.from(hash, "base64url");
  const actual = await derive(password, Buffer.from(salt, "base64url"), log2N);
  // timingSafeEqual throws on buffers of different length.
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}

function derive(
  password: string,
  salt: Buffer,
  log2N: number,
): Promise<Buffer> {
  const N = 2 ** log2N;
  return new Promise((resolve, reject) => {
    scrypt(
      password,
      salt,
      KEY_LENGTH,
      {
        N,
        r: BLOCK_SIZE,
        p: PARALLELIZATION,
        // scrypt needs 128 * N * r bytes; Node's default limit is 32 MiB.
        maxmem: 2 * 128 * N * BLOCK_SIZE,
      },
      (error, key) => (error ? reject(error) : resolve(key)),
    );
  });
}

function format(log2N: number, salt: Buffer, hash: Buffer): string {
  return `scrypt:${log2N}:${salt.toString("base64url")}:${hash.toString("base64url")}`;
}
