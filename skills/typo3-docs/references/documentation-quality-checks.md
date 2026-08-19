# Documentation Quality Checks (TD-52 … TD-55)

How these four were chosen, and — more useful — what was tried and thrown away.

## The principle: relational, not quantitative

Volume is the weakest signal available. It fails in both directions (too little
is incomplete, too much is unmaintainable), and every threshold on it is
arbitrary. All four checks therefore ask **does X match Y**, where the code
supplies Y:

| Check | Denominator from the code | Question |
|---|---|---|
| TD-52 | keys in `ext_conf_template.txt` | is every declared setting mentioned at all? |
| TD-53 | the `confval` blocks that exist | does each state `:type:` and `:default:`? |
| TD-54 | backend modules + registered plugins | does a UI surface appear in a screenshot at least once? |
| TD-55 | commits to templates and public assets | have the screenshots kept up? |

A three-setting extension can satisfy all four completely. That is the property
a page count can never have.

## Measured before adoption

Run over the 19 documented `netresearch/t3x-*` repositories. A criterion that
answers the same for every repository measures nothing and must not become a
checkpoint:

- **TD-52** applies to 11 repos, spread 0–100 %.
- **TD-53** applies to 15 repos, spread 20–100 %, eight distinct values — the
  widest spread of anything tried.
- **TD-54** fires on 8 of the 13 repos that register a UI surface.
- **TD-55** is met by 1 of the 6 repos that have screenshots. That is not a
  defect of the check: `Documentation Excellence` is a bonus category meant to
  identify reference-level work, so a bar the fleet does not yet clear is the
  point. It is `info`, never a failure.

## Two candidates that were dropped

**Alt text on every image directive.** Seven repositories have image
directives; all seven are at 100 %. The criterion cannot tell anyone apart and
has no headroom — it belongs in base conformance as a regression guard, not in
a quality score. (Contrast TD-55, where almost everyone fails but one
repository proves it is achievable. Universally *passed* and universally
*failed* are not the same finding.)

**"Too many screenshots" as a ratio.** A band of `images > 3 × surfaces` fired
on three repositories, and reading the artefacts showed all three were
defensible: `t3x-nr-passkeys-be` keeps eight images in four folders —
Administration, Configuration, Login, UserSettings — against a single
registered module. Login screens, user-settings panels, RTE toolbar buttons and
CKEditor dialogs are all UI surfaces that no registry declares, so the
denominator is unknowable. A machine cannot distinguish "fifteen screenshots of
one button" from "eight screenshots of four surfaces". If that judgement is
wanted, it has to be an LLM review; it must not be a count.

## Implementation notes worth keeping

`check-ui-surface-screenshots.sh` counts modules by including `Modules.php` in
PHP. Old-style registration through `ExtensionManagementUtility::addModule`
does not return an array; the fallback counts registrations and the message
says the number is an estimate rather than presenting it as a measurement.

`check-screenshot-freshness.sh` exits silently in a shallow clone or a
`--no-tags` checkout. Both know a truncated history, and the comparison would
then describe the checkout rather than the repository.

The 200-line threshold in TD-55 is calibrated on the observed distribution —
37 lines for the one current repository, 255 to 1354 for the rest — so it sits
in the gap rather than at either edge.
