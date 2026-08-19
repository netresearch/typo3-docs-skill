#!/usr/bin/env bash
# TD-53: every documented option carries its type and its default.
#
# Depth per entry rather than number of entries: a page with five complete
# options beats four pages of half-described ones, and the score does not move
# when an extension is small. Measured over the netresearch t3x fleet this
# spread from 20% to 100% across 15 repositories — the widest spread of any
# documentation-quality signal tried, which is why it is a checkpoint.
set -euo pipefail

[ -d Documentation ] || exit 0

# shellcheck disable=SC2016  # the $ signs belong to awk, not to the shell
report=$(find Documentation -name '*.rst' -print0 2>/dev/null \
    | xargs -0 -r awk '
    # A confval block runs until the next directive at the same or lower indent,
    # or a line at column 0 that is not blank.
    function flush() {
        if (in_block) {
            if (!(has_type && has_default)) {
                missing = (has_type ? "" : ":type: ") (has_default ? "" : ":default:")
                printf "%s:%d: confval %s lacks %s\n", file, start, name, missing
            }
        }
        in_block = 0; has_type = 0; has_default = 0
    }
    FNR == 1 { flush(); file = FILENAME }
    match($0, /^[[:space:]]*\.\.[[:space:]]+confval::[[:space:]]*/) {
        flush()
        in_block = 1; start = FNR
        name = substr($0, RSTART + RLENGTH)
        sub(/[[:space:]].*$/, "", name)
        indent = match($0, /[^[:space:]]/) - 1
        next
    }
    in_block && /^[[:space:]]*:type:/    { has_type = 1 }
    in_block && /^[[:space:]]*:[Dd]efault:/ { has_default = 1 }
    # Any following directive, or content back at column 0, closes the block.
    in_block && /^[[:space:]]*\.\.[[:space:]]+[a-zA-Z:]+::/ { flush() }
    in_block && /^[^[:space:]]/ && !/^\.\./ { flush() }
    END { flush() }
')

[ -z "$report" ] && exit 0

echo "$report"
n=$(printf '%s\n' "$report" | grep -c ':' || true)
echo "  $n confval block(s) without :type: and/or :default: — state both so the reader"
echo "  does not have to open the code to learn what a value may be"
exit 1
