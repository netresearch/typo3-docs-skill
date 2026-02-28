# Changelog

All notable changes to the typo3-docs skill are documented here.

This project follows [Semantic Versioning](https://semver.org/).

## [v2.6.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.6.0) — 2026-02-28

### Added

- **Heading hierarchy validation** — new `validate_headings.py` script checks
  RST files for TYPO3 heading convention violations:
  - First section heading not using `=` (h2)
  - Non-standard underline characters (e.g. `^`)
  - Skipped heading levels (e.g. h2 directly to h4 without h3)

### Fixed

- **`set -e` crash in `validate_docs.sh`** — `((WARNINGS++))` with `set -e`
  exits the script when the counter is 0 because bash treats `((0))` as falsy.
  Replaced all `((VAR++))` with safe `VAR=$((VAR + 1))` arithmetic.
- **Command injection in heading check** — shell variable was interpolated
  directly into `python3 -c`; extracted to separate Python script with
  `sys.argv[1]` for secure filename passing.

## [v2.5.4](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.5.4) — 2026-02-25

### Changed

- Replace generic emails with GitHub references
- Add skill validation CI job via centralized workflow

## [v2.5.3](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.5.3) — 2026-02-25

### Changed

- Add version validation pre-push hook and `.envrc`

## [v2.5.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.5.2) — 2026-02-24

### Fixed

- Align SKILL.md with writing-skills quality standard

### Changed

- Add lint CI (ShellCheck, Markdown, YAML)

## [v2.5.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.5.1) — 2026-02-24

### Changed

- Standardize release workflow via centralized CI from skill-repo-skill

## [v2.5.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.5.0) — 2026-02-23

### Changed

- Improve skill based on Claude Code insights analysis

## [v2.4.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.4.0) — 2026-02-22

### Added

- Expand troubleshooting section with common content issues

## [v2.3.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.3.0) — 2026-02-21

### Added

- Image zoom/lightbox support documentation (`:zoom: lightbox`, gallery,
  inline, lens modes)
- Enforce screenshot creation in validation

## [v2.2.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.2.1) — 2026-02-20

### Fixed

- Update checkpoint patterns for extension assessment

## [v2.2.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.2.0) — 2026-02-19

### Added

- `checkpoints.yaml` for automated extension assessment (TD-01 to TD-22)
- Mechanical verification of documentation structure
- LLM-based review for RST quality and completeness

## [v2.1.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.1.1) — 2026-02-18

### Fixed

- Remove duplicate hooks declaration (Claude Code auto-loads
  `hooks/hooks.json`)

## [v2.1.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.1.0) — 2026-02-17

### Added

- **PreToolUse hook** — validates RST syntax before writing to
  `Documentation/*.rst` files
- Detects common Markdown-to-RST conversion issues
- Quick reference for TYPO3 RST syntax in warnings

## [v2.0.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.0.2) — 2026-02-16

### Fixed

- Correct `plugin.json` version to match tag

## [v2.0.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.0.1) — 2026-02-16

### Fixed

- Update `plugin.json` version to match v2.0.0 release

## [v2.0.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.0.0) — 2026-02-15

### Breaking

- **Renamed `templates/` to `assets/`** — update any references from
  `templates/AGENTS.md` to `assets/AGENTS.md`

### Changed

- Rewritten SKILL.md with imperative/trigger-based writing style
- Complete documentation of all 15 references, 11 scripts, and 1 asset template
- Fixed non-existent `watch_docs.sh` script reference
- Updated internal path references in `add-agents-md.sh` and `README.md`

## [v1.9.3](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.9.3) — 2026-02-14

### Changed

- Reduced SKILL.md size from 12,990 to 3,505 bytes (73% reduction)

## [v1.9.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.9.2) — 2026-02-13

### Fixed

- Fix skills path format for Claude Code compatibility

## [v1.9.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.9.1) — 2026-02-12

### Changed

- Restructured skill for Claude Code compatibility (`skills/typo3-docs/`
  subdirectory)

## [v1.9.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.9.0) — 2026-02-11

### Added

- Claude Code plugin structure (`plugin.json`, `.claude-plugin/`)

## [v1.8.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.8.0) — 2026-02-10

### Changed

- Prefer `literalinclude` for complete code examples (5+ lines)
- File naming convention with underscore prefix for code snippet files
- Text markers (`:start-after:`, `:end-before:`) documentation
- Updated decision guide and pre-commit checklist

## [v1.7.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.7.0) — 2026-02-09

### Added

- Content directives guide (accordion, admonitions, cards, tabs, tables)
- Code structure elements guide (code-block, literalinclude, confval, PHP
  domain)
- Coding guidelines (.editorconfig, formatting, heading hierarchy)
- Init command workflow, live-view watch mode, screenshot guide
- Architecture Decision Records (ADR) documentation

## [v1.6.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.6.1) — 2026-02-08

### Fixed

- Concise `composer.json` description, update email to `info@netresearch.de`

## [v1.6.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.6.0) — 2026-02-07

### Added

- Warning about committing `Documentation-GENERATED-temp`
- Standardized installation, `composer.json`, release workflow

## [v1.5.3](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.5.3) — 2026-02-06

### Changed

- Prefer `guides.xml` (modern PHP-based rendering) over `Settings.cfg`
- Add webhook status codes to intercept-deployment reference
- GitHub CLI automation examples for webhook setup
- Fix `validate_docs.sh` to accept either `guides.xml` or `Settings.cfg`

## [v1.5.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.5.2) — 2026-02-05

### Fixed

- `schemaLocation` path — use `../vendor/` (relative from `Documentation/`)
- Clarified format as `namespace-URI schema-path` pair

## [v1.5.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.5.1) — 2026-02-04

### Fixed

- `guides.xml` theme syntax — `theme` must be attribute on `<guides>`, not a
  child element
- `schemaLocation` URL — docs.typo3.org schema URL returns 404, use vendor
  path instead

## [v1.5.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.5.0) — 2026-02-03

### Added

- `guides.xml` configuration reference with full template
- Extension attributes reference, common inventory URLs
- Warning about deprecated `<theme>` element

## [v1.4.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.4.0)

### Changed

- TYPO3 extension documentation skill for Claude Code

## [v1.2.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.2.0)

- Release v1.2.0

## [v1.0.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v1.0.0)

- Initial release
