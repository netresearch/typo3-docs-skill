# Developing render-guides itself

For changing the renderer — `TYPO3-Documentation/render-guides`, the
`typo3-docs-theme` package and its integration fixtures — not for writing
documentation with it. Everything here was measured against the repository
rather than taken from its documentation, which does not describe any of the
parsing or fixture behaviour below. The one overlap is the committed stylesheet:
`references/screenshots.md` already notes that it is a build artifact that must
be rebuilt in the same commit — the section here adds why CI will not catch a
missed rebuild.

## Directive options do not arrive as you wrote them

`Directive::getOptionString()` hides two shapes that reach the directive as
something other than the text in the `.rst` file. Both produce a value that
looks plausible and resolves to nonsense.

**An option written without a value is the boolean `true`.**
`DirectiveRule::parseDirectiveOption` matches `/^(\s+):(.+):(\s*)$/` and
constructs `new DirectiveOption($name, true)`; `getOptionString()` is `strval()`
over that, so `:changelog:` arrives as the string `"1"` and is happily treated
as an identifier. Read the option object instead and test the flag:

```php
if (!$directive->hasOption('changelog')) {
    return null;
}
$value = $directive->getOption('changelog')->getValue();   // string|true
$raw   = $value === true ? '' : (string) $value;
```

**A value on the following line is appended to that flag.**
`collectDirectiveOptionContent` calls `DirectiveOption::appendValue(' ' . trim($line))`,
which is `((string) $this->value) . $append` — so

```rst
..  versionchanged:: 14.0
    :changelog:
        feature-107628-1729026000
```

arrives as `"1 feature-107628-1729026000"`, and the `=== true` check above never
fires. `appendValue` always prepends one space and can run once per continuation
line, so the reliable tell is whitespace, not the `1`.

**Read the value untrimmed.** The inline form is trimmed by the parser and a
continued one is not, so leading whitespace is the only thing separating them.
Trim first and a trailing space after the option name silently decides whether a
value is accepted — a rendering difference caused by an invisible character.

**Check the encoding before any `/u` pattern.** `preg_match()` returns `false`,
not `0`, on malformed UTF-8, so `=== 1` reads a byte-damaged value as "no
match". Such a value reaching `SluggerAnchorNormalizer` throws in
`UnicodeString` and ends the entire render — no pages written, and the error
names the Twig template rather than the `.rst` file at fault.

## Interlink syntax in the theme is wider than upstream's

`vendor/package:anchor` parses only because `typo3-docs-theme.php` rebinds
`InterlinkParser::class` to `ExtendedInterlinkParser`, whose domain pattern is
`[a-zA-Z0-9\-_\/.]+`. Upstream's `DefaultInterlinkParser` uses
`[a-zA-Z0-9-_]+` and rejects the `/`. Anything splitting `<domain>:<anchor>` by
hand drifts from `:ref:`, `:doc:` and `ApiClassTextRole`, which all go through
the bound parser — delegate instead of writing another `explode(':')`.

## What the integration suite actually asserts

`tests/Integration/IntegrationTest.php` compares far less than the fixture files
suggest, and the gaps are silent.

| Fixture location | HTML comparison |
|---|---|
| `tests/Integration/tests/` | only between `<!-- content start -->` and `<!-- content end -->` |
| `tests/Integration/tests-full/` | the whole file |

Everything outside those markers — head, navigation, footer — is never compared,
so it can be arbitrarily wrong in an expected file.

**Log files are compared by line containment, not equality**
(`assertFileContainsLines`). Three consequences, each verified by mutation:
an added warning is invisible; a duplicate expected line asserts nothing beyond
the first; and an expected log of a single blank line asserts nothing at all,
because `explode("\n", …)` yields `['']` and every string contains the empty
string.

**The strong assertion is an absent `expected/logs/` directory.** Where a
fixture ships no expected log, the runner asserts that no warning log was
written — the only place in the suite a new warning cannot hide. Keep such a
manual free of anything that fetches an interlink inventory over the network, or
a transient failure fails the suite for an unrelated reason.

**Regenerate expectations, do not hand-edit them.** Each fixture renders into
its own `temp/`; splice the marker region from there into `expected/`. And when
counting fixtures, exclude `temp/` — it is generated output that looks exactly
like an expectation to a recursive grep.

## The committed theme assets are not gated

`packages/typo3-docs-theme/resources/public/css/theme.css` is committed, and
**no CI job rebuilds it**: `.github/workflows/main.yaml` runs `npm ci` and
`npm test` and nothing else. A SCSS change whose compiled asset is not rebuilt
passes CI and ships nothing.

Rebuild from `packages/typo3-docs-theme`. `npx grunt sass` regenerates the
stylesheet alone; `npm run build` is `vite build && grunt build`, where the
grunt default also runs `stylelint`, the JS pipeline and `removesourcemap` — use
it when anything beyond the CSS is involved. Either way, confirm first that a
no-op rebuild on `main` leaves the tree byte-identical, so your diff carries the
one change and not the churn of a different toolchain version.
