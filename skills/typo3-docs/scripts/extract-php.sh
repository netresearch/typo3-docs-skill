#!/usr/bin/env bash

#
# Extract PHP Code Documentation
#
# Parses PHP files in Classes/ directory to extract:
# - Class names, namespaces, descriptions
# - Method signatures and docblocks
# - Constants with descriptions
# - Security-critical comments
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_DIR="$(pwd)"
DATA_DIR="$(bash "$(dirname "${BASH_SOURCE[0]}")/extraction-dir.sh")/data"
# shellcheck source=SCRIPTDIR/json-string.sh
. "$(dirname "${BASH_SOURCE[0]}")/json-string.sh"
OUTPUT_FILE="${DATA_DIR}/php_apis.json"

CLASSES_DIR="${PROJECT_DIR}/Classes"

# TYPO3 Architecture Documentation Priorities
# Based on references/typo3-extension-architecture.md
get_doc_priority() {
    local file_path=$1
    if [[ "$file_path" == *"Controller"* ]]; then
        echo "HIGH"
    elif [[ "$file_path" == *"Domain/Model"* ]]; then
        echo "HIGH"
    elif [[ "$file_path" == *"Domain/Repository"* ]]; then
        echo "MEDIUM-HIGH"
    elif [[ "$file_path" == *"Service"* ]]; then
        echo "MEDIUM-HIGH"
    elif [[ "$file_path" == *"ViewHelper"* ]]; then
        echo "MEDIUM"
    elif [[ "$file_path" == *"Utility"* ]]; then
        echo "MEDIUM"
    else
        echo "MEDIUM"
    fi
}

get_class_category() {
    local file_path=$1
    if [[ "$file_path" == *"Controller"* ]]; then
        echo "controller"
    elif [[ "$file_path" == *"Domain/Model"* ]]; then
        echo "model"
    elif [[ "$file_path" == *"Domain/Repository"* ]]; then
        echo "repository"
    elif [[ "$file_path" == *"Service"* ]]; then
        echo "service"
    elif [[ "$file_path" == *"ViewHelper"* ]]; then
        echo "viewhelper"
    elif [[ "$file_path" == *"Utility"* ]]; then
        echo "utility"
    else
        echo "other"
    fi
}

# Create output directory
mkdir -p "${DATA_DIR}"

# Check if Classes/ exists
if [ ! -d "${CLASSES_DIR}" ]; then
    echo -e "${YELLOW}No Classes/ directory found, skipping PHP extraction${NC}"
    echo '{"classes": []}' > "${OUTPUT_FILE}"
    exit 0
fi

echo "Scanning PHP files in: ${CLASSES_DIR}"

# Initialize JSON output
{
    echo '{'
    printf '  "extraction_date": "%s",\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo '  "classes": ['
} > "${OUTPUT_FILE}"

# Find all PHP files
php_files=$(find "${CLASSES_DIR}" -type f -name "*.php" | sort)
file_count=$(echo "$php_files" | wc -l)
current=0
written=0

while IFS= read -r php_file; do
    [ -n "$php_file" ] || continue
    current=$((current + 1))
    rel_path="${php_file#"$PROJECT_DIR"/}"

    echo "  Processing: ${rel_path} (${current}/${file_count})"

    # Extract class information using grep and sed
    # This is a simplified extraction - full parsing would require PHP parser

    # Get namespace
    namespace=$(grep -m 1 '^namespace ' "$php_file" | sed 's/namespace //;s/;//' || echo "")

    # Get class name
    class_name=$(grep -m 1 '^class \|^final class \|^abstract class ' "$php_file" | \
                 sed 's/^class //;s/^final class //;s/^abstract class //;s/ extends.*//;s/ implements.*//;s/{//;s/ //g' || echo "")

    if [ -z "$class_name" ]; then
        continue
    fi

    # Get class docblock (simplified - just get the first /** */ block)
    class_desc=$(awk '/\/\*\*/{flag=1;next}/\*\//{flag=0}flag' "$php_file" | head -20 | grep -v '^ \* @' | sed 's/^ \* //;s/^ \*$//' | tr '\n' ' ' | sed 's/  */ /g;s/^ //;s/ $//')

    # Get author
    author=$(grep '@author' "$php_file" | head -1 | sed 's/.*@author //;s/ *$//' || echo "")

    # Get license
    license=$(grep '@license' "$php_file" | head -1 | sed 's/.*@license //;s/ *$//' || echo "")

    # Get documentation priority
    doc_priority=$(get_doc_priority "$rel_path")
    class_category=$(get_class_category "$rel_path")

    # Build JSON entry (simplified structure). The separator depends on the
    # entries written, not on the files read: a file without a class (an
    # interface, a trait) is skipped and must not leave a leading comma.
    {
        if [ "$written" -gt 0 ]; then
            echo '    ,'
        fi
        echo '    {'
        printf '      "name": %s,\n' "$(json_string "$class_name")"
        printf '      "namespace": %s,\n' "$(json_string "$namespace")"
        printf '      "file": %s,\n' "$(json_string "$rel_path")"
        printf '      "description": %s,\n' "$(json_string "$class_desc")"
        printf '      "author": %s,\n' "$(json_string "$author")"
        printf '      "license": %s,\n' "$(json_string "$license")"
        printf '      "documentation_priority": %s,\n' "$(json_string "$doc_priority")"
        printf '      "category": %s\n' "$(json_string "$class_category")"
        echo -n '    }'
    } >> "${OUTPUT_FILE}"
    written=$((written + 1))
done <<< "$php_files"

# Close JSON
{
    echo
    echo '  ]'
    echo '}'
} >> "${OUTPUT_FILE}"

echo -e "${GREEN}✓ PHP extraction complete: ${OUTPUT_FILE}${NC}"
echo "  Found ${file_count} PHP files"

# NOTE: This is a simplified extractor using bash/grep/sed
# For production use, consider using:
# - nikic/php-parser (PHP)
# - phpdocumentor/reflection-docblock (PHP)
# - Python script with libcst or ast
