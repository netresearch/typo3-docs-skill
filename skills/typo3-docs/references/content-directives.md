# Content Directives Reference

Routing tables, decision guides and observed pitfalls for TYPO3 content
directives. Syntax lives upstream — canonical sources (win on conflict, see
`canonical-sources.md`):
- https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Accordion.html
- https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Admonitions.html
- https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Cards.html
- https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tabs.html
- https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tables.html
- https://docs.typo3.org/permalink/h2document:versions
- https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/ViewHelper.html

## When to Use What

| Content Type | Directive | Use Case |
|--------------|-----------|----------|
| Collapsible sections | `accordion` | FAQ-style content, optional details |
| Warnings/notes | Admonitions | Important notices, tips, cautions |
| Overview grids | `card-grid` | Feature lists, navigation pages |
| Alternative code | `tabs` | Multi-language examples, version variants |
| Structured data | Tables | Comparisons, reference data |
| Version info | `versionadded` | API changes, new features |
| Fluid docs | `typo3:viewhelper` | ViewHelper reference |

## Accordion

Syntax and options (`accordion`, `accordion-item` with `:name:`, `:show:`,
`:header-level:`):
[Accordion](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Accordion.html)
`[upstream]`. Note: there is no `:open:` option — an earlier version of this
file invented one.

### Best Practices

- Use for FAQ sections
- Use for optional, supplementary information
- Use for long content that would break reading flow
- Do NOT use for critical information users might miss

## Admonitions

Types and syntax (`note`, `tip`, `warning`, `attention`, `seealso`; `hint`/
`caution`/`danger` as alternatives — upstream prefers `tip` over `hint`):
[Admonitions](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Admonitions.html)
`[upstream]`. `important` and `error` are NOT documented upstream — render
before using them.

### Options — unverified

`[regression]` Upstream's Admonitions page documents **no** options.
`:title:`, `:class:`, `:name:` previously listed here are unverified — render
locally before relying on them.

### Decision Guide

| Situation | Use |
|-----------|-----|
| Background context | `note` |
| Helpful suggestion | `tip` |
| Potential problems | `warning` |
| Data loss risk | `danger` |
| Related resources | `seealso` |
| API deprecation | `deprecated` (version directive) |

## Cards

`card-grid`, `card`, `card-footer` (`:button-style:` incl. `stretched-link`)
and `card-image` (`:alt:`, `:position:`):
[Cards](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Cards.html)
`[upstream]`. Previously listed here but NOT documented upstream (verify by
render before use): `:columns-lg:`, `:headline-level:`, `:link:`.

## Tabs

`..  tabs::` with inner `..  group-tab::`; tab changes synchronize across all
tab groups on the page:
[Tabs](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tabs.html)
`[upstream]`. (`..  tab::` is not documented upstream — do not use it.)

### Best Practices

- Use consistent tab names for synchronization
- Keep tab content comparable in scope
- First tab should be the most common/recommended option
- Do NOT nest tabs inside tabs

## Tables

Simple, grid and `csv-table` forms:
[Tables](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tables.html)
`[upstream]`.

### t3-field-list-table (TYPO3 Specific)

`[upstream]` — documented on the Tables page, **with a caveat the old copy
here hid**: it is a custom directive that should not be used when the RST
must also render on other platforms (e.g. GitHub); plain tables are portable.

### Table Options

`[upstream]` documents `:header:`, `:widths:`, `:header-rows:`. Previously
also listed here but unverified upstream: `:width:`, `:class:`, `:name:` —
render before relying on them.

### Decision Guide

| Scenario | Table Type |
|----------|------------|
| Quick 2-3 column | Simple table |
| Complex merging | Grid table |
| External data | csv-table |
| TCA/field docs | t3-field-list-table |

## Version Directives

`versionadded` / `versionchanged` / `deprecated`, incl. nesting inside
admonitions:
[Versions](https://docs.typo3.org/permalink/h2document:versions)
`[upstream]`. Write the directive for the release you are building — see
`rst-syntax.md` ("Version Directive Accuracy").

## ViewHelper Documentation

`[upstream]` Document Fluid ViewHelpers with the `typo3:viewhelper` directive
— it renders the argument list **automatically from a JSON file** produced by
the fluid-documentation-generator; do not hand-write per-argument `confval`
blocks or `rubric` argument tables (that is the legacy Sphinx-era pattern and
does not render as intended). Canonical reference:
[ViewHelper directive](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/ViewHelper.html)

```rst
..  typo3:viewhelper:: RenderViewHelper
    :source: _Json/RenderViewHelper.json
    :sortBy: name
```

| Option | Purpose |
|--------|---------|
| `:source:` | Path to the JSON file with the ViewHelper data (`argumentDefinitions`) |
| `:sortBy:` | Argument ordering: `name` (alphabetical) or `json` (file order) |
| `:noindex:` | Prevent indexing when the same ViewHelper appears multiple times |

## Comments and Special Characters

[Comments](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Comments.html)
and
[Special characters](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/SpecialCharacters.html)
`[upstream]`. Skill rule (`[regression]`): `.. todo::` must not survive into
published documentation — resolve it or demote to a comment (see
`rst-syntax.md`).

## Pre-Commit Checklist

1. ✅ Admonitions use correct type for message severity
2. ✅ Cards have consistent structure in grid
3. ✅ Tabs use matching names for synchronization
4. ✅ Tables use appropriate syntax for complexity
5. ✅ Version directives include version number
6. ✅ Deprecated items mention replacement and removal version
7. ✅ Accordion items have unique names
8. ✅ All directives properly indented (4 spaces)

## References

- **Accordion:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Accordion.html
- **Admonitions:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Admonitions.html
- **Cards:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Cards.html
- **Tabs:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tabs.html
- **Tables:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tables.html
- **Versions:** https://docs.typo3.org/permalink/h2document:versions
- **ViewHelper:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/ViewHelper.html
