# Documentation Context for AI Assistants

This is the official TYPO3 extension documentation directory in reStructuredText (RST) format.

## Documentation Type

**TYPO3 Extension Documentation** - Published at docs.typo3.org

## Documentation Strategy

<!-- Describe what this documentation covers and its target audience -->
<!-- Example: "End-user guide for content editors using the extension features" -->
<!-- Example: "Technical integration guide for developers implementing custom configurations" -->
<!-- Example: "Complete extension documentation including user guide, configuration reference, and API docs" -->

**Target Audience:**

**Main Topics:**

**Not Covered:** <!-- What is intentionally documented elsewhere -->

## Documentation Framework

- **Format**: reStructuredText (RST)
- **Build System**: TYPO3 Documentation rendering tools
- **Published At**: https://docs.typo3.org/p/[vendor]/[extension]/main/en-us/
- **Automated Build**: TYPO3 Intercept webhook deployment

## File Structure

### Required Files

- `Index.rst` - Main documentation entry point
- `Settings.cfg` - Documentation metadata and configuration

### Common Sections

- `Introduction/` - Getting started, features overview
- `Installation/` - Installation and upgrade guides
- `Configuration/` - TypoScript, extension configuration
- `Integration/` - Integration with other systems
- `Editor/` - User guide for content editors
- `Developer/` - Developer documentation
- `API/` - PHP API reference documentation
- `Troubleshooting/` - Common issues and solutions

## TYPO3-Specific Directives

### Configuration Documentation

Use `confval` for configuration options:

```rst
.. confval:: myOption
   :name: ext-myext-myoption
   :type: string
   :Default: 'default value'

   Description of the configuration option.
```

### Version Documentation

Document version-specific features:

```rst
.. versionadded:: 2.0
   Support for feature X was added.

.. versionchanged:: 2.1
   Behavior changed to improve performance.

.. deprecated:: 2.2
   This feature will be removed in version 3.0.
```

### PHP API Documentation

Document PHP methods and classes:

```rst
.. php:method:: processData(array $data): array

   Process the provided data array.

   :param array $data: The input data
   :returns: Processed data array
```

### Card Grid Navigation

Create visual navigation with card grids:

```rst
.. card-grid::
   :columns: 2
   :gap: 4

   .. card:: :ref:`Installation <installation>`

      How to install and configure the extension.

   .. card:: :ref:`Configuration <configuration>`

      TypoScript and extension configuration reference.
```

## Cross-References

### Internal References

```rst
.. _my-section-label:

Section Title
=============

Reference it with :ref:`my-section-label` or :ref:`custom text <my-section-label>`
```

### External TYPO3 Docs

```rst
:ref:`t3coreapi:caching` - Reference to TYPO3 Core API docs
:ref:`t3tsref:stdwrap` - Reference to TypoScript Reference
```

### Code References

```rst
:php:`ClassName` - PHP class
:ts:`config.tx_myext` - TypoScript
:file:`Configuration/TCA/` - File path
:bash:`composer require` - Shell command
```

## RST Syntax Patterns

### Headings

```rst
=============
Document Title (Level 1 - only once per file)
=============

Section (Level 2)
=================

Subsection (Level 3)
--------------------

Subsubsection (Level 4)
^^^^^^^^^^^^^^^^^^^^^^^
```

### Lists

```rst
Bullet list:

*  Item 1
*  Item 2

Numbered list:

#. First
#. Second

Definition list:

Term
   Definition of the term.
```

### Code Blocks

```rst
.. code-block:: php

   <?php
   $variable = 'value';

.. code-block:: typoscript

   plugin.tx_myext {
      setting = value
   }
```

### Admonitions

```rst
.. note::
   Important information for users.

.. warning::
   Critical warning about potential issues.

.. tip::
   Helpful suggestion or best practice.
```

## Local Rendering

### Render Documentation

```bash
# Using Docker (recommended)
cd Documentation
docker run --rm --pull always \
  -v $(pwd):/project \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation

# View output
open Documentation-GENERATED-temp/Result/project/0.0.0/Index.html
```

### Validate Documentation

```bash
# Check for syntax errors and warnings
scripts/validate_docs.sh

# Common issues to check:
# - Broken cross-references
# - Invalid directive syntax
# - Heading level inconsistencies
# - Missing required files
```

## Deployment

### TYPO3 Intercept Webhook

Documentation is automatically built and deployed when:

1. Changes pushed to `main` branch
2. Webhook configured in Settings.cfg
3. TYPO3 Intercept receives notification
4. Documentation rebuilt and published

### Settings.cfg Configuration

```ini
[general]
project = Extension Name
version = 1.0
release = 1.0.0
copyright = 2024

[html_theme_options]
project_repository = https://github.com/vendor/extension
```

## Best Practices

1. **Clear Structure**: Organize docs by audience (users vs developers)
2. **Card Grids**: Use card-grid for main navigation pages
3. **Cross-References**: Use :ref: labels instead of hardcoded paths
4. **Code Examples**: Always include working code examples
5. **Version Markers**: Document version-specific features
6. **Screenshots**: Place in `Images/` directory, reference with `.. image::`
7. **Validation**: Always validate before committing
8. **Local Preview**: Render locally to verify appearance

## Common Issues

**Broken cross-references:**
- Verify label exists: `.. _label-name:`
- Check reference syntax: `:ref:`label-name``
- Ensure label is unique

**Rendering warnings:**
- Check heading level consistency (no skipped levels)
- Verify directive syntax (proper indentation)
- Validate code block languages are supported

**Webhook not triggering:**
- Check Settings.cfg has correct repository URL
- Verify webhook configured in repository settings
- Check TYPO3 Intercept logs for errors

## Resources

- [TYPO3 Documentation Guide](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/)
- [RST Syntax Reference](~/.claude/skills/typo3-docs/references/rst-syntax.md)
- [TYPO3 Directives](~/.claude/skills/typo3-docs/references/typo3-directives.md)
- [Card Grids](~/.claude/skills/typo3-docs/references/card-grids.md)
- [Cross-References](~/.claude/skills/typo3-docs/references/cross-references.md)
- [Local Rendering](~/.claude/skills/typo3-docs/references/local-rendering.md)
