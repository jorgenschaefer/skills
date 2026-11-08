/** Every session ends at this hour, for example at a shift change. */
const SESSION_CUTOFF_HOUR = 6;
const SESSION_CUTOFF_TIME_ZONE = "Europe/Berlin";

/**
 * Every session ends at the first cut-off hour after its sign-in: the server
 * deletes it then, and its cookie expires.
 */
export function sessionCutoff(signedInAt: Date): Date {
  const { year, month, day } = wallClockIn(
    SESSION_CUTOFF_TIME_ZONE,
    signedInAt,
  );
  const sameDay = cutoffOn(year, month, day);
  return sameDay > signedInAt ? sameDay : cutoffOn(year, month, day + 1);
}

/** The cut-off hour on a calendar day in the cut-off time zone. */
function cutoffOn(year: number, month: number, day: number): Date {
  const asIfUtc = new Date(Date.UTC(year, month - 1, day, SESSION_CUTOFF_HOUR));
  // The offset read at `asIfUtc` is the one in force at the cut-off hour only
  // if no offset change lies between the two. Europe/Berlin changes its offset
  // at 01:00 UTC, so this is right there for hours 0 and 3-23, not 1 or 2.
  // Check this again when you change the hour or the time zone.
  return new Date(
    asIfUtc.getTime() - offsetFromUtc(SESSION_CUTOFF_TIME_ZONE, asIfUtc),
  );
}

/** How far the wall clock in `timeZone` is ahead of UTC at `instant`, in ms. */
function offsetFromUtc(timeZone: string, instant: Date): number {
  const { year, month, day, hour, minute, second } = wallClockIn(
    timeZone,
    instant,
  );
  const wallClockAsUtc = Date.UTC(year, month - 1, day, hour, minute, second);
  return wallClockAsUtc - (instant.getTime() - instant.getUTCMilliseconds());
}

function wallClockIn(timeZone: string, instant: Date) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    hourCycle: "h23",
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    second: "numeric",
  }).formatToParts(instant);
  const part = (type: Intl.DateTimeFormatPartTypes) => {
    const value = parts.find((p) => p.type === type)?.value;
    if (value === undefined) {
      throw new Error(`Intl gave no ${type} for ${instant.toISOString()}`);
    }
    return Number(value);
  };
  return {
    year: part("year"),
    month: part("month"),
    day: part("day"),
    hour: part("hour"),
    minute: part("minute"),
    second: part("second"),
  };
}
