---
name: typo3-docs
description: This skill should be used when creating or updating TYPO3 extension documentation. It provides comprehensive guidance for working with reStructuredText (RST) format, TYPO3-specific directives, official documentation standards, local rendering with Docker, and TYPO3 Intercept deployment. Use this skill for documentation tasks in TYPO3 extension projects, especially when encountering RST files, Documentation/ directories, or when asked to follow TYPO3 documentation guidelines.
---

# TYPO3 Documentation

## Overview

This skill enables creation and maintenance of TYPO3 extension documentation following official TYPO3 documentation standards. It covers RST syntax, TYPO3-specific directives (confval, versionadded, php:method, card-grid), local rendering with Docker, validation procedures, and automated deployment through TYPO3 Intercept.

## When to Use This Skill

Use this skill when:

- Creating new TYPO3 extension documentation
- Updating existing Documentation/*.rst files
- Adding configuration documentation with confval directives
- Documenting version-specific changes with versionadded/versionchanged
- Creating visual navigation with card-grid layouts
- Documenting PHP APIs with php:method directives
- Validating RST syntax and cross-references
- Rendering documentation locally for verification
- Troubleshooting broken cross-references or rendering warnings
- Following TYPO3 documentation best practices

## Documentation Structure

### Three-Tier Documentation System

TYPO3 extensions use a three-tier documentation structure:

**1. Documentation/ (RST Format - Official Published)**
- Official TYPO3 documentation in reStructuredText format
- Published at docs.typo3.org
- Built automatically by TYPO3 Intercept
- Versioned and searchable across all TYPO3 docs
- **This is where to work when using this skill**

**2. claudedocs/ (Markdown - AI Session Context)**
- Temporary session documentation (gitignored)
- Comprehensive project knowledge for AI agents
- Never committed to version control
- **Not relevant for this skill**

**3. Root Documentation (Project Essentials)**
- README.md, CONTRIBUTING.md, SECURITY.md
- Project overview and guidelines
- **Not relevant for this skill**

### Standard Documentation/ Structure

```
Documentation/
├── Index.rst           # Main entry point (required)
├── Settings.cfg        # Documentation metadata (required)
├── Introduction/       # Getting started content
├── Integration/        # Configuration guides
├── CKEditor/          # Feature-specific docs
├── Troubleshooting/   # Problem solving
├── Security/          # Security documentation
└── API/               # PHP API reference
```

## Workflow Decision Tree

**1. New Documentation?**
- Yes → Create Index.rst with card-grid navigation
- No → Go to step 2

**2. Adding Configuration?**
- Yes → Use confval directive (see "Configuration Documentation")
- No → Go to step 3

**3. Version-Specific Feature?**
- Yes → Use versionadded/versionchanged (see "Version Documentation")
- No → Go to step 4

**4. PHP API Documentation?**
- Yes → Use php:method directive (see "PHP API Documentation")
- No → Go to step 5

**5. Visual Navigation?**
- Yes → Use card-grid with stretched-link (see "Card Grid Navigation")
- No → Go to step 6

**6. Cross-References?**
- Yes → Use :ref: labels (see "Cross-References")
- No → Write standard RST content (see references/rst-syntax.md)

**7. Always: Validate and Render**
- Run scripts/validate_docs.sh
- Run scripts/render_docs.sh
- Check for warnings and broken references

## Configuration Documentation

To document configuration values, use the `confval` directive:

```rst
.. confval:: settingName

   :type: boolean
   :Default: true
   :Path: $GLOBALS['TYPO3_CONF_VARS']['EXTENSIONS']['ext_key']['setting']

   Description of the configuration value. Explain what it does,
   when to use it, and any important considerations.
```

**Required Fields:**
- `:type:` - Data type (boolean, string, integer, array, object)
- `:Default:` - Default value (capitalize 'Default')
- `:Path:` - Full path in TYPO3 configuration

**Example:**
```rst
.. confval:: fetchExternalImages

   :type: boolean
   :Default: true
   :Path: $GLOBALS['TYPO3_CONF_VARS']['EXTENSIONS']['rte_ckeditor_image']['fetchExternalImages']

   Controls whether external image URLs are automatically fetched and uploaded
   to the current backend user's upload folder. When enabled, pasting image
   URLs will trigger automatic download and FAL integration.
```

For detailed confval syntax and more examples, see: `references/typo3-directives.md`

## Version Documentation

To document version-specific changes, use version directives:

**New Feature:**
```rst
.. versionadded:: 13.0.0
   The CKEditor plugin now requires ``StyleUtils`` and ``GeneralHtmlSupport``
   dependencies for style functionality.
```

**Changed Behavior:**
```rst
.. versionchanged:: 13.1.0
   Image processing now uses TYPO3's native image processing service.
```

**Deprecated Feature:**
```rst
.. deprecated:: 13.2.0
   The ``oldSetting`` configuration option is deprecated. Use ``newSetting`` instead.
   This option will be removed in version 14.0.0.
```

**Placement:** Place version directives immediately before or after the content they describe.

## PHP API Documentation

To document PHP classes and methods, use the PHP domain directives:

**Method:**
```rst
.. php:method:: infoAction(ServerRequestInterface $request): ResponseInterface

   Retrieves image information and processed file details.

   :param \\Psr\\Http\\Message\\ServerRequestInterface $request: PSR-7 server request
   :returns: JSON response with image data
   :returntype: \\Psr\\Http\\Message\\ResponseInterface
   :throws \\RuntimeException: When file is not found
```

**Class:**
```rst
.. php:class:: SelectImageController

   Main controller for image selection wizard.

   Extends: ``TYPO3\\CMS\\Backend\\Controller\\ElementBrowserController``
```

For complete PHP domain reference, see: `references/typo3-directives.md`

## Card Grid Navigation

To create visual navigation, use card-grid layouts with stretched links:

```rst
.. card-grid::
    :columns: 1
    :columns-md: 2
    :gap: 4
    :card-height: 100

    ..  card:: 📘 Introduction

        The RTE CKEditor Image extension provides comprehensive image handling
        capabilities for CKEditor in TYPO3.

        ..  card-footer:: :ref:`Read more <introduction>`
            :button-style: btn btn-primary stretched-link

    ..  card:: 🔧 Configuration

        Learn how to configure the extension with TSConfig, YAML, and TypoScript
        settings for your specific needs.

        ..  card-footer:: :ref:`Read more <configuration>`
            :button-style: btn btn-secondary stretched-link
```

**Critical Elements:**
- UTF-8 emoji icons in card titles (📘, 🔧, 🎨, 🔍, ⚡, 🛡️, etc.)
- `stretched-link` class in card-footer for full card clickability
- `:ref:` cross-references in card-footer

For complete card-grid reference, see: `references/typo3-directives.md`

## Cross-References

To create internal links, use labels and `:ref:`:

**Create Label:**
```rst
.. _my-section-label:

Section Title
=============
```

**Reference Label:**
```rst
Link to :ref:`my-section-label`
Link with custom text: :ref:`Custom Text <my-section-label>`
```

**TYPO3 Core Documentation:**
```rst
:ref:`t3tsref:start` - TypoScript Reference
:ref:`t3coreapi:fal` - File Abstraction Layer
:ref:`t3tsconfig:pagetsconfig` - Page TSConfig
```

## Validation and Rendering

### Validate Documentation

Use the validation script to check RST syntax and common issues:

```bash
scripts/validate_docs.sh /path/to/project
```

**Checks:**
- RST file existence and count
- Settings.cfg presence
- Index.rst presence
- RST syntax validation
- UTF-8 encoding
- Trailing whitespace
- Common reference issues

### Render Documentation Locally

Use the rendering script to generate HTML output:

```bash
scripts/render_docs.sh /path/to/project
```

**Output:** `Documentation-GENERATED-temp/Index.html`

**View:**
```bash
open Documentation-GENERATED-temp/Index.html
# or
xdg-open Documentation-GENERATED-temp/Index.html
```

**Always render locally before committing to verify:**
- No rendering warnings
- No broken cross-references
- Proper formatting
- Card grids display correctly
- Code blocks render properly

## Common Tasks

### Add New Page

1. Create `Documentation/Section/NewPage.rst`
2. Add to parent `Index.rst` toctree:
   ```rst
   .. toctree::
      :maxdepth: 2

      Introduction/Index
      Section/NewPage
   ```
3. Add label at top: `.. _section-newpage:`
4. Validate: `scripts/validate_docs.sh`
5. Render: `scripts/render_docs.sh`
6. Commit changes

### Update Configuration

1. Find relevant RST file in `Integration/`
2. Add or update `.. confval::` directive
3. Include `:type:`, `:Default:`, `:Path:`
4. Provide clear description
5. Validate and render

### Document Version Changes

1. Add `.. versionadded::` or `.. versionchanged::`
2. Include version number
3. Describe what changed and why
4. Place near relevant content
5. Validate and render

### Fix Cross-References

1. Find broken reference in render warnings
2. Check if target label exists
3. Update reference or create missing label
4. Re-render to verify fix

## Quality Standards

**Before Committing:**
- ✅ No rendering warnings
- ✅ No broken cross-references
- ✅ All confval directives complete
- ✅ Version information for new features
- ✅ Card grids use stretched-link
- ✅ UTF-8 emoji icons in card titles
- ✅ Code blocks specify language
- ✅ Proper heading hierarchy
- ✅ No trailing whitespace

**Documentation Coverage:**
- All public APIs documented
- All configuration options explained
- All features have usage examples
- Troubleshooting for common issues
- Security considerations documented

## TYPO3 Intercept Deployment

**Automatic Publishing:**
- Git push to main/master triggers build
- New version tags trigger build
- Manual trigger via Intercept dashboard

**Build Process:**
1. Intercept detects commit/tag
2. Documentation rendered using render-guides
3. Output published to docs.typo3.org
4. Indexed for search

**Dashboard:** https://intercept.typo3.com/admin/docs/deployments

**Published Result:** https://docs.typo3.org/p/{vendor}/{extension}/main/en-us/

## Best Practices

**DO:**
- Edit existing RST files to update content
- Add new RST files following existing structure
- Use TYPO3-specific directives (confval, versionadded, php:method)
- Include UTF-8 emoji icons in card titles
- Use card-grid layouts with stretched-link
- Cross-reference using `:ref:` labels
- Render locally before committing
- Follow TYPO3 documentation standards

**DON'T:**
- Create markdown files in Documentation/ (RST only)
- Commit claudedocs/ to version control (gitignored)
- Break cross-references by renaming labels
- Use external links for internal docs (use :ref:)
- Skip local rendering
- Mix documentation formats

## Resources

This skill includes comprehensive reference materials and automation scripts:

### references/

**rst-syntax.md:**
Complete RST syntax reference including headings, code blocks, lists, links, tables, admonitions, images, and whitespace rules. Load this when working with basic RST syntax or encountering RST-specific formatting questions.

**typo3-directives.md:**
TYPO3-specific directive reference including confval, version directives, PHP domain, card-grid, intersphinx, and quality checklists. Load this when using TYPO3-specific features or creating specialized documentation elements.

### scripts/

**validate_docs.sh:**
Validates RST syntax, checks for Settings.cfg and Index.rst, detects encoding issues, identifies trailing whitespace, and provides comprehensive validation reporting. Execute this before committing documentation changes.

**render_docs.sh:**
Renders documentation locally using Docker with the official TYPO3 render-guides image. Execute this to verify documentation renders correctly before pushing to version control.

## Additional Resources

**Official Documentation:**
- TYPO3 Documentation Guide: https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/
- RST Reference: https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html
- Rendering with Docker: https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/RenderingDocs/Index.html

**Example Projects:**
- TYPO3 Best Practice Extension: https://github.com/TYPO3BestPractices/tea
- RTE CKEditor Image: https://docs.typo3.org/p/netresearch/rte-ckeditor-image/main/en-us/
