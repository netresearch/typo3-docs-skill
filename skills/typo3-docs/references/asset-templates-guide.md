# Asset Templates Guide

Templates for TYPO3 documentation projects.

## AI Agent Context

To provide AI assistants with documentation context, copy `assets/AGENTS.md` to the extension's `Documentation/` folder. This template includes:
- Documentation type and strategy
- Target audience definition
- File structure overview
- Style guidelines for AI-generated content

## Screenshot Requirements (MANDATORY)

| Documentation Topic | Screenshot Required |
|---------------------|---------------------|
| Backend module interfaces | YES - Show the module UI |
| Extension configuration screens | YES - Show settings location |
| Multi-step UI workflows | YES - One screenshot per step |
| TCA/FlexForm configurations | YES - Show resulting forms |
| Frontend visual output | YES - Show what users see |
| Error messages/states | YES - Help users identify issues |

Do NOT write "TODO: add screenshot" or skip screenshots. If you cannot take a screenshot, explicitly ask the user to provide one or use MCP tools to capture them.

## Screenshot Workflow

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
