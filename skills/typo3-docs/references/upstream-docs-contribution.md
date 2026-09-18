# Contributing to TYPO3-Documentation Repositories

`[regression]`/process knowledge — conventions and verification techniques
for PRs against official TYPO3 documentation repositories
(`TYPO3-Documentation/*`, e.g. `TYPO3CMS-Reference-CoreApi`), and for
fact-checking documentation claims against the TYPO3 core. **The target
repository's own `AGENTS.md` outranks this page** — see the first bullet
below. Upstream prose that binds every one of these repos:
Howto/Contribute (edit-on-GitHub vs local Docker, approval requirement) and
[Advanced/CommitMessages](https://docs.typo3.org/m/typo3/docs-how-to-document/main/en-us/Advanced/CommitMessages.html),
which defines the commit trailers including `Releases:`. The squash-only and
render-gate facts below are observed working knowledge on top of them.

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
- **Read the repository's `AGENTS.md` before the first commit — it owns
  trailers and backport scope, and it is more specific than anything here.**
  `TYPO3CMS-Reference-CoreApi` has carried one since 2026-08-21 (its
  `CLAUDE.md` is the single line `@AGENTS.md`), and it fixes what this page
  used to get wrong: `Releases:` in *every* commit whatever your label
  permissions, the trailer order (`Resolves:`/`References:`, `Releases:`,
  `Assisted-by:`, `Signed-off-by:`), `Assisted-by:` in the
  `<model> <contact>` form, the default `main, 14.3` with `13.4` reserved for
  a bugfix or security fix worth backporting that far — *not* for plain
  content or style changes — the `main only` and `changelog` labels, and how
  to verify the backport bot's PRs actually landed. Do not restate those
  rules from memory and do not ask a maintainer which labels apply: the
  trailer is the channel they read. (2026-08-13, CoreApi #6651: a PR body carrying
  the free text `backport 13.4, backport 14.3` plus a comment asking for the
  scope waited five weeks for an answer that was "use the trailer". The
  `AGENTS.md` did not exist yet; it does now.)
- **`AGENTS.md` is loaded, but not reliably obeyed — re-read your trailers
  before you push.** Measured 2026-09-18 on a clone with one uncommitted
  one-sentence edit, four headless runs per arm, the only difference being
  whether `AGENTS.md` was present: with it, 3 of 4 messages carried a TYPO3
  subject prefix and `Releases:`; without it, 0 of 4 did, every run producing
  `docs: …` with no trailers. But the full trailer order appeared complete in
  only 1 of 4, the `main, 14.3` default in 2 of 4, and the repo's
  `Assisted-by:` form in 1 of 4 — a personal `AGENT_NAME:MODEL_VERSION`
  convention in a user-level `CLAUDE.md` usually wins that field. Where the
  two disagree, the repo wins; check the message, do not assume.
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
