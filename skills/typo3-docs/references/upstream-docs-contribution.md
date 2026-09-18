# Contributing to TYPO3-Documentation Repositories

`[regression]`/process knowledge — conventions and verification techniques
for PRs against official TYPO3 documentation repositories
(`TYPO3-Documentation/*`, e.g. `TYPO3CMS-Reference-CoreApi`), and for
fact-checking documentation claims against the TYPO3 core. Two upstream pages
are binding and come first: Howto/Contribute (edit-on-GitHub vs local Docker,
approval requirement) and
[Advanced/CommitMessages](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CommitMessages.html),
which defines the commit trailers including `Releases:`. The squash-only,
backport-label and render-gate facts below are observed working knowledge on
top of them.

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
- **A `Releases:` trailer in the commit body is how backport scope is
  communicated** — it is not decoration. Backports run via labels
  (`backport 13.4`, `backport 14.3` trigger a backport job after merge;
  companion labels `backport-done` / `backport-failed`), and the labels are
  set by maintainers *reading the trailer*. Write
  `Releases: main, 14.3, 13.4` into the commit message of every commit,
  naming the branches the change's own scope requires — a limitation that
  exists since v13.0 belongs on `13.4` as well as on `14.3`. The squash
  commit keeps the branch commits' bodies, so the trailer lands on the target
  branch — verified in the merges of #6988, #6984 and #6979, each of which
  carries `Releases: main, 14.3` in the squashed message. Free text in the PR
  body does not survive, and no bot reads the body for backport scope. Do not
  ask about labels in a comment and do not try to set them yourself. Format
  and the other trailers (`Signed-off-by:`,
  `Assisted-by: <tool/model name> <contact>`, `Resolves:`) are documented in
  [Advanced/CommitMessages](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CommitMessages.html).
  (2026-09-18, CoreApi #6651: the PR body carried the free text
  `backport 13.4, backport 14.3` and a comment asking a maintainer to decide
  the scope; the answer — "Next time use a trailer as is documented here …
  Then tells the maintainers to add the labels" — came five weeks later.)
- **`Assisted-by:` here is not the personal trailer format.** These repos
  document `Assisted-by: <tool/model name> <contact>`, e.g.
  `Assisted-by: Claude Sonnet 5 <noreply@anthropic.com>` — and merged commits
  use it that way (`Assisted-by: Claude Opus 5 <noreply@anthropic.com>` in
  #6988, #6984, #6979), not the `AGENT_NAME:MODEL_VERSION` form used
  elsewhere. Target-repo rules win.
- **Commit subject prefix**: the documented set is `[TASK]`, `[BUGFIX]`,
  `[FEATURE]`; `[!!!]` marks a breaking change. `[DOCS]` (the
  core-contribution habit) is accepted but rare — 11 of 346 commits on
  `TYPO3CMS-Reference-CoreApi` `main` since 2026-01-01, against 159 `[TASK]`
  (measured 2026-09-18). Prefer a documented prefix; most content work is
  `[TASK]`.
- **The `render / Test documentation` CI job is the authoritative render
  gate** — equivalent to a local `render-guides --fail-on-log` run; a green
  job is the evidence a "renders without warnings" claim needs.
- `[regression]` Member association does not imply triage rights: requesting reviewers or
  setting labels may fail (`404` / GraphQL permission error) even for org
  members. That is expected and needs no workaround: the `Releases:` trailer
  above is the channel, so do not retry the API, do not @-mention a
  maintainer to ask which labels apply.

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
