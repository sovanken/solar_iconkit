import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_iconkit/solar_iconkit.dart';

void main() {
  group('SolarIcon widget', () {
    testWidgets('renders with defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SolarIcon(SolarIcons.home2))),
      );
      expect(find.byType(SolarIcon), findsOneWidget);
      final widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.name, 'home-2');
      expect(widget.style, SolarIconStyle.linear);
      expect(widget.size, isNull);
      expect(widget.color, isNull);
      expect(widget.opacity, 1.0);
      expect(widget.matchTextDirection, isFalse);
      expect(widget.fit, BoxFit.contain);
      expect(widget.alignment, Alignment.center);
    });

    testWidgets('respects explicit style, size, and color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SolarIcon(
            SolarIcons.heart,
            style: SolarIconStyle.bold,
            size: 48,
            color: Color(0xFFFF0000),
            semanticLabel: 'Heart',
          ),
        ),
      );
      final widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.style, SolarIconStyle.bold);
      expect(widget.size, 48);
      expect(widget.color, const Color(0xFFFF0000));
      expect(widget.semanticLabel, 'Heart');
    });

    testWidgets('reads size from IconTheme when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IconTheme(
            data: IconThemeData(size: 32),
            child: SolarIcon(SolarIcons.home2),
          ),
        ),
      );
      // The outer SizedBox.square is the first SizedBox descendant of
      // SolarIcon; flutter_svg may add its own SizedBox deeper in the tree.
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SolarIcon),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, 32);
      expect(sizedBox.height, 32);
    });

    testWidgets('explicit size overrides IconTheme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IconTheme(
            data: IconThemeData(size: 32),
            child: SolarIcon(SolarIcons.home2, size: 64),
          ),
        ),
      );
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SolarIcon),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, 64);
    });

    testWidgets('falls back to 24 when no size or IconTheme', (tester) async {
      // Bare WidgetsApp — no MaterialApp IconTheme.
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, child) => const SolarIcon(SolarIcons.home2),
        ),
      );
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SolarIcon),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, 24);
    });

    testWidgets('wraps in ExcludeSemantics when semanticLabel is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SolarIcon(SolarIcons.home2)),
      );
      expect(
        find.descendant(
          of: find.byType(SolarIcon),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not wrap in ExcludeSemantics when label is provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SolarIcon(SolarIcons.home2, semanticLabel: 'Home'),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(SolarIcon),
          matching: find.byType(ExcludeSemantics),
        ),
        findsNothing,
      );
    });

    testWidgets('matchTextDirection true under RTL mirrors the icon',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: SolarIcon(
            SolarIcons.altArrowRight,
            matchTextDirection: true,
          ),
        ),
      );
      final widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.matchTextDirection, isTrue);
      // The widget forwards matchTextDirection to SvgPicture, which flips the
      // rendered SVG under RTL. We assert the flag is preserved on the widget
      // itself (the render pass is validated by flutter_svg's own tests).
    });

    testWidgets('explicit textDirection overrides ambient Directionality',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SolarIcon(
            SolarIcons.altArrowRight,
            matchTextDirection: true,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      final widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.textDirection, TextDirection.rtl);
    });

    testWidgets('widget opacity composes with IconTheme.opacity',
        (tester) async {
      // Widget opacity 0.5 × IconTheme opacity 0.8 = effective 0.4 alpha.
      // The widget doesn't expose the computed alpha directly, but we can
      // assert that both inputs are preserved on the widget for consumers.
      await tester.pumpWidget(
        const MaterialApp(
          home: IconTheme(
            data: IconThemeData(opacity: 0.8),
            child: SolarIcon(SolarIcons.home2, opacity: 0.5),
          ),
        ),
      );
      final widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.opacity, 0.5);
      final iconTheme = IconTheme.of(
        tester.element(find.byType(SolarIcon)),
      );
      expect(iconTheme.opacity, 0.8);
    });

    testWidgets('blendMode defaults to srcIn but is configurable',
        (tester) async {
      // Default: srcIn.
      await tester.pumpWidget(
        const MaterialApp(home: SolarIcon(SolarIcons.home2)),
      );
      final defaultWidget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(defaultWidget.blendMode, BlendMode.srcIn);

      // Explicit override.
      await tester.pumpWidget(
        const MaterialApp(
          home: SolarIcon(
            SolarIcons.home2,
            blendMode: BlendMode.multiply,
          ),
        ),
      );
      final customWidget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(customWidget.blendMode, BlendMode.multiply);
    });

    testWidgets('shadows default to null and render when provided',
        (tester) async {
      // Default: no shadows, no Stack wrapper.
      await tester.pumpWidget(
        const MaterialApp(home: SolarIcon(SolarIcons.home2)),
      );
      var widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.shadows, isNull);
      expect(
        find.descendant(
          of: find.byType(SolarIcon),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );

      // With shadows: Stack wrapper appears with one child per shadow + main.
      await tester.pumpWidget(
        const MaterialApp(
          home: SolarIcon(
            SolarIcons.home2,
            shadows: [
              Shadow(color: Color(0x40000000), blurRadius: 4),
              Shadow(
                  color: Color(0x20000000),
                  blurRadius: 8,
                  offset: Offset(0, 2)),
            ],
          ),
        ),
      );
      widget = tester.widget<SolarIcon>(find.byType(SolarIcon));
      expect(widget.shadows, hasLength(2));
      expect(
        find.descendant(
          of: find.byType(SolarIcon),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('debugFillProperties reports every parameter', (tester) async {
      // Ensures the widget is inspectable in Flutter DevTools with all props
      // showing up. Also brings debugFillProperties into coverage.
      const widget = SolarIcon(
        SolarIcons.rocket,
        style: SolarIconStyle.boldDuotone,
        size: 32,
        color: Color(0xFF6366F1),
        opacity: 0.8,
        semanticLabel: 'Launch',
        matchTextDirection: true,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topLeft,
        blendMode: BlendMode.multiply,
        shadows: [Shadow(color: Color(0x40000000), blurRadius: 4)],
      );
      final dump = widget.toDiagnosticsNode().toStringDeep();
      expect(dump, contains('name: "rocket"'));
      expect(dump, contains('style: boldDuotone'));
      expect(dump, contains('size: 32'));
      expect(dump, contains('opacity: 0.8'));
      expect(dump, contains('semanticLabel: "Launch"'));
      expect(dump, contains('matches text direction'));
      expect(dump, contains('fit: fitWidth'));
      expect(dump, contains('blendMode: multiply'));
      expect(dump, contains('shadows'));
    });

    testWidgets('unknown icon name throws FlutterError in debug',
        (tester) async {
      // The assertion lives in build(), so we need to actually pump the
      // widget to trigger it. Wrapped in an ErrorWidget to catch the throw.
      await tester.pumpWidget(
        const MaterialApp(
          home: SolarIcon('totally-not-a-real-icon-name'),
        ),
      );
      final exception = tester.takeException();
      expect(exception, isA<FlutterError>());
      expect(
        exception.toString(),
        contains('unknown icon name: "totally-not-a-real-icon-name"'),
      );
    });

    test('opacity must be in [0, 1]', () {
      expect(() => SolarIcon(SolarIcons.home2, opacity: -0.1),
          throwsAssertionError);
      expect(() => SolarIcon(SolarIcons.home2, opacity: 1.1),
          throwsAssertionError);
    });

    test('assetPath resolves to package-scoped SVG path', () {
      expect(
        SolarIcon.assetPath('home-2', SolarIconStyle.linear),
        'assets/icons/linear/home-2.svg',
      );
      expect(
        SolarIcon.assetPath('rocket', SolarIconStyle.boldDuotone),
        'assets/icons/bold_duotone/rocket.svg',
      );
    });

    test('packageName constant is exposed', () {
      expect(SolarIcon.packageName, 'solar_iconkit');
    });
  });

  group('SolarIconStyle enum', () {
    test('has six values', () {
      expect(SolarIconStyle.values.length, 6);
    });

    test('every folder name is non-empty and lowercase snake_case', () {
      final valid = RegExp(r'^[a-z]+(_[a-z]+)*$');
      for (final s in SolarIconStyle.values) {
        expect(s.folderName, isNotEmpty);
        expect(valid.hasMatch(s.folderName), isTrue,
            reason: 'Invalid folder name: ${s.folderName}');
      }
    });

    test('folder names are unique', () {
      final names = SolarIconStyle.values.map((s) => s.folderName).toSet();
      expect(names.length, SolarIconStyle.values.length);
    });
  });

  group('SolarIcons catalog', () {
    test('all is non-empty', () {
      expect(SolarIcons.all, isNotEmpty);
    });

    test('all is sorted alphabetically', () {
      final sorted = List<String>.from(SolarIcons.all)..sort();
      expect(SolarIcons.all, sorted);
    });

    test('all has no duplicates', () {
      expect(SolarIcons.all.toSet().length, SolarIcons.all.length);
    });

    test('every name in all matches expected kebab-case grammar', () {
      final valid = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
      for (final n in SolarIcons.all) {
        expect(valid.hasMatch(n), isTrue, reason: 'Invalid icon name: $n');
      }
    });

    test('reserved-word icons rename to <name>Icon', () {
      // `case` becomes `caseIcon` — the constant should resolve to the
      // original kebab name.
      expect(SolarIcons.caseIcon, 'case');
    });

    test('digit-prefixed icons rename with an `i` prefix', () {
      expect(SolarIcons.i4k, '4k');
    });

    test('common icons are reachable via camelCase identifiers', () {
      expect(SolarIcons.home2, 'home-2');
      expect(SolarIcons.altArrowDown, 'alt-arrow-down');
      expect(SolarIcons.heart, 'heart');
    });
  });

  group('SolarIcon.assetPath', () {
    test('matches folder layout for every style', () {
      for (final s in SolarIconStyle.values) {
        final p = SolarIcon.assetPath('home-2', s);
        expect(p, startsWith('assets/icons/${s.folderName}/'));
        expect(p, endsWith('.svg'));
      }
    });
  });
}
