import { describe, expect, it } from "vitest";
import { BusyError, oneAtATime } from "./one-at-a-time";

describe("oneAtATime", () => {
  it("starts a check only once the one before has finished, failed or not", async () => {
    const log: string[] = [];
    const check = (name: string, fail = false) =>
      oneAtATime(async () => {
        log.push(`start ${name}`);
        await new Promise((resolve) => setTimeout(resolve, 5));
        log.push(`end ${name}`);
        if (fail) {
          throw new Error(name);
        }
      });

    await Promise.allSettled([check("a", true), check("b")]);

    expect(log).toEqual(["start a", "end a", "start b", "end b"]);
  });
});

describe("oneAtATime under a flood", () => {
  it("refuses checks beyond a few waiting ones instead of queueing them", async () => {
    let release = () => {};
    const slow = () =>
      oneAtATime(
        () =>
          new Promise<void>((resolve) => {
            release = resolve;
          }),
      );
    const running = [slow(), slow(), slow()];
    await expect(slow()).rejects.toThrow(BusyError);
    for (let i = 0; i < 3; i++) {
      await new Promise((resolve) => setTimeout(resolve, 0));
      release();
    }
    await Promise.all(running);
  });
});
