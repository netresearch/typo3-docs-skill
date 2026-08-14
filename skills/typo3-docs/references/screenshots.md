# Screenshots Reference

Creating and inserting screenshots in TYPO3 documentation. Canonical source:
[Guidelines for images](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/GuidelinesForImages.html)
`[upstream]` — on conflict the live manual wins. The viewport/iframe sections
below are `[regression]` knowledge from observed agent failures; that is this
file's real value.

## When to Add Screenshots

**Before adding a screenshot, consider if one is necessary.** Each screenshot requires ongoing maintenance when the UI changes.

### Screenshots ARE Appropriate For

- **Backend module interfaces** - Show where to find settings
- **Configuration screens** - Extension configuration, site settings
- **Complex UI workflows** - Multi-step processes that are hard to describe
- **Form configurations** - TCA forms, FlexForm settings
- **Visual results** - Frontend output that demonstrates a feature
- **Error messages** - Help users identify specific error states

### Screenshots Are NOT Needed For

- Simple button clicks or menu selections (use `:guilabel:` instead)
- Code that can be shown in code blocks
- Standard TYPO3 interfaces that haven't changed
- Information easily conveyed in text

## Image Requirements

### Format

| Type | Format |
|------|--------|
| Screenshots | **PNG or AVIF** `[upstream]`; PNG preferred for consistency `[NR policy]` |
| Diagrams | SVG preferred, PNG acceptable |
| Photos | PNG (or AVIF) |

### Dimensions

| Screenshot Type | Dimensions |
|-----------------|------------|
| Full-page screenshots | 1400 x 1050 pixels |
| Cropped screenshots | As small as practical while showing context |

**Best Practice:** Crop to show only relevant portions rather than entire pages.

### Capture Viewport

Resize the browser to **at least 1440 x 1050** before capturing backend
screenshots. Narrow viewports (≈780px) collapse the TYPO3 module menu, truncate
table columns, and cut off modal backgrounds — the result reads as "missing
context" and gets rejected in review.

```js
// Playwright (the Playwright MCP exposes this as browser_resize, same dimensions)
await page.setViewportSize({ width: 1440, height: 1050 });
```

Capture at the wider viewport, then crop the width down to the 1400px target —
the 40px of slack is why the floor is 1440, not 1400. Don't shrink the window to crop.

**Backend module content lives inside an `iframe` — `fullPage` won't capture it.**
The TYPO3 backend renders each module in an iframe that scrolls internally, so a
`fullPage: true` screenshot captures only the outer document (≈ the viewport
height) and clips the module's lower content — trace output, a completed form,
the answer panel. To capture a tall module view (e.g. a config form *and* its
result) in one shot, make the **viewport itself tall** and take a normal
(non-fullPage) screenshot:

```js
// Capture config + output together: tall viewport, NOT fullPage.
await page.setViewportSize({ width: 1440, height: 1750 });
await page.screenshot({ path: 'Documentation/Images/Usage/ModuleRun.png' }); // no fullPage
```

Verify the result height afterwards — a 1440×900 file when you expected a long
page means `fullPage` silently caught only the outer frame.

### File Location `[NR policy]`

Store images under `Documentation/Images/`, organized by section
(`Images/Configuration/…`, `Images/Usage/…`, CamelCase filenames). Note:
upstream examples use `/_Images/`; both work — this skill deliberately picks
`Documentation/Images/` for consistency across NR extensions (checkpoint
TD-12).

## TYPO3 Backend Setup and Screenshot Container

Backend settings (light mode, modern look, default installation on a
Composer-based latest LTS or dev-main, `j.doe` user) and the
`linawolf/typo3-screenshots` container incl. extension installation and
reset:
[Guidelines for images](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/GuidelinesForImages.html)
and
[Screenshot container](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ScreenshotContainer/Index.html)
`[upstream]`.

## RST Image Directives, CSS Classes, Zoom

`image`/`figure` syntax (`:alt:` required; `:width:`, `:scale:`, `:class:`,
`:align:`, `:target:`), the theme CSS classes (`with-shadow`, `with-border`,
`float-left`, `float-right`) and the four zoom modes (`lightbox`, `gallery`,
`inline`, `lens` with `:gallery:`, `:zoom-indicator:`, `:zoom-factor:`,
render-guides 0.36.0+, keyboard/ARIA/reduced-motion support):
[Images](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Graphics/Images.html)
and
[Image zoom](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Graphics/ImageZoom.html)
`[upstream]`. House default (`[NR policy]`): `:zoom: lightbox` +
`:class: with-border with-shadow` on screenshots.

## Annotations

When annotating screenshots with boxes, arrows, or numbers:

### Contrast Requirements

Use sufficient contrast to ensure annotations are visible:
- Across different devices and screens
- For readers with color vision differences
- Against varying background colors in the screenshot

### Recommended Annotation Colors `[NR policy]`

House palette — not a TYPO3 convention (the manual prescribes no annotation
colors; `#FF8700` is the TYPO3 brand orange used by choice):

| Element | Color | Hex |
|---------|-------|-----|
| Highlight boxes | TYPO3 brand orange | `#FF8700` |
| Arrows/lines | Dark gray | `#333333` |
| Numbers/labels | White on dark background | `#FFFFFF` on `#333333` |

### Annotation Tools

- **macOS**: Preview, Skitch, CleanShot X
- **Windows**: Snagit, Greenshot, ShareX
- **Linux**: Flameshot, Shutter
- **Cross-platform**: GIMP, Inkscape (for SVG)

## Alt Text Guidelines

Alt text is **required** for all images. Write descriptive alt text that:

1. **Describes what the image shows** - Not just "screenshot"
2. **Includes key information visible in the image** - Field names, values shown
3. **Is concise but complete** - Typically 10-30 words

### Examples

```rst
.. Bad alt text:
.. image:: screenshot.png
   :alt: Screenshot

.. Good alt text:
.. image:: /Images/Configuration/VaultSettings.png
   :alt: Extension configuration showing Master Key Path field set to /var/secrets/master.key
```

## Suggesting Screenshots in Documentation

When writing documentation, suggest screenshots for:

1. **New features** - Visual introduction helps users understand
2. **Configuration screens** - Show where settings are located
3. **Complex workflows** - Multi-step processes benefit from visuals
4. **Before/after comparisons** - Show the result of configuration changes
5. **Error states** - Help users identify problems

### Template Comment for Missing Screenshots

```rst
.. todo::
   Add screenshot of the backend module showing the secret list view.
   Dimensions: 1400x1050 or cropped to relevant area.
   Settings: Light mode, j.doe user, clean installation.
```

## Pre-Commit Checklist for Screenshots

1. ✅ **Format**: PNG (or AVIF) for all screenshots
2. ✅ **Dimensions**: 1400x1050 or appropriately cropped
3. ✅ **Backend setup**: Light mode, modern look, j.doe user
4. ✅ **Alt text**: Descriptive alt text provided
5. ✅ **File location**: Stored in `Documentation/Images/` with proper organization
6. ✅ **File naming**: CamelCase, descriptive names (e.g., `ExtensionSettings.png`)
7. ✅ **Annotations**: Sufficient contrast for accessibility
8. ✅ **Necessity**: Screenshot genuinely adds value vs. text description

## Diagrams: commit SVG, not PNG

A screenshot records a UI you do not control. A **diagram** is authored, and the
tradeoffs are the opposite ones.

Commit diagrams as SVG:

- It is text, so a reviewer sees the change in the diff instead of a binary
  blob swap. A wrong label is caught in review rather than shipped.
- It scales, and the same file serves every viewport.
- No build step and no generator dependency for the SVG itself. Two distinct
  PlantUML facts, do not conflate them: a `.. code-block:: plantuml` is not a
  diagram — there is no `plantuml` *highlighter*, and every render emits
  `Language "plantuml" is not available to highlight code`. The `.. uml::`
  *directive* however IS officially rendered (PlantUML is integrated into the
  toolchain — see
  [Diagrams](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ReStructuredText/Graphics/Diagrams.html)).
  Hand-authored SVG remains preferable where reviewable diffs matter.

```rst
..  figure:: /Images/diagram-streaming-flow.svg
    :alt: Streaming: the prompt is screened, the budget is checked, and each
        chunk passes a redaction window before the Generator yields it.
    :class: with-border

    Request path down the left, chunk path back up the right.
```

`render-guides` copies referenced images to `Images/` in the output tree, not to
`_images/` — check there when verifying that a figure resolved:

```bash
docker run --rm --user $(id -u):$(id -g) -v "$(pwd)":/project -w /project \
  ghcr.io/typo3-documentation/render-guides:latest --config=Documentation --no-progress
find Documentation-GENERATED-temp -name 'diagram-*.svg'
grep -oh 'diagram-[a-z-]*\.svg' Documentation-GENERATED-temp/**/*.html | sort -u
```

Two things worth doing while authoring:

- **Put an `aria-label` on the `<svg>` as well as the `:alt:` on the figure.**
  The `:alt:` serves the RST; the `aria-label` travels with the file if it is
  ever embedded elsewhere.
- **Trace the diagram against the code before drawing it.** A diagram is a claim
  about how the system works, and it ages exactly like a hand-maintained count.
  Drawing a CI pipeline from the workflow file rather than from memory is what
  surfaces that a required check never runs; drawing a streaming path from the
  service rather than from the feature description is what surfaces the
  redaction window nobody had documented.

Keep light-on-dark legibility in mind: a page is rendered in both themes, and an
`<img>` does not inherit `currentColor`. A neutral card with explicit fills
reads acceptably on both; a diagram drawn in pure black on transparent does not.

## References

- **Guidelines for Images:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/GuidelinesForImages.html
- **Screenshot Container:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/ScreenshotContainer/Index.html

## Theme-change screenshots (render-guides): file:// is unstyled, control the comparison

- The rendered output links `theme.css` with `crossorigin="anonymous"` — Chrome **blocks the stylesheet under `file://`** (CORS), so a `file://` screenshot is completely unstyled. Serve the output over HTTP (`python3 -m http.server`) and shoot `http://localhost:…`.
- For a true before/after on CSS-only changes, reuse the SAME output HTML and swap in the old stylesheet (`git show origin/main:…/theme.css`) — the HTML doesn't change. Neutralize sticky/fixed nav before element shots (`position: static`).
- The theme CSS is a **committed build artifact** (`npx grunt sass` → `resources/public/css/theme.css`) — rebuild it in the same commit as the SCSS change; local sass matches CI, keep the diff surgical (`git diff --stat`).
- Computed-style dumps flap on two non-differences: custom-property **enumeration order** (compare property→value dicts, never serialized strings) and load-timing noise (rerun the SAME variant twice; a property that flaps there is noise). Trust controlled pixel comparison — 12/12 pairs were 0-pixel identical while string dumps "differed".
