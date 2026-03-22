# AGENTS.md — TYPO3 Documentation Skill

## Repo Structure

```
├── skills/typo3-docs/
│   ├── SKILL.md                         # Main skill definition
│   ├── references/                      # Reference documentation (17 files)
│   │   ├── rst-syntax.md                # RST formatting guide
│   │   ├── typo3-directives.md          # TYPO3-specific directives
│   │   ├── extraction-patterns.md       # Doc extraction patterns
│   │   ├── intercept-deployment.md      # TYPO3 Intercept webhook setup
│   │   ├── rendering.md                 # Local rendering guide
│   │   └── ...                          # More references
│   ├── scripts/                         # Automation scripts (12 files)
│   │   ├── validate_docs.sh             # RST validation
│   │   ├── render_docs.sh               # Docker-based rendering
│   │   ├── extract-all.sh               # Full extraction orchestrator
│   │   ├── analyze-docs.sh              # Coverage analysis
│   │   ├── add-agents-md.sh             # Add AGENTS.md to Documentation/
│   │   └── extract-*.sh                 # Source-specific extractors
│   └── assets/                          # Templates (AGENTS.md for Documentation/)
├── scripts/
│   └── validate_rst.py                  # RST validation (Python)
├── hooks/                               # Git hooks
├── .github/workflows/                   # CI workflows
├── Build/                               # Build tooling
├── docs/                                # Architecture and plans
│   ├── ARCHITECTURE.md
│   └── exec-plans/
└── composer.json                        # Package definition
```

## Commands

No Makefile or npm scripts. Key scripts in `skills/typo3-docs/scripts/`:

- `bash skills/typo3-docs/scripts/validate_docs.sh /path/to/project` — validate RST syntax and structure
- `bash skills/typo3-docs/scripts/render_docs.sh /path/to/project` — render docs with Docker
- `bash skills/typo3-docs/scripts/extract-all.sh` — extract documentation data from code/configs
- `bash skills/typo3-docs/scripts/extract-all.sh --all` — extract including build configs and repo metadata
- `bash skills/typo3-docs/scripts/analyze-docs.sh` — analyze documentation coverage gaps
- `bash skills/typo3-docs/scripts/add-agents-md.sh` — add AGENTS.md template to Documentation/

## Rules

1. **RST format** — TYPO3 documentation uses reStructuredText, not Markdown
2. **confval directive** — use `.. confval::` for all configuration values with `:type:`, `:Default:`, `:Path:`
3. **Version directives** — use `.. versionadded::`, `.. versionchanged::`, `.. deprecated::` for version info
4. **Card grids use stretched-link** — always add `stretched-link` class to card footer buttons
5. **Docker rendering** — use official `ghcr.io/typo3-documentation/render-guides` image
6. **Webhook deployment** — docs publish via TYPO3 Intercept webhook to `docs-hook.typo3.org`
7. **First build needs approval** — initial docs.typo3.org publish requires TYPO3 Documentation Team approval
8. **Scope boundary** — this skill covers TYPO3 documentation; for core code contributions use typo3-core-contributions-skill

## References

- [SKILL.md](skills/typo3-docs/SKILL.md) — full skill definition
- [RST Syntax](skills/typo3-docs/references/rst-syntax.md)
- [TYPO3 Directives](skills/typo3-docs/references/typo3-directives.md)
- [Extraction Patterns](skills/typo3-docs/references/extraction-patterns.md)
- [Intercept Deployment](skills/typo3-docs/references/intercept-deployment.md)
- [Rendering](skills/typo3-docs/references/rendering.md)
- [Scripts Guide](skills/typo3-docs/references/scripts-guide.md)
- [Architecture](docs/ARCHITECTURE.md)
