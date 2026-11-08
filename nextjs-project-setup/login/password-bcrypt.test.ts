import bcrypt from "bcryptjs";
import { describe, expect, it, vi } from "vitest";
import {
  assertPasswordPolicy,
  DUMMY_PASSWORD_HASH,
  hashPassword,
  MIN_PASSWORD_LENGTH,
  PasswordPolicyError,
  verifyPassword,
} from "./password-bcrypt";

// bcryptjs is plain JavaScript: cost 12 takes about a second per hash. The
// tests check *that* passwords are hashed and compared, not how expensively,
// so they hash with the lowest cost. The spies below show the cost that
// password-bcrypt.ts asks for.
vi.mock("bcryptjs", async (importOriginal) => {
  const TEST_COST = 4;
  const { default: bcrypt } = await importOriginal<typeof import("bcryptjs")>();
  const fast = {
    ...bcrypt,
    hash: (password: string) => bcrypt.hash(password, TEST_COST),
    hashSync: (password: string) => bcrypt.hashSync(password, TEST_COST),
  };
  return { ...fast, default: fast };
});

describe("password hashing", () => {
  it("verifies a password against its own hash", async () => {
    const hash = await hashPassword("correct horse battery");
    expect(hash).not.toBe("correct horse battery");
    expect(await verifyPassword("correct horse battery", hash)).toBe(true);
  });

  it("rejects a wrong password", async () => {
    const hash = await hashPassword("correct horse battery");
    expect(await verifyPassword("wrong password!", hash)).toBe(false);
  });

  it("rejects any password against the dummy hash", async () => {
    expect(await verifyPassword("timing", DUMMY_PASSWORD_HASH)).toBe(false);
  });

  it("hashes with cost factor 12", async () => {
    const hash = vi.spyOn(bcrypt, "hash");
    await hashPassword("correct horse battery");
    expect(hash).toHaveBeenCalledWith("correct horse battery", 12);
    hash.mockRestore();
  });

  it("uses the same cost factor for the dummy timing-equalizer hash", async () => {
    vi.resetModules();
    const { default: freshBcrypt } = await import("bcryptjs");
    const hashSync = vi.spyOn(freshBcrypt, "hashSync");
    await import("./password-bcrypt");
    expect(hashSync).toHaveBeenCalledWith(expect.any(String), 12);
    hashSync.mockRestore();
  });

  it("still verifies a legacy cost-10 hash (bcrypt is cost-agnostic)", async () => {
    const { default: realBcrypt } =
      await vi.importActual<typeof import("bcryptjs")>("bcryptjs");
    const legacy = realBcrypt.hashSync("correct horse battery", 10);
    expect(legacy.split("$")[2]).toBe("10");
    expect(await verifyPassword("correct horse battery", legacy)).toBe(true);
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

  it("allows at most 72 bytes, counting an umlaut as two", () => {
    accepts("ä".repeat(36));
    accepts("q".repeat(72));
    refuses("q".repeat(73), TOO_LONG);
    refuses(`q${"ä".repeat(36)}`, TOO_LONG);
  });

  it("accepts common passwords that meet the length rule", () => {
    accepts("password1234");
    accepts("unbelievable");
    accepts("change-me-please");
  });

  it("refuses the username, ignoring case on both sides", () => {
    refuses("ANNA-maria-admin", SAME_AS_USERNAME, "Anna-Maria-Admin");
    accepts("anna-maria-admin!", "Anna-Maria-Admin");
  });
});

const TOO_LONG =
  "The password must be at most 72 bytes long (letters like ä count twice).";
const SAME_AS_USERNAME = "The password must not be the same as the username.";
