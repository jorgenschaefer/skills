import { afterEach, describe, expect, it, vi } from "vitest";
import { deleteSessionCookie, sessionCookie } from "./session-cookie";

const jar = vi.hoisted(() => ({ delete: vi.fn() }));
vi.mock("next/headers", () => ({ cookies: async () => jar }));

afterEach(() => {
  vi.unstubAllEnvs();
});

describe("sessionCookie", () => {
  it("uses the __Host- prefix and Secure in production", () => {
    vi.stubEnv("NODE_ENV", "production");
    expect(sessionCookie()).toEqual({
      name: "__Host-session",
      attributes: { httpOnly: true, sameSite: "lax", secure: true, path: "/" },
    });
  });

  it("drops both outside production, where there is no HTTPS", () => {
    vi.stubEnv("NODE_ENV", "development");
    expect(sessionCookie()).toEqual({
      name: "session",
      attributes: { httpOnly: true, sameSite: "lax", secure: false, path: "/" },
    });
  });

  it("deletes the cookie with the same attributes it was set with", async () => {
    vi.stubEnv("NODE_ENV", "production");
    await deleteSessionCookie();
    expect(jar.delete).toHaveBeenCalledWith({
      name: "__Host-session",
      httpOnly: true,
      sameSite: "lax",
      secure: true,
      path: "/",
    });
  });
});
