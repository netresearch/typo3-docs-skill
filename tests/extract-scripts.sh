#!/usr/bin/env bash
# tests/extract-scripts.sh — behaviour of the extract-*.sh scripts in
# skills/typo3-docs/scripts/.
#
# Each run sets DOCS_EXTRACTION_DIR to a temporary directory, so nothing is
# written under the shared ${TMPDIR:-/tmp}. Nothing here needs the network:
# extract-repo-metadata.sh is only run in a repository without a remote, where
# it stops before calling gh or glab.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$HERE/../skills/typo3-docs/scripts"
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

extract() { # extract <script> <project-dir> <extraction-dir> -> exit code
    ( cd "$2" && DOCS_EXTRACTION_DIR="$3" bash "$SCRIPTS/$1" >"$WORK/out" 2>&1 )
    echo $?
}

json() { # json <file> <key.index...> -> the value, "#" as last key for a length; INVALID if unparseable
    python3 - "$1" "$2" <<'PY' 2>/dev/null || echo INVALID
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    value = json.load(f)
for key in sys.argv[2].split("."):
    if key == "#":
        value = len(value)
    elif isinstance(value, list):
        value = value[int(key)]
    else:
        value = value[key]
print(value)
PY
}

if ! command -v php >/dev/null 2>&1; then
    echo "  FAIL php is required by extract-extension-config.sh and is not installed"
    exit 1
fi

# A fixture shaped like a TYPO3 extension. Its values contain what the JSON
# writers have to escape: namespace backslashes, double quotes, a tab.
proj="$WORK/proj"
mkdir -p "$proj/Classes/Controller" "$proj/Classes/Domain/Model" "$proj/.github/workflows"
printf '<?php\nnamespace Vendor\\Ext;\n\ninterface AlphaInterface\n{\n}\n' >"$proj/Classes/AlphaInterface.php"
printf '<?php\nnamespace Vendor\\Ext\\Controller;\n\n/**\n * Shows the "list".\n * @author Jane\n */\nfinal class FooController extends Base\n{\n}\n' \
    >"$proj/Classes/Controller/FooController.php"
printf '<?php\nnamespace Vendor\\Ext\\Domain\\Model;\n\nclass Bar\n{\n}\n' >"$proj/Classes/Domain/Model/Bar.php"
printf "<?php\n\$EM_CONF[\$_EXTKEY] = ['title' => 'Demo', 'version' => '1.2.3'];\n" >"$proj/ext_emconf.php"
cat >"$proj/ext_conf_template.txt" <<'EOF'
# cat=basic/enable; type=boolean; label=Enable "beta": Turns it on
enable = 1
# cat=basic; type=string; label=Path: C:\data WARNING: keep it private
path = /var/data
# cat=basic; type=string; label=Trailing comment without a setting
EOF
printf '{"name": "vendor/ext", "description": "D", "type": "typo3-cms-extension", "require": {"typo3/cms-core": "^13.4"}}\n' \
    >"$proj/composer.json"
printf '# Demo\n\n* item one\n*   spaced   words\npath C:\\data\n\tindented "quoted"\n' >"$proj/README.md"
printf '# Changelog\n\n## [1.2.3]\n' >"$proj/CHANGELOG.md"
printf 'name: CI\n' >"$proj/.github/workflows/ci.yml"
printf '<phpunit/>\n' >"$proj/phpunit.xml"
# Files a glob in the project directory would expand to.
touch "$proj/aaa-glob-target" "$proj/zzz-glob-target"

x="$WORK/extraction"

echo "extract-php.sh"
check "exits 0" 0 "$(extract extract-php.sh "$proj" "$x")"
f="$x/data/php_apis.json"
check "php_apis.json is valid JSON; an interface file adds no entry" "2" "$(json "$f" 'classes.#')"
check "a namespace keeps its backslashes" 'Vendor\Ext\Controller' "$(json "$f" 'classes.0.namespace')"
check "a docblock keeps its double quotes" 'Shows the "list".' "$(json "$f" 'classes.0.description')"
check "a model is categorised as model" "model" "$(json "$f" 'classes.1.category')"

noclasses="$WORK/no-classes"; mkdir -p "$noclasses"
check "without Classes/ and without an extraction directory it exits 0" 0 \
    "$(extract extract-php.sh "$noclasses" "$WORK/fresh-extraction")"
check "without Classes/ it writes an empty class list" "0" \
    "$(json "$WORK/fresh-extraction/data/php_apis.json" 'classes.#')"

echo "extract-extension-config.sh"
check "exits 0" 0 "$(extract extract-extension-config.sh "$proj" "$x")"
f="$x/data/config_options.json"
check "config_options.json is valid JSON with both settings" "2" "$(json "$f" 'config_options.#')"
check "a label keeps its double quotes" 'Enable "beta"' "$(json "$f" 'config_options.0.label')"
check "a security warning is split off the description" "keep it private" \
    "$(json "$f" 'config_options.1.security_warning')"
check "ext_emconf.php metadata is read" "1.2.3" "$(json "$x/data/extension_meta.json" 'metadata.version')"

echo "extract-composer.sh"
check "exits 0" 0 "$(extract extract-composer.sh "$proj" "$x")"
check "the requirements are copied" "^13.4" "$(json "$x/data/dependencies.json" 'require.typo3/cms-core')"

echo "PHP-based extraction in a directory whose name contains a single quote"
quoted="$WORK/it's-ext"; mkdir -p "$quoted"
cp "$proj/ext_emconf.php" "$proj/composer.json" "$quoted/"
check "extract-extension-config.sh exits 0" 0 "$(extract extract-extension-config.sh "$quoted" "$WORK/quoted")"
check "and reads ext_emconf.php" "1.2.3" "$(json "$WORK/quoted/data/extension_meta.json" 'metadata.version')"
# extract-composer.sh uses php only when jq is missing: a PATH with just the
# tools it calls.
nojq="$WORK/bin-without-jq"; mkdir -p "$nojq"
for tool in bash dirname mkdir php; do ln -s "$(command -v "$tool")" "$nojq/$tool"; done
check "extract-composer.sh without jq exits 0" 0 \
    "$( (cd "$quoted" && DOCS_EXTRACTION_DIR="$WORK/quoted" PATH="$nojq" bash "$SCRIPTS/extract-composer.sh" >/dev/null 2>&1); echo $?)"
check "and reads composer.json with php" "vendor/ext" "$(json "$WORK/quoted/data/dependencies.json" 'name')"

echo "extract-project-files.sh"
check "exits 0" 0 "$(extract extract-project-files.sh "$proj" "$x")"
f="$x/data/project_files.json"
check "the README preview is the README, byte for byte" "$(cat "$proj/README.md")" \
    "$(json "$f" 'readme.content_preview')"
check "the CHANGELOG preview is the CHANGELOG" "$(cat "$proj/CHANGELOG.md")" "$(json "$f" 'changelog.content_preview')"
check "a missing CONTRIBUTING.md is reported as missing" "False" "$(json "$f" 'contributing.exists')"

echo "extract-build-configs.sh"
check "exits 0" 0 "$(extract extract-build-configs.sh "$proj" "$x")"
f="$x/data/build_configs.json"
check "the workflow is listed" ".github/workflows/ci.yml" "$(json "$f" 'github_actions.files.0')"
check "phpunit.xml is listed" "phpunit.xml" "$(json "$f" 'phpunit.files.0')"

echo "extract-repo-metadata.sh"
norepo="$WORK/no-remote"; mkdir -p "$norepo"; git -C "$norepo" init -q .
check "a repository without a GitHub/GitLab remote exits 0" 0 "$(extract extract-repo-metadata.sh "$norepo" "$WORK/meta")"
check "and records that there is none" "False" "$(json "$WORK/meta/data/repo_metadata.json" 'repository.exists')"

echo "extract-all.sh"
check "the core extractions run and exit 0" 0 "$(extract extract-all.sh "$proj" "$WORK/all")"
check "the core files are written" "5" "$(find "$WORK/all/data" -name '*.json' | wc -l | tr -d ' ')"
check "an unknown option exits 1" 1 \
    "$( (cd "$proj" && DOCS_EXTRACTION_DIR="$WORK/all" bash "$SCRIPTS/extract-all.sh" --bogus >/dev/null 2>&1); echo $?)"

echo "extraction-dir.sh"
check "DOCS_EXTRACTION_DIR wins" "/some/where" "$(cd "$proj" && DOCS_EXTRACTION_DIR=/some/where bash "$SCRIPTS/extraction-dir.sh")"
expected="$WORK/tmp/typo3-docs-extraction/$(printf '%s' "$(cd "$proj" && pwd -P)" | sha256sum | cut -d' ' -f1)"
check "otherwise it is TMPDIR/typo3-docs-extraction/<sha256 of the project path>" "$expected" \
    "$(cd "$proj" && env -u DOCS_EXTRACTION_DIR TMPDIR="$WORK/tmp" bash "$SCRIPTS/extraction-dir.sh")"

echo
if [ "$fail" -eq 0 ]; then
    echo "All extract-script tests passed"
else
    echo "Some extract-script tests FAILED"
fi
exit "$fail"
