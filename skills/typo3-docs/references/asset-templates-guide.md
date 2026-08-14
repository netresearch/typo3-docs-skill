# Asset Templates Guide

Templates for TYPO3 documentation projects.

## AI Agent Context

To provide AI assistants with documentation context, copy `assets/AGENTS.md` to the extension's `Documentation/` folder. This template includes:
- Documentation type and strategy
- Target audience definition
- File structure overview
- Style guidelines for AI-generated content

## Screenshot Guidance `[heuristic]`

Upstream says: *before adding a screenshot, consider if one is necessary* —
each one is ongoing maintenance. There is no upstream "mandatory screenshot"
rule; the table below is the Netresearch quality bar for topics where a
screenshot usually earns its keep (necessity check still applies):

| Documentation Topic | Screenshot |
|---------------------|---------------------|
| Backend module interfaces | Usually — show the module UI |
| Extension configuration screens | Usually — show settings location |
| Multi-step UI workflows | Usually — one per non-obvious step |
| TCA/FlexForm configurations | Usually — show resulting forms |
| Frontend visual output | Usually — show what users see |
| Error messages/states | Usually — help users identify issues |

Where a screenshot IS warranted, do not write "TODO: add screenshot" or
silently skip it — capture it, or explicitly ask the user to provide one.

## Screenshot Workflow

1. Identify all UI elements that need screenshots (see requirements table above)
2. Set TYPO3 backend to light theme (`[upstream]` [Guidelines for images](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/GuidelinesForImages.html))
3. Capture screenshots using one of the methods below
4. Crop to relevant area
5. Save as PNG in `Documentation/Images/` with CamelCase naming
6. Add RST image directive with `:alt:` (`[upstream]` — alt text is required) plus `:zoom: lightbox` and `:class: with-border with-shadow` (`[NR policy]` house style; zoom modes are a render-guides feature, see `screenshots.md`)
7. Verify screenshots render correctly in documentation build

### Taking Screenshots

**Using browser DevTools (Chrome/Firefox):**
```bash
# Open DevTools (F12), then:
# Ctrl+Shift+P -> "Capture screenshot" or "Capture full size screenshot"
```

**Using Playwright MCP (automated):**
```
mcp__playwright__browser_take_screenshot
```

**Using Chrome DevTools MCP:**
```
mcp__chrome-devtools__take_screenshot
```

### Screenshot Checklist

- [ ] PNG format used
- [ ] Light theme in TYPO3 backend
- [ ] Cropped to relevant area
- [ ] `:alt:` text describes image content
- [ ] `:zoom: lightbox` added for click-to-enlarge
- [ ] `:class: with-border with-shadow` for visual polish
- [ ] Image stored in `Documentation/Images/` with CamelCase name
