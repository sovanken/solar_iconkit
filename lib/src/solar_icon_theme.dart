import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'solar_icon_style.dart';

/// Sets the default [SolarIconStyle] for every [SolarIcon] beneath it.
///
/// [SolarIcon] already inherits its size, color and opacity from the ambient
/// [IconTheme]; style was the one property that could not be set once for a
/// subtree, so an app with a house style had to repeat `style:` at every call
/// site or wrap the widget. This closes that gap.
///
/// ```dart
/// SolarIconTheme(
///   style: SolarIconStyle.boldDuotone,
///   child: MyApp(),
/// )
/// ```
///
/// An explicit `style:` on the widget always wins, and nesting works the way
/// [IconTheme] does — the nearest ancestor applies:
///
/// ```dart
/// SolarIconTheme(
///   style: SolarIconStyle.linear,
///   child: Column(
///     children: [
///       SolarIcon(SolarIcons.home2),                         // linear
///       SolarIcon(SolarIcons.home2, style: SolarIconStyle.bold), // bold
///       SolarIconTheme(
///         style: SolarIconStyle.broken,
///         child: SolarIcon(SolarIcons.home2),                // broken
///       ),
///     ],
///   ),
/// )
/// ```
@immutable
class SolarIconTheme extends InheritedWidget {
  /// Creates a style default for [child] and its descendants.
  const SolarIconTheme({
    super.key,
    required this.style,
    required super.child,
  });

  /// The style descendant [SolarIcon]s use when they do not specify one.
  final SolarIconStyle style;

  /// The style from the nearest enclosing [SolarIconTheme], or null when
  /// there is none.
  ///
  /// Use this when you need to distinguish "no theme" from "a theme that
  /// happens to be linear". Most code wants [of].
  static SolarIconStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SolarIconTheme>()?.style;

  /// The style from the nearest enclosing [SolarIconTheme], or
  /// [SolarIconStyle.linear] when there is none.
  ///
  /// This is the package default, so a [SolarIcon] with no `style:` and no
  /// enclosing theme renders exactly as it always has.
  static SolarIconStyle of(BuildContext context) =>
      maybeOf(context) ?? SolarIconStyle.linear;

  @override
  bool updateShouldNotify(SolarIconTheme oldWidget) => style != oldWidget.style;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<SolarIconStyle>('style', style));
  }
}
