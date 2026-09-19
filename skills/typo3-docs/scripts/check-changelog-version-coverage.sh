#!/usr/bin/env bash
# Check that CHANGELOG.md has entries for all git tags
set -euo pipefail

changelog=""
for f in CHANGELOG.md Changelog.md changelog.md Documentation/ChangeLog/Index.rst; do
    [ -f "$f" ] && changelog="$f" && break
done

[ -z "$changelog" ] && echo "No changelog file found" && exit 1

# Get all version-like tags
tags=$({ git tag -l 2>/dev/null | grep -P '^\d+\.\d+' || true; git tag -l 2>/dev/null | grep -P '^v\d+\.\d+' | sed 's/^v//' || true; })

[ -z "$tags" ] && exit 0

missing=()

while IFS= read -r tag; do
    [ -z "$tag" ] && continue
    # Strip leading 'v' for matching
    version=${tag#v}
    # The 'v' may sit INSIDE the brackets: both `## [2.19.1]` and
    # `## [v2.19.1](…/releases/tag/v2.19.1)` are in use across the fleet, and a
    # literal search for `[2.19.1]` reported every heading of the second kind
    # as missing — 59 false positives on a changelog that was complete, for a
    # repository that had simply picked the other convention. Accept either.
    #
    # Two FIXED strings rather than one regex. A regex needs the version
    # escaped, and escaping only `.` and `+` still mis-handles a legal tag like
    # `v2.19.2(1)` — `git check-ref-format` accepts `(`, `{` and `$` in a tag
    # name — which would be reported missing although its heading is there, and
    # would additionally let `[2.19.21]` satisfy it. grep -F has no pattern
    # language, so neither can happen.
    if ! grep -qF -e "[${version}]" -e "[v${version}]" "$changelog" 2>/dev/null; then
        missing+=("$version")
    fi
done <<< "$tags"

if [ ${#missing[@]} -gt 0 ]; then
    echo "Versions missing from $changelog: ${missing[*]}"
    exit 1
fi

exit 0
