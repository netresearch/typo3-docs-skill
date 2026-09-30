<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Scripts Guide

Detailed usage for documentation extraction and analysis scripts.

`scripts/` is this skill's scripts directory. The extraction, analysis and
checkpoint scripts and `add-agents-md.sh` work on the current directory and
take no path argument: run them from the extension root. `validate_docs.sh`,
`render_docs.sh` and `check-guides-xml-schema.sh` take the project root as an
optional argument (default: the current directory).

## Documentation Extraction

To extract documentation data from all sources:

```bash
cd /path/to/extension
scripts/extract-all.sh            # core sources
scripts/extract-all.sh --all      # plus build configs and repository metadata
```

The results go to the extraction directory outside the project, which
`scripts/extraction-dir.sh` prints (`$DOCS_EXTRACTION_DIR` if set).

To extract from specific sources:

```bash
# Extract PHP class declarations
scripts/extract-php.sh

# Extract extension configuration (ext_emconf.php, ext_conf_template.txt)
scripts/extract-extension-config.sh

# Extract Composer metadata
scripts/extract-composer.sh

# Extract build configurations (CI, testing)
scripts/extract-build-configs.sh

# Extract project files (README, CHANGELOG)
scripts/extract-project-files.sh

# Extract repository metadata (GitHub/GitLab, through gh or glab)
scripts/extract-repo-metadata.sh
```

## Documentation Analysis

To analyze documentation coverage and identify gaps:

```bash
scripts/analyze-docs.sh    # writes ANALYSIS.md into the extraction directory
```

## AI Context Setup

To add AGENTS.md template to Documentation/ folder:

```bash
scripts/add-agents-md.sh   # asks before it overwrites an existing Documentation/AGENTS.md
```

## Validation and Rendering

```bash
# Validate: guides.xml renders, Index.rst exists, RST syntax (with docutils'
# rst2html), encoding, trailing whitespace, heading hierarchy
scripts/validate_docs.sh /path/to/extension

# Heading-hierarchy validation used by validate_docs.sh, one file at a time
scripts/validate_headings.py Documentation/Index.rst

# Render with the official container (output: Documentation-GENERATED-temp/)
scripts/render_docs.sh /path/to/extension
```

## Checkpoint Helpers

Invoked by `checkpoints.yaml` (see the TD-* entries); runnable standalone
from the extension root:

```bash
scripts/check-adr-coverage.sh                 # TD-49: ADR dir for >10-class extensions
scripts/check-changelog-version-coverage.sh   # TD-48: CHANGELOG covers all git tags
scripts/check-guides-xml-version-sync.sh      # TD-30: guides.xml release == ext_emconf.php, version == its major.minor
scripts/check-required-doc-sections.sh        # TD-44: standard sections present
scripts/check-rst-substitutions-resolve.sh    # TD-46: no |name| that only an include defines
scripts/check-untranslated-fluid-strings.sh   # TD-45: hardcoded strings in Fluid templates
scripts/check-version-match.sh                # the same check as check-guides-xml-version-sync.sh
```

The authoritative list is the `scripts/` directory itself — when this page
and the directory disagree, the directory wins.
