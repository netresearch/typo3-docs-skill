# Text Roles and Inline Code

The role tables live upstream — do not restate them here. **Canonical sources
(win on conflict — see `canonical-sources.md`):**

- [Text roles](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/InlineMarkup/TextRoles/Index.html)
  `[upstream]` — `:file:`, `:path:`, `:guilabel:`, `:kbd:`, `:abbr:`, the
  TYPO3-specific roles (`:composer:`, `:issue:`, `:t3ext:`, `:t3src:`), and
  the note that Docutils standard roles are supported
- [Inline code](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/InlineCode.html)
  `[upstream]` — the language roles (`:php:`, `:php-short:`, `:typoscript:`,
  `:tsconfig:`, `:fluid:`, `:html:`, `:css:`, `:js:`, `:bash:`), PHP-class
  auto-linking to api.typo3.org, and the copy/selection behaviour of rendered
  inline code
- [Cross-references](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Links/Documentation.html)
  `[upstream]` — `:ref:` vs `:doc:` (prefer `:ref:`; `:doc:` breaks when a
  section moves) and interlink syntax

## Unverified roles — do not assert without a render test

`[regression]` The upstream inline-code page documents exactly: php,
php-short, typoscript, tsconfig, fluid, html, css, js, bash. Roles this file
previously listed as available but which are **not documented upstream**:
`:xml:`, `:xliff:`, `:yaml:`, `:json:`, `:sql:`, `:rst:`, and the aliases
`:javascript:`/`:shell:`. Before using one of these in documentation, render
locally and check the log — an unknown role fails the build.

## Common Mistakes `[regression]`

The three failure modes actually observed in agent-written docs:

```rst
# ❌ Wrong: backticks for everything          # ✅ Correct: typed role
``ImageResolverService`` renders images       :php:`ImageResolverService` renders images

# ❌ Wrong: plain text for file paths         # ✅ Correct
See ext_localconf.php for details             See :file:`ext_localconf.php` for details

# ❌ Wrong: plain text for UI elements        # ✅ Correct
Click the Save button                         Click the :guilabel:`Save` button
```

Menu paths: upstream's `:guilabel:` idiom is `Web > Pages` (with `>`);
`:menuselection:` with `-->` is a generic Sphinx role not documented on the
TYPO3 text-roles page — prefer `:guilabel:` with `>` for consistency.
