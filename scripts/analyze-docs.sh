#!/usr/bin/env bash

#
# Analyze Documentation Coverage
#
# Compares extracted data with existing Documentation/ to identify:
# - Missing documentation
# - Outdated documentation
# - Inconsistencies
#
# Generates: Documentation/ANALYSIS.md
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_DIR="$(pwd)"
DATA_DIR="${PROJECT_DIR}/.claude/docs-extraction/data"
DOC_DIR="${PROJECT_DIR}/Documentation"
ANALYSIS_FILE="${DOC_DIR}/ANALYSIS.md"

echo -e "${GREEN}=== Documentation Coverage Analysis ===${NC}"
echo

# Check if Documentation/ exists
if [ ! -d "${DOC_DIR}" ]; then
    echo -e "${YELLOW}No Documentation/ directory found${NC}"
    echo "Run this from a TYPO3 extension root directory"
    exit 1
fi

# Check if extraction data exists
if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${YELLOW}No extraction data found${NC}"
    echo "Run scripts/extract-all.sh first"
    exit 1
fi

echo "Project: ${PROJECT_DIR}"
echo "Documentation: ${DOC_DIR}"
echo "Extraction Data: ${DATA_DIR}"
echo

# Start analysis report
cat > "${ANALYSIS_FILE}" <<'EOF'
# Documentation Analysis Report

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Summary

This report compares extracted project data with existing documentation to identify gaps and inconsistencies.

EOF

# Replace the date placeholder
sed -i "s/\$(date -u +\"%Y-%m-%d %H:%M:%S UTC\")/$(date -u +"%Y-%m-%d %H:%M:%S UTC")/g" "${ANALYSIS_FILE}"

# Analyze PHP APIs
echo -e "${BLUE}Analyzing PHP APIs...${NC}"

if [ -f "${DATA_DIR}/php_apis.json" ]; then
    total_classes=$(jq '.classes | length' "${DATA_DIR}/php_apis.json" 2>/dev/null || echo 0)

    # Count documented classes (look for .rst files in API/ or Developer/)
    documented_classes=0
    if [ -d "${DOC_DIR}/API" ] || [ -d "${DOC_DIR}/Developer" ]; then
        documented_classes=$(find "${DOC_DIR}" -name "*.rst" -type f -exec grep -l ".. php:class::" {} \; 2>/dev/null | wc -l)
    fi

    missing_classes=$((total_classes - documented_classes))

    cat >> "${ANALYSIS_FILE}" <<EOF

### PHP Classes

- **Total Classes:** ${total_classes}
- **Documented Classes:** ${documented_classes}
- **Missing Documentation:** ${missing_classes}

EOF

    if [ $missing_classes -gt 0 ]; then
        echo "## Missing Class Documentation" >> "${ANALYSIS_FILE}"
        echo >> "${ANALYSIS_FILE}"

        # List undocumented classes
        jq -r '.classes[] | "### " + .namespace + "\\\\" + .name + "\n\n" +
               "- **File:** `" + .file + "`\n" +
               "- **Description:** " + .description + "\n" +
               "- **Suggested Location:** `Documentation/API/" + .name + ".rst`\n"' \
               "${DATA_DIR}/php_apis.json" 2>/dev/null >> "${ANALYSIS_FILE}" || true
    fi

    echo "  Classes: ${documented_classes}/${total_classes} documented"
fi

# Analyze Configuration Options
echo -e "${BLUE}Analyzing Configuration Options...${NC}"

if [ -f "${DATA_DIR}/config_options.json" ]; then
    total_options=$(jq '.config_options | length' "${DATA_DIR}/config_options.json" 2>/dev/null || echo 0)

    # Count documented confval directives
    documented_options=0
    if find "${DOC_DIR}" -name "*.rst" -type f -exec grep -q ".. confval::" {} \; 2>/dev/null; then
        documented_options=$(find "${DOC_DIR}" -name "*.rst" -type f -exec grep ".. confval::" {} \; 2>/dev/null | wc -l)
    fi

    missing_options=$((total_options - documented_options))

    cat >> "${ANALYSIS_FILE}" <<EOF

### Configuration Options

- **Total Options:** ${total_options}
- **Documented Options:** ${documented_options}
- **Missing Documentation:** ${missing_options}

EOF

    if [ $missing_options -gt 0 ]; then
        echo "## Missing Configuration Documentation" >> "${ANALYSIS_FILE}"
        echo >> "${ANALYSIS_FILE}"

        # List undocumented options
        jq -r '.config_options[] |
               "### " + .key + "\n\n" +
               "- **Type:** " + .type + "\n" +
               "- **Default:** `" + .default + "`\n" +
               "- **Description:** " + .description + "\n" +
               (if .security_warning then "- **⚠️ Security Warning:** " + .security_warning + "\n" else "" end) +
               "- **Suggested Location:** `Documentation/Integration/Configuration.rst`\n\n" +
               "**Template:**\n\n```rst\n" +
               ".. confval:: " + .key + "\n\n" +
               "   :type: " + .type + "\n" +
               "   :Default: " + .default + "\n" +
               "   :Path: $GLOBALS['"'"'TYPO3_CONF_VARS'"'"']['"'"'EXTENSIONS'"'"']['"'"'ext_key'"'"']['"'"'" + .key + "'"'"']\n\n" +
               "   " + .description + "\n" +
               (if .security_warning then "\n   .. warning::\n      " + .security_warning + "\n" else "" end) +
               "```\n"' \
               "${DATA_DIR}/config_options.json" 2>/dev/null >> "${ANALYSIS_FILE}" || true
    fi

    echo "  Options: ${documented_options}/${total_options} documented"
fi

# Check Extension Metadata
echo -e "${BLUE}Analyzing Extension Metadata...${NC}"

if [ -f "${DATA_DIR}/extension_meta.json" ]; then
    ext_version=$(jq -r '.metadata.version // "unknown"' "${DATA_DIR}/extension_meta.json" 2>/dev/null)
    ext_title=$(jq -r '.metadata.title // "unknown"' "${DATA_DIR}/extension_meta.json" 2>/dev/null)

    cat >> "${ANALYSIS_FILE}" <<EOF

### Extension Metadata

- **Title:** ${ext_title}
- **Version:** ${ext_version}
- **Location:** Check `Documentation/Index.rst` and `Documentation/Settings.cfg`

**Recommended Actions:**
- Verify version number in Settings.cfg matches ext_emconf.php
- Ensure extension title is documented in Index.rst
- Check TYPO3/PHP version constraints are in Installation requirements

EOF

    echo "  Extension: ${ext_title} v${ext_version}"
fi

# Overall Recommendations
cat >> "${ANALYSIS_FILE}" <<'EOF'

## Recommendations

### Priority 1: Core Documentation

1. **Review missing class documentation** - Essential for API reference
2. **Document all configuration options** - Required for proper extension usage
3. **Verify metadata consistency** - Ensure Settings.cfg matches ext_emconf.php

### Priority 2: Quality Improvements

1. Run validation: `scripts/validate_docs.sh`
2. Render locally: `scripts/render_docs.sh`
3. Fix any rendering warnings or broken cross-references

### Priority 3: Enhancement

1. Add usage examples for all configuration options
2. Add code examples for all API methods
3. Consider adding screenshots for user-facing features

## Next Steps

1. **Generate templates:** `scripts/generate-templates.sh` (if implemented)
2. **Manual documentation:** Review ANALYSIS.md and create missing RST files
3. **Validate:** `scripts/validate_docs.sh`
4. **Render:** `scripts/render_docs.sh`
5. **Commit:** Add new documentation to version control

---

**Analysis Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Extraction Data:** See `.claude/docs-extraction/data/`

EOF

# Replace date placeholder again
sed -i "s/\$(date -u +\"%Y-%m-%d %H:%M:%S UTC\")/$(date -u +"%Y-%m-%d %H:%M:%S UTC")/g" "${ANALYSIS_FILE}"

echo
echo -e "${GREEN}=== Analysis Complete ===${NC}"
echo
echo "Report generated: ${ANALYSIS_FILE}"
echo
echo -e "${YELLOW}Review the analysis report for documentation gaps and recommendations.${NC}"
echo
