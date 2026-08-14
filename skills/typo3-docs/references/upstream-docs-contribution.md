# Contributing to TYPO3-Documentation Repositories

`[regression]`/process knowledge — conventions and verification techniques
for PRs against official TYPO3 documentation repositories
(`TYPO3-Documentation/*`, e.g. `TYPO3CMS-Reference-CoreApi`), and for
fact-checking documentation claims against the TYPO3 core. Verified
non-duplicative: the upstream contribution page (Howto/Contribute) covers
only edit-on-GitHub vs local Docker plus the approval requirement — the
squash-only, backport-label, Releases-trailer and render-gate facts below are
observed working knowledge.

## Verify claims against core source, not rendered HTML

When a documentation statement must be checked against actual core behavior
("function X throws", "context Y provides variable Z"), fetch the **raw
source** — scraping docs.typo3.org HTML fights the theme markup (modals,
`data-*` attributes, code buttons) and burns several grep attempts for one
sentence of content:

```bash
# Core class source (any branch: main, 13.4, 12.4, ...)
curl -s https://raw.githubusercontent.com/TYPO3/typo3/main/typo3/sysext/core/Classes/Site/Entity/Site.php

# Changelog RST source — the authoritative wording of a Breaking/Deprecation
curl -s https://raw.githubusercontent.com/TYPO3/typo3/main/typo3/sysext/core/Documentation/Changelog/13.0/Breaking-100963-DeprecatedFunctionalityRemoved.rst
```

Changelog files live under
`typo3/sysext/core/Documentation/Changelog/<version>/<Type>-<issue>-<Title>.rst`.
To confirm behavior differences between LTS versions, fetch the same class
from both branch refs and diff.

**Changelog permalinks** (`https://docs.typo3.org/permalink/changelog:...`)
can be verified without rendering: a HEAD request answers `307` with a
`Location` naming the resolved page; anything else means the anchor is wrong.

## PR conventions in TYPO3-Documentation repos

- **Squash-only merges.** The repos allow only squash; separate commits (and
  preserved authorship of commits taken over from another PR) survive only as
  `Co-authored-by:` trailers in the squash commit. Rebasing keeps authors in
  the branch history, but a merge never transplants them to the target branch.
- **Backports run via labels**, not manual PRs: `backport 13.4`,
  `backport 14.3` trigger a backport job after merge (companion labels
  `backport-done` / `backport-failed`). Commit bodies conventionally carry a
  `Releases: main, 14.3, 13.4` trailer naming the intended branches.
- **The `render / Test documentation` CI job is the authoritative render
  gate** — equivalent to a local `render-guides --fail-on-log` run; a green
  job is the evidence a "renders without warnings" claim needs.
- `[regression]` Member association does not imply triage rights: requesting reviewers or
  setting labels may fail (`404` / GraphQL permission error) even for org
  members. Put backport intent in the PR body and @-mention the maintainer
  instead of retrying the API.

## Find where a topic lives: query the manual's inventory

Do not guess rendered paths — every manual publishes its object inventory:

```bash
curl -s https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/objects.inv.json \
  | jq -r '."std:label" | to_entries[] | select(.key|test("confval")) | "\(.key) -> \(.value[2])"'
```

`std:doc` maps document names, `std:label` maps every anchor to its page —
this is how a moved page or the right `:ref:` target is found in one call
(located the intersphinx section and the relocated InterlinkInventories page
this way, 2026-08-14). Works for any manual (render-guides, Core API, …) by
swapping the base URL.
