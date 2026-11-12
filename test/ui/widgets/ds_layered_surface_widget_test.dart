import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Uses the DS radius token and clamps opacity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[
            DsExtendedTokensExtension(
              tokens: ModelDsExtendedTokens(borderRadiusXXl: 37),
            ),
          ],
        ),
        home: const DsLayeredSurfaceWidget(
          gradientColors: <Color>[Colors.red, Colors.blue],
          opacity: 2,
          child: SizedBox(width: 120, height: 80),
        ),
      ),
    );
    final Finder surface = find.byType(DsLayeredSurfaceWidget);
    expect(
      tester
          .widget<ClipRRect>(
            find.descendant(of: surface, matching: find.byType(ClipRRect)),
          )
          .borderRadius,
      BorderRadius.circular(37),
    );
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: surface, matching: find.byType(Opacity)),
          )
          .opacity,
      1,
    );
    expect(tester.takeException(), isNull);
  });
  for (final List<Color> colors in <List<Color>>[
    <Color>[],
    <Color>[Colors.red],
    <Color>[Colors.red, Colors.blue],
  ]) {
    testWidgets(
      'Layered surface paints ${colors.length} colors and its child',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsLayeredSurfaceWidget(
              gradientColors: colors,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 120,
                height: 80,
                child: Text('Content'),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Content'), findsOneWidget);
      },
    );
  }
  test('Texture repaints only when its colors change', () {
    const DsOrganicTexturePainter painter = DsOrganicTexturePainter(
      color: Colors.red,
      highlightColor: Colors.blue,
    );
    expect(painter.shouldRepaint(painter), isFalse);
    expect(
      painter.shouldRepaint(
        const DsOrganicTexturePainter(
          color: Colors.black,
          highlightColor: Colors.blue,
        ),
      ),
      isTrue,
    );
  });
}
