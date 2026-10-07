<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Architecture — TYPO3 Documentation Skill

## Purpose

This skill guides AI agents through creating and maintaining TYPO3 extension documentation in reStructuredText format. It covers the full documentation lifecycle: extraction from code, gap analysis, authoring with TYPO3-specific directives, local rendering, validation, and deployment via TYPO3 Intercept webhooks.

## Skill Structure

```
skills/typo3-docs/
├── SKILL.md              # Entry point — workflow, directives, quality standards
├── references/           # Reference documents loaded on demand
├── scripts/              # Automation and checkpoint scripts
└── assets/               # Templates (AGENTS.md for target Documentation/ dirs)
```

### SKILL.md

The main skill file. Contains the documentation workflow, RST directive usage, quality checklists, and decision trees for when to use specific TYPO3 directives (confval, versionadded, card-grid, etc.).

### References (references/)

Deep-dive documents organized by topic:
- **rst-syntax.md** — complete RST formatting reference
- **typo3-directives.md** — TYPO3-specific Sphinx directives
- **extraction-patterns.md** — patterns for extracting docs from code
- **intercept-deployment.md** — webhook setup for docs.typo3.org publishing
- **rendering.md** — Docker-based local rendering
- **file-structure.md** — expected Documentation/ directory layout
- **coding-guidelines.md**, **screenshots.md**, **guides-xml.md** — specialized references

### Scripts (scripts/)

Three categories of scripts, plus two helpers:

**Documentation authoring:**
- `validate_docs.sh` — check that guides.xml renders, Index.rst exists, RST syntax, encoding, heading hierarchy
- `render_docs.sh` — render locally with the official TYPO3 Docker image
- `add-agents-md.sh` — inject AGENTS.md template into Documentation/

**Documentation extraction pipeline:**
- `extract-all.sh` — orchestrator that runs all extractors
- `extract-php.sh` — parse PHP class declarations and their docblocks
- `extract-extension-config.sh` — parse ext_emconf.php, ext_conf_template.txt
- `extract-composer.sh` — extract dependency information
- `extract-project-files.sh` — extract from README, CHANGELOG
- `extract-build-configs.sh` — CI/CD configuration (optional)
- `extract-repo-metadata.sh` — GitHub/GitLab API metadata (optional)
- `analyze-docs.sh` — compare extracted data with existing docs, find gaps

**Checkpoint helpers:** `check-*.sh`, the stand-alone versions of the TD-* checks in `checkpoints.yaml` (listed in `references/scripts-guide.md`). They read the extension in the current directory and exit 1 on a finding.

**Helpers:** `extraction-dir.sh` prints the extraction directory every extraction script and `analyze-docs.sh` use; `json-string.sh` is sourced by the extractors to write project values as escaped JSON strings.

### Plugin hook (hooks/)

`hooks/hooks.json` registers `scripts/validate_rst.py` as a Claude Code `PreToolUse` hook for `Write` and `Edit`. It reads the tool call from standard input and, for `.rst` files under `Documentation/`, hands the agent a reminder as the documented `hookSpecificOutput.additionalContext` JSON field when the new content matches one of its patterns: Markdown headings, code fences and links, a line that is only bold text, or a list item. It always exits 0.

### Tests (tests/)

Behavioural tests for every script, run offline by `.github/workflows/tests.yml`; see README "Tests".

## Actors

- **User and agent**: run the scripts in the extension being documented; the agent follows `SKILL.md`.
- **Extension under documentation**: input to every script. The extraction and UI-surface checks run its `ext_emconf.php` and `Configuration/Backend/Modules.php` through PHP.
- **render-guides container**: renders `Documentation/` into `Documentation-GENERATED-temp/`.
- **GitHub/GitLab API**: source of `extract-repo-metadata.sh`, through the user's `gh`/`glab` login.
- **TYPO3 Intercept**: builds docs.typo3.org from the webhook the user configures (`references/intercept-deployment.md`).

Security properties and limits: [SECURITY-ASSURANCE.md](SECURITY-ASSURANCE.md).

## Data Flow

1. **Extraction**: Scripts parse source code and configs into JSON files in `data/` of the extraction directory, which lies outside the project (`extraction-dir.sh`: `$DOCS_EXTRACTION_DIR`, else `${TMPDIR:-/tmp}/typo3-docs-extraction-<uid>/<sha256 of the project path>`, in a per-user directory with mode 0700)
2. **Analysis**: `analyze-docs.sh` compares extracted data with existing `Documentation/` content and writes `ANALYSIS.md` into the extraction directory
3. **Generation**: Agent uses analysis report to create/update RST files
4. **Validation**: `validate_docs.sh` checks RST syntax and structure
5. **Rendering**: `render_docs.sh` produces HTML output for visual review
6. **Deployment**: Push triggers webhook to TYPO3 Intercept for docs.typo3.org publishing

## Key Design Decisions

- **Extraction-first workflow**: Extract data from code before writing docs to ensure accuracy
- **JSON intermediate format**: Extraction outputs JSON, making it easy for agents to consume
- **Lazy reference loading**: reference files stay out of context until needed
- **Official Docker image**: Uses `ghcr.io/typo3-documentation/render-guides` for rendering parity with docs.typo3.org
- **Template-based AGENTS.md**: Provides documentation context for AI assistants working in target project Documentation/ folders
