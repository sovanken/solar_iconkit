/// The six native Solar icon styles.
///
/// Each style has a distinct visual character:
/// - [linear]: thin 1.5px stroke outline (default)
/// - [outline]: filled shape with evenodd cutouts (macOS-style outline)
/// - [broken]: 1.5px stroke with intentional gaps
/// - [bold]: fully filled solid shape
/// - [lineDuotone]: linear stroke + 50% opacity accent
/// - [boldDuotone]: bold fill + 50% opacity accent
enum SolarIconStyle {
  /// Thin 1.5 px hairline stroke outline. The default style.
  linear('linear'),

  /// Filled shape with evenodd cutouts (macOS-style outline).
  outline('outline'),

  /// 1.5 px stroke with intentional gaps for a friendly, casual feel.
  broken('broken'),

  /// Fully filled solid shape — high contrast, strong presence.
  bold('bold'),

  /// Linear stroke plus a secondary path at 50 % opacity.
  lineDuotone('line_duotone'),

  /// Bold fill plus a secondary path at 50 % opacity — richest style.
  boldDuotone('bold_duotone');

  const SolarIconStyle(this.folderName);

  /// Asset folder for this style within the package.
  final String folderName;
}
