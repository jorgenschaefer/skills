import { isIPv6 } from "node:net";

/** An address as a list of 16-bit groups: two for IPv4, eight for IPv6. */
export type Groups = number[];

/** The groups of an IPv6 literal (also with `::`, an IPv4 tail or a zone), or `null`. */
export function parseIpv6(ip: string): Groups | null {
  const unzoned = ip.split("%")[0];
  return isIPv6(unzoned) ? ipv6Groups(unzoned) : null;
}

/** The groups of a valid IPv4 literal. */
export function ipv4Groups(ip: string): Groups {
  const [a, b, c, d] = ip.split(".").map(Number);
  return [a * 256 + b, c * 256 + d];
}

/** The groups of a valid IPv6 literal without a zone. */
export function ipv6Groups(ip: string): Groups {
  const [head, tail] = ip.includes("::") ? ip.split("::") : [ip, undefined];
  const groups = (part: string | undefined): Groups =>
    part ? part.split(":").flatMap(group) : [];
  const left = groups(head);
  const right = groups(tail);
  const zeros = new Array(8 - left.length - right.length).fill(0);
  return [...left, ...zeros, ...right];
}

function group(text: string): Groups {
  return text.includes(".") ? ipv4Groups(text) : [Number.parseInt(text, 16)];
}
