#!/usr/bin/env bash

#
# Extract Project Files
#
# Extracts content from:
# - README.md
# - CHANGELOG.md
# - CONTRIBUTING.md (if exists)
#

set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROJECT_DIR="$(pwd)"
DATA_DIR="$(bash "$(dirname "${BASH_SOURCE[0]}")/extraction-dir.sh")/data"
OUTPUT_FILE="${DATA_DIR}/project_files.json"
# shellcheck source=SCRIPTDIR/json-string.sh
. "$(dirname "${BASH_SOURCE[0]}")/json-string.sh"

mkdir -p "${DATA_DIR}"

echo "Extracting project files..."

# Start JSON
{
    echo '{'
    printf '  "extraction_date": "%s",\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} > "${OUTPUT_FILE}"

# Extract README.md
if [ -f "${PROJECT_DIR}/README.md" ]; then
    # Get first 100 lines as preview
    readme_content=$(head -100 "${PROJECT_DIR}/README.md")
    {
        echo '  "readme": {'
        echo '    "exists": true,'
        echo '    "path": "README.md",'
        printf '    "content_preview": %s\n' "$(json_string "$readme_content")"
        echo '  },'
    } >> "${OUTPUT_FILE}"
else
    echo '  "readme": { "exists": false },' >> "${OUTPUT_FILE}"
fi

# Extract CHANGELOG.md
if [ -f "${PROJECT_DIR}/CHANGELOG.md" ]; then
    # Get first 50 lines as preview
    changelog_content=$(head -50 "${PROJECT_DIR}/CHANGELOG.md")
    {
        echo '  "changelog": {'
        echo '    "exists": true,'
        echo '    "path": "CHANGELOG.md",'
        printf '    "content_preview": %s\n' "$(json_string "$changelog_content")"
        echo '  },'
    } >> "${OUTPUT_FILE}"
else
    echo '  "changelog": { "exists": false },' >> "${OUTPUT_FILE}"
fi

# Extract CONTRIBUTING.md
if [ -f "${PROJECT_DIR}/CONTRIBUTING.md" ]; then
    {
        echo '  "contributing": {'
        echo '    "exists": true,'
        echo '    "path": "CONTRIBUTING.md"'
        echo '  }'
    } >> "${OUTPUT_FILE}"
else
    echo '  "contributing": { "exists": false }' >> "${OUTPUT_FILE}"
fi

# Close JSON
echo '}' >> "${OUTPUT_FILE}"

echo -e "${GREEN}✓ Project files extracted: ${OUTPUT_FILE}${NC}"
