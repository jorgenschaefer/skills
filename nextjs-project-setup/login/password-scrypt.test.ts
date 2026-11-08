import { describe, expect, it } from "vitest";
import {
  assertPasswordPolicy,
  DUMMY_PASSWORD_HASH,
  hashPassword,
  MIN_PASSWORD_LENGTH,
  PasswordPolicyError,
  verifyPassword,
} from "./password-scrypt";

describe("password hashing", () => {
  it("verifies a password against its own hash", async () => {
    const hash = await hashPassword("correct horse battery");
    expect(hash).toMatch(/^scrypt:17:[\w-]{22}:[\w-]{43}$/);
    expect(await verifyPassword("correct horse battery", hash)).toBe(true);
    expect(await verifyPassword("wrong password!", hash)).toBe(false);
  });

  it("reads the cost from the hash, so old hashes keep working", async () => {
    // "correct horse battery" hashed with N = 2^10.
    const cheap =
      "scrypt:10:AAAAAAAAAAAAAAAAAAAAAA:AsWvwMY_76m6UtetkFvlJIEPTCAm8Pu2vkYrRktx10s";
    expect(await verifyPassword("correct horse battery", cheap)).toBe(true);
  });

  it("rejects any password against the dummy hash", async () => {
    expect(DUMMY_PASSWORD_HASH).toMatch(/^scrypt:17:/);
    expect(await verifyPassword("", DUMMY_PASSWORD_HASH)).toBe(false);
  });

  it("rejects a hash of another length instead of throwing", async () => {
    const [scheme, cost, salt] = (await hashPassword("x")).split(":");
    expect(await verifyPassword("x", `${scheme}:${cost}:${salt}:AAAA`)).toBe(
      false,
    );
  });

  it.each([
    ["the old format without a cost", "scrypt:AAAA:AAAA"],
    ["another scheme", "bcrypt:17:AAAA:AAAA"],
    ["a cost that is not a number", "scrypt:x:AAAA:AAAA"],
    ["a cost too high to compute", "scrypt:30:AAAA:AAAA"],
  ])("refuses %s", async (_case, stored) => {
    await expect(verifyPassword("x", stored)).rejects.toThrow(
      "Not a hash from bin/hash-password-scrypt.mjs",
    );
  });
});

describe("assertPasswordPolicy", () => {
  const accepts = (password: string, username = "anna") =>
    expect(() => assertPasswordPolicy(password, username)).not.toThrow();
  const refuses = (password: string, message: string, username = "anna") =>
    expect(() => assertPasswordPolicy(password, username)).toThrow(
      new PasswordPolicyError(message),
    );

  it("enforces the 12-character minimum length", () => {
    refuses(
      "q".repeat(MIN_PASSWORD_LENGTH - 1),
      "The password must have at least 12 characters.",
    );
    accepts("q".repeat(MIN_PASSWORD_LENGTH));
  });

  it("has no upper limit on the length", () => {
    accepts("ä".repeat(1000));
  });

  it("refuses the username, ignoring case on both sides", () => {
    refuses(
      "ANNA-maria-admin",
      "The password must not be the same as the username.",
      "Anna-Maria-Admin",
    );
    accepts("anna-maria-admin!", "Anna-Maria-Admin");
  });
});
