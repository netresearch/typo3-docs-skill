# Documentation Rendering Reference

Complete reference for rendering TYPO3 documentation locally using Docker.

Based on: https://docs.typo3.org/permalink/h2document:rendering-container

## Overview

Rendering runs via the official container — image, basic command
(`docker run --rm --pull always -v $(pwd):/project -it
ghcr.io/typo3-documentation/render-guides:latest --config=Documentation`),
output at `Documentation-GENERATED-temp/Index.html`, and `init` for new
documentation:
[Rendering container](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/RenderingContainer.html)
and
[Rendering howto](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Howto/RenderingDocs/Index.html)
`[upstream]` — canonical, win on conflict (see `canonical-sources.md`).

### Command Options Explained

| Option | Purpose |
|--------|---------|
| `--rm` | Remove container after execution |
| `--pull always` | Fetch latest container image |
| `-v $(pwd):/project` | Mount current directory as `/project` |
| `-it` | Enable interactive terminal |
| `--config=Documentation` | Specify documentation folder location |

### Output Location

Rendered documentation is generated at:

```
Documentation-GENERATED-temp/Index.html
```

Open this file in a browser to preview the documentation.

#### `--output` is a container path

`[upstream]` since 2026-08-17 — that `--output` resolves inside the container,
that a path outside the mount disappears with the container, and that the
command reports the files as placed anyway are all stated on the [Rendering
container](https://docs.typo3.org/permalink/h2document:rendering-container)
page. Keep the target below the mount:

```bash
# WRONG — /tmp is the container's /tmp; nothing appears on the host
docker run --rm -v "$(pwd)":/project -w /project \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation --output=/tmp/rendered-docs

# RIGHT — inside the mount, so it lands in ./.build/rendered-docs on the host
docker run --rm -v "$(pwd)":/project -w /project \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation --output=/project/.build/rendered-docs
```

The delta that stays here is the consequence upstream does not draw: this
matters when a check *reads back* the rendered HTML — asserting a new
anchor exists, diffing output between branches, feeding a link checker. The
assertion then fails with `No such file or directory` on a render that
genuinely succeeded, which reads as a docs error rather than a path mistake.
Pick a mounted, git-ignored target (`.build/`, `var/`) so the artefacts stay
out of the working tree.

## Initializing New Documentation

`init` itself is `[upstream]` (Rendering container page). Kept below: the
prompt sequence and post-init workflow the upstream page does not show.

### Prerequisites

- `composer.json` must exist in project root
- Docker must be installed and running

### Interactive Prompts

The init command asks for:

1. **Documentation format**:
   - `rst` (ReStructuredText) - **Recommended** for full TYPO3 theme features
   - `md` (Markdown) - Simpler, for single-page documentation only

2. **Site Set configuration** (if applicable):
   - Enter the Site set name and path if your extension defines one
   - Auto-generates configuration documentation
   - Skip if extension has no Site sets

### Generated Files

The command creates:
- `Documentation/guides.xml` - Configuration file (enhance with GitHub integration)
- `Documentation/Index.rst` - Entry point with basic structure
- Example documentation pages

### Post-Init Workflow

After running init:

1. **Enhance `guides.xml`** with GitHub integration, project links, inventories
2. **Expand `Index.rst`** with proper toctree and extension overview
3. **Create section directories** (`Configuration/`, `Usage/`, `Developer/`) with `Index.rst` files
4. **Add content** based on extension features
5. **Render and verify** the documentation

### Reference

- **Writing Documentation for Extensions:** https://docs.typo3.org/permalink/h2document:how-to-document-an-extension

## Convenience Scripts

To simplify rendering, create wrapper scripts in your project:

### scripts/render_docs.sh

```bash
#!/bin/bash
# Render documentation locally using Docker
set -e

cd "$(dirname "$0")/.."

echo "Rendering documentation..."
docker run --rm --pull always -v "$(pwd)":/project -it \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation

echo ""
echo "Documentation rendered successfully!"
echo "Open: Documentation-GENERATED-temp/Index.html"
```

### scripts/validate_docs.sh

```bash
#!/bin/bash
# Validate documentation RST syntax
set -e

cd "$(dirname "$0")/.."

echo "Validating documentation..."
docker run --rm --pull always -v "$(pwd)":/project -it \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation \
  --no-progress \
  --fail-on-log

echo "Documentation validation passed!"
```

Make scripts executable:
```bash
chmod +x scripts/render_docs.sh scripts/validate_docs.sh
```

## Visual Verification

After rendering, always verify the output visually:

1. Open `Documentation-GENERATED-temp/Index.html` in a browser
2. Check that all pages render correctly
3. Verify code blocks have proper syntax highlighting
4. Confirm images and diagrams display
5. Test internal links work
6. Review table formatting

## Live View (Watch Mode)

Watch-mode command (both mounts, `-p 1337:1337`, `--watch`), custom port,
shell alias, DDEV addon, and the four limitations (guides.xml changes, new
files, menu changes, moved files require a restart):
[Automatic re-rendering](https://docs.typo3.org/permalink/h2document:rendering-wysiwyg)
`[upstream]`.

### Convenience Script: scripts/watch_docs.sh

```bash
#!/bin/bash
# Live-render documentation with auto-reload
set -e

cd "$(dirname "$0")/.."

echo "Starting documentation live server..."
echo "Open: http://localhost:1337/Index.html"
echo "Press Ctrl+C to stop"
echo ""

docker run --rm -it --pull always \
  -v "./Documentation:/project/Documentation" \
  -v "./Documentation-GENERATED-temp:/project/Documentation-GENERATED-temp" \
  -p 1337:1337 \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config="Documentation" --watch
```

### Shell Alias

Add to your shell config (`.bashrc`, `.zshrc`) for quick access:

```bash
alias typo3-docs-watch="docker run --rm -it --pull always \
  -v './Documentation:/project/Documentation' \
  -v './Documentation-GENERATED-temp:/project/Documentation-GENERATED-temp' \
  -p 1337:1337 ghcr.io/typo3-documentation/render-guides:latest --watch"
```

### DDEV Integration

For DDEV projects, use the official addon:

```bash
ddev add-on get TYPO3-Documentation/ddev-typo3-docs
ddev restart
```

Access via `http://<yourproject>.ddev.site:1337/`

### Watch Mode Limitations

Auto-rebuild does **not** trigger for:

| Change Type | Action Required |
|-------------|-----------------|
| `guides.xml` changes | Restart watch container |
| Newly added files | Restart watch container |
| Menu structure changes | Restart watch container |
| File relocations | Restart watch container |

For these changes, stop the container (Ctrl+C) and restart it.

## Troubleshooting

### Container Not Starting

Ensure Docker Desktop is running:
```bash
docker info
```

### Permission Issues

On Linux, you may need to run with your user ID:
```bash
docker run --rm --pull always -v $(pwd):/project -u $(id -u):$(id -g) -it \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation
```

### What the Rendering Reports, and What It Does Not

Measured on 2026-09-20 with `ghcr.io/typo3-documentation/render-guides:latest`,
which resolved that day to version `0.43.0`, revision `1adeb0a`. Keep using
`:latest` — the tag is what the rest of this reference and the CI examples use;
pin `:0.43.0` or the digest only when a result has to be reproduced exactly.
The messages below are the literal strings the renderer emits; the entries
under "Not emitted" were in this file until that measurement and are Sphinx
wording, not this renderer's.

**The exit code is `0` even after errors.** A render that logs an unresolved
reference and a missing image still ends on `Successfully placed ... files`
and exits `0`. Three options change that:

| Option | Effect |
|--------|--------|
| `--fail-on-log` | exit 1 on any logged message, warning included |
| `--fail-on-error` | exit 1 on an error; a warning still exits 0 |
| `--minimal-test` | exit 1 on a warning |

A CI job that only checks the exit code of a bare render therefore passes on a
broken manual. Add one of the three.

**Messages you will actually see:**

| Message | What the renderer does next |
|---------|-----------------------------|
| `Document "X" isn't included in any toctree. Use :orphan: ...` | renders the page; add it to a toctree or mark it `:orphan:` |
| `Menu entry "X" was not found in the document tree. Ignoring it.` | drops that entry, keeps the menu |
| `Reference X could not be resolved in Y` | renders `<span class="invalid-link">` in place of the link |
| `Duplicate anchor "X". There is already another anchor of that name in document "Y"` | keeps both pages; a foreign `:ref:` resolves to the first. Fires only for a duplicate **across two files** — two identical anchors in one file produce no message |
| `No template found for rendering directive "x". Expected template "body/directive/x.html.twig"` | skips the directive |
| `Image reference not found "..."` — logged as an **error** | renders the page without the image |
| `The code-block has no content. Did you properly indent the code?` (same for `math` and `list-table`) | renders an empty block |
| `Inventory with key X not found.` / `Inventory link with key "X:y" (y) not found.` | drops the interlink |

**Not emitted — do not search the log for these:**

- `Unknown directive`, `Duplicate label`, `Reference not found`, `undefined label` — Sphinx wording; this renderer uses the strings in the table above.
- Any warning about a missing `:alt:`. The only alt-text warning in the stack is Markdown-only, so a reStructuredText image without `:alt:` is silent.
- Any warning about a code block without a language. Highlighting is simply off.

### Claims This File Carried That Are False

Each was tested against the image named above and did not reproduce.

- **"Page renders blank — check 3-space indent for directive content."** A
  three-space and a four-space directive body render identically. Four spaces
  is a style rule in the upstream `CodingGuidelines`, not a parsing
  requirement.
- **"Render fails immediately — missing `guides.xml`, run `docker run ... init`
  to scaffold."** A project with no `guides.xml` renders and exits 0; there is
  no immediate failure to fix, and `init` is a scaffolding wizard rather than
  a remedy. The one qualification: a missing `guides.xml` also means no
  interlink inventories, so a page using `:ref:` into another manual logs
  `Inventory link with key "..." not found.` and drops the link. The render
  still exits 0, but `--fail-on-log` then exits 1 — measured with a
  one-page project referencing `t3coreapi`.
- **"Broken image icon — use `/Images/...` absolute from the Documentation
  root"** and **"Image missing in output — move to `Documentation/Images/`."**
  Both an absolute and a relative image path resolve; images render from any
  path.

### The One Mistake That Produces No Message

A directive with no blank line above it is absorbed into the paragraph and
printed as literal source. Nothing is logged, and `--fail-on-log` does not
catch it, so the only way to find it is to look at the rendered page.

```rst
Some paragraph text.
..  note::
    This is printed as plain text, not rendered as a note.
```

### Clearing Cache

If rendering produces unexpected results, clear the generated directory:
```bash
rm -rf Documentation-GENERATED-temp/
```

### Structure and Menus

| Symptom | Cause | Fix |
|---------|-------|-----|
| New page not in menu | Missing from `toctree` | Add to parent `Index.rst` toctree directive |
| Menu order wrong | toctree order | Reorder entries in toctree directive |
| Interlink fails | Missing inventory | Add to `guides.xml` interlink section |

### Debugging Render Failures

`[regression]` caveat: `--fail-on-log` is absent from the manual, though the
image's own `--help` lists it and upstream's CI examples use `--no-progress
--minimal-test` instead. Measured working at 0.43.0 (exit 1 on a warning);
if it disappears, switch to `--minimal-test`, which upstream does document.
A page documenting all three options is proposed upstream in
[TYPO3CMS-Guide-HowToDocument#573](https://github.com/TYPO3-Documentation/TYPO3CMS-Guide-HowToDocument/pull/573).

For verbose error output:
```bash
docker run --rm --pull always -v $(pwd):/project -it \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation \
  --fail-on-log
```

Check the last few lines of output for specific RST file and line number causing the error.

## CI/CD Integration

`[upstream]` ships GitHub Actions and GitLab CI examples (SHA-pinned action,
`mkdir -p Documentation-GENERATED-temp` before the render, `--no-progress
--minimal-test`) on the rendering pages — prefer those as the base. The
variant below additionally fails on log warnings (`--fail-on-log`, see the
caveat above); pin `actions/checkout` to a full SHA per NR policy:

```yaml
name: Documentation
on: [push, pull_request]

jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Render documentation
        run: |
          docker run --rm -v ${{ github.workspace }}:/project \
            ghcr.io/typo3-documentation/render-guides:latest \
            --config=Documentation \
            --no-progress \
            --fail-on-log
```

## Requirements

- **Docker**: Must be installed and running
- **Project structure**: Valid `composer.json` in project root
- **Documentation**: `Documentation/` folder with RST files
- **Configuration**: `Documentation/guides.xml` (or use `init` command)

## Gitignore

Always exclude the generated directory from version control:

```gitignore
# Documentation rendering output
Documentation-GENERATED-temp/
```

## References

- **Rendering Container:** https://docs.typo3.org/permalink/h2document:rendering-container
- **Live View (Watch Mode):** https://docs.typo3.org/permalink/h2document:rendering-wysiwyg
- **guides.xml Reference:** https://docs.typo3.org/permalink/h2document:guides-xml

## Renderer gotchas: symlinks in Documentation/, permalinks for outbound links

- **No symlinks inside `Documentation/`** — `[upstream]` since 2026-08-15, stated in [File structure](https://docs.typo3.org/permalink/h2document:file-structure): the render walks the tree literally and a symlink breaks the walk. The delta that stays here: a *regular* `Documentation/AGENTS.md` file is fine, because unknown `.md` files are ignored — only the symlink breaks it. So agent-rules tooling that generates scoped instruction files across an extension tree must exclude `Documentation/` from **linking**, not from having such a file at all.
- **Link TO docs.typo3.org with permalinks, not path URLs**: `https://docs.typo3.org/permalink/<identifier>` survives restructuring; full `…/main/en-us/<Path>.html` URLs rot and reviewers flag them. Applies everywhere — code comments, PR bodies, chat, docs.
