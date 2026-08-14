# Canonical Sources — who owns which truth

The official TYPO3 How-to-Document manual is the canonical source for TYPO3
documentation standards. This skill legitimately carries three things:

- **workflow, scripts, and extraction/validation tooling** (its own procedure),
- **agent-specific failure patterns** observed in real sessions
  (e.g. the `fullPage`-clips-the-backend-iframe trap),
- **deliberately stricter Netresearch policy**, labelled as such.

Everything else is a *reference* to upstream, not a copy. A duplicated
upstream rule needs justification and evidence; an agent-specific rule needs
an observed failure mode; a Netresearch rule must be labelled as Netresearch
policy — anything else is removed or referenced.

## On conflict, the live upstream page wins

Do not enforce a cached skill rule against current official documentation:
follow the live manual, then **report the drift** (e.g. via `/retro`) so the
skill gets fixed. Where upstream itself is wrong or incomplete, propose an
upstream PR instead of widening the local copy — see
`upstream-docs-contribution.md`.

## Topic → canonical source

| Topic | Canonical source |
|---|---|
| RST coding guidelines (indentation, wrapping, headings) | [CGL for ReST files](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/CodingGuidelines/Index.html) |
| Images and screenshots (formats, necessity, dimensions) | [Guidelines for images](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/GuidelinesForImages.html) |
| `guides.xml` settings and their allowed values | [guides.xml reference](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/GuidesXml.html) |
| File structure and naming | [File structure](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/FileStructure.html) |
| Directives, text roles, content elements | [reStructuredText reference](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Index.html) |
| Screenshot container setup | [Screenshot container](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ScreenshotContainer/Index.html) |
| TYPO3 core behaviour cited in docs | TYPO3 core **source** (raw GitHub, see `upstream-docs-contribution.md`) — never rendered HTML, never memory |
| The extension's own values (version, CLI flags, API signatures) | The extension's code and manifests (`ext_emconf.php`, `Command::configure()`, `Classes/`) |

## Provenance labels

Rules in this skill's references and `checkpoints.yaml` carry one of four
provenance classes (schema: automated-assessment-skill,
`references/checkpoints-schema.md` §Provenance):

| Label | Meaning | Price of entry |
|---|---|---|
| `[upstream]` | Restates the official manual | Source link; re-verify on any conflict |
| `[NR policy]` | Deliberate Netresearch rule at or beyond upstream | Named rationale; never presented as "the TYPO3 standard" |
| `[heuristic]` | Quality preference | Lowest severity; never presented as a normative rule |
| `[regression]` | Guards an observed agent failure | The observed failure (session/issue/PR) |

Known deliberate deviations from upstream:

| Rule | Upstream says | Netresearch says | Class |
|---|---|---|---|
| `project-contact` / email addresses | `mailto:` explicitly allowed (it is the documented example) | No `mailto:`/email in public docs — spam and PII exposure; use Issues/Discussions URLs | `[NR policy]` |
| Screenshot format | PNG **or AVIF** | PNG preferred for consistency; AVIF acceptable | `[NR policy]` (soft) |
| RST page length | No limit exists | Aim for ≤ ~250 lines, split with `toctree` | `[heuristic]` |
| Screenshots for backend modules/config | "Consider if one is necessary" | Strongly encouraged where they aid understanding — never blind, necessity check first | `[heuristic]` |
