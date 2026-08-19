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

echo
if [ "$fail" -eq 0 ]; then
    echo "All checkpoint-script tests passed"
else
    echo "Some checkpoint-script tests FAILED"
fi
exit "$fail"
