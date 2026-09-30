#!/usr/bin/env bash
# tests/add-agents-md.sh — behaviour of skills/typo3-docs/scripts/add-agents-md.sh.
#
# The script copies assets/AGENTS.md into Documentation/ of the current
# directory and asks before it overwrites an existing file.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../skills/typo3-docs/scripts/add-agents-md.sh"
TEMPLATE="$HERE/../skills/typo3-docs/assets/AGENTS.md"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
check() { # check <name> <expected> <actual>
    if [ "$2" = "$3" ]; then
        echo "  ok   $1"
    else
        echo "  FAIL $1: expected '$2', got '$3'"
        fail=1
    fi
}

run() { # run <dir> <stdin-file> -> exit code; output in $WORK/out
    ( cd "$1" && bash "$SCRIPT" <"$2" >"$WORK/out" 2>&1 )
    echo $?
}

printf '' >"$WORK/empty"
printf 'y' >"$WORK/yes"
printf 'n' >"$WORK/no"

echo "add-agents-md.sh"

d="$WORK/no-docs"; mkdir -p "$d"
check "without Documentation/ it exits 1" 1 "$(run "$d" "$WORK/empty")"
check "without Documentation/ it creates nothing" "no" "$([ -e "$d/Documentation" ] && echo yes || echo no)"

d="$WORK/fresh"; mkdir -p "$d/Documentation"
check "a fresh Documentation/ gets the file, exit 0" 0 "$(run "$d" "$WORK/empty")"
check "the created file is the template, byte for byte" 0 \
    "$(cmp -s "$TEMPLATE" "$d/Documentation/AGENTS.md"; echo $?)"

d="$WORK/keep"; mkdir -p "$d/Documentation"; echo "own notes" >"$d/Documentation/AGENTS.md"
check "answering n keeps the existing file, exit 0" 0 "$(run "$d" "$WORK/no")"
check "answering n leaves the content alone" "own notes" "$(cat "$d/Documentation/AGENTS.md")"

d="$WORK/eof"; mkdir -p "$d/Documentation"; echo "own notes" >"$d/Documentation/AGENTS.md"
check "no terminal and no answer aborts cleanly, exit 0" 0 "$(run "$d" "$WORK/empty")"
check "no answer says it aborted" "yes" "$(grep -q '^Aborted\.$' "$WORK/out" && echo yes || echo no)"
check "no answer leaves the content alone" "own notes" "$(cat "$d/Documentation/AGENTS.md")"

d="$WORK/overwrite"; mkdir -p "$d/Documentation"; echo "own notes" >"$d/Documentation/AGENTS.md"
check "answering y overwrites, exit 0" 0 "$(run "$d" "$WORK/yes")"
check "answering y writes the template" 0 "$(cmp -s "$TEMPLATE" "$d/Documentation/AGENTS.md"; echo $?)"

echo
if [ "$fail" -eq 0 ]; then
    echo "All add-agents-md tests passed"
else
    echo "Some add-agents-md tests FAILED"
fi
exit "$fail"
