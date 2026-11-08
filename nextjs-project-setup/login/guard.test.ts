import { readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";
import { describe, expect, it, vi } from "vitest";
import { UnauthorizedError } from "./guard";

// No session cookie: every request in this file comes from someone not
// logged in.
vi.mock("next/headers", () => ({
  cookies: async () => ({ get: () => undefined }),
}));
vi.mock("next/navigation", () => ({
  redirect: (to: string) => {
    throw new Error(`redirect to ${to}`);
  },
  notFound: () => {
    throw new Error("not found");
  },
}));

const APP = join(__dirname, "..", "app");

/** The only entries that need no session: the way to get one. */
const OPEN_ACTIONS = ["login/actions.ts#login"];
const OPEN_PAGES = ["login/page.tsx"];

function filesIn(dir: string): string[] {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) =>
    entry.isDirectory()
      ? filesIn(join(dir, entry.name))
      : [join(dir, entry.name)],
  );
}

const files = filesIn(APP).map((file) => relative(APP, file));
const actionFiles = files.filter((file) => /(^|\/)actions\.ts$/.test(file));
const routeFiles = files.filter((file) => /(^|\/)route\.ts$/.test(file));
const pageFiles = files.filter(
  (file) => /(^|\/)page\.tsx$/.test(file) && !OPEN_PAGES.includes(file),
);

describe("the login check", () => {
  it("knows every Server Action: they live in files named actions.ts", () => {
    const useServer = filesIn(join(__dirname, ".."))
      .filter((file) => /\.tsx?$/.test(file) && !file.endsWith(".test.ts"))
      .filter((file) =>
        /^\s*["']use server["']/m.test(readFileSync(file, "utf8")),
      )
      .map((file) => relative(APP, file));
    expect(useServer.sort()).toEqual(actionFiles.sort());
  });

  it.each(actionFiles)(
    "refuses every Server Action in %s without a session",
    async (file) => {
      const module = await import(join(APP, file));
      const actions = Object.entries(module).filter(
        ([name]) => !OPEN_ACTIONS.includes(`${file}#${name}`),
      );
      expect(actions.length).toBeGreaterThan(0);
      for (const [name, action] of actions) {
        await expect(
          (action as (...args: unknown[]) => Promise<unknown>)(
            "00000000-0000-4000-8000-000000000000",
            {},
            new FormData(),
          ),
          `${file}#${name}`,
        ).rejects.toThrow(UnauthorizedError);
      }
    },
  );

  it.each(routeFiles)(
    "answers 401 to every method of %s without a session",
    async (file) => {
      const module = await import(join(APP, file));
      const handlers = Object.entries(module).filter(([name]) =>
        ["GET", "POST", "PUT", "PATCH", "DELETE"].includes(name),
      );
      expect(handlers.length).toBeGreaterThan(0);
      for (const [method, handler] of handlers) {
        const response = await (
          handler as (request: Request, context: unknown) => Promise<Response>
        )(new Request("http://localhost/", { method }), {
          params: Promise.resolve({
            id: "00000000-0000-4000-8000-000000000000",
          }),
        });
        expect(response.status, `${method} ${file}`).toBe(401);
      }
    },
  );

  it.each(pageFiles)(
    "sends %s to the login page without a session",
    async (file) => {
      const module = await import(join(APP, file));
      await expect(
        module.default({
          params: Promise.resolve({
            id: "00000000-0000-4000-8000-000000000000",
          }),
          searchParams: Promise.resolve({}),
        }),
      ).rejects.toThrow("redirect to /login");
    },
  );
});
