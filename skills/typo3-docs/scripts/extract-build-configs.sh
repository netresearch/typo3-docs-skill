#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH

#
# Extract Build Configuration
#
# Extracts configuration from:
# - .github/workflows/*.yml (GitHub Actions)
# - .gitlab-ci.yml (GitLab CI)
# - phpunit.xml (PHPUnit config)
# - phpstan.neon (PHPStan config)
#

set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROJECT_DIR="$(pwd)"
DATA_DIR="$(bash "$(dirname "${BASH_SOURCE[0]}")/extraction-dir.sh")/data"
OUTPUT_FILE="${DATA_DIR}/build_configs.json"
# shellcheck source=SCRIPTDIR/json-string.sh
. "$(dirname "${BASH_SOURCE[0]}")/json-string.sh"

mkdir -p "${DATA_DIR}"

echo "Extracting build configurations..."

# Start JSON
{
    echo '{'
    printf '  "extraction_date": "%s",\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} > "${OUTPUT_FILE}"

# GitHub Actions
if [ -d "${PROJECT_DIR}/.github/workflows" ]; then
    workflow_files=$(find "${PROJECT_DIR}/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)
    if [ -n "$workflow_files" ]; then
        {
            echo '  "github_actions": {'
            echo '    "exists": true,'
            echo '    "files": ['
            first=true
            while IFS= read -r wf; do
                if [ "$first" = false ]; then echo '      ,'; fi
                first=false
                rel_path="${wf#"$PROJECT_DIR"/}"
                printf '      %s\n' "$(json_string "$rel_path")"
            done <<< "$workflow_files"
            echo '    ]'
            echo '  },'
        } >> "${OUTPUT_FILE}"
    else
        echo '  "github_actions": { "exists": false },' >> "${OUTPUT_FILE}"
    fi
else
    echo '  "github_actions": { "exists": false },' >> "${OUTPUT_FILE}"
fi

# GitLab CI
if [ -f "${PROJECT_DIR}/.gitlab-ci.yml" ]; then
    echo '  "gitlab_ci": { "exists": true, "file": ".gitlab-ci.yml" },' >> "${OUTPUT_FILE}"
else
    echo '  "gitlab_ci": { "exists": false },' >> "${OUTPUT_FILE}"
fi

# PHPUnit
phpunit_files=$(find "${PROJECT_DIR}" -maxdepth 2 -name "phpunit.xml*" 2>/dev/null || true)
if [ -n "$phpunit_files" ]; then
    {
        echo '  "phpunit": { "exists": true, "files": ['
        first=true
        while IFS= read -r pf; do
            if [ "$first" = false ]; then echo '      ,'; fi
            first=false
            rel_path="${pf#"$PROJECT_DIR"/}"
            printf '      %s\n' "$(json_string "$rel_path")"
        done <<< "$phpunit_files"
        echo '    ] },'
    } >> "${OUTPUT_FILE}"
else
    echo '  "phpunit": { "exists": false },' >> "${OUTPUT_FILE}"
fi

# PHPStan
if [ -f "${PROJECT_DIR}/phpstan.neon" ] || [ -f "${PROJECT_DIR}/phpstan.neon.dist" ]; then
    echo '  "phpstan": { "exists": true }' >> "${OUTPUT_FILE}"
else
    echo '  "phpstan": { "exists": false }' >> "${OUTPUT_FILE}"
fi

# Close JSON
echo '}' >> "${OUTPUT_FILE}"

echo -e "${GREEN}✓ Build configs extracted: ${OUTPUT_FILE}${NC}"
