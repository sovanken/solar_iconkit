# Contributing to solar_iconkit

Thanks for your interest in improving `solar_iconkit`. This document covers how to file issues, propose changes, and get your pull requests merged smoothly.

## Ways to contribute

- **Report bugs** — open an issue with a minimal reproduction (a small Dart snippet or a Dartpad link).
- **Suggest features** — open an issue tagged `enhancement` describing the use case, not just the API you'd like.
- **Improve the docs** — README typos, unclear sections, missing examples. PRs to `README.md` are always welcome.
- **Fix a bug** — comment on the issue you'd like to tackle so nobody duplicates work, then open a PR.
- **Add tests** — coverage gaps are called out in the [audit report](https://github.com/sovanken/solar_iconkit/issues); pick one and send a PR.

## Before you file an issue

Search existing issues first — the bug or request may already be tracked. If not, use the templates provided under [.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE) — they collect the info the maintainer needs to reproduce the problem.

## Development setup

```bash
git clone https://github.com/sovanken/solar_iconkit.git
cd solar_iconkit
flutter pub get
flutter test              # run all tests (should all pass)
flutter analyze           # should report zero errors
cd example && flutter run # run the example app
```

**Requirements:** Flutter ≥ 3.27, Dart ≥ 3.6.

## Pull request checklist

Before submitting a PR, please confirm:

- [ ] Code follows the existing style (run `dart format .` — the generated `.g.dart` is excluded)
- [ ] `flutter analyze` reports zero errors
- [ ] `flutter test` passes (all existing tests + any new ones you added)
- [ ] Public API changes are documented via dartdoc
- [ ] `CHANGELOG.md` has an unreleased entry describing the change (Keep a Changelog format)
- [ ] If you touched the widget, added at least one test covering the new behavior

## Commit messages

We follow a lightweight convention:

```
<short imperative summary — under 60 chars>

<longer paragraph explaining why, not what, when helpful>
```

Examples of good commit summaries:

- `Add blendMode parameter to SolarIcon`
- `Fix opacity composition when IconTheme.opacity is set`
- `Docs: clarify semanticLabel behavior`

## Adding new icons

The Solar icon set is upstream — new icons come from the Iconify collection, not hand-drawn additions. If Solar adds icons, the maintainer will regenerate `lib/src/solar_iconkit_data.g.dart` and the SVG assets in a minor release.

Please do NOT hand-add SVGs to `assets/icons/` — they'll be overwritten on the next regeneration.

### How the maintainer syncs the catalog

A weekly workflow (`.github/workflows/upstream-check.yml`) compares the
committed catalog against the live Iconify collection and opens a single
`upstream-sync` issue when Solar has added or renamed icons. It closes that
issue once a sync lands. Run the same check locally at any time:

```bash
python tool/check_upstream.py
```

Syncing is then:

```bash
python tool/fetch_icons.py     # downloads assets, regenerates the catalog
npx svgo -r -f assets/icons --config tool/svgo.config.mjs
flutter analyze && flutter test
```

Two things the generator deliberately protects, both learned the hard way:

- **It never drops a name a release has shipped.** Iconify hides renamed
  icons from its browsable listing, so a naive refresh would delete the
  `@Deprecated` constants from the previous release. `previously_shipped()`
  reads both `all` and `legacyAliases` and the script aborts rather than
  drop anything.
- **Renames are not the only kind of change.** Upstream sometimes redraws a
  glyph without renaming it — 1.1.0 shipped eleven of those, and 1.2.0
  picked up a fix for a malformed `bold/logout`. Only a pixel diff finds
  them, so before releasing, render every icon at the old and new revisions
  and compare. Note that a per-style sweep is not enough on its own: check
  every asset whose *bytes* changed, since the SVGO pass is deterministic
  and so a changed glyph always changes bytes.

## Style guide

- Public API names use `camelCase` (Dart convention)
- Doc comments start with a one-line summary, followed by an optional paragraph and examples
- Prefer `const` constructors and `final` fields
- Line width: 100 chars (soft limit)

## Getting a PR reviewed

- Small, focused PRs get reviewed faster than large ones
- Include screenshots or a `flutter run` GIF when your change is visible
- If the CI fails, please push a fix — don't wait for a maintainer to catch it

## Release process

Releases follow [Semantic Versioning](https://semver.org). Contributors don't
need to do anything for a release; the maintainer tags it.

Publishing is driven entirely by the tag. There is no manual `pub publish`
step and no credential on anyone's machine:

```bash
# 1. bump `version:` in pubspec.yaml and add the CHANGELOG section
# 2. merge that through a PR as usual
# 3. tag the merged commit
git tag -a v1.3.0 -m "1.3.0 - <summary>"
git push origin v1.3.0
```

`.github/workflows/release.yml` then, in order:

1. verifies the tag matches `pubspec.yaml` — a mismatch would publish the
   wrong version under the right name, which pub.dev cannot undo;
2. verifies `CHANGELOG.md` has a section for it, so the release notes are
   the changelog rather than a second copy that drifts;
3. runs format, analyze, tests, `pub publish --dry-run`, and `pana`;
4. publishes to pub.dev with a short-lived OIDC token;
5. creates the GitHub Release from the changelog section.

The `pana` gate is set to `--exit-code-threshold 0` because the package
scores 160/160 on pub.dev — any lost point is a regression. Raise it only
with a reason in the commit message.

Publishing requires a one-time pub.dev setting (Admin → Automated
publishing) naming the repository and a `v{{version}}` tag pattern.
Nothing else is needed; the workflow holds no secrets beyond the
repository's own `GITHUB_TOKEN`.

## Code of conduct

By participating, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Questions?

Open a [Discussion](https://github.com/sovanken/solar_iconkit/discussions) or reach the maintainer at [sovanken.tech@gmail.com](mailto:sovanken.tech@gmail.com).

Thanks for helping make `solar_iconkit` better.
