<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Security assurance case — typo3-docs-skill

This document states what a user can expect from this repository in terms of security, and argues why that expectation holds. Every claim names the file that implements it. Reporting a vulnerability: see the [security policy](https://github.com/netresearch/.github/blob/main/SECURITY.md). Components and data flow: [ARCHITECTURE.md](ARCHITECTURE.md).

## What the repository ships

| Part | Files | Runs where |
| --- | --- | --- |
| Skill instructions for an AI agent | `skills/typo3-docs/SKILL.md`, `skills/typo3-docs/references/*.md` | Read by the agent as instructions; not executed. The agent may run the commands they show in the user's project. |
| Templates | `skills/typo3-docs/assets/AGENTS.md`, `skills/typo3-docs/assets/guides.xml.dist` | Copied into the user's extension, by `add-agents-md.sh` or by hand. |
| Scripts | `skills/typo3-docs/scripts/*.sh`, `skills/typo3-docs/scripts/validate_headings.py` | On the user's machine, in the extension directory the user runs them from. |
| Checkpoints | `skills/typo3-docs/checkpoints.yaml` | Only when an assessment tool runs them in a user's project. |
| Plugin hook | `hooks/hooks.json`, `scripts/validate_rst.py` | In a Claude Code session that has the plugin installed, before every `Write` and `Edit`. |
| Repository checks | `Build/Scripts/check-plugin-version.sh`, `Build/hooks/pre-push`, `scripts/verify-harness.sh`, `tests/*` | In this repository's CI and on contributors' machines. |

The repository ships no server component, no container image and no code that runs inside a TYPO3 installation. It stores nothing and handles no accounts. It holds no credentials; `extract-repo-metadata.sh` uses whatever `gh` or `glab` login the user already has.

## Security requirements

1. Scripts change the user's extension only where their purpose says so: `add-agents-md.sh` creates `Documentation/AGENTS.md` and asks before it replaces an existing one; `render_docs.sh` lets the renderer write `Documentation-GENERATED-temp/`. The extraction scripts and `analyze-docs.sh` write their results into the extraction directory outside the project. The check scripts and the checkpoints do not change the extension.
2. Only two scripts use the network: `render_docs.sh` through `docker run`, and `extract-repo-metadata.sh` through `gh` or `glab`, which `extract-all.sh` runs only with `--repo` or `--all`. The skill never sends a webhook itself.
3. The plugin hook cannot block or alter a write: it reads the tool call from standard input, prints advice, and always exits 0.
4. Values read from the project cannot change the structure of the JSON the extraction scripts write.
5. Nothing committed to this repository contains a secret.
6. A release carries the version that `.claude-plugin/plugin.json` states, comes from a signed tag, and its archives can be verified against the build that produced them.

## Actors and trust boundaries

- **Skill user and agent.** The agent reads `SKILL.md` and the references and acts in the user's project with the user's permissions. `allowed-tools` in `SKILL.md` (`Bash(php:*) Bash(docker:*) Bash(sed:*) Bash(grep:*) Read Write Glob Grep`) pre-approves those tools so the agent is not asked for each call; it does not take any other tool away from the agent.
- **The documented extension.** It is trusted in the same way as code the user is about to work on. `extract-extension-config.sh` runs the extension's `ext_emconf.php` through PHP's `include`, and `check-ui-surface-screenshots.sh` includes `Configuration/Backend/Modules.php`, so the extension's PHP runs with the user's rights. Other files are read as text or parsed as XML or JSON.
- **The renderer.** `render_docs.sh` runs `ghcr.io/typo3-documentation/render-guides:latest`, the TYPO3 Documentation Team's image, and mounts the project into it at `/project`, writable.
- **GitHub and GitLab.** `extract-repo-metadata.sh` derives the repository from `git remote -v` and asks the GitHub or GitLab API about it with the user's CLI login.
- **docs.typo3.org.** `references/intercept-deployment.md` shows how to set up and redeliver the `docs-hook.typo3.org` webhook with `gh api`. Those commands run only when the agent or the user runs them, with the user's GitHub credentials.
- **Assessment tools.** `checkpoints.yaml` commands run in the assessed project with the privileges of whoever starts the tool; its header lists the runner's restrictions every command obeys.
- **Contributors.** Changes reach `main` through pull requests, checked by the workflows in `.github/workflows/`. `.envrc` (direnv) sets `core.hooksPath` to `Build/hooks`, so a contributor who allows it runs the `pre-push` hook.
- **CI.** Workflows run on GitHub-hosted runners with `permissions: {}` at the top level and grant each job only the scopes its reusable workflow needs. The `pull_request_target` workflows (`auto-merge-deps.yml`, `labeler.yml`, `pr-quality.yml`) call reusables that merge, label, or approve pull requests from collaborators with write access, and do not check out pull request code; `auto-merge-deps.yml` passes two named secrets instead of `secrets: inherit`.

## Threats and countermeasures

| Threat | Countermeasure | Evidence |
| --- | --- | --- |
| A path or file name from the project is interpreted by the shell (CWE-78) | Paths are quoted; file lists are read line by line (`while IFS= read -r`) or NUL-separated (`find -print0`); PHP receives file paths as arguments (`$argv`), not inside its source | `extract-*.sh`, `validate_docs.sh`, `check-guides-xml-schema.sh`; `tests/extract-scripts.sh` (directory name with a single quote) |
| A value from the project breaks out of the JSON the extractors write (CWE-116) | Every project-derived value goes through `json_string`, which escapes backslashes, quotes and control characters | `scripts/json-string.sh`; `tests/extract-scripts.sh` |
| Report text from the project is run as a command | The heredocs in `analyze-docs.sh` expand only variables; the Markdown backticks in its text are escaped | `analyze-docs.sh`; `tests/analyze-docs.sh` ("prints nothing on stderr") |
| A script silently overwrites the user's work | `add-agents-md.sh` asks before replacing `Documentation/AGENTS.md`; without an answer it aborts | `add-agents-md.sh`; `tests/add-agents-md.sh` |
| A malformed or foreign hook payload breaks the agent's write | `validate_rst.py` exits 0 on unreadable, invalid or unexpected input and never blocks | `scripts/validate_rst.py`; `tests/validate_rst_hook.py` |
| A check reports a partial result as the outcome | Counters use `X=$((X + 1))`, which cannot end a `set -e` script; each check script has tests for the case that must fire and the case that must stay silent | `skills/typo3-docs/scripts/`; `tests/checkpoint-scripts.sh`, `tests/check-changelog-version-coverage.sh`, `tests/check-version-match.sh`, `tests/validation-scripts.sh` |
| A checkpoint modifies the assessed project | The checkpoint commands read files and exit with a status; none writes a file or calls the network | `checkpoints.yaml` |
| A release is tagged with a version that disagrees with `plugin.json` | The pre-push hook runs `check-plugin-version.sh`, which fails when a semver tag at `HEAD` differs from `.claude-plugin/plugin.json` | `Build/hooks/pre-push`, `Build/Scripts/check-plugin-version.sh`; `tests/check-plugin-version.sh` |
| A released archive is tampered with, or released from an unsigned tag | The release workflow verifies that the tag is signed and publishes a Cosign-signed `SHA256SUMS.txt` and build-provenance attestations for the archives | `.github/workflows/release.yml` (calls the skill-repo-skill release reusable) |
| A secret is committed | Betterleaks scans every push to `main` and every pull request to `main` and fails when it finds one | `.github/workflows/security.yml` |
| A vulnerable or malicious dependency is added | Dependency review fails a pull request to `main` on vulnerabilities of severity high or above; Composer Audit checks the Composer dependencies against known advisories; Renovate proposes updates | `.github/workflows/security.yml`, `renovate.json` |
| Insecure code or workflow patterns | Opengrep fails on findings of severity WARNING or above; zizmor reports workflow findings to code scanning; ShellCheck and ruff run in Skill Validation | `.github/workflows/security.yml`, `.github/workflows/lint.yml` |

Which of these checks must pass before a pull request can merge is set in the branch protection of `main`, not in this repository.

## Secure design principles applied

- **Least privilege:** the check scripts and checkpoints do not change the extension; the scripts that do name their target. Workflows start from `permissions: {}`.
- **Fail safe:** the hook fails open so it can never stop an edit; `add-agents-md.sh` treats a missing answer as "no".
- **Economy of mechanism:** the scripts are short bash and Python programs with no dependencies beyond standard tools, PHP and, for rendering, Docker.
- **Separation of data and code:** project values are passed to PHP as arguments and written into JSON through one escaping function.

## What a user cannot expect

- The skill gives guidance; it does not enforce it. The agent writes files and runs commands with the user's permissions; review what it proposes.
- Running the extraction or the UI-surface check on an extension runs that extension's PHP (`ext_emconf.php`, `Configuration/Backend/Modules.php`). Use them only on code you trust.
- `render_docs.sh` uses the `latest` tag of the render-guides image, so what runs depends on what that tag points to at the time.
- `validate_docs.sh` exits 1 only when `Documentation/`, an `.rst` file or `Index.rst` is missing, when `guides.xml` will not render or cannot be checked because `php` is missing, or when docutils' `rst2html.py` is installed and reports a syntax error. Encoding, trailing whitespace and heading findings are warnings and leave the exit code at 0. Without `rst2html.py`, RST syntax is not checked.
- The checks are text and structure checks. They do not render the documentation and do not judge its content; the LLM review checkpoints are judgements by a model and can miss issues.
- The plugin hook recognises a few Markdown patterns in `.rst` files under `Documentation/`; it is a reminder, not a validator.
- Security fixes follow the supported-versions rules of the organisation's security policy; older releases may not receive them.
