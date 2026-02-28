#!/usr/bin/env bash
#
# Validate TYPO3 documentation RST files
#
# Usage: ./validate_docs.sh [project_root]
#

set -e

PROJECT_ROOT="${1:-.}"
DOC_DIR="$PROJECT_ROOT/Documentation"

if [ ! -d "$DOC_DIR" ]; then
    echo "Error: Documentation/ directory not found at $PROJECT_ROOT"
    echo "Usage: $0 [project_root]"
    exit 1
fi

echo "🔍 Validating TYPO3 documentation..."
echo "   Directory: $DOC_DIR"
echo ""

# Check for RST files
RST_FILES=$(find "$DOC_DIR" -name "*.rst" 2>/dev/null | wc -l)
if [ "$RST_FILES" -eq 0 ]; then
    echo "❌ No RST files found in Documentation/"
    exit 1
fi

echo "Found $RST_FILES RST files"
echo ""

# Check for guides.xml (modern) or Settings.cfg (legacy)
if [ -f "$DOC_DIR/guides.xml" ]; then
    echo "✅ guides.xml found (modern PHP-based rendering)"
elif [ -f "$DOC_DIR/Settings.cfg" ]; then
    echo "✅ Settings.cfg found (legacy Sphinx-based rendering)"
    echo "   ℹ️  Consider migrating to guides.xml for modern rendering"
else
    echo "⚠️  Warning: Neither guides.xml nor Settings.cfg found"
    echo "   One of these files is required for TYPO3 Intercept builds"
    echo "   Recommended: Create guides.xml (modern PHP-based rendering)"
fi

# Check for Index.rst
if [ ! -f "$DOC_DIR/Index.rst" ]; then
    echo "❌ Error: Index.rst not found"
    echo "   This is the main entry point and is required"
    exit 1
fi

echo "✅ Index.rst found"

# Validate RST syntax if rst2html.py is available
if command -v rst2html.py &> /dev/null; then
    echo ""
    echo "Checking RST syntax..."

    ERRORS=0
    while IFS= read -r -d '' file; do
        if ! rst2html.py --strict "$file" > /dev/null 2>&1; then
            echo "❌ Syntax error in: $file"
            ERRORS=$((ERRORS + 1))
        fi
    done < <(find "$DOC_DIR" -name "*.rst" -print0)

    if [ $ERRORS -eq 0 ]; then
        echo "✅ All RST files have valid syntax"
    else
        echo ""
        echo "❌ Found $ERRORS files with syntax errors"
        exit 1
    fi
else
    echo "⚠️  rst2html.py not found - skipping syntax validation"
    echo "   Install with: pip install docutils"
fi

# Check for common issues
echo ""
echo "Checking for common issues..."

# Check for broken internal references (basic check)
WARNINGS=0

# Check for :ref: without proper labels
while IFS= read -r -d '' file; do
    if grep -q ':ref:`[^<]*`' "$file"; then
        REF_COUNT=$(grep -o ':ref:`[^`]*`' "$file" | wc -l)
        if [ "$REF_COUNT" -gt 0 ]; then
            echo "ℹ️  Found $REF_COUNT :ref: references in $(basename "$file")"
        fi
    fi
done < <(find "$DOC_DIR" -name "*.rst" -print0)

# Check for UTF-8 encoding
while IFS= read -r -d '' file; do
    if ! file -b --mime-encoding "$file" | grep -q utf-8; then
        echo "⚠️  Non-UTF-8 encoding in: $file"
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$DOC_DIR" -name "*.rst" -print0)

# Check for trailing whitespace
while IFS= read -r -d '' file; do
    if grep -q '[[:space:]]$' "$file"; then
        echo "⚠️  Trailing whitespace in: $file"
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$DOC_DIR" -name "*.rst" -print0)

# Check TYPO3 heading hierarchy (= for h1/h2, - for h3, ~ for h4)
echo ""
echo "Checking heading hierarchy..."
HEADING_ERRORS=0
while IFS= read -r -d '' file; do
    RESULT=$(python3 -c "
import sys

# TYPO3 heading convention:
# h1: = above AND below (overline)
# h2: = below only
# h3: - below only
# h4: ~ below only
# h5: \" below only
# h6: ' below only
EXPECTED_ORDER = ['=', '-', '~', '\"', \"'\"]

with open('$file') as f:
    lines = f.readlines()

headings = []
i = 0
while i < len(lines):
    line = lines[i].rstrip()
    if line and len(line) >= 3 and all(c == line[0] for c in line) and line[0] in '=-~\"^#\\'':
        char = line[0]
        # Check if this is an overline (title) or underline
        if i + 2 < len(lines):
            next_line = lines[i+1].rstrip()
            next_next = lines[i+2].rstrip()
            if (next_line and not all(c == next_line[0] for c in next_line)
                and next_next and all(c == next_next[0] for c in next_next)
                and next_next[0] == char):
                # Overline+underline = title (h1), skip both
                headings.append(('h1', char, next_line, i+1))
                i += 3
                continue
        # Underline only - check previous line for title text
        if i > 0:
            prev = lines[i-1].rstrip()
            if prev and not all(c == prev[0] for c in prev):
                headings.append(('section', char, prev, i))
    i += 1

if not headings:
    sys.exit(0)

# Check that section headings follow TYPO3 convention
errors = []
sections = [h for h in headings if h[0] == 'section']

# Check 1: First section heading must use = (h2)
if sections and sections[0][1] != '=':
    char = sections[0][1]
    title = sections[0][2]
    lineno = sections[0][3]
    errors.append(f'  L{lineno+1}: \"{title}\" - first section heading must use \"=\" (h2), not \"{char}\"')

# Check 2: Detect nesting violations (e.g. h4 directly under h2, skipping h3)
# Track the current heading depth stack
depth_stack = []  # stack of EXPECTED_ORDER indices
for kind, char, title, lineno in headings:
    if kind == 'h1':
        depth_stack = []
        continue
    if char not in EXPECTED_ORDER:
        errors.append(f'  L{lineno+1}: \"{title}\" uses non-standard underline char \"{char}\"')
        continue
    char_idx = EXPECTED_ORDER.index(char)
    # Pop stack back to find where this heading fits
    while depth_stack and depth_stack[-1] >= char_idx:
        depth_stack.pop()
    # Check for skipped levels (e.g. jumping from = to ~ without -)
    if depth_stack:
        parent_idx = depth_stack[-1]
        if char_idx > parent_idx + 1:
            skipped = EXPECTED_ORDER[parent_idx + 1]
            errors.append(f'  L{lineno+1}: \"{title}\" uses \"{char}\" (h{char_idx+2}) directly under \"{EXPECTED_ORDER[parent_idx]}\" (h{parent_idx+2}), skipping \"{skipped}\" (h{parent_idx+3})')
    depth_stack.append(char_idx)

for e in errors:
    print(e)
" 2>/dev/null)
    if [ -n "$RESULT" ]; then
        echo "❌ Heading hierarchy issue in: $(basename "$file")"
        echo "$RESULT"
        HEADING_ERRORS=$((HEADING_ERRORS + 1))
    fi
done < <(find "$DOC_DIR" -name "*.rst" -print0)

if [ $HEADING_ERRORS -eq 0 ]; then
    echo "✅ Heading hierarchy follows TYPO3 convention"
else
    echo ""
    echo "❌ Found $HEADING_ERRORS files with heading hierarchy issues"
    echo "   TYPO3 heading order: = (h1 title, above+below), = (h2), - (h3), ~ (h4)"
    WARNINGS=$((WARNINGS + HEADING_ERRORS))
fi

echo ""
if [ $WARNINGS -eq 0 ]; then
    echo "✅ No common issues found"
else
    echo "⚠️  Found $WARNINGS warnings (not blocking)"
fi

echo ""
echo "Validation summary:"
echo "  RST files: $RST_FILES"
echo "  Warnings: $WARNINGS"
echo ""
echo "✅ Documentation validation complete"
echo ""
echo "Next step: Render locally to check for broken references"
echo "   ./render_docs.sh $PROJECT_ROOT"
