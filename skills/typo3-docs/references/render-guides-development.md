<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Developing render-guides itself

For changing the renderer — `TYPO3-Documentation/render-guides`, the
`typo3-docs-theme` package and its integration fixtures — not for writing
documentation with it. Everything here was measured against the repository
rather than taken from its documentation, which does not describe any of the
parsing or fixture behaviour below. The one overlap is the committed stylesheet:
`references/screenshots.md` already notes that it is a build artifact that must
be rebuilt in the same commit — the section here adds what CI checks about it.
render-guides' own `AGENTS.md` (in the root of
`TYPO3-Documentation/render-guides`, not this skill's) covers its `make` targets, fixture recording
and layout; read it first.

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
written — the only place in the suite a new warning cannot hide. The suite
does not use the network: answers from docs.typo3.org, api.typo3.org and
Packagist come from recordings in `tests/Integration/http-fixtures/`, and an
address without a recording is answered as not found. A fixture that adds an
interlink, a PHP class or a Composer package needs its recordings (record with
`RECORD_HTTP=1`, as render-guides' `AGENTS.md` describes); without them the
lookup is answered as not found.

**Regenerate expectations, do not hand-edit them.** Each fixture renders into
its own `temp/`; splice the marker region from there into `expected/`. And when
counting fixtures, exclude `temp/` — it is generated output that looks exactly
like an expectation to a recursive grep.

## The committed theme assets are gated by a byte comparison

`packages/typo3-docs-theme/resources/public/` (compiled `css/theme.css`,
`js/theme.min.js`) is committed. `.github/workflows/check-built-assets.yaml`
runs `npm ci --ignore-scripts && npm run build` in `packages/typo3-docs-theme`
whenever a pull request or merge-queue entry touches that package, and on
every push to `main`, and fails when `assets/` or `resources/public/` then differ from the
commit, or contain untracked files. A SCSS or JS change without its rebuilt
output is therefore red, not silently shipped.

Rebuild with `npm ci && npm run build` in `packages/typo3-docs-theme` and
commit `assets` and `resources/public` together with the source change. The
check uses the Node version from that package's `.nvmrc`; a different local
Node can produce a different byte stream, so confirm first that a no-op
rebuild on `main` leaves the tree unchanged.

## Updating Composer dependencies

- **Raising the PHP floor** (`require.php` and `config.platform.php` in the
  root `composer.json`) is a full `composer update`: the whole tree may resolve
  differently once the platform changes.
- **Upgrading one library** is a targeted update with its dependencies,
  `composer update <vendor/pkg> [<vendor/pkg> …] -W`, so unrelated upgrades
  stay out of the change.
- **`composer update --lock` alone** only refreshes the lock file's content
  hash; it updates no package, so it is not enough after changing the platform
  or a constraint.
- **A dependency bump can change fixture output.** A newer
  `phpdocumentor/guides` changes rendered HTML (1.9.2 → 1.9.6 started wrapping
  admonition bodies in `<p>`, rendered one-line `.. hint::` text and passed the
  code-block language to the highlighter). Regenerate the expectations and
  consider a separate pull request for the bump, so the fixture diff is not
  mixed with your change.
- **`composer.lock` conflicts on rebase.** During a rebase, `--ours` is the
  branch you rebase onto and `--theirs` is your replayed commit. Take upstream's
  lock (`git checkout --ours composer.lock`), re-run the same
  `composer update` command your commit made (full or targeted), `git add composer.lock`, continue, and run
  `composer install` before the tests — `vendor/` is stale after the rebase.
- **PHP extensions per package.** Each sub-package declares the `ext-*` its
  own source uses in its `composer.json` (at `a0e64940`: `typo3-docs-theme`
  curl and dom; `typo3-guides-cli` dom, libxml and simplexml;
  `typo3-version-handling` curl). Code that starts calling another extension's
  functions adds the declaration to that package.

## Contributing to TYPO3-Documentation repositories

- **Commit messages** follow the How to Document rules
  ([Commit messages](https://docs.typo3.org/permalink/h2document:commit-messages)),
  which render-guides' `AGENTS.md` repeats: a `[TASK]` / `[BUGFIX]` /
  `[FEATURE]` summary (render-guides adds `[DOCS]`), a body that explains why,
  then `Assisted-by: <tool/model name> <contact>` when AI helped beyond a
  spelling check, before the human's `Signed-off-by:`. `Co-authored-by:` is for
  people (and dependabot), never for a model.
- **No other agent trailers.** Session or host metadata trailers and a session
  footer in the pull request body are not part of those rules; maintainers
  squash-merge without them. Where a personal convention adds such trailers,
  the repository rule wins: drop them here.
- **Architecture decisions** of the organisation live in
  `TYPO3-Documentation/.github` under `Documentation/Decisions/ADR-NNN-Name.rst`:
  reStructuredText starting with `.. include:: /Includes.rst.txt`, sections
  Status, Context, Decision, Alternatives Considered, Consequences. Contributors
  without push access open the pull request from a fork.
