# Contributing to solar_iconkit

Thanks for your interest in improving `solar_iconkit`. This document covers how to file issues, propose changes, and get your pull requests merged smoothly.

## Ways to contribute

- **Report bugs** — open an issue with a minimal reproduction (a small Dart snippet or a Dartpad link).
- **Suggest features** — open an issue tagged `enhancement` describing the use case, not just the API you'd like.
- **Improve the docs** — README typos, unclear sections, missing examples. PRs to `README.md` are always welcome.
- **Fix a bug** — comment on the issue you'd like to tackle so nobody duplicates work, then open a PR.
- **Add tests** — coverage gaps are called out in the [audit report](https://github.com/sovankentech/solar_iconkit/issues); pick one and send a PR.

## Before you file an issue

Search existing issues first — the bug or request may already be tracked. If not, use the templates provided under [.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE) — they collect the info the maintainer needs to reproduce the problem.

## Development setup

```bash
git clone https://github.com/sovankentech/solar_iconkit.git
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

Releases follow [Semantic Versioning](https://semver.org). The maintainer handles all publishes to pub.dev — contributors don't need to worry about the release step.

## Code of conduct

By participating, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Questions?

Open a [Discussion](https://github.com/sovankentech/solar_iconkit/discussions) or reach the maintainer at [sovanken.tech@gmail.com](mailto:sovanken.tech@gmail.com).

Thanks for helping make `solar_iconkit` better.
