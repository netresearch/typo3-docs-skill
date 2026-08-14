# Code Blocks and Structure Elements

Code-presentation elements for TYPO3 docs — routing, decision guides and the
skill's own snippet conventions. Syntax lives upstream (canonical, wins on
conflict — see `canonical-sources.md`):
[Code blocks](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Codeblocks.html),
[Inline code](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/InlineCode.html),
[Confval](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Confval.html),
[PHP domain](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Phpdomain.html),
[Site settings](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/SiteSettings.html)
`[upstream]`.

## When to Use What

| Content Type | Element | Example |
|--------------|---------|---------|
| Short inline examples (< 5 lines) | `code-block` directive | Quick syntax demos |
| **Complete code snippets** | **`literalinclude` directive (preferred)** | PHP classes, services, TCA |
| External code files | `literalinclude` directive | Full example files |
| Configuration options | `confval` directive | Extension settings, TCA fields |
| Inline PHP | `:php:` role | Class names, method calls |
| Inline TypoScript | `:typoscript:` role | TypoScript properties |
| File paths | `:file:` role | `ext_localconf.php` |
| UI elements | `:guilabel:` role | Button labels, menu items |
| Keyboard shortcuts | `:kbd:` role | `Ctrl+S` |
| PHP API documentation | `php:class`, `php:method` | Public API reference |
| Site settings | `typo3:site-set-settings` | Site set configuration |

## Code Blocks

Directive syntax, options (`caption`, `linenos`, `lineno-start`,
`emphasize-lines`, `name`), ~200 language identifiers and the placeholder
convention: [Code blocks](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Codeblocks.html)
`[upstream]`. Indent code-block content 4 spaces (CGL).

## literalinclude Directive (Preferred for Code)

`[NR policy]` The "preferred over code-block" grading is a house rule —
upstream mentions `literalinclude` without stating a preference. Rationale:
included files are testable and lintable, embedded blocks are not.

`[regression]` Verify any literalinclude option against the **renderer**
source before using or documenting it (typo3-docs-theme
`LiteralincludeDirective`, phpDocumentor guides option mapper) — the
renderer implements only a subset of Sphinx. Line-selection options
(`:lines:`, `:start-after:`, `:end-before:`) do not exist and are silently
ignored (checkpoint TD-51; upstream precedent #490 / render-guides#974).

**`literalinclude` is the preferred way to include code examples** in TYPO3 documentation. It provides:

- **Syntax validation**: IDE support catches errors in source files
- **Reusability**: Same snippet can be included in multiple places
- **Maintainability**: Update code in one place, documentation stays in sync
- **Testability**: Code files can be validated/linted separately

### File Naming Convention

Code snippet files use an **underscore prefix** to indicate they are include files:

| File Type | Naming Pattern | Example |
|-----------|----------------|---------|
| PHP classes | `_ClassName.php` | `_TranslationService.php` |
| Configuration | `_config-name.yaml` | `_services.yaml` |
| TCA | `_tca-tablename.php` | `_tca-apiendpoint.php` |
| TypoScript | `_setup.typoscript` | `_setup.typoscript` |

### File Organization

Store code snippets in the same directory as the RST file that uses them, or in a shared location:

```
Documentation/
├── Usage/
│   ├── Index.rst
│   ├── ApiEndpointExample.rst
│   ├── _ApiEndpoint.php           ← DTO class
│   ├── _ApiClientService.php      ← Service class
│   └── _tca-apiendpoint.php       ← TCA definition
├── Developer/
│   ├── Adr/
│   │   ├── ADR-009-ExtensionConfig.rst
│   │   ├── _TranslationService.php
│   │   └── _DirectUsage.php
```

### Syntax, Options, confval-menu

[Confval](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Confval.html)
`[upstream]` — reserved attributes `:type:`, `:default:`, `:required:`,
`:name:`, `:class:`, `noindex` (free-form attributes render as written), and
`confval-menu` with `:display:`, `:name:`, `:exclude:`, `:exclude-noindex:`,
`:class:`.

## PHP Domain

Directives and cross-reference roles:
[PHP domain](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Phpdomain.html)
`[upstream]`; signature-parser limitations (`?string`, union types) in
[`typo3-directives.md`](typo3-directives.md#php-domain).

### When NOT to Use PHP Domain

Use `confval` instead of PHP domain for:
- TCA configuration
- Extension configuration arrays
- Any PHP array-based configuration

## Site Settings Documentation

[Site settings](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/SiteSettings.html)
`[upstream]` — incl. the `:Label: max=30` / `:default: max=10` syntax and
`PROJECT:` usage that an excerpt would lose.

## Decision Guide

### Use `literalinclude` When (Preferred)

- **Complete code examples** (classes, services, configuration)
- Code is **5+ lines** or represents a complete unit
- Code should be **syntactically valid** and testable
- Same code might be **referenced multiple times**
- You want **IDE support** for the source files

### Use `code-block` When

- Very short snippets (< 5 lines)
- Pseudocode or conceptual examples
- Code with intentional placeholders like `<your-value>`
- Quick syntax demonstrations

### Use `confval` When

- Documenting configuration options
- Values have type, default, required attributes
- Need structured presentation of settings

### Use Inline Roles When

- Mentioning code elements in text
- Referencing file paths, UI elements
- Keep paragraphs readable (avoid overuse)

### Use PHP Domain When

- Documenting public API
- Creating formal class/method reference
- Need cross-referencing between API elements

## Pre-Commit Checklist

1. ✅ **Complete code examples use `literalinclude`** with `_filename.ext` source files
2. ✅ Source files have underscore prefix (`_MyClass.php`)
3. ✅ All code blocks/includes have `:caption:` with target file path
4. ✅ Correct `:language:` identifier used
5. ✅ Code syntax is valid (highlighting works)
6. ✅ Placeholders use angle brackets `<your-value>`
7. ✅ Configuration uses `confval` directive
8. ✅ Inline code uses appropriate roles (`:php:`, `:file:`, etc.)
9. ✅ UI elements use `:guilabel:`

## References

- **Code Blocks:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Codeblocks.html
- **confval:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Confval.html
- **Inline Code:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/InlineCode.html
- **PHP Domain:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Phpdomain.html
- **Site Settings:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/SiteSettings.html
