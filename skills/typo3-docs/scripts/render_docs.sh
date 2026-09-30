#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Netresearch DTT GmbH
#
# Render TYPO3 documentation locally using Docker
#
# Usage: ./render_docs.sh [project_root]
#

set -e

PROJECT_ROOT="${1:-.}"

if [ ! -d "$PROJECT_ROOT/Documentation" ]; then
    echo "Error: Documentation/ directory not found at $PROJECT_ROOT"
    echo "Usage: $0 [project_root]"
    exit 1
fi

echo "🚀 Rendering TYPO3 documentation..."
echo "   Project: $PROJECT_ROOT"

docker run --rm \
    -v "$(cd "$PROJECT_ROOT" && pwd)":/project \
    ghcr.io/typo3-documentation/render-guides:latest \
    --config=Documentation

OUTPUT_DIR="$PROJECT_ROOT/Documentation-GENERATED-temp"

if [ -f "$OUTPUT_DIR/Index.html" ]; then
    echo ""
    echo "✅ Documentation rendered successfully!"
    echo "   Output: $OUTPUT_DIR/Index.html"
    echo ""
    echo "To view:"
    echo "   open $OUTPUT_DIR/Index.html"
    echo "   # or"
    echo "   xdg-open $OUTPUT_DIR/Index.html"
else
    echo ""
    echo "❌ Rendering failed or output not found"
    exit 1
fi
