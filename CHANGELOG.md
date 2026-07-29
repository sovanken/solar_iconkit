# Changelog

All notable changes to this package are documented here. The format loosely
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
package uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] — 2026-07-29

### Changed

- **LICENSE cleanup.** The bundled Solar attribution has been moved to a new
  top-level `NOTICE` file so `LICENSE` is now a clean, unaltered MIT template.
  `licensee`/pub.dev can now confidently detect the license — the pub.dev
  license status will resolve from "pending" to "MIT".

### Added

- **Continuous integration.** A GitHub Actions workflow at
  `.github/workflows/ci.yml` runs `flutter analyze` and `flutter test` on
  every push and pull request, against Flutter 3.27.0 (the minimum declared
  in `pubspec.yaml`) and the current stable channel. Status badge added to
  the README.
- **Bundle-size roadmap.** The "Reducing bundle size" section in the README
  now explicitly documents the 23 MB / 4–5 MB gzipped footprint, the
  per-style trimming workflow (fork + edit `pubspec.yaml`), and flags
  per-icon tree-shaking via `build_runner` as the direction for `v1.0`.

## [0.3.0] — 2026-07-29

### Added

- **Icon browser website** — <https://solar-icons-web.vercel.app> is now the
  primary place to preview icons, pick a style, and copy Flutter widget code
  for any icon in the set. Referenced throughout the README and set as the
  package `homepage`.
- **Sponsorship link** — Ko-fi funding URL declared in `pubspec.yaml` under
  the `funding` field (pub.dev renders a "Sponsor" button pointing to
  <https://ko-fi.com/sovanken>). README now includes a short "Support" section.

### Changed

- README trimmed to five essential badges (pub version, pub points, Flutter,
  license, Ko-fi) — the badge cluster is easier to read and each badge now
  communicates something distinct.
- External links to the Solar collection page were replaced with links to the
  new browser website so readers land on an interactive preview instead of an
  outdated third-party listing.
- Package `homepage` now points at the icon browser
  (<https://solar-icons-web.vercel.app>) rather than pub.dev — pub.dev already
  links to itself.

### Removed

- README sections that documented the internal regeneration script have been
  removed. The script is still shipped for maintainers under `tool/`, but it
  is not part of the public API and no longer surfaces in the readme,
  troubleshooting, or requirements sections.

## [0.2.0] — 2026-07-28

### Added

- Dartdoc comment on every `SolarIcons.<name>` constant (1,231 total). Raises
  pub.dev "Provide documentation" from 10 % to ~98 % coverage.
- Dartdoc comments on every `SolarIconStyle` enum value, describing the
  visual character of each of the six styles.

### Changed

- **Breaking:** minimum Flutter bumped from `3.24.0` to `3.27.0` (Dart 3.6+).
  This lets the widget use the modern non-deprecated color API.
- Opacity composition now uses `Color.withValues(alpha: ...)` (Flutter 3.27+)
  instead of the deprecated `.alpha`, `.red`, `.green`, `.blue` component
  getters. Fixes the pub.dev static-analysis warnings about deprecated
  members in `lib/src/solar_icon.dart`.
- Fetcher generator (`tool/fetch_icons.py`) now emits `/// Solar icon \`X\`.`
  before each constant, so future regenerations preserve the documentation.

### Fixed

- pub.dev score raised from 140/160 to an expected 160/160 (documentation
  and static analysis categories both at max).

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
