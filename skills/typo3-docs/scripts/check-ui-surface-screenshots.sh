#!/usr/bin/env bash
# TD-54: an extension with a user interface shows it at least once.
#
# Binds to what the code registers — backend modules and frontend plugins —
# rather than to a screenshot count, so this cannot ask a library for pictures
# and cannot ask a one-module extension for ten. Deliberately only the zero
# case: how MANY screenshots are enough is not mechanically decidable. Measured
# over the netresearch t3x fleet, one repository keeps eight images for what the
# registries report as a single module, and reading them shows four genuine
# surfaces (administration, configuration, login, user settings) that no
# registry declares. A count-based rule flagged all three such repositories
# wrongly, so it was dropped and only "none at all" remains.
set -euo pipefail

[ -d Documentation ] || exit 0

modules=0
if [ -f Configuration/Backend/Modules.php ]; then
    if command -v php >/dev/null 2>&1; then
        # shellcheck disable=SC2016  # $m is PHP's variable, not the shell's
        modules=$(php -r '$m = @include "Configuration/Backend/Modules.php";
            echo is_array($m) ? count($m) : -1;' 2>/dev/null || echo -1)
    else
        modules=-1
    fi
    if [ "$modules" = "-1" ]; then
        # Old-style registration (ExtensionManagementUtility::addModule) does not
        # return an array. Count registrations instead, and say the number is an
        # estimate rather than presenting it as a measurement.
        modules=$({ grep -cE "addModule|^ {4}'[A-Za-z0-9_]+' *=>" \
            Configuration/Backend/Modules.php 2>/dev/null || true; } | head -1)
        modules=${modules:-0}
        estimated=" (estimated: this Modules.php does not return an array)"
    fi
fi

plugins=0
if [ -d Configuration/TCA/Overrides ]; then
    # `grep` exits 1 when it matches nothing, and under `set -e` with `pipefail`
    # that killed the script before it reached the image count — a silent exit 1
    # that reads as a finding. Measured on two repositories of the fleet.
    plugins=$({ grep -rhoE 'registerPlugin|addPlugin' Configuration/TCA/Overrides/ 2>/dev/null || true; } | wc -l)
fi

surfaces=$((modules + plugins))
[ "$surfaces" -gt 0 ] || exit 0

images=0
for dir in Documentation/Images Documentation/_Images; do
    [ -d "$dir" ] || continue
    found=$({ find "$dir" -type f \
        \( -iname '*.png' -o -iname '*.avif' -o -iname '*.jpg' -o -iname '*.jpeg' \
           -o -iname '*.gif' -o -iname '*.webp' \) 2>/dev/null || true; } | wc -l)
    images=$((images + found))
done

[ "$images" -gt 0 ] && exit 0

echo "This extension registers $surfaces user-interface surface(s)${estimated:-} but Documentation/ has no screenshot."
echo "  A reader cannot tell what the module or plugin looks like before installing it."
exit 1
