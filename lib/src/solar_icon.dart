import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'solar_icon_style.dart';

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
/// * Uses `ColorFilter.mode(..., BlendMode.srcIn)` so duotone variants keep
///   their opacity-based accent while still respecting the caller's color.
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

  /// Fill/stroke color applied via [ColorFilter.mode] with [BlendMode.srcIn].
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

  /// Returns the asset path used to load this icon.
  ///
  /// Useful for advanced cases where you need the raw path — for example when
  /// preloading with [precachePicture] or embedding the SVG in a custom widget.
  static String assetPath(String name, SolarIconStyle style) =>
      'assets/icons/${style.folderName}/$name.svg';

  /// The package name used when loading assets. Consumers rarely need this;
  /// exposed for advanced integrations.
  static const String packageName = 'solar_iconkit';

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double resolvedSize = size ?? iconTheme.size ?? _kDefaultIconSize;
    final Color baseColor = color ?? iconTheme.color ?? _kFallbackIconColor;
    final double effectiveOpacity = opacity * (iconTheme.opacity ?? 1.0);
    // Compose alpha from the caller's opacity and any IconTheme opacity.
    // Uses Color.fromARGB so we don't depend on `withOpacity` (deprecated in
    // Flutter 3.27+) or `withValues` (unavailable before 3.27).
    final Color resolvedColor = effectiveOpacity < 1.0
        ? Color.fromARGB(
            (baseColor.alpha * effectiveOpacity).round(),
            baseColor.red,
            baseColor.green,
            baseColor.blue,
          )
        : baseColor;

    Widget picture = SvgPicture.asset(
      assetPath(name, style),
      package: packageName,
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      fit: fit,
      alignment: alignment,
      matchTextDirection: matchTextDirection,
      semanticsLabel: semanticLabel,
    );

    // Enforce a strict box so the icon never lays out larger than requested.
    // This helps consistent alignment in Rows, ListTiles, and Buttons.
    picture = SizedBox.square(dimension: resolvedSize, child: picture);

    if (semanticLabel == null) {
      picture = ExcludeSemantics(child: picture);
    }

    return picture;
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
          defaultValue: Alignment.center));
  }
}
