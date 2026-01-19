#!/usr/bin/env python3
"""
PreToolUse hook to validate RST content before writing to Documentation/ files.
Checks for common TYPO3 RST patterns and provides helpful reminders.
"""

import sys
import re
import json

# TYPO3 RST directive patterns
TYPO3_DIRECTIVES = [
    "confval",
    "versionadded",
    "versionchanged",
    "deprecated",
    "card-grid",
    "card",
    "tabs",
    "tab",
    "accordion",
    "accordion-item",
    "note",
    "tip",
    "warning",
    "important",
    "attention",
    "seealso",
]

# Common RST issues
RST_ISSUES = [
    {
        "pattern": r"^(#{1,6})\s",
        "message": "Markdown heading detected. RST uses underlines: = for h1, - for h2, ~ for h3",
        "severity": "error",
    },
    {
        "pattern": r"```\w*\n",
        "message": "Markdown code block detected. RST uses: .. code-block:: language",
        "severity": "error",
    },
    {
        "pattern": r"\[([^\]]+)\]\(([^)]+)\)",
        "message": "Markdown link detected. RST uses: `Link text <url>`_",
        "severity": "error",
    },
    {
        "pattern": r"^\*\*[^*]+\*\*$",
        "message": "Consider using RST admonition (.. note::, .. tip::) instead of bold for callouts",
        "severity": "info",
    },
    {
        "pattern": r"^\s*-\s+\w",
        "message": "List item found. Ensure blank line before list and consistent indentation",
        "severity": "info",
    },
]


def check_rst_content(content: str, file_path: str) -> list[dict]:
    """Check RST content for common issues."""
    issues = []

    # Only check Documentation/ files
    if "Documentation" not in file_path or not file_path.endswith(".rst"):
        return []

    for check in RST_ISSUES:
        if re.search(check["pattern"], content, re.MULTILINE):
            issues.append(
                {
                    "severity": check["severity"],
                    "message": check["message"],
                }
            )

    return issues


def main():
    try:
        input_data = sys.stdin.read()
    except Exception:
        return

    if not input_data:
        return

    try:
        data = json.loads(input_data)
        file_path = data.get("file_path", "") or data.get("path", "")
        content = data.get("content", "") or data.get("new_string", "")
    except (json.JSONDecodeError, TypeError):
        return

    if not file_path or "Documentation" not in file_path:
        return

    if not file_path.endswith(".rst"):
        return

    issues = check_rst_content(content, file_path)

    if issues:
        severity_icons = {"error": "❌", "warning": "⚠️", "info": "ℹ️"}
        output_lines = []
        for issue in issues:
            icon = severity_icons.get(issue["severity"], "•")
            output_lines.append(f"{icon} {issue['message']}")

        print(f"""<system-reminder>
RST validation for {file_path}:

{chr(10).join(output_lines)}

TYPO3 RST Quick Reference:
- Headings: Use = (h1), - (h2), ~ (h3) underlines
- Code: .. code-block:: php
- Links: `Link text <url>`_
- Notes: .. note::, .. tip::, .. warning::
- TYPO3 directives: .. confval::, .. versionadded::

See typo3-docs skill for full RST reference.
</system-reminder>""")


if __name__ == "__main__":
    main()
