#!/usr/bin/env bash
# tests/check-plugin-version.sh — behaviour of Build/Scripts/check-plugin-version.sh
# and of Build/hooks/pre-push, which runs it.
#
# Each case builds a throwaway git repository with a .claude-plugin/plugin.json,
# tags HEAD and runs the script inside it. The user's git configuration is not
# read, so signing or hook settings cannot interfere.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
SCRIPT="$ROOT/Build/Scripts/check-plugin-version.sh"
HOOK="$ROOT/Build/hooks/pre-push"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

fail=0
check() { # check <name> <expected> <actual>
    if [ "$2" = "$3" ]; then
        echo "  ok   $1"
    else
        echo "  FAIL $1: expected '$2', got '$3'"
        fail=1
    fi
}

repo() { # repo <name> <plugin.json content> [tag...] -> path of a one-commit repository
    local dir="$WORK/$1" content="$2" tag
    shift 2
    mkdir -p "$dir/.claude-plugin"
    printf '%s\n' "$content" >"$dir/.claude-plugin/plugin.json"
    git -C "$dir" init -q
    git -C "$dir" add .claude-plugin/plugin.json
    git -C "$dir" -c user.name=test -c user.email=test@example.invalid commit -q -m init
    for tag in "$@"; do
        git -C "$dir" tag "$tag"
    done
    printf '%s\n' "$dir"
}

run() { # run <dir> <script> -> exit code; output in $WORK/out
    ( cd "$1" && bash "$2" >"$WORK/out" 2>&1 )
    echo $?
}

echo "check-plugin-version.sh"
check "no tag at HEAD exits 0" 0 "$(run "$(repo untagged '{"version": "1.2.3"}')" "$SCRIPT")"
check "a matching v-prefixed tag exits 0" 0 "$(run "$(repo prefixed '{"version": "1.2.3"}' v1.2.3)" "$SCRIPT")"
check "a matching tag without prefix exits 0" 0 "$(run "$(repo bare '{"version": "1.2.3"}' 1.2.3)" "$SCRIPT")"
check "tags that are not semver are ignored" 0 "$(run "$(repo nonsemver '{"version": "1.2.3"}' latest v1.2)" "$SCRIPT")"
check "a tag that differs from plugin.json exits 1" 1 "$(run "$(repo mismatch '{"version": "1.2.3"}' v1.2.4)" "$SCRIPT")"
check "the mismatch names both versions" "yes" \
    "$(grep -qF 'plugin.json version (1.2.3) does not match any semver tag at HEAD' "$WORK/out" && grep -qx '1.2.4' "$WORK/out" && echo yes || echo no)"
check "one matching tag among several is enough" 0 "$(run "$(repo several '{"version": "1.2.3"}' v1.2.4 v1.2.3)" "$SCRIPT")"
check "an unreadable plugin.json fails a tagged push" 1 "$(run "$(repo broken '{"version": ' v1.2.3)" "$SCRIPT")"

echo "pre-push hook"
check "the hook passes a matching tag" 0 "$(run "$(repo hook-ok '{"version": "2.0.0"}' v2.0.0)" "$HOOK")"
check "the hook fails a mismatching tag" 1 "$(run "$(repo hook-bad '{"version": "2.0.0"}' v2.0.1)" "$HOOK")"

echo
if [ "$fail" -eq 0 ]; then
    echo "All check-plugin-version tests passed"
else
    echo "Some check-plugin-version tests FAILED"
fi
exit "$fail"
