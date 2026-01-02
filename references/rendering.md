# Documentation Rendering Reference

Complete reference for rendering TYPO3 documentation locally using Docker.

Based on: https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/RenderingContainer.html

## Overview

TYPO3 documentation is rendered using a Docker container that processes reStructuredText files into HTML. This enables local preview before committing changes.

## Container Image

```
ghcr.io/typo3-documentation/render-guides:latest
```

## Rendering Documentation

### Basic Render Command

Execute from the project root (where `composer.json` is located):

```bash
docker run --rm --pull always -v $(pwd):/project -it \
  ghcr.io/typo3-documentation/render-guides:latest \
  --config=Documentation
```

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

## Initializing New Documentation

For new projects, scaffold the documentation structure:

```bash
docker run --rm --pull always -v $(pwd):/project -it \
  ghcr.io/typo3-documentation/render-guides:latest init
```

This creates:
- `Documentation/guides.xml` - Configuration file
- `Documentation/Index.rst` - Entry point
- Example documentation pages

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

### Warnings During Rendering

Common warnings and fixes:

| Warning | Fix |
|---------|-----|
| `Unknown directive` | Check directive spelling and available directives |
| `Duplicate label` | Ensure unique `.. _label:` across all RST files |
| `Reference not found` | Verify `:ref:` targets exist |
| `Image not found` | Check image path is relative to RST file |

### Clearing Cache

If rendering produces unexpected results, clear the generated directory:
```bash
rm -rf Documentation-GENERATED-temp/
```

## CI/CD Integration

For GitHub Actions, add documentation rendering to your workflow:

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

- **Rendering Container:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/RenderingContainer.html
- **guides.xml Reference:** https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Reference/GuidesXml.html
