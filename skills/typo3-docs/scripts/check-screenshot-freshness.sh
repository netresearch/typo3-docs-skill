#!/usr/bin/env bash
# TD-55: the screenshots are not older than the interface they show.
#
# Severity `info` on purpose. Measured over the netresearch t3x fleet, five of
# the six repositories with screenshots have changed templates or public assets
# substantially since their newest image, and only one has not — so this is a
# bar the fleet does not currently meet rather than a pass/fail gate, which is
# what a bonus indicator is for. It is the one signal here that measures decay
# instead of volume: an outdated screenshot is worse than a missing one,
# because it actively describes an interface that no longer exists.
#
# The 200-line threshold is calibrated, not invented: across that fleet the
# observed magnitudes were 37 lines for the one current repository and 255 to
# 1354 for the rest. It sits in the gap, not at either edge.
set -euo pipefail

[ -d Documentation ] || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
# A shallow clone or a --no-tags CI checkout knows a truncated history, and the
# comparison would describe the checkout rather than the repository.
[ "$(git rev-parse --is-shallow-repository 2>/dev/null)" = "true" ] && exit 0

image_dir=""
for dir in Documentation/Images Documentation/_Images; do
    [ -d "$dir" ] || continue
    if find "$dir" -type f \( -iname '*.png' -o -iname '*.avif' -o -iname '*.jpg' \
        -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' \) 2>/dev/null \
        | head -1 | grep -q .; then
        image_dir="$dir"
        break
    fi
done
# No screenshots at all is TD-54's business, not this check's.
[ -n "$image_dir" ] || exit 0

visual=""
for p in Resources/Private/Templates Resources/Private/Partials Resources/Public; do
    [ -e "$p" ] && visual="$visual $p"
done
[ -n "$visual" ] || exit 0

# shellcheck disable=SC2086
last_image=$(git log -1 --format=%H -- "$image_dir" 2>/dev/null || true)
[ -n "$last_image" ] || exit 0

# shellcheck disable=SC2086
changed=$(git diff --shortstat "$last_image..HEAD" -- $visual 2>/dev/null || true)
lines=$(printf '%s' "$changed" | grep -oE '[0-9]+ (insertion|deletion)' \
    | grep -oE '^[0-9]+' | paste -sd+ - 2>/dev/null || true)
total=$(( ${lines:-0} + 0 ))

[ "$total" -le 200 ] && exit 0

days=$(( ( $(git log -1 --format=%ct HEAD) - $(git log -1 --format=%ct "$last_image") ) / 86400 ))
echo "Templates and public assets changed by $total lines since the newest screenshot (${days} days ago)."
echo "  Re-take the screenshots that show those surfaces, or confirm they still match."
exit 1
