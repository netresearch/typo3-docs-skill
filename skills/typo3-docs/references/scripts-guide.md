# Scripts Guide

Detailed usage for documentation extraction and analysis scripts.

## Documentation Extraction

To extract documentation data from all sources:

```bash
scripts/extract-all.sh /path/to/extension
```

To extract from specific sources:

```bash
# Extract PHP API documentation
scripts/extract-php.sh /path/to/extension

# Extract extension configuration (ext_emconf.php, ext_localconf.php)
scripts/extract-extension-config.sh /path/to/extension

# Extract Composer metadata
scripts/extract-composer.sh /path/to/extension

# Extract build configurations (CI, testing)
scripts/extract-build-configs.sh /path/to/extension

# Extract project files (README, CHANGELOG)
scripts/extract-project-files.sh /path/to/extension

# Extract repository metadata (GitHub/GitLab)
scripts/extract-repo-metadata.sh /path/to/extension
```

## Documentation Analysis

To analyze documentation coverage and identify gaps:

```bash
scripts/analyze-docs.sh /path/to/extension
```

## AI Context Setup

To add AGENTS.md template to Documentation/ folder:

```bash
scripts/add-agents-md.sh /path/to/extension
```

## Validation and Rendering

```bash
# Validate RST (indentation, alt text, heading hierarchy, editorconfig)
scripts/validate_docs.sh /path/to/extension

# Heading-hierarchy validation used by validate_docs.sh
scripts/validate_headings.py Documentation/

# Render with the official container (output: Documentation-GENERATED-temp/)
scripts/render_docs.sh /path/to/extension
```

## Checkpoint Helpers

Invoked by `checkpoints.yaml` (see the TD-* entries); runnable standalone
from the extension root:

```bash
scripts/check-adr-coverage.sh                 # TD-49: ADR dir for >10-class extensions
scripts/check-changelog-version-coverage.sh   # TD-48: CHANGELOG covers all git tags
scripts/check-guides-xml-version-sync.sh      # TD-30: guides.xml version/release == ext_emconf.php
scripts/check-required-doc-sections.sh        # TD-44: standard sections present
scripts/check-rst-substitutions-used.sh       # TD-46: Includes.rst.txt substitutions used
scripts/check-unreleased-versions.sh          # TD-41: versionadded refers to released versions
scripts/check-untranslated-fluid-strings.sh   # TD-45: hardcoded strings in Fluid templates
scripts/check-version-match.sh                # version consistency across manifests
```

The authoritative list is the `scripts/` directory itself — when this page
and the directory disagree, the directory wins.
