@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_iconkit/solar_iconkit.dart';

/// Golden (visual regression) tests.
///
/// One golden per [SolarIconStyle] renders `solar:home-2` at a fixed size and
/// color. If flutter_svg upgrades or the SolarIcon widget layout regresses,
/// the goldens will fail visibly.
///
/// Regenerate the reference PNGs with:
/// ```bash
/// flutter test test/golden_test.dart --update-goldens
/// ```
///
/// Golden files land under `test/goldens/`.
void main() {
  group('SolarIcon golden', () {
    for (final style in SolarIconStyle.values) {
      testWidgets('home-2 ${style.name}', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: const Color(0xFFF7F7F7),
              body: Center(
                child: SolarIcon(
                  SolarIcons.home2,
                  style: style,
                  size: 96,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        );
        // Give flutter_svg time to decode the SVG asset.
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(SolarIcon),
          matchesGoldenFile('goldens/home-2-${style.name}.png'),
        );
      });
    }
  });
}
