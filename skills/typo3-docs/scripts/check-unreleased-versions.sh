#!/usr/bin/env bash
# Warn when versionadded/versionchanged names a version that never shipped.
#
# Documenting the version currently being built is correct practice, not a
# finding — upstream writes the documentation for a release while that release
# is being built, so the docs are ready when it lands. The real defect is
# narrower: the number turns out wrong because the next release went elsewhere
# (documented 1.3.0, but the project released 1.2.0 -> 2.0.0). That is only
# decidable in hindsight, once a *higher* version exists, which is exactly when
# this check can see it.
set -euo pipefail

released=$(git tag -l 2>/dev/null | sed 's/^v//' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V || true)
[ -n "$released" ] || exit 0
highest=$(printf '%s\n' "$released" | tail -1)

documented=$(grep -rhoE 'version(added|changed):: *[0-9]+\.[0-9]+\.[0-9]+' \
    Documentation/ 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u || true)

skipped=""
for ver in $documented; do
    # Shipped under either tag spelling: nothing to say.
    if printf '%s\n' "$released" | grep -qx "$ver"; then
        continue
    fi
    # Not shipped, and nothing higher exists yet: this is the pending release.
    if [ "$ver" = "$highest" ] \
        || [ "$(printf '%s\n%s\n' "$ver" "$highest" | sort -V | tail -1)" = "$ver" ]; then
        continue
    fi
    skipped="$skipped $ver"
done

[ -n "$skipped" ] || exit 0
echo "versionadded/versionchanged names version(s) that never shipped:$skipped"
echo "  highest released version is $highest — correct the numbers or drop the directives"
exit 1
