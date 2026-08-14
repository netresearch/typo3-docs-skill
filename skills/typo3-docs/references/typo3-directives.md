# TYPO3-Specific Directives

Routing, observed failure modes and labelled house rules for TYPO3 RST
directives. Directive syntax itself lives upstream — **canonical source (wins
on conflict, see `canonical-sources.md`):**
[reStructuredText reference](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Index.html)
`[upstream]` with per-topic subpages (Confval, Phpdomain, Cards, Tabs,
Versions, Diagrams, …).

## Permalink Anchors (Labels)

Every section in TYPO3 documentation **MUST** have a permalink anchor (label) for deep linking.

`[NR policy]` The MUST and the hierarchical-prefix naming below are stricter
than upstream: [Anchors](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Links/Anchors.html)
says anchors *should* be alphanumeric-plus-hyphen (derived from the
headline), and the CGL says each headline *should* have a unique anchor.
Upstream also treats published anchors as permanent — once a page reaches
`main`, its anchors must keep working. Do not present the stricter parts as a
TYPO3 standard.

**Syntax:**
```rst
..  _section-name-label:

Section heading
===============
```

**Requirements:**
- Place label **immediately before** the section heading (no blank line between)
- Use **lowercase** with hyphens (`-`) as separators
- Use **descriptive, hierarchical names** reflecting the document structure
- Labels enable `:ref:` cross-references and URL anchors

**Example (hierarchical prefixes):**
```rst
..  _crowdin-mass-approval:

========================
Mass approval on Crowdin
========================

..  _crowdin-mass-approval-workflow:

Crowdin API workflow
====================

..  _crowdin-mass-approval-workflow-authentication:

Authentication
--------------
```

**Naming Convention:**
- Start with document/topic prefix: `crowdin-mass-approval`
- Add section hierarchy: `crowdin-mass-approval-workflow`
- Add subsection: `crowdin-mass-approval-implementation-usage`
- This creates predictable, navigable anchor URLs

**Benefits:**
- Direct linking to specific sections
- Stable URLs for documentation references
- Cross-document `:ref:` linking
- Search engine indexability

## Configuration Values (confval)

Full directive reference (options `:type:`, `:default:`, `:required:`,
`:name:`, `:class:`, `noindex`, plus free-form attributes, and
`confval-menu`):
[Confval](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Confval.html)
`[upstream]`.

One nuance this skill grades stricter: upstream requires `:name:` only when
the confval title is not unique within the manual; always setting it is
`[NR policy]` (stable anchors), not an upstream requirement.

### Two-Level Configuration Pattern

**Pattern:** Site-wide configuration with per-item override capability

Many TYPO3 features support two-level configuration:
1. **Site-wide default** via TypoScript
2. **Per-item override** via attributes or UI

**When to use:**
- Features where editors need item-specific control
- Mixed content pages (some items use site-wide, others override)
- Configuration that varies by context or workflow

**Documentation Structure:**

```text
## Configuration

The noScale feature can be configured at two levels:

1. **Site-wide (TypoScript)** - Default behavior for all images
2. **Per-image (Editor)** - Override for specific images

### Site-Wide Configuration

.. confval:: noScale

   :type: boolean
   :Default: false (auto-optimization enabled)
   :Path: lib.parseFunc_RTE.tags.img.noScale

   Controls whether images are automatically optimized or used as original files.
   When enabled, all images skip TYPO3's image processing.

   **Configuration Priority:**

   - **Per-image setting** (data-noscale attribute) takes precedence
   - **Site-wide setting** (TypoScript) is the fallback
   - **Default behavior** when neither is set

   **Enable for all images:**

   .. code-block:: typoscript
      :caption: setup.typoscript

      lib.parseFunc_RTE {
          tags.img {
              noScale = 1  # All images use original files
          }
      }

### Per-Image Override

.. versionadded:: 13.0.0
   Editors can now enable noScale for individual images using the CKEditor
   image dialog, overriding the site-wide TypoScript setting.

**How to Use:**

1. Insert or edit an image in CKEditor
2. Open the image dialog (double-click or select + click insert image button)
3. Check "Use original file (noScale)" checkbox
4. Save the image

**Configuration Priority:**

- **Per-image setting** (data-noscale attribute) overrides site-wide configuration
- If unchecked: Falls back to site-wide TypoScript setting
- If no site-wide setting: Default behavior (auto-optimization)

**Workflow Benefits:**

- **Mixed Content**: Some images original, others optimized on same page
- **Editorial Control**: Editors decide per-image without developer intervention
- **Flexibility**: Override site-wide settings for specific images
- **Newsletter Integration**: Mark high-quality images for email

**Technical Implementation:**

.. code-block:: html

   <!-- Per-image override via data attribute -->
   <img src="image.jpg" data-noscale="true" />
```

**Example from t3x-rte_ckeditor_image:**

The noScale feature uses this pattern:
- **Site-wide**: `lib.parseFunc_RTE.tags.img.noScale = 1` in TypoScript
- **Per-image**: Checkbox in CKEditor dialog sets `data-noscale` attribute
- **Priority**: Per-image attribute overrides TypoScript setting

**Documentation Benefits:**

✅ Clear separation of site-wide vs per-item configuration
✅ Explicit priority/precedence rules documented
✅ Workflow guidance for editors
✅ Technical implementation details for developers
✅ Use case explanations (mixed content, newsletters)

## Version Information

`versionadded` / `versionchanged` / `deprecated`:
[Versions](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Versions.html)
`[upstream]` (also shows nesting them inside admonitions). Skill rule that is
NOT upstream (`[regression]`, from v13 doc reviews): only reference
**released** versions — verify against `git tag --list` and `ext_emconf.php`
before writing a version directive (see `rst-syntax.md`).

## PHP Domain

Directives (`php:namespace`, `php:class`, `php:interface`, `php:trait`,
`php:method`, `php:attr`, `php:const`, `php:exc`) and cross-reference roles:
[PHP domain](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Phpdomain.html)
`[upstream]`. Document only public, non-internal entities.

### Method Signature Limitations

The `php:method` directive has strict syntax requirements that differ from PHP 8+ syntax.

**Nullable Return Types:**
```rst
# ❌ WRONG - Parser rejects ?string and string|null in signature
..  php:method:: retrieve(string $identifier): ?string
..  php:method:: retrieve(string $identifier): string|null

# ✅ CORRECT - Use :returntype: annotation instead
..  php:method:: retrieve(string $identifier)

   Retrieve a secret from the vault.

   :param string $identifier: The secret identifier
   :returns: The decrypted secret value or null if not found
   :returntype: string|null
```

**Nullable Parameters:**
```rst
# ❌ WRONG - ?string syntax in parameters
..  php:method:: list(?string $pattern): array

# ✅ CORRECT - Use = null for nullable parameters
..  php:method:: list(string $pattern = null): array

   :param string|null $pattern: Optional pattern to filter
```

**Union Types:**
```rst
# ❌ WRONG - Union types in signature
..  php:method:: process(string|array $data): ResponseInterface

# ✅ CORRECT - Simplify signature, document types in :param:
..  php:method:: process($data): ResponseInterface

   :param string|array $data: Data to process
```

**Why this matters:**
- The Sphinx PHP domain parser uses older syntax
- Build will fail or produce warnings with modern PHP type syntax
- Use `:returntype:` and `:param type:` annotations for complex types

### PHP Domain Best Practices

1. **Use full namespaces** in `:returntype:` and `:throws:`
2. **Document only public methods** - skip internal/private
3. **Include meaningful descriptions** - not just type signatures
4. **Link related classes** using `:php:` role in descriptions

## Card Grids

`card-grid`, `card`, `card-footer` (incl. `:button-style:` with
`stretched-link`) and `card-image` (`:alt:`, `:position:`):
[Cards](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Cards.html)
`[upstream]`.

## Intersphinx References

The standard inventories (18 ids incl. `t3coreapi`, `t3tca`, `t3tsref`,
`changelog`, `h2document`) are **auto-provided** — listing them in
`guides.xml` is no longer necessary:
[Interlink inventories](https://docs.typo3.org/permalink/t3renderguides:interlink-inventories)
`[upstream]`. Usage syntax: see `text-roles-inline-code.md` and
[Cross-references](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Links/Documentation.html).

## Index and Glossary

Generic Sphinx (`.. index::`, `.. glossary::`) — not part of the TYPO3 RST
reference; see the Sphinx directives documentation if needed.

## Tabs

Use `..  tabs::` with inner `..  group-tab::` (synchronized across the page):
[Tabs](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Tabs.html)
`[upstream]`. An earlier version of this section showed `..  tab::`, which is
not documented upstream — see `content-directives.md` for the correct form.

## Special TYPO3 Directives

`include` → [Including files](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Menus/IncludingFiles.html);
`directory-tree` (incl. `:level:`, `:show-file-icons:`) → [Directory tree](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Lists/DirectoryTree.html);
`youtube` → [YouTube videos](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/YoutubeVideos.html);
`:download:` is generic Sphinx. All `[upstream]`.

## PHP Code CGL Compliance

`[NR policy]` PHP code examples in documentation MUST pass CGL (Coding
Guidelines) checks. This is a house quality rule — no upstream page states
that documentation builds enforce CGL on embedded examples, and `make
fix-cgl` is a project-local target. Rationale: examples get copied verbatim;
non-compliant examples propagate non-compliant code.

**Validation:**
```bash
# Run CGL check locally before committing
make fix-cgl

# Or using Docker/DDEV
ddev exec make fix-cgl
```

**Common CGL Issues:**
- Missing/incorrect spacing around operators
- Improper array formatting
- Wrong indentation (4 spaces, not tabs)
- Missing blank lines between functions
- Line length exceeding limits

**Example Fix:**
```php
// ❌ Before (CGL violation)
function getItems($id){return $this->items[$id];}

// ✅ After (CGL compliant)
function getItems(int $id): array
{
    return $this->items[$id];
}
```

**Best Practice Workflow:**
1. Write code examples following PSR-12 and TYPO3 CGL
2. Run `make fix-cgl` before committing
3. Fix any reported issues before pushing
4. If build fails on CI, check CGL compliance first

## PlantUML Diagrams

The `..  uml::` directive IS officially rendered (PlantUML is integrated into
the toolchain), in both inline and external-file form with `:caption:`,
`:align:`, `:width:`:
[Diagrams](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Graphics/Diagrams.html)
`[upstream]`. PlantUML language syntax: https://plantuml.com/. Two skill
rules survive (`[regression]`): `code-block:: plantuml` has no highlighter
and fails the render log (checkpoint TD-47), and hand-authored SVG is
preferred where reviewable diffs matter (see `screenshots.md`).

## Best Practices

1. **Use confval for all configuration**: Document every setting with proper metadata
2. **Version everything**: Add versionadded/versionchanged for all version-specific features
3. **Cross-reference liberally**: Link to related documentation with :ref:
4. **Card grids for navigation**: Use card-grid layouts for Index.rst files
5. **Emoji icons in titles**: Use UTF-8 emojis in card titles for visual appeal
6. **Stretched links**: Always use `stretched-link` class in card-footer for full card clicks
7. **PHP domain for APIs**: Document all public methods with php:method
8. **Intersphinx for core**: Reference TYPO3 core docs with intersphinx

## Quality Checklist

✅ All configuration options documented with confval
✅ Version information added for all version-specific features
✅ Cross-references work (no broken :ref: links)
✅ Card grids use stretched-link in card-footer
✅ UTF-8 emoji icons in card titles
✅ PHP API documented with php:method
✅ Code blocks specify language
✅ Admonitions used appropriately
✅ Local render shows no warnings
✅ All headings have proper underlines
✅ **Sentence case** used for all headlines (not Title Case)
✅ **Permalink anchors** (`.. _label:`) before every section heading
✅ **List punctuation**: all list items end with periods
✅ **CGL compliance**: PHP code examples pass `make fix-cgl`

## guides.xml Configuration

Owned by `references/guides-xml.md` (extraction workflow, labelled NR
policies) with the upstream
[guides.xml reference](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/GuidesXml.html)
as canonical source — this file does not duplicate it. Two observed failure
modes worth keeping (`[regression]`): a `<theme>` **child element** fails the
build with `Invalid type for path guides.theme` (and a `theme` attribute is
unnecessary — the TYPO3 theme comes from `<extension class=…>`); the
`xsi:schemaLocation` format is `namespace-URI schema-path`, where the
namespace is only an identifier and the schema path is relative to
`Documentation/`.

## References

- **TYPO3 Documentation Guide:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/
- **Confval Reference:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Confval.html
- **Version Directives:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Versions.html
- **PHP Domain:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Code/Phpdomain.html
- **Card Grid:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Content/Cards.html
