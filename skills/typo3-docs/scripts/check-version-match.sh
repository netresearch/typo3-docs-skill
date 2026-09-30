#!/usr/bin/env bash
# Check that guides.xml version matches ext_emconf.php version.
#
# Kept under this name for callers that know it; the check itself is
# check-guides-xml-version-sync.sh (checkpoint TD-30). This script used to grep
# the first version="…" in guides.xml, which is the XML declaration's "1.0",
# so every guides.xml with a declaration was reported as a mismatch, and a
# missing guides.xml ended the script with a silent exit 1.
set -euo pipefail

exec bash "$(dirname "${BASH_SOURCE[0]}")/check-guides-xml-version-sync.sh"
