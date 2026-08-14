import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'solar_icon_style.dart';
import 'solar_iconkit_data.g.dart';

const double _kDefaultIconSize = 24.0;
const Color _kFallbackIconColor = Color(0xDD000000);

/// A drop-in icon widget that renders any Solar icon in any of the six native
/// styles.
///
/// Designed to integrate cleanly with Flutter's icon conventions:
///
/// * Reads size and color from the enclosing [IconTheme] when not overridden
///   directly on the widget (matching the behaviour of [Icon]).
/// * Falls back to a sane default (24 px, opaque black) only when no context
///   is available.
/// * Uses `ColorFilter.mode(..., BlendMode.srcIn)` by default so duotone
///   variants keep their opacity-based accent while still respecting the
///   caller's color. The blend mode is configurable via [blendMode].
/// * Optional drop shadows via [shadows], mirroring Flutter's built-in [Icon].
/// * Wraps decorative usages with [ExcludeSemantics] to avoid noise from
///   screen readers when no [semanticLabel] is supplied.
/// * Is `const`-constructible and immutable, so it can be reused freely in
///   large widget trees without triggering rebuilds.
///
/// ### Basic usage
///
/// ```dart
/// SolarIcon(SolarIcons.home2)
/// ```
///
/// ### Full form
///
/// ```dart
/// SolarIcon(
///   SolarIcons.rocket,
///   style: SolarIconStyle.boldDuotone,
///   size: 32,
///   color: Theme.of(context).colorScheme.primary,
///   shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
///   semanticLabel: 'Launch',
/// )
/// ```
///
/// See the package README for detailed usage patterns and performance notes.
@immutable
class SolarIcon extends StatelessWidget {
  /// Creates a Solar icon.
  ///
  /// [name] must be a valid Solar base name (see [SolarIcons] for the full,
  /// autocomplete-safe catalog). Any string is accepted but a missing asset
  /// renders as empty space at build time.
  const SolarIcon(
    this.name, {
    super.key,
    this.style = SolarIconStyle.linear,
    this.size,
    this.color,
    this.opacity = 1.0,
    this.semanticLabel,
    this.textDirection,
    this.matchTextDirection = false,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.blendMode = BlendMode.srcIn,
    this.shadows,
  }) : assert(opacity >= 0.0 && opacity <= 1.0,
            'SolarIcon.opacity must be between 0.0 and 1.0');

  /// The base icon name, for example `'home-2'`. Use [SolarIcons] constants
  /// for autocomplete-safe references.
  final String name;

  /// The visual style. Defaults to [SolarIconStyle.linear].
  final SolarIconStyle style;

  /// Width and height in logical pixels.
  ///
  /// When null, the widget reads from [IconTheme.of] on the enclosing context.
  /// If [IconTheme] does not provide a size either, defaults to 24 px.
  final double? size;

  /// Fill/stroke color applied via [ColorFilter.mode] with the current
  /// [blendMode] (default [BlendMode.srcIn]).
  ///
  /// When null, the widget reads [IconTheme.color] from the enclosing context.
  /// If [IconTheme] does not provide a color either, defaults to a near-opaque
  /// black (`Color(0xDD000000)`) that matches Material's default icon color.
  final Color? color;

  /// A multiplier applied on top of [color]'s alpha. Combined with
  /// [IconTheme.opacity]. Must be between 0.0 and 1.0 inclusive.
  ///
  /// Defaults to 1.0.
  final double opacity;

  /// Accessibility label read by screen readers.
  ///
  /// When null, the widget wraps its rendered SVG in [ExcludeSemantics] so
  /// decorative icons do not produce audible noise.
  final String? semanticLabel;

  /// If [matchTextDirection] is true and this is null, [Directionality.of] is
  /// used. See [SvgPicture.matchTextDirection].
  final TextDirection? textDirection;

  /// Mirror the icon horizontally when the ambient [Directionality] is RTL.
  ///
  /// Useful for directional icons like arrows and chevrons that must flip in
  /// right-to-left locales. Defaults to false.
  final bool matchTextDirection;

  /// How to inscribe the icon into the size box. Defaults to [BoxFit.contain].
  final BoxFit fit;

  /// How to align the icon within its bounding box. Defaults to
  /// [Alignment.center].
  final AlignmentGeometry alignment;

  /// The [BlendMode] used to composite [color] onto the SVG.
  ///
  /// Defaults to [BlendMode.srcIn], which replaces the source color while
  /// keeping the source alpha — the standard "recolor an icon" behaviour.
  ///
  /// Set to [BlendMode.multiply] or [BlendMode.plus] for advanced effects
  /// where you want the icon to interact with the background instead of
  /// fully replacing pixels. Set to [BlendMode.dst] to disable recoloring
  /// entirely and render the icon in its native SVG colors.
  final BlendMode blendMode;

  /// Optional drop shadows painted underneath the icon.
  ///
  /// Mirrors the [Icon.shadows] parameter from Flutter's built-in [Icon].
  /// When non-empty, the shadows are drawn as blurred, offset copies of the
  /// icon behind the main render. Cheap for a couple of shadows; avoid
  /// large lists in scrolling contexts.
  ///
  /// Example:
  /// ```dart
  /// SolarIcon(
  ///   SolarIcons.heart,
  ///   style: SolarIconStyle.bold,
  ///   color: Colors.red,
  ///   shadows: const [
  ///     Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
  ///   ],
  /// )
  /// ```
  final List<Shadow>? shadows;

  /// Returns the asset path used to load this icon.
  ///
  /// Useful for advanced cases where you need the raw path — for example when
  /// preloading with [precachePicture] or embedding the SVG in a custom widget.
  ///
  /// Retired names are resolved through [SolarIcons.legacyAliases] first, so
  /// `assetPath('magnifer', ...)` returns the path to `magnifier.svg`.
  static String assetPath(String name, SolarIconStyle style) =>
      'assets/icons/${style.folderName}/${resolveName(name)}.svg';

  /// Maps a possibly-retired icon name to the name actually shipped as an
  /// asset. Returns [name] unchanged when it is already current.
  ///
  /// Solar renames icons upstream from time to time. This package keeps the
  /// old names working — see [SolarIcons.legacyAliases] for the full table.
  static String resolveName(String name) =>
      SolarIcons.legacyAliases[name] ?? name;

  /// The package name used when loading assets. Consumers rarely need this;
  /// exposed for advanced integrations.
  static const String packageName = 'solar_iconkit';

  @override
  Widget build(BuildContext context) {
    // Debug-only: validate that [name] refers to a real Solar icon. The
    // assert is stripped in release builds so this has zero production cost.
    // A typo throws a clear FlutterError with a stack trace pointing to the
    // offending call site — much better than silently rendering blank.
    assert(_debugAssertKnownIcon(name));
    final IconThemeData iconTheme = IconTheme.of(context);
    final double resolvedSize = size ?? iconTheme.size ?? _kDefaultIconSize;
    final Color baseColor = color ?? iconTheme.color ?? _kFallbackIconColor;
    final double effectiveOpacity = opacity * (iconTheme.opacity ?? 1.0);
    // Compose alpha from the caller's opacity and any IconTheme opacity.
    // Uses withValues (Flutter 3.27+); the pubspec Flutter minimum enforces this.
    final Color resolvedColor = effectiveOpacity < 1.0
        ? baseColor.withValues(alpha: baseColor.a * effectiveOpacity)
        : baseColor;

    Widget picture = SvgPicture.asset(
      assetPath(name, style),
      package: packageName,
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: ColorFilter.mode(resolvedColor, blendMode),
      fit: fit,
      alignment: alignment,
      matchTextDirection: matchTextDirection,
      semanticsLabel: semanticLabel,
    );

    // Enforce a strict box so the icon never lays out larger than requested.
    // This helps consistent alignment in Rows, ListTiles, and Buttons.
    picture = SizedBox.square(dimension: resolvedSize, child: picture);

    // Drop shadows are painted via a Stack of blurred copies. Kept cheap by
    // sharing the same SvgPicture widget for the shadow layer.
    if (shadows != null && shadows!.isNotEmpty) {
      final List<Widget> layers = <Widget>[
        for (final shadow in shadows!)
          Positioned(
            left: shadow.offset.dx,
            top: shadow.offset.dy,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: shadow.blurRadius,
                sigmaY: shadow.blurRadius,
              ),
              child: _shadowLayer(resolvedSize, shadow.color),
            ),
          ),
        picture,
      ];
      picture = SizedBox.square(
        dimension: resolvedSize,
        child: Stack(clipBehavior: Clip.none, children: layers),
      );
    }

    if (semanticLabel == null) {
      picture = ExcludeSemantics(child: picture);
    }

    return picture;
  }

  /// Renders a solid-color copy of the icon for use as a shadow layer.
  Widget _shadowLayer(double dimension, Color shadowColor) {
    return SizedBox.square(
      dimension: dimension,
      child: SvgPicture.asset(
        assetPath(name, style),
        package: packageName,
        width: dimension,
        height: dimension,
        colorFilter: ColorFilter.mode(shadowColor, BlendMode.srcIn),
        fit: fit,
        alignment: alignment,
        matchTextDirection: matchTextDirection,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name))
      ..add(EnumProperty<SolarIconStyle>('style', style))
      ..add(DoubleProperty('size', size, defaultValue: null))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(DoubleProperty('opacity', opacity, defaultValue: 1.0))
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null))
      ..add(FlagProperty('matchTextDirection',
          value: matchTextDirection,
          ifTrue: 'matches text direction',
          defaultValue: false))
      ..add(EnumProperty<BoxFit>('fit', fit, defaultValue: BoxFit.contain))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment,
          defaultValue: Alignment.center))
      ..add(EnumProperty<BlendMode>('blendMode', blendMode,
          defaultValue: BlendMode.srcIn))
      ..add(IterableProperty<Shadow>('shadows', shadows, defaultValue: null));
  }
}

/// Validates that [name] refers to a real Solar icon and throws a detailed
/// [FlutterError] if not. Called from an `assert` on [SolarIcon]'s constructor,
/// so this function only runs in debug/profile builds — release builds strip
/// assertions and never touch the lookup [Set].
///
/// Returns `true` when the name is valid so `assert(_debugAssertKnownIcon(...))`
/// stays quiet. Never returns `false`: an invalid name throws instead, giving
/// consumers a stack trace that points to the offending call site.
bool _debugAssertKnownIcon(String name) {
  if (_iconNameLookup.contains(name)) return true;
  if (SolarIcons.legacyAliases.containsKey(name)) return true;
  throw FlutterError.fromParts(<DiagnosticsNode>[
    ErrorSummary('SolarIcon received an unknown icon name: "$name".'),
    ErrorDescription(
      'The name did not match any of the ${_iconNameLookup.length} icons '
      'in the Solar catalog. This usually indicates a typo.',
    ),
    ErrorHint(
      'Use the SolarIcons.<name> constants (for example SolarIcons.home2) '
      'so the Dart analyzer catches typos at compile time. Browse the full '
      'catalog at https://solar-icons-web.vercel.app.',
    ),
  ]);
}

/// Lazily-built `Set<String>` for O(1) icon name lookups. Populated the first
/// time [_debugAssertKnownIcon] is called. Because `assert` is compiled out of
/// release builds, this Set is only ever allocated in debug/profile modes.
final Set<String> _iconNameLookup = SolarIcons.all.toSet();
