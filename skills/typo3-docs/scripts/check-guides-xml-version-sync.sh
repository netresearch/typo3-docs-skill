#!/usr/bin/env bash
# Check that guides.xml <project> release matches the ext_emconf.php version and
# <project> version matches its major.minor (the full version is accepted too).
# SKILL.md and references/guides-xml.md write version="MAJOR.MINOR" and
# release="MAJOR.MINOR.PATCH". Checkpoint TD-30 mirrors this script.
set -euo pipefail

[ ! -f Documentation/guides.xml ] && exit 0
[ ! -f ext_emconf.php ] && exit 0
command -v php >/dev/null 2>&1 || { echo "php not found, cannot parse guides.xml" >&2; exit 0; }

# Read the attributes off the <project> element: a plain grep for version="…"
# first hits the XML declaration's version="1.0".
# shellcheck disable=SC2016  # PHP source; the $ must reach php unexpanded
attrs=$(php -r '$d = new DOMDocument();
if (!@$d->load("Documentation/guides.xml")) { exit(1); }
$p = $d->getElementsByTagNameNS("https://www.phpdoc.org/guides", "project")->item(0);
if ($p === null) { exit(1); }
echo trim($p->getAttribute("version")), "\n", trim($p->getAttribute("release")), "\n";' 2>/dev/null) || true
[ -n "$attrs" ] || exit 0

guides_version=$(printf '%s\n' "$attrs" | sed -n 1p)
guides_release=$(printf '%s\n' "$attrs" | sed -n 2p)
emconf_ver=$(grep -oP "'version'\s*=>\s*'[^']*'" ext_emconf.php 2>/dev/null | grep -oP "'[^']*'$" | tr -d "'" || true)
[ -n "$emconf_ver" ] || exit 0
emconf_short=$(printf '%s\n' "$emconf_ver" | cut -d. -f1-2)

errors=0

if [ -n "$guides_version" ] && [ "$guides_version" != "$emconf_short" ] && [ "$guides_version" != "$emconf_ver" ]; then
    echo "Version mismatch: guides.xml version=\"$guides_version\" != ext_emconf.php major.minor '$emconf_short' (or full '$emconf_ver')"
    errors=1
fi

if [ -n "$guides_release" ] && [ "$guides_release" != "$emconf_ver" ]; then
    echo "Release mismatch: guides.xml release=\"$guides_release\" != ext_emconf.php version='$emconf_ver'"
    errors=1
fi

exit "$errors"
