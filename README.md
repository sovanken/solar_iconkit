# solar_iconkit

[![platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20macos%20%7C%20windows%20%7C%20linux%20%7C%20web-4c1)](https://pub.dev/packages/solar_iconkit)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.27-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![icons](https://img.shields.io/badge/icons-1%2C231%20%C2%B7%206%20styles-FFA500)](https://solar-icons-web.vercel.app)
[![Ko-fi](https://img.shields.io/badge/Support-Ko--fi-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/sovanken)

A Flutter package that bundles the entire Solar icon set — **1,231 icons across 6 native styles** (7,386 SVG variants total) — behind a single, type-safe widget API. Zero setup, works offline, integrates with Flutter's `IconTheme` conventions.

- **Browse icons**: <https://solar-icons-web.vercel.app>
- **pub.dev**: <https://pub.dev/packages/solar_iconkit>
- **Issues**: <https://github.com/sovankentech/solar_iconkit/issues>
- **Support**: <https://ko-fi.com/sovanken>

**What you get**

- Six native Solar styles: `linear`, `outline`, `broken`, `bold`, `lineDuotone`, `boldDuotone`.
- One widget: `SolarIcon(name, style: ..., size: ..., color: ...)`.
- ~1,231 generated `SolarIcons.<name>` constants for autocomplete-safe references.
- Bundled SVG assets in `assets/icons/`. No network access at runtime, works fully offline.
- Full `IconTheme` integration — size, color, and opacity resolve from the ambient theme when unset on the widget.
- Deterministic asset resolution — `packages/solar_iconkit/assets/icons/{style}/{name}.svg`.
- Example browser app under `example/` demonstrating every usage pattern.
- Runs on Android, iOS, macOS, Windows, Linux, and Web.

**Non-goals**

- Not a `flutter_svg` replacement — this package depends on it internally, but you should not need to import `flutter_svg` in your own code when using `SolarIcon`.

---

## Table of contents

- [solar\_iconkit](#solar_iconkit)
  - [Table of contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Option A: pub.dev (recommended)](#option-a-pubdev-recommended)
    - [Option B: Path dependency](#option-b-path-dependency)
    - [Option C: Git dependency](#option-c-git-dependency)
    - [Option D: Version pin with dependency\_overrides](#option-d-version-pin-with-dependency_overrides)
    - [After installing](#after-installing)
  - [Quick start](#quick-start)
  - [API reference](#api-reference)
    - [SolarIcon widget](#solaricon-widget)
    - [SolarIconStyle enum](#solariconstyle-enum)
    - [SolarIcons constants](#solaricons-constants)
  - [Style guide](#style-guide)
  - [Usage recipes](#usage-recipes)
    - [Basic display](#basic-display)
    - [Coloring](#coloring)
    - [Sizing](#sizing)
    - [In buttons](#in-buttons)
    - [In text fields](#in-text-fields)
    - [In lists and tiles](#in-lists-and-tiles)
    - [In app bars and navigation](#in-app-bars-and-navigation)
    - [In cards and dialogs](#in-cards-and-dialogs)
    - [Animated style transitions](#animated-style-transitions)
    - [Honoring IconTheme](#honoring-icontheme)
    - [Accessibility](#accessibility)
  - [Advanced patterns](#advanced-patterns)
    - [Building an icon picker](#building-an-icon-picker)
    - [Precaching for smooth scrolling](#precaching-for-smooth-scrolling)
    - [Reducing bundle size](#reducing-bundle-size)
    - [Wrapping SolarIcon in a project-level widget](#wrapping-solaricon-in-a-project-level-widget)
  - [Performance notes](#performance-notes)
  - [Testing](#testing)
  - [Troubleshooting](#troubleshooting)
  - [Package layout](#package-layout)
  - [Versioning](#versioning)
  - [License and attribution](#license-and-attribution)
  - [Support](#support)

---

## Requirements

| Requirement | Minimum |
|---|---|
| Flutter | 3.27.0 |
| Dart | 3.6.0 |
| flutter_svg | 2.0.10 (transitive) |

The package targets all Flutter platforms supported by `flutter_svg`: Android, iOS, macOS, Windows, Linux, and Web.

---

## Installation

Choose one of the four dependency forms below.

### Option A: pub.dev (recommended)

Add to your `pubspec.yaml`:

```yaml
dependencies:
  solar_iconkit: ^0.3.0
```

Or run:

```bash
flutter pub add solar_iconkit
```

**When to use:** production apps; you want stable, version-pinned releases.

### Option B: Path dependency

Best for a monorepo or when the package sits next to the app in a workspace. Add to each consuming project's `pubspec.yaml`:

```yaml
dependencies:
  solar_iconkit:
    path: ../solar_iconkit          # relative to the consumer's pubspec.yaml
```

Then run `flutter pub get`. Changes to the package are picked up instantly by any consumer in the workspace.

**When to use:** local development, single-repo layouts, quick iteration.

**Caveats:** each consumer needs a valid relative path. If team members clone the repos into different layouts, prefer Option A or Option D.

### Option C: Git dependency

Best when the package lives in its own repo and consumers pull it from Git:

```yaml
dependencies:
  solar_iconkit:
    git:
      url: git@github.com:sovankentech/solar_iconkit.git
      ref: v0.3.0                 # a tag, branch, or commit SHA
```

**When to use:** package has its own repo, multiple consumers on different machines.

**Caveats:** every consumer needs SSH access (or use HTTPS + token). Use tags (not `main`) for reproducibility.

### Option D: Version pin with dependency_overrides

Best when you want to publish semver-like versions but override to local during development:

```yaml
dependencies:
  solar_iconkit: ^0.3.0

dependency_overrides:
  solar_iconkit:
    path: ../solar_iconkit
```

**When to use:** you want the safety of pinned versions in production but zero friction while making package changes locally.

**Caveats:** the override must be removed (or ignored via `dev` groups) before shipping to CI/production. Commit the override in a `pubspec_overrides.yaml` file that CI does not use, to keep `pubspec.yaml` clean.

### After installing

You do not need to add `flutter_svg` to your own dependencies — this package depends on it transitively. You also do not need to declare the SVG assets in your consumer app's `pubspec.yaml`; assets are declared inside `solar_iconkit/pubspec.yaml` and Flutter resolves them via the `packages/` scheme automatically.

Verify the install:

```dart
import 'package:solar_iconkit/solar_iconkit.dart';

void main() {
  print(SolarIcons.all.length);      // 1231
  print(SolarIcons.home2);           // 'home-2'
  print(SolarIconStyle.values.length); // 6
}
```

---

## Quick start

Three commonly used forms:

```dart
import 'package:flutter/material.dart';
import 'package:solar_iconkit/solar_iconkit.dart';

// Minimum — default style (linear), size 24, color inherited from IconTheme.
SolarIcon(SolarIcons.home2)

// Explicit style and size.
SolarIcon(SolarIcons.heart, style: SolarIconStyle.bold, size: 32)

// Full — style, size, color, and semantic label.
SolarIcon(
  SolarIcons.rocket,
  style: SolarIconStyle.boldDuotone,
  size: 48,
  color: Theme.of(context).colorScheme.primary,
  semanticLabel: 'Launch',
)
```

There is no `init()` call, no font loading, no asset path to remember, and no `flutter_svg` import required from consumer code.

---

## API reference

### SolarIcon widget

```dart
const SolarIcon(
  String name, {
  SolarIconStyle style = SolarIconStyle.linear,
  double size = 24,
  Color? color,
  String? semanticLabel,
  Key? key,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `name` (positional) | `String` | required | Base icon name, for example `'home-2'`. Use [`SolarIcons`](#solaricons-constants) constants for autocomplete. Any string is accepted, but if the SVG does not exist a blank space is rendered at build time (see [Troubleshooting](#troubleshooting)). |
| `style` | `SolarIconStyle` | `SolarIconStyle.linear` | Which of the six visual styles to render. |
| `size` | `double?` | `null` (inherits from `IconTheme`, then 24) | Width and height in logical pixels. The SVG scales uniformly, so any positive value stays crisp. |
| `color` | `Color?` | `null` (inherits from `IconTheme`, then `Color(0xDD000000)`) | Fill/stroke color, applied via `ColorFilter.mode(..., BlendMode.srcIn)`. |
| `opacity` | `double` | `1.0` | Multiplier on top of `color`'s alpha. Combined with `IconTheme.opacity`. Asserted to be in `[0.0, 1.0]`. |
| `semanticLabel` | `String?` | `null` | Read by screen readers. When null, the icon is wrapped in `ExcludeSemantics` so decorative usages are silent. |
| `matchTextDirection` | `bool` | `false` | Mirror the icon horizontally under RTL. Set true for directional icons like arrows. |
| `textDirection` | `TextDirection?` | `null` | Explicit direction override; falls back to `Directionality.of(context)`. |
| `fit` | `BoxFit` | `BoxFit.contain` | How the SVG is inscribed in its size box. |
| `alignment` | `AlignmentGeometry` | `Alignment.center` | Alignment within the size box. |
| `key` | `Key?` | `null` | Standard Flutter widget key. |

**How coloring works internally.** The widget applies `ColorFilter.mode(color, BlendMode.srcIn)` to the rendered SVG. `srcIn` keeps the source alpha (so opacity is preserved) and replaces the source color with the chosen color. This is why duotone styles — which use `opacity="0.5"` on their secondary path — retain their two-tone effect while adopting your chosen base color.

**How color and size resolve** (matches Flutter's built-in `Icon` widget):
1. If the parameter is passed explicitly on the widget, use it.
2. Otherwise read from `IconTheme.of(context)`.
3. Fall back to defaults (24 px, `Color(0xDD000000)`).

Wrap subtrees in `IconTheme` to theme every `SolarIcon` inside them at once — see [Recipe: Theming across the app](#honoring-icontheme).

**Const-friendly.** `SolarIcon`'s constructor is `const`, so instances can be used in `const` contexts and will not rebuild unless their inputs change.

**Static helpers.**
- `SolarIcon.assetPath(name, style)` — the raw asset path for advanced use (custom widgets, precache).
- `SolarIcon.packageName` — the `'solar_iconkit'` string, useful when passing to `SvgAssetLoader` directly.

### SolarIconStyle enum

```dart
enum SolarIconStyle {
  linear,       // Folder: 'linear'
  outline,      // Folder: 'outline'
  broken,       // Folder: 'broken'
  bold,         // Folder: 'bold'
  lineDuotone,  // Folder: 'line_duotone'
  boldDuotone,  // Folder: 'bold_duotone'
}
```

Each member exposes a `folderName` property that maps to the asset subdirectory:

```dart
SolarIconStyle.linear.folderName        // 'linear'
SolarIconStyle.lineDuotone.folderName   // 'line_duotone'
```

You rarely need `folderName` — the widget uses it internally to resolve the asset path.

Iterate every style:

```dart
for (final style in SolarIconStyle.values) {
  print('${style.name} -> ${style.folderName}');
}
```

### SolarIcons constants

Generated file: `lib/src/solar_iconkit_data.g.dart`. Exposes every base icon name as a `static const String` on the `SolarIcons` class, plus an `all` list of every name sorted alphabetically.

```dart
class SolarIcons {
  static const String home = 'home';
  static const String home2 = 'home-2';
  static const String heart = 'heart';
  static const String rocket = 'rocket';
  static const String caseIcon = 'case';       // reserved-word rename
  static const String i4k = '4k';              // digit prefix rename
  // ... 1,231 total constants

  static const List<String> all = <String>[/* every icon */];
}
```

**Naming rules applied by the generator:**

| Input | Output identifier | Rule |
|---|---|---|
| `home` | `home` | plain identifier |
| `home-2` | `home2` | kebab-case to camelCase |
| `alt-arrow-down` | `altArrowDown` | multi-word camelCase |
| `4k` | `i4k` | leading digit prefixed with `i` |
| `case` | `caseIcon` | Dart reserved word suffixed with `Icon` |
| `duplicate` (colliding) | `duplicate2` | collision resolved with numeric suffix |

Reserved words that get the `Icon` suffix include (but are not limited to): `case`, `catch`, `class`, `const`, `continue`, `default`, `do`, `else`, `enum`, `extends`, `false`, `final`, `finally`, `for`, `if`, `in`, `is`, `new`, `null`, `rethrow`, `return`, `super`, `switch`, `this`, `throw`, `true`, `try`, `var`, `void`, `while`, `with`, plus Dart built-in identifiers and contextual keywords.

**Practical examples:**

```dart
// Direct usage
SolarIcon(SolarIcons.altArrowDown)

// Programmatic — the icon name is just a string
final String iconName = SolarIcons.rocket;
SolarIcon(iconName, style: SolarIconStyle.bold)

// Iterate every icon (e.g. for a picker)
for (final name in SolarIcons.all) {
  print(name);
}

// Look up existence
final exists = SolarIcons.all.contains('home-2');
```

`SolarIcons` is a namespace class with a private constructor — it cannot be instantiated.

---

## Style guide

The six Solar styles have distinct SVG structures. Understanding their character helps pick the right one for a UI role.

**Linear**
Thin 1.5 px stroke around the shape, no fill. Feels light, hairline, precise. Use for chrome, tab bars, form field decorations, and any high-density UI.

**Outline**
The same silhouette as Linear, but rendered as a filled path with `evenodd` cutouts — the outline is created by the filled shape's boundary. Corners tend to look slightly heavier than Linear at the same rendered size. Use where you want a marginally more substantial outline without going bold.

**Broken**
Same 1.5 px stroke weight as Linear, but with intentional gaps in the stroke path (like broken pen strokes). Playful and friendly, well-suited to empty states, illustrations, and casual UIs.

**Bold**
Fully filled solid shape. High contrast, strong presence. Use for active states in navigation, primary CTAs, and emphasis.

**Line Duotone**
Linear stroke with an additional path that has `opacity="0.5"` — that path acts as a light accent behind or beside the main stroke. Adds depth without going fully solid.

**Bold Duotone**
Bold filled shape with a secondary path at `opacity="0.5"` for the accent. The richest style; feels illustrative. Use for feature highlights, onboarding, and hero areas.

**Recommendation.** Default to `linear` for UI chrome, promote to `bold` for selected/active states, and reserve `boldDuotone` for feature moments.

---

## Usage recipes

### Basic display

```dart
SolarIcon(SolarIcons.home2)                                    // default linear
SolarIcon(SolarIcons.heart, style: SolarIconStyle.bold)        // filled
SolarIcon(SolarIcons.rocket, style: SolarIconStyle.boldDuotone)// duotone
```

### Coloring

Four progressively more integrated approaches:

```dart
// 1. Explicit
SolarIcon(SolarIcons.heart, color: Colors.red)

// 2. Inherit from an ambient IconTheme (matches Flutter's Icon widget)
IconTheme(
  data: const IconThemeData(color: Colors.blueAccent),
  child: SolarIcon(SolarIcons.star),
)

// 3. Theme-driven
SolarIcon(
  SolarIcons.settings,
  color: Theme.of(context).colorScheme.primary,
)

// 4. Duotone keeps its opacity variation while adopting the base color
SolarIcon(
  SolarIcons.rocket,
  style: SolarIconStyle.boldDuotone,
  color: Colors.deepPurple,
)
```

### Sizing

`size` sets both width and height. All Solar icons ship with a 24 × 24 viewBox and scale uniformly.

```dart
SolarIcon(SolarIcons.home2, size: 16)   // dense UI, tables
SolarIcon(SolarIcons.home2, size: 20)   // buttons
SolarIcon(SolarIcons.home2, size: 24)   // default
SolarIcon(SolarIcons.home2, size: 32)   // toolbars
SolarIcon(SolarIcons.home2, size: 48)   // section headers
SolarIcon(SolarIcons.home2, size: 64)   // feature callouts
SolarIcon(SolarIcons.home2, size: 96)   // hero
```

For responsive sizing, drive `size` from `MediaQuery`:

```dart
Builder(builder: (context) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  return SolarIcon(SolarIcons.home2, size: 24 * scale);
})
```

### In buttons

Icon-only:

```dart
IconButton(
  onPressed: onDelete,
  icon: SolarIcon(SolarIcons.trashBinTrash),
  tooltip: 'Delete',
)
```

Leading icon on a text button:

```dart
FilledButton.icon(
  onPressed: onDownload,
  icon: SolarIcon(SolarIcons.download, size: 18, color: Colors.white),
  label: const Text('Download'),
)

OutlinedButton.icon(
  onPressed: onShare,
  icon: SolarIcon(SolarIcons.shareLinear, size: 18),
  label: const Text('Share'),
)
```

Segmented button:

```dart
SegmentedButton<int>(
  segments: [
    ButtonSegment(
      value: 0,
      icon: SolarIcon(SolarIcons.listCheck, size: 16),
      label: const Text('List'),
    ),
    ButtonSegment(
      value: 1,
      icon: SolarIcon(SolarIcons.widget5, size: 16),
      label: const Text('Grid'),
    ),
  ],
  selected: {selectedView},
  onSelectionChanged: (s) => setState(() => selectedView = s.first),
)
```

### In text fields

```dart
TextField(
  decoration: InputDecoration(
    prefixIcon: Padding(
      padding: const EdgeInsets.all(12),
      child: SolarIcon(SolarIcons.magnifer, size: 18),
    ),
    suffixIcon: IconButton(
      icon: SolarIcon(SolarIcons.closeCircle, size: 18),
      onPressed: _clear,
    ),
    hintText: 'Search...',
    border: const OutlineInputBorder(),
  ),
)
```

Note: `prefixIcon` and `suffixIcon` respect a fixed size by default; wrap in `Padding` or set an explicit `prefixIconConstraints` if you need custom sizing.

### In lists and tiles

```dart
ListTile(
  leading: SolarIcon(
    SolarIcons.folder,
    style: SolarIconStyle.boldDuotone,
    color: Colors.amber,
  ),
  title: const Text('Documents'),
  subtitle: const Text('12 files'),
  trailing: SolarIcon(SolarIcons.altArrowRight, size: 18),
  onTap: () {},
)
```

In a `Drawer`:

```dart
Drawer(
  child: ListView(
    children: [
      const DrawerHeader(child: Text('Menu')),
      ListTile(
        leading: SolarIcon(SolarIcons.home2),
        title: const Text('Home'),
        onTap: () {},
      ),
      ListTile(
        leading: SolarIcon(SolarIcons.settings),
        title: const Text('Settings'),
        onTap: () {},
      ),
      ListTile(
        leading: SolarIcon(SolarIcons.logout),
        title: const Text('Sign out'),
        onTap: () {},
      ),
    ],
  ),
)
```

### In app bars and navigation

Bottom navigation bar with active state style switching:

```dart
NavigationBar(
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
  destinations: [
    for (final (i, entry) in const [
      ('Home', SolarIcons.home2),
      ('Search', SolarIcons.magnifer),
      ('Profile', SolarIcons.user),
    ].indexed)
      NavigationDestination(
        icon: SolarIcon(entry.$2),
        selectedIcon: SolarIcon(entry.$2, style: SolarIconStyle.bold),
        label: entry.$1,
      ),
  ],
)
```

`NavigationRail` follows the same pattern with `icon` / `selectedIcon`.

`AppBar` leading and actions:

```dart
AppBar(
  leading: IconButton(
    icon: SolarIcon(SolarIcons.hamburgerMenu),
    onPressed: () => Scaffold.of(context).openDrawer(),
  ),
  title: const Text('Solar'),
  actions: [
    IconButton(icon: SolarIcon(SolarIcons.bell), onPressed: () {}),
    IconButton(icon: SolarIcon(SolarIcons.settings), onPressed: () {}),
  ],
)
```

`TabBar`:

```dart
TabBar(
  tabs: [
    Tab(icon: SolarIcon(SolarIcons.gallery)),
    Tab(icon: SolarIcon(SolarIcons.videoLibrary)),
    Tab(icon: SolarIcon(SolarIcons.musicLibrary2)),
  ],
)
```

### In cards and dialogs

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        SolarIcon(
          SolarIcons.rocket,
          style: SolarIconStyle.boldDuotone,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        const Expanded(child: Text('Deploy to production')),
      ],
    ),
  ),
)

AlertDialog(
  icon: SolarIcon(
    SolarIcons.dangerTriangle,
    style: SolarIconStyle.boldDuotone,
    size: 40,
    color: Colors.orange,
  ),
  title: const Text('Delete this item?'),
  content: const Text('This action cannot be undone.'),
  actions: [
    TextButton(onPressed: () {}, child: const Text('Cancel')),
    FilledButton(onPressed: () {}, child: const Text('Delete')),
  ],
)
```

### Animated style transitions

Cross-fade between two styles (for example when a nav item becomes selected):

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: SolarIcon(
    SolarIcons.heart,
    key: ValueKey(_liked ? 'bold' : 'linear'),
    style: _liked ? SolarIconStyle.bold : SolarIconStyle.linear,
    color: _liked ? Colors.red : null,
  ),
)
```

Animate size with a tween:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 24, end: _big ? 48 : 24),
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeOutCubic,
  builder: (context, size, _) => SolarIcon(SolarIcons.home2, size: size),
)
```

### Honoring IconTheme

`SolarIcon` reads `IconTheme.of(context)` for both size and color when those parameters are left null on the widget. This is the same convention as Flutter's built-in `Icon` widget, so `IconTheme` scoping "just works":

```dart
IconTheme(
  data: const IconThemeData(color: Colors.indigo, size: 20),
  child: Row(children: [
    SolarIcon(SolarIcons.home2),   // picks up indigo + size 20
    SolarIcon(SolarIcons.heart),   // same
  ]),
)
```

Under a `MaterialApp`, `IconTheme.of(context)` returns `Theme.of(context).iconTheme`, so setting `iconTheme:` on your `ThemeData` themes every `SolarIcon` in the app:

```dart
MaterialApp(
  theme: ThemeData(
    iconTheme: IconThemeData(color: Colors.black87, size: 24, opacity: 0.9),
  ),
  home: MyApp(),
)
```

The widget also combines its own `opacity` parameter with `IconTheme.opacity`, so both compose predictably.

### Accessibility

Screen readers treat unlabeled decorative icons as skippable. Provide a `semanticLabel` on any icon that carries meaning without a visible text label:

```dart
IconButton(
  onPressed: _delete,
  icon: SolarIcon(
    SolarIcons.trashBinTrash,
    semanticLabel: 'Delete this item',
  ),
)
```

Do **not** set `semanticLabel` on icons that sit next to visible descriptive text — the label would be announced twice.

---

## Advanced patterns

### Building an icon picker

The `example/` app contains a full picker; the core loop is:

```dart
class IconPicker extends StatefulWidget {
  const IconPicker({super.key, required this.onPicked});
  final ValueChanged<String> onPicked;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String _query = '';
  SolarIconStyle _style = SolarIconStyle.linear;

  List<String> get _matches {
    final all = List<String>.from(SolarIcons.all);
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return <String>[
      for (final n in all) if (n.contains(q)) n,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(onChanged: (v) => setState(() => _query = v)),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 96,
            ),
            itemCount: _matches.length,
            itemBuilder: (context, i) {
              final name = _matches[i];
              return InkWell(
                onTap: () => widget.onPicked(name),
                child: SolarIcon(name, style: _style, size: 36),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Precaching for smooth scrolling

`flutter_svg` decodes each SVG the first time it is rendered. In a long list, initial decoding can cause single-frame jank. Precache the icons you know will appear:

```dart
Future<void> precacheSolarIcons(BuildContext context, List<String> names, SolarIconStyle style) async {
  for (final name in names) {
    await precachePicture(
      SvgAssetLoader(
        'assets/icons/${style.folderName}/$name.svg',
        packageName: 'solar_iconkit',
      ),
      context,
    );
  }
}
```

Call from an `initState` or a route enter callback for icons visible in the first few screens.

### Reducing bundle size

The full asset bundle is about 23 MB uncompressed. If your app only uses a subset of styles, trim the asset declaration in your own build. Fork the package or edit `pubspec.yaml` locally:

```yaml
flutter:
  assets:
    - assets/icons/linear/
    - assets/icons/bold/
    # remove the styles you do not use
```

Then delete the unused style folders under `assets/icons/`. The build will only include the assets you declare.

### Wrapping SolarIcon in a project-level widget

For consistency across screens, define your own primitive:

```dart
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {this.emphasis = AppIconEmphasis.regular, super.key});

  final String name;
  final AppIconEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    return SolarIcon(
      name,
      style: switch (emphasis) {
        AppIconEmphasis.regular => SolarIconStyle.linear,
        AppIconEmphasis.selected => SolarIconStyle.bold,
        AppIconEmphasis.feature => SolarIconStyle.boldDuotone,
      },
      size: 24,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

enum AppIconEmphasis { regular, selected, feature }
```

Now the rest of the app uses `AppIcon(SolarIcons.home2, emphasis: AppIconEmphasis.selected)` — one place to change styling for every screen.

---

## Performance notes

**Behavior guarantees.** These are the design properties that make the package safe for production use:

1. **Const-constructible widget.** `SolarIcon` is `@immutable` and its constructor is `const`. The Flutter framework can cache and skip rebuilds when parent widgets rebuild with identical children.
2. **No allocation in the hot path beyond what `flutter_svg` requires.** The widget builds a `SvgPicture.asset` + `SizedBox.square` + (optionally) `ExcludeSemantics` — three widgets, no closures, no state.
3. **Strict layout box.** The `SizedBox.square` wrapper enforces the requested size — the icon never overflows or shrinks a parent unexpectedly.
4. **Idiomatic theming via `IconTheme`.** Matches the built-in `Icon` widget's resolution order, so wrapping subtrees in `IconTheme` (or setting `ThemeData.iconTheme`) themes every icon in the tree with no adapter code.
5. **Semantic hygiene.** Decorative icons (no `semanticLabel`) are wrapped in `ExcludeSemantics` — screen readers do not receive noise from every icon on screen.
6. **Assertion-guarded parameters.** Invalid values (for example `opacity: 2.0`) throw in debug mode; production builds strip the assertions but the widget still behaves gracefully.
7. **No dynamic dispatch.** Style-to-folder mapping is via an enum's `folderName` getter — no reflection, no runtime string manipulation beyond the asset path concatenation.
8. **Modern color handling.** Uses `withValues(alpha:)` for opacity composition — the modern, non-deprecated Flutter 3.27+ API.
9. **DevTools integration.** `debugFillProperties` reports every prop, so the widget shows up cleanly in the Flutter Inspector.

**Startup cost is effectively zero.** SVG files are read only when the corresponding `SolarIcon` widget first mounts. Package assets are bundled into the app's asset bundle but not decoded eagerly.

**Per-icon decode cost.** `flutter_svg` parses the SVG (a few hundred bytes) and rasterises to a `Picture` the first time an icon renders — typically well under 1 ms. Subsequent instances of the same icon (same path, same size) reuse the cached picture.

**In lists, first scroll is the bottleneck.** As new cards appear on screen, each unique icon decodes once. To avoid single-frame jank on long lists, precache (see [Precaching](#precaching-for-smooth-scrolling)).

**Widget rebuilds are cheap.** `SolarIcon` is a `const` constructor and `SvgPicture.asset` is efficient to rebuild — the widget layer does not re-decode the SVG.

**Bundle size**: about 23 MB uncompressed, roughly 4–5 MB after gzip. See [Reducing bundle size](#reducing-bundle-size) to trim.

**Do not** put an icon's size in a value that changes every frame (for example a raw animation controller value) — that forces layout recalculation. If you need to animate size, do so with `TweenAnimationBuilder` at reasonable durations, or animate the container's scale via `Transform.scale`.

---

## Testing

The package includes widget and unit tests under `test/`. Run them with:

```bash
flutter test
```

Example widget test — verifying the widget mounts with the expected props:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_iconkit/solar_iconkit.dart';

void main() {
  testWidgets('SolarIcon renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SolarIcon(SolarIcons.home2)),
    ));
    expect(find.byType(SolarIcon), findsOneWidget);
  });

  testWidgets('SolarIcon uses given style and color', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SolarIcon(
        SolarIcons.heart,
        style: SolarIconStyle.bold,
        size: 48,
        color: Color(0xFFFF0000),
      ),
    ));
    final widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
    expect(widget.style, SolarIconStyle.bold);
    expect(widget.size, 48);
    expect(widget.color, const Color(0xFFFF0000));
  });
}
```

For consuming apps that mock icons in golden tests, wrap `SolarIcon` in a test-friendly builder that returns a placeholder in test mode.

---

## Troubleshooting

**The icon renders as an empty space.**

Check that the icon name is correct. `SolarIcons.home2` resolves to `'home-2'`; typos silently produce a missing asset path. Programmatic usage should validate:

```dart
if (!SolarIcons.all.contains(name)) {
  throw ArgumentError('Unknown icon: $name');
}
```

**`Unable to load asset: assets/icons/linear/xxx.svg` at runtime.**

The base name exists in one style but not another (very rare upstream, but possible). Confirm by inspecting the file system under `packages/solar_iconkit/assets/icons/{style}/`. If the file is genuinely missing, please open an issue.

**"A value of type 'List<dynamic>' can't be assigned to 'List<String>'."**

The Dart analyzer occasionally infers `SolarIcons.all` as `List<dynamic>` right after the generated file changes. Force-refresh:

```bash
flutter clean
flutter pub get
```

Then restart the Dart analysis server in your IDE. In VS Code: `Command Palette > Dart: Restart Analysis Server`.

**Icons look pixelated.**

SVGs do not pixelate. If you observe blurriness, check for parent widgets applying non-integer `Transform.scale` or `FilterQuality.none`.

**Icon color does not update on theme change.**

Verify you are passing a color from `Theme.of(context)` (a rebuild-tracked source), not a captured constant. `SolarIcon` rebuilds when its `color` prop changes; the surrounding widget must also rebuild when the theme changes.

**`flutter_svg` version conflict with another package.**

`solar_iconkit` pins `flutter_svg: ^2.0.10`. If a peer package pins a lower version, run `flutter pub upgrade flutter_svg`. If two packages pin incompatible ranges, use `dependency_overrides` to force a single version.

---

## Package layout

```
solar_iconkit/
├── pubspec.yaml                            Package manifest and asset declarations.
├── README.md                               This document.
├── LICENSE                                 MIT license with Solar attribution.
├── CHANGELOG.md                            Versioned change history.
├── analysis_options.yaml                   Lint configuration.
├── .gitignore
├── lib/
│   ├── solar_iconkit.dart                    Public export barrel.
│   └── src/
│       ├── solar_icon.dart                 The SolarIcon widget.
│       ├── solar_icon_style.dart           The SolarIconStyle enum.
│       └── solar_iconkit_data.g.dart         Generated icon name constants.
├── assets/
│   └── icons/
│       ├── linear/                         Linear-style SVGs (1,231 files).
│       ├── outline/                        Outline-style SVGs.
│       ├── broken/                         Broken-style SVGs.
│       ├── bold/                           Bold-style SVGs.
│       ├── line_duotone/                   Line-duotone-style SVGs.
│       └── bold_duotone/                   Bold-duotone-style SVGs.
├── test/
│   └── solar_icon_test.dart                Widget and unit tests.
└── example/
    ├── pubspec.yaml                        Example app manifest (path-depends on parent).
    ├── README.md                           Example app notes.
    └── lib/main.dart                       Interactive icon browser.
```

---

## Versioning

The package follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html):

| Change | Version bump |
|---|---|
| Asset-only refresh (upstream tweaks with no name changes) | Patch (`0.1.0 -> 0.1.1`) |
| New icons added, existing behavior unchanged | Minor (`0.1.0 -> 0.2.0`) |
| Renamed / removed constants, changed widget API, changed default style | Major (`0.1.0 -> 1.0.0`) |

Breaking changes require coordinated upgrades across every consumer. Prefer additive changes where possible; when a break is unavoidable, document the migration path in `CHANGELOG.md`.

**Tagging discipline:** always cut a git tag for every published version (`git tag v0.1.1`). Consumers using the git dependency form should pin `ref:` to a tag, not a branch.

---

## License and attribution

- **Icons.** The Solar icon set is © 480 Design, released under the [MIT License](https://opensource.org/licenses/MIT). This package redistributes the SVGs unmodified.
- **Package code.** MIT License. See `LICENSE`.

When shipping an application that uses `solar_iconkit`, include the following attribution in your licenses/about screen:

> Icons: Solar by 480 Design, licensed under the MIT License.

Flutter's `showLicensePage()` automatically picks up `LICENSE` files from every dependency and displays them together — no additional integration is needed on the consumer side.

---

## Support

`solar_iconkit` is MIT-licensed and will always be free. If it saved you time in your Flutter project, a coffee helps me keep it updated, add features to the [icon browser](https://solar-icons-web.vercel.app), and build more open-source tools for the Flutter community.

[![Support on Ko-fi](https://img.shields.io/badge/Support%20on-Ko--fi-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/sovanken)

- Sponsor: <https://ko-fi.com/sovanken>
- Browse icons: <https://solar-icons-web.vercel.app>
- pub.dev: <https://pub.dev/packages/solar_iconkit>
