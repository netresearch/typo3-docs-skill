# shellcheck shell=bash
# Sourced by the extract-*.sh scripts; defines json_string. Not run directly.
#
#   json_string <text>   prints <text> as a JSON string literal, quotes included
#
# The extractors assemble their JSON with echo/printf. A value taken from the
# project (a PHP namespace, a label, a README line) is only safe inside that
# JSON once backslashes, double quotes and control characters are escaped: an
# unescaped `Vendor\Ext` namespace made php_apis.json unreadable for jq.

json_string() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\r'/\\r}
    s=${s//$'\t'/\\t}
    # The other control characters (U+0001–U+001F) are not allowed in a JSON
    # string and carry no text; drop them.
    s=$(printf '%s' "$s" | tr -d '\001-\010\013\014\016-\037')
    printf '"%s"' "$s"
}
