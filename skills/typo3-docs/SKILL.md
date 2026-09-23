---
name: typo3-docs
description: "Use when TYPO3 extension documentation has to render on docs.typo3.org, which builds a manual from Documentation/guides.xml and reads no Settings.cfg (a single README.rst serves an extension too small for one): when an extension has no documentation yet, or when creating, editing or reviewing Documentation/*.rst, guides.xml, README.md or XLF translations, rendering docs with Docker, TYPO3 RST directives, screenshots, or XLIFF 2-space indentation (TYPO3 v14+)."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires php, docker (for rendering). A TYPO3 extension; Documentation/ may be absent."
metadata:
  author: Netresearch DTT GmbH
  version: "2.20.5"
  repository: https://github.com/netresearch/typo3-docs-skill
allowed-tools: Bash(php:*) Bash(docker:*) Bash(sed:*) Bash(grep:*) Read Write Glob Grep
---

# TYPO3 Documentation Skill

Create and maintain TYPO3 extension documentation per docs.typo3.org standards.

## Core Workflow

0. **No `Documentation/` yet?** Run this, do not type the file out. The
   namespace is the part that comes out wrong when it is written from memory
   -- `guides.phpdoc.org` and `guides.typo3.org` are both addresses nobody
   serves -- and a file in the wrong namespace is well-formed XML that renders
   nothing:

   ```bash
   mkdir -p Documentation && cat > Documentation/guides.xml <<'XML'
   <?xml version="1.0" encoding="UTF-8"?>
   <guides xmlns="https://www.phpdoc.org/guides" links-are-relative="true">
       <project title="TITLE" version="MAJOR.MINOR" release="MAJOR.MINOR.PATCH"/>
   </guides>
   XML
   grep -Fc 'xmlns="https://www.phpdoc.org/guides"' Documentation/guides.xml
   ```

   `Settings.cfg` is the file `guides.xml` replaced. Nothing reads it any
   more, so writing one leaves the extension with no rendered documentation
   and no error to show for it.

   The `grep` prints `1` when the namespace is right and `0` when it is not.
   Then replace TITLE and both versions. `<project>` carries them **as
   attributes**; an element whose text is the extension key has no title and
   no release. `assets/guides.xml.dist` holds the full file -- extension
   element, interlinks, build configuration -- and is the better starting
   point wherever the skill directory is reachable.
1. **Run extraction first** to find gaps:
   ```bash
   scripts/extract-all.sh /path/to/extension
   scripts/analyze-docs.sh /path/to/extension
   ```
2. Consult the matching reference
3. Use TYPO3 directives, not plain text
4. Validate: `scripts/validate_docs.sh /path/to/extension`
5. Render: `scripts/render_docs.sh /path/to/extension`

> **Critical**: For "show docs", render HTML, not raw RST.

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

- **UTF-8**, **4-space** indent (no tabs), **LF**; wrap at **80 chars** where possible
- **CamelCase** files, **sentence case** headings
- **Permalink anchors** (`.. _label:`) before every heading
- **Index.rst** in every subdirectory
- **PNG/AVIF** images with `:alt:`
- **PHP domain**: no `?Type`/`Type|null` in `php:method::`; use `:returntype:`

NR policy: **no `mailto:`** (upstream allows it; spam/PII -- use
Issues/Discussions); **.editorconfig** in `Documentation/`.

Heuristic: **~250 lines** per RST, split with `toctree`; screenshots where
they help (backend modules, config, workflows).

## Code Example Validation

Cross-reference examples against source: grep method names in
`Classes/`, compare CLI arguments with `configure()`.
See `references/extraction-patterns.md`.

## Pre-Commit Checklist

1. Code blocks have `:caption:`, inline code uses proper roles
2. Screenshots exist with `:alt:` and `:zoom: lightbox`
3. `scripts/validate_docs.sh` passes, render has no warnings
4. README and Documentation/ synchronized

## References

- `references/canonical-sources.md` -- topic-to-upstream map, provenance labels
- `references/file-structure.md` -- layout, naming
- `references/guides-xml.md` -- the guides.xml skeleton, build config, interlinks
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
- `references/render-guides-development.md` -- changing the renderer itself: directive options, interlink parsing, integration-fixture semantics
