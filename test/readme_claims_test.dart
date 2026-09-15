import 'package:flutter_test/flutter_test.dart';
import 'package:solar_iconkit/solar_iconkit.dart';

void main() {
  test('every factual claim the README makes', () {
    expect(SolarIcons.all.length, 1269, reason: '1,269 icons');
    expect(SolarIconStyle.values.length, 6, reason: '6 styles');
    expect(SolarIcons.all.length * 6, 7614, reason: '7,614 SVG variants');
    expect(SolarIcons.categories.length, 37, reason: '37 categories');
    expect(SolarIcons.categories['Arrows']!.length, 67);
    expect(SolarIcons.categoryOf('home-2'), 'UI');
    expect(SolarIcons.categoryOf('magnifier'), 'Search');
    expect(SolarIcons.categoryOf('magnifer'), 'Search');
    expect(SolarIcons.categoryOf('not-an-icon'), isNull);
    expect(SolarIcons.home2, 'home-2');
    expect(SolarIcons.legacyAliases.length, 57);
    // Names used in README examples must exist.
    for (final n in ['home-2', 'heart', 'rocket', 'magnifier', 'arrow-right']) {
      expect(SolarIcons.all, contains(n), reason: '$n used in README');
    }
    // trellis: in all, but in no category.
    expect(SolarIcons.all, contains('trellis'));
    expect(SolarIcons.categoryOf('trellis'), isNull);
    // Defaults quoted in the README.
    expect(SolarIcon.assetBasePath, 'assets/icons');
    expect(SolarIcon.assetPackage, 'solar_iconkit');
  });
}
