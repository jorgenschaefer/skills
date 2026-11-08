#!/usr/bin/env node
// Prints the hash of a password for a variable in secrets.prod.env.
//   bin/hash-password-bcrypt.mjs             asks for the password twice
//   bin/hash-password-bcrypt.mjs <password>  takes it from the command line
//                                            (tests only: it ends up in the
//                                            shell history)
// Same cost as src/auth/password-bcrypt.ts.
//
// A bcrypt hash contains "$", which Docker Compose reads as a variable in
// .env: write each "$" as "$$" there.

import bcrypt from "bcryptjs";

const BCRYPT_COST = 12;

const PROMPT = "Password: ";
const PROMPT_AGAIN = "Password again: ";
const NO_TTY_MESSAGE = "Run this in a terminal, so the password is not echoed.";
const MISMATCH_MESSAGE = "The passwords differ.";

function hash(password) {
  return bcrypt.hashSync(password, BCRYPT_COST);
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
