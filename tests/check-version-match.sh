#!/usr/bin/env bash
# tests/check-version-match.sh — behaviour of
# skills/typo3-docs/scripts/check-version-match.sh against guides.xml files of
# the shape the skill prescribes (an XML declaration, then <project version=…
# release=…>).

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../skills/typo3-docs/scripts/check-version-match.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
check() { # check <name> <expected-exit> <actual-exit>
    if [ "$2" = "$3" ]; then
        echo "  ok   $1"
    else
        echo "  FAIL $1: expected exit $2, got $3"
        fail=1
    fi
}

run() { # run <dir>
    ( cd "$1" && bash "$SCRIPT" >/dev/null 2>&1 )
    echo $?
}

project() { # project <name> <guides-version> <guides-release> <emconf-version>
    d="$WORK/$1"
    mkdir -p "$d/Documentation"
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<guides xmlns="https://www.phpdoc.org/guides">\n    <project title="T" version="%s" release="%s"/>\n</guides>\n' \
        "$2" "$3" >"$d/Documentation/guides.xml"
    printf "<?php\n\$EM_CONF[\$_EXTKEY] = [\n    'version' => '%s',\n];\n" "$4" >"$d/ext_emconf.php"
    echo "$d"
}

echo "check-version-match.sh"

if ! command -v php >/dev/null 2>&1; then
    echo "  FAIL php is required to parse guides.xml and is not installed"
    exit 1
fi

check "the skill's own shape (version=major.minor, release=full) passes" 0 "$(run "$(project short 0.8 0.8.2 0.8.2)")"
check "a full version that matches passes" 0 "$(run "$(project full 0.8.2 0.8.2 0.8.2)")"
check "a stale release fires" 1 "$(run "$(project stale 0.8 0.8.1 0.8.2)")"

d="$WORK/no-guides"; mkdir -p "$d"
printf "<?php\n\$EM_CONF[\$_EXTKEY] = ['version' => '0.8.2'];\n" >"$d/ext_emconf.php"
check "no guides.xml is not a mismatch" 0 "$(run "$d")"

echo
if [ "$fail" -eq 0 ]; then
    echo "All check-version-match tests passed"
else
    echo "Some check-version-match tests FAILED"
fi
exit "$fail"
