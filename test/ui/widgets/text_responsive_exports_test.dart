import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype_text_responsive.dart'
    as text;
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('both entrypoints expose the same widgets inside material_ui', (
    WidgetTester tester,
  ) async {
    expect(const text.InlineTextWidget('Inline'), isA<InlineTextWidget>());
    expect(
      const text.ParagraphTextWidget('Paragraph'),
      isA<ParagraphTextWidget>(),
    );
    expect(
      const text.TextResponsiveWidget(child: Text('Text')),
      isA<TextResponsiveWidget>(),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              SizedBox(
                width: 180,
                height: 40,
                child: InlineTextWidget('Inline'),
              ),
              SizedBox(
                width: 180,
                height: 60,
                child: ParagraphTextWidget('Paragraph'),
              ),
              SizedBox(
                width: 90,
                height: 30,
                child: TextResponsiveWidget(
                  child: Text(
                    'A long title to shrink',
                    maxLines: 1,
                    style: TextStyle(fontSize: 24),
                    textDirection: TextDirection.rtl,
                    textScaler: TextScaler.linear(1.5),
                    semanticsLabel: 'Accessible title',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final Text resized = tester.widget<Text>(
      find.text('A long title to shrink'),
    );
    expect(resized.style!.fontSize, lessThan(24));
    expect(resized.textDirection, TextDirection.rtl);
    expect(resized.textScaler!.scale(10), 15);
    expect(resized.semanticsLabel, 'Accessible title');
  });
}
