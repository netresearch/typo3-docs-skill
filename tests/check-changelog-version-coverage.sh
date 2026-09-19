#!/usr/bin/env bash
# Cases for skills/typo3-docs/scripts/check-changelog-version-coverage.sh.
#
# The script reported every released version of this repository as missing from
# a changelog that lists all of them: it searched for the literal `[2.19.1]`
# while every heading here is written `## [v2.19.1](…/releases/tag/v2.19.1)`,
# so the `v` sits inside the brackets. 59 headings, 59 false positives, and the
# suggested repair on the v2.19.2 release PR would have fixed exactly one entry
# while making it inconsistent with the twenty above it (#105).
#
# Each case builds a throwaway git repository, so nothing here depends on the
# repository it runs in.

set -uo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills/typo3-docs/scripts/check-changelog-version-coverage.sh"

fail=0
check() { # check <name> <expected> <actual>
    if [ "$2" = "$3" ]; then
        echo "  ok   $1"
    else
        echo "  FAIL $1: expected '$2', got '$3'"
        fail=1
    fi
}
check_contains() { # check_contains <name> <needle> <haystack>
    case "$3" in
        *"$2"*) echo "  ok   $1" ;;
        *) echo "  FAIL $1: no '$2' in output"; fail=1 ;;
    esac
}

# run <changelog-body> <tag>... -> prints the script output, sets RC
run() {
    local body="$1"; shift
    local dir; dir=$(mktemp -d)
    (
        cd "$dir" || exit 1
        git init -q .
        git config user.email t@example.invalid
        git config user.name t
        printf '%s\n' "$body" > CHANGELOG.md
        git add CHANGELOG.md
        git commit -qm init
        # Annotated, and signing explicitly off: a host with tag.gpgSign or
        # forceSignAnnotated set rejects a lightweight `git tag` with "no tag
        # message?", the fixture then has no tags at all, and the script exits
        # 0 at its own empty-tags guard — every case passing for a reason that
        # has nothing to do with what it asserts.
        for t in "$@"; do git -c tag.gpgSign=false tag -a -m "$t" "$t"; done
    ) >/dev/null 2>&1
    # Refuse to assert against a fixture that did not build.
    if [ "$#" -gt 0 ] && [ -z "$(cd "$dir" && git tag -l)" ]; then
        echo "  FAIL fixture built no tags — the cases below would be vacuous"
        fail=1
    fi
    OUT=$(cd "$dir" && bash "$SCRIPT" 2>&1); RC=$?
    rm -rf "$dir"
}

echo "case: bracketed-v headings, the convention this repository uses"
run '# Changelog

## [v2.19.2](https://example.invalid/releases/tag/v2.19.2) — 2026-09-03

## [v2.19.1](https://example.invalid/releases/tag/v2.19.1) — 2026-09-02' v2.19.2 v2.19.1
check "exits 0" "0" "$RC"
check "reports nothing missing" "" "$OUT"

echo "case: bare-version headings, the convention the rest of the fleet uses"
run '# Changelog

## [2.19.2] — 2026-09-03

## [2.19.1] — 2026-09-02' v2.19.2 v2.19.1
check "exits 0" "0" "$RC"
check "reports nothing missing" "" "$OUT"

echo "case: a version that genuinely is not in the changelog is still reported"
# Without this the whole file would pass against a script that always exits 0.
run '# Changelog

## [v2.19.1](https://example.invalid/releases/tag/v2.19.1) — 2026-09-02' v2.19.2 v2.19.1
check "exits 1" "1" "$RC"
check_contains "names the missing one" "2.19.2" "$OUT"
check_contains "and only that one" "missing from CHANGELOG.md: 2.19.2" "$OUT"

echo "case: an unprefixed tag with bracketed-v headings"
run '# Changelog

## [v2.19.2](https://example.invalid/releases/tag/v2.19.2) — 2026-09-03' 2.19.2
check "exits 0" "0" "$RC"

echo "case: the dot is not a wildcard"
# `[2.19.2]` as a regex would match `[2019x2]`. A version present only in that
# shape must still be reported missing.
run '# Changelog

## [2019x2] — 2026-09-03' v2.19.2
check "exits 1" "1" "$RC"
check_contains "still reported" "2.19.2" "$OUT"

echo "case: a version with regex metacharacters in it"
# `git check-ref-format` accepts `(`, `{` and `$` in a tag name. Under a regex
# these would need escaping, and an incomplete escape both rejects a version
# whose heading IS present and lets a different one satisfy it. Review finding
# on PR #139.
run '# Changelog

## [v2.19.2(1)](https://example.invalid/releases/tag/v2.19.2%281%29) — 2026-09-03' 'v2.19.2(1)'
check "exits 0" "0" "$RC"
check "reports nothing missing" "" "$OUT"

echo "case: and it does not satisfy a neighbouring version"
run '# Changelog

## [2.19.21] — 2026-09-03' 'v2.19.2(1)'
check "exits 1" "1" "$RC"
check_contains "names the missing one" "2.19.2(1)" "$OUT"

echo "case: no tags at all"
run '# Changelog'
check "exits 0" "0" "$RC"

# ── the checkpoint that mirrors this script ─────────────────────────────────
# checkpoints.yaml TD-48 carries its own copy of the same logic, and says so in
# a comment naming its single intended divergence (an RST changelog also
# matches the bare version). A copy nobody runs is a copy that drifts: the
# bracketed-v defect above lived in both. These cases run the checkpoint's own
# command text, extracted from the YAML, against the same fixtures.
CHECKPOINTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills/typo3-docs/checkpoints.yaml"
if ! command -v yq >/dev/null 2>&1; then
    echo "  skip TD-48 mirror (yq not installed)"
else
    TD48="$(mktemp)"
    yq -r '.mechanical[] | select(.id == "TD-48") | .command' "$CHECKPOINTS" > "$TD48"
    if [ ! -s "$TD48" ]; then
        echo "  FAIL TD-48 command not found in checkpoints.yaml"
        fail=1
    else
        run_td48() { # same shape as run(), against the checkpoint's command
            local body="$1"; shift
            local dir; dir=$(mktemp -d)
            (
                cd "$dir" || exit 1
                git init -q .
                git config user.email t@example.invalid
                git config user.name t
                printf '%s\n' "$body" > CHANGELOG.md
                git add CHANGELOG.md
                git commit -qm init
                for t in "$@"; do git -c tag.gpgSign=false tag -a -m "$t" "$t"; done
            ) >/dev/null 2>&1
            OUT=$(cd "$dir" && bash "$TD48" 2>&1); RC=$?
            rm -rf "$dir"
        }

        echo "case: TD-48 accepts bracketed-v headings too"
        run_td48 '# Changelog

## [v2.19.2](https://example.invalid/releases/tag/v2.19.2) — 2026-09-03' v2.19.2
        check "exits 0" "0" "$RC"

        echo "case: TD-48 still reports a genuinely missing version"
        run_td48 '# Changelog

## [v2.19.1](https://example.invalid/releases/tag/v2.19.1) — 2026-09-02' v2.19.2 v2.19.1
        check "exits 1" "1" "$RC"
        check_contains "names it" "2.19.2" "$OUT"

        echo "case: TD-48 keeps its documented divergence — bare version in RST"
        d=$(mktemp -d)
        (
            cd "$d" || exit 1
            git init -q .
            git config user.email t@example.invalid
            git config user.name t
            mkdir -p Documentation/ChangeLog
            printf 'Changelog\n=========\n\n2.19.2\n------\n' > Documentation/ChangeLog/Index.rst
            git add -A
            git commit -qm init
            git -c tag.gpgSign=false tag -a -m v2.19.2 v2.19.2
        ) >/dev/null 2>&1
        OUT=$(cd "$d" && bash "$TD48" 2>&1); RC=$?
        rm -rf "$d"
        check "exits 0 on an RST changelog" "0" "$RC"
    fi
    rm -f "$TD48"
fi

exit "$fail"
