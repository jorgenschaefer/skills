"""Print a Claude Code session log as a readable conversation.

Usage: python3 narrate.py ~/.claude/projects/<project>/<session>.jsonl

User and assistant text is printed in full. Tool calls and tool results are
shortened to one line each. Subagent turns are left out.
"""

import json
import sys


def one_line(text, limit):
    return str(text)[:limit].replace("\n", " | ")


def main(path):
    with open(path) as log:
        for line in log:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if entry.get("isSidechain"):
                continue
            kind = entry.get("type")
            content = (entry.get("message") or {}).get("content")
            if kind == "user":
                if isinstance(content, str):
                    print("USER:", content)
                    continue
                for block in content or []:
                    if block.get("type") == "text":
                        print("USER:", block["text"])
                    elif block.get("type") == "tool_result":
                        result = block.get("content")
                        if isinstance(result, list):
                            result = " ".join(
                                part.get("text", "")
                                for part in result
                                if isinstance(part, dict)
                            )
                        print("  RESULT:", one_line(result, 300))
            elif kind == "assistant":
                for block in content or []:
                    if block.get("type") == "text":
                        print("ASSISTANT:", block["text"])
                    elif block.get("type") == "tool_use":
                        print("  TOOL", block["name"], one_line(json.dumps(block["input"]), 400))


if __name__ == "__main__":
    main(sys.argv[1])
