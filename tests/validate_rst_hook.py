#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
"""Behaviour of scripts/validate_rst.py, the PreToolUse hook in hooks/hooks.json.

The hook is run as a subprocess with the payload Claude Code sends on stdin:
the tool's arguments are nested under "tool_input". Run: python3 tests/validate_rst_hook.py
"""

import json
import subprocess
import sys
from pathlib import Path

HOOK = Path(__file__).resolve().parent.parent / "scripts" / "validate_rst.py"

failures = 0


def run(stdin: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(HOOK)],
        input=stdin,
        capture_output=True,
        text=True,
        timeout=10,
        check=False,
    )


def payload(tool: str, **tool_input: str) -> str:
    return json.dumps(
        {
            "session_id": "test",
            "hook_event_name": "PreToolUse",
            "tool_name": tool,
            "tool_input": tool_input,
        }
    )


def context(result: subprocess.CompletedProcess) -> str:
    """The additionalContext the hook hands the agent, or "" when it printed none."""
    try:
        output = json.loads(result.stdout)
    except json.JSONDecodeError:
        return ""
    specific = output.get("hookSpecificOutput", {}) if isinstance(output, dict) else {}
    if specific.get("hookEventName") != "PreToolUse":
        return ""
    return specific.get("additionalContext", "")


def check(name: str, condition: bool, result: subprocess.CompletedProcess) -> None:
    global failures
    if condition:
        print(f"  ok   {name}")
    else:
        failures += 1
        print(f"  FAIL {name}: exit {result.returncode}")
        print(f"       stdout: {result.stdout!r}")
        print(f"       stderr: {result.stderr!r}")


print("validate_rst.py")

r = run(payload("Write", file_path="/ext/Documentation/Index.rst", content="# Title\n"))
check(
    "Write of a Markdown heading into Documentation/*.rst is reported",
    r.returncode == 0 and "Markdown heading detected" in context(r),
    r,
)

r = run(
    payload(
        "Edit",
        file_path="/ext/Documentation/Index.rst",
        old_string="x",
        new_string="See [docs](https://example.org)\n",
    )
)
check(
    "Edit with a Markdown link into Documentation/*.rst is reported",
    r.returncode == 0 and "Markdown link detected" in context(r),
    r,
)

r = run(
    payload(
        "Write",
        file_path="/ext/Documentation/Index.rst",
        content="Title\n=====\n\nText.\n",
    )
)
check("clean RST produces no output", r.returncode == 0 and r.stdout == "", r)

r = run(payload("Write", file_path="/ext/Documentation/notes.md", content="# Title\n"))
check("a non-.rst file is ignored", r.returncode == 0 and r.stdout == "", r)

r = run(payload("Write", file_path="/ext/Classes/Foo.rst", content="# Title\n"))
check(
    "an .rst outside Documentation/ is ignored", r.returncode == 0 and r.stdout == "", r
)

r = run("not json")
check(
    "invalid JSON exits 0 silently",
    r.returncode == 0 and r.stdout == "" and r.stderr == "",
    r,
)

r = run("")
check(
    "empty stdin exits 0 silently",
    r.returncode == 0 and r.stdout == "" and r.stderr == "",
    r,
)

r = run('["a list"]')
check(
    "a JSON value that is not an object exits 0 silently",
    r.returncode == 0 and r.stdout == "" and r.stderr == "",
    r,
)

for name, tool_input in (
    ("a file_path that is not a string", '{"file_path": 1, "content": "# Title"}'),
    (
        "content that is not a string",
        '{"file_path": "/ext/Documentation/Index.rst", "content": ["# Title"]}',
    ),
):
    r = run('{"tool_input": ' + tool_input + "}")
    check(
        f"{name} exits 0 silently",
        r.returncode == 0 and r.stdout == "" and r.stderr == "",
        r,
    )

print()
if failures:
    print(f"{failures} validate_rst.py test(s) FAILED")
    sys.exit(1)
print("All validate_rst.py tests passed")
