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
  linear('linear'),
  outline('outline'),
  broken('broken'),
  bold('bold'),
  lineDuotone('line_duotone'),
  boldDuotone('bold_duotone');

  const SolarIconStyle(this.folderName);

  /// Asset folder for this style within the package.
  final String folderName;
}
