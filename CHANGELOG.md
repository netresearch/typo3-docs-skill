# Changelog

All notable changes to the typo3-docs skill are documented here.

This project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [v2.20.4](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.20.4) — 2026-09-20

### Fixed

- `scripts/check-changelog-version-coverage.sh` accepts the version with or without the `v` inside the brackets, and matches both heading forms as fixed strings. A heading the script did not recognise counted as a missing release, so the coverage check reported gaps that were not there

### Changed

- `CHANGELOG.md` carries the fifteen releases 2.7.0 through 2.14.4, which were published without an entry here
- The reference set drops what has landed upstream and corrects what was wrong, so the skill no longer restates rules the TYPO3 documentation now owns
- The inventory lookup is case-insensitive, and the permalink check is part of it

## [v2.20.3](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.20.3) — 2026-09-18

### Changed

- `references/upstream-docs-contribution.md` now points at the target repository's own `AGENTS.md` instead of restating backport rules, and says the repo wins where the two disagree. `TYPO3CMS-Reference-CoreApi` has carried one since 2026-08-21, and it owns what this page used to get wrong: `Releases:` in every commit whatever your label permissions, the trailer order, the `Assisted-by:` form, the default `main, 14.3` with `13.4` reserved for a bugfix or security fix, and the `main only` / `changelog` labels. The page previously said backports run via labels and told the reader to put backport intent in the PR body and @-mention a maintainer — in CoreApi #6651 that waited five weeks for the answer "use the trailer"
- The non-duplicative claim is scoped to what it covers. Beside Howto/Contribute the page now names [Advanced/CommitMessages](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CommitMessages.html), which defines the trailers including `Releases:`; only the squash-only and render-gate facts are observed working knowledge on top of them
- The permission bullet no longer proposes a workaround. A `404` on requesting reviewers or setting labels is expected for an org member without triage rights, and the `Releases:` trailer is the channel — so neither retrying the API nor @-mentioning a maintainer is the answer

### Added

- A measurement of whether that pointer earns its place, because a reference that only repeats a repository's own file is cost without benefit. Haiku 4.5 in headless `claude -p` sessions, against a clone with one uncommitted one-sentence edit, asked only for the commit message: what reaches the session is the `CLAUDE.md` holding `@AGENTS.md`, not the `AGENTS.md` itself. Delete that one-line import and leave `AGENTS.md` in place and `Releases:`, the TYPO3 prefix and every trailer drop to 0 of 6 — indistinguishable from deleting `AGENTS.md` too (0 of 4), pooling to 0 of 10 against 6 of 10 with the import. With the import alone, `Releases:` appeared in 6 of 10 runs, the `main, 14.3` default in 4 of 10 and the prescribed trailer order in 4 of 10; with the two bullets above also in context, `Releases: main, 14.3` and the full order in 6 of 6. A `CLAUDE.md` symlinked to `AGENTS.md` works but is no better, and a Windows clone without `core.symlinks` turns it into a text file whose content is the string `AGENTS.md`

## [v2.20.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.20.2) — 2026-09-17

### Fixed

- The description now opens with what docs.typo3.org reads — it builds from `Documentation/guides.xml` and reads no `Settings.cfg` — and names `README.rst`/`README.md` as the single-file path beside the manual. Measured over recorded rounds on a case asking for an extension's first documentation set (Haiku 4.5, six trials each): the skill was loaded in 1 of 6 trials while its description opened with "creating, editing, or reviewing TYPO3 extension documentation" and named docs.typo3.org eleven words later; the occasion — an extension that has no documentation yet — appeared nowhere. Naming the occasion moved the output directory from `docs/` to `Documentation/`, three trials to nothing. Naming `Settings.cfg` as the replaced file did not stop three of three from writing one, so the description now leads with the consequence rather than the occasion, because what the agent lacks is a fact about what renders
- Step 0 of the guides.xml workflow is a command that writes the file rather than a block to retype. Where the skill was loaded, the agent read the skeleton and then typed it from memory in namespace `guides.phpdoc.org` instead of `www.phpdoc.org/guides` — a file in the wrong namespace is well-formed XML that renders nothing
- The namespace check matches as a fixed string. `grep -c` reads the periods in the URI as wildcards, so a near-miss such as `https://www.phpdocXorg/guides` printed 1 and the check called an invalid namespace valid — on exactly the part that comes out wrong

## [v2.20.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.20.1) — 2026-09-16

### Fixed

- Step 0 of the guides.xml workflow told the agent to copy `assets/guides.xml.dist` and named the namespace in prose only. Written from memory the file comes out wrong in one of two ways, and both are well-formed XML that renders nothing: an invented namespace, or `<project>` carrying the extension key as element text where the renderer reads attributes. The step now carries the two lines that decide it: the phpDocumentor namespace, and `<project>` with `title`, `version` and `release` as attributes. The template stays the source for everything else
- `checkpoints.yaml` declared no preconditions, so `/assess` ran every check against any repository. On a Python repository it reported 16 failures out of 35 checks that were not about that repository. The skill is now gated on `composer.json` `type == "typo3-cms-extension"`, the scope `SKILL.md` declares in `compatibility:`. Gating on `Documentation/` instead would hide TD-01 on extensions that have none

### Changed

- The `generate-guides-xml` eval now asserts the namespace of the root element and whether `<project>` carries its data in attributes — the two properties that decided 14 of 19 measured trials. It previously asserted the theme attribute, the extension class, the GitHub attributes and the inventory URLs, so a file failing both of those properties would have passed it

## [v2.20.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.20.0) — 2026-09-12

### Added

- `references/render-guides-development.md` — changing the renderer itself: how directive options arrive (an option written without a value is the boolean `true`, and a value on the following line is appended to its stringified form), why the value must be read untrimmed, the theme's widened interlink parser, what the integration suite actually compares, and that the committed `theme.css` is not rebuilt by any CI job

## [v2.19.4](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.19.4) — 2026-09-11

### Added

- README: the `/plugin install` step missing from the marketplace section, a "Without a marketplace" section covering the skills-directory route, and a note that `npx skills` installs `SKILL.md` skills only — not the hooks this repo also ships

## [v2.19.3](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.19.3) — 2026-09-05

### Changed

- intercept-deployment: a first-push 500 may already have notified volunteers

## [v2.19.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.19.2) — 2026-09-03

### Changed

- Renovate manages the pre-commit hooks

### Fixed

- Checkpoints no longer execute repository code to count backend modules
- Checks that could never pass repaired

## [v2.19.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.19.1) — 2026-08-26

### Fixed
- Comments in `check-guides-xml-schema.sh`, `validate_docs.sh` and checkpoint `TD-05` named the benchmark case and repository the measurement came from. A skill that is itself under evaluation must not carry the evaluation's identifiers; the benchmark's contamination check flagged it (typo3-docs)

## [v2.19.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.19.0) — 2026-08-22

### Fixed
- `scripts/validate_docs.sh` tested only that `Documentation/guides.xml` exists and printed "guides.xml found (modern PHP-based rendering)" for a file in an invented schema — it never opened it. It now parses the file and exits non-zero unless the root element is in `https://www.phpdoc.org/guides` and `<project>` carries non-empty `title` and `release` **attributes** (typo3-docs)
- Checkpoint `TD-05` was `contains "<project"`, which a hallucinated `<project>my-extension</project>` satisfies. It now asserts the namespace and both attributes (typo3-docs)

### Added
- `scripts/check-guides-xml-schema.sh`, the parse-and-assert check both of the above use, runnable on its own (typo3-docs)

## [v2.18.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.18.0) — 2026-08-22

### Added
- `assets/guides.xml.dist`, the canonical `guides.xml` to copy when an extension has none, and a step 0 in the Core Workflow that says to copy it rather than write one from memory (typo3-docs)

### Fixed
- `references/guides-xml.md` was listed as "build config, interlinks", which hid that it also carries the `guides.xml` skeleton — an agent creating documentation from nothing had no reason to open it (typo3-docs)
- `compatibility` claimed the skill needs "a TYPO3 extension with Documentation/ directory", which excluded the case the skill is most needed for (typo3-docs)

## [v2.17.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.17.0) — 2026-08-17

### Added
- Checkpoint TD-51 flags `literalinclude` line-selection options (`:lines:`, `:start-after:`, `:end-before:`, `:start-at:`, `:end-at:`) — the TYPO3 renderer does not implement them, renders the whole file and ignores the option silently (typo3-docs)
- `objects.inv.json` query recipe for locating moved pages and `:ref:` targets via the manual's published object inventory instead of guessed rendered paths (typo3-docs)

### Changed
- Screenshot viewport, iframe and "no symlinks in Documentation/" rules shrink to a reference plus the part that is genuinely ours, now that HowToDocument #539 and #543 carry them upstream (typo3-docs)

### Fixed
- Replace the dead InterlinkInventories URL with its permalink form; the manual lives under `other/t3docs/`, not `other/typo3/render-guides/` (typo3-docs)
- Correct the todo rationale: the renderer silently drops todo content, so author notes must use plain comments (typo3-docs)

## [v2.16.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.16.0) — 2026-08-14

### Added
- Upstream TYPO3-Documentation contribution guide as a reference (typo3-docs)

### Changed
- Reconcile all reference files against their canonical upstream sources, with provenance labeled per rule (typo3-docs)
- Prune RST-family, build and config references to pointers plus agent-specific value (typo3-docs)

### Fixed
- Align drifted authority rules with upstream wording, including the ~250-line report heuristic (typo3-docs)
- Correct four verified factual defects in the references (typo3-docs)
- guides.xml: remove the invented `theme=typo3docs` mandate (typo3-docs)

## [v2.15.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.15.1) — 2026-08-12

### Added
- Commit diagrams as SVG, and where render-guides puts them (typo3-docs)

## [v2.15.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.15.0) — 2026-08-08

### Added
- Add Agent Plugins 1.0.0 portable manifest (manifest)

## [v2.14.4](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.14.4) — 2026-08-06

### Added

- Rendering: symlinks under `Documentation/` break the renderer — use permalinks
  for outbound links ([#65](https://github.com/netresearch/typo3-docs-skill/pull/65))
- Theme-screenshot verification and interlink facts
  ([#66](https://github.com/netresearch/typo3-docs-skill/pull/66))

## [v2.14.3](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.14.3) — 2026-08-03

### Added

- Rendering: `--output` is resolved inside the container, so a host path that is
  not mounted discards the render while printing success
  ([#60](https://github.com/netresearch/typo3-docs-skill/pull/60))
- Secret and workflow scanning in `security.yml`
  ([#61](https://github.com/netresearch/typo3-docs-skill/pull/61))

### Changed

- Adopted the shared skill template
  ([#62](https://github.com/netresearch/typo3-docs-skill/pull/62))
- Dropped the local zizmor policy copy — the reusable workflow supplies it
  ([#63](https://github.com/netresearch/typo3-docs-skill/pull/63))

### Fixed

- ruff 0.16.0 compatibility
  ([#59](https://github.com/netresearch/typo3-docs-skill/pull/59))

## [v2.14.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.14.2) — 2026-07-13

### Changed

- `rst-syntax`: cut generic RST/Sphinx tutorial content
  ([#57](https://github.com/netresearch/typo3-docs-skill/pull/57))

## [v2.14.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.14.1) — 2026-07-06

### Added

- The version-tag webhook's HTTP 500 from docs-hook.typo3.org diagnosed and
  documented ([#54](https://github.com/netresearch/typo3-docs-skill/pull/54))
- Screenshots: `fullPage` clips backend-module content because it sits in an
  iframe ([#55](https://github.com/netresearch/typo3-docs-skill/pull/55))

## [v2.14.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.14.0) — 2026-05-28

### Added

- `.pre-commit-config.yaml` mirroring the CI checks
  ([#50](https://github.com/netresearch/typo3-docs-skill/pull/50))

### Changed

- Screenshots require a capture viewport of 1440px or wider
  ([#51](https://github.com/netresearch/typo3-docs-skill/pull/51))

## [v2.13.2](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.13.2) — 2026-05-15

### Added

- ADR, coverage, scripts and extension-architecture references are cited from
  SKILL.md where they are referenced, so the documentation surface is linked
  from the entry point instead of being found by directory crawl
  ([#48](https://github.com/netresearch/typo3-docs-skill/pull/48))
- `id-token: write` and `attestations: write` on the release caller, so SLSA
  build provenance and cosign signatures can be emitted
  ([#46](https://github.com/netresearch/typo3-docs-skill/pull/46))

### Changed

- SKILL.md trimmed to the 500-word cap the skill-repo validator enforces
  ([2133b7d](https://github.com/netresearch/typo3-docs-skill/commit/2133b7d))
- Release caller simplified to the signed-tag-only model: the deprecated
  `with: bump:` block and the `workflow_dispatch.bump` input are gone, and a
  release happens by pushing a locally signed tag
  ([#47](https://github.com/netresearch/typo3-docs-skill/pull/47))

### Fixed

- yamllint: trailing newline on the release workflow file
  ([97f7b10](https://github.com/netresearch/typo3-docs-skill/commit/97f7b10))

## [v2.13.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.13.1) — 2026-04-25

### Fixed

- Forward the bump input to the reusable release workflow
  ([#43](https://github.com/netresearch/typo3-docs-skill/pull/43))
- TD-07: multiline `guides.xml` and the interlink slash form
  ([#44](https://github.com/netresearch/typo3-docs-skill/pull/44))

## [v2.13.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.13.0) — 2026-04-22

### Added

- XLF 2-space indentation documented as the canonical style, with concrete v14
  translation-extraction examples including a Composer example that runs
  through v14.3
- The reusable `pr-quality` workflow from `skill-repo-skill`, with the
  `SECURITY` note on `pull_request_target` restored for the caller
- The reusable `harness-verify` workflow from `skill-repo-skill`
- The `eval-validate` workflow, running the skill evals on every change

### Changed

- The indent table clarified after review so the guidance does not contradict
  tooling defaults

### Fixed

- The `auto-merge-deps` reusable workflow reference, so dependency PRs
  auto-merge again
- Trailing blank line removed from `harness-verify.yml` to satisfy the reusable
  workflow's YAML check

## [v2.12.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.12.0) — 2026-04-01

### Added

- Eval suite expanded to 20 cases
  ([#36](https://github.com/netresearch/typo3-docs-skill/pull/36))

### Changed

- Skill text improved from the A/B findings those evals produced
  ([#36](https://github.com/netresearch/typo3-docs-skill/pull/36))

## [v2.11.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.11.0) — 2026-03-29

### Added

- Eight documentation-completeness checkpoints, TD-43 through TD-50, covering
  mechanical validation and LLM-assisted review:
  - **TD-43** `guides.xml` version and release stay in sync with
    `ext_emconf.php` (consolidated into TD-30)
  - **TD-44** all six expected sections present: Introduction, Installation,
    Configuration, Usage, Developer, FAQ
  - **TD-45** untranslated literal strings in Fluid templates that should use
    `f:translate`
  - **TD-46** RST substitutions defined in `Includes.rst.txt` are actually used
  - **TD-47** PlantUML directives that may not render on docs.typo3.org
  - **TD-48** every git tag has a `CHANGELOG.md` entry
  - **TD-49** extensions with more than 10 classes that lack an `Adr/` directory
  - **TD-50** LLM review of code examples against the actual API

### Changed

- `.serena/` removed from version control — it holds local project
  configuration

## [v2.10.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.10.0) — 2026-03-28

### Added

- Documentation accuracy and completeness checkpoints
  ([#30](https://github.com/netresearch/typo3-docs-skill/pull/30))

### Fixed

- ASCII accepted as valid UTF-8, and heading-hierarchy detection improved
  ([#31](https://github.com/netresearch/typo3-docs-skill/pull/31))

## [v2.9.1](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.9.1) — 2026-03-21

### Fixed

- GitHub Actions hardened against supply-chain attacks
  ([#27](https://github.com/netresearch/typo3-docs-skill/pull/27))

## [v2.9.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.9.0) — 2026-03-17

### Added

- Agent Skills spec frontmatter: `license`, `compatibility`, `metadata`,
  `allowed-tools`
- Expanded trigger description, now covering rendering, RST directives and
  `guides.xml`
- Eval suite with four cases: create docs from scratch, add a configuration
  section, validate and fix, add screenshots

### Changed

- SKILL.md trimmed to 484 words, dropping four rarely-needed reference entries

### Fixed

- Broken reference link (`guides-xml-reference.md` → `guides-xml.md`)

## [v2.8.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.8.0) — 2026-03-15

### Fixed

- TD-07 accepts the modern phpdoc/guides extension-key formats
  ([#26](https://github.com/netresearch/typo3-docs-skill/pull/26))

## [v2.7.0](https://github.com/netresearch/typo3-docs-skill/releases/tag/v2.7.0) — 2026-03-14

### Added

- Renovate configuration
  ([#23](https://github.com/netresearch/typo3-docs-skill/pull/23))

### Fixed

- DDEV addon name and install command in the documentation
  ([#25](https://github.com/netresearch/typo3-docs-skill/pull/25))

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
