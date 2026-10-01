#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH

#
# Extract Extension Configuration
#
# Extracts metadata and configuration from:
# - ext_emconf.php (extension metadata)
# - ext_conf_template.txt (configuration options)
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

EXT_EMCONF="${PROJECT_DIR}/ext_emconf.php"
EXT_CONF_TEMPLATE="${PROJECT_DIR}/ext_conf_template.txt"

mkdir -p "${DATA_DIR}"

# Extract ext_emconf.php
if [ -f "${EXT_EMCONF}" ]; then
    echo "Extracting ext_emconf.php..."

    OUTPUT_FILE="${DATA_DIR}/extension_meta.json"

    # Use PHP to parse ext_emconf.php properly. This runs the file's PHP.
    # The path is passed as an argument: interpolated into the PHP source, a
    # directory name with a single quote was a PHP syntax error.
    # shellcheck disable=SC2016  # the $ signs belong to PHP, not to the shell
    php -r '
    $_EXTKEY = "temp";
    include $argv[1];
    echo json_encode([
        "extraction_date" => date("c"),
        "metadata" => $EM_CONF[$_EXTKEY] ?? []
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    ' "${EXT_EMCONF}" > "${OUTPUT_FILE}"

    echo -e "${GREEN}✓ ext_emconf.php extracted: ${OUTPUT_FILE}${NC}"
else
    echo -e "${YELLOW}No ext_emconf.php found, skipping${NC}"
fi

# Extract ext_conf_template.txt
if [ -f "${EXT_CONF_TEMPLATE}" ]; then
    echo "Extracting ext_conf_template.txt..."

    OUTPUT_FILE="${DATA_DIR}/config_options.json"

    # Parse ext_conf_template.txt format:
    # # cat=category/subcategory; type=type; label=Label: Description
    # settingName = defaultValue

    {
        echo '{'
        printf '  "extraction_date": "%s",\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo '  "config_options": ['
    } > "${OUTPUT_FILE}"

    first=true

    while IFS= read -r line; do
        # Check if comment line with metadata
        if [[ $line =~ ^#\ cat= ]]; then
            # Extract metadata from comment
            category=$(echo "$line" | sed -n 's/.*cat=\([^/;]*\).*/\1/p')
            subcategory=$(echo "$line" | sed -n 's/.*cat=[^/]*\/\([^;]*\).*/\1/p')
            type=$(echo "$line" | sed -n 's/.*type=\([^;]*\).*/\1/p')
            label_and_desc=$(echo "$line" | sed -n 's/.*label=\(.*\)/\1/p')
            label=$(echo "$label_and_desc" | cut -d':' -f1)
            description=$(echo "$label_and_desc" | cut -d':' -f2- | sed 's/^ *//')

            # Check for WARNING in description
            security_warning=""
            if echo "$description" | grep -qi "WARNING:"; then
                security_warning=$(echo "$description" | sed -n 's/.*WARNING: \(.*\)/\1/p')
                description=$(echo "$description" | sed 's/WARNING:.*//' | sed 's/ *$//')
            fi

            # Read next line for setting name and default. At the end of the
            # file read returns 1, which set -e would turn into an exit in the
            # middle of the JSON. It still assigns a last line that has no
            # newline, so keep that value; after a comment on the last line it
            # is empty.
            read -r next_line || true
            if [[ $next_line =~ ^([^=]+)\ =\ (.+)$ ]]; then
                setting_name="${BASH_REMATCH[1]}"
                setting_name="${setting_name%"${setting_name##*[! ]}"}"
                default_value="${BASH_REMATCH[2]}"
                default_value=$(echo "$default_value" | sed 's/^ *//;s/ *$//')

                # Write JSON entry, with a comma before every entry but the first
                {
                    if [ "$first" = false ]; then
                        echo '    ,'
                    fi
                    echo '    {'
                    printf '      "key": %s,\n' "$(json_string "$setting_name")"
                    printf '      "category": %s,\n' "$(json_string "$category")"
                    printf '      "subcategory": %s,\n' "$(json_string "$subcategory")"
                    printf '      "type": %s,\n' "$(json_string "$type")"
                    printf '      "label": %s,\n' "$(json_string "$label")"
                    printf '      "description": %s,\n' "$(json_string "$description")"
                    printf '      "default": %s\n' "$(json_string "$default_value")"
                    if [ -n "$security_warning" ]; then
                        echo '      ,'
                        printf '      "security_warning": %s\n' "$(json_string "$security_warning")"
                    fi
                    echo -n '    }'
                } >> "${OUTPUT_FILE}"
                first=false
            fi
        fi
    done < "${EXT_CONF_TEMPLATE}"

    # Close JSON
    {
        echo
        echo '  ]'
        echo '}'
    } >> "${OUTPUT_FILE}"

    echo -e "${GREEN}✓ ext_conf_template.txt extracted: ${OUTPUT_FILE}${NC}"
else
    echo -e "${YELLOW}No ext_conf_template.txt found, skipping${NC}"
fi
