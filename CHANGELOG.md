# Changelog

All notable changes to this package are documented here. The format loosely
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
package uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-07-29

🎉 **First stable release.**

`solar_iconkit` is now API-stable and production-endorsed. The 1.0 line
commits to backwards compatibility — future 1.x releases will only add
optional parameters or fix bugs. Breaking changes will bump to 2.0.

### Highlights from the 0.x → 1.0 journey

- **1,231 Solar icons** across **6 native styles** (7,386 SVG variants) —
  behind a single, type-safe `SolarIcon` widget.
- **160/160 pub.dev score** across all five evaluation categories.
- **32 tests + 6 golden files** covering widget behaviour, IconTheme
  integration, RTL mirroring, opacity composition, blendMode, shadows,
  and visual regression on all six styles.
- **Cross-platform CI** on Ubuntu, macOS, and Windows, plus a dedicated
  Ubuntu job on the declared minimum Flutter 3.27.0.
- **Zero deprecated API use** — modern `Color.withValues(alpha:)` for
  opacity composition, `Directionality.of` for RTL, `IconTheme.of` for
  ambient theme integration.
- **Strict analyzer** — `strict-casts`, `strict-inference`, and
  `strict-raw-types` all enabled, plus 11 additional lint rules.
- **Full community-standards** compliance: `CONTRIBUTING.md`,
  `CODE_OF_CONDUCT.md`, `SECURITY.md`, issue templates, PR template,
  Dependabot, FUNDING.
- **Branch protection** on `main` — all four CI matrix jobs must pass
  before merge.

### Since 0.4.0

- **Analyzer strictness bumped** — 11 additional lint rules and full
  strict-type-checking. Codebase already compliant; no user-visible
  changes.
- **Coverage tracked via Codecov** — every push and PR uploads
  `lcov.info` from the min-Flutter CI job. Coverage badge in the README.
- **Branch protection on `main`** — the four CI matrix jobs are required
  status checks. Force-push and deletion blocked.
- Version references bumped throughout the docs to `^1.0.0`.

### Roadmap toward 2.0

- **Per-style sub-packages** (`solar_iconkit_linear`,
  `solar_iconkit_bold_duotone`, etc.) for consumers who only need a
  subset of styles. Would cut typical bundle size from 23 MB to ~4 MB.
- **Icon-font distribution** as an alternative to SVG for consumers who
  prioritise bundle size over duotone rendering.

## [0.4.0] — 2026-07-29

### Added

- **`SolarIcon.blendMode`** parameter (defaults to `BlendMode.srcIn`). Lets
  advanced consumers customise how the icon's color composites onto the
  background — for example `BlendMode.multiply` for icon-over-texture
  effects, or `BlendMode.dst` to render the SVG in its native colors.
- **`SolarIcon.shadows`** parameter — a `List<Shadow>?`. Mirrors the
  `shadows` parameter on Flutter's built-in `Icon` widget. When
  non-empty, blurred and offset copies of the icon are painted behind
  the main render.

  ```dart
  SolarIcon(
    SolarIcons.heart,
    style: SolarIconStyle.bold,
    color: Colors.red,
    shadows: const [
      Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
    ],
  )
  ```

- **Golden tests** covering all six styles. `test/golden_test.dart`
  renders `SolarIcons.home2` per style and compares against reference
  PNGs in `test/goldens/`. Catches visual regressions caused by
  `flutter_svg` upgrades or widget-layout changes.
- **Cross-platform CI.** The workflow now runs a matrix on Ubuntu,
  Windows, and macOS against the current Flutter stable channel, plus
  a dedicated Ubuntu job on the declared minimum Flutter 3.27.0. Golden
  tests are gated to Ubuntu only via the `golden` test tag
  (`dart_test.yaml`) — pixel-level rasterization can differ across
  platforms.
- **Format enforcement in CI.** `dart format --set-exit-if-changed` runs
  as part of the min-flutter job. Codebase is now fully dart-formatted.

### Changed

- **Test count 24 → 32.** Two new widget tests (`blendMode`, `shadows`)
  plus six golden tests.
- **`debugFillProperties`** now reports `blendMode` and `shadows` so
  they show up in Flutter DevTools.

### Notes

- No breaking changes. Both new parameters are optional and default to
  the pre-existing behaviour (srcIn blend, no shadows).

## [0.3.3] — 2026-07-29

### Added

- **pub.dev screenshots.** Three screenshots are now shipped in the package
  and rendered on the pub.dev landing page:
    - `browser-grid.png` — the interactive icon browser with sidebar,
      style chips, and icon grid.
    - `style-comparison.png` — the detail dialog showing an icon in all
      six native styles, hero preview, "Preview in context", and Copy tab.
    - `widget-in-app.png` — the "Preview in context" strip demonstrating
      SolarIcon in menu, sidebar, button, and toolbar UI patterns.
- **Capture script.** `screenshots/capture.mjs` uses Playwright to
  regenerate all three PNGs from the live icon browser
  (<https://solar-icons-web.vercel.app>) — makes future re-captures a
  one-command operation.

## [0.3.2] — 2026-07-29

### Added

- **Community health files.** Added `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`
  (Contributor Covenant 2.1), `SECURITY.md` (with GitHub private vulnerability
  reporting), issue templates (bug report + feature request), pull request
  template, and `.github/FUNDING.yml`. GitHub's community-standards score
  moves from 0/7 to 7/7.
- **Dependabot.** `.github/dependabot.yml` opens weekly PRs for pub
  dependencies and GitHub Actions versions.
- **RTL and opacity tests.** Three new widget tests covering `matchTextDirection`
  under `Directionality.rtl`, explicit `textDirection` override, and
  composition of widget-level `opacity` with `IconTheme.opacity`. Total
  test count is now 24 (up from 21).
- **Screenshots scaffold.** `screenshots/README.md` documents which
  visuals to capture for pub.dev; a commented `screenshots:` block in
  `pubspec.yaml` is ready to activate once the PNGs are in place.

### Changed

- **`flutter_lints` bumped `^5.0.0 → ^6.0.0`.** Picks up the latest Dart
  lint rules. No new warnings surfaced by the upgrade.
- **Example app cleanup.** Replaced 8 remaining `Color.withOpacity(...)`
  calls with `Color.withValues(alpha: ...)` (Flutter 3.27+ API). Applied
  `const` where the analyzer suggested. `flutter analyze` now reports
  zero issues across `lib/`, `test/`, and `example/`.

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
