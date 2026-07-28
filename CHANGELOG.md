# Changelog

All notable changes to this package are documented here. The format loosely
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
package uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-07-28

Initial public release.

### Widget

- `SolarIcon` widget with a `const` constructor and 11 parameters: `name`,
  `style`, `size`, `color`, `opacity`, `semanticLabel`, `textDirection`,
  `matchTextDirection`, `fit`, `alignment`, and `key`.
- Full `IconTheme.of(context)` integration — `size`, `color`, and `opacity`
  resolve from the ambient theme when unset on the widget, matching the
  behaviour of Flutter's built-in `Icon`.
- Decorative icons (no `semanticLabel`) are wrapped in `ExcludeSemantics` so
  screen readers skip them cleanly.
- Strict layout box via `SizedBox.square` — icons never overflow their parent.
- `debugFillProperties` for Flutter DevTools inspection.
- Static helpers: `SolarIcon.assetPath(name, style)` and
  `SolarIcon.packageName`.
- Cross-version alpha computation via `Color.fromARGB` — no dependency on
  `withOpacity` (deprecated) or `withValues` (unavailable pre-3.27).

### Styles

- `SolarIconStyle` enum with six native Solar styles:
  `linear`, `outline`, `broken`, `bold`, `lineDuotone`, `boldDuotone`.

### Catalog

- `SolarIcons` class with 1,231 generated string constants — one per Solar
  base icon — and an alphabetically sorted `all` list.
- Identifier naming rules: kebab-case to camelCase, leading digits prefixed
  with `i`, Dart reserved words suffixed with `Icon`, collisions resolved
  with numeric suffixes.

### Assets

- 7,386 SVG assets bundled across 6 style folders under `assets/icons/`.
- Assets declared in `pubspec.yaml` under the `flutter.assets` key; consumers
  do not need to declare anything.

### Tooling

- Python 3 regeneration script at `tools/fetch_icons.py` that pulls the
  latest Solar icons from the Iconify API, writes SVGs into
  `assets/icons/{style}/`, and regenerates `lib/src/solar_iconkit_data.g.dart`.

### Testing

- Widget and unit tests covering: default rendering, explicit props,
  `IconTheme` inheritance, `ExcludeSemantics` wrapping, opacity assertions,
  `assetPath` resolution, catalog invariants (sortedness, uniqueness,
  identifier grammar), and reserved-word renames.

### Documentation

- Comprehensive `README.md` covering installation (pub.dev + path + git +
  overrides), API reference, style guide, recipes for common Flutter widgets,
  advanced patterns, performance guarantees, and troubleshooting.
- Dartdoc comments on every public class, member, and enum value.
- `PUBLISHING.md` maintainer guide with release workflow.
- `example/` Flutter app browses every icon in every style with search and
  size controls.

### Platform support

Android, iOS, macOS, Windows, Linux, Web — every platform supported by
`flutter_svg`.
