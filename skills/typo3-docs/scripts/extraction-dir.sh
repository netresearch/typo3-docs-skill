#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# Print the directory the extraction scripts write to, for the project in the
# current directory.
#
# DOCS_EXTRACTION_DIR wins when set. Otherwise the directory lies outside the
# project, one per project and user:
# ${TMPDIR:-/tmp}/typo3-docs-extraction-<uid>/<key>, where <key> is the
# SHA-256 of the project's physical path. The per-user directory is created
# with mode 0700 and must be a real directory owned by the current user, so
# nobody else can create, read or replace what lies inside it. Every
# extraction script and analyze-docs.sh resolve their directory through this
# file, so they agree, and a reader can resolve the same directory with:
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

parent="${TMPDIR:-/tmp}"
base="${parent}/typo3-docs-extraction-$(id -u)"
# A TMPDIR that does not exist yet is created, as before; only the per-user
# directory inside it has to be private.
mkdir -p "${parent}"
if [ ! -e "${base}" ] && [ ! -L "${base}" ]; then
    mkdir -m 0700 "${base}" 2>/dev/null || true
fi
if [ -L "${base}" ] || [ ! -d "${base}" ] || [ ! -O "${base}" ]; then
    echo "extraction-dir.sh: ${base} is not a directory owned by $(id -un); set DOCS_EXTRACTION_DIR or TMPDIR" >&2
    exit 1
fi
chmod 0700 "${base}"

printf '%s\n' "${base}/${key}"
