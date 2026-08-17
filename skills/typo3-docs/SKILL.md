---
name: typo3-docs
description: "Use when creating, editing, or reviewing TYPO3 extension documentation (Documentation/*.rst, guides.xml, README.md, XLF translations), rendering docs with Docker, using TYPO3 RST directives, adding screenshots, deploying to docs.typo3.org, improve docs, fix documentation, or XLIFF 2-space indentation (TYPO3 v14+)."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires php, docker (for rendering). TYPO3 extension with Documentation/ directory."
metadata:
  author: Netresearch DTT GmbH
  version: "2.17.0"
  repository: https://github.com/netresearch/typo3-docs-skill
allowed-tools: Bash(php:*) Bash(docker:*) Bash(sed:*) Bash(grep:*) Read Write Glob Grep
---

# TYPO3 Documentation Skill

Create and maintain TYPO3 extension documentation per docs.typo3.org standards.

## Core Workflow

1. **Run extraction first** to find gaps:
   ```bash
   scripts/extract-all.sh /path/to/extension
   scripts/analyze-docs.sh /path/to/extension
   ```
2. Consult the matching reference
3. Use TYPO3 directives, not plain text
4. Validate: `scripts/validate_docs.sh /path/to/extension`
5. Render: `scripts/render_docs.sh /path/to/extension`

> **Critical**: For "show docs", render and display HTML, not raw RST.

## Element Selection Guide

| Content Type | Directive |
|--------------|-----------|
| Complete code | `literalinclude` (preferred) |
| Short snippets | `code-block` with `:caption:` |
| Config options | `confval` with `:type:`, `:default:` |
| PHP API | `php:method::` -- `:returntype:` for nullable/union |
| Notices | `note`, `tip`, `warning`, `important` |
| Feature grids | `card-grid` with footer `stretched-link` |
| Alternatives | `tabs` (synchronized) |
| Screenshots | `figure` with `:zoom: lightbox` + border/shadow classes |

## Critical Rules

Official docs are canonical; on conflict the live manual wins -- report
drift (`references/canonical-sources.md`).

Upstream:

- **UTF-8**, **4-space** indent, **LF**; wrap at **80 chars** where possible
- **CamelCase** files, **sentence case** headings
- **Permalink anchors** (`.. _label:`) before every heading
- **Index.rst** in every subdirectory
- **PNG/AVIF** images with `:alt:`; check screenshot necessity first
- **PHP domain**: no `?Type`/`Type|null` in `php:method::`; use `:returntype:`

NR policy: **no `mailto:`** (upstream allows it; spam/PII -- use
Issues/Discussions); **.editorconfig** in `Documentation/`.

Heuristic: **~250 lines** per RST, split with `toctree`; `:zoom: lightbox` on
figures; screenshots where they help (backend modules, config, workflows).

## Code Example Validation

Cross-reference code examples against source: grep method names in
`Classes/`, compare CLI arguments with `configure()`.
See `references/extraction-patterns.md`.

## Pre-Commit Checklist

1. `.editorconfig` present, `Index.rst` in every directory
2. 4-space indent, no tabs, max 80 chars
3. Code blocks have `:caption:`, inline code uses proper roles
4. Screenshots exist with `:alt:` and `:zoom: lightbox`
5. `scripts/validate_docs.sh` passes, render has no warnings
6. README and Documentation/ synchronized

## References

- `references/canonical-sources.md` -- topic-to-upstream map, provenance labels
- `references/file-structure.md` -- layout, naming
- `references/guides-xml.md` -- build config, interlinks
- `references/coding-guidelines.md` -- CGL deltas, .editorconfig
- `references/rst-syntax.md` -- headings, punctuation pitfalls
- `references/text-roles-inline-code.md` -- `:php:`, `:guilabel:`, `:ref:`
- `references/code-structure-elements.md` -- code blocks, confval, PHP domain
- `references/typo3-directives.md` -- confval, versionadded, deprecated
- `references/content-directives.md` -- accordion, tabs, card-grid
- `references/screenshots.md` -- figures, image rules, SVG diagrams
- `references/rendering.md` -- Docker commands, live preview
- `references/intercept-deployment.md` -- webhook, build triggers
- `references/asset-templates-guide.md` -- templates, screenshot workflow
- `references/architecture-decision-records.md` -- ADR patterns
- `references/documentation-coverage-analysis.md` -- coverage scoring
- `references/scripts-guide.md` -- script options
- `references/typo3-extension-architecture.md` -- extension layout
- `references/upstream-docs-contribution.md` -- upstream docs PRs
