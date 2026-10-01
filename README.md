<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# TYPO3 Documentation Skill

A comprehensive Claude Code skill for creating and maintaining TYPO3 extension documentation following official TYPO3 documentation standards.

## 🔌 Compatibility

This is an **Agent Skill** following the [open standard](https://agentskills.io) originally developed by Anthropic and released for cross-platform use.

**Supported Platforms:**
- ✅ Claude Code (Anthropic)
- ✅ Cursor
- ✅ GitHub Copilot
- ✅ Other skills-compatible AI agents

> Skills are portable packages of procedural knowledge that work across any AI agent supporting the Agent Skills specification.


## Overview

This skill provides guidance for working with TYPO3 extension documentation in reStructuredText (RST) format, including TYPO3-specific directives, local rendering with Docker, validation procedures, and automated deployment through TYPO3 Intercept.

## Features

- **Documentation Extraction** - Automated extraction from code, configs, and repository metadata
- **Gap Analysis** - Identify missing and outdated documentation
- **RST Syntax Reference** - Complete reStructuredText formatting guide
- **TYPO3-Specific Directives** - confval, versionadded, php:method, card-grid
- **Local Rendering** - Docker-based documentation rendering scripts
- **Validation Tools** - RST syntax and quality check scripts
- **Quality Standards** - Pre-commit checklists and best practices
- **TYPO3 Intercept** - Automated deployment guidance
- **AI Assistant Context** - AGENTS.md templates for Documentation/ folders

## Installation

### Marketplace (Recommended)

Add the [Netresearch marketplace](https://github.com/netresearch/claude-code-marketplace) once, then browse and install skills:

```bash
# Claude Code
/plugin marketplace add netresearch/claude-code-marketplace
/plugin install typo3-docs@netresearch-claude-code-marketplace
```

### Without a marketplace

Since Claude Code 2.1.157 a plugin directory under your personal skills directory loads on its own, including the hooks this repo ships:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/netresearch/typo3-docs-skill.git \
  ~/.claude/skills/typo3-docs
```

It loads as `typo3-docs@skills-dir` on the next session. Update with `git -C ~/.claude/skills/typo3-docs pull` and start a new session; remove it by deleting the directory. This route has no `claude plugin update`.

### npx ([skills.sh](https://skills.sh))

Install with any [Agent Skills](https://agentskills.io)-compatible agent:

```bash
npx skills add https://github.com/netresearch/typo3-docs-skill --skill typo3-docs
```

> **Limitation:** `npx skills` installs `SKILL.md`-based skills only. This repo also ships `hooks`, which it does not install — use the marketplace or the skills directory for those.

### Download Release

Download the [latest release](https://github.com/netresearch/typo3-docs-skill/releases/latest) and extract to your agent's skills directory.

### Git Clone

```bash
git clone https://github.com/netresearch/typo3-docs-skill.git
```

### Composer (PHP Projects)

```bash
composer require netresearch/typo3-docs-skill
```

Requires [netresearch/composer-agent-skill-plugin](https://github.com/netresearch/composer-agent-skill-plugin).
## Contents

### SKILL.md

Main skill file with comprehensive instructions for:
- Documentation structure and workflow
- Configuration documentation with confval
- Version documentation with versionadded/versionchanged
- PHP API documentation with php:method
- Card grid navigation with stretched links
- Cross-references and quality standards

### references/

**rst-syntax.md** - TYPO3-specific RST conventions:
- Heading hierarchy, list punctuation
- README/Documentation sync
- Documentation-review error patterns

**typo3-directives.md** - TYPO3-specific directives:
- confval for configuration values
- Version directives (added/changed/deprecated)
- PHP domain (class/method/property)
- Card grids with stretched links
- Intersphinx references
- Quality checklists

**extraction-patterns.md** - Documentation extraction guide:
- Multi-source extraction patterns (PHP, configs, repository)
- Data-to-RST mapping strategies
- Gap analysis workflow
- Template generation approaches
- Quality standards for extraction

**typo3-extension-architecture.md** - TYPO3 official file structure reference:
- File structure hierarchy with priority weights
- Directory structure weights (Classes/, Configuration/, Resources/)
- Extraction weight matrix (Priority 1-5)
- Quality weighting algorithm
- Gap analysis priority calculation
- Documentation mapping strategies

### assets/

**AGENTS.md** - AI assistant context template:
- Documentation strategy and audience
- TYPO3 RST syntax patterns
- Directive usage examples
- Cross-reference patterns
- Validation and rendering procedures

### scripts/

**add-agents-md.sh** - Add AI context to Documentation/:
- Creates AGENTS.md from template
- Provides documentation context for AI assistants
- Helps AI understand project documentation structure

**validate_docs.sh** - Validation script:
- Checks RST syntax
- Checks that guides.xml will render (a legacy Settings.cfg is only reported) and that Index.rst exists
- Detects encoding issues
- Identifies trailing whitespace

**render_docs.sh** - Rendering script:
- Renders documentation locally with Docker
- Uses official TYPO3 render-guides image
- Outputs to Documentation-GENERATED-temp/

**extract-all.sh** - Documentation extraction orchestrator:
- Extracts data from PHP code, extension configs, composer.json
- Optional: build configs (.github/workflows, phpunit.xml)
- Optional: repository metadata (GitHub/GitLab API)
- Writes JSON files to `data/` in the extraction directory, outside the project: `$DOCS_EXTRACTION_DIR` if set, else `${TMPDIR:-/tmp}/typo3-docs-extraction/<sha256 of the project path>`; `extraction-dir.sh` prints it

**analyze-docs.sh** - Documentation coverage analysis:
- Compares extracted data with existing Documentation/
- Identifies missing and outdated documentation
- Generates ANALYSIS.md with recommendations in the extraction directory
- Prioritizes action items for systematic documentation

**extract-php.sh** - PHP code extraction:
- Reads the class declarations in Classes/**/*.php
- Extracts class name, namespace, docblock summary, @author and @license
- Outputs to data/php_apis.json in the extraction directory

**extract-extension-config.sh** - Extension configuration extraction:
- Parses ext_emconf.php for extension metadata
- Parses ext_conf_template.txt for configuration options
- Identifies security warnings in config comments
- Outputs to extension_meta.json and config_options.json

**extract-composer.sh** - Composer dependency extraction:
- Extracts requirements and dev-requirements
- Outputs to data/dependencies.json in the extraction directory

**extract-project-files.sh** - Project file extraction:
- Extracts content from README.md, CHANGELOG.md
- Outputs to data/project_files.json in the extraction directory

**extract-build-configs.sh** - Build configuration extraction (optional):
- Extracts CI/CD configurations, PHPUnit settings
- Outputs to data/build_configs.json in the extraction directory

**extract-repo-metadata.sh** - Repository metadata extraction (optional):
- Fetches GitHub/GitLab repository information
- Requires gh or glab CLI tools
- Outputs to data/repo_metadata.json in the extraction directory
- Cached for 24 hours

## Usage

The skill automatically activates for TYPO3 documentation tasks. You can also manually invoke it:

```
/skill typo3-docs
```

### Quick Examples

`$SKILL_SCRIPTS` stands for the skill's `scripts/` directory. For the skills-directory install above, set it first: `SKILL_SCRIPTS=~/.claude/skills/typo3-docs/skills/typo3-docs/scripts`.

**Add AI Assistant Context:**
```bash
cd /path/to/your-extension
$SKILL_SCRIPTS/add-agents-md.sh
# Creates Documentation/AGENTS.md with TYPO3 documentation patterns
```

**Extract and Analyze Documentation:**
```bash
cd /path/to/your-extension

# Extract data from code and configs
$SKILL_SCRIPTS/extract-all.sh

# Analyze documentation coverage
$SKILL_SCRIPTS/analyze-docs.sh

# Review the analysis report
cat "$("$SKILL_SCRIPTS/extraction-dir.sh")/ANALYSIS.md"

# Extract with optional sources
$SKILL_SCRIPTS/extract-all.sh --all  # Include build configs & repo metadata
```

**Document Configuration:**
```rst
.. confval:: fetchExternalImages

   :type: boolean
   :Default: true
   :Path: $GLOBALS['TYPO3_CONF_VARS']['EXTENSIONS']['ext_key']['setting']

   Controls whether external image URLs are automatically fetched.
```

**Document Version Changes:**
```rst
.. versionadded:: 13.0.0
   The CKEditor plugin now requires ``StyleUtils`` and ``GeneralHtmlSupport``
   dependencies for style functionality.
```

**Create Card Grid Navigation:**
```rst
.. card-grid::
    :columns: 1
    :columns-md: 2

    ..  card:: 📘 Introduction

        Extension overview and features

        ..  card-footer:: :ref:`Read more <introduction>`
            :button-style: btn btn-primary stretched-link
```

**Validate Documentation:**
```bash
$SKILL_SCRIPTS/validate_docs.sh /path/to/project
```

**Render Documentation:**
```bash
$SKILL_SCRIPTS/render_docs.sh /path/to/project
```

## Deployment Setup

**Enable automatic documentation publishing to docs.typo3.org:**

### Prerequisites
1. Extension published in [TYPO3 Extension Repository (TER)](https://extensions.typo3.org/)
2. Git repository URL referenced on TER detail page
3. Valid Documentation/ structure with Index.rst and guides.xml

### Quick Webhook Setup

**GitHub:**
```
Settings → Webhooks → Add webhook
Payload URL: https://docs-hook.typo3.org
Content type: application/json
SSL: Enabled
Events: Just the push event
Active: ✓
```

**GitLab:**
```
Settings → Webhooks
URL: https://docs-hook.typo3.org
Triggers: Push events + Tag push events
SSL: Enabled
```

### Verification

After first push, check:
- **Webhook delivery**: GitHub/GitLab webhook recent deliveries (expect `200`)
- **Build status**: [Intercept Dashboard](https://intercept.typo3.com/admin/docs/deployments)
- **Published docs**: `https://docs.typo3.org/p/{vendor}/{extension}/main/en-us/`

**First build requires approval** by TYPO3 Documentation Team (1-3 business days). Future builds are automatic.

**Full webhook setup guide:** [references/intercept-deployment.md](skills/typo3-docs/references/intercept-deployment.md)

## Quality Standards

Before committing documentation changes, ensure:

- ✅ No rendering warnings
- ✅ No broken cross-references
- ✅ All confval directives complete
- ✅ Version information for new features
- ✅ Card grids use stretched-link
- ✅ UTF-8 emoji icons in card titles
- ✅ Code blocks specify language
- ✅ Proper heading hierarchy
- ✅ No trailing whitespace

## Resources

**Official Documentation:**
- [TYPO3 Documentation Guide](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/)
- [RST Reference](https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html)
- [Rendering with Docker](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/RenderingDocs/Index.html)

**Example Projects:**
- [TYPO3 Best Practice Extension](https://github.com/TYPO3BestPractices/tea)
- [RTE CKEditor Image](https://docs.typo3.org/p/netresearch/rte-ckeditor-image/main/en-us/)

**TYPO3 Intercept:**
- [Deployment Dashboard](https://intercept.typo3.com/admin/docs/deployments)

## Contributing

Open issues and pull requests on [GitHub](https://github.com/netresearch/typo3-docs-skill). Fork the repository, create a branch, and open a pull request against `main`. The commands for working on this repository are listed in [AGENTS.md](AGENTS.md#commands). A pull request that adds or changes behaviour in a script adds or updates a check in `tests/` that fails without the change.

### Tests

The behavioural tests live in `tests/` and run offline. They need bash, git, php, python3, perl and jq; no Docker daemon, network or model API is used.

```bash
bash tests/checkpoint-scripts.sh                  # the TD-* check scripts (settings, confval, screenshots, ADRs, substitutions, guides.xml sync)
bash tests/check-changelog-version-coverage.sh    # check-changelog-version-coverage.sh
bash tests/check-version-match.sh                 # check-version-match.sh
bash tests/validation-scripts.sh                  # validate_docs.sh, validate_headings.py, check-guides-xml-schema.sh, check-required-doc-sections.sh, check-untranslated-fluid-strings.sh, render_docs.sh
bash tests/extract-scripts.sh                     # extract-*.sh, extraction-dir.sh, json-string.sh
bash tests/analyze-docs.sh                        # analyze-docs.sh
bash tests/add-agents-md.sh                       # add-agents-md.sh
bash tests/check-plugin-version.sh                # Build/Scripts/check-plugin-version.sh and Build/hooks/pre-push
python3 tests/validate_rst_hook.py                # scripts/validate_rst.py, the plugin hook
```

- The tests build fixture directories (extensions, git repositories, extraction data, hook payloads) in a temporary directory, run the script against them and compare exit codes, output and written files. Extraction output goes to a temporary `DOCS_EXTRACTION_DIR`.
- `render_docs.sh` is run against a stand-in `docker` placed first on `PATH`, which records the arguments; the real renderer is not started.
- Each check prints `ok` or `FAIL`; a `FAIL` line names the expectation that was not met and, where there is one, the value found instead. A test file exits 1 when any check failed.

In CI, the Tests workflow (`.github/workflows/tests.yml`) runs every `tests/**/*.sh` and `tests/**/*.py` on each pull request and on pushes to `main`, and fails when the repository ships scripts under `skills/*/scripts/` but no test ran. The skill's Markdown is not executed: Skill Validation checks its structure, and Eval Validation checks the definitions in `skills/typo3-docs/evals/evals.json`. `pre-commit run --all-files` runs the hooks of [`.pre-commit-config.yaml`](.pre-commit-config.yaml) locally. `shellcheck -x -S style` reports nothing for the repository's shell scripts; CI enforces severity `error`.

### Dependencies

- **Composer:** `composer.json` requires `netresearch/composer-agent-skill-plugin` (`*`, the latest release at install time), which installs the skill into a PHP project. No `composer.lock` is committed.
- **Tools the scripts call:** bash, git, php (guides.xml parsing, `ext_emconf.php`), python3 (`validate_headings.py`, the plugin hook), jq (`analyze-docs.sh`, `extract-repo-metadata.sh`; `extract-composer.sh` falls back to php), perl (`check-rst-substitutions-resolve.sh`), Docker (`render_docs.sh`, image `ghcr.io/typo3-documentation/render-guides:latest`), `gh` or `glab` (`extract-repo-metadata.sh`, optional) and docutils' `rst2html.py` (`validate_docs.sh`, optional). The scripts install none of them; `SKILL.md` names php and Docker under `compatibility`.
- **Development tools:** the hooks in `.pre-commit-config.yaml` are pinned by `rev:`. Renovate ([`renovate.json`](renovate.json), `config:recommended` with the pre-commit manager enabled) proposes updates for them. The Composer requirement has no version range and no lock file, so there is nothing for it to update.
- **CI:** the workflows call reusable workflows of `netresearch/.github`, `netresearch/skill-repo-skill` and `netresearch/typo3-ci-workflows`; those reusables pin the third-party actions they use by commit SHA.
- A new dependency arrives through a pull request, where dependency review and Composer Audit run (see below); which licences and findings are acceptable is set by the organisation policy linked below.

## Governance and policies

This repository follows the Netresearch organisation policies:

- [Governance](https://github.com/netresearch/.github/blob/main/GOVERNANCE.md): ownership, roles, how decisions are made and disputes resolved, and continuity.
- [Roadmap](https://github.com/netresearch/.github/blob/main/ROADMAP.md): planned and explicitly excluded work for the coming year.
- [Handling of dependency and code analysis findings](https://github.com/netresearch/.github/blob/main/SECURITY.md#handling-of-dependency-and-code-analysis-findings): thresholds, deadlines and the exception process for dependency (SCA) and static analysis (SAST) findings.
- [Secret management](https://github.com/netresearch/.github/blob/main/SECURITY.md#secret-management): how CI and release credentials are stored, accessed and rotated.
- [Access roster](https://github.com/netresearch/.github/blob/main/docs/access-roster.md): who holds administrative access to this repository and the organisation.

The security assurance case for this skill (threat model, trust boundaries, countermeasures and limits) is in [docs/SECURITY-ASSURANCE.md](docs/SECURITY-ASSURANCE.md).

Checks that run on pull requests in this repository:

- Every pull request: Skill Validation (`lint.yml`: skill structure, markdownlint, yamllint, actionlint, JSON syntax, ShellCheck, ruff, checkpoint schema), Eval Validation (`eval-validate.yml`), Tests (`tests.yml`), PR Quality Gates (`pr-quality.yml`), the Labeler (`labeler.yml`) and Auto-merge dependency PRs (`auto-merge-deps.yml`, which acts only on Renovate and Dependabot pull requests); configured outside the workflows: CodeQL through GitHub's default setup (Actions and Python), SonarCloud, the DCO sign-off check, the CodeRabbit review and the Copilot code review that the repository ruleset requests.
- Pull requests to `main`: `security.yml` with Betterleaks (secret scanning; fails when it finds a secret), zizmor (workflow static analysis, reported to code scanning), dependency review (fails on vulnerabilities of severity high or above), Composer Audit and Opengrep SAST (which findings fail the check is set by the [organisation rule](https://github.com/netresearch/.github/blob/main/SECURITY.md#static-analysis-sast)); Harness Verification (`harness-verify.yml`) and Template Drift (`check-template-drift.yml`).

Secrets are detected by Betterleaks, which also scans every push to `main`, and by GitHub secret scanning with push protection, which is enabled for the repository.

## License

This project uses split licensing:

- **Code** (scripts, workflows, configs): [MIT](LICENSE-MIT)
- **Content** (skill definitions, documentation, references): [CC-BY-SA-4.0](LICENSE-CC-BY-SA-4.0)

See the individual license files for full terms.
## Support

**Issues and Questions:**
- GitHub Issues: [Report issues](https://github.com/netresearch/typo3-docs-skill/issues)
- TYPO3 Slack: [#typo3-cms](https://typo3.slack.com/archives/typo3-cms)

## Credits

Created by Netresearch DTT GmbH for the TYPO3 community.

Based on:
- [TYPO3 Official Documentation Standards](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/)
- [Anthropic Skill Creator](https://github.com/anthropics/skills/tree/main/skill-creator)
- Real-world usage in [RTE CKEditor Image Extension](https://github.com/netresearch/t3x-rte_ckeditor_image)

---

**Maintained By:** Netresearch DTT GmbH

---

**Made with ❤️ for Open Source by [Netresearch](https://www.netresearch.de/)**
