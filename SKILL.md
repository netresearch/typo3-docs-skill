---
name: typo3-docs
description: "Create and maintain TYPO3 extension documentation following official TYPO3 13.x standards. Use when creating/editing Documentation/*.rst files or README.md, using TYPO3 directives (confval, versionadded, card-grid), rendering docs locally, or deploying to docs.typo3.org. By Netresearch."
---

# TYPO3 Documentation

## When to Use

- Creating new `Documentation/` directory structure
- Editing `Documentation/**/*.rst` files
- Creating `Documentation/guides.xml` or updating `Settings.cfg`
- Using TYPO3 directives: `confval`, `versionadded`, `card-grid`, `php:class`
- Using text roles: `:php:`, `:file:`, `:guilabel:`, `:ref:`
- Running: `scripts/validate_docs.sh`, `scripts/render_docs.sh`
- Deploying to docs.typo3.org

## Core Workflow

1. Read reference files for the task at hand (see table below)
2. Use TYPO3 directives, not plain text equivalents
3. Validate: `scripts/validate_docs.sh`
4. Render: `scripts/render_docs.sh`
5. **Verify rendered output visually** (open in browser)
6. Keep README.md and Documentation/ synchronized
7. Commit together atomically

> **Critical**: When user asks to "show docs", render and display the HTML output, not raw RST.

## Quick Reference Table

| Task | Reference File |
|------|----------------|
| File structure and naming conventions | `references/file-structure.md` |
| Text roles (`:php:`, `:file:`, `:guilabel:`) | `references/text-roles-inline-code.md` |
| RST syntax (headings, lists, code blocks) | `references/rst-syntax.md` |
| TYPO3 directives (confval, card-grid, PlantUML) | `references/typo3-directives.md` |
| Documentation extraction and analysis | `references/extraction-patterns.md` |
| Coverage methodology | `references/documentation-coverage-analysis.md` |
| Webhook setup and deployment | `references/intercept-deployment.md` |
| Extension architecture context | `references/typo3-extension-architecture.md` |
| Architecture Decision Records (ADRs) | `references/architecture-decision-records.md` |

## Critical Rules (Always Apply)

- **UTF-8** encoding, **4-space** indentation, no tabs
- **Sentence case** headings (not Title Case)
- **CamelCase** file/directory names
- **Index.rst** required in every subdirectory
- **American English** spelling (color, behavior, optimize)
- **PNG format** for screenshots, always include `:alt:` text

## Text Roles (Must Use)

| Content | Role |
|---------|------|
| PHP code | `:php:\`ClassName\`` |
| Files | `:file:\`ext_localconf.php\`` |
| Directories | `:path:\`Configuration/\`` |
| UI elements | `:guilabel:\`Save\`` |
| TypoScript | `:typoscript:\`lib.parseFunc\`` |

See `references/text-roles-inline-code.md` for complete list.

## Required File Structure

Full documentation requires this structure (per [TYPO3 File Structure](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/FileStructure.html)):

```
project-root/
├── composer.json         # Required for rendering
├── README.md             # Project overview (synced with Documentation/)
└── Documentation/
    ├── guides.xml        # Metadata and rendering config (required)
    ├── Index.rst         # Entry point with toctree (required)
    ├── Sitemap.rst       # Auto-populated site structure (optional)
    ├── Includes.rst.txt  # Global includes for all pages (optional)
    └── SectionName/      # CamelCase directories
        └── Index.rst     # Required in every subdirectory
```

**Naming Conventions:**
- **CamelCase** for directories and files: `Configuration/Index.rst`, `Developer/TcaIntegration.rst`
- **Index.rst** required in every directory (fallback during version switching)
- Included RST files use `.rst.txt` extension: `Includes.rst.txt`
- Code snippet files start with underscore: `_Services.yaml`, `_Example.php`

**Minimum Prerequisites:**
- Valid `composer.json` in project root
- Entry point: `Documentation/Index.rst` (or `README.md` for single-file docs)

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/validate_docs.sh` | Validate RST syntax |
| `scripts/render_docs.sh` | Render locally with Docker |
| `scripts/extract-all.sh` | Extract documentation data |
| `scripts/analyze-docs.sh` | Generate coverage analysis |

## Pre-Commit Checklist

1. **File structure**: Every directory has `Index.rst`, CamelCase naming
2. `scripts/validate_docs.sh` passes
3. `scripts/render_docs.sh` shows no warnings
4. **Visual verification**: Open rendered HTML and confirm formatting
5. README.md and Documentation/ are in sync (no contradictions)
6. `Documentation-GENERATED-temp/` is in `.gitignore`

## README.md Synchronization

"In sync" means **content parity** and **consistency**, not duplication:

- **Parity**: Topics in README.md should be covered in Documentation/.
- **Consistency**: Shared topics must not contradict (CLI commands, code examples, configs).
- **Source of truth**: Documentation/ is authoritative; update README.md to match.

See `references/rst-syntax.md` for detailed examples.

For detailed guidelines, read the appropriate reference file before starting work.

---

> **Contributing:** Improvements to this skill should be submitted to the source repository:
> https://github.com/netresearch/typo3-docs-skill
