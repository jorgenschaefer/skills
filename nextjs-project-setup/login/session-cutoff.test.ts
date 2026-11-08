import { describe, expect, it } from "vitest";
import { sessionCutoff } from "./session-cutoff";

describe("sessionCutoff", () => {
  it.each([
    // Summer time, CEST = UTC+2: 06:00 Berlin is 04:00 UTC.
    ["the evening", "2026-10-21T20:00:00Z", "2026-10-22T04:00:00Z"],
    ["just after midnight", "2026-10-21T22:30:00Z", "2026-10-22T04:00:00Z"],
    ["a minute before 06:00", "2026-10-22T03:59:00Z", "2026-10-22T04:00:00Z"],
    ["exactly 06:00", "2026-10-22T04:00:00Z", "2026-10-23T04:00:00Z"],
    ["a minute after 06:00", "2026-10-22T04:01:00Z", "2026-10-23T04:00:00Z"],
    // Winter time, CET = UTC+1: 06:00 Berlin is 05:00 UTC.
    ["a winter evening", "2026-12-01T20:00:00Z", "2026-12-02T05:00:00Z"],
    ["04:30 UTC in winter", "2026-12-02T04:30:00Z", "2026-12-02T05:00:00Z"],
    ["a winter 06:00", "2026-12-02T05:00:00Z", "2026-12-03T05:00:00Z"],
    ["New Year's Eve", "2026-12-31T22:00:00Z", "2027-01-01T05:00:00Z"],
    // The night summer time ends: 2026-10-25, 03:00 CEST becomes 02:00 CET.
    [
      "the evening before it ends",
      "2026-10-24T20:00:00Z",
      "2026-10-25T05:00:00Z",
    ],
    ["the night it ends", "2026-10-25T01:30:00Z", "2026-10-25T05:00:00Z"],
    // The night summer time starts: 2027-03-28, 02:00 CET becomes 03:00 CEST.
    [
      "the evening before it starts",
      "2027-03-27T20:00:00Z",
      "2027-03-28T04:00:00Z",
    ],
    ["the night it starts", "2027-03-28T01:30:00Z", "2027-03-28T04:00:00Z"],
  ])(
    "ends a session signed in %s at the next 06:00 Berlin",
    (_when, signedInAt, cutoff) => {
      expect(sessionCutoff(new Date(signedInAt))).toEqual(new Date(cutoff));
    },
  );
});
