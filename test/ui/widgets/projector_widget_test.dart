import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ProjectorWidget', () {
    testWidgets(
      'Given wide-enough height When layout is taller than projected height Then it fits by width (no height overflow branch)',
      (WidgetTester tester) async {
        // Arrange
        const double designWidth = 200;
        const double designHeight = 400; // aspect = 0.5
        const Size hostSize =
            Size(300, 800); // widthScale=300 heightScale=600 (<=800)
        const Key childKey = Key('child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: hostSize.width,
                height: hostSize.height,
                child: const ProjectorWidget(
                  designWidth: designWidth,
                  designHeight: designHeight,
                  child: SizedBox(key: childKey),
                ),
              ),
            ),
          ),
        );

        // Assert: child exists
        expect(find.byKey(childKey), findsOneWidget);

        // Assert: inner fixed canvas SizedBox exists (designWidth x designHeight)
        final Finder descendantSizedBoxes = find.descendant(
          of: find.byType(ProjectorWidget),
          matching: find.byType(SizedBox),
        );

        final List<SizedBox> sizedBoxes = tester
            .widgetList<SizedBox>(descendantSizedBoxes)
            .toList(growable: false);

        final bool hasInnerDesignBox = sizedBoxes.any((SizedBox s) {
          return (s.width != null && s.height != null) &&
              (s.width! - designWidth).abs() < 0.001 &&
              (s.height! - designHeight).abs() < 0.001;
        });
        expect(hasInnerDesignBox, isTrue);

        // Assert: outer scaled box should be 300 x 600
        const double expectedWidthScale = 300;
        const double expectedHeightScale = 600;

        final bool hasOuterScaledBox = sizedBoxes.any((SizedBox s) {
          return (s.width != null && s.height != null) &&
              (s.width! - expectedWidthScale).abs() < 0.001 &&
              (s.height! - expectedHeightScale).abs() < 0.001;
        });
        expect(hasOuterScaledBox, isTrue);
      },
    );

    testWidgets(
      'Given limited height When projected height exceeds constraints Then it fits by height (height overflow branch)',
      (WidgetTester tester) async {
        // Arrange
        const double designWidth = 200;
        const double designHeight = 400; // aspect = 0.5
        const Size hostSize = Size(
          500,
          500,
        ); // widthScale=500 heightScale=1000 -> overflow -> 250 x 500
        const Key childKey = Key('child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: hostSize.width,
                height: hostSize.height,
                child: const ProjectorWidget(
                  designWidth: designWidth,
                  designHeight: designHeight,
                  child: SizedBox(key: childKey),
                ),
              ),
            ),
          ),
        );

        // Assert: child exists
        expect(find.byKey(childKey), findsOneWidget);

        // Assert: outer scaled box should be 250 x 500
        final Finder descendantSizedBoxes = find.descendant(
          of: find.byType(ProjectorWidget),
          matching: find.byType(SizedBox),
        );

        final List<SizedBox> sizedBoxes = tester
            .widgetList<SizedBox>(descendantSizedBoxes)
            .toList(growable: false);

        const double expectedWidthScale = 250;
        const double expectedHeightScale = 500;

        final bool hasOuterScaledBox = sizedBoxes.any((SizedBox s) {
          return (s.width != null && s.height != null) &&
              (s.width! - expectedWidthScale).abs() < 0.001 &&
              (s.height! - expectedHeightScale).abs() < 0.001;
        });
        expect(hasOuterScaledBox, isTrue);
      },
    );

    testWidgets(
      'Given debug true When building Then it paints an amber canvas background',
      (WidgetTester tester) async {
        // Arrange
        const Key childKey = Key('child');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 800,
                child: ProjectorWidget(
                  debug: true,
                  child: SizedBox(key: childKey),
                ),
              ),
            ),
          ),
        );

        // Assert: debug container exists and is amber
        final Finder containerFinder = find.descendant(
          of: find.byType(ProjectorWidget),
          matching: find.byType(Container),
        );

        expect(containerFinder, findsOneWidget);

        final Container container = tester.widget<Container>(containerFinder);
        expect(container.color, equals(Colors.amber));
      },
    );
  });
}
