#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# tests/validation-scripts.sh — behaviour of the validation and rendering
# scripts in skills/typo3-docs/scripts/ that tests/checkpoint-scripts.sh does
# not cover: check-required-doc-sections.sh, check-untranslated-fluid-strings.sh,
# check-guides-xml-schema.sh, validate_docs.sh, validate_headings.py and
# render_docs.sh.
#
# render_docs.sh runs `docker run`. The tests put a stand-in `docker` first on
# PATH that records its arguments and writes the Index.html the real renderer
# would; no container is started and nothing is pulled.

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

run() { # run <script> <dir> [args...] -> exit code, run inside <dir>; output in $WORK/out
    local script=$1 dir=$2
    shift 2
    ( cd "$dir" && bash "$SCRIPTS/$script" "$@" >"$WORK/out" 2>&1 )
    echo $?
}

guides() { # guides <file> -> a guides.xml of the shape SKILL.md prescribes
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<guides xmlns="https://www.phpdoc.org/guides" links-are-relative="true">\n    <project title="Demo" version="1.2" release="1.2.3"/>\n</guides>\n' >"$1"
}

if ! command -v php >/dev/null 2>&1; then
    echo "  FAIL php is required to parse guides.xml and is not installed"
    exit 1
fi

echo "check-required-doc-sections.sh"
d="$WORK/sections"; mkdir -p "$d"
for s in Introduction Installation Configuration Usage Developer; do
    mkdir -p "$d/Documentation/$s"; printf '%s\n===\n' "$s" >"$d/Documentation/$s/Index.rst"
done
mkdir -p "$d/Documentation/FAQ"
check "all sections present exits 0" 0 "$(run check-required-doc-sections.sh "$d")"
rm "$d/Documentation/Usage/Index.rst"
check "a section directory without Index.rst fires" 1 "$(run check-required-doc-sections.sh "$d")"
check "the finding names the section" "Missing documentation sections: Usage" "$(cat "$WORK/out")"
printf 'Usage\n===\n' >"$d/Documentation/Usage/Index.rst"
printf "<?php\n\$EM_CONF[\$_EXTKEY] = ['category' => 'auth'];\n" >"$d/ext_emconf.php"
check "a security-related extension without Documentation/Security fires" 1 "$(run check-required-doc-sections.sh "$d")"
mkdir -p "$d/Documentation/Security"
check "and passes once it exists" 0 "$(run check-required-doc-sections.sh "$d")"
empty="$WORK/empty"; mkdir -p "$empty"
check "no Documentation/ fires" 1 "$(run check-required-doc-sections.sh "$empty")"

echo "check-untranslated-fluid-strings.sh"
d="$WORK/fluid"; mkdir -p "$d/Resources/Private/Templates"
printf '<a title="{f:translate(key: \x27more\x27)}" aria-label="Go">x</a>\n<img alt="Three word text" />\n' \
    >"$d/Resources/Private/Templates/List.html"
check "translated or short attribute values stay silent" 0 "$(run check-untranslated-fluid-strings.sh "$d")"
printf '<button aria-label="Open the main navigation menu">x</button>\n' >"$d/Resources/Private/Templates/Nav.html"
check "a hardcoded attribute of more than three words fires" 1 "$(run check-untranslated-fluid-strings.sh "$d")"
check "no Resources/Private/ is not a finding" 0 "$(run check-untranslated-fluid-strings.sh "$empty")"

echo "check-guides-xml-schema.sh"
d="$WORK/schema"; mkdir -p "$d/Documentation"
guides "$d/Documentation/guides.xml"
check "the prescribed shape passes" 0 "$(run check-guides-xml-schema.sh "$d")"
sed 's/{[A-Z_0-9]*}/x/g' "$SCRIPTS/../assets/guides.xml.dist" >"$d/Documentation/guides.xml"
check "assets/guides.xml.dist with its placeholders filled passes" 0 "$(run check-guides-xml-schema.sh "$d")"
printf '<?xml version="1.0"?>\n<guides xmlns="https://guides.typo3.org"><project title="T" release="1"/></guides>\n' >"$d/Documentation/guides.xml"
check "another namespace fails" 1 "$(run check-guides-xml-schema.sh "$d")"
check "and names the namespace it found" "yes" \
    "$(grep -qF 'root element is in namespace https://guides.typo3.org' "$WORK/out" && echo yes || echo no)"
printf '<?xml version="1.0"?>\n<guides xmlns="https://www.phpdoc.org/guides"><project>my_ext</project></guides>\n' >"$d/Documentation/guides.xml"
check "a <project> with text instead of attributes fails" 1 "$(run check-guides-xml-schema.sh "$d")"
printf '<guides xmlns="https://www.phpdoc.org/guides">\n' >"$d/Documentation/guides.xml"
check "malformed XML fails" 1 "$(run check-guides-xml-schema.sh "$d")"
check "a missing guides.xml fails" 1 "$(run check-guides-xml-schema.sh "$empty")"
check "the project root can be passed as an argument" 0 "$(guides "$d/Documentation/guides.xml"; run check-guides-xml-schema.sh "$empty" "$d")"

echo "validate_docs.sh"
d="$WORK/docs"; mkdir -p "$d/Documentation"
printf '=====\nDemo\n=====\n\nIntroduction\n============\n\nText.\n' >"$d/Documentation/Index.rst"
guides "$d/Documentation/guides.xml"
check "a minimal valid manual exits 0" 0 "$(run validate_docs.sh "$d" "$d")"
check "no Documentation/ exits 1" 1 "$(run validate_docs.sh "$empty" "$empty")"
d2="$WORK/no-rst"; mkdir -p "$d2/Documentation"
check "a Documentation/ without .rst files exits 1" 1 "$(run validate_docs.sh "$d2" "$d2")"
printf '<?xml version="1.0"?>\n<guides xmlns="https://guides.typo3.org"/>\n' >"$d2/Documentation/guides.xml"
printf 'Page\n====\n' >"$d2/Documentation/Page.rst"
check "a guides.xml that will not render exits 1" 1 "$(run validate_docs.sh "$d2" "$d2")"
guides "$d2/Documentation/guides.xml"
check "no Index.rst exits 1" 1 "$(run validate_docs.sh "$d2" "$d2")"
d3="$WORK/latin1"; mkdir -p "$d3/Documentation"
printf '=====\nDemo\n=====\n\nText.\n' >"$d3/Documentation/Index.rst"
printf '=====\nCaf\xe9\n=====\n\nText \xe9\n' >"$d3/Documentation/Other.rst"
guides "$d3/Documentation/guides.xml"
check "a Latin-1 .rst file under a UTF-8 locale is a warning, exit 0" 0 "$(LC_ALL=C.UTF-8 run validate_docs.sh "$d3" "$d3")"
check "and the encoding warning names the file" "yes" \
    "$(grep -q 'Non-UTF-8 encoding in: .*Other.rst' "$WORK/out" && echo yes || echo no)"

echo "validate_headings.py"
printf 'Page\n====\n\nSection\n-------\n\nSub\n~~~\n' >"$WORK/good.rst"
check "a correct hierarchy prints nothing" "" "$(python3 "$SCRIPTS/validate_headings.py" "$WORK/good.rst")"
printf 'Page\n====\n\nDeep\n~~~~\n' >"$WORK/skip.rst"
check "a skipped level is reported" "yes" \
    "$(python3 "$SCRIPTS/validate_headings.py" "$WORK/skip.rst" | grep -q 'skipping "-"' && echo yes || echo no)"
check "a wrong argument count exits 2" 2 "$(python3 "$SCRIPTS/validate_headings.py" >/dev/null 2>&1; echo $?)"

echo "render_docs.sh"
bin="$WORK/bin"; mkdir -p "$bin"
cat >"$bin/docker" <<'EOF'
#!/usr/bin/env bash
# Stand-in for docker: record the arguments, write what render-guides writes.
printf '%s\n' "$@" >"$DOCKER_LOG"
for arg in "$@"; do
    case "$arg" in
        *:/project) mkdir -p "${arg%:/project}/Documentation-GENERATED-temp"
                    [ -n "${FAKE_RENDER_OK:-}" ] && touch "${arg%:/project}/Documentation-GENERATED-temp/Index.html" ;;
    esac
done
exit 0
EOF
chmod +x "$bin/docker"
export DOCKER_LOG="$WORK/docker.log"
rm -f "$DOCKER_LOG"
check "no Documentation/ exits 1" 1 "$(PATH="$bin:$PATH" run render_docs.sh "$empty" "$empty")"
check "and does not call docker" "no" "$([ -e "$DOCKER_LOG" ] && echo yes || echo no)"
check "a successful render exits 0" 0 "$(FAKE_RENDER_OK=1 PATH="$bin:$PATH" run render_docs.sh "$WORK" "$d")"
check "docker mounts the project at /project" "$(cd "$d" && pwd):/project" "$(grep ':/project$' "$DOCKER_LOG")"
check "docker runs the official render-guides image" "ghcr.io/typo3-documentation/render-guides:latest" \
    "$(grep '^ghcr.io/' "$DOCKER_LOG")"
rm -rf "$d/Documentation-GENERATED-temp"
check "no Index.html after the run exits 1" 1 "$(PATH="$bin:$PATH" run render_docs.sh "$WORK" "$d")"

echo
if [ "$fail" -eq 0 ]; then
    echo "All validation-script tests passed"
else
    echo "Some validation-script tests FAILED"
fi
exit "$fail"
