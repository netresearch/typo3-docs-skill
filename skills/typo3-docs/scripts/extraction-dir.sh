#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# Print the directory the extraction scripts write to, for the project in the
# current directory.
#
# DOCS_EXTRACTION_DIR wins when set. Otherwise the directory lies outside the
# project, one per project: ${TMPDIR:-/tmp}/typo3-docs-extraction/<key>, where
# <key> is the SHA-256 of the project's physical path. Every extraction script
# and analyze-docs.sh resolve their directory through this file, so they agree,
# and a reader can resolve the same directory with:
#
#   DOCS_EXTRACTION_DIR="$(path/to/scripts/extraction-dir.sh)"

set -euo pipefail

if [ -n "${DOCS_EXTRACTION_DIR:-}" ]; then
    printf '%s\n' "${DOCS_EXTRACTION_DIR}"
    exit 0
fi

project="$(pwd -P)"
if command -v sha256sum >/dev/null 2>&1; then
    key="$(printf '%s' "${project}" | sha256sum | cut -d' ' -f1)"
else
    key="$(printf '%s' "${project}" | shasum -a 256 | cut -d' ' -f1)"
fi

printf '%s\n' "${TMPDIR:-/tmp}/typo3-docs-extraction/${key}"
