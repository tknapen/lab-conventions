#!/usr/bin/env python3
"""PreToolUse hook: deterministically deny writes to protected paths.

Protects (defense in depth alongside settings.json deny rules):
  - data/raw/**            raw data is read-only (principle 9)
  - uv.lock, pixi.lock     lockfiles are never hand-edited (build gate)

Reads the PreToolUse JSON payload on stdin; emits a deny decision on stdout
when a file-editing tool targets a protected path, otherwise exits silently
(allow). Any internal error exits 0 without output so a hook bug never
blocks legitimate work — settings.json deny rules remain the backstop.
"""

import json
import re
import sys

# File-editing tools whose tool_input carries the target path.
EDIT_TOOLS = {"Write", "Edit", "MultiEdit", "NotebookEdit"}

# A path is protected if any of these match it (after normalization).
PROTECTED = [
    re.compile(r"(^|/)data/raw(/|$)"),
    re.compile(r"(^|/)(uv|pixi)\.lock$"),
]

# Conservative Bash patterns: only unambiguous writes/edits to protected
# targets. Deliberately narrow — false negatives are acceptable (the deny
# rules and CI catch more); false positives that block real work are not.
BASH_PATTERNS = [
    re.compile(r"(>>?|\btee\b|\bcp\b[^|;&]*|\bmv\b[^|;&]*|\brm\b[^|;&]*)\s+\S*data/raw/"),
    re.compile(r"\bsed\b[^|;&]*-i[^|;&]*\s\S*(uv|pixi)\.lock"),
    re.compile(r"(>>?)\s*\S*(uv|pixi)\.lock"),
]


def is_protected(path: str) -> bool:
    return any(p.search(path) for p in PROTECTED)


def main() -> None:
    payload = json.load(sys.stdin)
    tool = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {}) or {}

    reason = None
    if tool in EDIT_TOOLS:
        path = str(
            tool_input.get("file_path") or tool_input.get("notebook_path") or ""
        )
        if is_protected(path):
            reason = f"{path!r} is protected: data/raw/ is read-only and lockfiles are never hand-edited (lab conventions, CORE.md build gates)."
    elif tool == "Bash":
        command = str(tool_input.get("command", ""))
        if any(p.search(command) for p in BASH_PATTERNS):
            reason = "This command writes to data/raw/ or edits a lockfile directly — both are protected (lab conventions, CORE.md build gates). Edit the manifest and re-lock, or write derived data to data/processed//data/generated/."

    if reason:
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "PreToolUse",
                        "permissionDecision": "deny",
                        "permissionDecisionReason": reason,
                    }
                }
            )
        )
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Never let a hook bug block work; deny rules are the backstop.
        sys.exit(0)
