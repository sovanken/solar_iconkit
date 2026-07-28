# solar_iconkit_example

Reference application for the `solar_iconkit` package. Interactive browser that lets you preview every icon in every style, at any size.

## Running

From this directory:

```bash
flutter pub get
flutter run
```

The example depends on the parent package via a relative path (`path: ../` in `pubspec.yaml`), so any change to the package source is picked up on hot reload.

To run on a specific device:

```bash
flutter devices
flutter run -d chrome              # web
flutter run -d windows             # desktop
flutter run -d macos               # desktop
```

## What it demonstrates

- Basic `SolarIcon(name)` usage with the default style.
- Live switching between all six `SolarIconStyle` values via a chip row.
- Continuous sizing from 16 to 96 px via a slider.
- Filtering with `SolarIcons.all` and a local search string.
- The same icon rendered in multiple contexts on one screen:
  - Inside an `AppBar` title with a themed color.
  - Inside a `ChoiceChip.avatar` at 16 px.
  - Inside a `TextField` `prefixIcon`.
  - Inside a `GridView.builder` card.
  - Inside a `showModalBottomSheet` at 40 px showing all six styles side by side for one icon.
- Automatic light/dark theme following `ThemeMode.system`, with icons picking up the surrounding color.

## What to look for in the code

- `_filtered` shows the recommended pattern for filtering `SolarIcons.all` in a way that keeps Dart's type inference happy (`List<String>.from(...)` plus a typed collection literal).
- The bottom sheet in `_showDetails` demonstrates how to render the same icon across every style — useful for reference sheets and design docs.
- The `_IconCard` widget is a self-contained tile you can copy into your own icon picker.

Use this app as a template. Copy `example/lib/main.dart` into your project, prune the pieces you do not need, and adapt the styling to your design system.
