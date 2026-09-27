#!/usr/bin/env bash
# tests/checkpoint-scripts.sh — exercises the documentation-quality checkpoint
# scripts against fixtures.
#
# Every "must fire" case is paired with a companion proving the same fixture is
# otherwise silent. Without that pair a non-zero exit only shows the fixture is
# invalid for some other reason, not that the check works: three assertions in
# an earlier suite were green before their implementation existed, because the
# fixture tripped an unrelated precondition.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$HERE/../skills/typo3-docs/scripts"
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

run() { # run <script> <fixture-dir>
    ( cd "$2" && bash "$SCRIPTS/$1" >/dev/null 2>&1 )
    echo $?
}

fixture() { # fixture <name> -> echoes its path, with Documentation/ present
    d="$WORK/$1"
    rm -rf "$d"
    mkdir -p "$d/Documentation"
    printf 'Index\n=====\n' > "$d/Documentation/Index.rst"
    echo "$d"
}

echo "check-settings-documented.sh"
d=$(fixture settings-ok)
printf '# cat=basic; type=string; label=API key\napiKey = \nendpoint = https://x\n' > "$d/ext_conf_template.txt"
printf 'Settings\n========\n\napiKey does this, endpoint that.\n' > "$d/Documentation/Settings.rst"
check "documented settings stay silent" 0 "$(run check-settings-documented.sh "$d")"

d=$(fixture settings-missing)
printf 'apiKey = \nendpoint = https://x\n' > "$d/ext_conf_template.txt"
printf 'Settings\n========\n\napiKey does this.\n' > "$d/Documentation/Settings.rst"
check "an undocumented setting fires" 1 "$(run check-settings-documented.sh "$d")"

d=$(fixture settings-none)
printf 'Docs only\n' > "$d/Documentation/Settings.rst"
check "no ext_conf_template is not a finding" 0 "$(run check-settings-documented.sh "$d")"

d=$(fixture settings-comments)
printf '# cat=basic; type=string; label=Not a setting: decoy = value\napiKey = \n' > "$d/ext_conf_template.txt"
printf 'Settings\n========\n\napiKey only.\n' > "$d/Documentation/Settings.rst"
check "a key-shaped word inside a comment is not counted" 0 "$(run check-settings-documented.sh "$d")"

echo "check-confval-completeness.sh"
d=$(fixture confval-ok)
cat > "$d/Documentation/Settings.rst" <<'EOF'
Settings
========

..  confval:: apiKey

    :type: string
    :Default: (empty)

    The key.

..  confval:: timeout

    :type: int
    :default: 30

    Seconds.
EOF
check "complete confvals stay silent" 0 "$(run check-confval-completeness.sh "$d")"

d=$(fixture confval-missing-default)
cat > "$d/Documentation/Settings.rst" <<'EOF'
Settings
========

..  confval:: apiKey

    :type: string

    The key.
EOF
check "a confval without :default: fires" 1 "$(run check-confval-completeness.sh "$d")"

d=$(fixture confval-missing-type)
cat > "$d/Documentation/Settings.rst" <<'EOF'
Settings
========

..  confval:: apiKey

    :default: none

    The key.
EOF
check "a confval without :type: fires" 1 "$(run check-confval-completeness.sh "$d")"

d=$(fixture confval-none)
printf 'Prose\n=====\n\nNo confvals here.\n' > "$d/Documentation/Settings.rst"
check "documentation without confvals is not a finding" 0 "$(run check-confval-completeness.sh "$d")"

d=$(fixture confval-two-blocks)
cat > "$d/Documentation/Settings.rst" <<'EOF'
Settings
========

..  confval:: complete

    :type: string
    :default: x

..  confval:: incomplete

    :type: string

Another section
===============
EOF
check "the options of one block do not satisfy the next" 1 "$(run check-confval-completeness.sh "$d")"

echo "check-ui-surface-screenshots.sh"
d=$(fixture ui-with-screenshot)
mkdir -p "$d/Configuration/Backend" "$d/Documentation/Images"
printf '<?php\nreturn ["web_demo" => ["parent" => "web"]];\n' > "$d/Configuration/Backend/Modules.php"
printf 'x' > "$d/Documentation/Images/Module.png"
check "a module with a screenshot stays silent" 0 "$(run check-ui-surface-screenshots.sh "$d")"

d=$(fixture ui-without-screenshot)
mkdir -p "$d/Configuration/Backend"
printf '<?php\nreturn ["web_demo" => ["parent" => "web"]];\n' > "$d/Configuration/Backend/Modules.php"
check "a module without any screenshot fires" 1 "$(run check-ui-surface-screenshots.sh "$d")"

d=$(fixture ui-none)
check "an extension without a UI surface is not asked for pictures" 0 "$(run check-ui-surface-screenshots.sh "$d")"

d=$(fixture ui-plugin-without-screenshot)
mkdir -p "$d/Configuration/TCA/Overrides"
printf '<?php\nExtensionUtility::registerPlugin("Demo", "Pi1", "Demo");\n' \
    > "$d/Configuration/TCA/Overrides/tt_content.php"
check "a frontend plugin counts as a surface too" 1 "$(run check-ui-surface-screenshots.sh "$d")"

echo "check-screenshot-freshness.sh"
setup_repo() { # setup_repo <dir>
    git -C "$1" init -q .
    git -C "$1" config user.email t@example.invalid
    git -C "$1" config user.name Test
    git -C "$1" config commit.gpgsign false
}
commit() { git -C "$1" add -A && git -C "$1" commit -q --no-verify -m "$2"; }

d=$(fixture fresh-repo)
mkdir -p "$d/Documentation/Images" "$d/Resources/Private/Templates"
setup_repo "$d"
printf 'x' > "$d/Documentation/Images/Module.png"
printf 'small\n' > "$d/Resources/Private/Templates/List.html"
commit "$d" "initial"
printf 'one more line\n' >> "$d/Resources/Private/Templates/List.html"
commit "$d" "tiny template change"
check "a small change after the screenshot stays silent" 0 "$(run check-screenshot-freshness.sh "$d")"

d=$(fixture stale-repo)
mkdir -p "$d/Documentation/Images" "$d/Resources/Private/Templates"
setup_repo "$d"
printf 'x' > "$d/Documentation/Images/Module.png"
printf 'start\n' > "$d/Resources/Private/Templates/List.html"
commit "$d" "initial"
seq 1 400 > "$d/Resources/Private/Templates/List.html"
commit "$d" "rewrite the template"
check "a large template rewrite after the screenshot fires" 1 "$(run check-screenshot-freshness.sh "$d")"

d=$(fixture no-images-repo)
mkdir -p "$d/Resources/Private/Templates"
setup_repo "$d"
seq 1 400 > "$d/Resources/Private/Templates/List.html"
commit "$d" "initial"
check "no screenshots is TD-54's business, not this one's" 0 "$(run check-screenshot-freshness.sh "$d")"

d=$(fixture no-git-repo)
mkdir -p "$d/Documentation/Images" "$d/Resources/Private/Templates"
printf 'x' > "$d/Documentation/Images/Module.png"
check "outside a git repository the check stays silent" 0 "$(run check-screenshot-freshness.sh "$d")"

echo "check-guides-xml-version-sync.sh"
guides() { # guides <dir> <version> <release> <emconf-version>
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<guides xmlns="https://www.phpdoc.org/guides">\n    <project title="T" version="%s" release="%s"/>\n</guides>\n' \
        "$2" "$3" > "$1/Documentation/guides.xml"
    printf "<?php\n\$EM_CONF[\$_EXTKEY] = [\n    'version' => '%s',\n];\n" "$4" > "$1/ext_emconf.php"
}
d=$(fixture guides-short-version)
guides "$d" 0.8 0.8.2 0.8.2
check "version=major.minor, release=full (the skill's template) stays silent" 0 "$(run check-guides-xml-version-sync.sh "$d")"

d=$(fixture guides-full-version)
guides "$d" 0.8.2 0.8.2 0.8.2
check "version=release=full version stays silent" 0 "$(run check-guides-xml-version-sync.sh "$d")"

d=$(fixture guides-stale-release)
guides "$d" 0.8 0.8.1 0.8.2
check "a stale release fires" 1 "$(run check-guides-xml-version-sync.sh "$d")"

d=$(fixture guides-stale-version)
guides "$d" 0.7 0.8.2 0.8.2
check "a stale major.minor version fires" 1 "$(run check-guides-xml-version-sync.sh "$d")"

echo "check-adr-coverage.sh"
classes() { # classes <dir> -> eleven PHP classes
    mkdir -p "$1/Classes"
    for i in $(seq 1 11); do printf '<?php\nclass C%s {}\n' "$i" > "$1/Classes/C$i.php"; done
}
d=$(fixture adr-developer)
classes "$d"; mkdir -p "$d/Documentation/Developer/Adr"
check "Documentation/Developer/Adr/ stays silent" 0 "$(run check-adr-coverage.sh "$d")"

d=$(fixture adr-top-level)
classes "$d"; mkdir -p "$d/Documentation/Adr"
check "Documentation/Adr/ stays silent" 0 "$(run check-adr-coverage.sh "$d")"

d=$(fixture adr-none)
classes "$d"
check "eleven classes without an ADR directory fire" 1 "$(run check-adr-coverage.sh "$d")"

echo "check-rst-substitutions-resolve.sh"
subs_fixture() { # subs_fixture <name> -> fixture whose Includes.rst.txt defines |extension_key|
    d=$(fixture "$1")
    printf '.. |extension_key| replace:: my_ext\n' > "$d/Documentation/Includes.rst.txt"
    echo "$d"
}
d=$(subs_fixture subs-include-only)
printf '.. include:: /Includes.rst.txt\n\nPage\n====\n\nInstall |extension_key| now.\n' > "$d/Documentation/Page.rst"
check "a substitution defined only in Includes.rst.txt fires" 1 "$(run check-rst-substitutions-resolve.sh "$d")"

d=$(subs_fixture subs-local)
printf '.. |extension_key| replace:: my_ext\n\nPage\n====\n\nInstall |extension_key| now.\n' > "$d/Documentation/Page.rst"
check "a substitution defined on the page itself stays silent" 0 "$(run check-rst-substitutions-resolve.sh "$d")"

d=$(subs_fixture subs-hardcoded)
printf '.. include:: /Includes.rst.txt\n\nPage\n====\n\nInstall my_ext and my_ext_tts now.\n' > "$d/Documentation/Page.rst"
check "a hardcoded value is not a finding" 0 "$(run check-rst-substitutions-resolve.sh "$d")"

d=$(subs_fixture subs-builtin)
printf '.. include:: /Includes.rst.txt\n\nPage\n====\n\n:Version: |release|\n:Rendered: |today|\n' > "$d/Documentation/Page.rst"
check "guides.xml built-ins (|release|, |today|) stay silent" 0 "$(run check-rst-substitutions-resolve.sh "$d")"

d=$(subs_fixture subs-literals)
cat > "$d/Documentation/Page.rst" <<'EOF'
.. include:: /Includes.rst.txt

Page
====

Inline ``|extension_key|`` and a multi-line ``a →
b|extension_key|c`` literal, plus :php:`$x = '|extension_key|'`.

..  code-block:: bash

    composer req vendor/|extension_key|

::

    status: queued → |extension_key| → done
EOF
check "literals, code blocks and interpreted text stay silent" 0 "$(run check-rst-substitutions-resolve.sh "$d")"
printf '\nAfter the block: |extension_key|.\n' >> "$d/Documentation/Page.rst"
check "prose after a code block is scanned again" 1 "$(run check-rst-substitutions-resolve.sh "$d")"

d=$(subs_fixture subs-table)
printf '.. include:: /Includes.rst.txt\n\nPage\n====\n\n+-----+-----+\n| a   | b   |\n+-----+-----+\n\n| line block\n' > "$d/Documentation/Page.rst"
check "grid tables and line blocks are not substitution references" 0 "$(run check-rst-substitutions-resolve.sh "$d")"

echo
if [ "$fail" -eq 0 ]; then
    echo "All checkpoint-script tests passed"
else
    echo "Some checkpoint-script tests FAILED"
fi
exit "$fail"
