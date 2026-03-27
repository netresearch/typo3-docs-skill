---
name: typo3-docs
description: "Use when creating, editing, or reviewing TYPO3 extension documentation (Documentation/*.rst, guides.xml, README.md), rendering docs with Docker, using TYPO3 RST directives, adding screenshots, deploying to docs.typo3.org, setting up TYPO3 docs webhook, publishing TYPO3 documentation via Intercept, improve docs, add screenshots, fix documentation, or docs accuracy."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires php, docker (for rendering). TYPO3 extension with Documentation/ directory."
metadata:
  author: Netresearch DTT GmbH
  version: "2.9.1"
  repository: https://github.com/netresearch/typo3-docs-skill
allowed-tools: Bash(php:*) Bash(docker:*) Bash(sed:*) Bash(grep:*) Read Write Glob Grep
---

# TYPO3 Documentation Skill

Create and maintain TYPO3 extension documentation following official docs.typo3.org standards.

## Core Workflow

1. **Run extraction first** to identify documentation gaps:
   ```bash
   scripts/extract-all.sh /path/to/extension
   scripts/analyze-docs.sh /path/to/extension
   ```
2. Consult the appropriate reference file for the task
3. Use TYPO3-specific directives, not plain text
4. Validate: `scripts/validate_docs.sh /path/to/extension`
5. Render: `scripts/render_docs.sh /path/to/extension`
6. Verify rendered output and README/Documentation sync

> **Critical**: When the user asks to "show docs", render and display HTML output, not raw RST.

## Element Selection Guide

| Content Type | Directive |
|--------------|-----------|
| Code (5+ lines) | `literalinclude` |
| Short snippets | `code-block` with `:caption:` |
| Config options | `confval` with `:type:`, `:default:` |
| PHP API | `php:class::`, `php:method::` |
| Notices | `note`, `tip`, `warning`, `important` |
| Feature grids | `card-grid` |
| Alternatives | `tabs` (synchronized) |
| Collapsible | `accordion` |
| Screenshots | `figure` with `:zoom: lightbox` `:class: with-border with-shadow` |

## Critical Rules

- **UTF-8**, **4-space** indent, **80 char** line length, **LF** endings
- **CamelCase** file/directory names, **sentence case** headings
- **Index.rst** required in every subdirectory
- **PNG** screenshots with `:alt:` and `:zoom: lightbox`
- **.editorconfig** required in `Documentation/`
- **Screenshots MANDATORY** for backend modules, config screens, UI workflows (see `references/asset-templates-guide.md`)
- **Max 250 lines per RST page** -- split into sub-pages with `toctree` if exceeded
- **No `mailto:` links** -- use GitHub Issues/Discussions URLs instead

## Code Example Validation

After generating or reviewing documentation, cross-reference all code examples against the actual extension source code:

1. **PHP code examples**: Grep every method name from documentation in `Classes/` to verify existence. If a method name appears in docs but not in source, the example is wrong.
2. **CLI command arguments**: Compare documented arguments and options against the `configure()` method in each Command class under `Classes/Command/`.
3. **API method signatures**: Verify that documented parameter types, return types, and method names match the actual class methods in `Classes/`.
4. **Model accessors in migrations**: Confirm getter/setter names used in migration examples match the domain model classes.
5. **Version numbers**: Ensure versions in `guides.xml`, code examples, and `versionadded`/`versionchanged` directives match `ext_emconf.php`.

See `references/extraction-patterns.md` (Code Example Accuracy Validation) for detailed patterns and validation commands.

## Pre-Commit Checklist

1. `.editorconfig` in `Documentation/`, `Index.rst` in every directory
2. 4-space indentation, no tabs, max 80 chars
3. Code blocks have `:caption:`, inline code uses proper roles (`:php:`, `:file:`)
4. Screenshots exist with `:alt:` and `:zoom: lightbox`
5. `scripts/validate_docs.sh` passes, render output has no warnings
6. README and Documentation/ are synchronized
7. No RST page exceeds 250 lines
8. `guides.xml` has all required theme attributes (see `references/guides-xml.md`)
9. No `mailto:` links anywhere

## References

- `references/file-structure.md` -- directory layout, naming conventions
- `references/guides-xml.md` -- build configuration, interlink settings
- `references/coding-guidelines.md` -- .editorconfig, indentation rules
- `references/rst-syntax.md` -- headings, lists, tables, formatting
- `references/text-roles-inline-code.md` -- `:php:`, `:file:`, `:guilabel:`, `:ref:`
- `references/code-structure-elements.md` -- code blocks, confval, PHP domain
- `references/typo3-directives.md` -- confval, versionadded, deprecated
- `references/content-directives.md` -- accordion, tabs, card-grid
- `references/screenshots.md` -- image requirements, figure directives
- `references/rendering.md` -- Docker commands, live preview
- `references/intercept-deployment.md` -- webhook, build triggers
- `references/asset-templates-guide.md` -- templates, screenshot workflow
- `references/scripts-guide.md` -- extraction and analysis scripts

## External Resources

- [TYPO3 Documentation Writing Guide](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/)
- [TYPO3 Documentation Rendering](https://github.com/typo3-documentation/render-guides)
- [TYPO3 Directive Reference](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/WritingReST/Reference/)

---

> **Contributing:** https://github.com/netresearch/typo3-docs-skill
