# Architecture — TYPO3 Documentation Skill

## Purpose

This skill guides AI agents through creating and maintaining TYPO3 extension documentation in reStructuredText format. It covers the full documentation lifecycle: extraction from code, gap analysis, authoring with TYPO3-specific directives, local rendering, validation, and deployment via TYPO3 Intercept webhooks.

## Skill Structure

```
skills/typo3-docs/
├── SKILL.md              # Entry point — workflow, directives, quality standards
├── references/           # 17 reference documents loaded on demand
├── scripts/              # 12 automation scripts
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

Two categories of scripts:

**Documentation authoring:**
- `validate_docs.sh` — check RST syntax, Settings.cfg, encoding
- `render_docs.sh` — render locally with the official TYPO3 Docker image
- `add-agents-md.sh` — inject AGENTS.md template into Documentation/

**Documentation extraction pipeline:**
- `extract-all.sh` — orchestrator that runs all extractors
- `extract-php.sh` — parse PHP classes, methods, docblocks
- `extract-extension-config.sh` — parse ext_emconf.php, ext_conf_template.txt
- `extract-composer.sh` — extract dependency information
- `extract-project-files.sh` — extract from README, CHANGELOG
- `extract-build-configs.sh` — CI/CD configuration (optional)
- `extract-repo-metadata.sh` — GitHub/GitLab API metadata (optional)
- `analyze-docs.sh` — compare extracted data with existing docs, find gaps

## Data Flow

1. **Extraction**: Scripts parse source code and configs into JSON files in `.claude/docs-extraction/data/`
2. **Analysis**: `analyze-docs.sh` compares extracted data with existing `Documentation/` content
3. **Generation**: Agent uses analysis report to create/update RST files
4. **Validation**: `validate_docs.sh` checks RST syntax and structure
5. **Rendering**: `render_docs.sh` produces HTML output for visual review
6. **Deployment**: Push triggers webhook to TYPO3 Intercept for docs.typo3.org publishing

## Key Design Decisions

- **Extraction-first workflow**: Extract data from code before writing docs to ensure accuracy
- **JSON intermediate format**: Extraction outputs JSON, making it easy for agents to consume
- **Lazy reference loading**: 17 reference files stay out of context until needed
- **Official Docker image**: Uses `ghcr.io/typo3-documentation/render-guides` for rendering parity with docs.typo3.org
- **Template-based AGENTS.md**: Provides documentation context for AI assistants working in target project Documentation/ folders
