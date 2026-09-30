#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# tests/analyze-docs.sh — behaviour of skills/typo3-docs/scripts/analyze-docs.sh.
#
# The script reads extraction data from DOCS_EXTRACTION_DIR and writes
# ANALYSIS.md there. The fixture points DOCS_EXTRACTION_DIR into a temporary
# directory, so nothing is written under the shared ${TMPDIR:-/tmp}.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../skills/typo3-docs/scripts/analyze-docs.sh"
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

echo "analyze-docs.sh"

if ! command -v jq >/dev/null 2>&1; then
    echo "  FAIL jq is required by analyze-docs.sh and is not installed"
    exit 1
fi

proj="$WORK/proj"; data="$WORK/extraction"
mkdir -p "$proj/Documentation" "$data/data"
printf 'Index\n=====\n' >"$proj/Documentation/Index.rst"
cat >"$data/data/php_apis.json" <<'EOF'
{"classes": [
  {"name": "FooController", "namespace": "Vendor\\Ext", "file": "Classes/Controller/FooController.php", "description": "d"},
  {"name": "Bar", "namespace": "Vendor\\Ext", "file": "Classes/Domain/Model/Bar.php", "description": "d"}
]}
EOF
printf '{"metadata": {"version": "1.2.3", "title": "Demo"}}\n' >"$data/data/extension_meta.json"

( cd "$proj" && DOCS_EXTRACTION_DIR="$data" bash "$SCRIPT" >"$WORK/out" 2>"$WORK/err" )
check "exits 0" 0 "$?"
report="$data/ANALYSIS.md"
check "writes ANALYSIS.md into the extraction directory" "yes" "$([ -f "$report" ] && echo yes || echo no)"
check "writes nothing into the project" "Index.rst" "$(ls "$proj/Documentation")"
check "prints nothing on stderr" "" "$(cat "$WORK/err")"
check "a controller class is typed as controller" "yes" \
    "$(grep -A4 'Vendor\\Ext\\FooController' "$report" | grep -qx -- '- \*\*Type:\*\* controller' && echo yes || echo no)"
check "a model class is typed as model" "yes" \
    "$(grep -A4 'Vendor\\Ext\\Bar' "$report" | grep -qx -- '- \*\*Type:\*\* model' && echo yes || echo no)"
# shellcheck disable=SC2016  # the backticks are Markdown in the report, not shell
check "the metadata section names both files literally" "yes" \
    "$(grep -qF -- '- **Location:** Check `Documentation/Index.rst` and `Documentation/guides.xml`' "$report" && echo yes || echo no)"

empty="$WORK/empty"; mkdir -p "$empty"
( cd "$empty" && DOCS_EXTRACTION_DIR="$data" bash "$SCRIPT" >/dev/null 2>&1 )
check "without Documentation/ it exits 1" 1 "$?"

( cd "$proj" && DOCS_EXTRACTION_DIR="$WORK/missing" bash "$SCRIPT" >/dev/null 2>&1 )
check "without extraction data it exits 1" 1 "$?"

echo
if [ "$fail" -eq 0 ]; then
    echo "All analyze-docs tests passed"
else
    echo "Some analyze-docs tests FAILED"
fi
exit "$fail"
