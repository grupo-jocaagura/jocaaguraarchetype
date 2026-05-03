import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('DsGalleryPage', () {
    testWidgets(
      'Given gallery page When index is tapped Then shows index page',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DsGalleryPage(),
          ),
        );

        await tester.tap(find.text('Index'));
        await tester.pumpAndSettle();

        expect(find.text('Design System Gallery Index'), findsOneWidget);
        expect(find.text('ModelThemeData'), findsOneWidget);
        expect(find.text('ModelDsExtendedTokens'), findsOneWidget);
      },
    );

    testWidgets(
      'Given index page When ModelDataVizPalette tile is tapped Then opens data viz page',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DsGalleryPage(),
          ),
        );

        await tester.tap(find.text('Index'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('ModelDataVizPalette'));
        await tester.pumpAndSettle();

        expect(find.text('ModelDataVizPalette'), findsWidgets);
        expect(find.text('Categorical'), findsOneWidget);
        expect(find.text('Sequential'), findsOneWidget);
      },
    );
  });
}
