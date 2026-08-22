#!/usr/bin/env bash
#
# Fail when Documentation/guides.xml will not render.
#
# Usage: ./check-guides-xml-schema.sh [project_root]
#
# Why this exists as its own check.
#
# `validate_docs.sh` used to test `[ -f Documentation/guides.xml ]` and print
# "guides.xml found (modern PHP-based rendering)". It never opened the file, so
# a file named guides.xml containing an invented schema was reported as fine —
# the validator actively reassured on the defect. Checkpoint TD-05 was
# `contains "<project"`, which a hallucinated `<project>my-ext</project>`
# satisfies.
#
# Measured, not assumed: across two recorded series of OFR-TYPO3-DOCS-001 in
# netresearch/agent-system-evals, agents produced SEVEN distinct fabricated
# namespaces and not one correct file. Three of them would have passed both
# gates above. See netresearch/typo3-docs-skill#91.
#
# What is asserted, and why exactly this:
#
#   * the root element is in https://www.phpdoc.org/guides. Rendering is done
#     by phpDocumentor Guides, so the document lives in phpDocumentor's
#     namespace and not in a typo3.org one. Verified against every TYPO3
#     project checked: georgringer/news, FriendsOfTYPO3/extension_builder,
#     TYPO3-Documentation/TYPO3CMS-Reference-TCA, helhum/typo3-console.
#   * <project> carries `title` and `release` as ATTRIBUTES. The renderer reads
#     them from attributes; an element with the extension key as text is the
#     shape agents reach for and is silently wrong.
#
# Deliberately not a schema validation: guides.xsd lives in the vendor tree and
# is absent before `composer install`, so a check that needed it would be
# skipped exactly where documentation is being created from nothing.

set -eu

PROJECT_ROOT="${1:-.}"
GUIDES="$PROJECT_ROOT/Documentation/guides.xml"
NS="https://www.phpdoc.org/guides"

if [ ! -f "$GUIDES" ]; then
    echo "❌ $GUIDES does not exist"
    echo "   Copy assets/guides.xml.dist and fill the placeholders."
    exit 1
fi

if ! command -v php >/dev/null 2>&1; then
    echo "⚠️  php not found; cannot parse $GUIDES"
    echo "   This check needs php, which this skill requires anyway."
    exit 2
fi

# The PHP body is single-quoted on purpose: $argv, $doc and $root belong to
# PHP, and letting the shell expand them would substitute empty strings.
# shellcheck disable=SC2016
php -r '
$file = $argv[1];
$ns = $argv[2];
$doc = new DOMDocument();
if (!@$doc->load($file)) {
    $e = libxml_get_last_error();
    fwrite(STDERR, "not well-formed XML" . ($e ? ": " . trim($e->message) : "") . "\n");
    exit(1);
}
$root = $doc->documentElement;
if ($root->namespaceURI !== $ns) {
    fwrite(STDERR, sprintf(
        "root element is in namespace %s, not %s\n",
        $root->namespaceURI === null ? "(none)" : $root->namespaceURI,
        $ns
    ));
    exit(1);
}
$project = $doc->getElementsByTagNameNS($ns, "project")->item(0);
if ($project === null) {
    fwrite(STDERR, "no <project> element\n");
    exit(1);
}
$missing = [];
foreach (["title", "release"] as $attribute) {
    if (trim($project->getAttribute($attribute)) === "") {
        $missing[] = $attribute;
    }
}
if ($missing !== []) {
    fwrite(STDERR, sprintf(
        "<project> has no %s attribute%s%s\n",
        implode(" and no ", $missing),
        count($missing) > 1 ? "s" : "",
        trim($project->textContent) !== ""
            ? " (the extension key is in the element text; the renderer reads attributes)"
            : ""
    ));
    exit(1);
}
exit(0);
' "$GUIDES" "$NS" 2>/tmp/guides-xml-check.$$ || {
    echo "❌ $GUIDES will not render: $(cat /tmp/guides-xml-check.$$)"
    rm -f /tmp/guides-xml-check.$$
    echo "   Expected: <guides xmlns=\"$NS\"> with"
    echo "   <project title=\"…\" release=\"…\" version=\"…\" copyright=\"…\"/>"
    echo "   assets/guides.xml.dist is that file; copy it rather than writing one."
    exit 1
}
rm -f /tmp/guides-xml-check.$$
echo "✅ guides.xml is in $NS with a <project> carrying title and release"
