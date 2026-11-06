"""List the Claude Code sessions of a project that have not been read yet.

Usage: python3 sessions.py <project path>
       python3 sessions.py <project path> --mark <session id>...

Claude Code keeps a project's session logs in ~/.claude/projects/<name>/, where
<name> is the project path with every character other than a letter, a digit
or "-" turned into "-". Sessions in a worktree of the project are in
directories whose name starts with <name> followed by "--claude-worktrees-".

Without --mark, prints one line per session that is not marked as read, oldest
first: the date it was last written, its ID, its log file, and the start of its
first message. With --mark, marks the given sessions as read. The list of read
sessions is kept in ~/.claude/projects/<name>/learn-from-sessions.read, beside
the logs, because the logs exist only on this machine.
"""

import json
import re
import sys
from datetime import datetime
from pathlib import Path

PROJECTS = Path.home() / ".claude" / "projects"


def project_dir(path):
    name = re.sub(r"[^A-Za-z0-9-]", "-", str(Path(path).resolve()))
    return PROJECTS / name


def log_files(main):
    dirs = [main] + sorted(PROJECTS.glob(main.name + "--claude-worktrees-*"))
    return [log for d in dirs if d.is_dir() for log in d.glob("*.jsonl")]


def first_message(log):
    with open(log) as lines:
        for line in lines:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if entry.get("type") != "user" or entry.get("isSidechain"):
                continue
            content = (entry.get("message") or {}).get("content")
            if isinstance(content, list):
                content = " ".join(
                    b.get("text", "") for b in content if b.get("type") == "text"
                )
            text = " ".join(str(content or "").split())
            if text and not text.startswith("<"):
                return text[:100]
    return ""


def main(args):
    main_dir = project_dir(args[0])
    read_file = main_dir / "learn-from-sessions.read"
    read = set(read_file.read_text().split()) if read_file.exists() else set()

    if len(args) > 1 and args[1] == "--mark":
        main_dir.mkdir(parents=True, exist_ok=True)
        with open(read_file, "a") as out:
            for session in args[2:]:
                if session not in read:
                    out.write(session + "\n")
        return

    logs = [log for log in log_files(main_dir) if log.stem not in read]
    for log in sorted(logs, key=lambda log: log.stat().st_mtime):
        when = datetime.fromtimestamp(log.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
        print(when, log.stem, log, first_message(log), sep="  ")


if __name__ == "__main__":
    main(sys.argv[1:])
