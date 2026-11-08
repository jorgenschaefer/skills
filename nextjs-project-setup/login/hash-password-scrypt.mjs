#!/usr/bin/env node
// Prints the hash of a password for a variable in secrets.prod.env.
//   bin/hash-password-scrypt.mjs             asks for the password twice
//   bin/hash-password-scrypt.mjs <password>  takes it from the command line
//                                            (tests only: it ends up in the
//                                            shell history)
// Same format and cost as src/auth/password-scrypt.ts:
// scrypt:<log2N>:<salt>:<hash>, salt and hash in base64url.

import { randomBytes, scryptSync } from "node:crypto";

const LOG2_N = 17;
const BLOCK_SIZE = 8;

const PROMPT = "Password: ";
const PROMPT_AGAIN = "Password again: ";
const NO_TTY_MESSAGE = "Run this in a terminal, so the password is not echoed.";
const MISMATCH_MESSAGE = "The passwords differ.";

function hash(password) {
  const N = 2 ** LOG2_N;
  const salt = randomBytes(16);
  const key = scryptSync(password, salt, 32, {
    N,
    r: BLOCK_SIZE,
    p: 1,
    maxmem: 2 * 128 * N * BLOCK_SIZE,
  });
  return `scrypt:${LOG2_N}:${salt.toString("base64url")}:${key.toString("base64url")}`;
}

/** Reads a line from the terminal without echoing it. */
function askHidden(prompt) {
  return new Promise((resolve) => {
    process.stderr.write(prompt);
    process.stdin.setRawMode(true);
    process.stdin.setEncoding("utf8");
    process.stdin.resume();
    let input = [];
    const onData = (chunk) => {
      for (const char of chunk) {
        if (char === "\r" || char === "\n") {
          process.stdin.off("data", onData);
          process.stdin.setRawMode(false);
          process.stdin.pause();
          process.stderr.write("\n");
          resolve(input.join(""));
          return;
        }
        if (char === "\u0003") {
          process.stdin.setRawMode(false);
          process.stderr.write("\n");
          process.exit(130);
        }
        if (char === "\u007f" || char === "\b") {
          input = input.slice(0, -1);
        } else if (char >= " ") {
          input.push(char);
        }
      }
    };
    process.stdin.on("data", onData);
  });
}

if (process.argv[2] !== undefined) {
  console.log(hash(process.argv[2]));
} else if (!process.stdin.isTTY) {
  console.error(NO_TTY_MESSAGE);
  process.exit(1);
} else {
  const password = await askHidden(PROMPT);
  if ((await askHidden(PROMPT_AGAIN)) !== password) {
    console.error(MISMATCH_MESSAGE);
    process.exit(1);
  }
  console.log(hash(password));
}
