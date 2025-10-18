# RST Syntax Reference

Complete reStructuredText syntax reference for TYPO3 documentation.

## Headings

```rst
===========
Page Title
===========

Section
=======

Subsection
----------

Subsubsection
~~~~~~~~~~~~~

Paragraph
^^^^^^^^^
```

**Rules:**
- Page titles: `=` above and below (11 characters minimum)
- Sections: `=` below
- Subsections: `-` below
- Subsubsections: `~` below
- Paragraphs: `^` below
- **CRITICAL**: Underline must be exactly the same length as the title text

## Inline Formatting

```rst
*italic text*
**bold text**
``code or literal text``
```

## Code Blocks

**PHP:**
```rst
.. code-block:: php

   <?php
   $code = 'example';
```

**YAML:**
```rst
.. code-block:: yaml

   setting: value
   nested:
     item: value
```

**TypoScript:**
```rst
.. code-block:: typoscript

   config.tx_extension.setting = value
```

**Bash:**
```rst
.. code-block:: bash

   composer install
```

**JavaScript:**
```rst
.. code-block:: javascript

   const example = 'value';
```

## Lists

**Bullet Lists:**
```rst
- First item
- Second item

  - Nested item
  - Another nested
```

**Numbered Lists:**
```rst
1. First item
2. Second item
3. Third item
```

**Definition Lists:**
```rst
term
   Definition of the term

another term
   Definition of another term
```

## Links

**External Links:**
```rst
`Link text <https://example.com>`__
```

**Internal Cross-References:**
```rst
.. _my-label:

Section Title
=============

Link to :ref:`my-label`
Link with custom text: :ref:`Custom Text <my-label>`
```

**Documentation Links:**
```rst
:ref:`t3tsref:start` (TYPO3 TS Reference)
:ref:`t3coreapi:start` (TYPO3 Core API)
```

## Tables

**Simple Table:**
```rst
===========  ===========
Column 1     Column 2
===========  ===========
Row 1 Col 1  Row 1 Col 2
Row 2 Col 1  Row 2 Col 2
===========  ===========
```

**Grid Table:**
```rst
+------------+------------+
| Header 1   | Header 2   |
+============+============+
| Cell 1     | Cell 2     |
+------------+------------+
```

**List Table:**
```rst
.. list-table:: Table Title
   :header-rows: 1
   :widths: 20 80

   * - Column 1
     - Column 2
   * - Value 1
     - Value 2
```

## Admonitions

```rst
.. note::
   Additional information

.. important::
   Important notice

.. warning::
   Warning message

.. attention::
   Attention required

.. tip::
   Helpful tip

.. caution::
   Caution advised
```

## Images

```rst
.. image:: ../Images/screenshot.png
   :alt: Alternative text
   :width: 600px
   :class: with-shadow
```

**Figure with Caption:**
```rst
.. figure:: ../Images/screenshot.png
   :alt: Alternative text
   :width: 600px

   This is the caption text
```

## Table of Contents

**In-page TOC:**
```rst
.. contents::
   :local:
   :depth: 2
```

**Toctree (document hierarchy):**
```rst
.. toctree::
   :maxdepth: 2
   :titlesonly:
   :hidden:

   Introduction/Index
   Configuration/Index
   API/Index
```

## Comments

```rst
.. This is a comment
   It can span multiple lines
   and will not appear in the output
```

## Line Blocks

```rst
| Line 1
| Line 2
| Line 3
```

## Substitutions

```rst
.. |TYPO3| replace:: TYPO3 CMS

Using |TYPO3| in documentation...
```

## Special Characters

```rst
\*literal asterisk\*
```

## Whitespace Rules

1. **Blank lines**: Required before and after directives
2. **Indentation**: Use 3 spaces for directive content
3. **No trailing whitespace**: Remove all trailing spaces
4. **Consistent indentation**: Maintain same level within blocks

## Common Mistakes

❌ **Wrong underline length:**
```rst
Section
====  # Too short
```

❌ **Missing blank lines:**
```rst
.. code-block:: php
   $code = 'example';  # No blank line before content
```

❌ **Incorrect indentation:**
```rst
.. note::
  Text  # Only 2 spaces instead of 3
```

✅ **Correct:**
```rst
Section
=======

.. code-block:: php

   $code = 'example';

.. note::
   Text with 3-space indentation
```

## References

- **Sphinx RST Guide:** https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html
- **Docutils RST:** https://docutils.sourceforge.io/rst.html
- **TYPO3 Documentation Guide:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/
