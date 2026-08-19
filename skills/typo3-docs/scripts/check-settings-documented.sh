#!/usr/bin/env bash
# TD-52: every setting the extension declares is mentioned in the documentation.
#
# The denominator comes from the code, not from a page count: ext_conf_template.txt
# says how many settings exist, so a three-setting extension can score full marks.
# Mentioned anywhere counts — using `confval` is better (typed, linkable) but is a
# recommendation, not the bar. Measured over the netresearch t3x fleet, this ranges
# from 0% to 100%, and one repo documents its settings in a backend module rather
# than in prose, which is why the check asks for a mention rather than a directive.
set -euo pipefail

[ -f ext_conf_template.txt ] || exit 0
[ -d Documentation ] || exit 0

missing=""
count=0
while IFS= read -r key; do
    count=$((count + 1))
    # A direct file grep, never `printf … | grep -q`: that pipeline inverts under
    # pipefail once the input passes the pipe buffer.
    if ! grep -rqF -- "$key" Documentation/ 2>/dev/null; then
        missing="$missing $key"
    fi
done < <(sed -e 's/#.*$//' ext_conf_template.txt \
         | grep -oE '^[A-Za-z][A-Za-z0-9_.]*[[:space:]]*=' \
         | sed -e 's/[[:space:]]*=$//' | sort -u)

[ "$count" -eq 0 ] && exit 0
[ -z "$missing" ] && exit 0

echo "Settings declared in ext_conf_template.txt but not mentioned in Documentation/:$missing"
echo "  ($count declared; document each one, ideally as a confval so it is typed and linkable)"
exit 1
