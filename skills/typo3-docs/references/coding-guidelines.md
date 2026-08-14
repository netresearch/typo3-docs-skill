# RST Coding Guidelines

Working summary of the TYPO3 documentation coding standards, plus the
labelled Netresearch deltas. **The canonical source is the official manual —
on conflict it wins; report the drift instead of enforcing a stale copy**
(see `canonical-sources.md`):

- [CGL for ReST files](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/CodingGuidelines/Index.html) `[upstream]`
- [Coding guidelines (with .editorconfig sample)](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CodingGuidelines.html) `[upstream]`

## .editorconfig `[NR policy]`

Upstream ships a sample `.editorconfig`; Netresearch makes it mandatory:
every `Documentation/` folder **must** contain one to enforce consistent
formatting:

```editorconfig
# Documentation/.editorconfig
# root = false, as in upstream's sample: root = true here would stop the
# upward lookup and shadow the project's own root .editorconfig.
root = false

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true
max_line_length = 80

[*.rst]
indent_size = 4

[*.{yaml,yml}]
indent_size = 2

[*.xlf]
indent_size = 2
```

> **TYPO3 v14+**: XLIFF files use **2-space** indentation (Important [#107971](https://docs.typo3.org/c/typo3/cms-core/main/en-us/Changelog/14.1/Important-107971-XLFFilesUseTwoSpaceIndentation.html)). Extensions shipping translations alongside docs should align.

**Why .editorconfig?**
- Ensures consistent formatting across editors (VS Code, PhpStorm, Vim, etc.)
- Prevents common issues: wrong indentation, trailing whitespace, mixed line endings
- Auto-enforces TYPO3 documentation standards

## Encoding, Whitespace, Line Wrapping `[upstream]`

UTF-8, spaces-not-tabs, no trailing whitespace, final newline, LF endings,
wrap at 80 chars where possible:
[CGL for ReST files](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/CodingGuidelines/Index.html)
and [Coding guidelines](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CodingGuidelines.html).

## Indentation

| Rule | Value |
|------|-------|
| Indentation style | **Spaces only** (never tabs) |
| RST indentation size | **4 spaces** per level |
| YAML indentation size | 2 spaces per level `[NR policy]` (not stated on the upstream CGL pages) |
| XLIFF indentation size | **2 spaces** per level (TYPO3 **core** changelog [#107971](https://docs.typo3.org/c/typo3/cms-core/main/en-us/Changelog/14.1/Important-107971-XLFFilesUseTwoSpaceIndentation.html) — not a docs-manual rule) |
| RST code examples | 4 spaces indentation |

**Critical:** Incorrect indentation causes rendering failures. RST is whitespace-sensitive. The file-type split above matches the `.editorconfig` block shown earlier: `[*]` (and `[*.rst]`) use 4 spaces, `[*.{yaml,yml}]` and `[*.xlf]` use 2.

```rst
.. note::
    This is correctly indented with 4 spaces.
    The content aligns properly.

.. code-block:: php

    <?php
    // Code block content also uses 4 spaces
    $example = 'value';
```

## Heading Hierarchy

Use consistent underlining characters per heading level:

| Level | Character | Usage |
|-------|-----------|-------|
| 1 | `=` above and below | Page title only |
| 2 | `=` below | Major sections |
| 3 | `-` below | Subsections |
| 4 | `~` below | Sub-subsections |
| 5 | `"` below | Paragraphs |
| 6 | `'` below | Deep nesting |
| 7 | `^` below | Rarely used |
| 8 | `#` below | Rarely used |

**Rules:**
- Underline must be **exactly** the same length as heading text (`[NR policy]`
  — upstream says "as long as the line but this is not enforced"; a mismatch
  renders, but keep them equal)
- Each file starts with level 1, regardless of document hierarchy
- Use **sentence case** (not Title Case)

```rst
=========================
Page title in sentence case
=========================

Section heading
===============

Subsection heading
------------------

Sub-subsection heading
~~~~~~~~~~~~~~~~~~~~~~
```

## Version Hints `[upstream]`

`versionadded`/`versionchanged`/`deprecated` — see
[Versions](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Versions.html)
and the released-versions rule in `rst-syntax.md`.

## GUI and Keyboard References `[upstream]`

`:guilabel:` (menu paths with `>`) and `:kbd:` are documented upstream
([Coding guidelines](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CodingGuidelines.html));
note upstream's `:kbd:` idiom is one role per key, e.g. two `:kbd:` roles joined by `+` for Ctrl+S.

## Common Formatting Errors

### Wrong Indentation

```rst
.. note::
  Wrong: only 2 spaces

.. note::
    Correct: 4 spaces
```

### Inconsistent Heading Underlines

```rst
Section
====
Wrong: underline too short

Section
=======
Correct: matches text length
```

### Trailing Whitespace

```rst
This line has trailing spaces.
Wrong: spaces at end

This line is clean.
Correct: no trailing whitespace
```

### Mixed Tabs and Spaces

```rst
..	code-block:: php
Wrong: tab character after ..

..  code-block:: php
Correct: spaces only
```

## No Email Addresses in Documentation `[NR policy]`

**This is a deliberate Netresearch policy, stricter than upstream.** The
official guides.xml reference explicitly allows `mailto:` for
`project-contact` (it is even the documented example). Netresearch forbids it
anyway — do not present this rule as a TYPO3 standard.

**NEVER** include email addresses (`mailto:` links or raw email addresses) in public documentation. This applies to:

- `guides.xml` `project-contact` attribute
- RST page content
- `Includes.rst.txt` substitutions
- README files synced with documentation

**Use instead:** GitHub Issues URL, GitHub Discussions URL, or other public web-based contact channels.

**Why:** Email addresses in public repositories attract spam and expose personal information. GitHub Issues/Discussions provide trackable, public communication channels.

## Pre-Commit Checklist

1. ✅ `.editorconfig` exists in `Documentation/`
2. ✅ All files use UTF-8 encoding
3. ✅ Indentation uses 4 spaces (no tabs)
4. ✅ Lines wrapped at 80 characters where possible
5. ✅ No trailing whitespace
6. ✅ Files end with a newline
7. ✅ Line endings are LF (Unix-style)
8. ✅ Heading underlines match text length
9. ✅ Sentence case for headings
10. ✅ No `mailto:` links or email addresses in documentation

## Editor Configuration

### VS Code

Install the EditorConfig extension. It automatically reads `.editorconfig`.

### PhpStorm / IntelliJ

EditorConfig support is built-in. Enable in Settings > Editor > Code Style.

### Vim

Install `editorconfig-vim` plugin:
```vim
Plug 'editorconfig/editorconfig-vim'
```

## References

- **CGL for ReST files (canonical):** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/CodingGuidelines/Index.html
- **Coding Guidelines (with .editorconfig sample):** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CodingGuidelines.html
- **EditorConfig:** https://editorconfig.org/
