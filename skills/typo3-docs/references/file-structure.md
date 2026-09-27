# TYPO3 Documentation File Structure

Complete reference for TYPO3 extension documentation file structure.

Based on: https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/FileStructure.html

## Minimum Prerequisites

Entry points (valid `composer.json` + `Documentation/Index.rst`|`Index.md`
or `README.rst`|`README.md`), required files, `Index.rst` in every
directory, CamelCase naming, `.rst.txt` includes, underscore-prefixed
snippets, `Sitemap.rst`, single-file documentation:
[File structure](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/FileStructure.html)
`[upstream]` — canonical, wins on conflict (see `canonical-sources.md`).

## Full Documentation Structure

```
project-root/
├── composer.json              # Required for rendering
├── README.md                  # Project overview (synced with Documentation/)
└── Documentation/
    ├── guides.xml             # Metadata and rendering configuration
    ├── Index.rst              # Entry point with general info and toctree
    ├── Sitemap.rst            # Auto-populated site structure (optional)
    ├── Includes.rst.txt       # Central includes for all pages (optional)
    ├── Introduction/
    │   └── Index.rst          # Required in every subdirectory
    ├── Installation/
    │   └── Index.rst
    ├── Configuration/
    │   └── Index.rst
    ├── Usage/
    │   └── Index.rst
    ├── Developer/
    │   ├── Index.rst
    │   ├── Api.rst            # Additional pages in CamelCase
    │   ├── Commands.rst
    │   └── _codesnippets/     # Code examples (underscore prefix)
    │       ├── _Example.php
    │       └── _Services.yaml
    └── Images/                # Screenshots and diagrams
        └── screenshot.png
```

## Page Length Limits `[heuristic]`

**Aim for at most ~250 lines per RST file; split longer pages into
sub-pages.** This is a Netresearch quality heuristic for focused,
navigable pages — **no upstream limit exists**, so never present it as a
TYPO3 standard or reject content solely for exceeding it.

### Splitting Pattern

```
# BEFORE: One huge file
Documentation/
├── Configuration/
│   └── Index.rst          # 456 lines — TOO LONG

# AFTER: Split into focused sub-pages
Documentation/
├── Configuration/
│   ├── Index.rst          # Overview + toctree (~30 lines)
│   ├── ProviderFields.rst # Provider config reference
│   ├── ModelFields.rst    # Model config reference
│   ├── ConfigFields.rst   # LLM configuration fields
│   └── Security.rst       # Security, caching, logging
```

### Sub-Page Requirements

Each sub-page MUST:
- Focus on ONE topic
- Be independently navigable
- Have proper heading hierarchy
- Cross-reference related pages with `:ref:`

The `Index.rst` becomes a short overview with `toctree`, NOT a content dumping ground.

### Checking Page Length

```bash
# Find RST files exceeding 250 lines
find Documentation/ -name "*.rst" -exec awk 'END{if(NR>250) print FILENAME": "NR" lines"}' {} \;
```

## Directory Structure Rules

### Index.rst in Every Directory

`[upstream]` — every directory shall have an `Index.rst` (default page,
version-switch fallback, toctree container); see the File structure page
linked above. Checked by TD-19.

### Standard Directory Names `[heuristic]`

Upstream shows these names only as toctree examples, not as a named
convention — this table is the NR default layout:

| Directory | Content |
|-----------|---------|
| `Introduction/` | What the extension does, features, requirements |
| `Installation/` | Composer installation, setup steps |
| `Configuration/` | Extension settings, TypoScript, TSconfig |
| `Usage/` | How to use the extension, examples |
| `Developer/` | API reference, extending, events |
| `Security/` | Security considerations (if applicable) |
| `Changelog/` | Version history (if applicable) |
| `Images/` | Screenshots and diagrams |

## guides.xml Configuration

Owned by `references/guides-xml.md` (template, extraction workflow, labelled
NR policies; no `theme` attribute — the TYPO3 theme comes from
`<extension class=…>`), with the upstream
[guides.xml reference](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/GuidesXml.html)
as canonical source. Not duplicated here.

## Includes.rst.txt

Included at the top of every RST file:
```rst
.. include:: /Includes.rst.txt
```

**Do not put substitutions or hyperlink targets in it.** render-guides does
not carry a `.. |name| replace::` definition or a `.. _name: URL` target from
an included file into the page that includes it. Measured with render-guides
0.40.2 (`ghcr.io/typo3-documentation/render-guides@sha256:52f3b521…`, the
digest `netresearch/typo3-ci-workflows` `docs.yml` pins) and with `:latest` of
2026-09-23:

- `.. include:: /Includes.rst.txt`, `.. include:: ../Includes.rst.txt` and an
  included `.rst` file all behave the same;
- the page renders the literal text `|extension_key|`, and the log says
  `app.WARNING: No replacement was found for variable |extension_key|`;
- a link to a target defined in the include renders as an invalid link
  (`Reference vendor-website_ could not be resolved`).

What works instead:

- write the value (`my_extension`) — the normal case;
- when one page repeats a value, define the substitution on that page:

  ```rst
  .. |extension_key| replace:: my_extension
  ```

- `|release|`, `|version|`, `|project|` and `|today|` are built in: the first
  three come from `guides.xml` `<project>`, and none needs a definition.

TD-46 reports a page that uses a substitution only an included file defines.

## Validation Checklist

Before committing documentation:

1. ✅ `composer.json` exists in project root
2. ✅ `Documentation/guides.xml` exists with valid configuration
3. ✅ `Documentation/Index.rst` exists as entry point
4. ✅ Every subdirectory has an `Index.rst` file
5. ✅ All directories and files use CamelCase naming
6. ✅ Included files use `.rst.txt` extension
7. ✅ Code snippet files start with underscore
8. ✅ `.. include:: /Includes.rst.txt` at top of every RST file
9. ✅ Pages stay near the ~250-line heuristic (split into sub-pages if needed) `[heuristic]`

## Common Mistakes

### Missing Index.rst

❌ **Wrong:**
```
Documentation/
├── Configuration/
│   └── Settings.rst    # No Index.rst!
```

✅ **Correct:**
```
Documentation/
├── Configuration/
│   ├── Index.rst       # Required!
│   └── Settings.rst
```

### Wrong File Naming

❌ **Wrong:**
```
Documentation/
├── configuration/      # lowercase
│   └── index.rst       # lowercase
```

✅ **Correct:**
```
Documentation/
├── Configuration/      # CamelCase
│   └── Index.rst       # CamelCase
```

## References

- **TYPO3 File Structure:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/FileStructure.html
- **guides.xml Reference:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/GuidesXml.html
