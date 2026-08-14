# Architecture Decision Records (ADRs)

`[skill-procedure]` — ADR practice for TYPO3 extension documentation (not an
upstream TYPO3 topic; pattern derived from nr_llm).
**Purpose:** Document architectural decisions with context and consequences

## Overview

Architecture Decision Records capture important architectural decisions along with their context and consequences. They provide a historical record of why certain decisions were made, helping future maintainers understand the codebase.

## When to Write an ADR

- Major architectural changes (new patterns, frameworks, approaches)
- Technology choices (libraries, APIs, protocols)
- Significant refactoring decisions
- Security-relevant decisions
- Performance optimization strategies
- Deprecation of existing patterns

## Directory Structure

ADRs live where checkpoint TD-49 (`scripts/check-adr-coverage.sh`) looks for
them: `Documentation/Developer/Adr/` (preferred; `Documentation/Developer/ADR/`
and `docs/adr/` are also accepted). Do not place them in
`Documentation/DeveloperGuide/ArchitectureDecisions/` or `claudedocs/` — those
paths fail the skill's own coverage check.

```
Extension/
├── Documentation/
│   └── Developer/
│       └── Adr/
│           ├── Index.rst                        # Links to ADRs
│           ├── Adr001InitialArchitecture.rst
│           └── Adr013ApiKeyEncryption.rst
└── README.md
```

## ADR Format

### Standard Template

```markdown
# ADR-NNN: Title

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?

### Positive
- Benefit 1
- Benefit 2

### Negative
- Tradeoff 1
- Tradeoff 2

### Neutral
- Side effect 1
```

### Extended Template (Recommended)

```markdown
# ADR-NNN: Descriptive Title

## Status

Accepted

## Date

2024-12-30

## Context

Describe the forces at play, including technical, political, social, and
project local. These forces are probably in tension.

## Problem Statement

Clear statement of the specific problem being solved.

## Decision Drivers

- Driver 1: What factors influenced this decision?
- Driver 2: Performance requirements?
- Driver 3: Security considerations?
- Driver 4: Maintainability concerns?

## Considered Options

### Option 1: [Name]
**Description:** Brief explanation

**Pros:**
- Advantage 1
- Advantage 2

**Cons:**
- Disadvantage 1
- Disadvantage 2

### Option 2: [Name]
**Description:** Brief explanation

**Pros:**
- Advantage 1

**Cons:**
- Disadvantage 1

## Decision

We chose Option 1 because...

## Implementation Details

```php
// Code example showing the decided approach
```

## Consequences

### Positive
- What becomes easier

### Negative
- What becomes harder

### Risks
- Potential issues to watch for

## Related Decisions

- ADR-005: Related decision
- ADR-012: Prerequisite decision

## References

- [External documentation](https://example.com)
- [TYPO3 documentation](https://docs.typo3.org)
```

## Example ADRs

Full worked examples (security-decision and configuration-hierarchy ADRs
following the extended template) live in the nr_llm extension:
https://github.com/netresearch/t3x-nr-llm — `Documentation/Developer/Adr/`.
This file deliberately does not duplicate them; use the templates above.

## Best Practices

### Naming Conventions

- Format: `ADR-NNN-kebab-case-title.md`
- Numbers: Zero-padded, sequential (001, 002, 003)
- Title: Descriptive, action-oriented

### Content Guidelines

1. **Be specific** - Include code examples, not just concepts
2. **Document alternatives** - Show what wasn't chosen and why
3. **Include dates** - Decisions have context in time
4. **Link related ADRs** - Build a decision graph
5. **Update status** - Mark deprecated/superseded decisions

### RST Integration

```rst
.. toctree::
   :maxdepth: 2
   :caption: Architecture Decisions

   Adr/Adr001InitialArchitecture
   Adr/Adr012ApiKeyEncryption
   Adr/Adr013ThreeLevelConfiguration
```

### One Set of ADRs, Not Two

Keep ADRs only in `Documentation/Developer/Adr/` (rendered, checked by
TD-49). Do not maintain a parallel Markdown set under `claudedocs/` — two
copies drift, and agents read the rendered documentation source anyway.

## ADR Lifecycle

```
┌──────────┐     ┌──────────┐     ┌────────────┐
│ Proposed │ ──▶ │ Accepted │ ──▶ │ Deprecated │
└──────────┘     └──────────┘     └────────────┘
                      │                  │
                      │                  ▼
                      │           ┌────────────────┐
                      └─────────▶ │ Superseded by  │
                                  │   ADR-XXX      │
                                  └────────────────┘
```

## Tools and Automation

### Generate ADR Index

```bash
#!/bin/bash
# scripts/generate-adr-index.sh

echo "# Architecture Decision Records" > docs/adr/README.md
echo "" >> docs/adr/README.md
echo "| ADR | Title | Status |" >> docs/adr/README.md
echo "|-----|-------|--------|" >> docs/adr/README.md

for file in docs/adr/ADR-*.md; do
    number=$(basename "$file" | grep -oP 'ADR-\d+')
    title=$(head -1 "$file" | sed 's/# //')
    status=$(grep -m1 "^## Status" -A2 "$file" | tail -1)
    echo "| [$number]($file) | $title | $status |" >> docs/adr/README.md
done
```

### ADR Template Script

```bash
#!/bin/bash
# scripts/new-adr.sh

NEXT_NUM=$(ls docs/adr/ADR-*.md 2>/dev/null | wc -l)
NEXT_NUM=$((NEXT_NUM + 1))
PADDED=$(printf "%03d" $NEXT_NUM)

TITLE="${1:-untitled}"
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
FILENAME="docs/adr/ADR-${PADDED}-${SLUG}.md"

cat > "$FILENAME" << EOF
# ADR-${PADDED}: ${TITLE}

## Status

Proposed

## Date

$(date +%Y-%m-%d)

## Context

[Describe the context]

## Decision

[Describe the decision]

## Consequences

### Positive
-

### Negative
-
EOF

echo "Created: $FILENAME"
```

## Related References

- [Michael Nygard's ADR format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR Tools](https://github.com/npryce/adr-tools)
- `rst-syntax.md` - RST formatting for TYPO3 docs
- `typo3-extension-architecture.md` - Extension structure
